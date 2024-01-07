module axi_m_arbitration #(
    parameter integer VIDEO_LENGTH      = 1920                            ,
    parameter integer VIDEO_HIGTH       = 1080                            ,
    parameter integer ZOOM_VIDEO_LENGTH = 960                             ,
    parameter integer ZOOM_VIDEO_HIGTH  = 540                             ,
    parameter integer PIXEL_WIDTH       = 32                              ,
	parameter integer CTRL_ADDR_WIDTH   = 28                              ,
	parameter integer DQ_WIDTH	       = 32                             ,
    parameter integer M_AXI_BRUST_LEN   = 8
)
(
	input wire                                    DDR_INIT_DONE           /* synthesis PAP_MARK_DEBUG="1" */,
	input wire                                    M_AXI_ACLK              /* synthesis PAP_MARK_DEBUG="1" */,
	input wire                                    M_AXI_ARESETN           /* synthesis PAP_MARK_DEBUG="1" */,
    input wire                                    pix_clk_out             ,
	//写地址通道↓                                                              
	output wire [3 : 0]                           M_AXI_AWID              ,
	output wire [CTRL_ADDR_WIDTH-1 : 0]           M_AXI_AWADDR            ,
//	output wire [3 : 0]                           M_AXI_AWLEN             ,
	output wire                                   M_AXI_AWUSER            ,
	output wire                                   M_AXI_AWVALID           ,
	input wire                                    M_AXI_AWREADY           ,
	//写数据通道↓                                                              
	output wire [DQ_WIDTH*8-1 : 0]                M_AXI_WDATA             ,
	output wire [DQ_WIDTH-1 : 0]                  M_AXI_WSTRB             ,
	input wire                                    M_AXI_WLAST             ,
	input wire  [3 : 0]                           M_AXI_WUSER             ,
	input wire                                    M_AXI_WREADY            ,
                                                             
	//读地址通道↓                                                              
	output wire [3 : 0]                           M_AXI_ARID              ,
    output wire                                   M_AXI_ARUSER            ,
	output wire [CTRL_ADDR_WIDTH-1 : 0]           M_AXI_ARADDR            ,
//	output wire [3 : 0]                           M_AXI_ARLEN             ,
	output wire                                   M_AXI_ARVALID           ,
	input wire                                    M_AXI_ARREADY           ,
	//读数据通道↓                                                              
	input wire  [3 : 0]                           M_AXI_RID               ,
	input wire  [DQ_WIDTH*8-1 : 0]                M_AXI_RDATA             ,
	input wire                                    M_AXI_RLAST             ,
	input wire                                    M_AXI_RVALID            ,
    //video
    input wire                                    vs_in                   /* synthesis PAP_MARK_DEBUG="1" */,
    input wire                                    vs_out                  /* synthesis PAP_MARK_DEBUG="1" */,
    //fifo0信号
    input wire                                    video0_clk_in             ,
    input wire                                    video0_de_in            /* synthesis PAP_MARK_DEBUG="1" */,
    input wire [31 : 0]                           video0_data_in          /* synthesis PAP_MARK_DEBUG="1" */,
    input wire                                    video0_rd_en            ,
    output wire [31 : 0]                          video0_data_out         /* synthesis PAP_MARK_DEBUG="1" */,
    output wire                                   fram0_done              ,
    input wire                                    video0_vs_in            ,
    //fifo1信号
    input wire                                    video1_clk_in             ,
    input wire                                    video1_de_in            /* synthesis PAP_MARK_DEBUG="1" */,
    input wire [31 : 0]                           video1_data_in          ,
    input wire                                    video1_rd_en            ,
    output wire [31 : 0]                          video1_data_out         /* synthesis PAP_MARK_DEBUG="1" */,
    output wire                                   fram1_done              ,
    input wire                                    video1_vs_in            ,
    //fifo2信号
    input wire                                    video2_clk_in             ,
    input wire                                    video2_de_in            /* synthesis PAP_MARK_DEBUG="1" */,
    input wire [31 : 0]                           video2_data_in          ,
    input wire                                    video2_rd_en            ,
    output wire [31 : 0]                          video2_data_out         /* synthesis PAP_MARK_DEBUG="1" */,
    output wire                                   fram2_done              ,
    input wire                                    video2_vs_in            ,
    //fifo3信号   
    input wire                                    video3_clk_in             ,
    input wire                                    video3_de_in            /* synthesis PAP_MARK_DEBUG="1" */,
    input wire [31 : 0]                           video3_data_in          ,
    input wire                                    video3_rd_en            ,
    output wire [31 : 0]                          video3_data_out         /* synthesis PAP_MARK_DEBUG="1" */, 
    output wire                                   fram3_done              ,
    input wire                                    video3_vs_in            ,
    //其他
    input       [19 : 0]                          wr_addr_min             ,//写数据ddr最小地址0地址开始算，1920*1080*16 = 33177600 bits
    input       [19 : 0]                          wr_addr_max             ,//写数据ddr最大地址，一个地址存32位 33177600/32 = 1036800 = 20'b1111_1101_0010_0000_0000
    input wire  [11 : 0]                          y_act                   ,
    input wire  [11 : 0]                          x_act                                   
   );
//********************************parameter**********************************//
parameter    VIDEO0_BASE_ADDR = 2'd0;
parameter    VIDEO1_BASE_ADDR = 2'd1;
parameter    VIDEO2_BASE_ADDR = 2'd2;
parameter    VIDEO3_BASE_ADDR = 2'd3;

