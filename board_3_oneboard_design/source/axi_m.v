//接口定义最好和赛灵思/ARM文档保持一致，下面直接拷贝了IP核的模块接口和参数
	module AXI_FULL_M #
	(
        parameter integer VIDEO_LENGTH      = 1920                            ,
        parameter integer VIDEO_HIGTH       = 1080                            ,
        parameter integer PIXEL_WIDTH       = 32                              ,
		parameter integer CTRL_ADDR_WIDTH	= 28                              ,
		parameter integer DQ_WIDTH	        = 32                              ,
        parameter integer M_AXI_BRUST_LEN   = 8                               ,
        parameter integer VIDEO_BASE_ADDR   = 2'd0                            
	)
	(

		input wire                                    DDR_INIT_DONE           ,
		input wire                                    M_AXI_ACLK              ,
		input wire                                    M_AXI_ARESETN           ,
		//写地址通道↓                                                              
		output wire [CTRL_ADDR_WIDTH-1 : 0]           M_AXI_AWADDR            ,
		output wire                                   M_AXI_AWVALID           ,
		input wire                                    M_AXI_AWREADY           ,
		//写数据通道↓                                                              
		input wire                                    M_AXI_WLAST             ,
		input wire                                    M_AXI_WREADY            ,
		//写响应通道↓                                                              
		//读地址通道↓                                                              
		output wire [CTRL_ADDR_WIDTH-1 : 0]           M_AXI_ARADDR            ,
		output wire                                   M_AXI_ARVALID           ,
		input wire                                    M_AXI_ARREADY           ,
		//读数据通道↓                                                              
		input wire                                    M_AXI_RLAST             ,
		input wire                                    M_AXI_RVALID            ,
        //video
        input wire                                    vs_in                   ,
        input wire                                    vs_out                  ,
        //fifo信号
        input wire  [8 : 0]                           wfifo_rd_water_level    ,
        output                                        wfifo_rd_req            /* synthesis PAP_MARK_DEBUG="1" */,
        output                                        wfifo_pre_rd_req        /* synthesis PAP_MARK_DEBUG="1" */,
        input wire  [8 : 0]                           rfifo_wr_water_level    ,
        output                                        rfifo_wr_req            ,
        output reg                                    r_fram_done             ,
        //其他
        input       [19 : 0]                          wr_addr_min             ,//写数据ddr最小地址0地址开始算，1920*1080*16 = 33177600 bits
        input       [19 : 0]                          wr_addr_max             ,//写数据ddr最大地址，一个地址存32位 33177600/32 = 1036800 = 20'b1111_1101_0010_0000_0000
        output reg                                    r_wr_rst                ,
        output reg                                    r_rd_rst                ,
        output reg [1 : 0]                            w_fifo_state/* synthesis PAP_MARK_DEBUG="1" */,
        output reg [1 : 0]                            r_fifo_state/* synthesis PAP_MARK_DEBUG="1" */,
        output wire [19 : 0]                          wr_addr_cnt/* synthesis PAP_MARK_DEBUG="1" */
	);
/************************************************************************/

/*******************************参数***************************************/
parameter    IDLE          =   'd0,
             WRITE_START   =   'd1,
             WRITE_ADDR    =   'd2,
             WRITE_DATA    =   'd3,
             READ_START    =   'd1,
             READ_ADDR    =    'd2,
             READ_DATA     =   'd3;




/*******************************寄存器***************************************/


reg [CTRL_ADDR_WIDTH - 1 : 0]    r_m_axi_awaddr;//地址寄存器
reg                              r_m_axi_awvalid;
reg                              r_m_axi_wlast;
reg                              r_m_axi_wvalid;
reg [CTRL_ADDR_WIDTH*8 - 1 : 0]  r_m_axi_araddr;
reg                              r_m_axi_arvalid/* synthesis PAP_MARK_DEBUG="1" */;
reg [7 : 0]                      r_wburst_cnt;
reg [7 : 0]                      r_rburst_cnt;
reg [DQ_WIDTH*8 - 1 : 0]         r_m_axi_rdata;

