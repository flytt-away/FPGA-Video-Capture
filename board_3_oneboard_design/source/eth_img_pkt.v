module eth_img_pkt(
    input                 rst_n          ,   //复位信号，低电平有效
    //图像相关信号
    input                 cam_pclk       ,   //像素时钟
    input                 img_vsync      ,   //帧同步信号
    input                 img_data_en    ,   //数据有效使能信号
    input        [15:0]   img_data       ,   //有效数据 
    
    input                 transfer_flag  ,   //图像开始传输标志,1:开始传输 0:停止传输
    //以太网相关信号 
    input                 eth_tx_clk     ,   //以太网发送时钟
    input                 udp_tx_req     ,   //udp发送数据请求信号
    input                 udp_tx_done    /* synthesis PAP_MARK_DEBUG="1" */,   //udp发送数据完成信号                               
    output  reg           udp_tx_start_en,   //udp开始发送信号
    output       [31:0]   udp_tx_data    /* synthesis PAP_MARK_DEBUG="1" */,   //udp发送的数据
    output  reg  [15:0]   udp_tx_byte_num    //udp单包发送的有效字节数
    );    
    
//parameter define
parameter  CMOS_H_PIXEL = 16'd960;  //图像水平方向分辨率
parameter  CMOS_V_PIXEL = 16'd540;  //图像垂直方向分辨率
parameter  UDP_DATA_SIZE = 16'd960; //UDP数据长度（不包含首部）
parameter  ETH_TRAN_DELAY = 11'd800; //帧间隔延迟
//图像帧头,用于标志一帧数据的开始
parameter  IMG_FRAME_HEAD = {32'hf0_5a_a5_0f};

reg             img_vsync_d0    ;  //帧有效信号打拍
reg             img_vsync_d1    ;  //帧有效信号打拍
reg             neg_vsync_d0    ;  //帧有效信号下降沿打拍
reg             neg_vsync_d1    ;
reg             img_de_d0       ;  //DE标志位打拍
reg             img_de_d1       ;  //DE标志位 打拍     
reg             eth_delay_d0    ;
reg             eth_delay_d1    ;                          


reg             wr_sw           ;  //用于位拼接的标志
reg    [15:0]   img_data_d0     ;  //有效图像数据打拍
reg             wr_fifo_en      /* synthesis PAP_MARK_DEBUG="1" */;  //写fifo使能
reg    [31:0]   wr_fifo_data    /* synthesis PAP_MARK_DEBUG="1" */;  //写fifo数据

reg             img_vsync_txc_d0;  //以太网发送时钟域下,帧有效信号打拍
reg             img_vsync_txc_d1;  //以太网发送时钟域下,帧有效信号打拍
reg             tx_busy_flag    ;  //发送忙信号标志
reg    [15 : 0] img_de_cnt      /* synthesis PAP_MARK_DEBUG="1" */;//de下降沿计数
reg    [31 : 0] img_pkt_cnt    /* synthesis PAP_MARK_DEBUG="1" */;
reg    [15 : 0]       eth_delay_cnt  /* synthesis PAP_MARK_DEBUG="1" */;    //delay计数器  
reg                  eth_delay_start/* synthesis PAP_MARK_DEBUG="1" */;
reg                  eth_delay_done /* synthesis PAP_MARK_DEBUG="1" */;                           
//wire define                   
wire            pos_vsync       ;  //帧有效信号上升沿
wire            neg_vsync       ;  //帧有效信号下降沿
wire            neg_vsynt_txc   ;  //以太网发送时钟域下,帧有效信号下降沿
wire            pos_de          ;  //数据有效信号上升沿
wire            pos_eth_delay   ;  //udp
wire   [10:0]    fifo_rdusedw    /* synthesis PAP_MARK_DEBUG="1" */;  //当前FIFO缓存的个数


//*****************************************************
//**                    main code
//*****************************************************

//信号采沿
assign neg_vsync = img_vsync_d1 & (~img_vsync_d0);
assign pos_vsync = ~img_vsync_d1 & img_vsync_d0;
assign neg_vsynt_txc = ~img_vsync_txc_d1 & img_vsync_txc_d0;
assign neg_de    = (~img_de_d0) & img_de_d1;
assign pos_eth_delay = eth_delay_d0 & (~eth_delay_d1);
//对img_vsync信号延时两个时钟周期,用于采沿
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        img_vsync_d0 <= 1'b0;
        img_vsync_d1 <= 1'b0;
        img_de_d0    <= 1'b0;
        img_de_d1    <= 1'b0;
        eth_delay_d0 <=  'd0;//在输入时钟域下对udp发送完成信号采样
        eth_delay_d1 <=  'd0;
    end
    else begin
        img_vsync_d0 <= img_vsync;
        img_vsync_d1 <= img_vsync_d0;
        img_de_d0 <= img_data_en;
        img_de_d1 <= img_de_d0;
        eth_delay_d0 <= eth_delay_start;//在输入时钟域下对udp发送完成信号采样
        eth_delay_d1 <= eth_delay_d0;
    end
end

//寄存neg_vsync信号
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        neg_vsync_d0 <= 1'b0;
        neg_vsync_d1 <= 1'b0;
    end    
    else begin 
        neg_vsync_d0 <= neg_vsync;
        neg_vsync_d1 <= neg_vsync_d0;
    end
end    

//对wr_sw和img_data_d0信号赋值,用于位拼接
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        wr_sw <= 1'b0;
        img_data_d0 <= 1'b0;
    end
     else if(neg_vsync)
        wr_sw <= 1'b0;
    else if(img_data_en) begin
        wr_sw <= ~wr_sw;
        img_data_d0 <= img_data;
    end    
end 

//将帧头和图像数据写入FIFO
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n || pos_vsync) begin
        wr_fifo_en <= 1'b0;
        wr_fifo_data <= 32'b0;
        img_de_cnt <= 32'd0;
        img_pkt_cnt <= 'd1;
    end
    else begin
        if(neg_vsync) begin
            wr_fifo_en <= 1'b1;
            wr_fifo_data <= img_pkt_cnt;                  //UDP包标志位
            img_pkt_cnt <= img_pkt_cnt + 'd1;
        end
        else if(neg_vsync_d0) begin
            wr_fifo_en <= 1'b1;
            wr_fifo_data <= IMG_FRAME_HEAD;               //帧头
        end
        else if(neg_vsync_d1) begin
            wr_fifo_en <= 1'b1;
            wr_fifo_data <= {CMOS_H_PIXEL,CMOS_V_PIXEL};  //水平和垂直方向分辨率
        end
        else if(img_data_en && wr_sw) begin
            wr_fifo_en <= 1'b1;
            img_de_cnt <= img_de_cnt + 'd1;
            wr_fifo_data <= {img_data_d0,img_data};       //图像数据位拼接,16位转32位
        end
        else if(img_de_cnt == 240) begin
            wr_fifo_en <= 1'b1;
            wr_fifo_data <= img_pkt_cnt;
            img_pkt_cnt <= img_pkt_cnt + 'd1;
            
        end
        else if(neg_de) begin  
            wr_fifo_en <= 1'b1;
            wr_fifo_data <= img_pkt_cnt;           //de结束后写入计数
            img_pkt_cnt <= img_pkt_cnt + 'd1;
            img_de_cnt <= 'd0;
        end
        else begin
            wr_fifo_en <= 1'b0;
            wr_fifo_data <= 32'b0;        
        end
    end
