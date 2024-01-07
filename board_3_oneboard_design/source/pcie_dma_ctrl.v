module pcie_dma_ctrl(
    input wire             clk                ,
    input wire             pix_clk_out        ,
    input wire             rstn               ,
    input wire             axis_master_tvalid /* synthesis PAP_MARK_DEBUG="1" */,    
    output wire            axis_master_tready /* synthesis PAP_MARK_DEBUG="1" */,    
    input wire    [127:0]  axis_master_tdata  /* synthesis PAP_MARK_DEBUG="1" */,    
    input wire    [3:0]    axis_master_tkeep  /* synthesis PAP_MARK_DEBUG="1" */,    
    input wire             axis_master_tlast  /* synthesis PAP_MARK_DEBUG="1" */,    
    input wire    [7:0]    axis_master_tuser  /* synthesis PAP_MARK_DEBUG="1" */,     
    
    input  [7 : 0]            ep_bus_num      ,
    input  [4 : 0]            ep_dev_num      ,

    input                     AXIS_S_TREADY   /* synthesis PAP_MARK_DEBUG="1" */,
    output                    AXIS_S_TVALID   /* synthesis PAP_MARK_DEBUG="1" */,
    output [127:0]            AXIS_S_TDATA    /* synthesis PAP_MARK_DEBUG="1" */,
    output                    AXIS_S_TLAST    /* synthesis PAP_MARK_DEBUG="1" */,
    output                    AXIS_S_TUSER    /* synthesis PAP_MARK_DEBUG="1" */,
//HDMI FIFO DATA IN
    input  [15: 0]           hdmi_data_in        /* synthesis PAP_MARK_DEBUG="1" */,
   //input  [8  : 0]           rd_water_level     /* synthesis PAP_MARK_DEBUG="1" */,
   //output reg                pcie_rd_en         /* synthesis PAP_MARK_DEBUG="1" */,
   //output reg                fram_start         /* synthesis PAP_MARK_DEBUG="1" */,
    input                     vs_in                ,
    input                     de_in                ,
//PCIe ctrl
    output reg [7 : 0]        video_enhance_lightdown_num    /* synthesis PAP_MARK_DEBUG="1" */,
    output reg                video_enhance_lightdown_sw     /* synthesis PAP_MARK_DEBUG="1" */,        
    output reg [7 : 0]        video_enhance_darkup_num       /* synthesis PAP_MARK_DEBUG="1" */,
    output reg                video_enhance_darkup_sw        /* synthesis PAP_MARK_DEBUG="1" */ 
      
   );                                         
/*****************************wire******************************/
wire [12 : 0]    rd_water_level /* synthesis PAP_MARK_DEBUG="1" */;
wire [127:0]    pcie_dma_data  /* synthesis PAP_MARK_DEBUG="1" */;
/*****************************reg******************************/
localparam MWR_32    = 8'h40;

localparam DMA_CMD_L_ADDR                   = 12'h110;
localparam DMA_CMD_CLEAR_ADDR               = 12'h130;
localparam DMA_CMD_VIDEO_HIGHTLIGHT_SUB     = 12'h140;
localparam DMA_CMD_VIDEO_LOWLIGHT_ADD       = 12'h150;
localparam DMA_CMD_VIDEO_ENHANCE_CLEAR      = 12'h160;

parameter  ALLOC_ADDR_1   = 4'd1;
parameter  ALLOC_ADDR_2   = 4'd2;
parameter  ALLOC_ADDR_3   = 4'd3;
parameter  ALLOC_ADDR_4   = 4'd4;


parameter  MWR_IDLE       = 2'd0;
parameter  MWR_TLP_HEADER = 2'd1;
parameter  MWR_TLP_DATA   = 2'd2;
parameter  TLP_LENGTH     = 10'd16;
parameter  DMA_TRAN_TIMES = 'd64801;// 8100次传输 8100*64*4=1920*1080//64;//129600;
reg [1:0]   mwr_state /* synthesis PAP_MARK_DEBUG="1" */;
reg         r_axis_s_tvalid/* synthesis PAP_MARK_DEBUG="1" */;
reg [127:0] r_axis_s_tdata;
reg         r_axis_s_tlast;
reg [10 :0] r_tlp_length_cnt/* synthesis PAP_MARK_DEBUG="1" */;

