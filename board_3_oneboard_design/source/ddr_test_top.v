// Created by IP Generator (Version 2022.1 build 99559)
// creat V3 on 2023.7.31
// #add eth interfacing loop


`timescale 1ps/1ps

`define DDR3
//仿真128*72 ->64*36
module test_ddr #(
  parameter PCIE_ENABLE          = 1                   ,//PCIE模块例化，0不例化，1例化
  parameter PROJECT_MODE         = 1                    ,//PROJECT_MODE 0:仿真；>=1：上板子；2：使用pcie
  parameter VIDEO_LENGTH         = 1920                 ,
  parameter VIDEO_HIGTH          = 1080                 ,
  parameter ZOOM_VIDEO_LENGTH    = 960                 ,
  parameter ZOOM_VIDEO_HIGTH     = 540                 ,
  parameter PIXEL_WIDTH          = 32                 ,    
  parameter MEM_ROW_ADDR_WIDTH   = 15                 ,
  parameter MEM_COL_ADDR_WIDTH   = 10                 ,
  parameter MEM_BADDR_WIDTH      = 3                  ,
  parameter MEM_DQ_WIDTH         = 32                 ,
  parameter MEM_DM_WIDTH         = MEM_DQ_WIDTH/8     ,
  parameter MEM_DQS_WIDTH        = MEM_DQ_WIDTH/8     ,
  parameter M_AXI_BRUST_LEN      = 8                  ,
  parameter RW_ADDR_MIN          = 20'b0              ,
  parameter RW_ADDR_MAX          = ZOOM_VIDEO_LENGTH*ZOOM_VIDEO_HIGTH*PIXEL_WIDTH/MEM_DQ_WIDTH       ,//@540p  518400个地址   
  parameter CTRL_ADDR_WIDTH      = MEM_ROW_ADDR_WIDTH + MEM_BADDR_WIDTH + MEM_COL_ADDR_WIDTH
)(
  input                                  ref_clk         ,
  input                                  rst_board       /* synthesis syn_keep="1" */,
  output                                 ddr_pll_lock        ,           
  output                                 ddr_init_done   ,
  //DDR 
  output                                 mem_rst_n       ,                       
  output                                 mem_ck          ,
  output                                 mem_ck_n        ,
  output                                 mem_cke         ,
  output                                 mem_cs_n        ,
  output                                 mem_ras_n       ,
  output                                 mem_cas_n       ,
  output                                 mem_we_n        ,  
  output                                 mem_odt         ,
  output     [MEM_ROW_ADDR_WIDTH-1:0]    mem_a           ,   
  output     [MEM_BADDR_WIDTH-1:0]       mem_ba          ,   
  inout      [MEM_DQS_WIDTH-1:0]         mem_dqs         ,
  inout      [MEM_DQS_WIDTH-1:0]         mem_dqs_n       ,
  inout      [MEM_DQ_WIDTH-1:0]          mem_dq          ,
  output     [MEM_DM_WIDTH-1:0]          mem_dm          ,
//MS72XX配置
  output wire                               hdmi_rst   ,
  output                                   iic_tx_scl        ,
  inout                                    iic_tx_sda        ,
  output                                   iic_scl            ,
  inout                                    iic_sda            ,
  output wire                              hdmi_int_led      ,
  output wire                              fram0_done         ,
  output wire                              fram1_done         ,
  output wire                              fram2_done         ,
  output wire                              fram3_done         ,
//HDMI IN
  input wire                               pix_clk_in      ,//HDMI输入时钟 1080p @148.5Mhz
  input wire                               vs_in           /* synthesis PAP_MARK_DEBUG="1" */,//帧同步
  input wire                               hs_in           ,//行同步
  input wire                               de_in           /* synthesis PAP_MARK_DEBUG="1" */,//数据有效信号
  input wire [7 : 0]                       r_in            /* synthesis PAP_MARK_DEBUG="1" */,
  input wire [7 : 0]                       g_in            /* synthesis PAP_MARK_DEBUG="1" */,
  input wire [7 : 0]                       b_in            /* synthesis PAP_MARK_DEBUG="1" */,
//HDMI OUT
  output                                 pix_clk_out     ,
  output reg                             r_vs_out        /* synthesis PAP_MARK_DEBUG="1" */,  
  output reg                             r_hs_out        , 
  output reg                             r_de_out        /* synthesis PAP_MARK_DEBUG="1" */, 
  output reg  [7 : 0]                    r_r_out         /* synthesis PAP_MARK_DEBUG="1" */, 
  output reg  [7 : 0]                    r_g_out         /* synthesis PAP_MARK_DEBUG="1" */,
  output reg  [7 : 0]                    r_b_out         /* synthesis PAP_MARK_DEBUG="1" */,  
//coms1	
  inout                                cmos1_scl            ,//cmos1 i2c 
  inout                                cmos1_sda            ,//cmos1 i2c 
  input                                cmos1_vsync          /* synthesis PAP_MARK_DEBUG="1" */,//cmos1 vsync
  input                                cmos1_href           ,//cmos1 hsync refrence,data valid
  input                                cmos1_pclk           ,//cmos1 pxiel clock
  input   [7:0]                        cmos1_data           ,//cmos1 data
  output                               cmos1_reset          /* synthesis PAP_MARK_DEBUG="1" */, //cmos1 reset
  //coms2
  inout                                cmos2_scl            ,//cmos2 i2c 
  inout                                cmos2_sda            ,//cmos2 i2c 
  input                                cmos2_vsync          ,//cmos2 vsync
  input                                cmos2_href           ,//cmos2 hsync refrence,data valid
  input                                cmos2_pclk           ,//cmos2 pxiel clock
  input   [7:0]                        cmos2_data           ,//cmos2 data
  output                               cmos2_reset          ,
   //pcie相关引脚
  input                                pcie_perst_n       ,//PCIE复位引脚
   //ETH0_RGMII 开发板eth1网口，使用原语之后这些地方不能接ILA
  output wire                          eth_rst_n_0        , //以太网复位信号
  input  wire                          eth_rgmii_rxc_0    ,
  input  wire                          eth_rgmii_rx_ctl_0 ,
  input  wire [3:0]                    eth_rgmii_rxd_0    ,  
                       
  output wire                          eth_rgmii_txc_0    ,
  output wire                          eth_rgmii_tx_ctl_0 ,
  output wire [3:0]                    eth_rgmii_txd_0    

);

/******************************PARAMETER********************************************/
parameter DQ_WIDTH = MEM_DQ_WIDTH;
parameter DE_IN_WAIT  = 4'd0;
parameter DE_IN_CNT  = 4'd1;
parameter DE_IN_END  = 4'd2;

parameter DE_OUT_WAIT  = 4'd0;
parameter DE_OUT_CNT  = 4'd1;
parameter DE_OUT_END  = 4'd2;

parameter PIX_IN_WAIT = 3'd0;
parameter PIX_IN_CNT = 3'd1;
parameter PIX_IN_END = 3'd2;

parameter PIX_OUT_WAIT = 3'd0;
parameter PIX_OUT_CNT = 3'd1;
parameter PIX_OUT_END = 3'd2;
//开发板MAC地址 00-11-22-33-44-55
parameter  BOARD_MAC = 48'h00_11_22_33_44_55;     
//开发板IP地址 192.168.1.10     
parameter  BOARD_IP  = {8'd192,8'd168,8'd1,8'd10};
//目的MAC地址 ff_ff_ff_ff_ff_ff
parameter  DES_MAC   = 48'h58_11_22_91_38_31;
//parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff;