//parameter    WRITE_ARBITRATION = 3'd0;
//parameter    M0_WRITE          = 4'b0001;
//parameter    M1_WRITE          = 4'b0010;
//parameter    M2_WRITE          = 4'b0100;
//parameter    M3_WRITE          = 4'b1000;
parameter    M0_WRITE = 2'd0;
parameter    M1_WRITE = 2'd1;
parameter    M2_WRITE = 2'd2;
parameter    M3_WRITE = 2'd3;
parameter    READ_ARBITRATION = 3'd0;
parameter    M0_READ          = 3'd1;
parameter    M1_READ          = 3'd2;
parameter    M2_READ          = 3'd3;
parameter    M3_READ          = 3'd4;
//********************************wire**********************************//
wire [255 : 0]                     M0_AXI_WDATA      /* synthesis PAP_MARK_DEBUG="1" */;
wire                               M0_AXI_AWVALID    /* synthesis PAP_MARK_DEBUG="1" */;
wire                               M0_AXI_AWREADY    /* synthesis PAP_MARK_DEBUG="1" */;
wire [CTRL_ADDR_WIDTH-1 : 0]       M0_AXI_AWADDR     /* synthesis PAP_MARK_DEBUG="1" */;
wire                               M0_AXI_WLAST      /* synthesis PAP_MARK_DEBUG="1" */;
wire                               M0_AXI_WREADY     /* synthesis PAP_MARK_DEBUG="1" */;
wire                               M0_AXI_ARVALID    /* synthesis PAP_MARK_DEBUG="1" */;
wire                               M0_AXI_ARREADY    /* synthesis PAP_MARK_DEBUG="1" */;
wire [CTRL_ADDR_WIDTH-1 : 0]       M0_AXI_ARADDR     /* synthesis PAP_MARK_DEBUG="1" */;
wire [255 : 0]                     M0_AXI_RDATA      /* synthesis PAP_MARK_DEBUG="1" */;
wire                               M0_AXI_RLAST      /* synthesis PAP_MARK_DEBUG="1" */;
wire                               M0_AXI_RVALID     /* synthesis PAP_MARK_DEBUG="1" */;

wire [255 : 0]                     M1_AXI_WDATA   /* synthesis PAP_MARK_DEBUG="1" */;
wire                               M1_AXI_AWVALID /* synthesis PAP_MARK_DEBUG="1" */;
wire                               M1_AXI_AWREADY /* synthesis PAP_MARK_DEBUG="1" */;
wire [CTRL_ADDR_WIDTH-1 : 0]       M1_AXI_AWADDR  /* synthesis PAP_MARK_DEBUG="1" */  ;
wire                               M1_AXI_WLAST   /* synthesis PAP_MARK_DEBUG="1" */ ;
wire                               M1_AXI_WREADY  /* synthesis PAP_MARK_DEBUG="1" */  ;
wire                               M1_AXI_ARVALID /* synthesis PAP_MARK_DEBUG="1" */   ;
wire                               M1_AXI_ARREADY /* synthesis PAP_MARK_DEBUG="1" */   ;
wire [CTRL_ADDR_WIDTH-1 : 0]       M1_AXI_ARADDR  /* synthesis PAP_MARK_DEBUG="1" */  ;
wire [255 : 0]                     M1_AXI_RDATA   /* synthesis PAP_MARK_DEBUG="1" */ ;
wire                               M1_AXI_RLAST   /* synthesis PAP_MARK_DEBUG="1" */   ;
wire                               M1_AXI_RVALID  /* synthesis PAP_MARK_DEBUG="1" */   ;

wire [255 : 0]                     M2_AXI_WDATA   /* synthesis PAP_MARK_DEBUG="1" */     ;
wire                               M2_AXI_AWVALID /* synthesis PAP_MARK_DEBUG="1" */   ;
wire                               M2_AXI_AWREADY /* synthesis PAP_MARK_DEBUG="1" */   ;
wire [CTRL_ADDR_WIDTH-1 : 0]       M2_AXI_AWADDR  /* synthesis PAP_MARK_DEBUG="1" */  ;
wire                               M2_AXI_WLAST   /* synthesis PAP_MARK_DEBUG="1" */ ;
wire                               M2_AXI_WREADY  /* synthesis PAP_MARK_DEBUG="1" */  ;
wire                               M2_AXI_ARVALID /* synthesis PAP_MARK_DEBUG="1" */   ;
wire                               M2_AXI_ARREADY /* synthesis PAP_MARK_DEBUG="1" */   ;
wire [CTRL_ADDR_WIDTH-1 : 0]       M2_AXI_ARADDR  /* synthesis PAP_MARK_DEBUG="1" */  ;
wire [255 : 0]                     M2_AXI_RDATA   /* synthesis PAP_MARK_DEBUG="1" */ ;
wire                               M2_AXI_RLAST   /* synthesis PAP_MARK_DEBUG="1" */   ;
wire                               M2_AXI_RVALID  /* synthesis PAP_MARK_DEBUG="1" */   ;
  
wire [255 : 0]                     M3_AXI_WDATA   /* synthesis PAP_MARK_DEBUG="1" */     ;
wire                               M3_AXI_AWVALID /* synthesis PAP_MARK_DEBUG="1" */       ;
wire                               M3_AXI_AWREADY /* synthesis PAP_MARK_DEBUG="1" */       ;
wire [CTRL_ADDR_WIDTH-1 : 0]       M3_AXI_AWADDR  /* synthesis PAP_MARK_DEBUG="1" */  ;
wire                               M3_AXI_WLAST   /* synthesis PAP_MARK_DEBUG="1" */ ;
wire                               M3_AXI_WREADY  /* synthesis PAP_MARK_DEBUG="1" */  ;
wire                               M3_AXI_ARVALID /* synthesis PAP_MARK_DEBUG="1" */   ;
wire                               M3_AXI_ARREADY /* synthesis PAP_MARK_DEBUG="1" */   ;
wire [CTRL_ADDR_WIDTH-1 : 0]       M3_AXI_ARADDR  /* synthesis PAP_MARK_DEBUG="1" */  ;
wire [255 : 0]                     M3_AXI_RDATA   /* synthesis PAP_MARK_DEBUG="1" */ ;
wire                               M3_AXI_RLAST   /* synthesis PAP_MARK_DEBUG="1" */   ;
wire                               M3_AXI_RVALID  /* synthesis PAP_MARK_DEBUG="1" */   ;    
     
wire                               rfifo0_wr_req        /* synthesis PAP_MARK_DEBUG="1" */;
wire [8 : 0]                       rfifo0_wr_water_level/* synthesis PAP_MARK_DEBUG="1" */;
wire                               rfifo1_wr_req        /* synthesis PAP_MARK_DEBUG="1" */;
wire [8 : 0]                       rfifo1_wr_water_level/* synthesis PAP_MARK_DEBUG="1" */;
wire                               rfifo2_wr_req        /* synthesis PAP_MARK_DEBUG="1" */;
wire [8 : 0]                       rfifo2_wr_water_level/* synthesis PAP_MARK_DEBUG="1" */; 
wire                               rfifo3_wr_req        /* synthesis PAP_MARK_DEBUG="1" */;
wire [8 : 0]                       rfifo3_wr_water_level/* synthesis PAP_MARK_DEBUG="1" */;