reg [127:0] axis_master_tdata_d0    /* synthesis PAP_MARK_DEBUG="1" */;
reg         axis_master_tvalid_d0   /* synthesis PAP_MARK_DEBUG="1" */;
reg         axis_master_tvalid_d1   /* synthesis PAP_MARK_DEBUG="1" */;
reg [2 : 0] tlp_fmt             /* synthesis PAP_MARK_DEBUG="1" */;
reg [4 : 0] tlp_type            /* synthesis PAP_MARK_DEBUG="1" */;
reg         mwr32               /* synthesis PAP_MARK_DEBUG="1" */;
reg [31: 0] mwr_addr            /* synthesis PAP_MARK_DEBUG="1" */;
reg [11: 0] cmd_reg_addr        /* synthesis PAP_MARK_DEBUG="1" */;
reg [9 : 0] tlp_lenght           /* synthesis PAP_MARK_DEBUG="1" */;   
reg         rc_cfg_ep_flag      /* synthesis PAP_MARK_DEBUG="1" */;
reg [31: 0] alloc_addrl         /* synthesis PAP_MARK_DEBUG="1" */;
//分配的帧缓存地址
reg [3 : 0] alloc_addr_state    /* synthesis PAP_MARK_DEBUG="1" */;
reg [1 : 0] addr_page           /* synthesis PAP_MARK_DEBUG="1" */;
reg [31: 0] dma_addr0           /* synthesis PAP_MARK_DEBUG="1" */;
reg [31: 0] dma_addr1           /* synthesis PAP_MARK_DEBUG="1" */;
reg [31: 0] dma_addr2           /* synthesis PAP_MARK_DEBUG="1" */;
reg [31: 0] dma_addr3           /* synthesis PAP_MARK_DEBUG="1" */;
reg         dma_addr_cfg_flag   /* synthesis PAP_MARK_DEBUG="1" */;
reg         dma_stop_flag       /* synthesis PAP_MARK_DEBUG="1" */;
reg [1 : 0] rc_cfg_cnt          /* synthesis PAP_MARK_DEBUG="1" */;
reg [15: 0] dma_cnt             /* synthesis PAP_MARK_DEBUG="1" */;
reg         rc_cfg_ep_flag_d0   /* synthesis PAP_MARK_DEBUG="1" */;
reg         vs_in_d0            /* synthesis PAP_MARK_DEBUG="1" */;
reg         vs_in_d1            /* synthesis PAP_MARK_DEBUG="1" */;
reg         r_pre_rd_flag        /* synthesis PAP_MARK_DEBUG="1" */;
reg         fram_start        /* synthesis PAP_MARK_DEBUG="1" */;
reg         dma_start        /* synthesis PAP_MARK_DEBUG="1" */;
reg         pcie_rd_en        /* synthesis PAP_MARK_DEBUG="1" */;
reg [7  : 0]  fram_cnt    /* synthesis PAP_MARK_DEBUG="1" */;
/*****************************assign******************************/
assign axis_master_tready = 'd1;
assign AXIS_S_TVALID = r_axis_s_tvalid;
assign AXIS_S_TDATA  = r_axis_s_tdata ;
assign AXIS_S_TLAST  = r_axis_s_tlast ;
assign AXIS_S_TUSER  = 'd0;
/************************always**********************************/
//对输入数据多打一拍
always  @(posedge clk) begin
    if(!rstn) begin
        axis_master_tdata_d0 <= 'd0;
        axis_master_tvalid_d0 <= 'd0;
        rc_cfg_ep_flag_d0 <= 'd0;
        vs_in_d0 <= 'd0;
        vs_in_d1 <= 'd0;
    end
    else begin
        axis_master_tdata_d0 <= axis_master_tdata;
        axis_master_tvalid_d0 <= axis_master_tvalid;
        axis_master_tvalid_d1 <= axis_master_tvalid_d0;
        rc_cfg_ep_flag_d0 <= rc_cfg_ep_flag;
        vs_in_d0 <= vs_in;
        vs_in_d1 <= vs_in_d0;
    end
