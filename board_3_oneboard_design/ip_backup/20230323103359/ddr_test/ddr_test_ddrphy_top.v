// Created by IP Generator (Version 2022.1 build 99559)



`timescale 1ns/1ps

`define DDR3


module ddr_test_ddrphy_top  #(
  parameter [15:0]  T200US       =  16'd20000 ,  
  parameter [15:0]  T500US       =  16'd50000 ,  

  parameter         MEM_TYPE     =  "DDR3"   ,

  parameter [7:0]   TMRD         =  4/4   ,

  parameter [7:0]   TMOD         =  12/4   ,

  parameter [9:0]   TZQINIT      =  10'd128,

  parameter [7:0]   TXPR         =  31     ,

  parameter [7:0]   TRP          =  2     ,

  parameter [7:0]   TRFC         =  30     ,

  parameter [7:0]   TRCD         =  2     ,

  parameter MEM_ADDR_WIDTH       =  15     , 

  parameter MEM_BANK_WIDTH   =  3         ,

  parameter MEM_DQ_WIDTH         =  32     ,

  parameter MEM_DM_WIDTH         =  4     ,

  parameter MEM_DQS_WIDTH        =  4     ,

  parameter REGION_NUM           =  3     ,

  parameter DM_GROUP_EN          =  0     

)(
//clk
  input                              ref_clk              ,
  input                              ddr_rstn             , 
  input                              pll_lock             ,
  output                             ddrphy_ioclk_gate    , 
  output                             ddrphy_pll_rst       ,
  output                             ddrphy_dqs_rst       ,                                                  
  input                              ddrphy_clkin         ,
  input [8:0]                        ddrphy_ioclk         ,   
  input                              ioclk_gate_clk       ,         
//rst                                                                                                        
  input                              ddrphy_gate_update_en,   
  output [MEM_DQS_WIDTH-1:0]         update_com_val_err_flag,
  input [1:0]                        init_read_clk_ctrl   ,                                                       
  input [3:0]                        init_slip_step       ,                                                
  input [7:0]                        init_samp_position   , 
  input                              force_read_clk_ctrl  ,               

//dfi                                                          
  input  [4*MEM_ADDR_WIDTH-1:0]      dfi_address          ,                     
  input  [4*MEM_BANK_WIDTH-1:0]      dfi_bank             ,                     
  input  [3:0]                       dfi_cs_n             ,                     
  input  [3:0]                       dfi_cas_n            ,                     
  input  [3:0]                       dfi_ras_n            ,                     
  input  [3:0]                       dfi_we_n             ,                     
  input  [3:0]                       dfi_cke              ,                     
  input  [3:0]                       dfi_odt              , 
  input  [3:0]                       dfi_wrdata_en        ,                      
  input  [8*MEM_DQ_WIDTH-1:0]        dfi_wrdata           ,                     
  input  [8*MEM_DM_WIDTH-1:0]        dfi_wrdata_mask      ,                     
  output [8*MEM_DQ_WIDTH-1:0]        dfi_rddata           ,                                         
  output                             dfi_rddata_valid     ,                     
  input                              dfi_reset_n          ,                     
  output                             dfi_phyupd_req       ,                             
  input                              dfi_phyupd_ack       ,                                       
  output                             dfi_init_complete    ,                             
  output                             dfi_error            , 
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
  output [MEM_ADDR_WIDTH-1:0]        mem_a                ,   
  output [MEM_BANK_WIDTH-1:0]        mem_ba               ,   
  inout  [MEM_DQS_WIDTH-1:0]         mem_dqs              ,
  inout  [MEM_DQS_WIDTH-1:0]         mem_dqs_n            ,
  inout  [MEM_DQ_WIDTH-1:0]          mem_dq               ,
  output [MEM_DM_WIDTH-1:0]          mem_dm               ,
  output [21:0]                      debug_calib_ctrl     ,
  output [34*MEM_DQS_WIDTH -1:0]     debug_data           ,
  output [13*MEM_DQS_WIDTH -1:0]     debug_slice_state    ,
  output [7:0]                       ck_dly_set_bin       ,
  input  [7:0]                       force_ck_dly_set_bin ,
  input                              force_ck_dly_en      ,
  output [7:0]                       dll_step             ,
  output                             dll_lock                                                      
);