//目的IP地址 192.168.1.102
//环回写自己
parameter  DES_IP    = {8'd192,8'd168,8'd1,8'd102};
//parameter  DES_IP    = {8'd192,8'd168,8'd1,8'd10};
/******************************wire********************************************/      
wire                                   ddr_ip_clk      /* synthesis PAP_MARK_DEBUG="1" */;
wire                                   ddr_ip_rst_n    /* synthesis PAP_MARK_DEBUG="1" */;   
//写地址通道↓                                                  
wire [3 : 0]                           M_AXI_AWID     /* synthesis PAP_MARK_DEBUG="1" */;
wire [CTRL_ADDR_WIDTH-1 : 0]           M_AXI_AWADDR   /* synthesis PAP_MARK_DEBUG="1" */;
//wire [3 : 0]                           M_AXI_AWLEN    /* synthesis PAP_MARK_DEBUG="1" */;
wire                                   M_AXI_AWUSER   /* synthesis PAP_MARK_DEBUG="1" */;
wire                                   M_AXI_AWVALID   /* synthesis PAP_MARK_DEBUG="1" */;
wire                                   M_AXI_AWREADY   /* synthesis PAP_MARK_DEBUG="1" */;
//写数据通道↓                                                 
wire [DQ_WIDTH*8-1 : 0]                M_AXI_WDATA    /* synthesis PAP_MARK_DEBUG="1" */;
wire [DQ_WIDTH-1 : 0]                  M_AXI_WSTRB    /* synthesis PAP_MARK_DEBUG="1" */;
wire                                   M_AXI_WLAST    /* synthesis PAP_MARK_DEBUG="1" */;
wire [3 : 0]                           M_AXI_WUSER    /* synthesis PAP_MARK_DEBUG="1" */;
wire                                   M_AXI_WREADY   /* synthesis PAP_MARK_DEBUG="1" */;                                                
//读地址通道↓                                                 
wire [3 : 0]                           M_AXI_ARID     /* synthesis PAP_MARK_DEBUG="1" */;
wire                                   M_AXI_ARUSER   /* synthesis PAP_MARK_DEBUG="1" */;
wire [CTRL_ADDR_WIDTH-1 : 0]           M_AXI_ARADDR   /* synthesis PAP_MARK_DEBUG="1" */;
//wire [3 : 0]                           M_AXI_ARLEN    /* synthesis PAP_MARK_DEBUG="1" */;
wire                                   M_AXI_ARVALID   /* synthesis PAP_MARK_DEBUG="1" */;
wire                                   M_AXI_ARREADY   /* synthesis PAP_MARK_DEBUG="1" */;
//读数据通道↓                                                
wire  [3 : 0]                          M_AXI_RID      /* synthesis PAP_MARK_DEBUG="1" */;
wire  [DQ_WIDTH*8-1 : 0]               M_AXI_RDATA    /* synthesis PAP_MARK_DEBUG="1" */;
wire                                   M_AXI_RLAST    /* synthesis PAP_MARK_DEBUG="1" */;
wire                                   M_AXI_RVALID   /* synthesis PAP_MARK_DEBUG="1" */;
//debug控制线
wire  [1 : 0 ]                         init_read_clk_ctrl;
wire  [3 : 0 ]                         init_slip_step;
wire                                   force_read_clk_ctrl; 
//w_fifo
wire  [31 : 0]                        rgb_in/* synthesis PAP_MARK_DEBUG="1" */;
wire  [31 : 0]                        video0_data_out/* synthesis PAP_MARK_DEBUG="1" */;
wire  [31 : 0]                        video1_data_out/* synthesis PAP_MARK_DEBUG="1" */;
wire  [31 : 0]                        video2_data_out/* synthesis PAP_MARK_DEBUG="1" */;
wire  [31 : 0]                        video3_data_out/* synthesis PAP_MARK_DEBUG="1" */;



//wire                                    fram_done;
//iic
wire                                 iic_clk;//10mhz
wire                                 pll_init_done;
wire                                 [11 : 0] x_act /* synthesis PAP_MARK_DEBUG="1" */;
wire                                 [11 : 0] y_act /* synthesis PAP_MARK_DEBUG="1" */;
//wire                                 hdmi_rst;

wire                                vs_out/* synthesis PAP_MARK_DEBUG="1" */;
wire                                hs_out;
wire                                de_out/* synthesis PAP_MARK_DEBUG="1" */;

wire                                zoom_de_out/* synthesis PAP_MARK_DEBUG="1" */;
wire [PIXEL_WIDTH - 1: 0]           zoom_data_out;

wire                                clk_25M;
wire [1:0]                          cmos_init_done/* synthesis PAP_MARK_DEBUG="1" */;
wire [15:0]                         cmos1_d_16bit;
wire                                cmos1_href_16bit/* synthesis PAP_MARK_DEBUG="1" */;
wire                                cmos1_pclk_16bit;
wire[15:0]                          cmos2_d_16bit       /*synthesis PAP_MARK_DEBUG="1"*/;
wire                                cmos2_href_16bit    /*synthesis PAP_MARK_DEBUG="1"*/;
wire                                cmos2_pclk_16bit    /*synthesis PAP_MARK_DEBUG="1"*/;
/******************************reg********************************************/
reg [11 : 0]              de_in_cnt    /* synthesis PAP_MARK_DEBUG="1" */;
reg                       de_in_d0     /* synthesis PAP_MARK_DEBUG="1" */;
reg                       de_in_d1     /* synthesis PAP_MARK_DEBUG="1" */;
reg                       vs_in_d0     /* synthesis PAP_MARK_DEBUG="1" */;
reg                       vs_in_d1     /* synthesis PAP_MARK_DEBUG="1" */;
reg [3 : 0]               de_in_state  /* synthesis PAP_MARK_DEBUG="1" */;

reg                       zoom_vs_in_d0   ;
reg                       zoom_vs_in_d1   ;
reg                       zoom_de_in_d0   ;
reg                       zoom_de_in_d1   ;
reg [11 : 0]              zoom_de_in_cnt  /* synthesis PAP_MARK_DEBUG="1" */;
reg [3 : 0]               zoom_de_in_state;

reg [11 : 0]              de_out_cnt    /* synthesis PAP_MARK_DEBUG="1" */;
reg                       r_de_out_d0   /* synthesis PAP_MARK_DEBUG="1" */;//由于fifo需要预读出，所以多打一拍
reg                       r_vs_out_d0   /* synthesis PAP_MARK_DEBUG="1" */;
reg                       de_out_d0     /* synthesis PAP_MARK_DEBUG="1" */;
reg                       de_out_d1     /* synthesis PAP_MARK_DEBUG="1" */;
reg                       vs_out_d0     /* synthesis PAP_MARK_DEBUG="1" */;
reg                       vs_out_d1     /* syntqqhesis PAP_MARK_DEBUG="1" */;
reg [3 : 0]               de_out_state  /* synthesis PAP_MARK_DEBUG="1" */;
reg [11 : 0]              r_x_act_d0    /* synthesis PAP_MARK_DEBUG="1" */;
reg [11 : 0]              r_x_act       /* synthesis PAP_MARK_DEBUG="1" */;
reg                       video0_rd_en/* synthesis PAP_MARK_DEBUG="1" */;
reg                       video1_rd_en/* synthesis PAP_MARK_DEBUG="1" */;
reg                       video2_rd_en/* synthesis PAP_MARK_DEBUG="1" */;
reg                       video3_rd_en/* synthesis PAP_MARK_DEBUG="1" */;
reg                       video_pre_rd_flag/* synthesis PAP_MARK_DEBUG="1" */;
wire                      w_video_pre_rd_flag;
assign w_video_pre_rd_flag = video_pre_rd_flag;
reg                        v_sync_flag;
reg [15:0]                rstn_1ms       ;
 
reg [7:0]                   cmos1_d_d0          ;
reg                         cmos1_href_d0       ;
reg                         cmos1_vsync_d0      ;
reg [7:0]                   cmos2_d_d0          /*synthesis PAP_MARK_DEBUG="1"*/;
reg                         cmos2_href_d0       /*synthesis PAP_MARK_DEBUG="1"*/;
reg                         cmos2_vsync_d0      /*synthesis PAP_MARK_DEBUG="1"*/;

reg [2:0]                   out_state            /*synthesis PAP_MARK_DEBUG="1"*/;
/******************************assign********************************************/
//assign pix_clk_out = pix_clk_in         ;//HDMI输入输出时钟相同 1080p 仿真使用
//       bits31-22 R；bits21-12 G；bits11-2 B；低两位保留
assign des_mac       = DES_MAC;
assign des_ip        = DES_IP;

assign rgb_in[31:24] = r_in;
assign rgb_in[23:22] = 2'd0;
assign rgb_in[21:14] = g_in;
assign rgb_in[13:12] = 2'd0;
assign rgb_in[11: 4] = b_in;
assign rgb_in[3 : 2] = 2'd0;
assign rgb_in[1 : 0] = 2'd0;
//assign rgb_in = de_in ? {r_in[7:3] , g_in[7:2] , b_in[7:3]} : 16'b0;
assign eth_rst_n_0 = ddr_ip_rst_n;
//临时
//assign de_out                 =       ddr_init_done? 1'b1 : 1'b0;
/******************************always********************************************/
/******************************instant********************************************/

//测量de个数
always @(posedge pix_clk_in) begin//抓下降沿
    if(!ddr_ip_rst_n) begin  
        vs_in_d0 <= 'd0;
        vs_in_d1 <= 'd0;
        de_in_d0 <= 'd0;
        de_in_d1 <= 'd0;
        de_in_cnt <= 'd0; 
        de_in_state <= 0;
    end
    else begin
       case(de_in_state) 
            DE_IN_WAIT:
            begin
                vs_in_d0 <= vs_in;
                vs_in_d1 <= vs_in_d0;
                if(!vs_in_d0 && vs_in_d1) begin
                    de_in_state <= DE_IN_CNT;//抓取vs_in下降沿，当抓到下降沿时开始计数
                end
            end
            DE_IN_CNT:
            begin
                de_in_d0 <= de_in;
                de_in_d1 <= de_in_d0;
                if(de_in_d0 && !de_in_d1) begin
                    de_in_cnt <= de_in_cnt + 1'd1;//抓取de上升沿，de上升时计数
                end
                else if(de_in_cnt == VIDEO_HIGTH) begin
                    de_in_state <= DE_IN_END;
                end
            end
            DE_IN_END:
            begin
                vs_in_d0 <= vs_in;
                vs_in_d1 <= vs_in_d0;
                if(vs_in_d0 && !vs_in_d1) begin
                    de_in_cnt <= 'd0;
                    de_in_state <= DE_IN_WAIT;//抓取vs_in上升沿，当抓到上升沿时计数归零
                end
            end
        endcase  
    end