end
//根据输入数据分析格式
always  @(posedge clk) begin
    if(!rstn) begin
        tlp_fmt  <= 'd0;
        tlp_type <= 'd0;
        mwr32    <= 'd0;
        mwr_addr <= 'd0;
        cmd_reg_addr <= 'd0;
        tlp_lenght <= 'd0;
    end
    else if(axis_master_tvalid_d0 && !(axis_master_tvalid_d1))begin
        tlp_fmt  <= axis_master_tdata_d0[31:29];
        tlp_type <= axis_master_tdata_d0[28:24];
        mwr_addr <= axis_master_tdata_d0[95:64];
        cmd_reg_addr <= axis_master_tdata_d0[75:64];//cmd偏移地址
        tlp_lenght <= axis_master_tdata_d0[9:0];//TLP数据包长度
    end
    else begin
        tlp_fmt  <= 'd0;
        tlp_type <= 'd0;
        mwr_addr <= 'd0;
        cmd_reg_addr <= 'd0;
        tlp_lenght <= 'd0;
    end
end

always  @(posedge clk) begin//对RC配置EP的MWR信号进行计数
    if(!rstn || dma_stop_flag) begin
        alloc_addr_state  <= ALLOC_ADDR_1;
        dma_addr0         <= 'd0;
        dma_addr1         <= 'd0;
        dma_addr2         <= 'd0;
        dma_addr3         <= 'd0;
        dma_stop_flag     <= 'd0;
        video_enhance_lightdown_num <= 'd0;
        video_enhance_lightdown_sw  <= 'd0;
        video_enhance_darkup_num    <= 'd0;
        video_enhance_darkup_sw     <= 'd0;
    end
    else if(({tlp_fmt,tlp_type} == MWR_32 )&& (tlp_lenght == 1) && (cmd_reg_addr == DMA_CMD_L_ADDR)) begin
        case(alloc_addr_state)//循环捕获地址
            ALLOC_ADDR_1:
            begin
                dma_addr0  <= {axis_master_tdata_d0[7:0],axis_master_tdata_d0[15:8],axis_master_tdata_d0[23:16],axis_master_tdata_d0[31:24]};
                alloc_addr_state <= ALLOC_ADDR_2;
            end
            ALLOC_ADDR_2:
            begin
                dma_addr1  <= {axis_master_tdata_d0[7:0],axis_master_tdata_d0[15:8],axis_master_tdata_d0[23:16],axis_master_tdata_d0[31:24]};
                alloc_addr_state <= ALLOC_ADDR_3;
            end
            ALLOC_ADDR_3:
            begin
                dma_addr2  <= {axis_master_tdata_d0[7:0],axis_master_tdata_d0[15:8],axis_master_tdata_d0[23:16],axis_master_tdata_d0[31:24]};
                alloc_addr_state <= ALLOC_ADDR_4;
            end
            ALLOC_ADDR_4:
            begin
                dma_addr3  <= {axis_master_tdata_d0[7:0],axis_master_tdata_d0[15:8],axis_master_tdata_d0[23:16],axis_master_tdata_d0[31:24]};
                alloc_addr_state <= ALLOC_ADDR_1;
            end
        endcase
    end
    else if(({tlp_fmt,tlp_type} == MWR_32 )&& (tlp_lenght == 1) && (cmd_reg_addr == DMA_CMD_CLEAR_ADDR)) begin//接收到清空DMA地址命令
        dma_stop_flag <= 1'b1;
    end
    else if(({tlp_fmt,tlp_type} == MWR_32 )&& (tlp_lenght == 1) && (cmd_reg_addr == DMA_CMD_VIDEO_LOWLIGHT_ADD)) begin//暗光增强命令
        video_enhance_darkup_num <= axis_master_tdata_d0[31:24];
        video_enhance_darkup_sw <= 1'b1;
    end
    else if(({tlp_fmt,tlp_type} == MWR_32 )&& (tlp_lenght == 1) && (cmd_reg_addr == DMA_CMD_VIDEO_HIGHTLIGHT_SUB)) begin//高光压制命令
        video_enhance_lightdown_num <= axis_master_tdata_d0[31:24];
        video_enhance_lightdown_sw <= 1'b1;
    end
    else if(({tlp_fmt,tlp_type} == MWR_32 )&& (tlp_lenght == 1) && (cmd_reg_addr == DMA_CMD_VIDEO_ENHANCE_CLEAR)) begin//停止视频增强
        video_enhance_lightdown_sw <= 1'b0;
        video_enhance_darkup_sw    <= 1'b0;
        video_enhance_lightdown_num <= 'd0;
        video_enhance_darkup_num   <= 'd0;
    end
    else begin
        alloc_addr_state  <=  alloc_addr_state ; 
        dma_addr0         <=  dma_addr0        ; 
        dma_addr1         <=  dma_addr1        ; 
        dma_addr2         <=  dma_addr2        ; 
        dma_addr3         <=  dma_addr3        ; 
        dma_addr_cfg_flag <=  dma_addr_cfg_flag; 
        video_enhance_lightdown_num <= video_enhance_lightdown_num;
        video_enhance_lightdown_sw  <= video_enhance_lightdown_sw ;
        video_enhance_darkup_num    <= video_enhance_darkup_num   ;
        video_enhance_darkup_sw     <= video_enhance_darkup_sw    ;
    end
