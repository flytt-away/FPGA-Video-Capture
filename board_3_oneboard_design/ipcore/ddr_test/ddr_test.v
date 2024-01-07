// Created by IP Generator (Version 2022.1 build 99559)



`timescale 1ns/1ps

`define DDR3

module  ddr_test #(

   parameter DFI_CLK_PERIOD       = 10000         ,

   parameter MEM_ROW_WIDTH   = 15         ,

   parameter MEM_COLUMN_WIDTH   = 10         ,

   parameter MEM_BANK_WIDTH      = 3          ,

  parameter MEM_DQ_WIDTH         =  32         ,

  parameter MEM_DM_WIDTH         =  4         ,

  parameter MEM_DQS_WIDTH        =  4         ,

  parameter REGION_NUM           =  3         ,

  parameter CTRL_ADDR_WIDTH      = MEM_ROW_WIDTH + MEM_COLUMN_WIDTH + MEM_BANK_WIDTH         
  )(
   input                              ref_clk        ,
   input                              resetn         ,
   output                             ddr_init_done  ,
   output                             ddrphy_clkin   ,
   output                             pll_lock       , 
 
   input [CTRL_ADDR_WIDTH-1:0]        axi_awaddr     ,
   input                              axi_awuser_ap  ,
   input [3:0]                        axi_awuser_id  ,
   input [3:0]                        axi_awlen      ,
   output                             axi_awready    ,
   input                              axi_awvalid    ,

   input [MEM_DQ_WIDTH*8-1:0]         axi_wdata      ,
   input [MEM_DQ_WIDTH-1:0]           axi_wstrb      ,
   output                             axi_wready     ,
   output [3:0]                       axi_wusero_id  ,
   output                             axi_wusero_last,

   input [CTRL_ADDR_WIDTH-1:0]        axi_araddr     ,
   input                              axi_aruser_ap  ,
   input [3:0]                        axi_aruser_id  ,
   input [3:0]                        axi_arlen      ,
   output                             axi_arready    ,
   input                              axi_arvalid    ,

   output[8*MEM_DQ_WIDTH-1:0]         axi_rdata      ,
   output[3:0]                        axi_rid        ,
   output                             axi_rlast      ,
   output                             axi_rvalid     ,

   input                              apb_clk        ,
   input                              apb_rst_n      ,
   input                              apb_sel        ,
   input                              apb_enable     ,
   input [7:0]                        apb_addr       ,
   input                              apb_write      ,
   output                             apb_ready      ,
   input [15:0]                       apb_wdata      ,
   output[15:0]                       apb_rdata      ,
   output                             apb_int        ,
   output [34*MEM_DQS_WIDTH -1:0]     debug_data           ,
   output [13*MEM_DQS_WIDTH -1:0]     debug_slice_state    ,
   output [21:0]                      debug_calib_ctrl     ,
   output [7:0]                       ck_dly_set_bin       ,
   input                              force_ck_dly_en      ,
   input [7:0]                        force_ck_dly_set_bin ,
   output [7:0]                       dll_step             ,    
   output                             dll_lock             ,
   input [1:0]                        init_read_clk_ctrl   ,                                                       
   input [3:0]                        init_slip_step       ,                                                
   input                              force_read_clk_ctrl  , 

   input                              ddrphy_gate_update_en,
   output [MEM_DQS_WIDTH-1:0]         update_com_val_err_flag,
   input                              rd_fake_stop         ,
   
   output                             mem_rst_n            ,                       
   output                             mem_ck               ,
   output                             mem_ck_n             ,
   output                             mem_cke              ,

   output                             mem_cs_n             ,

   output                             mem_ras_n            ,
   output                             mem_cas_n            ,
   output                             mem_we_n             , 
   output                             mem_odt              ,
   output [MEM_ROW_WIDTH-1:0]         mem_a                ,   
   output [MEM_BANK_WIDTH-1:0]        mem_ba               ,   
   inout [MEM_DQS_WIDTH-1:0]          mem_dqs              ,
   inout [MEM_DQS_WIDTH-1:0]          mem_dqs_n            ,
   inout [MEM_DQ_WIDTH-1:0]           mem_dq               ,
   output [MEM_DM_WIDTH-1:0]          mem_dm               
);