localparam real CLKIN_FREQ  =  50.0   ;

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



wire                            dll_update_n                 ;
wire                            dll_update_n_syn             ; 
wire                            ddrphy_dll_rst               ;
wire                            dll_update_req_rst_ctrl      ;
wire                            dll_update_ack_rst_ctrl      ;
wire                            ddrphy_rst_n                 ;   
wire                            dll_update_ack               ;
wire                            dll_freeze                   ; 
wire                            dll_freeze_syn               ; 
wire [4:0]                      mc_wl                        ;
wire [4:0]                      mc_rl                        ;
wire [15:0]                     mr0_ddr3                     ;
wire [15:0]                     mr1_ddr3                     ;
wire [15:0]                     mr2_ddr3                     ;
wire [15:0]                     mr3_ddr3                     ;
wire                            calib_done                   ;
wire                            ddrphy_update                ;
wire                            ddrphy_update_done           ;
wire                            update_cal_req               ;
wire                            update_done                  ;
wire [31:0]                     read_wait_cnt                ;
wire [2*MEM_DQS_WIDTH-1:0]      dqs_drift                    ;
wire                            update_gate_read_flag        ;
wire                            dqs_gate_update1             ;
wire                            dqs_gate_update2             ;
wire                            gate_update1_done            ;
wire                            gate_update2_done            ;
wire                            dqs_gate_check_falling       ;
wire                            ddrphy_rst_req               ;
wire                            ddrphy_rst_ack               ;
wire                            wrlvl_dqs_req                ;
wire                            wrlvl_dqs_resp               ;
wire                            wrlvl_error                  ;
wire                            wrlvl_ck_dly_start_rst       ;
wire                            gatecal_start                ;
wire                            gate_check_pass              ;
wire                            gate_adj_done                ;
wire                            gate_cal_error               ;
wire                            gate_move_en                 ;
wire                            rddata_cal                   ;
wire                            rddata_check_pass            ;
wire                            init_adj_rdel                ;
wire                            reinit_adj_rdel              ;
wire                            adj_rdel_done                ;
wire                            rdel_calibration             ;
wire                            rdel_calib_done              ;
wire                            rdel_calib_error             ;
wire                            rdel_move_en                 ;
wire                            rdel_move_done               ;     
wire                            gate_check_error             ;
wire                            calib_rst                    ;
wire [MEM_BANK_WIDTH-1:0]       calib_ba                     ;
wire [MEM_ADDR_WIDTH-1:0]       calib_address                ;
wire                            calib_cs_n                   ;
wire                            calib_ras_n                  ;
wire                            calib_cas_n                  ;
wire                            calib_we_n                   ;
wire                            calib_cke                    ;
wire                            calib_odt                    ;
wire [3:0]                      calib_wrdata_en              ;
wire [8*MEM_DQ_WIDTH-1:0]       calib_wrdata                 ;
wire [8*MEM_DM_WIDTH-1:0]       calib_wrdata_mask            ;
wire                            ddrphy_dqs_training_rstn     ;
wire [3:0]                      read_cmd                     ;
wire     	                read_valid                   ;       
wire [MEM_DQS_WIDTH-1:0]        ddrphy_read_valid            ;
wire [8*MEM_DQ_WIDTH-1:0]       o_read_data                  ;                                                                               
wire [3:0]                      phy_wrdata_en                ;               
wire [8*MEM_DM_WIDTH-1:0]       phy_wrdata_mask              ;               
wire [8*MEM_DQ_WIDTH-1:0]       phy_wrdata                   ;                            
wire [3:0]                      phy_cke                      ;                             
wire [3:0]                      phy_cs_n                     ;                             
wire [3:0]                      phy_ras_n                    ;                             
wire [3:0]                      phy_cas_n                    ;                             
wire [3:0]                      phy_we_n                     ;                             
wire [4*MEM_ADDR_WIDTH-1:0]     phy_addr                     ;                             
wire [4*MEM_BANK_WIDTH-1:0]     phy_ba                       ;                             
wire [3:0]                      phy_odt                      ;
wire [3:0]                      phy_ck                       ;
wire                            phy_rst                      ;