end


always  @(posedge clk) begin//用于判断各种标志位
    if(!rstn  || dma_stop_flag) begin
        rc_cfg_ep_flag  <= 'd0; 
        dma_cnt         <= 'd0;
        fram_start      <= 'd0;
        dma_start       <= 'd0;
    end 
    else begin
        if((dma_addr0 != 32'b0) && (dma_addr1 != 32'b0) && (dma_addr2 != 32'b0) && (dma_addr3 != 32'b0)) begin//收到RC的两个MWR_32后，rc_cfg_ep_flag拉高，开始等待视频帧头到来
            rc_cfg_ep_flag <= 'd1;
        end
        if(!vs_in_d0 && vs_in_d1 && rc_cfg_ep_flag) begin//当rc_cfg_ep_flag拉高，同时抓取VS下降沿，下降沿来到时表示一帧开始，拉高fram_start
            fram_start <= 'd1;
            dma_start  <= 'd0;
        end   
        if(fram_start && (vs_in_d0 && !vs_in_d1)) begin//fram_start拉高后，抓取上升沿，上升沿到来时表示一帧结束，fram_start拉低
            fram_start <= 'd0;
            //rc_cfg_ep_flag <= 'd0;
        end 
        if(AXIS_S_TLAST) begin//一次DMA结束后，相关标志位拉低
            dma_start <= 'd0;
            if(dma_cnt >= DMA_TRAN_TIMES - 1) begin
                dma_cnt <= 'd0;
            end
            else begin 
                dma_cnt <= dma_cnt +'d1;
            end
        end
        else if( ((dma_cnt == 0)&&(rd_water_level >= TLP_LENGTH/4 + 1))|| ((dma_cnt != 0)&&(rd_water_level >= TLP_LENGTH/4)) || ((rd_water_level >= TLP_LENGTH/4 - 1) &&( dma_cnt == DMA_TRAN_TIMES - 2)) || dma_cnt == DMA_TRAN_TIMES-1) begin//水位高于4（16dw），拉高dma_start标志位
            dma_start <= 'd1;
        end
    end
end