`ifdef SIMULATION                                                  
localparam T200US         = (200*1000*1000 / DFI_CLK_PERIOD) / 100;
`else                                                              
localparam T200US         = (200*1000*1000 / DFI_CLK_PERIOD);      
`endif

`ifdef SIMULATION                                                  
localparam T500US         = (500*1000*1000 / DFI_CLK_PERIOD) / 100;
`else                                                              
localparam T500US         = (500*1000*1000 / DFI_CLK_PERIOD);      
`endif

//MR0_DDR3
localparam [0:0] DDR3_PPD      = 1'b1;

localparam [2:0] DDR3_WR       =  3'd2;

localparam [0:0] DDR3_DLL      = 1'b1;
localparam [0:0] DDR3_TM       = 1'b0;
localparam [0:0] DDR3_RBT      = 1'b0;


localparam [3:0] DDR3_CL       = 4'd4;

    
localparam [1:0] DDR3_BL       = 2'b00;
localparam [15:0] MR0_DDR3     = {3'b000, DDR3_PPD, DDR3_WR, DDR3_DLL, DDR3_TM, DDR3_CL[3:1], DDR3_RBT, DDR3_CL[0], DDR3_BL};
//MR1_DDR3
localparam [0:0] DDR3_QOFF     = 1'b0;
localparam [0:0] DDR3_TDQS     = 1'b0;


localparam [2:0] DDR3_RTT_NOM  = 3'b001;
      

localparam [0:0] DDR3_LEVEL    = 1'b0;

localparam [1:0] DDR3_DIC      = 2'b00;

localparam [1:0] DDR3_AL       = 2'd2;
    
localparam [0:0] DDR3_DLL_EN   = 1'b0;
localparam [15:0] MR1_DDR3 = {1'b0, DDR3_QOFF, DDR3_TDQS, 1'b0, DDR3_RTT_NOM[2], 1'b0, DDR3_LEVEL, DDR3_RTT_NOM[1], DDR3_DIC[1], DDR3_AL, DDR3_RTT_NOM[0], DDR3_DIC[0], DDR3_DLL_EN};
//MR2_DDR3
localparam [1:0] DDR3_RTT_WR   = 2'b00;
localparam [0:0] DDR3_SRT      = 1'b0;
localparam [0:0] DDR3_ASR      = 1'b0;


localparam [2:0] DDR3_CWL      = 5 - 5;


localparam [2:0] DDR3_PASR     = 3'b000;
localparam [15:0] MR2_DDR3     = {5'b00000, DDR3_RTT_WR, 1'b0, DDR3_SRT, DDR3_ASR, DDR3_CWL, DDR3_PASR};
//MR3_DDR3
localparam [0:0] DDR3_MPR      = 1'b0;
localparam [1:0] DDR3_MPR_LOC  = 2'b00;
localparam [15:0] MR3_DDR3     = {13'b0, DDR3_MPR, DDR3_MPR_LOC};



//****************************************************************************     
//The following parameters are mode register settings                              
//*****************************************************************************       
localparam INIT_MC_AL           = 2'b10       ;
localparam INIT_MC_CL           = 6           ;
localparam INIT_MC_CWL          = 5           ;
localparam INIT_MC_WR           = 6           ;       

//******************************************************************************
//The following parameters are Memory Timing
//******************************************************************************    

  localparam         MEM_TYPE          =  "DDR3"    ;

  localparam [7:0]   PHY_TMRD          =  4/4    ;

  localparam [7:0]   PHY_TRP           =  2      ;

  localparam [7:0]   PHY_TRCD          =  2      ;

  localparam         DDRC_TXSDLL       = 512      ;

  localparam         DDRC_TXP          = 3       ;

  localparam         DDRC_TFAW         = 18       ;

  localparam         DDRC_TRAS         = 15       ;

  localparam         DDRC_TRCD         = 6       ;

  localparam         DDRC_TRFC         = 120       ;

  localparam         DDRC_TREFI        = 3120       ;

  localparam         DDRC_TRC          = 20       ;

  localparam         DDRC_TRP          = 6       ;

  localparam         DDRC_TRRD         = 4       ;

  localparam         DDRC_TRTP         = 4       ;

  localparam         DDRC_TWR          = 6       ;

  localparam         DDRC_TWTR         = 4       ;

  localparam [7:0]   PHY_TMOD          =  12/4    ;

  localparam [9:0]   PHY_TZQINIT       =  10'd128 ;

  localparam [7:0]   PHY_TRFC          =  30      ;

  localparam [7:0]   PHY_TXPR          =  31      ;

  localparam real    CLKIN_FREQ        =  50.0   ;

  localparam         PLL_IDIV          =  1      ;

  localparam         PLL_FDIV          =  16     ;

  localparam         PLL_ODIV0         =  2      ;

  localparam         PLL_ODIV1         =  2*4    ;

  localparam         PLL_DUTY0         =  2      ;

  localparam         PLL_DUTY1         =  2*4    ;


wire                              dfi_phyupd_req  ;
wire                              dfi_phyupd_ack  ;
wire                              dfi_init_complete;
wire [4*MEM_ROW_WIDTH-1:0]        dfi_address     ;
wire [4*MEM_BANK_WIDTH-1:0]       dfi_bank        ;
wire [4-1:0]                      dfi_cs_n        ;
wire [4-1:0]                      dfi_ras_n       ;
wire [4-1:0]                      dfi_cas_n       ;
wire [4-1:0]                      dfi_we_n        ;
wire [4-1:0]                      dfi_cke         ;
wire [4-1:0]                      dfi_odt         ;
wire [2*4*MEM_DQ_WIDTH-1:0]       dfi_wrdata      ;
wire [4-1:0]                      dfi_wrdata_en   ;
wire [2*4*MEM_DQ_WIDTH/8-1:0]     dfi_wrdata_mask ;
wire [2*4*MEM_DQ_WIDTH-1:0]       dfi_rddata      ;
wire                              dfi_rddata_valid;
wire                              ddrphy_ioclk_gate;
wire                              ddrphy_dqs_rst   ;

wire [1:0]                        ddrphy_ioclk_source;

wire [REGION_NUM-1:0]             ioclk;
wire [8:0]                        ddrphy_ioclk;
wire                              pll_clkin;

wire [1:0]                        pll_ioclk_lock;

wire                              ddr_rstn;
wire                              ddrphy_pll_rst;
wire                              ioclk_gate_clk;
wire                              ioclk_gate_clk_pll;
    
ipsxb_rst_sync_v1_1 u_ddrp_rstn_sync(
    .clk                        (pll_clkin       ),
    .rst_n                      (resetn          ),
    .sig_async                  (1'b1),               
    .sig_synced                 (ddr_rstn        )
);

GTP_CLKBUFG u_clkbufg
(
 .CLKOUT(pll_clkin  ),
 .CLKIN (ref_clk    )
);


//pll_0
ipsxb_ddrphy_pll_v1_0 #(
    .CLKIN_FREQ    (CLKIN_FREQ            ),
    .STATIC_RATIOI (PLL_IDIV              ),
    .STATIC_RATIOF (PLL_FDIV              ),
    .STATIC_RATIO0 (PLL_ODIV0             ),
    .STATIC_DUTY0  (PLL_DUTY0             ),
    .STATIC_RATIO1 (PLL_ODIV1             ),
    .STATIC_DUTY1  (PLL_DUTY1             )
) u_ipsxb_ddrphy_pll_0 (
    .pll_rst      (ddrphy_pll_rst         ),
    .pll_lock     (pll_ioclk_lock[0]      ),
    .clkout0_gate (ddrphy_ioclk_gate      ),
    .clkout0      (ddrphy_ioclk_source[0] ), //io clock
    .clkout1      (ioclk_gate_clk_pll     ),
    .clkin1       (pll_clkin              )
);

//pll_1
ipsxb_ddrphy_pll_v1_0 #(
    .CLKIN_FREQ    (CLKIN_FREQ            ),
    .STATIC_RATIOI (PLL_IDIV              ),
    .STATIC_RATIOF (PLL_FDIV              ),
    .STATIC_RATIO0 (PLL_ODIV0             ),
    .STATIC_DUTY0  (PLL_DUTY0             ),
    .STATIC_RATIO1 (PLL_ODIV1             ),
    .STATIC_DUTY1  (PLL_DUTY1             )
) u_ipsxb_ddrphy_pll_1 (
    .pll_rst      (ddrphy_pll_rst         ),
    .pll_lock     (pll_ioclk_lock[1]      ),
    .clkout0_gate (ddrphy_ioclk_gate      ),
    .clkout0      (ddrphy_ioclk_source[1] ), //io clock
    .clkin1       (pll_clkin              )
);

GTP_IOCLKBUF #(
    .GATE_EN    ("TRUE"                )
) I_GTP_IOCLKBUF_0 (
    .CLKOUT     (ioclk[0]              ),
    .CLKIN      (ddrphy_ioclk_source[0]),
    .DI         (1'b1                  )
);

GTP_IOCLKBUF #(
    .GATE_EN("TRUE"              )
) I_GTP_IOCLKBUF_1 (
    .CLKOUT(ioclk[1]             ),
    .CLKIN(ddrphy_ioclk_source[0]),
    .DI(1'b1                     )
);

GTP_IOCLKBUF #(
    .GATE_EN    ("TRUE"                )
) I_GTP_IOCLKBUF_2 (
    .CLKOUT     (ioclk[2]              ),
    .CLKIN      (ddrphy_ioclk_source[1]),
    .DI         (1'b1                  )
);

GTP_IOCLKDIV #(
    .DIV_FACTOR     ("4"), //"2"; "3.5"; "4"; "5"; 
    .GRS_EN         ("FALSE") //"true"; "false"
)I_GTP_CLKDIV(      
    .CLKIN           (ddrphy_ioclk_source[0]),
    .RST_N           (~ddrphy_dqs_rst),
    .CLKDIVOUT       (ddrphy_clkin)
    );

assign ddrphy_ioclk = {ioclk[2],ioclk[2],ioclk[2],ioclk[1],ioclk[1],ioclk[1],ioclk[0],ioclk[0],ioclk[0]};


GTP_CLKBUFG u_clkbufg_gate
(
 .CLKOUT(ioclk_gate_clk        ),
 .CLKIN (ioclk_gate_clk_pll    )
);


assign pll_lock = &pll_ioclk_lock;
                                                            
ipsxb_mcdq_wrapper_v1_2a #(             
   .MEM_ROW_ADDR_WIDTH (MEM_ROW_WIDTH ),   
   .MEM_COL_ADDR_WIDTH (MEM_COLUMN_WIDTH ),   
   .MEM_BA_ADDR_WIDTH  (MEM_BANK_WIDTH    ),    
   .MEM_DQ_WIDTH       (MEM_DQ_WIDTH       ), 
   .CTRL_ADDR_WIDTH    (CTRL_ADDR_WIDTH    ),         
   .ADDR_MAPPING_SEL   (1                  ),  //0:  ROW + BANK + COLUMN   1:BANK + ROW +COLUMN                                                                                                                           

   .MR0_DDR3           (MR0_DDR3           ),  
   .MR1_DDR3           (MR1_DDR3           ),
   .MR2_DDR3           (MR2_DDR3           ),                     
   .MR3_DDR3           (MR3_DDR3           ),  
                                           
   .TXSDLL             (DDRC_TXSDLL        ),
   .TXP                (DDRC_TXP           ),
   .TFAW               (DDRC_TFAW          ),       
   .TRAS               (DDRC_TRAS          ),       
   .TRCD               (DDRC_TRCD          ),       
   .TREFI              (DDRC_TREFI         ),       
   .TRFC               (DDRC_TRFC          ),  
   .TRC                (DDRC_TRC           ),
   .TRP                (DDRC_TRP           ),       
   .TRRD               (DDRC_TRRD          ),       
   .TRTP               (DDRC_TRTP          ),
   .TWR                (DDRC_TWR           ),      
   .TWTR               (DDRC_TWTR          )        
  )u_ipsxb_ddrc_top(
   .clk                (ddrphy_clkin      ),
   .rst_n              (ddr_rstn          ),

   .phy_init_done      (dfi_init_complete ),
   .ddr_init_done      (ddr_init_done     ),

   .axi_awaddr         (axi_awaddr        ), 
   .axi_awuser_ap      (axi_awuser_ap     ),
   .axi_awuser_id      (axi_awuser_id     ),
   .axi_awlen          (axi_awlen         ),
   .axi_awready        (axi_awready       ),
   .axi_awvalid        (axi_awvalid       ),

   .axi_wdata          (axi_wdata         ),   
   .axi_wstrb          (axi_wstrb         ),   
   .axi_wready         (axi_wready        ),   
   .axi_wusero_id      (axi_wusero_id     ),   
   .axi_wusero_last    (axi_wusero_last   ),   

   .axi_araddr         (axi_araddr        ),     
   .axi_aruser_ap      (axi_aruser_ap     ),  
   .axi_aruser_id      (axi_aruser_id     ),  
   .axi_arlen          (axi_arlen         ),  
   .axi_arready        (axi_arready       ),  
   .axi_arvalid        (axi_arvalid       ),  

   .axi_rdata          (axi_rdata         ),
   .axi_rid            (axi_rid           ), 
   .axi_rlast          (axi_rlast         ), 
   .axi_rvalid         (axi_rvalid        ),  

   .apb_clk            (apb_clk           ),
   .apb_rst_n          (apb_rst_n         ),
   .apb_sel            (apb_sel           ),
   .apb_enable         (apb_enable        ),
   .apb_addr           (apb_addr          ),
   .apb_write          (apb_write         ),
   .apb_ready          (apb_ready         ),
   .apb_wdata          (apb_wdata         ),
   .apb_rdata          (apb_rdata         ),

   .dfi_phyupd_req     (dfi_phyupd_req    ), 
   .dfi_phyupd_ack     (dfi_phyupd_ack    ),  

   .dfi_address        (dfi_address       ),
   .dfi_bank           (dfi_bank          ),
   .dfi_cs_n           (dfi_cs_n          ),
   .dfi_ras_n          (dfi_ras_n         ),
   .dfi_cas_n          (dfi_cas_n         ),
   .dfi_we_n           (dfi_we_n          ),
   .dfi_cke            (dfi_cke           ),
   .dfi_odt            (dfi_odt           ),
   .dfi_wrdata         (dfi_wrdata        ),
   .dfi_wrdata_en      (dfi_wrdata_en     ),
   .dfi_wrdata_mask    (dfi_wrdata_mask   ),
   .dfi_rddata         (dfi_rddata        ),
   .dfi_rddata_valid   (dfi_rddata_valid  )
   );