GTP_DLL  #(
    .GRS_EN             ("FALSE"), //"true"; "false"
    .FAST_LOCK          ("TRUE" ), //"true"; "false"
    .DELAY_STEP_OFFSET  (0      )  //-4, -3,-2, -1, 0, 1, 2, 3, 4
) I_GTP_DLL(    
    
    .CLKIN          (ddrphy_ioclk[4]   ),

    .UPDATE_N       (dll_update_n      ),
    .RST            (ddrphy_dll_rst    ),
    .PWD            (dll_freeze_syn    ),
    .DELAY_STEP     (dll_step          ),
    .LOCK           (dll_lock          )
); 

ipsxb_ddrphy_reset_ctrl_v1_4  ddrphy_reset_ctrl(
  .ddrphy_clkin             (ddrphy_clkin            ),
  .ddr_rstn                 (ddr_rstn                ),
  .ref_clk                  (ref_clk                 ),
  .ioclk_gate_clk           (ioclk_gate_clk          ),
  .dll_lock                 (dll_lock                ),
  .pll_lock                 (pll_lock                ),
  .dll_update_req_rst_ctrl  (dll_update_req_rst_ctrl ),
  .dll_update_ack_rst_ctrl  (dll_update_ack_rst_ctrl ),
  .training_error           (dfi_error               ),
  .ddrphy_calib_done        (calib_done              ),
  .ddrphy_dll_rst           (ddrphy_dll_rst          ),    //dll reset
  .ddrphy_rst_n             (ddrphy_rst_n            ),
  .ddrphy_pll_rst           (ddrphy_pll_rst          ),
  .ddrphy_dqs_rst           (ddrphy_dqs_rst          ),
  .logic_rstn               (logic_rstn              ),
  .ddrphy_ioclk_gate        (ddrphy_ioclk_gate       ),
  .gate_check_error         (gate_check_error        ),
  .dll_tran_update_en       (dll_tran_update_en      ),
  .wrlvl_ck_dly_start_rst   (wrlvl_ck_dly_start_rst  )
);

ipsxb_ddrphy_gate_update_ctrl_v1_3 #(
  .MEM_DQS_WIDTH            (MEM_DQS_WIDTH           )
) ddrphy_gate_update_ctrl (
  .ddrphy_clkin             (ddrphy_clkin            ),
  .ddrphy_rst_n             (ddrphy_rst_n            ),
  .ddrphy_gate_update_en    (ddrphy_gate_update_en   ),
  .calib_done               (calib_done              ),
  .dqs_drift                (dqs_drift               ),
  .update_done              (update_done             ),
  .ddrphy_update_done       (ddrphy_update_done      ),
  .update_req_start         (ddrphy_update           ),
  .ddrphy_read_valid        (ddrphy_read_valid       ),
  .update_gate_read_flag    (update_gate_read_flag   ),
  .update_com_val_err_flag  (update_com_val_err_flag )
);