//控制AXIS发送TLP包
always @(posedge clk) begin
    if(!rstn  || dma_stop_flag) begin
        r_axis_s_tvalid  <= 'd0;
        r_axis_s_tdata   <= 'd0;
        r_axis_s_tlast   <= 'd0;
        r_tlp_length_cnt <= 'd0;
        r_pre_rd_flag    <= 'd0;
        pcie_rd_en       <= 'd0;
        alloc_addrl      <= 'd0;
        addr_page        <= 'd0;
        fram_cnt         <= 'd1;
    end
    else if (vs_in_d0 && !vs_in_d1) begin//vs上升沿复位
        r_axis_s_tvalid  <= 'd0; 
        r_axis_s_tdata   <= 'd0; 
        r_axis_s_tlast   <= 'd0; 
        r_tlp_length_cnt <= 'd0; 
        r_pre_rd_flag    <= 'd0; 
        pcie_rd_en       <= 'd0; 
        addr_page        <= addr_page + 'd1;
        //判断当前地址页
        if(addr_page == 0) begin
            alloc_addrl      <= dma_addr0;
        end 
        else if(addr_page == 1) begin
            alloc_addrl      <= dma_addr1;
        end
        else if(addr_page == 2) begin
            alloc_addrl      <= dma_addr2;
        end
        else if(addr_page == 3) begin
            alloc_addrl      <= dma_addr3;
        end
    end
    else if (fram_start && dma_start && rc_cfg_ep_flag) begin //(rc_cfg_ep_flag) begin //
        case(mwr_state)
            MWR_IDLE:
            begin
                r_axis_s_tvalid <= 'd0;
                r_axis_s_tdata  <= 'd0;
                r_axis_s_tlast  <= 'd0;
                if(r_pre_rd_flag == 0) begin
                    pcie_rd_en <= 'd1;
                    r_pre_rd_flag <= 'd1;
                end
                else begin
                    pcie_rd_en <= 'd0;
                end
            end
            MWR_TLP_HEADER:
            begin
                //Mwr
                r_axis_s_tvalid <= 'd1;
                r_axis_s_tlast  <= 'd0;
                //Byte 0+
                r_axis_s_tdata[9  :  0]  <= TLP_LENGTH;        //包长 2
                r_axis_s_tdata[11 : 10]  <= 'h0;        //AT
                r_axis_s_tdata[13 : 12]  <= 'h0;        //Attr
                r_axis_s_tdata[14]       <= 'h0;        //EP
                r_axis_s_tdata[15]       <= 'h0;        //TD
                r_axis_s_tdata[16]       <= 'h0;        //TH
                r_axis_s_tdata[17]       <= 'h0;        //保留
                r_axis_s_tdata[18]       <= 'h0;        //Attr2
                r_axis_s_tdata[19]       <= 'h0;        //保留
                r_axis_s_tdata[22 : 20]  <= 'h0;        //TC
                r_axis_s_tdata[23]       <= 'h0;        //保留
                r_axis_s_tdata[28 : 24]  <= 'h0;        //Type
                r_axis_s_tdata[31 : 29]  <= 3'b010;     //Fmt 3DW Mwr
                //Byte 4+                               
                r_axis_s_tdata[35 : 32]  <= 4'hf;    //First DW BE 用于说明数据第一个DW哪一个字节有效
                r_axis_s_tdata[39 : 36]  <= 4'hf;    //Last DW BE  用于说明数据最后一个DW哪一个字节有效
                r_axis_s_tdata[47 : 40]  <= 8'h01;        //Tag
                r_axis_s_tdata[63 : 48]  <= {ep_bus_num,ep_dev_num,3'b0};  //Requester ID [63:56] Bus Num [55:51] Device Num [50:48] Function Num 
                //Byte 8+
                r_axis_s_tdata[95 : 64]  <= alloc_addrl;//r_dma_addr;     //64位的高32位地址 or 32位的低30位地址（低两位保留，保证数据DW对其）
                //Byte 12+_                
                r_axis_s_tdata[127: 96]  <= 32'd0;     //64位的低30位地址（低两位保留）
                pcie_rd_en <= 'd1;//提前一个周期把数据整出来
            end
            MWR_TLP_DATA:
            begin
                if(AXIS_S_TREADY) begin
                    if(dma_cnt <= DMA_TRAN_TIMES - 2) begin
                        //地址做变换
                        r_axis_s_tdata <= {
                                            pcie_dma_data[103: 96],pcie_dma_data[111:104],pcie_dma_data[119:112],pcie_dma_data[127:120],
                                            pcie_dma_data[71 : 64],pcie_dma_data[79 : 72],pcie_dma_data[87 : 80],pcie_dma_data[95 : 88],
                                            pcie_dma_data[39 : 32],pcie_dma_data[47 : 40],pcie_dma_data[55 : 48],pcie_dma_data[63 : 56],
                                            pcie_dma_data[7  :  0],pcie_dma_data[15 :  8],pcie_dma_data[23 : 16],pcie_dma_data[31 : 24] };//前60次传输，传输数据
                    end
                    else if(dma_cnt >= DMA_TRAN_TIMES - 1) begin
                        r_axis_s_tdata <= {16{fram_cnt}};//128'hdddd_dddd_dddd_dddd_dddd_dddd_dddd_dddd;//最后4次传输，传输标志位
                        if(fram_cnt == 8'hff) begin
                            fram_cnt <= 'd1;
                        end
                        else begin
                            fram_cnt <= fram_cnt + 'd1;
                        end
                        pcie_rd_en <= 'd0;
                    end
                    r_tlp_length_cnt <= r_tlp_length_cnt + 1'd1;
                    if(AXIS_S_TLAST) begin
                        r_tlp_length_cnt <= 'd0;
                        r_axis_s_tvalid  <= 'd0;
                        r_axis_s_tdata   <= 'd0;
                        r_axis_s_tlast   <= 'd0;
                        
                        alloc_addrl <= alloc_addrl + TLP_LENGTH*4;//结束传输后地址自增 包长*4
                    end          
                    else if(((TLP_LENGTH <= 4) || ((TLP_LENGTH > 4) && (r_tlp_length_cnt >= TLP_LENGTH/4 - 1)) && AXIS_S_TREADY)) begin
                        r_axis_s_tlast  <= 'd1;
                        pcie_rd_en       <= 'd0;
                    end
                end
                else begin
                    pcie_rd_en <= 'd0;
                end
            end
            default:
            begin
                r_axis_s_tvalid <= 'd0;
                r_axis_s_tdata  <= 'd0;
                r_axis_s_tlast  <= 'd0;
                pcie_rd_en      <='d0 ;
            end
        endcase
    end
end

/************************state_machine**********************************/
//控制AXIS发送TLP包
always @(posedge clk) begin
    if(!rstn || (vs_in_d0 && !vs_in_d1)  || dma_stop_flag) begin
        mwr_state <= 'd0;
    end
    else if(fram_start && dma_start && rc_cfg_ep_flag) begin // (rc_cfg_ep_flag) begin //
        case(mwr_state)
            MWR_IDLE:
            begin
                if(AXIS_S_TREADY) begin
                    mwr_state <= MWR_TLP_HEADER;
                end
                else begin
                    mwr_state <= mwr_state;
                end
            end 
            MWR_TLP_HEADER:
            begin
                if(AXIS_S_TREADY) begin//当Valid和Ready同时拉高时，进入下一个状态
                    mwr_state <= MWR_TLP_DATA;
                end
                else begin
                    mwr_state <= mwr_state;
                end
            end
            MWR_TLP_DATA:
            begin
                if(AXIS_S_TLAST) begin //拉高后回归IDLE
                    mwr_state <= MWR_IDLE;
                end
                else begin
                    mwr_state <= mwr_state;
                end
            end
            default:
            begin
                    mwr_state <= mwr_state;
            end
        endcase
    end
    else begin
        mwr_state <= mwr_state;
    end
end


hdmi_pcie_fifo u_hdmi_pcie_fifo (
  .wr_clk            (pix_clk_out                ),    // input
  .wr_rst            (vs_in || ~rstn  || dma_stop_flag             ),    // input
  .wr_en             (de_in && fram_start       ),    // input
  .wr_data           (hdmi_data_in               ),    // input [15:0]
  .wr_full           (                           ),    // output
  .wr_water_level    (                           ),    // output [10:0]
  .almost_full       (                           ),    // output
  .rd_clk            (clk                        ),    // input
  .rd_rst            (vs_in || ~rstn  || dma_stop_flag             ),    // input
  .rd_en             (pcie_rd_en                 ),    // input
  .rd_data           (pcie_dma_data              ),    // output [127:0]
  .rd_empty          (                           ),    // output
  .rd_water_level    (rd_water_level             ),    // output [10:0]
  .almost_empty      (                           )     // output
);


endmodule