reg [19 : 0]                     r_wr_addr_cnt/* synthesis PAP_MARK_DEBUG="1" */;
reg [19 : 0]                     r_rd_addr_cnt/* synthesis PAP_MARK_DEBUG="1" */;
reg [1 : 0]                      r_wr_addr_page/* synthesis PAP_MARK_DEBUG="1" */;
reg [1 : 0]                      r_rd_addr_page/* synthesis PAP_MARK_DEBUG="1" */;
reg [1 : 0]                      r_wr_last_page/* synthesis PAP_MARK_DEBUG="1" */;
reg [1 : 0]                      r_rd_last_page/* synthesis PAP_MARK_DEBUG="1" */;

reg                              r_wr_done;//一帧图像传输完成信号
reg                              r_rd_done;
reg                              r_wfifo_rd_req;
reg                              r_wfifo_pre_rd_req;
reg                              r_wfifo_pre_rd_flag;
reg                              r_rfifo_wr_req;
//复位信号
reg                              r_vs_in_d0;
reg                              r_vs_in_d1; 
reg                              r_vs_out_d0;                            
reg                              r_vs_out_d1;     
//reg                              r_wr_rst/* synthesis PAP_MARK_DEBUG="1" */;
//reg                              r_rd_rst/* synthesis PAP_MARK_DEBUG="1" */;                       
/*******************************网表型***************************************/