end
//测量zoom de个数
always @(posedge pix_clk_in) begin//抓下降沿
    if(!ddr_ip_rst_n) begin  
        zoom_vs_in_d0    <= 'd0;
        zoom_vs_in_d1    <= 'd0;
        zoom_de_in_d0    <= 'd0;
        zoom_de_in_d1    <= 'd0;
        zoom_de_in_cnt   <= 'd0; 
        zoom_de_in_state <= 0;
    end
    else begin
       case(zoom_de_in_state) 
            DE_IN_WAIT:
            begin
                zoom_vs_in_d0 <= vs_in;
                zoom_vs_in_d1 <= zoom_vs_in_d0;
                if(!zoom_vs_in_d0 && zoom_vs_in_d1) begin
                    zoom_de_in_state <= DE_IN_CNT;//抓取vs_in下降沿，当抓到下降沿时开始计数
                end
            end
            DE_IN_CNT:
            begin
                zoom_de_in_d0 <= zoom_de_out;
                zoom_de_in_d1 <= zoom_de_in_d0;
                if(zoom_de_in_d0 && !zoom_de_in_d1) begin
                    zoom_de_in_cnt <= zoom_de_in_cnt + 1'd1;//抓取de上升沿，de上升时计数
                end
                else if(zoom_de_in_cnt == ZOOM_VIDEO_HIGTH) begin
                    zoom_de_in_state <= DE_IN_END;
                end
            end
            DE_IN_END:
            begin
                zoom_vs_in_d0 <= vs_in;
                zoom_vs_in_d1 <= zoom_vs_in_d0;
                if(vs_in_d0 && !vs_in_d1) begin
                    zoom_de_in_cnt <= 'd0;
                    zoom_de_in_state <= DE_IN_WAIT;//抓取vs_in上升沿，当抓到上升沿时计数归零
                end
            end
        endcase  
    end
end
//测量de_out个数
always @(posedge pix_clk_out) begin//抓下降沿
    if(!ddr_ip_rst_n) begin  
        vs_out_d0 <= 'd0;
        vs_out_d1 <= 'd0;
        de_out_d0 <= 'd0;
        de_out_d1 <= 'd0;
        de_out_cnt <= 'd0; 
        de_out_state <= 'd0;
    end
    else begin
       case(de_out_state) 
            DE_OUT_WAIT:
            begin
                vs_out_d0 <= vs_out;
                vs_out_d1 <= vs_out_d0;
                if(!vs_out_d0 && vs_out_d1) begin
                    de_out_state <= DE_OUT_CNT;//抓取vs_in下降沿，当抓到下降沿时开始计数
                end
            end
            DE_OUT_CNT:
            begin
                de_out_d0 <= de_out;
                de_out_d1 <= de_out_d0;
                if (de_out_d0 && !de_out_d1) begin
                    de_out_cnt <= de_out_cnt + 1'd1;//抓取de上升沿，de上升时计数
                end
                else if(de_out_cnt == VIDEO_HIGTH) begin
                    de_out_state <= DE_OUT_END;
                end
            end
            DE_OUT_END:
            begin
                vs_out_d0 <= vs_out;
                vs_out_d1 <= vs_out_d0;
                if(vs_out_d0 && !vs_out_d1) begin
                    de_out_cnt <= 'd0;
                    de_out_state <= DE_OUT_WAIT;//抓取vs_in上升沿，当抓到上升沿时计数归零
                end
            end
        endcase  
    end
end


//将传输后的信号进行输出
always @(posedge pix_clk_out) begin
    if(!ddr_ip_rst_n) begin
        r_vs_out <= 'd0;
        r_hs_out <= 'd0;
        r_de_out <= 'd0;
        r_r_out  <= 'd0;
        r_g_out  <= 'd0;
        r_b_out  <= 'd0;
        v_sync_flag <= 'd0;
        video0_rd_en <= 1'b0; 
        video1_rd_en <= 1'b0; 
        video2_rd_en <= 1'b0; 
        video3_rd_en <= 1'b0; 
        video_pre_rd_flag <= 1'b0;
        
        out_state <= 'd0;
    end 
    else if(ddr_init_done) begin 
        r_vs_out_d0 <= vs_out;
        r_vs_out    <= r_vs_out_d0;
        r_hs_out <= hs_out;
        r_de_out_d0 <= de_out;
        r_de_out <= r_de_out_d0;
        //r_de_out <= de_out;

        r_x_act_d0 <= x_act;//X轴坐标随着多打+一拍
        r_x_act <= r_x_act_d0;

       if(vs_out_d0 && !vs_out_d1) begin
            video_pre_rd_flag <= 'd0;
       end
       else if(!vs_out_d0 && vs_out_d1 && !video_pre_rd_flag && (fram0_done || fram1_done || fram2_done || fram3_done)) begin
            video0_rd_en      <= 'd1;
            video1_rd_en      <= 'd1;
            video2_rd_en      <= 'd1;
            video3_rd_en      <= 'd1;
            video_pre_rd_flag <= 'd1;
            out_state         <= 'd1;
       end
       else begin
           if( fram0_done && (r_x_act >= 0) && (r_x_act < ZOOM_VIDEO_LENGTH - 1) && (y_act < ZOOM_VIDEO_HIGTH ) && (y_act >= 0)) begin//左上角
                //test
                //test_out <=  video0_data_out;
                r_r_out  <=  video0_data_out[31:24];
                r_g_out  <=  video0_data_out[21:14];
                r_b_out  <=  video0_data_out[11: 4];  
                video0_rd_en <= de_out; //预读出
                video1_rd_en <= 'd0; 
                video2_rd_en <= 'd0; 
                video3_rd_en <= 'd0; //'d0; 
                out_state    <= 'd2;
                if(r_x_act == ZOOM_VIDEO_LENGTH - 2) begin
                    video1_rd_en <= de_out;
                    video0_rd_en <= 'd0;
                end
            end
            if(fram1_done &&(r_x_act >= ZOOM_VIDEO_LENGTH - 1) && (r_x_act < VIDEO_LENGTH - 1) && (y_act < ZOOM_VIDEO_HIGTH )&& (y_act >= 0)) begin//实际上是r_x_act 0~63
                //r_r_out  <= video1_data_out[31:24] ; 
                //r_g_out  <='d0 ; 
                //r_b_out  <='d0 ;
                //test
                //test_out <=  video1_data_out; 
                r_r_out  <= video1_data_out[31:24];
                r_g_out  <= video1_data_out[21:14];
                r_b_out  <= video1_data_out[11: 4];
                //r_r_out  <= {video1_data_out[15 : 11],3'b0};
                //r_g_out  <= {video1_data_out[10 :  5],2'b0};
                //r_b_out  <= {video1_data_out[4  :  0],3'b0}; 
                //
                //r_r_out  <= 'hff;
                //r_g_out  <= 'd00;
                //r_b_out  <= 'd00;
                video0_rd_en <= 'd0; 
                video1_rd_en <= de_out; 
                video2_rd_en <= 'd0; 
                video3_rd_en <= 'd0; 
                out_state    <= 'd3;

            end  
            if( fram2_done &&(r_x_act >= 0) && (r_x_act < ZOOM_VIDEO_LENGTH - 1) && (y_act < VIDEO_HIGTH )&& (y_act >= ZOOM_VIDEO_HIGTH)) begin//实际上是r_x_act 0~63
                //r_r_out  <='d0 ; 
                //r_g_out  <= video2_data_out[21:14] ; 
                //r_b_out  <='d0 ; 
                //test
                //test_out <=  video2_data_out;
                r_r_out  <= video2_data_out[31:24] ;
                r_g_out  <= video2_data_out[21:14] ;
                r_b_out  <= video2_data_out[11: 4] ;  
                video0_rd_en <= 'd0; 
                video1_rd_en <= 'd0; 
                video2_rd_en <= de_out; 
                video3_rd_en <= 'd0; 
                out_state    <= 'd4;
                if(r_x_act == ZOOM_VIDEO_LENGTH - 2) begin
                    video3_rd_en <= de_out;
                    video2_rd_en <= 'd0;
                end
            end    
            if(fram3_done &&(r_x_act >= ZOOM_VIDEO_LENGTH - 1) && (r_x_act < VIDEO_LENGTH - 1) && (y_act < VIDEO_HIGTH )&& (y_act >= ZOOM_VIDEO_HIGTH)) begin//实际上是r_x_act 0~63
                //r_r_out  <='d0 ; 
                //r_g_out  <='d0 ; 
                //r_b_out  <=video3_data_out[11:4] ;
                //test
                //test_out <=  video3_data_out;
                r_r_out  <= video3_data_out[31:24];
                r_g_out  <= video3_data_out[21:14];
                r_b_out  <= video3_data_out[11: 4];     
                video0_rd_en <= 'd0; 
                video1_rd_en <= 'd0; 
                video2_rd_en <= 'd0; 
                video3_rd_en <= de_out; 
                
                out_state    <= 'd5;
            end 
        end         
    end
    else begin
        r_vs_out <= 'd0;
        r_hs_out <= 'd0;
        r_de_out <= 'd0;
        r_r_out  <= 8'hff ;
        r_g_out  <= 8'h00 ;
        r_b_out  <= 8'h00 ;
        video0_rd_en <= 1'b0; 
        video1_rd_en <= 1'b0; 
        video2_rd_en <= 1'b0; 
        video3_rd_en <= 1'b0; 
        out_state    <= 'd7; 
    end            