wire [8 : 0]                       wfifo0_rd_water_level/* synthesis PAP_MARK_DEBUG="1" */;
wire [8 : 0]                       wfifo1_rd_water_level/* synthesis PAP_MARK_DEBUG="1" */;
wire [8 : 0]                       wfifo2_rd_water_level/* synthesis PAP_MARK_DEBUG="1" */;
wire [8 : 0]                       wfifo3_rd_water_level/* synthesis PAP_MARK_DEBUG="1" */;
wire                               wfifo0_rd_req    /* synthesis PAP_MARK_DEBUG="1" */;
wire                               wfifo0_pre_rd_req/* synthesis PAP_MARK_DEBUG="1" */;
wire                               wfifo1_rd_req    /* synthesis PAP_MARK_DEBUG="1" */;
wire                               wfifo1_pre_rd_req/* synthesis PAP_MARK_DEBUG="1" */;
wire                               wfifo2_rd_req    /* synthesis PAP_MARK_DEBUG="1" */;
wire                               wfifo2_pre_rd_req/* synthesis PAP_MARK_DEBUG="1" */;
wire                               wfifo3_rd_req    /* synthesis PAP_MARK_DEBUG="1" */;
wire                               wfifo3_pre_rd_req/* synthesis PAP_MARK_DEBUG="1" */;
wire [1 : 0]                       wfifo0_state/* synthesis PAP_MARK_DEBUG="1" */;  
wire [1 : 0]                       wfifo1_state/* synthesis PAP_MARK_DEBUG="1" */;  
wire [1 : 0]                       wfifo2_state/* synthesis PAP_MARK_DEBUG="1" */;  
wire [1 : 0]                       wfifo3_state/* synthesis PAP_MARK_DEBUG="1" */;  
wire [1 : 0]                       rfifo0_state/* synthesis PAP_MARK_DEBUG="1" */;  
wire [1 : 0]                       rfifo1_state/* synthesis PAP_MARK_DEBUG="1" */;  
wire [1 : 0]                       rfifo2_state/* synthesis PAP_MARK_DEBUG="1" */;  
wire [1 : 0]                       rfifo3_state/* synthesis PAP_MARK_DEBUG="1" */;  
wire                               wr_rst           /* synthesis PAP_MARK_DEBUG="1" */;
wire                               rd_rst           /* synthesis PAP_MARK_DEBUG="1" */;
wire [19 : 0]                      wr_addr_cnt0    /* synthesis PAP_MARK_DEBUG="1" */;
wire [19 : 0]                      wr_addr_cnt1    /* synthesis PAP_MARK_DEBUG="1" */;
wire [19 : 0]                      wr_addr_cnt2    /* synthesis PAP_MARK_DEBUG="1" */;
wire [19 : 0]                      wr_addr_cnt3    /* synthesis PAP_MARK_DEBUG="1" */;
//********************************reg**********************************//
reg [4 : 0]                           arbitration_wr_state/* synthesis PAP_MARK_DEBUG="1" */;
reg [2 : 0]                           arbitration_rd_state/* synthesis PAP_MARK_DEBUG="1" */;
reg                                   rfifo_pre_write_init/* synthesis PAP_MARK_DEBUG="1" */;
reg [11 : 0]                          r_y_act_d0/* synthesis PAP_MARK_DEBUG="1" */;    
reg [11 : 0]                          r_x_act_d0/* synthesis PAP_MARK_DEBUG="1" */;    
reg                                   r_video0_rd_en_d0/* synthesis PAP_MARK_DEBUG="1" */;
reg                                   r_video1_rd_en_d0/* synthesis PAP_MARK_DEBUG="1" */;
reg                                   r_video2_rd_en_d0/* synthesis PAP_MARK_DEBUG="1" */;
reg                                   r_video3_rd_en_d0/* synthesis PAP_MARK_DEBUG="1" */;
//********************************assign**********************************//
//固定输出的接口，各主机不需要单独再输出
assign M_AXI_AWID       =   4'b0;
assign M_AXI_AWUSER     =   1'b0;
assign M_AXI_WSTRB	     =   {(DQ_WIDTH){1'b1}};//闪光灯信号，数据位宽/4 4位都为1
assign M_AXI_ARID       =   4'b0;//与写地址类似
assign M_AXI_ARUSER     =   1'b0;
//仲裁器输出主机的控制信号
assign M_AXI_AWVALID = (arbitration_wr_state == M0_WRITE)?M0_AXI_AWVALID:((arbitration_wr_state == M1_WRITE)?M1_AXI_AWVALID : ((arbitration_wr_state == M2_WRITE)?M2_AXI_AWVALID : (arbitration_wr_state == M3_WRITE)?M3_AXI_AWVALID : 'd0));//r_M_AXI_AWVALID; //仲裁器输出awvalid
assign M_AXI_AWADDR  = (arbitration_wr_state == M0_WRITE)?M0_AXI_AWADDR:((arbitration_wr_state == M1_WRITE)?M1_AXI_AWADDR : ((arbitration_wr_state == M2_WRITE)?M2_AXI_AWADDR : (arbitration_wr_state == M3_WRITE)?M3_AXI_AWADDR : 'd0));  //仲裁器输出awaddr
assign M_AXI_ARVALID = (arbitration_rd_state == M0_READ)?M0_AXI_ARVALID:((arbitration_rd_state == M1_READ)?M1_AXI_ARVALID : ((arbitration_rd_state == M2_READ)?M2_AXI_ARVALID : (arbitration_rd_state == M3_READ)?M3_AXI_ARVALID : 'd0));
assign M_AXI_ARADDR  = (arbitration_rd_state == M0_READ)?M0_AXI_ARADDR:((arbitration_rd_state == M1_READ)?M1_AXI_ARADDR : ((arbitration_rd_state == M2_READ)?M2_AXI_ARADDR : (arbitration_rd_state == M3_READ)?M3_AXI_ARADDR : 'd0)); 
//仲裁器将从机发出的信号转发给主机0
assign M0_AXI_AWREADY = (arbitration_wr_state == M0_WRITE)?M_AXI_AWREADY : 'd0 ;  //r_M0_AXI_AWREADY;由于多一个always块会导致信号慢一拍，对于从机来不行
assign M0_AXI_WLAST   = (arbitration_wr_state == M0_WRITE)?M_AXI_WLAST   : 'd0 ;  //r_M0_AXI_WLAST  ;由于多一个always块会导致信号慢一拍，对于从机来不行
assign M0_AXI_WREADY  = (arbitration_wr_state == M0_WRITE)?M_AXI_WREADY  : 'd0 ;  //r_M0_AXI_WREADY ;由于多一个always块会导致信号慢一拍，对于从机来不行
assign M0_AXI_ARREADY = (arbitration_rd_state == M0_READ )?M_AXI_ARREADY : 'd0;//r_M0_AXI_ARREADY;由于多一个always块会导致信号慢一拍，对于从机来不行
assign M0_AXI_RLAST   = (arbitration_rd_state == M0_READ )?M_AXI_RLAST   : 'd0;//r_M0_AXI_RLAST  ;由于多一个always块会导致信号慢一拍，对于从机来不行
assign M0_AXI_RVALID  = (arbitration_rd_state == M0_READ )?M_AXI_RVALID  : 'd0;//r_M0_AXI_RVALID ;由于多一个always块会导致信号慢一拍，对于从机来不行
//仲裁器将从机发出的信号转发给主机1
assign M1_AXI_AWREADY = (arbitration_wr_state == M1_WRITE)?M_AXI_AWREADY : 'd0 ;  //r_M1_AXI_AWREADY;
assign M1_AXI_WLAST   = (arbitration_wr_state == M1_WRITE)?M_AXI_WLAST   : 'd0 ;  //r_M1_AXI_WLAST;
assign M1_AXI_WREADY  = (arbitration_wr_state == M1_WRITE)?M_AXI_WREADY  : 'd0 ;  //r_M1_AXI_WREADY;
assign M1_AXI_ARREADY = (arbitration_rd_state == M1_READ )?M_AXI_ARREADY : 'd0;// r_M1_AXI_ARREADY;
assign M1_AXI_RLAST   = (arbitration_rd_state == M1_READ )?M_AXI_RLAST   : 'd0;// r_M1_AXI_RLAST  ;
assign M1_AXI_RVALID  = (arbitration_rd_state == M1_READ )?M_AXI_RVALID  : 'd0;// r_M1_AXI_RVALID ;
//仲裁器将从机发出的信号转发给主机2
assign M2_AXI_AWREADY = (arbitration_wr_state == M2_WRITE)?M_AXI_AWREADY : 'd0 ;  //r_M2_AXI_AWREADY;
assign M2_AXI_WLAST   = (arbitration_wr_state == M2_WRITE)?M_AXI_WLAST   : 'd0 ;  //r_M2_AXI_WLAST;
assign M2_AXI_WREADY  = (arbitration_wr_state == M2_WRITE)?M_AXI_WREADY  : 'd0 ;  //r_M2_AXI_WREADY;
assign M2_AXI_ARREADY = (arbitration_rd_state == M2_READ )?M_AXI_ARREADY : 'd0;// r_M2_AXI_ARREADY;
assign M2_AXI_RLAST   = (arbitration_rd_state == M2_READ )?M_AXI_RLAST   : 'd0;// r_M2_AXI_RLAST  ;
assign M2_AXI_RVALID  = (arbitration_rd_state == M2_READ )?M_AXI_RVALID  : 'd0;// r_M2_AXI_RVALID ;
//仲裁器将从机发出的信号转发给主机3
assign M3_AXI_AWREADY = (arbitration_wr_state == M3_WRITE)?M_AXI_AWREADY : 'd0 ;  //r_M3_AXI_AWREADY;
assign M3_AXI_WLAST   = (arbitration_wr_state == M3_WRITE)?M_AXI_WLAST   : 'd0 ;  //r_M3_AXI_WLAST;
assign M3_AXI_WREADY  = (arbitration_wr_state == M3_WRITE)?M_AXI_WREADY  : 'd0 ;  //r_M3_AXI_WREADY;
assign M3_AXI_ARREADY = (arbitration_rd_state == M3_READ )?M_AXI_ARREADY : 'd0;//r_M3_AXI_ARREADY;
assign M3_AXI_RLAST   = (arbitration_rd_state == M3_READ )?M_AXI_RLAST   : 'd0;//r_M3_AXI_RLAST  ;
assign M3_AXI_RVALID  = (arbitration_rd_state == M3_READ )?M_AXI_RVALID  : 'd0;//r_M3_AXI_RVALID ;
//数据输出
assign M_AXI_WDATA    = (arbitration_wr_state == M0_WRITE)?M0_AXI_WDATA:((arbitration_wr_state == M1_WRITE)?M1_AXI_WDATA : ((arbitration_wr_state == M2_WRITE)?M2_AXI_WDATA : (arbitration_wr_state == M3_WRITE)?M3_AXI_WDATA : 'd0));//写FIFO输出数据给DDR
//数据输入
assign M0_AXI_RDATA   = (arbitration_rd_state == M0_READ )?M_AXI_RDATA : 'd0;
assign M1_AXI_RDATA   = (arbitration_rd_state == M1_READ )?M_AXI_RDATA : 'd0;
assign M2_AXI_RDATA   = (arbitration_rd_state == M2_READ )?M_AXI_RDATA : 'd0;
assign M3_AXI_RDATA   = (arbitration_rd_state == M3_READ )?M_AXI_RDATA : 'd0;
//********************************always**********************************//
//对AXI主机和FIFO进行复位
always @(posedge M_AXI_ACLK ) begin
    if(!M_AXI_ARESETN) begin
        r_video0_rd_en_d0 <= 'd0;
        r_video1_rd_en_d0 <= 'd0;
        r_video2_rd_en_d0 <= 'd0;
        r_video3_rd_en_d0 <= 'd0;
        r_y_act_d0        <= 'd0; 
        r_x_act_d0        <= 'd0; 
    end
    else begin
        r_video0_rd_en_d0 <= video0_rd_en;
        r_video1_rd_en_d0 <= video1_rd_en;
        r_video2_rd_en_d0 <= video2_rd_en;
        r_video3_rd_en_d0 <= video3_rd_en;
        r_y_act_d0        <= y_act; 
        r_x_act_d0        <= x_act; 
    end
end
//********************************状态机**********************************//
//写状态机，依次写数据
always @(posedge M_AXI_ACLK ) begin
    if(!M_AXI_ARESETN ) begin
        arbitration_wr_state  <= 'd0;
    end
    else if(DDR_INIT_DONE)begin
        case(arbitration_wr_state)
            M0_WRITE:
            begin
                if(M0_AXI_WLAST) begin//第一次传输完成，对第二个主机进行传输
                    arbitration_wr_state <= M1_WRITE;
                end
                else if( (!(wfifo0_state == 'd3)) && (wfifo0_rd_water_level < M_AXI_BRUST_LEN) && (wr_addr_cnt0 < wr_addr_max - M_AXI_BRUST_LEN * 8 )) begin
                    arbitration_wr_state <= M1_WRITE;
                end       
            end
            M1_WRITE:
            begin
                if(M1_AXI_WLAST) begin
                    arbitration_wr_state <= M2_WRITE;
                end  
                else if( (!(wfifo1_state == 'd3)) && (wfifo1_rd_water_level < M_AXI_BRUST_LEN)&& (wr_addr_cnt1 < wr_addr_max - M_AXI_BRUST_LEN * 8 )) begin
                    arbitration_wr_state <= M2_WRITE;
                end  
            end
            M2_WRITE:
            begin
                if(M2_AXI_WLAST) begin
                    arbitration_wr_state <= M3_WRITE;
                end  
                else if((!(wfifo2_state == 'd3)) && (wfifo2_rd_water_level < M_AXI_BRUST_LEN)&& (wr_addr_cnt2 < wr_addr_max - M_AXI_BRUST_LEN * 8 )) begin
                    arbitration_wr_state <= M3_WRITE;
                end                    
            end
            M3_WRITE:
            begin
                if(M3_AXI_WLAST) begin
                    arbitration_wr_state <= M0_WRITE;
                end  
                else if((!(wfifo3_state == 'd3)) && (wfifo3_rd_water_level < M_AXI_BRUST_LEN)&& (wr_addr_cnt3 < wr_addr_max - M_AXI_BRUST_LEN * 8 )) begin
                    arbitration_wr_state <= M0_WRITE;
                end                        
            end
        endcase
    end
    else begin
        arbitration_wr_state <= arbitration_wr_state; 
    end
end
//读状态机，依次读
always @(posedge M_AXI_ACLK ) begin
    if(!M_AXI_ARESETN || rd_rst) begin
        arbitration_rd_state  <= READ_ARBITRATION;
        rfifo_pre_write_init <= 3'd0;//rfifo预写入标志，一帧开始时向四个主机轮流向rfifo预写入一行数据
    end
    else if(DDR_INIT_DONE)begin
        case(arbitration_rd_state)
            READ_ARBITRATION:
            begin
                if(!rfifo_pre_write_init) begin
                    if(rfifo0_wr_water_level < ZOOM_VIDEO_LENGTH*PIXEL_WIDTH/256*2 ) begin//rfifo0预写完一行后切换到下一个rfifo
                        arbitration_rd_state <= M0_READ;
                    end
                    else if(rfifo1_wr_water_level < ZOOM_VIDEO_LENGTH*PIXEL_WIDTH/256*2 ) begin
                        arbitration_rd_state <= M1_READ;
                    end
                    else if(rfifo2_wr_water_level < ZOOM_VIDEO_LENGTH*PIXEL_WIDTH/256*2 ) begin
                        arbitration_rd_state <= M2_READ;
                    end
                    else if(rfifo3_wr_water_level < ZOOM_VIDEO_LENGTH*PIXEL_WIDTH/256*2 ) begin
                        arbitration_rd_state <= M3_READ;
                    end
                    else begin
                        rfifo_pre_write_init <= 1'd1;//四个rfifo都写完后标志置1，在不同区域对rfifo进行写入
                    end
                end
                else if(r_video0_rd_en_d0 || r_video1_rd_en_d0) begin
                    arbitration_rd_state <= M0_READ;
                end  
                //else if(r_video1_rd_en_d0) begin
                //    arbitration_rd_state <= M1_READ;
                //end  
                else if(r_video2_rd_en_d0 || r_video3_rd_en_d0) begin
                    arbitration_rd_state <= M2_READ;
                end  
                //else if(r_video3_rd_en_d0) begin
                //    arbitration_rd_state <= M3_READ;
                //end  
                else begin
                    arbitration_rd_state <= arbitration_rd_state;
                end                                     
            end
            M0_READ:
            begin
                if(fram0_done) begin
                   //if(M0_AXI_RLAST) begin//第一次传输完成，对第二个主机进行传输
                   //    arbitration_rd_state <= READ_ARBITRATION;
                   //end  
                    if((rfifo0_wr_water_level >= 'd120) && (rfifo0_state == 1)) begin
                        arbitration_rd_state <= M1_READ;    
                    end
                    else begin
                        arbitration_rd_state <= arbitration_rd_state;
                    end                    
                end
                else begin
                    arbitration_rd_state <= READ_ARBITRATION;
                end      
            end
            M1_READ:
            begin
                if(fram1_done) begin
                    //if(M1_AXI_RLAST) begin//第一次传输完成，对第二个主机进行传输
                    //    arbitration_rd_state <= READ_ARBITRATION;
                    //end  
                    if((rfifo1_wr_water_level  >= 'd120)&& (rfifo1_state == 1)) begin
                        arbitration_rd_state <= READ_ARBITRATION;    
                    end
                    else begin
                        arbitration_rd_state <= arbitration_rd_state;
                    end
                end
                else begin
                    arbitration_rd_state <= READ_ARBITRATION;
                end  
            end
            M2_READ:
            begin
                if(fram2_done) begin
                    //if(M2_AXI_RLAST) begin//第一次传输完成，对第二个主机进行传输
                    //    arbitration_rd_state <= READ_ARBITRATION;
                    //end  
                    if((rfifo2_wr_water_level  >= 'd120)&& (rfifo2_state == 1)) begin
                        arbitration_rd_state <= M3_READ;    
                    end
                    else begin
                        arbitration_rd_state <= arbitration_rd_state;
                    end
                end
                else begin
                    arbitration_rd_state <= READ_ARBITRATION;
                end                 
            end
            M3_READ:
            begin
                if(fram3_done) begin
                    //if(M3_AXI_RLAST) begin//第一次传输完成，对第二个主机进行传输
                    //    arbitration_rd_state <= READ_ARBITRATION;
                    //end  
                    if( (rfifo3_wr_water_level  >= 'd120 )&& (rfifo3_state == 1)) begin
                        arbitration_rd_state <= READ_ARBITRATION;    
                    end
                    else begin
                        arbitration_rd_state <= arbitration_rd_state;
                    end
                end
                else begin
                    arbitration_rd_state <= READ_ARBITRATION;
                end                
            end
            default : 
                arbitration_rd_state <= READ_ARBITRATION;
        endcase
    end
    else begin
        arbitration_rd_state  <= READ_ARBITRATION;
    end
end

//********************************例化**********************************//
//例化AXI_FULL_M
//AXI主机0
AXI_FULL_M #(
        .VIDEO_LENGTH     (ZOOM_VIDEO_LENGTH)    ,
        .VIDEO_HIGTH      (ZOOM_VIDEO_HIGTH )    ,
        .PIXEL_WIDTH      (PIXEL_WIDTH      )    ,
        .CTRL_ADDR_WIDTH  (CTRL_ADDR_WIDTH  )    ,
        .DQ_WIDTH	      (DQ_WIDTH         )    ,
        .M_AXI_BRUST_LEN  (M_AXI_BRUST_LEN  )    ,
        .VIDEO_BASE_ADDR  (VIDEO0_BASE_ADDR )     
)
u_axi_full_m0
    (
		.DDR_INIT_DONE       (DDR_INIT_DONE  )                 ,//input wire  
		.M_AXI_ACLK          (M_AXI_ACLK     )                 ,//input wire  
		.M_AXI_ARESETN       (M_AXI_ARESETN)     ,//input wire  
		//写地址通道↓                                               
		.M_AXI_AWADDR        (M0_AXI_AWADDR   )     ,           //output wire 
		.M_AXI_AWVALID       (M0_AXI_AWVALID  )     ,           //output wire 
		.M_AXI_AWREADY       (M0_AXI_AWREADY  )     ,           //input wire 
		//写数据通道↓                                            //写数据通道↓           
        .M_AXI_WLAST         (M0_AXI_WLAST    )     ,           //input wire   
        .M_AXI_WREADY        (M0_AXI_WREADY   )     ,           //input wire 
		//写响应通道↓                                             //写响应通道↓  
		//读地址通道↓                                             //读地址通道↓    
		.M_AXI_ARADDR        (M0_AXI_ARADDR   )     ,          //output wire   
		.M_AXI_ARVALID       (M0_AXI_ARVALID  )     ,          //output wire   
		.M_AXI_ARREADY       (M0_AXI_ARREADY  )     ,          //input wire   
		//读数据通道↓                                            //读数据通道↓     
		.M_AXI_RLAST         (M0_AXI_RLAST    )     ,          //input wire 
		.M_AXI_RVALID        (M0_AXI_RVALID   )     ,          //input wire 
        //video                                                ////video      
        .vs_in               (video0_vs_in        )      ,          //input wire  
        .vs_out              (vs_out         )      ,          //input wire   
        //fifo                                                 ////fifo信号     
        .wfifo_rd_water_level(wfifo0_rd_water_level) ,         //input wire   
        .wfifo_rd_req        (wfifo0_rd_req        )      ,    //output       
        .wfifo_pre_rd_req    (wfifo0_pre_rd_req    ) ,         //output       
        .rfifo_wr_water_level(rfifo0_wr_water_level) ,         //input wire   
        .rfifo_wr_req        (rfifo0_wr_req   )      ,         // output       
        .r_fram_done         (fram0_done      )      ,         // output reg   
         //其他
        .wr_addr_min         (wr_addr_min     )      ,          // input         
        .wr_addr_max         (wr_addr_max     )      ,          // input  
        .r_wr_rst            (wr_rst          )      ,
        .r_rd_rst            (rd_rst          )      ,
        .w_fifo_state        (wfifo0_state    )      ,
        .r_fifo_state        (rfifo0_state    )      ,
        .wr_addr_cnt         (wr_addr_cnt0    )
	);                                                               
//AXI主机1                                                         
AXI_FULL_M #(                                                    
        .VIDEO_LENGTH     (ZOOM_VIDEO_LENGTH)    ,               
        .VIDEO_HIGTH      (ZOOM_VIDEO_HIGTH )    ,               
        .PIXEL_WIDTH      (PIXEL_WIDTH      )    ,
        .CTRL_ADDR_WIDTH  (CTRL_ADDR_WIDTH  )    ,
        .DQ_WIDTH	      (DQ_WIDTH         )    ,
        .M_AXI_BRUST_LEN  (M_AXI_BRUST_LEN  )    ,
        .VIDEO_BASE_ADDR  (VIDEO1_BASE_ADDR )    
)
u_axi_full_m1
    (
		.DDR_INIT_DONE       (DDR_INIT_DONE  )                 ,
		.M_AXI_ACLK          (M_AXI_ACLK     )                 ,
		.M_AXI_ARESETN       (M_AXI_ARESETN)     ,
		//写地址通道↓                                   
		.M_AXI_AWADDR        (M1_AXI_AWADDR   )     ,
		.M_AXI_AWVALID       (M1_AXI_AWVALID  )     ,
		.M_AXI_AWREADY       (M1_AXI_AWREADY  )     ,
		//写数据通道↓                                   
		.M_AXI_WLAST         (M1_AXI_WLAST    )     ,
		.M_AXI_WREADY        (M1_AXI_WREADY   )     ,
		//写响应通道↓                                   
		//读地址通道↓                                   
		.M_AXI_ARADDR        (M1_AXI_ARADDR   )     ,
		.M_AXI_ARVALID       (M1_AXI_ARVALID  )     ,
		.M_AXI_ARREADY       (M1_AXI_ARREADY  )     ,
		//读数据通道↓                                   
		.M_AXI_RLAST         (M1_AXI_RLAST    )     ,
		.M_AXI_RVALID        (M1_AXI_RVALID   )     ,
        //video
        .vs_in                (video1_vs_in          )     ,
        .vs_out               (vs_out         )     ,
        //fifo
        .wfifo_rd_water_level(wfifo1_rd_water_level),
        .wfifo_rd_req        (wfifo1_rd_req   )     ,
        .wfifo_pre_rd_req    (wfifo1_pre_rd_req    ),
        .rfifo_wr_water_level(rfifo1_wr_water_level),
        .rfifo_wr_req        (rfifo1_wr_req   )     ,
        .r_fram_done         (fram1_done      )     ,
        .wr_addr_min         (wr_addr_min     )     ,
        .wr_addr_max         (wr_addr_max     )     ,
        .r_wr_rst            (                )     ,
        .r_rd_rst            (                )     ,
        .w_fifo_state        (wfifo1_state)                      ,
        .r_fifo_state        (rfifo1_state)        ,
        .wr_addr_cnt       (wr_addr_cnt1    )
	);
//AXI主机2 
AXI_FULL_M #(
        .VIDEO_LENGTH     (ZOOM_VIDEO_LENGTH)    ,
        .VIDEO_HIGTH      (ZOOM_VIDEO_HIGTH )    ,
        .PIXEL_WIDTH      (PIXEL_WIDTH      )    ,
        .CTRL_ADDR_WIDTH  (CTRL_ADDR_WIDTH  )    ,
        .DQ_WIDTH	      (DQ_WIDTH         )    ,
        .M_AXI_BRUST_LEN  (M_AXI_BRUST_LEN  )    ,
        .VIDEO_BASE_ADDR  (VIDEO2_BASE_ADDR )    
)
u_axi_full_m2
    (
		.DDR_INIT_DONE       (DDR_INIT_DONE  )                 ,
		.M_AXI_ACLK          (M_AXI_ACLK     )                 ,
		.M_AXI_ARESETN       (M_AXI_ARESETN)     ,
		//写地址通道↓                                   
		.M_AXI_AWADDR        (M2_AXI_AWADDR   )     ,
		.M_AXI_AWVALID       (M2_AXI_AWVALID  )     ,
		.M_AXI_AWREADY       (M2_AXI_AWREADY  )     ,
		//写数据通道↓                                   
		.M_AXI_WLAST         (M2_AXI_WLAST    )     ,
		.M_AXI_WREADY        (M2_AXI_WREADY   )     ,
		//写响应通道↓                                   
		//读地址通道↓                                   
		.M_AXI_ARADDR        (M2_AXI_ARADDR   )     ,
		.M_AXI_ARVALID       (M2_AXI_ARVALID  )     ,
		.M_AXI_ARREADY       (M2_AXI_ARREADY  )     ,
		//读数据通道↓                                   
		.M_AXI_RLAST         (M2_AXI_RLAST    )     ,
		.M_AXI_RVALID        (M2_AXI_RVALID   )     ,
        //video
        .vs_in                (video2_vs_in          )     ,
        .vs_out               (vs_out         )     ,
        //fifo
        .wfifo_rd_water_level(wfifo2_rd_water_level),
        .wfifo_rd_req        (wfifo2_rd_req   )     ,
        .wfifo_pre_rd_req    (wfifo2_pre_rd_req    ),
        .rfifo_wr_water_level(rfifo2_wr_water_level),
        .rfifo_wr_req        (rfifo2_wr_req   )     ,
        .r_fram_done         (fram2_done      )     ,
        .wr_addr_min         (wr_addr_min    )      ,
        .wr_addr_max         (wr_addr_max    )      ,
        .r_wr_rst            (                )     ,
        .r_rd_rst            (                )     ,
        .w_fifo_state        (wfifo2_state)                     ,
        .r_fifo_state        (rfifo2_state)        ,
        .wr_addr_cnt       (wr_addr_cnt2    )
	);
//AXI主机3
AXI_FULL_M #(
        .VIDEO_LENGTH     (ZOOM_VIDEO_LENGTH)    ,
        .VIDEO_HIGTH      (ZOOM_VIDEO_HIGTH )    ,
        .PIXEL_WIDTH      (PIXEL_WIDTH      )    ,
        .CTRL_ADDR_WIDTH  (CTRL_ADDR_WIDTH  )    ,
        .DQ_WIDTH	       (DQ_WIDTH         )    ,
        .M_AXI_BRUST_LEN  (M_AXI_BRUST_LEN  )    ,
        .VIDEO_BASE_ADDR  (VIDEO3_BASE_ADDR )    
)
u_axi_full_m3
    (
		.DDR_INIT_DONE       (DDR_INIT_DONE  )                 ,
		.M_AXI_ACLK          (M_AXI_ACLK     )                 ,
		.M_AXI_ARESETN       (M_AXI_ARESETN)     ,
		//写地址通道↓                                   
		.M_AXI_AWADDR        (M3_AXI_AWADDR   )     ,
		.M_AXI_AWVALID       (M3_AXI_AWVALID  )     ,
		.M_AXI_AWREADY       (M3_AXI_AWREADY  )     ,
		//写数据通道↓                                   
		.M_AXI_WLAST         (M3_AXI_WLAST    )     ,
		.M_AXI_WREADY        (M3_AXI_WREADY   )     ,
		//写响应通道↓                                   
		//读地址通道↓                                   
		.M_AXI_ARADDR        (M3_AXI_ARADDR   )     ,
		.M_AXI_ARVALID       (M3_AXI_ARVALID  )     ,
		.M_AXI_ARREADY       (M3_AXI_ARREADY  )     ,
		//读数据通道↓                                   
		.M_AXI_RLAST         (M3_AXI_RLAST    )     ,
		.M_AXI_RVALID        (M3_AXI_RVALID   )     ,
        //video
        .vs_in                (video3_vs_in          )     ,
        .vs_out               (vs_out         )     ,
        //fifo
        .wfifo_rd_water_level(wfifo3_rd_water_level),
        .wfifo_rd_req        (wfifo3_rd_req   )     ,
        .wfifo_pre_rd_req    (wfifo3_pre_rd_req   ),
        .rfifo_wr_water_level(rfifo3_wr_water_level),
        .rfifo_wr_req        (rfifo3_wr_req   )     ,
        .r_fram_done         (fram3_done      )     ,
        .wr_addr_min         (wr_addr_min     )     ,
        .wr_addr_max         (wr_addr_max     )     ,
        .r_wr_rst            (                )     ,
        .r_rd_rst            (                )     ,
        .w_fifo_state        (wfifo3_state)                     ,
        .r_fifo_state        (rfifo3_state)        ,
        .wr_addr_cnt       (wr_addr_cnt3    )
	);


//第0组FIFO
rw_fifo_ctrl user_rw_fifo_ctrl0(
        .rstn                   (M_AXI_ARESETN),//系统复位,DDR未初始化完成时保持复位状态
        .ddr_clk                (M_AXI_ACLK          ),//写入内存的时钟（内存axi4接口时钟）
         //hdmi_wfifo_ddr                             
        .wfifo_wr_clk           (video0_clk_in          ),//wfifo写时钟
        .wfifo_wr_en            (video0_de_in         ),//wfifo输入使能
        .wfifo_wr_data32_in     (video0_data_in       ),//wfifo输入数据,32bits
        .wfifo_rd_req           (wfifo0_rd_req || wfifo0_pre_rd_req),//wfifo读请求，当数量大于突发长度时拉高
        .wfifo_rd_water_level   (wfifo0_rd_water_level),//wfifo读水位，当数量大于突发长度时开始传输
        .wfifo_rd_data256_out   (M0_AXI_WDATA        ),//wfifo读数据，256bits      
        //ddr_rfifo_hdmi
        .rfifo_rd_clk           (pix_clk_out)          ,//rfifo读时钟
        .rfifo_rd_en            (video0_rd_en   )         ,//rfifo读出使能
        .rfifo_rd_data32_out    (video0_data_out)      ,//rfifo输入数据,32bits
        .rfifo_wr_req           (rfifo0_wr_req)        ,//rfifo写请求，当数量大于突发长度时拉高
        .rfifo_wr_water_level   (rfifo0_wr_water_level),//rfifo写水位，当数量小于一行数据时开始传输
        .rfifo_wr_data256_in    (M0_AXI_RDATA)         ,//rfifo写数据，256bits    
        .vs_in                  (video0_vs_in          )      ,
        .vs_out                 (vs_out         )                              
   );

//第1组FIFO
rw_fifo_ctrl user_rw_fifo_ctrl1(
        .rstn                   (M_AXI_ARESETN),//系统复位,DDR未初始化完成时保持复位状态
        .ddr_clk                (M_AXI_ACLK          ),//写入内存的时钟（内存axi4接口时钟）
         //hdmi_wfifo_ddr                             
        .wfifo_wr_clk           (video1_clk_in          ),//wfifo写时钟
        .wfifo_wr_en            (video1_de_in         ),//wfifo输入使能
        .wfifo_wr_data32_in     (video1_data_in       ),//wfifo输入数据,32bits
        .wfifo_rd_req           (wfifo1_rd_req || wfifo1_pre_rd_req),//wfifo读请求，当数量大于突发长度时拉高
        .wfifo_rd_water_level   (wfifo1_rd_water_level),//wfifo读水位，当数量大于突发长度时开始传输
        .wfifo_rd_data256_out   (M1_AXI_WDATA         ),//wfifo读数据，256bits      
        //ddr_rfifo_hdmi
        .rfifo_rd_clk           (pix_clk_out)          ,//rfifo读时钟
        .rfifo_rd_en            (video1_rd_en)         ,//rfifo读出使能
        .rfifo_rd_data32_out    (video1_data_out)      ,//rfifo输入数据,16bits
        .rfifo_wr_req           (rfifo1_wr_req)        ,//rfifo写请求，当数量大于突发长度时拉高
        .rfifo_wr_water_level   (rfifo1_wr_water_level),//rfifo写水位，当数量小于突发长度时开始传输
        .rfifo_wr_data256_in    (M1_AXI_RDATA)         ,   //rfifo写数据，256bits    
        .vs_in                  (video1_vs_in          )     ,
        .vs_out                 (vs_out         )                              
   );

//第2组FIFO
rw_fifo_ctrl user_rw_fifo_ctrl2(
        .rstn                   (M_AXI_ARESETN),//系统复位,DDR未初始化完成时保持复位状态
        .ddr_clk                (M_AXI_ACLK          ),//写入内存的时钟（内存axi4接口时钟）
         //hdmi_wfifo_ddr                             
        .wfifo_wr_clk           (video2_clk_in          ),//wfifo写时钟
        .wfifo_wr_en            (video2_de_in         ),//wfifo输入使能
        .wfifo_wr_data32_in     (video2_data_in       ),//wfifo输入数据,32bits
        .wfifo_rd_req           (wfifo2_rd_req || wfifo2_pre_rd_req),//wfifo读请求，当数量大于突发长度时拉高
        .wfifo_rd_water_level   (wfifo2_rd_water_level),//wfifo读水位，当数量大于突发长度时开始传输
        .wfifo_rd_data256_out   (M2_AXI_WDATA         ),//wfifo读数据，256bits      
        //ddr_rfifo_hdmi
        .rfifo_rd_clk           (pix_clk_out)          ,//rfifo读时钟
        .rfifo_rd_en            (video2_rd_en)         ,//rfifo读出使能
        .rfifo_rd_data32_out    (video2_data_out)      ,//rfifo输入数据,16bits
        .rfifo_wr_req           (rfifo2_wr_req)        ,//rfifo写请求，当数量大于突发长度时拉高
        .rfifo_wr_water_level   (rfifo2_wr_water_level),//rfifo写水位，当数量小于突发长度时开始传输
        .rfifo_wr_data256_in    (M2_AXI_RDATA)         ,   //rfifo写数据，256bits    
        .vs_in                  (video2_vs_in          )     ,
        .vs_out                 (vs_out         )                              
   );

//第3组FIFO
rw_fifo_ctrl user_rw_fifo_ctrl3(
        .rstn                   (M_AXI_ARESETN),//系统复位,DDR未初始化完成时保持复位状态
        .ddr_clk                (M_AXI_ACLK          ),//写入内存的时钟（内存axi4接口时钟）
         //hdmi_wfifo_ddr                             
        .wfifo_wr_clk           (video3_clk_in          ),//wfifo写时钟
        .wfifo_wr_en            (video3_de_in          ),//wfifo输入使能
        .wfifo_wr_data32_in     (video3_data_in        ),//wfifo输入数据,32bits
        .wfifo_rd_req           (wfifo3_rd_req || wfifo3_pre_rd_req),//wfifo读请求，当数量大于突发长度时拉高
        .wfifo_rd_water_level   (wfifo3_rd_water_level),//wfifo读水位，当数量大于突发长度时开始传输
        .wfifo_rd_data256_out   (M3_AXI_WDATA         ),//wfifo读数据，256bits      
        //ddr_rfifo_hdmi
        .rfifo_rd_clk           (pix_clk_out)         ,//rfifo读时钟
        .rfifo_rd_en            (video3_rd_en)          ,//rfifo读出使能
        .rfifo_rd_data32_out    (video3_data_out)       ,//rfifo输入数据,32bits
        .rfifo_wr_req           (rfifo3_wr_req  )       ,//rfifo写请求，当数量大于突发长度时拉高
        .rfifo_wr_water_level   (rfifo3_wr_water_level),//rfifo写水位，当数量小于突发长度时开始传输
        .rfifo_wr_data256_in    (M3_AXI_RDATA)         ,   //rfifo写数据，256bits    
        .vs_in                  (video3_vs_in          )     ,
        .vs_out                 (vs_out         )                              
   );


endmodule