end

//以太网发送时钟域下,对img_vsync信号延时两个时钟周期,用于采沿
always @(posedge eth_tx_clk or negedge rst_n) begin
    if(!rst_n) begin
        img_vsync_txc_d0 <= 1'b0;
        img_vsync_txc_d1 <= 1'b0;
    end
    else begin
        img_vsync_txc_d0 <= img_vsync;
        img_vsync_txc_d1 <= img_vsync_txc_d0;
    end
end

//控制以太网发送的字节数
always @(posedge eth_tx_clk or negedge rst_n) begin
    if(!rst_n)
        udp_tx_byte_num <= 1'b0;
    else if(neg_vsynt_txc)//vs后第一个数据包发送图像数据长度+起始标志位长度8Byte
        //udp_tx_byte_num <= {CMOS_H_PIXEL,1'b0} + 16'd8;
        udp_tx_byte_num <= UDP_DATA_SIZE + 16'd12;//16'd960 + 16'd8;
    else if(udp_tx_done)//后续正常包长    
        //udp_tx_byte_num <= {CMOS_H_PIXEL,1'b0};
        udp_tx_byte_num <= UDP_DATA_SIZE + 16'd4;//16'd960;
end

//控制以太网发送开始信号
always @(posedge eth_tx_clk or negedge rst_n) begin
    if(!rst_n) begin
        udp_tx_start_en <= 1'b0;
        tx_busy_flag <= 1'b0;
    end
    //上位机未发送"开始"命令时,以太网不发送图像数据
    else if(transfer_flag == 1'b0) begin
        udp_tx_start_en <= 1'b0;
        tx_busy_flag <= 1'b0;        
    end
    else begin
        udp_tx_start_en <= 1'b0;
        //当FIFO中的个数满足需要发送的字节数时 水位/4(32bit->8bit)
        if(tx_busy_flag == 1'b0 && fifo_rdusedw >= udp_tx_byte_num[15:2]) begin
            udp_tx_start_en <= 1'b1;                     //开始控制发送一包数据
            tx_busy_flag <= 1'b1;
        end
        else if(eth_delay_done|| neg_vsynt_txc) 
            tx_busy_flag <= 1'b0;
    end
end
//最小帧间隔，至少有96bits的间隔,千兆以太网要求96ns，125Mhz->8ns，即12个时钟周期，这里给500+吧
always @(posedge eth_tx_clk or negedge rst_n) begin
    if(!rst_n) begin
        eth_delay_cnt <= 'd0;
        eth_delay_start <= 'd0;
        eth_delay_done <= 'd0;
    end
    else begin
        eth_delay_done <= 'd0;
        if(udp_tx_done) begin
            eth_delay_start <= 'd1;
        end 
        if(eth_delay_start) begin
            eth_delay_cnt <= eth_delay_cnt + 'd1;
        end
        if(eth_delay_cnt >= ETH_TRAN_DELAY) begin
            eth_delay_done  <= 'd1;
            eth_delay_start <= 'd0;
            eth_delay_cnt   <= 'd0;
        end
    end
end
reg    [10:0]   udp_pkt_cnt     /* synthesis PAP_MARK_DEBUG="1" */;  //udp包计数
always @(posedge eth_tx_clk or negedge rst_n) begin
    if(!rst_n || neg_vsynt_txc) begin
        udp_pkt_cnt <= 'd0;
    end    
    else if(udp_tx_done)begin
        udp_pkt_cnt <= udp_pkt_cnt + 'd1;
    end
    else begin
        udp_pkt_cnt <= udp_pkt_cnt;
    end
end
//异步FIFO
  
eth_pkt_fifo u_eth_pkt_fifo (
  .wr_clk           (cam_pclk                    ) ,    // input
  .wr_rst           (pos_vsync | (~transfer_flag)) ,    // input
  .wr_en            (wr_fifo_en                  ) ,    // input
  .wr_data          (wr_fifo_data                ) ,    // input [31:0]
  .wr_full          (                            ) ,    // output
  .wr_water_level   (                            ) ,    // output [10:0]
  .almost_full      (                            ) ,    // output
  .rd_clk           (eth_tx_clk                  ) ,    // input
  .rd_rst           (pos_vsync | (~transfer_flag)) ,    // input
  .rd_en            (udp_tx_req                  ) ,    // input
  .rd_data          (udp_tx_data                 ) ,    // output [31:0]
  .rd_empty         (                            ) ,    // output
  .rd_water_level   (fifo_rdusedw                ) ,    // output [10:0]
  .almost_empty     (                            )      // output
);
//eth_pkt_fifo u_eth_pkt_fifo (
//  .wr_clk(wr_clk),                    // input
//  .wr_rst(wr_rst),                    // input
//  .wr_en(wr_en),                      // input
//  .wr_data(wr_data),                  // input [31:0]
//  .wr_full(wr_full),                  // output
//  .wr_water_level(wr_water_level),    // output [9:0]
//  .almost_full(almost_full),          // output
//  .rd_clk(rd_clk),                    // input
//  .rd_rst(rd_rst),                    // input
//  .rd_en(rd_en),                      // input
//  .rd_data(rd_data),                  // output [31:0]
//  .rd_empty(rd_empty),                // output
//  .rd_water_level(rd_water_level),    // output [9:0]
//  .almost_empty(almost_empty)         // output
//);

endmodule