/*******************************组合逻辑***************************************/
//一些常用接口是常量，根据顶层模块直接赋值就好
//写地址
assign M_AXI_AWADDR     =   {4'b0 , VIDEO_BASE_ADDR , r_wr_addr_page , r_wr_addr_cnt};//27-22高位0，21-20 帧缓存页数， 19-0 写地址计数
assign M_AXI_AWVALID    =   r_m_axi_awvalid;
//写数据
assign wfifo_rd_req     =   M_AXI_WLAST ? 1'b0 : M_AXI_WREADY;//r_wfifo_rd_req;
assign wfifo_pre_rd_req =   r_wfifo_pre_rd_req;//当地址有效后进行预读出一次数据
//读地址
assign M_AXI_ARADDR     =   {4'b0 , VIDEO_BASE_ADDR , r_rd_addr_page , r_rd_addr_cnt};//27-22高位0，21-20 帧缓存页数， 19-0 读地址计数
assign M_AXI_ARVALID    =   r_m_axi_arvalid;
assign rfifo_wr_req     =   M_AXI_RLAST ? 1'b0 : M_AXI_RVALID;//r_rfifo_wr_req;

assign wr_addr_cnt = r_wr_addr_cnt;
//读数据
//内存切换
/*******************************进程***************************************/
//抓取帧同步上升沿，方便后续复位操作
always @(posedge M_AXI_ACLK ) begin
    if(!M_AXI_ARESETN ) begin
        r_vs_in_d0 <= 'd0;
        r_vs_in_d1 <= 'd0;
        r_vs_out_d0 <= 'd0;
        r_vs_out_d1 <= 'd0;
    end
    else begin
        r_vs_in_d0 <= vs_in;
        r_vs_in_d1 <= r_vs_in_d0;
        r_vs_out_d0 <= vs_out;
        r_vs_out_d1 <= r_vs_out_d0;
    end
end
//脉冲复位
always @(posedge M_AXI_ACLK ) begin
    if(!M_AXI_ARESETN ) begin
        r_wr_rst <= 'd0; 
    end
    else if(r_vs_in_d0 && (!r_vs_in_d1)) begin//抓取上升沿，d0为高，d1为1时拉高复位
        r_wr_rst <= 'd1;
    end
    else if(r_wr_addr_cnt == wr_addr_min) begin //当地址位归零时结束复位
        r_wr_rst <= 'd0;
    end
    else begin
        r_wr_rst <= r_wr_rst;
    end
end

always @(posedge M_AXI_ACLK ) begin
    if(!M_AXI_ARESETN ) begin
        r_rd_rst <= 'd0; 
    end
    else if(r_vs_out_d0 && (!r_vs_out_d1)) begin//抓取上升沿，d0为高，d1为1时拉高复位
        r_rd_rst <= 'd1;
    end
    else if(r_rd_addr_cnt == wr_addr_min) begin //当地址位归零时结束复位
        r_rd_rst <= 'd0;
    end
    else begin
        r_rd_rst <= r_rd_rst;
    end
end
//地址页改变
always @(posedge M_AXI_ACLK ) begin
    if(!M_AXI_ARESETN ) begin//复位后为0时
        r_wr_addr_page <= 2'b0;
        r_wr_last_page <= 2'b0;
    end 
    else if(r_wr_done) begin
        r_wr_last_page <= r_wr_addr_page ;
        r_wr_addr_page <= r_wr_addr_page + 1;                                 //最后一次突发传输完成，一帧图像传输完成
        if(r_wr_addr_page == r_rd_addr_page) begin
            r_wr_addr_page <= r_wr_addr_page + 1;
        end
    end
end
always @(posedge M_AXI_ACLK ) begin
    if(!M_AXI_ARESETN ) begin//复位后为0时
        r_rd_addr_page <= 2'b0;
        r_rd_last_page <= 2'b0;
    end 
    else if(r_rd_done) begin//帧缓存读完后，对地址页进行切换，对上一次写的帧缓存进行读，如果当前写入的帧缓存和上一次的帧缓存未变（帧缓存没有写完），则重复读上一次的读帧缓存
        r_rd_last_page <= r_rd_addr_page;
        r_rd_addr_page <= r_wr_last_page;
        if(r_rd_addr_page == r_wr_addr_page) begin
            r_rd_addr_page <= r_rd_last_page ;
        end
    end
end
//一个always块最好控制一个reg
//写地址通道
always @(posedge M_AXI_ACLK ) begin
   if(!M_AXI_ARESETN ) begin//有效信号和准备信号都为1时，有效信号归0
        r_m_axi_awvalid <= 1'b0;
        r_wr_addr_cnt <= 20'b0;
        r_wr_done <= 1'b0;
        r_fram_done <= 1'b0;
    end 
    else if (r_wr_rst) begin
        r_wr_addr_cnt <= wr_addr_min;
        r_m_axi_awvalid <= 1'b0;
    end
    else if (DDR_INIT_DONE) begin
        if(r_wr_addr_cnt < wr_addr_max - M_AXI_BRUST_LEN * 8 ) begin //写入的地址小于最大地址减去一次突发传输的总量（len*axi_data_width(256)/32）
            r_wr_done<= 1'b0; 
            if(M_AXI_AWVALID && M_AXI_AWREADY) begin         
                r_m_axi_awvalid <= 1'b0;
                r_wr_addr_cnt <= r_wr_addr_cnt + M_AXI_BRUST_LEN * 8;
            end
            else if(w_fifo_state == WRITE_ADDR) begin
                r_m_axi_awvalid <= 1'b1;
            end
        end
        else if(r_wr_addr_cnt >= wr_addr_max - M_AXI_BRUST_LEN * 8 ) begin//最后一次突发传输时，地址计数归零            
            if(M_AXI_AWVALID && M_AXI_AWREADY) begin         
                r_m_axi_awvalid <= 1'b0;
                r_wr_addr_cnt <= wr_addr_min;
                r_wr_done<= 1'b1;  
                r_fram_done <= 1'b1;     
            end
            else if(w_fifo_state == WRITE_ADDR) begin
                r_m_axi_awvalid <= 1'b1;
            end
        end  
    end
    else begin
        r_m_axi_awvalid <= r_m_axi_awvalid;//其他状态保持不动
        r_wr_done <= r_wr_done;
        r_wr_addr_cnt <= 20'b0;
    end
end

//写数据通道
always @(posedge M_AXI_ACLK )begin//写突发计数
    if(!M_AXI_ARESETN || M_AXI_WLAST)begin
        r_wburst_cnt <= 'd0;
        r_wfifo_rd_req <= 1'b0;
    end
    else if (M_AXI_WREADY) begin
        r_wburst_cnt <= r_wburst_cnt + 1 ;
        r_wfifo_rd_req <= 1'b1;
        if (r_wburst_cnt == M_AXI_BRUST_LEN - 1'b1) begin//当计数到7时，不再使能读出wfifo
            r_wfifo_rd_req <= 1'b0;
        end
    end
    else begin
        r_wburst_cnt <= r_wburst_cnt;
        r_wfifo_rd_req <= 'd0;
    end
end
//预读WFIFO，清除fifo输出接口上一次数据
always @(posedge M_AXI_ACLK )begin//写突发计数
    if(!M_AXI_ARESETN ||(!(r_vs_in_d0) && r_vs_in_d1))begin//每次VS下降沿对其复位
        r_wfifo_pre_rd_req <= 'd0;
        r_wfifo_pre_rd_flag <= 'd0;
    end
    else if(M_AXI_AWVALID && M_AXI_AWREADY && (r_wfifo_pre_rd_flag == 'd0)) begin
        r_wfifo_pre_rd_req <= 'd1;
        r_wfifo_pre_rd_flag <= 'd1;
    end
    else begin
        r_wfifo_pre_rd_req <= 'd0;
    end
end
//读地址
always @(posedge M_AXI_ACLK ) begin//读地址有效
    if(!M_AXI_ARESETN)begin
        r_m_axi_arvalid <= 'd0;//复位、拉高后归零
        r_rd_addr_cnt <= 20'b0;
        r_rd_done <= 'd0;
    end
    else if(r_rd_rst)begin
        r_rd_addr_cnt <= wr_addr_min;
        r_m_axi_arvalid <= 'd0;
    end
    else if (DDR_INIT_DONE) begin//DDR初始化结束且有一帧图像已经存储好后,
        if(r_rd_addr_cnt < wr_addr_max - M_AXI_BRUST_LEN * 8) begin
            r_rd_done <= 'd0;
            if(M_AXI_ARVALID && M_AXI_ARREADY) begin//从机相应后拉低，写地址有效拉低，同时地址自增            
                r_m_axi_arvalid <= 1'b0;
                r_rd_addr_cnt <= r_rd_addr_cnt + M_AXI_BRUST_LEN * 8;
            end
            else if(r_fifo_state == READ_ADDR) begin
                r_m_axi_arvalid <= 1'b1;
            end
        end
        else if(r_rd_addr_cnt == wr_addr_max - M_AXI_BRUST_LEN * 8) begin
            if(M_AXI_ARVALID && M_AXI_ARREADY) begin//最后传输完成后归零            
                r_m_axi_arvalid <= 1'b0;
                r_rd_addr_cnt <= wr_addr_min;
                r_rd_done <= 'd1;
            end
            else if(r_fifo_state == READ_ADDR) begin
                r_m_axi_arvalid <= 1'b1;
            end            
        end

    end
    else begin
        r_m_axi_arvalid <= r_m_axi_arvalid;
        r_rd_addr_cnt <= r_rd_addr_cnt;
    end
end
//读数据
always @(posedge M_AXI_ACLK )begin//收到valid后使能fifo传输数据
    if(!M_AXI_ARESETN || M_AXI_RLAST)begin
        r_rfifo_wr_req <= 'd0;
        r_rburst_cnt <= 'd0;
    end
    else if (M_AXI_RVALID) begin
        r_rfifo_wr_req <= 1'b1;
        r_rburst_cnt <= r_rburst_cnt + 1'b1;
        if (r_rburst_cnt == M_AXI_BRUST_LEN - 1'b1) begin//当计数到7时，不再使能读出wfifo
            r_rfifo_wr_req <= 1'b0;
        end
    end
    else begin
        r_rfifo_wr_req <= 'd0;
        r_rburst_cnt <= r_rburst_cnt;
    end
end

/*******************************状态机***************************************/
//为了实现双向同时传输互不影响，所以读写状态单独做状态机使用
//DDR3写状态机
always @(posedge M_AXI_ACLK ) begin
    if(~M_AXI_ARESETN || r_wr_rst)
        w_fifo_state    <= IDLE;
    else begin
        case(w_fifo_state)
            IDLE: 
            begin
                if(DDR_INIT_DONE)
                    w_fifo_state <= WRITE_START ;
                else
                    w_fifo_state <= IDLE;
            end
            WRITE_START:
            begin
//                if (r_wr_rst) begin
//                    w_fifo_state <= WRITE_START;
//                end
                if(wfifo_rd_water_level > M_AXI_BRUST_LEN) begin//当wfifo中读水位高于突发长度（4）是，开始突发传输
                    w_fifo_state <= WRITE_ADDR;   //跳到写操作
                end
                else if((r_wr_addr_cnt >= wr_addr_max - M_AXI_BRUST_LEN * 8) && (wfifo_rd_water_level >= M_AXI_BRUST_LEN - 1'b1)) begin//由于之前预读了一次，所以这里需要-1
                    w_fifo_state <= WRITE_ADDR;
                end                
                else begin
                    w_fifo_state <= w_fifo_state;
                end            
            end
            WRITE_ADDR:
            begin
                if(M_AXI_AWVALID && M_AXI_AWREADY)
                    w_fifo_state <= WRITE_DATA;  //跳到写数据操作
                else
                    w_fifo_state <= w_fifo_state;   //条件不满足，保持当前值
            end
            WRITE_DATA: 
            begin
                //写到设定的长度跳到等待状态
                if(M_AXI_WLAST)//M_AXI_WREADY && (r_wburst_cnt == M_AXI_BRUST_LEN - 1)
                    w_fifo_state <= WRITE_START;  //写到设定的长度跳到等待状态
                else
                    w_fifo_state <= w_fifo_state;  //写条件不满足，保持当前值
            end
            default:
            begin
                w_fifo_state     <= IDLE;
            end
        endcase
    end
end
//DDR读状态机
always @(posedge M_AXI_ACLK ) begin
    if(~M_AXI_ARESETN || r_rd_rst)
        r_fifo_state    <= IDLE;
    else begin
        case(r_fifo_state)
            IDLE: 
            begin
                if(DDR_INIT_DONE && r_fram_done) begin
                    r_fifo_state <= READ_START ;
                end
                else begin
                    r_fifo_state <= IDLE;
                end
            end
            READ_START:
            begin
//                if(r_rd_rst) begin
//                    r_fifo_state <= READ_START;       
//                end
                if(rfifo_wr_water_level < VIDEO_LENGTH*PIXEL_WIDTH/128)//当wfifo中读水位小于240，开始突发传输，1920*32*2/256 = 240（120个突发传输数据）240/8 = 30次突发传输
                    r_fifo_state <= READ_ADDR;   //跳到写操作
                else
                    r_fifo_state <= r_fifo_state;
            end
            READ_ADDR:
            begin
                if(M_AXI_ARVALID && M_AXI_ARREADY)
                    r_fifo_state <= READ_DATA;  //跳到写数据操作
                else
                    r_fifo_state <= r_fifo_state;   //条件不满足，保持当前值
            end
            READ_DATA: 
            begin
                //写到设定的长度跳到等待状态
                if(M_AXI_RLAST ) //&& (r_rburst_cnt == M_AXI_BRUST_LEN - 1)
                    r_fifo_state <= READ_START;  //写到设定的长度跳到等待状态
                else
                    r_fifo_state <= r_fifo_state;  //写条件不满足，保持当前值
            end
            default:
            begin
                r_fifo_state     <= IDLE;
            end
        endcase
    end
end

endmodule