ddr_test_ddrphy_top  #(
  .T200US              (T200US             ),  
  .T500US              (T500US             ),  
  .MEM_TYPE            (MEM_TYPE           ),
  .TMRD                (PHY_TMRD           ),
  .TMOD                (PHY_TMOD           ),
  .TZQINIT             (PHY_TZQINIT        ),
  .TXPR                (PHY_TXPR           ),
  .TRP                 (PHY_TRP            ),
  .TRFC                (PHY_TRFC           ),
  .TRCD                (PHY_TRCD           ), 
  .MEM_ADDR_WIDTH      (MEM_ROW_WIDTH ),  
  .MEM_BANK_WIDTH      (MEM_BANK_WIDTH    ),  
  .MEM_DQ_WIDTH        (MEM_DQ_WIDTH       ),  
  .MEM_DM_WIDTH        (MEM_DM_WIDTH       ),  
  .MEM_DQS_WIDTH       (MEM_DQS_WIDTH      )
 )u_ddrphy_top(
  .ref_clk               (pll_clkin                 ),
  .ddr_rstn              (ddr_rstn                  ), 
  .pll_lock              (pll_lock                  ),
  .ddrphy_ioclk_gate     (ddrphy_ioclk_gate         ), 
  .ddrphy_pll_rst        (ddrphy_pll_rst            ),
  .ioclk_gate_clk        (ioclk_gate_clk            ),
  .ddrphy_dqs_rst        (ddrphy_dqs_rst            ),                                                  
  .ddrphy_clkin          (ddrphy_clkin              ),
  .ddrphy_ioclk          (ddrphy_ioclk              ), 
  .dll_step              (dll_step                  ), 
  .dll_lock              (dll_lock                  ),                                                                                                                 
  .ddrphy_gate_update_en (ddrphy_gate_update_en     ), 
  .update_com_val_err_flag (update_com_val_err_flag ),
  .init_read_clk_ctrl    (init_read_clk_ctrl        ),                                                       
  .init_slip_step        (init_slip_step            ), 
  .force_read_clk_ctrl   (force_read_clk_ctrl       ),                                             
  .init_samp_position    (8'h0                      ),                                                                     
  .dfi_address           (dfi_address               ),                     
  .dfi_bank              (dfi_bank                  ),                     
  .dfi_cs_n              (dfi_cs_n                  ),                     
  .dfi_cas_n             (dfi_cas_n                 ),                     
  .dfi_ras_n             (dfi_ras_n                 ),                     
  .dfi_we_n              (dfi_we_n                  ),                     
  .dfi_cke               (dfi_cke                   ),                     
  .dfi_odt               (dfi_odt                   ), 
  .dfi_wrdata_en         (dfi_wrdata_en             ),                      
  .dfi_wrdata            (dfi_wrdata                ),                     
  .dfi_wrdata_mask       (dfi_wrdata_mask           ),                     
  .dfi_rddata            (dfi_rddata                ),                                         
  .dfi_rddata_valid      (dfi_rddata_valid          ),                     
  .dfi_reset_n           (1'b1                      ),                                          
  .dfi_phyupd_req        (dfi_phyupd_req            ),                                         
  .dfi_phyupd_ack        (dfi_phyupd_ack            ),                                          
  .dfi_init_complete     (dfi_init_complete         ), 
  .rd_fake_stop          (rd_fake_stop              ),
  .debug_calib_ctrl      (debug_calib_ctrl          ),
  .debug_data            (debug_data                ), 
  .debug_slice_state     (debug_slice_state         ),    
  .ck_dly_set_bin        (ck_dly_set_bin            ),   
  .force_ck_dly_set_bin  (force_ck_dly_set_bin      ),
  .force_ck_dly_en       (force_ck_dly_en           ),
  .mem_rst_n             (mem_rst_n                 ),                       
  .mem_ck                (mem_ck                    ),
  .mem_ck_n              (mem_ck_n                  ),
  .mem_cke               (mem_cke                   ),

  .mem_cs_n              (mem_cs_n                  ),

  .mem_ras_n             (mem_ras_n                 ),
  .mem_cas_n             (mem_cas_n                 ),
  .mem_we_n              (mem_we_n                  ), 
  .mem_odt               (mem_odt                   ),
  .mem_a                 (mem_a                     ),   
  .mem_ba                (mem_ba                    ),   
  .mem_dqs               (mem_dqs                   ),
  .mem_dqs_n             (mem_dqs_n                 ),
  .mem_dq                (mem_dq                    ),
  .mem_dm                (mem_dm                    )                                                                                   
);

endmodule