ipsxb_ddrphy_dll_update_ctrl_v1_0 ddrphy_dll_update_ctrl(
  .ddr_clkin                (ref_clk                 ),
  .ddr_rstn                 (logic_rstn              ),
  .dll_update_req_rst_ctrl  (dll_update_req_rst_ctrl ),
  .dll_update_ack_rst_ctrl  (dll_update_ack_rst_ctrl ),
  .dll_update_req_training  (1'b0                    ),
  .dll_update_ack_training  (dll_update_ack          ),
  .dll_tran_update_en       (dll_tran_update_en      ),
  .dll_update_n             (dll_update_n            ),
  .dll_freeze               (dll_freeze              )
);

ipsxb_rst_sync_v1_1 #(
    .DATA_WIDTH            (1                        ),
    .DFT_VALUE             (1'b0                     )
) u_dll_freeze_sync(
    .clk                   (ddrphy_clkin             ),
    .rst_n                 (ddrphy_dll_rst_n         ),
    .sig_async             (dll_freeze               ),
    .sig_synced            (dll_freeze_syn           )
);

ipsxb_ddrphy_calib_top_v1_3 #(
 .T200US              (T200US             ),
 .T500US              (T500US             ),
 .TMRD                (TMRD               ),
 .TMOD                (TMOD               ),
 .TXPR                (TXPR               ),
 .TZQINIT             (TZQINIT            ),       
 .TRFC                (TRFC               ),
 .TRCD                (TRCD               ),
 .MEM_ADDR_WIDTH      (MEM_ADDR_WIDTH     ),
 .MEM_BANKADDR_WIDTH  (MEM_BANK_WIDTH     ),
 .MEM_DQ_WIDTH        (MEM_DQ_WIDTH       ),
 .MEM_DM_WIDTH        (MEM_DM_WIDTH       ),
 .MEM_DQS_WIDTH       (MEM_DQS_WIDTH      )
) ddrphy_calib_top(     
  .mc_wl               (mc_wl                    ),
  .mr0_ddr3            (mr0_ddr3                 ),
  .mr1_ddr3            (mr1_ddr3                 ),
  .mr2_ddr3            (mr2_ddr3                 ),
  .mr3_ddr3            (mr3_ddr3                 ),
 
  .ddrphy_clkin        (ddrphy_clkin             ),
  .ddrphy_rst_n        (ddrphy_rst_n             ),
  .calib_done          (calib_done               ),
  .update_done         (update_done              ),
  .ddrphy_update_done  (ddrphy_update_done       ),
  .ddrphy_rst_req      (ddrphy_rst_req           ),
  .ddrphy_rst_ack      (ddrphy_rst_ack           ),
  .wrlvl_dqs_req       (wrlvl_dqs_req            ),
  .wrlvl_dqs_resp      (wrlvl_dqs_resp           ),
  .wrlvl_error         (wrlvl_error              ),
  .gatecal_start       (gatecal_start            ),   
  .gate_check_pass     (gate_check_pass          ),
  .gate_adj_done       (gate_adj_done            ),
  .gate_cal_error      (gate_cal_error           ),
  .gate_move_en        (gate_move_en             ),
  .rddata_cal          (rddata_cal               ), 
  .rddata_check_pass   (rddata_check_pass        ),
  .stop_with_error     (1'b0                     ),
  .init_adj_rdel       (init_adj_rdel            ),
  .reinit_adj_rdel     (reinit_adj_rdel          ),
  .adj_rdel_done       (adj_rdel_done            ),
  .rdel_calibration    (rdel_calibration         ),
  .rdel_calib_done     (rdel_calib_done          ),
  .rdel_calib_error    (rdel_calib_error         ),
  .rdel_move_en        (rdel_move_en             ),
  .rdel_move_done      (rdel_move_done           ),
  .write_debug         (1'b0                     ),
  .dqgt_debug          (1'b0                     ),
  .rdel_rd_cnt         (19'd64                   ),
  .dfi_error           (dfi_error                ),
  .debug_calib_ctrl    (debug_calib_ctrl         ),

  .read_wait_cnt       (read_wait_cnt            ),
  .read_data           (o_read_data              ),
  .read_valid          (read_valid               ),
  .dqs_gate_update1    (dqs_gate_update1         ),
  .dqs_gate_update2    (dqs_gate_update2         ),
  .gate_update1_done   (gate_update1_done        ),
  .gate_update2_done   (gate_update2_done        ),
  .dqs_gate_check_falling (dqs_gate_check_falling),
  
  
  .update_cal_req      (update_cal_req           ),
  .update_gate_read_flag (update_gate_read_flag  ),   

  .calib_ba            (calib_ba                 ),
  .calib_address       (calib_address            ),
  .calib_cs_n          (calib_cs_n               ),
  .calib_ras_n         (calib_ras_n              ),
  .calib_cas_n         (calib_cas_n              ),
  .calib_we_n          (calib_we_n               ),
  .calib_cke           (calib_cke                ),
  .calib_odt           (calib_odt                ),
  .calib_rst           (calib_rst                ),
  .calib_wrdata_en     (calib_wrdata_en          ),
  .calib_wrdata        (calib_wrdata             ),
  .calib_wrdata_mask   (calib_wrdata_mask        )             
);

ipsxb_ddrphy_training_ctrl_v1_0 ddrphy_training_ctrl
(
 .ddrphy_clkin               (ddrphy_clkin              ),
 .ddrphy_rst_n               (ddrphy_rst_n              ),
 .ddrphy_rst_req             (ddrphy_rst_req            ),
 .ddrphy_rst_ack             (ddrphy_rst_ack            ),
 .ddrphy_dqs_training_rstn   (ddrphy_dqs_training_rstn  )        
);

ipsxb_ddrphy_slice_top_v1_4 #(
  .MEM_ADDR_WIDTH      (MEM_ADDR_WIDTH     ),
  .MEM_BANKADDR_WIDTH  (MEM_BANK_WIDTH     ),
  .MEM_DQ_WIDTH        (MEM_DQ_WIDTH       ),
  .MEM_DQS_WIDTH       (MEM_DQS_WIDTH      ),
  .MEM_DM_WIDTH        (MEM_DM_WIDTH       ),
  .WL_EXTEND           ("FALSE"            ),
  .DM_GROUP_EN         (DM_GROUP_EN        )
) ddrphy_slice_top(                          
  .mc_rl                    (mc_rl                    ),
  .init_read_clk_ctrl       (init_read_clk_ctrl       ),                                                       
  .init_slip_step           (init_slip_step           ),                                                 
  .init_samp_position       (init_samp_position       ),                
                                           
  .ddrphy_clkin             (ddrphy_clkin             ),                       
  .ddrphy_rst_n             (ddrphy_rst_n             ),
  .logic_rstn               (logic_rstn               ),
  .ddrphy_ioclk             (ddrphy_ioclk             ), 
  .ddrphy_dqs_rst           (ddrphy_dqs_rst           ),
  .ddrphy_dqs_training_rstn (ddrphy_dqs_training_rstn ),
  .ddrphy_iodly_ctrl        (3'b000                   ),
  .ddrphy_wl_ctrl           (3'b001                   ),
                        
  .wrlvl_dqs_req            (wrlvl_dqs_req            ),                        
  .wrlvl_dqs_resp           (wrlvl_dqs_resp           ),                        
  .wrlvl_error              (wrlvl_error              ),                                 
  .man_wrlvl_dqs            (1'b0                     ),  
  .wrlvl_ck_dly_start_rst   (wrlvl_ck_dly_start_rst   ),
  .force_ck_dly_en          (force_ck_dly_en          ),
  .force_ck_dly_set_bin     (force_ck_dly_set_bin     ),
                         
  .force_read_clk_ctrl      (force_read_clk_ctrl      ),
  .gatecal_start            (gatecal_start            ),
  .gate_check_pass          (gate_check_pass          ),
  .gate_check_error         (gate_check_error         ),
  .gate_adj_done            (gate_adj_done            ),
  .gate_cal_error           (gate_cal_error           ),
  .gate_move_en             (gate_move_en             ),
  .dqs_gate_update1         (dqs_gate_update1         ),
  .dqs_gate_update2         (dqs_gate_update2         ),
  .gate_update1_done        (gate_update1_done        ),
  .gate_update2_done        (gate_update2_done        ),
  .dqs_gate_check_falling   (dqs_gate_check_falling   ),

  .rddata_cal               (rddata_cal               ),
  .rddata_check_pass        (rddata_check_pass        ),
  .read_cmd                 (read_cmd                 ),  
  .ddrphy_read_valid        (ddrphy_read_valid        ),               
                        
  .force_samp_position      (1'b0                     ),                       
  .dll_step                 (dll_step                 ), 
  .dqs_drift                (dqs_drift                ),
  .init_adj_rdel            (init_adj_rdel            ),                        
  .reinit_adj_rdel          (reinit_adj_rdel          ),
  .adj_rdel_done            (adj_rdel_done            ),                        
  .rdel_calibration         (rdel_calibration         ),                        
  .rdel_calib_done          (rdel_calib_done          ),                        
  .rdel_calib_error         (rdel_calib_error         ),                        
  .rdel_move_en             (rdel_move_en             ),                        
  .rdel_move_done           (rdel_move_done           ),                                                
                                          
  .read_valid               (read_valid               ),                        
  .o_read_data              (o_read_data              ),                      
        
  .phy_wrdata_en            (phy_wrdata_en            ),               
  .phy_wrdata_mask          (phy_wrdata_mask          ),               
  .phy_wrdata               (phy_wrdata               ),           
  .phy_cke                  (phy_cke                  ),                                              
  .phy_cs_n                 (phy_cs_n                 ),                                              
  .phy_ras_n                (phy_ras_n                ),                                              
  .phy_cas_n                (phy_cas_n                ),                                              
  .phy_we_n                 (phy_we_n                 ),                                              
  .phy_addr                 (phy_addr                 ),                                              
  .phy_ba                   (phy_ba                   ),                                              
  .phy_odt                  (phy_odt                  ),
  .phy_ck                   (phy_ck                   ),
  .phy_rst                  (phy_rst                  ),


  .mem_cs_n                 (mem_cs_n                 ),

  .mem_rst_n                (mem_rst_n                ),
  .mem_ck                   (mem_ck                   ),
  .mem_ck_n                 (mem_ck_n                 ),
  .mem_cke                  (mem_cke                  ),
  .mem_ras_n                (mem_ras_n                ),
  .mem_cas_n                (mem_cas_n                ),
  .mem_we_n                 (mem_we_n                 ),
  .mem_odt                  (mem_odt                  ),
  .mem_a                    (mem_a                    ), 
  .mem_ba                   (mem_ba                   ),  
  .mem_dqs                  (mem_dqs                  ),
  .mem_dqs_n                (mem_dqs_n                ),
  .mem_dq                   (mem_dq                   ),
  .mem_dm                   (mem_dm                   ),
  .debug_data               (debug_data               ),
  .debug_slice_state        (debug_slice_state        ),
  .ck_dly_set_bin           (ck_dly_set_bin           )
  );                                              
 
ipsxb_ddrphy_dfi_v1_4 #(
  .MEM_ADDR_WIDTH      (MEM_ADDR_WIDTH     ),
  .MEM_BANKADDR_WIDTH  (MEM_BANK_WIDTH     ),             
  .MEM_DQ_WIDTH        (MEM_DQ_WIDTH       ),
  .MEM_DQS_WIDTH       (MEM_DQS_WIDTH      ), 
  .MEM_DM_WIDTH        (MEM_DM_WIDTH       )         
) ddrphy_dfi(
  .ddrphy_clkin          (ddrphy_clkin         ),
  .ddrphy_rst_n          (ddrphy_rst_n         ),                                      
  .calib_done            (calib_done           ),
  .calib_rst             (calib_rst            ),   
  .calib_ba              (calib_ba             ),    
  .calib_address         (calib_address        ),    
  .calib_cs_n            (calib_cs_n           ),    
  .calib_ras_n           (calib_ras_n          ),    
  .calib_cas_n           (calib_cas_n          ),    
  .calib_we_n            (calib_we_n           ),    
  .calib_cke             (calib_cke            ),    
  .calib_odt             (calib_odt            ), 
  .calib_wrdata_en       (calib_wrdata_en      ),  
  .calib_wrdata          (calib_wrdata         ),    
  .calib_wrdata_mask     (calib_wrdata_mask    ), 
  .read_valid            (read_valid           ),       
  .o_read_data           (o_read_data          ),
                                               
  .ddrphy_update         (ddrphy_update        ),
  .update_cal_req        (update_cal_req       ),
  .update_done           (update_done          ),
  .ddrphy_update_done    (ddrphy_update_done   ), 
                                               
  .read_wait_cnt         (read_wait_cnt        ),
  .rd_fake_stop          (rd_fake_stop         ),
  .ddrphy_gate_update_en (ddrphy_gate_update_en),
   
  .dfi_address           (dfi_address          ),
  .dfi_bank              (dfi_bank             ),
  .dfi_cs_n              (dfi_cs_n             ),
  .dfi_cas_n             (dfi_cas_n            ),
  .dfi_ras_n             (dfi_ras_n            ),
  .dfi_we_n              (dfi_we_n             ),
  .dfi_cke               (dfi_cke              ),
  .dfi_odt               (dfi_odt              ),
  .dfi_wrdata_en         (dfi_wrdata_en        ),
  .dfi_wrdata            (dfi_wrdata           ),
  .dfi_wrdata_mask       (dfi_wrdata_mask      ),
  .dfi_rddata            (dfi_rddata           ),
  .dfi_rddata_valid      (dfi_rddata_valid     ),
  .dfi_reset_n           (dfi_reset_n          ),
  .dfi_phyupd_req        (dfi_phyupd_req       ),
  .dfi_phyupd_ack        (dfi_phyupd_ack       ),
  .dfi_init_complete     (dfi_init_complete    ),
                                               
  .read_cmd              (read_cmd             ),    
  .phy_ck                (phy_ck               ), 
  .phy_rst               (phy_rst              ),  
  .phy_addr              (phy_addr             ),
  .phy_ba                (phy_ba               ),    
  .phy_cs_n              (phy_cs_n             ),
  .phy_ras_n             (phy_ras_n            ),
  .phy_cas_n             (phy_cas_n            ),
  .phy_we_n              (phy_we_n             ),
  .phy_cke               (phy_cke              ),
  .phy_odt               (phy_odt              ), 
  .phy_wrdata_en         (phy_wrdata_en        ),
  .phy_wrdata            (phy_wrdata           ),   
  .phy_wrdata_mask       (phy_wrdata_mask      ) 
);

ipsxb_ddrphy_info_v1_0 #(
  .MEM_ADDR_WIDTH       (MEM_ADDR_WIDTH     ),
  .MEM_BANKADDR_WIDTH   (MEM_BANK_WIDTH     ),
  .MR0_DDR3             (MR0_DDR3           ),
  .MR1_DDR3             (MR1_DDR3           ),
  .MR2_DDR3             (MR2_DDR3           ),             
  .MR3_DDR3             (MR3_DDR3           )
) ddrphy_info (
  .ddrphy_clkin   (ddrphy_clkin  ),  
  .ddrphy_rst_n   (ddrphy_rst_n  ), 
  .calib_done     (calib_done    ),                    
  .phy_addr       (phy_addr      ),    
  .phy_ba         (phy_ba        ),    
  .phy_cs_n       (phy_cs_n      ),    
  .phy_cas_n      (phy_cas_n     ),    
  .phy_ras_n      (phy_ras_n     ),    
  .phy_we_n       (phy_we_n      ),    
  .phy_cke        (phy_cke       ),
  .mc_rl          (mc_rl         ),
  .mc_wl          (mc_wl         ),
  .mr0_ddr3       (mr0_ddr3      ),     
  .mr1_ddr3       (mr1_ddr3      ),     
  .mr2_ddr3       (mr2_ddr3      ),     
  .mr3_ddr3       (mr3_ddr3      ) 
);
              
endmodule   