end

always @(posedge iic_clk)begin
	if(!pll_init_done)
	    rstn_1ms <= 16'd0;
	else if(!ddr_init_done) begin
  	    rstn_1ms <= 16'd0;  
    end
	else if(!rst_board) begin
  	    rstn_1ms <= 16'd0;  
    end
	else begin
		if(rstn_1ms == 16'h2710)
		    rstn_1ms <= rstn_1ms;
		else
		    rstn_1ms <= rstn_1ms + 1'b1;
	end
end
assign hdmi_rst = (rstn_1ms == 16'h2710);
hdmi_ctrl user_hdmi_ctrl(
    .clk         (  iic_clk    ), //input       clk,
    .rst_n       (  hdmi_rst   ), //input       rstn, 
    .init_over   (  hdmi_int_led  ), //output      init_over,
    .iic_tx_scl  (  iic_tx_scl ), //output      iic_scl,
    .iic_tx_sda  (  iic_tx_sda ), //inout       iic_sda
    .iic_scl     (  iic_scl    ), //output      iic_scl,
    .iic_sda     (  iic_sda    )  //inout       iic_sda
);
//ov5640配置
//CMOS1 Camera 720P，缩放至540P，30帧
ov5640_reg_cfg_0	coms1_reg_config(
	.clk_25M                 (clk_25M            ),//input
	.camera_rstn             (cmos1_reset        ),//input
	.initial_en              (initial_en         ),//input		
	.i2c_sclk                (cmos1_scl          ),//output
	.i2c_sdat                (cmos1_sda          ),//inout
	.reg_conf_done           (cmos_init_done[0]  ),//output config_finished
	.reg_index               (                   ),//output reg [8:0]
	.clock_20k               (                   ) //output reg
);
//CMOS2 Camera 
ov5640_reg_config	coms2_reg_config(
    	.clk_25M                 (clk_25M            ),//input
    	.camera_rstn             (cmos2_reset        ),//input
    	.initial_en              (initial_en         ),//input		
    	.i2c_sclk                (cmos2_scl          ),//output
    	.i2c_sdat                (cmos2_sda          ),//inout
    	.reg_conf_done           (cmos_init_done[1]  ),//output config_finished
    	.reg_index               (                   ),//output reg [8:0]
    	.clock_20k               (                   ) //output reg
    );
ov5640_power_on_delay	power_on_delay_inst(
	.clk_50M                 (ref_clk        ),//input
	.reset_n                 (ddr_ip_rst_n           ),//input	
	.camera1_rstn            (cmos1_reset    ),//output
	.camera2_rstn            (cmos2_reset    ),//output	
	.camera_pwnd             (               ),//output
	.initial_en              (initial_en     ) //output		
);
//CMOS 8bit转16bit//////////
//CMOS1
always@(posedge cmos1_pclk)
    begin
        cmos1_d_d0        <= cmos1_data    ;
        cmos1_href_d0     <= cmos1_href    ;
        cmos1_vsync_d0    <= cmos1_vsync   ;
    end

cmos_8_16bit cmos1_8_16bit(
	.pclk           (cmos1_pclk       ),//input
	.rst_n          (cmos_init_done[0]),//input
	.pdata_i        (cmos1_d_d0       ),//input[7:0]
	.de_i           (cmos1_href_d0    ),//input
	.vs_i           (cmos1_vsync_d0    ),//input
	
	.pixel_clk      (cmos1_pclk_16bit ),//output
	.pdata_o        (cmos1_d_16bit    ),//output[15:0] rgb565 r在高5位
	.de_o           (cmos1_href_16bit ) //output
);
//CMOS2
always@(posedge cmos2_pclk)
    begin
        cmos2_d_d0        <= cmos2_data    ;
        cmos2_href_d0     <= cmos2_href    ;
        cmos2_vsync_d0    <= cmos2_vsync   ;
    end

cmos_8_16bit cmos2_8_16bit(
	.pclk           (cmos2_pclk       ),//input
	.rst_n          (cmos_init_done[1]),//input
	.pdata_i        (cmos2_d_d0       ),//input[7:0]
	.de_i           (cmos2_href_d0    ),//input
	.vs_i           (cmos2_vsync_d0    ),//input
	
	.pixel_clk      (cmos2_pclk_16bit ),//output
	.pdata_o        (cmos2_d_16bit    ),//output[15:0]
	.de_o           (cmos2_href_16bit ) //output
);

 

ipsxb_rst_sync_v1_1 u_core_clk_rst_sync(
    .clk                        (ref_clk        ),
    .rst_n                      (rst_board       ),
    .sig_async                  (1'b1),
    .sig_synced                 (ddr_ip_rst_n   )
);

//初始化顺序：DDR->AXI_M & FIFO ->IIC PLL -HDMI
axi_m_arbitration #(
    .VIDEO_LENGTH     (VIDEO_LENGTH)                    ,
    .VIDEO_HIGTH      (VIDEO_HIGTH)                     ,
    .ZOOM_VIDEO_LENGTH(ZOOM_VIDEO_LENGTH )              ,
    .ZOOM_VIDEO_HIGTH (ZOOM_VIDEO_HIGTH )               ,
    .PIXEL_WIDTH      (PIXEL_WIDTH  )                            ,
	.CTRL_ADDR_WIDTH  (CTRL_ADDR_WIDTH  )                            ,
	.DQ_WIDTH	     (DQ_WIDTH  )                            ,
    .M_AXI_BRUST_LEN  (M_AXI_BRUST_LEN   )
)
user_axi_m_arbitration (
	.DDR_INIT_DONE           (ddr_init_done),
	.M_AXI_ACLK              (ddr_ip_clk   ),
	.M_AXI_ARESETN           (ddr_ip_rst_n  && ddr_init_done),
     .pix_clk_out             (pix_clk_out),//1080p 148.5m
      
	//写地址通道↓                                                              
	.M_AXI_AWID              (M_AXI_AWID   ),
	.M_AXI_AWADDR            (M_AXI_AWADDR ),
//	.M_AXI_AWLEN             (),
	.M_AXI_AWUSER            (M_AXI_AWUSER ),
	.M_AXI_AWVALID           (M_AXI_AWVALID),
	.M_AXI_AWREADY           (M_AXI_AWREADY),
	//写数据通道↓                                                              
	.M_AXI_WDATA             (M_AXI_WDATA),
	.M_AXI_WSTRB             (M_AXI_WSTRB),
	.M_AXI_WLAST             (M_AXI_WLAST),
	.M_AXI_WUSER             (M_AXI_WUSER),
	.M_AXI_WREADY            (M_AXI_WREADY),
                                                             
	//读地址通道↓                                                              
	.M_AXI_ARID              (M_AXI_ARID),
    .M_AXI_ARUSER            (M_AXI_ARUSER),
	.M_AXI_ARADDR            (M_AXI_ARADDR),
//	.M_AXI_ARLEN             (),
	.M_AXI_ARVALID           (M_AXI_ARVALID),
	.M_AXI_ARREADY           (M_AXI_ARREADY),
	//读数据通道↓                                                              
	.M_AXI_RID               (M_AXI_RID   ),
	.M_AXI_RDATA             (M_AXI_RDATA ),
	.M_AXI_RLAST             (M_AXI_RLAST ),
	.M_AXI_RVALID            (M_AXI_RVALID),
    //video
    .vs_in                   (vs_in       ),
    .vs_out                  (vs_out      ),
//fifo0信号          
    .video0_clk_in           (pix_clk_in),                                                                                                                  
    .video0_de_in            (zoom_de_out    ),
    .video0_data_in          (zoom_data_out  ),
    .video0_rd_en            (video0_rd_en   ),
    .video0_data_out         (video0_data_out),
    .fram0_done              (fram0_done     ),
    .video0_vs_in            (vs_in ),//用于抓取复位
//fifo1信号
    .video1_clk_in           (pix_clk_in),                                                               
    .video1_de_in            (zoom_de_out    ),
    .video1_data_in          (zoom_data_out  ),
    .video1_rd_en            (video1_rd_en   ),
    .video1_data_out         (video1_data_out),
    .fram1_done              (fram1_done     ),
    .video1_vs_in            (vs_in ),//用于抓取复位
    //.video1_clk_in           (rgmii_clk_0    ),    
    //.video1_de_in            (eth0_rx_de     ),
    //.video1_data_in          ({eth0_rx_data[15:11],5'b0,eth0_rx_data[10:5],4'b0,eth0_rx_data[4:0],7'b0} ),
    //.video1_rd_en            (video1_rd_en   ),
    //.video1_data_out         (video1_data_out),
    //.fram1_done              (fram1_done     ),
    //.video1_vs_in            (eth0_rx_vs     ),//用于抓取复位
//fifo2信号，接CMOS1                                  
    .video2_clk_in           (cmos1_pclk_16bit),                       
    .video2_de_in            (cmos1_href_16bit ),
    .video2_data_in          ({cmos1_d_16bit[4:0],5'b0,cmos1_d_16bit[10:5],4'b0,cmos1_d_16bit[15:11],7'b0}),//27
    .video2_rd_en            (video2_rd_en   ),
    .video2_data_out         (video2_data_out),
    .fram2_done              (fram2_done     ),
    .video2_vs_in            (cmos1_vsync_d0 ),//用于抓取复位
//fifo3信号                                        
    .video3_clk_in           (cmos2_pclk_16bit),                       
    .video3_de_in            (cmos2_href_16bit    ),
    .video3_data_in          ({cmos2_d_16bit[4:0],5'b0,cmos2_d_16bit[10:5],4'b0,cmos2_d_16bit[15:11],7'b0}  ),
    .video3_rd_en            (video3_rd_en   ),
    .video3_data_out         (video3_data_out),
    .fram3_done              (fram3_done     ),
    .video3_vs_in            (cmos2_vsync_d0 ),//用于抓取复位
    //其他
    .wr_addr_min             (RW_ADDR_MIN),//写数据ddr最小地址0地址开始算，1920*1080*16 = 33177600 bits
    .wr_addr_max             (RW_ADDR_MAX), //写数据ddr最大地址，一个地址存32位 33177600/32 = 1036800 = 20'b1111_1101_0010_0000_0000
    .y_act                   (y_act)        , 
    .x_act                   (x_act)  

);

sync_generator user_sync_gen(
    .clk       (pix_clk_out ),//1080p参考时钟为148.5mhz
    .rstn      (ddr_ip_rst_n && ddr_init_done),
    .vs_out    (vs_out),
    .hs_out    (hs_out),
    .de_out    (de_out),
    .de_re     (),
    .x_act     (x_act),
    .y_act     (y_act)
);

video_zoom hdmi_video_zoom(
    .clk                (pix_clk_in),
    .rstn               (ddr_ip_rst_n && ddr_init_done),
    .vs_in              (vs_in                        ) ,
    .hs_in              (hs_in                        ) ,
    .de_in              (de_in                        ) ,
    .video_data_in      (rgb_in                       ),
    .de_out             (zoom_de_out                  ),
    .video_data_out     (zoom_data_out                )
   );


pll_cfg user_pll_cfg (
  .clkin1(ref_clk),        // input
  .pll_lock(pll_init_done),    // output
  .clkout0(iic_clk),      // output
  .clkout1(clk_25M)       // output
);

pll_video_out user_pll_video_out (
  .clkin1(ref_clk),        // input
  .pll_lock(pll_lock),    // output
  .clkout0(pix_clk_out)       // output
);


reg [11 : 0]              cmos1_de_in_cnt    /* synthesis PAP_MARK_DEBUG="1" */;
reg [11 : 0]              cmos1_h_cnt        /* synthesis PAP_MARK_DEBUG="1" */;

reg                       cmos1_de_in_d0     /* synthesis PAP_MARK_DEBUG="1" */;
reg                       cmos1_de_in_d1     /* synthesis PAP_MARK_DEBUG="1" */;
reg                       cmos1_vs_in_d0     /* synthesis PAP_MARK_DEBUG="1" */;
reg                       cmos1_vs_in_d1     /* synthesis PAP_MARK_DEBUG="1" */;
reg [3 : 0]               cmos1_de_in_state  /* synthesis PAP_MARK_DEBUG="1" */;

always @(posedge cmos1_pclk_16bit) begin//抓下降沿
    if(!ddr_ip_rst_n) begin  
        cmos1_vs_in_d0 <= 'd0;
        cmos1_vs_in_d1 <= 'd0;
        cmos1_de_in_d0 <= 'd0;
        cmos1_de_in_d1 <= 'd0;
        cmos1_de_in_cnt <= 'd0; 
        cmos1_de_in_state <= 'd0;
        cmos1_h_cnt     <= 'd0;
    end
    else begin
       case(cmos1_de_in_state) 
            DE_IN_WAIT:
            begin
                cmos1_vs_in_d0 <= cmos1_vsync;
                cmos1_vs_in_d1 <= cmos1_vs_in_d0;
                if(!cmos1_vs_in_d0 && cmos1_vs_in_d1) begin
                    cmos1_de_in_state <= DE_IN_CNT;//抓取vs_in下降沿，当抓到下降沿时开始计数
                end
            end
            DE_IN_CNT:
            begin
                cmos1_de_in_d0 <= cmos1_href_16bit;
                cmos1_de_in_d1 <= cmos1_de_in_d0;
                if(cmos1_de_in_d0 && !cmos1_de_in_d1) begin
                    cmos1_de_in_cnt <= cmos1_de_in_cnt + 1'd1;//抓取de上升沿，de上升时计数
                end
                if(cmos1_href_16bit) begin
                    cmos1_h_cnt <= cmos1_h_cnt +'d1;
                end
                else begin
                    cmos1_h_cnt <= 'd0;
                end
                cmos1_vs_in_d0 <= cmos1_vsync;
                cmos1_vs_in_d1 <= cmos1_vs_in_d0;
                if(cmos1_vs_in_d0 && !cmos1_vs_in_d1) begin
                    cmos1_de_in_cnt <= 'd0;
                    cmos1_de_in_state <= DE_IN_WAIT;//抓取vs_in上升沿，当抓到上升沿时计数归零
                end
            end
        endcase  
    end
end
//ddr IP例化
ddr_test  #
  (
   //***************************************************************************
   // The following parameters are Memory Feature
   //***************************************************************************
   .MEM_ROW_WIDTH          (MEM_ROW_ADDR_WIDTH),     //行宽度？
   .MEM_COLUMN_WIDTH       (MEM_COL_ADDR_WIDTH),     //列宽度？
   .MEM_BANK_WIDTH         (MEM_BADDR_WIDTH   ),     //bank宽度？
   .MEM_DQ_WIDTH           (MEM_DQ_WIDTH      ),     //数据宽度
   .MEM_DM_WIDTH           (MEM_DM_WIDTH      ),     
   .MEM_DQS_WIDTH          (MEM_DQS_WIDTH     ),     
   .CTRL_ADDR_WIDTH        (CTRL_ADDR_WIDTH   )     //地址宽度 = 行宽度+列宽度+bank地址？不太理解
  )
  I_ipsxb_ddr_top(
   .ref_clk                (ref_clk                ),
   .resetn                 (ddr_ip_rst_n           ),
   .ddr_init_done          (ddr_init_done          ),
   .ddrphy_clkin           (ddr_ip_clk             ),
   .pll_lock               (ddr_pll_lock               ), 
    //写地址
   .axi_awaddr             (M_AXI_AWADDR           ),//写地址
   .axi_awuser_ap          (M_AXI_AWUSER           ),//precharge？
   .axi_awuser_id          (M_AXI_AWID             ),
   .axi_awlen              (M_AXI_BRUST_LEN        ),//突发长度
   .axi_awready            (M_AXI_AWREADY          ),//out,从机awready
   .axi_awvalid            (M_AXI_AWVALID          ),//主机awvalid
    //写数据
   .axi_wdata              (M_AXI_WDATA            ),//位宽为DQ_WIDTH*8  迷惑 这里为什么是32*8？
   .axi_wstrb              (M_AXI_WSTRB            ),
   .axi_wready             (M_AXI_WREADY           ),//OUT 从机wready 这里没用valid 所以主机收到ready继续发送就行
   .axi_wusero_id          (M_AXI_WUSER            ),
   .axi_wusero_last        (M_AXI_WLAST            ),//out 从机写last
    //读地址                   
   .axi_araddr             (M_AXI_ARADDR           ),
   .axi_aruser_ap          (M_AXI_ARUSER           ),
   .axi_aruser_id          (M_AXI_ARID             ),
   .axi_arlen              (M_AXI_BRUST_LEN        ),
   .axi_arready            (M_AXI_ARREADY          ),
   .axi_arvalid            (M_AXI_ARVALID          ),
    //读数据
   .axi_rdata              (M_AXI_RDATA             ),
   .axi_rid                (M_AXI_RID            ),
   .axi_rlast              (M_AXI_RLAST            ),
   .axi_rvalid             (M_AXI_RVALID           ),

   .apb_clk                (1'b0                   ),
   .apb_rst_n              (1'b1                   ),
   .apb_sel                (1'b0                   ),
   .apb_enable             (1'b0                   ),
   .apb_addr               (8'b0                   ),
   .apb_write              (1'b0                   ),
   .apb_ready              (                       ),
   .apb_wdata              (16'b0                  ),
   .apb_rdata              (                       ),
   .apb_int                (                       ),
   .debug_data             (                       ),
   .debug_slice_state      (                       ),
   .debug_calib_ctrl       (                       ),
   .ck_dly_set_bin         (                       ),
   .force_ck_dly_en        (1'b0                   ),
   .force_ck_dly_set_bin   (8'h05                  ),
   .dll_step               (                       ),
   .dll_lock               (                       ),
   .init_read_clk_ctrl     (2'b0                   ),                                                       
   .init_slip_step         (4'b0                   ), 
   .force_read_clk_ctrl    (1'b0                   ),  
   .ddrphy_gate_update_en  (1'b0                   ),
   .update_com_val_err_flag(                       ),
   .rd_fake_stop           (1'b0                   ),
    //内存接口
   .mem_rst_n              (mem_rst_n              ),
   .mem_ck                 (mem_ck                 ),
   .mem_ck_n               (mem_ck_n               ),
   .mem_cke                (mem_cke                ),
   .mem_cs_n               (mem_cs_n               ),
   .mem_ras_n              (mem_ras_n              ),
   .mem_cas_n              (mem_cas_n              ),
   .mem_we_n               (mem_we_n               ),
   .mem_odt                (mem_odt                ),
   .mem_a                  (mem_a                  ),
   .mem_ba                 (mem_ba                 ),
   .mem_dqs                (mem_dqs                ),
   .mem_dqs_n              (mem_dqs_n              ),
   .mem_dq                 (mem_dq                 ),
   .mem_dm                 (mem_dm                 )
  );

wire         video_enhance_vs_out;
wire         video_enhance_hs_out;
wire         video_enhance_de_out;
wire [7 : 0] video_enhance_r_out;
wire [7 : 0] video_enhance_g_out;
wire [7 : 0] video_enhance_b_out;

wire [7  : 0]    video_enhance_lightdown_num;
wire             video_enhance_lightdown_sw ;
wire [7  : 0]    video_enhance_darkup_num   ;
wire             video_enhance_darkup_sw    ;

wire                    eth_zoom_de_out/* synthesis PAP_MARK_DEBUG="1" */;
wire [31 : 0]           eth_zoom_data_out;
wire [31 : 0]           eth_zoom_data__in;
assign eth_zoom_data__in = {video_enhance_r_out,2'b0,video_enhance_g_out,2'b0,video_enhance_b_out,4'b0};

video_zoom eth_video_zoom(
 .clk                (pix_clk_out),
 .rstn               (rst_board),
 .vs_in              (video_enhance_vs_out                        ) ,
 .hs_in              (video_enhance_hs_out                        ) ,
 .de_in              (video_enhance_de_out                        ) ,
 .video_data_in      (eth_zoom_data__in                    ),
 .de_out             (eth_zoom_de_out                  ),
 .video_data_out     (eth_zoom_data_out                )
);

video_enhance u_video_enhance(
.pix_clk(pix_clk_out),//input  wire            
.vs_in  (r_vs_out),//input  wire            
.hs_in  (),//input  wire            
.de_in  (r_de_out),//input  wire         zoom_de_out              
.r_in   (r_r_out),//input  wire [7 : 0] zoom_data_out[31 : 24]   
.g_in   (r_g_out),//input  wire [7 : 0] zoom_data_out[21 : 14]   
.b_in   (r_b_out),//input  wire [7 : 0] zoom_data_out[11 :  4]
   
.vs_out (video_enhance_vs_out  ),//output wire                               
.hs_out (video_enhance_hs_out  ),//output wire            
.de_out (video_enhance_de_out  ),//output wire            
.r_out  (video_enhance_r_out   ),//output wire [7 : 0]    
.g_out  (video_enhance_g_out   ),//output wire [7 : 0]    
.b_out  (video_enhance_b_out   ), //output wire [7 : 0]    
.video_enhance_lightdown_num (video_enhance_lightdown_num),//input wire [7 : 0]            
.video_enhance_lightdown_sw  (video_enhance_lightdown_sw ),//input wire                    
.video_enhance_darkup_num    (video_enhance_darkup_num   ),//input wire [7 : 0]            
.video_enhance_darkup_sw     (video_enhance_darkup_sw    )//input wire                            
   );


////************************************    PCIE   ***********************************************


pcie_dma_ctrl u_pcie_dam_ctrl(
   .clk                (pclk_div2 ), //input wire   
   .pix_clk_out        (pix_clk_out),          
   .rstn               (rst_board), //input              
    
   .axis_master_tvalid (axis_master_tvalid), //input wire                
   .axis_master_tready (axis_master_tready), //output wire               
   .axis_master_tdata  (axis_master_tdata), //input wire    [127:0]     
   .axis_master_tkeep  (axis_master_tkeep), //input wire    [3:0]       
   .axis_master_tlast  (axis_master_tlast), //input wire                
   .axis_master_tuser  (axis_master_tuser), //input wire    [7:0]       
 
   .ep_bus_num         (cfg_pbus_num), //input  [7 : 0]         
   .ep_dev_num         (cfg_pbus_dev_num), //input  [4 : 0] 
        
   .AXIS_S_TREADY      (axis_slave2_tready ), //input                  
   .AXIS_S_TVALID      (axis_slave2_tvalid ), //output                 
   .AXIS_S_TDATA       (axis_slave2_tdata  ), //output [127:0]         
   .AXIS_S_TLAST       (axis_slave2_tlast  ), //output                 
   .AXIS_S_TUSER       (axis_slave2_tuser  ), //output 
   .hdmi_data_in       (pcie_data_out      ), // input 32bits
   .vs_in              (r_vs_out             ),                   
   .de_in              (r_de_out           ) ,
   .video_enhance_lightdown_num (video_enhance_lightdown_num),// output reg [7 : 0]        
   .video_enhance_lightdown_sw  (video_enhance_lightdown_sw ),// output reg                
   .video_enhance_darkup_num    (video_enhance_darkup_num   ),// output reg [7 : 0]        
   .video_enhance_darkup_sw     (video_enhance_darkup_sw    ) // output reg            
   );
wire    [127 : 0 ]  axis_master_tdata /* synthesis PAP_MARK_DEBUG="1" */;
wire    [15: 0] pcie_data_out /* synthesis PAP_MARK_DEBUG="1" */;
//assign    pcie_data_out =  r_de_out?{r_r_out,r_g_out,r_b_out,'hdd} : 'd0;
assign    pcie_data_out =  video_enhance_de_out?{video_enhance_r_out[7:3],video_enhance_g_out[7:2],video_enhance_b_out[7:3]} : 'd0;

//----------------------------------------------------------rst debounce ----------------------------------------------------------
//ASYNC RST  define IPSL_PCIE_SPEEDUP_SIM when simulation
hsst_rst_cross_sync_v1_0 #(
    `ifdef IPSL_PCIE_SPEEDUP_SIM
    .RST_CNTR_VALUE     (16'h10             )
    `else
    .RST_CNTR_VALUE     (16'hC000           )
    `endif
)
u_refclk_buttonrstn_debounce(
    .clk                (pcie_ref_clk            ),
    .rstn_in            (rst_board       ),
    .rstn_out           (sync_button_rst_n  )
);

hsst_rst_cross_sync_v1_0 #(
    `ifdef IPSL_PCIE_SPEEDUP_SIM
    .RST_CNTR_VALUE     (16'h10             )
    `else
    .RST_CNTR_VALUE     (16'hC000           )
    `endif
)
u_refclk_perstn_debounce(
    .clk                (pcie_ref_clk            ),
    .rstn_in            (pcie_perst_n            ),
    .rstn_out           (sync_perst_n       )
);

ipsl_pcie_sync_v1_0  u_ref_core_rstn_sync    (
    .clk                (pcie_ref_clk            ),
    .rst_n              (core_rst_n         ),
    .sig_async          (1'b1               ),
    .sig_synced         (ref_core_rst_n     )
);

ipsl_pcie_sync_v1_0  u_pclk_core_rstn_sync   (
    .clk                (pclk               ),
    .rst_n              (core_rst_n         ),
    .sig_async          (1'b1               ),
    .sig_synced         (s_pclk_rstn        )
);

ipsl_pcie_sync_v1_0  u_pclk_div2_core_rstn_sync   (
    .clk                (pclk_div2          ),
    .rst_n              (core_rst_n         ),
    .sig_async          (1'b1               ),
    .sig_synced         (s_pclk_div2_rstn   )
);
//axis slave 2 interface
wire            axis_slave2_tready      ;
wire            axis_slave2_tvalid      ;
wire    [127:0] axis_slave2_tdata       ;
wire            axis_slave2_tlast       ;
wire            axis_slave2_tuser       ;

wire    [7:0]   cfg_pbus_num            ;
wire    [4:0]   cfg_pbus_dev_num        ;
wire    [2:0]   cfg_max_rd_req_size     ;
wire    [2:0]   cfg_max_payload_size    ;
wire            cfg_rcb                 ;
//system signal
wire    [4:0]   smlh_ltssm_state       /* synthesis PAP_MARK_DEBUG="1" */;
wire            core_rst_n             /* synthesis PAP_MARK_DEBUG="1" */;
wire            sync_button_rst_n      /* synthesis PAP_MARK_DEBUG="1" */;
wire            sync_perst_n           /* synthesis PAP_MARK_DEBUG="1" */;  
wire            smlh_link_up           /* synthesis PAP_MARK_DEBUG="1" */;
wire            rdlh_link_up           /* synthesis PAP_MARK_DEBUG="1" */; 
    

assign axis_slave0_tvalid      = 'd0;
assign axis_slave0_tlast       = 'd0;
assign axis_slave0_tuser       = 'd0;
assign axis_slave0_tdata       = 'd0;
assign axis_slave1_tvalid      = 'd0;
assign axis_slave1_tlast       = 'd0;
assign axis_slave1_tuser       = 'd0;
assign axis_slave1_tdata       = 'd0;

pcie_test u_ipsl_pcie_wrap
(
    .button_rst_n               (sync_button_rst_n      ),
    .power_up_rst_n             (sync_perst_n           ),
    .perst_n                    (sync_perst_n           ),
    //clk and rst
    .free_clk                   (ref_clk               ),
    .pclk                       (pclk                   ),      //output
    .pclk_div2                  (pclk_div2              ),      //output
    .ref_clk                    (pcie_ref_clk                ),      //output
    .ref_clk_n                  (ref_clk_n              ),      //input
    .ref_clk_p                  (ref_clk_p              ),      //input
    .core_rst_n                 (core_rst_n             ),      //output
    
    //APB interface to  DBI cfg
//  .p_clk                      (ref_clk                ),      //input
    .p_sel                      (                       ),      //input
    .p_strb                     (                       ),      //input  [ 3:0]
    .p_addr                     (                       ),      //input  [15:0]
    .p_wdata                    (                       ),      //input  [31:0]
    .p_ce                       (                       ),      //input
    .p_we                       (                       ),      //input
    .p_rdy                      (                       ),      //output
    .p_rdata                    (                       ),      //output [31:0]
    
    //PHY diff signals
    .rxn                        (rxn                    ),      //input   max[3:0]
    .rxp                        (rxp                    ),      //input   max[3:0]
    .txn                        (txn                    ),      //output  max[3:0]
    .txp                        (txp                    ),      //output  max[3:0]
    
    .pcs_nearend_loop           ({2{1'b0}}              ),      //input
    .pma_nearend_ploop          ({2{1'b0}}              ),      //input
    .pma_nearend_sloop          ({2{1'b0}}              ),      //input
    
    //AXIS master interface
    .axis_master_tvalid         (axis_master_tvalid     ),      //output
    .axis_master_tready         (axis_master_tready     ),      //input
    .axis_master_tdata          (axis_master_tdata      ),      //output [127:0]
    .axis_master_tkeep          (axis_master_tkeep      ),      //output [3:0]
    .axis_master_tlast          (axis_master_tlast      ),      //output
    .axis_master_tuser          (axis_master_tuser      ),      //output [7:0]
    
    //axis slave 0 interface
    .axis_slave0_tready         (axis_slave0_tready     ),      //output
    .axis_slave0_tvalid         (axis_slave0_tvalid     ),      //input
    .axis_slave0_tdata          (axis_slave0_tdata      ),      //input  [127:0]
    .axis_slave0_tlast          (axis_slave0_tlast      ),      //input
    .axis_slave0_tuser          (axis_slave0_tuser      ),      //input
    
    //axis slave 1 interface
    .axis_slave1_tready         (axis_slave1_tready     ),      //output
    .axis_slave1_tvalid         (axis_slave1_tvalid     ),      //input
    .axis_slave1_tdata          (axis_slave1_tdata      ),      //input  [127:0]
    .axis_slave1_tlast          (axis_slave1_tlast      ),      //input
    .axis_slave1_tuser          (axis_slave1_tuser      ),      //input
    //axis slave 2 interface
    .axis_slave2_tready         (axis_slave2_tready     ),      //output
    .axis_slave2_tvalid         (axis_slave2_tvalid     ),      //input
    .axis_slave2_tdata          (axis_slave2_tdata      ),      //input  [127:0]
    .axis_slave2_tlast          (axis_slave2_tlast      ),      //input
    .axis_slave2_tuser          (axis_slave2_tuser      ),      //input
     
    .pm_xtlh_block_tlp          (                       ),      //output
    
    .cfg_send_cor_err_mux       (                       ),      //output
    .cfg_send_nf_err_mux        (                       ),      //output
    .cfg_send_f_err_mux         (                       ),      //output
    .cfg_sys_err_rc             (                       ),      //output
    .cfg_aer_rc_err_mux         (                       ),      //output
    //radm timeout
    .radm_cpl_timeout           (                       ),      //output
    
    //configuration signals
    .cfg_max_rd_req_size        (cfg_max_rd_req_size    ),      //output [2:0]
    .cfg_bus_master_en          (                       ),      //output
    .cfg_max_payload_size       (cfg_max_payload_size   ),      //output [2:0]
    .cfg_ext_tag_en             (                       ),      //output
    .cfg_rcb                    (cfg_rcb                ),      //output
    .cfg_mem_space_en           (                       ),      //output
    .cfg_pm_no_soft_rst         (                       ),      //output
    .cfg_crs_sw_vis_en          (                       ),      //output
    .cfg_no_snoop_en            (                       ),      //output
    .cfg_relax_order_en         (                       ),      //output
    .cfg_tph_req_en             (                       ),      //output [2-1:0]
    .cfg_pf_tph_st_mode         (                       ),      //output [3-1:0]
    .rbar_ctrl_update           (                       ),      //output
    .cfg_atomic_req_en          (                       ),      //output
    
    .cfg_pbus_num               (cfg_pbus_num           ),      //output [7:0]
    .cfg_pbus_dev_num           (cfg_pbus_dev_num       ),      //output [4:0]
    
    //debug signals
    .radm_idle                  (                       ),      //output
    .radm_q_not_empty           (                       ),      //output
    .radm_qoverflow             (                       ),      //output
    .diag_ctrl_bus              (2'b0                   ),      //input   [1:0]
    .cfg_link_auto_bw_mux       (                       ),      //output              merge cfg_link_auto_bw_msi and cfg_link_auto_bw_int
    .cfg_bw_mgt_mux             (                       ),      //output              merge cfg_bw_mgt_int and cfg_bw_mgt_msi
    .cfg_pme_mux                (                       ),      //output              merge cfg_pme_int and cfg_pme_msi
    .app_ras_des_sd_hold_ltssm  (1'b0                   ),      //input
    .app_ras_des_tba_ctrl       (2'b0                   ),      //input   [1:0]
    
    .dyn_debug_info_sel         (4'b0                   ),      //input   [3:0]
    .debug_info_mux             (                       ),      //output  [132:0]
    
    //system signal
    .smlh_link_up               (smlh_link_up           ),      //output
    .rdlh_link_up               (rdlh_link_up           ),      //output
    .smlh_ltssm_state           (smlh_ltssm_state       )       //output  [4:0]
);

//assign rgb_in[31:24] = r_in;
//assign rgb_in[23:22] = 2'd0;
//assign rgb_in[21:14] = g_in;
//assign rgb_in[13:12] = 2'd0;
//assign rgb_in[11: 4] = b_in;
//assign rgb_in[3 : 2] = 2'd0;
//assign rgb_in[1 : 0] = 2'd0;
//rgb565
wire [15 : 0] eth0_img_data;
wire          eth0_img_de  ;
//assign eth0_img_de = zoom_de_out;
//assign eth0_img_data[15 : 11] = zoom_data_out[31 : 27];//r5 
//assign eth0_img_data[10 :  5] = zoom_data_out[21 : 16];//g6 
//assign eth0_img_data[4  :  0] = zoom_data_out[11 :  7];//b5 

wire [31 :  0] video1_data_in;
//assign video1_data_in [31 : 27] = 16'h0;
//assign video1_data_in [31 : 27] = eth0_rx_data[15 : 11];//r5
//assign video1_data_in [10 :  5] = eth0_rx_data[10 :  5];//g6
//assign video1_data_in [4  :  0] = eth0_rx_data[4  :  0];//b5
//assign video1_data_in[31 : 27] = eth0_rx_data[15 : 11];//r5
//assign video1_data_in[26 : 22] = 5'b0;//rxx
//assign video1_data_in[21 : 16] = eth0_rx_data[10 :  5];//g6
//assign video1_data_in[15 : 12] = 4'b0;//gxx
//assign video1_data_in[11 :  7] = eth0_rx_data[4  :  0];//b5
//assign video1_data_in[6  :  0] = 7'b0;//bxx


wire             rgmii_clk_0/* synthesis PAP_MARK_DEBUG="1" */;
wire             eth0_img_de/* synthesis PAP_MARK_DEBUG="1" */;
wire [15 : 0]    eth0_img_data/* synthesis PAP_MARK_DEBUG="1" */;
wire             tx_req/* synthesis PAP_MARK_DEBUG="1" */;
wire             udp_tx_done/* synthesis PAP_MARK_DEBUG="1" */;
wire             tx_start_en/* synthesis PAP_MARK_DEBUG="1" */;
wire [31 : 0]    tx_data    /* synthesis PAP_MARK_DEBUG="1" */;
wire [15 : 0]    tx_byte_num/* synthesis PAP_MARK_DEBUG="1" */;
wire             mac_tx_data_valid_0/* synthesis PAP_MARK_DEBUG="1" */;
wire [7  : 0]    mac_tx_data_0      /* synthesis PAP_MARK_DEBUG="1" */;
wire             mac_rx_error_0     /* synthesis PAP_MARK_DEBUG="1" */;
wire             mac_rx_data_valid_0/* synthesis PAP_MARK_DEBUG="1" */;
wire [7  : 0]    mac_rx_data_0      /* synthesis PAP_MARK_DEBUG="1" */;
wire             rec_pkt_done/* synthesis PAP_MARK_DEBUG="1" */;
wire             rec_en      /* synthesis PAP_MARK_DEBUG="1" */;
wire [31 : 0]    rec_data    /* synthesis PAP_MARK_DEBUG="1" */;
wire [15 : 0]    rec_byte_num/* synthesis PAP_MARK_DEBUG="1" */;

wire [15 : 0]    eth0_rx_data/* synthesis PAP_MARK_DEBUG="1" */;
wire [15 : 0]    vesa_debug_data/* synthesis PAP_MARK_DEBUG="1" */;
wire             eth0_rx_de  /* synthesis PAP_MARK_DEBUG="1" */;
wire             eth0_rx_vs  /* synthesis PAP_MARK_DEBUG="1" */;
//将图像封装为ip帧格式
vesa_debug 
#(
.PIX_WIGHT(16)
)
eth_vesa_debug(
.pix_clk  (pix_clk_in   ),//input wire    
.rstn     (rst_board    ),//input wire    
.vs       (vs_in        ),//input wire    
.de       (zoom_de_out  ),//input wire    
.vesa_data(vesa_debug_data) //output reg [15 : 0]   
);

eth_img_rec
//#(
//parameter integer PIXEL_WIDTH = 32                                   ,
//parameter integer VIDEO_LENGTH = 16'd960                             ,
//parameter integer VIDEO_HIGTH  = 16'd540                             
//)
eth0_img_rec(
.eth_rx_clk   (rgmii_clk_0  ),//input wire                         
.rstn         (rst_board    ),//input wire                         
.udp_date_rcev(rec_data     ),//input wire [31: 0]   
.udp_date_en  (rec_en       ),//input wire                         
.img_data_en  (eth0_rx_de  ),//output reg                         
.img_data_vs  (eth0_rx_vs  ),//output reg                         
.img_data     (eth0_rx_data) //output reg [15: 0]   
 );
  



eth_img_pkt eth0_img_pkt(    
    .rst_n              (rst_board       ), //input                    
    ////图像相关信号              
    .cam_pclk           (pix_clk_out      ), //input  图像时钟             
    .img_vsync          (video_enhance_vs_out           ), //input  帧同步               
    .img_data_en        (eth_zoom_de_out     ), //input  de               
    .img_data           ({eth_zoom_data_out[31 : 27],eth_zoom_data_out[21 : 16],eth_zoom_data_out[11 :  7]}), //input  [15:0]   //vesa_debug_data //eth0_img_data
    .transfer_flag      (1               ), //input                                        
    ////以太网相关信号
    .eth_tx_clk         (rgmii_clk_0     ), //input                          
    .udp_tx_req         (tx_req          ), //input                
    .udp_tx_done        (udp_tx_done     ), //input                
    .udp_tx_start_en    (tx_start_en     ), //output  reg          
    .udp_tx_data        (tx_data         ), //output       [31:0]  
    .udp_tx_byte_num    (tx_byte_num     )  //output  reg  [15:0]  
    ); 
//ETH0_GMII_RGMII
gmii_to_rgmii eth0_gmii_to_rgmii(
   .rgmii_clk             (rgmii_clk_0       ),    // output GMII时钟，供数据使用      
   .rst                   (rst_board         ),    // input        
    //mac输入的数据由gmii转化为rgmii，时钟为rgmii_clk
   .mac_tx_data_valid     (mac_tx_data_valid_0),    // input        
   .mac_tx_data           (mac_tx_data_0      ),    // input [7:0]  
    //eth输入的数据由rgmii转化为gmii，时钟为rgmii_clk
   .mac_rx_error          (mac_rx_error_0     ),    //output reg       
   .mac_rx_data_valid     (mac_rx_data_valid_0),    //output reg       
   .mac_rx_data           (mac_rx_data_0      ),    //output reg [7:0] 
   //eth接收                
   .rgmii_rxc             (eth_rgmii_rxc_0    ),    //input        
   .rgmii_rx_ctl          (eth_rgmii_rx_ctl_0 ),    //input        
   .rgmii_rxd             (eth_rgmii_rxd_0    ),    //input [3:0]  
   //eth发送                                    
   .rgmii_txc             (eth_rgmii_txc_0    ),    //output       
   .rgmii_tx_ctl          (eth_rgmii_tx_ctl_0 ),    //output       
   .rgmii_txd             (eth_rgmii_txd_0    )     //output [3:0] 
);

//UDP通信
udp_top                                             
   #(
    .BOARD_MAC     (BOARD_MAC),      //参数例化
    .BOARD_IP      (BOARD_IP ),
    .DES_MAC       (DES_MAC  ),
    .DES_IP        (DES_IP   )
    )
u_udp(
    .rst_n         (rst_board   ),  //input       复位信号，低电平有效            
    //GMII接口                                
    .gmii_rx_clk   (rgmii_clk_0         ),  //input       GMII接收数据时钟                    
    .gmii_rx_dv    (mac_rx_data_valid_0 ),  //input       GMII输入数据有效信号                
    .gmii_rxd      (mac_rx_data_0       ),  //input [7:0] GMII输入数据                              
    .gmii_tx_clk   (rgmii_clk_0         ),  //input       GMII发送数据时钟            
    .gmii_tx_en    (mac_tx_data_valid_0 ),  //output      GMII输出数据有效信号                  
    .gmii_txd      (mac_tx_data_0       ),  //output[7:0] GMII输出数据              
    //用户接口                                  
    .rec_pkt_done  (rec_pkt_done        ),  //output      以太网单包数据接收完成信号          
    .rec_en        (rec_en              ),  //output      以太网接收的数据使能信号            
    .rec_data      (rec_data            ),  //output[31:0]以太网接收的数据                    
    .rec_byte_num  (rec_byte_num        ),  //output[15:0]以太网接收的有效字节数 单位:byte  
    
    .tx_start_en   (tx_start_en         ),  //input       以太网开始发送信号                  
    .tx_data       (tx_data             ),  //input [31:0]以太网待发送数据                    
    .tx_byte_num   (tx_byte_num         ),  //input [15:0]以太网发送的有效字节数 单位:byte   
    .des_mac       (DES_MAC             ),  //input [47:0]发送的目标MAC地址            
    .des_ip        (DES_IP              ),  //input [31:0]发送的目标IP地址              
    .tx_done       (udp_tx_done         ),  //output      以太网发送完成信号                  
    .tx_req        (tx_req              )   //output      读数据请求信号                      
    ); 


endmodule

