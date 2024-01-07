// Created by IP Generator (Version 2022.1 build 99559)



`timescale 1ns/1ps

`define DDR3

module test_ddr #(

   parameter MEM_ROW_ADDR_WIDTH   = 15         ,

   parameter MEM_COL_ADDR_WIDTH   = 10         ,

   parameter MEM_BADDR_WIDTH      = 3         ,

  parameter MEM_DQ_WIDTH         =  32         ,

  parameter MEM_DM_WIDTH         = MEM_DQ_WIDTH/8,
  parameter MEM_DQS_WIDTH        = MEM_DQ_WIDTH/8,
  parameter CTRL_ADDR_WIDTH      = MEM_ROW_ADDR_WIDTH + MEM_BADDR_WIDTH + MEM_COL_ADDR_WIDTH
)(
  input                                  ref_clk         ,
  input                                  free_clk        ,
  input                                  rst_board       ,
  output                                 pll_lock        ,           
  output                                 ddr_init_done   ,
  
  //uart
  input                                  uart_rxd        ,
  output                                 uart_txd        ,

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
  output reg                             heart_beat_led  ,
  output                                 err_flag_led    

  
);

parameter TH_1S         = 27'd50_000_000;
parameter TH_4MS        = 27'd200_000;
parameter REM_DQS_WIDTH = 4 - MEM_DQS_WIDTH;

wire                             core_clk_rst_n            ;
wire                             free_clk_rst_n            ;
wire                             core_clk                  ;
wire                             free_clk_g                ;
wire [CTRL_ADDR_WIDTH-1:0]       axi_awaddr                ;
wire                             axi_awuser_ap             ;
wire [3:0]                       axi_awuser_id             ;
wire [3:0]                       axi_awlen                 ;
wire                             axi_awready               ;
wire                             axi_awvalid               ;
wire [MEM_DQ_WIDTH*8-1:0]        axi_wdata                 ;
wire [MEM_DQ_WIDTH*8/8-1:0]      axi_wstrb                 ;
wire                             axi_wready                ;
wire [CTRL_ADDR_WIDTH-1:0]       axi_araddr                ;
wire                             axi_aruser_ap             ;
wire [3:0]                       axi_aruser_id             ;
wire [3:0]                       axi_arlen                 ;
wire                             axi_arready               ;
wire                             axi_arvalid               ;
wire [MEM_DQ_WIDTH*8-1:0]        axi_rdata                 ;
wire                             axi_rvalid                ;
wire                             resetn                    ;

reg  [26:0]                      cnt                       ;

wire [7:0]                       ck_dly_set_bin            ;
wire                             force_ck_dly_en           ;
wire [7:0]                       force_ck_dly_set_bin      ;
wire [7:0]                       dll_step                  ;     
wire                             dll_lock                  ;      

wire [1:0]                       init_read_clk_ctrl        ;                                         
wire [3:0]                       init_slip_step            ;                                                
wire                             force_read_clk_ctrl       ;    
wire                             ddrphy_gate_update_en     ;

wire [34*MEM_DQS_WIDTH-1:0]      debug_data                ;
wire [13*MEM_DQS_WIDTH-1:0]      debug_slice_state         ;
wire [34*4-1:0]                  status_debug_data         ;
wire [13*4-1:0 ]                 status_debug_slice_state  ;

wire                             rd_fake_stop              ;
wire                             bist_run_led              ;


//***********************************************************************************
//uart ctrl
wire [31:0]                      ctrl_bus_0                ;
wire [31:0]                      ctrl_bus_1                ;
wire [31:0]                      ctrl_bus_2                ;
wire [31:0]                      ctrl_bus_3                ;
wire [31:0]                      ctrl_bus_4                ;
wire [31:0]                      ctrl_bus_5                ;
wire [31:0]                      ctrl_bus_6                ;
wire [31:0]                      ctrl_bus_7                ;
wire [31:0]                      ctrl_bus_8                ;
wire [31:0]                      ctrl_bus_9                ;
wire [31:0]                      ctrl_bus_10               ;
wire [31:0]                      ctrl_bus_11               ;
wire [31:0]                      ctrl_bus_12               ;
wire [31:0]                      ctrl_bus_13               ;
wire [31:0]                      ctrl_bus_14               ;
wire [31:0]                      ctrl_bus_15               ;

wire [31:0]                      status_bus_80             ;
wire [31:0]                      status_bus_81             ;
wire [31:0]                      status_bus_82             ;
wire [31:0]                      status_bus_83             ;
wire [31:0]                      status_bus_84             ;
wire [31:0]                      status_bus_85             ;
wire [31:0]                      status_bus_86             ;
wire [31:0]                      status_bus_87             ;
wire [31:0]                      status_bus_88             ;
wire [31:0]                      status_bus_89             ;
wire [31:0]                      status_bus_8a             ;
wire [31:0]                      status_bus_8b             ;
wire [31:0]                      status_bus_8c             ;
wire [31:0]                      status_bus_8d             ;
wire [31:0]                      status_bus_8e             ;
wire [31:0]                      status_bus_8f             ;

wire [31:0]                      status_bus_90             ;
wire [31:0]                      status_bus_91             ;
wire [31:0]                      status_bus_92             ;
wire [31:0]                      status_bus_93             ;
wire [31:0]                      status_bus_94             ;
wire [31:0]                      status_bus_95             ;
wire [31:0]                      status_bus_96             ;
wire [31:0]                      status_bus_97             ;
wire [31:0]                      status_bus_98             ;
wire [31:0]                      status_bus_99             ;
wire [31:0]                      status_bus_9a             ;
wire [31:0]                      status_bus_9b             ;
wire [31:0]                      status_bus_9c             ;
wire [31:0]                      status_bus_9d             ;
wire [31:0]                      status_bus_9e             ;
wire [31:0]                      status_bus_9f             ;

wire [31:0]                      status_bus_a0             ;
wire [31:0]                      status_bus_a1             ;
wire [31:0]                      status_bus_a2             ;
wire [31:0]                      status_bus_a3             ;
wire [31:0]                      status_bus_a4             ;
wire [31:0]                      status_bus_a5             ;
wire [31:0]                      status_bus_a6             ;
wire [31:0]                      status_bus_a7             ;
wire [31:0]                      status_bus_a8             ;
wire [31:0]                      status_bus_a9             ;
wire [31:0]                      status_bus_aa             ;
wire [31:0]                      status_bus_ab             ;
wire [31:0]                      status_bus_ac             ;
wire [31:0]                      status_bus_ad             ;
wire [31:0]                      status_bus_ae             ;
wire [31:0]                      status_bus_af             ;

wire [31:0]                      status_bus_b0             ;
wire [31:0]                      status_bus_b1             ;
wire [31:0]                      status_bus_b2             ;
wire [31:0]                      status_bus_b3             ;
wire [31:0]                      status_bus_b4             ;
wire [31:0]                      status_bus_b5             ;
wire [31:0]                      status_bus_b6             ;
wire [31:0]                      status_bus_b7             ;
wire [31:0]                      status_bus_b8             ;
wire [31:0]                      status_bus_b9             ;
wire [31:0]                      status_bus_ba             ;
wire [31:0]                      status_bus_bb             ;
wire [31:0]                      status_bus_bc             ;
wire [31:0]                      status_bus_bd             ;
wire [31:0]                      status_bus_be             ;
wire [31:0]                      status_bus_bf             ;

wire [31:0]                      status_bus_c0             ;
wire [31:0]                      status_bus_c1             ;
wire [31:0]                      status_bus_c2             ;
wire [31:0]                      status_bus_c3             ;
wire [31:0]                      status_bus_c4             ;
wire [31:0]                      status_bus_c5             ;
wire [31:0]                      status_bus_c6             ;
wire [31:0]                      status_bus_c7             ;
wire [31:0]                      status_bus_c8             ;
wire [31:0]                      status_bus_c9             ;
wire [31:0]                      status_bus_ca             ;
wire [31:0]                      status_bus_cb             ;
wire [31:0]                      status_bus_cc             ;
wire [31:0]                      status_bus_cd             ;
wire [31:0]                      status_bus_ce             ;
wire [31:0]                      status_bus_cf             ;

wire [31:0]                      status_bus_d0             ;
wire [31:0]                      status_bus_d1             ;
wire [31:0]                      status_bus_d2             ;
wire [31:0]                      status_bus_d3             ;
wire [31:0]                      status_bus_d4             ;
wire [31:0]                      status_bus_d5             ;
wire [31:0]                      status_bus_d6             ;
wire [31:0]                      status_bus_d7             ;
wire [31:0]                      status_bus_d8             ;
wire [31:0]                      status_bus_d9             ;
wire [31:0]                      status_bus_da             ;
wire [31:0]                      status_bus_db             ;
wire [31:0]                      status_bus_dc             ;
wire [31:0]                      status_bus_dd             ;
wire [31:0]                      status_bus_de             ;
wire [31:0]                      status_bus_df             ;

wire [31:0]                      status_bus_e0             ;
wire [31:0]                      status_bus_e1             ;
wire [31:0]                      status_bus_e2             ;
wire [31:0]                      status_bus_e3             ;
wire [31:0]                      status_bus_e4             ;
wire [31:0]                      status_bus_e5             ;
wire [31:0]                      status_bus_e6             ;
wire [31:0]                      status_bus_e7             ;
wire [31:0]                      status_bus_e8             ;
wire [31:0]                      status_bus_e9             ;
wire [31:0]                      status_bus_ea             ;
wire [31:0]                      status_bus_eb             ;
wire [31:0]                      status_bus_ec             ;
wire [31:0]                      status_bus_ed             ;
wire [31:0]                      status_bus_ee             ;
wire [31:0]                      status_bus_ef             ;

wire [31:0]                      status_bus_f0             ;
wire [31:0]                      status_bus_f1             ;
wire [31:0]                      status_bus_f2             ;
wire [31:0]                      status_bus_f3             ;
wire [31:0]                      status_bus_f4             ;
wire [31:0]                      status_bus_f5             ;
wire [31:0]                      status_bus_f6             ;
wire [31:0]                      status_bus_f7             ;
wire [31:0]                      status_bus_f8             ;
wire [31:0]                      status_bus_f9             ;
wire [31:0]                      status_bus_fa             ;
wire [31:0]                      status_bus_fb             ;
wire [31:0]                      status_bus_fc             ;
wire [31:0]                      status_bus_fd             ;
wire [31:0]                      status_bus_fe             ;
wire [31:0]                      status_bus_ff             ;

wire [31:0]                      status_bus_lock           ;
wire                             uart_read_req             ;
wire                             uart_read_ack             ;
wire [8:0]                       uart_read_addr            ;

wire                             debug_ddr_rst_n           ;

wire [7:0]                       err_cnt                   ;
wire [3:0]                       test_main_state           ;
wire [2:0]                       test_wr_state             ;
wire [2:0]                       test_rd_state             ;
wire [21:0]                      debug_calib_ctrl          ;

wire                             manu_clear                ;
wire [15:0]                      result_bit_out            ;
wire [1:0]                       wr_mode                   ;
wire [1:0]                       data_mode                 ;
wire                             data_order                ;
wire                             insert_err                ;
wire [7:0]                       dq_inversion              ;
wire                             bist_stop                 ;
wire                             len_random_en             ;
wire [3:0]                       fix_axi_len               ;
wire [3:0]                       read_repeat_num           ;

wire [MEM_DQ_WIDTH*8-1:0]        err_data_out              ;
wire [MEM_DQ_WIDTH*8-1:0]        err_flag_out              ;
wire [MEM_DQ_WIDTH*8-1:0]        exp_data_out              ;
wire                             next_err_flag             ;
wire [MEM_DQ_WIDTH*8-1:0]        next_err_data             ;
wire [MEM_DQ_WIDTH*8-1:0]        err_data_pre              ;
wire [MEM_DQ_WIDTH*8-1:0]        err_data_aft              ;

wire [32*8-1:0]                  status_err_data_out       ;
wire [32*8-1:0]                  status_err_flag_out       ;
wire [32*8-1:0]                  status_exp_data_out       ;
wire [32*8-1:0]                  status_next_err_data      ;
wire [32*8-1:0]                  status_err_data_pre       ;
wire [32*8-1:0]                  status_err_data_aft       ;

wire [MEM_DQS_WIDTH-1:0]         update_com_val_err_flag   ;
wire [3:0]                       status_com_val_err_flag   ;

//control bus 0
parameter DFT_CTRL_BUS_0      = 32'h00_00_00_01;
assign debug_ddr_rst_n        = ctrl_bus_0[0];

//control bus 1
parameter DFT_CTRL_BUS_1      = 32'h00_00_00_00;
assign manu_clear             = ctrl_bus_1[1];

//control bus 2
parameter DFT_CTRL_BUS_2      = 32'h00_00_00_00;
assign wr_mode                = ctrl_bus_2[1:0];
assign data_mode              = ctrl_bus_2[5:4];
assign data_order             = ctrl_bus_2[8];
assign insert_err             = ctrl_bus_2[12];
assign dq_inversion           = ctrl_bus_2[23:16];
assign bist_stop              = ctrl_bus_2[24];

//control bus 3
parameter DFT_CTRL_BUS_3      = 32'h00_00_00_00;
assign force_read_clk_ctrl    = ctrl_bus_3[0];
assign init_slip_step         = ctrl_bus_3[7:4];
assign init_read_clk_ctrl     = ctrl_bus_3[9:8];

//control bus 4
parameter DFT_CTRL_BUS_4      = 32'h00_00_03_01;
assign len_random_en          = ctrl_bus_4[0];
assign fix_axi_len            = ctrl_bus_4[7:4];
assign read_repeat_num        = ctrl_bus_4[11:8];

//control bus 5
parameter DFT_CTRL_BUS_5      = 32'h00_00_00_01;
assign ddrphy_gate_update_en  = ctrl_bus_5[0];
assign rd_fake_stop           = ctrl_bus_5[4];

//control bus 6
parameter DFT_CTRL_BUS_6      = 32'h00_00_00_00;

//control bus 7
parameter DFT_CTRL_BUS_7      = 32'h00_00_00_00;

//control bus 8
parameter DFT_CTRL_BUS_8      = 32'h00_00_00_00;

//control bus 9
parameter DFT_CTRL_BUS_9      = 32'h00_00_00_00;

//control bus 10
parameter DFT_CTRL_BUS_10     = 32'h00_00_00_00;

//control bus 11
parameter DFT_CTRL_BUS_11     = 32'h00_00_00_00;

//control bus 12
parameter DFT_CTRL_BUS_12     = 32'h00_00_00_00;

//control bus 13
parameter DFT_CTRL_BUS_13     = 32'h00_00_00_00;

//control bus 14
parameter DFT_CTRL_BUS_14     = 32'h00_00_00_00;

//control bus 15
parameter DFT_CTRL_BUS_15     = 32'h00_00_01_40;
assign force_ck_dly_en        = ctrl_bus_15[0];
assign force_ck_dly_set_bin   = ctrl_bus_15[11:4];

assign status_debug_slice_state = {{13*REM_DQS_WIDTH{1'b0}},debug_slice_state };
assign status_debug_data        = {{34*REM_DQS_WIDTH{1'b0}},debug_data        };

assign status_err_flag_out      = {{64*REM_DQS_WIDTH{1'b0}},err_flag_out      };
assign status_err_data_out      = {{64*REM_DQS_WIDTH{1'b0}},err_data_out      };
assign status_exp_data_out      = {{64*REM_DQS_WIDTH{1'b0}},exp_data_out      };
assign status_next_err_data     = {{64*REM_DQS_WIDTH{1'b0}},next_err_data     };
assign status_err_data_pre      = {{64*REM_DQS_WIDTH{1'b0}},err_data_pre      };
assign status_err_data_aft      = {{64*REM_DQS_WIDTH{1'b0}},err_data_aft      };
assign status_com_val_err_flag  = {{REM_DQS_WIDTH{1'b0}},update_com_val_err_flag};


//status
assign status_bus_80 =  {15'b0,heart_beat_led,3'b0,ddr_init_done,3'b0,dll_lock,3'b0,pll_lock,3'b0,err_flag_led};
assign status_bus_81 =  {10'b0,debug_calib_ctrl};

assign status_bus_82 =  {15'b0,ck_dly_set_bin,next_err_flag,dll_step};

assign status_bus_83 =  32'b0;
assign status_bus_84 =  32'b0;
assign status_bus_85 =  32'b0;
assign status_bus_86 =  32'b0;
assign status_bus_87 =  32'b0;
assign status_bus_88 =  32'b0;
assign status_bus_89 =  32'b0;
assign status_bus_8a =  32'b0;
assign status_bus_8b =  {14'b0,test_rd_state,test_wr_state,test_main_state,err_cnt};
assign status_bus_8c =  32'b0;
assign status_bus_8d =  32'b0;
assign status_bus_8e =  32'b0;
assign status_bus_8f =  32'b0;

assign status_bus_90 =  status_debug_data[32*0 +: 32];
assign status_bus_91 =  status_debug_data[32*1 +: 32];
assign status_bus_92 =  status_debug_data[32*2 +: 32];
assign status_bus_93 =  status_debug_data[32*3 +: 32];
assign status_bus_94 =  {24'b0,status_debug_data[32*4 +: 8]};
assign status_bus_95 =  32'b0;
assign status_bus_96 =  32'b0;
assign status_bus_97 =  32'b0;
assign status_bus_98 =  32'b0;
assign status_bus_99 =  status_debug_slice_state[32*0 +: 32];
assign status_bus_9a =  {12'b0,status_debug_slice_state[32*1 +: 20]};
assign status_bus_9b =  32'b0;
assign status_bus_9c =  32'b0;

assign status_bus_9d =  status_err_flag_out[32*0 +: 32];
assign status_bus_9e =  status_err_flag_out[32*1 +: 32];
assign status_bus_9f =  status_err_flag_out[32*2 +: 32];

assign status_bus_a0 =  status_err_flag_out[32*3 +: 32];
assign status_bus_a1 =  status_err_flag_out[32*4 +: 32];
assign status_bus_a2 =  status_err_flag_out[32*5 +: 32];
assign status_bus_a3 =  status_err_flag_out[32*6 +: 32];
assign status_bus_a4 =  status_err_flag_out[32*7 +: 32];
assign status_bus_a5 =  32'b0;
assign status_bus_a6 =  32'b0;
assign status_bus_a7 =  32'b0;
assign status_bus_a8 =  32'b0;
assign status_bus_a9 =  32'b0;
assign status_bus_aa =  32'b0;
assign status_bus_ab =  32'b0;
assign status_bus_ac =  32'b0;
assign status_bus_ad =  status_err_data_out[32*0 +: 32];
assign status_bus_ae =  status_err_data_out[32*1 +: 32];
assign status_bus_af =  status_err_data_out[32*2 +: 32];
                                                         
assign status_bus_b0 =  status_err_data_out[32*3 +: 32];
assign status_bus_b1 =  status_err_data_out[32*4 +: 32];
assign status_bus_b2 =  status_err_data_out[32*5 +: 32];
assign status_bus_b3 =  status_err_data_out[32*6 +: 32];
assign status_bus_b4 =  status_err_data_out[32*7 +: 32];
assign status_bus_b5 =  32'b0;
assign status_bus_b6 =  32'b0;
assign status_bus_b7 =  32'b0;
assign status_bus_b8 =  32'b0;
assign status_bus_b9 =  32'b0;
assign status_bus_ba =  32'b0;
assign status_bus_bb =  32'b0;
assign status_bus_bc =  32'b0;
assign status_bus_bd =  status_exp_data_out[32*0 +: 32];  
assign status_bus_be =  status_exp_data_out[32*1 +: 32];
assign status_bus_bf =  status_exp_data_out[32*2 +: 32];
                                                         
assign status_bus_c0 =  status_exp_data_out[32*3 +: 32];
assign status_bus_c1 =  status_exp_data_out[32*4 +: 32];
assign status_bus_c2 =  status_exp_data_out[32*5 +: 32];
assign status_bus_c3 =  status_exp_data_out[32*6 +: 32];
assign status_bus_c4 =  status_exp_data_out[32*7 +: 32];
assign status_bus_c5 =  32'b0;
assign status_bus_c6 =  32'b0;
assign status_bus_c7 =  32'b0;
assign status_bus_c8 =  32'b0;
assign status_bus_c9 =  32'b0;
assign status_bus_ca =  32'b0;
assign status_bus_cb =  32'b0;
assign status_bus_cc =  32'b0;
assign status_bus_cd =  status_err_data_pre[32*0 +: 32]; 
assign status_bus_ce =  status_err_data_pre[32*1 +: 32];
assign status_bus_cf =  status_err_data_pre[32*2 +: 32];
                                      
assign status_bus_d0 =  status_err_data_pre[32*3 +: 32];
assign status_bus_d1 =  status_err_data_pre[32*4 +: 32];
assign status_bus_d2 =  status_err_data_pre[32*5 +: 32];
assign status_bus_d3 =  status_err_data_pre[32*6 +: 32];
assign status_bus_d4 =  status_err_data_pre[32*7 +: 32];
assign status_bus_d5 =  32'b0;
assign status_bus_d6 =  32'b0;
assign status_bus_d7 =  32'b0;
assign status_bus_d8 =  32'b0;
assign status_bus_d9 =  32'b0;
assign status_bus_da =  32'b0;
assign status_bus_db =  32'b0;
assign status_bus_dc =  32'b0;
assign status_bus_dd =  status_err_data_aft[32*0 +: 32]; 
assign status_bus_de =  status_err_data_aft[32*1 +: 32];
assign status_bus_df =  status_err_data_aft[32*2 +: 32];
                                      
assign status_bus_e0 =  status_err_data_aft[32*3 +: 32];
assign status_bus_e1 =  status_err_data_aft[32*4 +: 32];
assign status_bus_e2 =  status_err_data_aft[32*5 +: 32];
assign status_bus_e3 =  status_err_data_aft[32*6 +: 32];
assign status_bus_e4 =  status_err_data_aft[32*7 +: 32];
assign status_bus_e5 =  32'b0;
assign status_bus_e6 =  32'b0;
assign status_bus_e7 =  32'b0;
assign status_bus_e8 =  32'b0;
assign status_bus_e9 =  32'b0;
assign status_bus_ea =  32'b0;
assign status_bus_eb =  32'b0;
assign status_bus_ec =  32'b0;
assign status_bus_ed =  status_next_err_data[32*0 +: 32]; 
assign status_bus_ee =  status_next_err_data[32*1 +: 32];
assign status_bus_ef =  status_next_err_data[32*2 +: 32];

assign status_bus_f0 =  status_next_err_data[32*3 +: 32];
assign status_bus_f1 =  status_next_err_data[32*4 +: 32];
assign status_bus_f2 =  status_next_err_data[32*5 +: 32];
assign status_bus_f3 =  status_next_err_data[32*6 +: 32];
assign status_bus_f4 =  status_next_err_data[32*7 +: 32];
assign status_bus_f5 =  32'b0;
assign status_bus_f6 =  32'b0;
assign status_bus_f7 =  32'b0;
assign status_bus_f8 =  32'b0;
assign status_bus_f9 =  32'b0;
assign status_bus_fa =  32'b0;
assign status_bus_fb =  32'b0;
assign status_bus_fc =  32'b0;

assign status_bus_fd =  {28'b0,status_com_val_err_flag};
assign status_bus_fe =  32'b0;
assign status_bus_ff =  32'b0;


GTP_CLKBUFG free_clk_ibufg
(
    .CLKOUT                     (free_clk_g          ),
    .CLKIN                      (free_clk            )
);

ipsxb_rst_sync_v1_1 u_free_clk_rstn_sync(
    .clk                        (free_clk_g          ),
    .rst_n                      (rst_board           ),
    .sig_async                  (1'b1),               
    .sig_synced                 (free_clk_rst_n      )
);

ipsxb_uart_ctrl_top_32bit # (
    `ifdef IPS_DDR_SPEEDUP_SIM
    .CLK_DIV_P                  (16'd18                       ),
    `else

    .CLK_DIV_P                  (16'd72                       ), //115200bps for 50MHz clk.

    `endif
    .DFT_CTRL_BUS_0             (DFT_CTRL_BUS_0               ),
    .DFT_CTRL_BUS_1             (DFT_CTRL_BUS_1               ),
    .DFT_CTRL_BUS_2             (DFT_CTRL_BUS_2               ),
    .DFT_CTRL_BUS_3             (DFT_CTRL_BUS_3               ),
    .DFT_CTRL_BUS_4             (DFT_CTRL_BUS_4               ),
    .DFT_CTRL_BUS_5             (DFT_CTRL_BUS_5               ),
    .DFT_CTRL_BUS_6             (DFT_CTRL_BUS_6               ),
    .DFT_CTRL_BUS_7             (DFT_CTRL_BUS_7               ),
    .DFT_CTRL_BUS_8             (DFT_CTRL_BUS_8               ),
    .DFT_CTRL_BUS_9             (DFT_CTRL_BUS_9               ),
    .DFT_CTRL_BUS_10            (DFT_CTRL_BUS_10              ),
    .DFT_CTRL_BUS_11            (DFT_CTRL_BUS_11              ),
    .DFT_CTRL_BUS_12            (DFT_CTRL_BUS_12              ),
    .DFT_CTRL_BUS_13            (DFT_CTRL_BUS_13              ),
    .DFT_CTRL_BUS_14            (DFT_CTRL_BUS_14              ),
    .DFT_CTRL_BUS_15            (DFT_CTRL_BUS_15              )
) u_ipsxb_uart_ctrl (
    .rst_n                      (free_clk_rst_n               ),
    .clk                        (free_clk_g                   ),

    .txd                        (uart_txd                     ),
    .rxd                        (uart_rxd                     ),

    .read_req                   (uart_read_req                ),
    .read_ack                   (uart_read_ack                ),
    .uart_rd_addr               (uart_read_addr               ),

    .ctrl_bus_0                 (ctrl_bus_0                   ),
    .ctrl_bus_1                 (ctrl_bus_1                   ),
    .ctrl_bus_2                 (ctrl_bus_2                   ),
    .ctrl_bus_3                 (ctrl_bus_3                   ),
    .ctrl_bus_4                 (ctrl_bus_4                   ),
    .ctrl_bus_5                 (ctrl_bus_5                   ),
    .ctrl_bus_6                 (ctrl_bus_6                   ),
    .ctrl_bus_7                 (ctrl_bus_7                   ),
    .ctrl_bus_8                 (ctrl_bus_8                   ),
    .ctrl_bus_9                 (ctrl_bus_9                   ),
    .ctrl_bus_10                (ctrl_bus_10                  ),
    .ctrl_bus_11                (ctrl_bus_11                  ),
    .ctrl_bus_12                (ctrl_bus_12                  ),
    .ctrl_bus_13                (ctrl_bus_13                  ),
    .ctrl_bus_14                (ctrl_bus_14                  ),
    .ctrl_bus_15                (ctrl_bus_15                  ),

    .status_bus                 (status_bus_lock              )
);

uart_rd_lock u_uart_rd_lock
(
    .core_clk                   (free_clk_g                   ),
    .core_rst_n                 (free_clk_rst_n               ),

    .uart_read_req              (uart_read_req                ),
    .uart_read_ack              (uart_read_ack                ),
    .uart_read_addr             (uart_read_addr               ),

    .status_bus_80              (status_bus_80                ),
    .status_bus_81              (status_bus_81                ),
    .status_bus_82              (status_bus_82                ),
    .status_bus_83              (status_bus_83                ),
    .status_bus_84              (status_bus_84                ),
    .status_bus_85              (status_bus_85                ),
    .status_bus_86              (status_bus_86                ),
    .status_bus_87              (status_bus_87                ),
    .status_bus_88              (status_bus_88                ),
    .status_bus_89              (status_bus_89                ),
    .status_bus_8a              (status_bus_8a                ),
    .status_bus_8b              (status_bus_8b                ),
    .status_bus_8c              (status_bus_8c                ),
    .status_bus_8d              (status_bus_8d                ),
    .status_bus_8e              (status_bus_8e                ),
    .status_bus_8f              (status_bus_8f                ),

    .status_bus_90              (status_bus_90                ),
    .status_bus_91              (status_bus_91                ),
    .status_bus_92              (status_bus_92                ),
    .status_bus_93              (status_bus_93                ),
    .status_bus_94              (status_bus_94                ),
    .status_bus_95              (status_bus_95                ),
    .status_bus_96              (status_bus_96                ),
    .status_bus_97              (status_bus_97                ),
    .status_bus_98              (status_bus_98                ),
    .status_bus_99              (status_bus_99                ),
    .status_bus_9a              (status_bus_9a                ),
    .status_bus_9b              (status_bus_9b                ),
    .status_bus_9c              (status_bus_9c                ),
    .status_bus_9d              (status_bus_9d                ),
    .status_bus_9e              (status_bus_9e                ),
    .status_bus_9f              (status_bus_9f                ),

    .status_bus_a0              (status_bus_a0                ),
    .status_bus_a1              (status_bus_a1                ),
    .status_bus_a2              (status_bus_a2                ),
    .status_bus_a3              (status_bus_a3                ),
    .status_bus_a4              (status_bus_a4                ),
    .status_bus_a5              (status_bus_a5                ),
    .status_bus_a6              (status_bus_a6                ),
    .status_bus_a7              (status_bus_a7                ),
    .status_bus_a8              (status_bus_a8                ),
    .status_bus_a9              (status_bus_a9                ),
    .status_bus_aa              (status_bus_aa                ),
    .status_bus_ab              (status_bus_ab                ),
    .status_bus_ac              (status_bus_ac                ),
    .status_bus_ad              (status_bus_ad                ),
    .status_bus_ae              (status_bus_ae                ),
    .status_bus_af              (status_bus_af                ),

    .status_bus_b0              (status_bus_b0                ),
    .status_bus_b1              (status_bus_b1                ),
    .status_bus_b2              (status_bus_b2                ),
    .status_bus_b3              (status_bus_b3                ),
    .status_bus_b4              (status_bus_b4                ),
    .status_bus_b5              (status_bus_b5                ),
    .status_bus_b6              (status_bus_b6                ),
    .status_bus_b7              (status_bus_b7                ),
    .status_bus_b8              (status_bus_b8                ),
    .status_bus_b9              (status_bus_b9                ),
    .status_bus_ba              (status_bus_ba                ),
    .status_bus_bb              (status_bus_bb                ),
    .status_bus_bc              (status_bus_bc                ),
    .status_bus_bd              (status_bus_bd                ),
    .status_bus_be              (status_bus_be                ),
    .status_bus_bf              (status_bus_bf                ),

    .status_bus_c0              (status_bus_c0                ),
    .status_bus_c1              (status_bus_c1                ),
    .status_bus_c2              (status_bus_c2                ),
    .status_bus_c3              (status_bus_c3                ),
    .status_bus_c4              (status_bus_c4                ),
    .status_bus_c5              (status_bus_c5                ),
    .status_bus_c6              (status_bus_c6                ),
    .status_bus_c7              (status_bus_c7                ),
    .status_bus_c8              (status_bus_c8                ),
    .status_bus_c9              (status_bus_c9                ),
    .status_bus_ca              (status_bus_ca                ),
    .status_bus_cb              (status_bus_cb                ),
    .status_bus_cc              (status_bus_cc                ),
    .status_bus_cd              (status_bus_cd                ),
    .status_bus_ce              (status_bus_ce                ),
    .status_bus_cf              (status_bus_cf                ),

    .status_bus_d0              (status_bus_d0                ),
    .status_bus_d1              (status_bus_d1                ),
    .status_bus_d2              (status_bus_d2                ),
    .status_bus_d3              (status_bus_d3                ),
    .status_bus_d4              (status_bus_d4                ),
    .status_bus_d5              (status_bus_d5                ),
    .status_bus_d6              (status_bus_d6                ),
    .status_bus_d7              (status_bus_d7                ),
    .status_bus_d8              (status_bus_d8                ),
    .status_bus_d9              (status_bus_d9                ),
    .status_bus_da              (status_bus_da                ),
    .status_bus_db              (status_bus_db                ),
    .status_bus_dc              (status_bus_dc                ),
    .status_bus_dd              (status_bus_dd                ),
    .status_bus_de              (status_bus_de                ),
    .status_bus_df              (status_bus_df                ),

    .status_bus_e0              (status_bus_e0                ),
    .status_bus_e1              (status_bus_e1                ),
    .status_bus_e2              (status_bus_e2                ),
    .status_bus_e3              (status_bus_e3                ),
    .status_bus_e4              (status_bus_e4                ),
    .status_bus_e5              (status_bus_e5                ),
    .status_bus_e6              (status_bus_e6                ),
    .status_bus_e7              (status_bus_e7                ),
    .status_bus_e8              (status_bus_e8                ),
    .status_bus_e9              (status_bus_e9                ),
    .status_bus_ea              (status_bus_ea                ),
    .status_bus_eb              (status_bus_eb                ),
    .status_bus_ec              (status_bus_ec                ),
    .status_bus_ed              (status_bus_ed                ),
    .status_bus_ee              (status_bus_ee                ),
    .status_bus_ef              (status_bus_ef                ),

    .status_bus_f0              (status_bus_f0                ),
    .status_bus_f1              (status_bus_f1                ),
    .status_bus_f2              (status_bus_f2                ),
    .status_bus_f3              (status_bus_f3                ),
    .status_bus_f4              (status_bus_f4                ),
    .status_bus_f5              (status_bus_f5                ),
    .status_bus_f6              (status_bus_f6                ),
    .status_bus_f7              (status_bus_f7                ),
    .status_bus_f8              (status_bus_f8                ),
    .status_bus_f9              (status_bus_f9                ),
    .status_bus_fa              (status_bus_fa                ),
    .status_bus_fb              (status_bus_fb                ),
    .status_bus_fc              (status_bus_fc                ),
    .status_bus_fd              (status_bus_fd                ),
    .status_bus_fe              (status_bus_fe                ),
    .status_bus_ff              (status_bus_ff                ),

    .status_bus_lock            (status_bus_lock              )
);

//***********************************************************************************

assign resetn = debug_ddr_rst_n & rst_board ;

//***********************************************************************************

`ifdef SIMULATION
parameter MEM_SPACE_AW = 13; //to reduce simulation time
`else
parameter MEM_SPACE_AW = CTRL_ADDR_WIDTH;
`endif

//***********************************************************************************
reg [2:0]   rst_board_dly;  
reg [26:0]  cnt_rst   ;
reg         rst_board_rg = 1'b1;

always @(posedge ref_clk)
begin
  rst_board_dly <= {rst_board_dly[1:0],rst_board};    
end

always @(posedge ref_clk)
begin
  if (!rst_board_dly[2] && rst_board_dly[1]) begin
    cnt_rst <= 0;
    rst_board_rg <= 1'b1;
  end 
  else begin
  	if(!rst_board_dly[2])begin  		
  		if(cnt_rst == TH_4MS) begin
  			rst_board_rg <= 1'b0;
  		end 
  		else begin
  			cnt_rst <= cnt_rst + 1'b1;
  		end 
  	end 
  end      
end

always@(posedge core_clk or negedge resetn)
begin
   if (!resetn)
      cnt <= 27'd0;
   else if ( cnt >= TH_1S )
      cnt <= 27'd0;
   else
      cnt <= cnt + 27'd1;
end

always @(posedge core_clk or negedge resetn)
begin
   if (!resetn)
      heart_beat_led <= 1'd1;
   else if ( cnt >= TH_1S )
      heart_beat_led <= ~heart_beat_led;
end

ipsxb_rst_sync_v1_1 u_core_clk_rst_sync(
    .clk                        (core_clk        ),
    .rst_n                      (resetn          ),
    .sig_async                  (1'b1),
    .sig_synced                 (core_clk_rst_n  )
);

ddr_test  #
  (
   //***************************************************************************
   // The following parameters are Memory Feature
   //***************************************************************************
   .MEM_ROW_WIDTH          (MEM_ROW_ADDR_WIDTH),     
   .MEM_COLUMN_WIDTH       (MEM_COL_ADDR_WIDTH),     
   .MEM_BANK_WIDTH         (MEM_BADDR_WIDTH   ),     
   .MEM_DQ_WIDTH           (MEM_DQ_WIDTH      ),     
   .MEM_DM_WIDTH           (MEM_DM_WIDTH      ),     
   .MEM_DQS_WIDTH          (MEM_DQS_WIDTH     ),     
   .CTRL_ADDR_WIDTH        (CTRL_ADDR_WIDTH   )     
  )

  I_ipsxb_ddr_top(
   .ref_clk                (ref_clk                ),
   .resetn                 (resetn                 ),
   .ddr_init_done          (ddr_init_done          ),
   .ddrphy_clkin           (core_clk               ),
   .pll_lock               (pll_lock               ), 

   .axi_awaddr             (axi_awaddr             ),
   .axi_awuser_ap          (axi_awuser_ap          ),
   .axi_awuser_id          (axi_awuser_id          ),
   .axi_awlen              (axi_awlen              ),
   .axi_awready            (axi_awready            ),
   .axi_awvalid            (axi_awvalid            ),

   .axi_wdata              (axi_wdata              ),
   .axi_wstrb              (axi_wstrb              ),
   .axi_wready             (axi_wready             ),
   .axi_wusero_id          (                       ),
   .axi_wusero_last        (                       ),

   .axi_araddr             (axi_araddr             ),
   .axi_aruser_ap          (axi_aruser_ap          ),
   .axi_aruser_id          (axi_aruser_id          ),
   .axi_arlen              (axi_arlen              ),
   .axi_arready            (axi_arready            ),
   .axi_arvalid            (axi_arvalid            ),

   .axi_rdata              (axi_rdata              ),
   .axi_rid                (                       ),
   .axi_rlast              (                       ),
   .axi_rvalid             (axi_rvalid             ),

   .apb_clk                (1'b0                   ),
   .apb_rst_n              (1'b0                   ),
   .apb_sel                (1'b0                   ),
   .apb_enable             (1'b0                   ),
   .apb_addr               (8'd0                   ),
   .apb_write              (1'b0                   ),
   .apb_ready              (                       ),
   .apb_wdata              (16'd0                  ),
   .apb_rdata              (                       ),
   .apb_int                (                       ),
   .debug_data             (debug_data             ),
   .debug_slice_state      (debug_slice_state      ),
   .debug_calib_ctrl       (debug_calib_ctrl       ),
   .ck_dly_set_bin         (ck_dly_set_bin         ),
   .force_ck_dly_en        (force_ck_dly_en        ),
   .force_ck_dly_set_bin   (force_ck_dly_set_bin   ),
   .dll_step               (dll_step               ),
   .dll_lock               (dll_lock               ),
   .init_read_clk_ctrl     (init_read_clk_ctrl     ),                                                       
   .init_slip_step         (init_slip_step         ), 
   .force_read_clk_ctrl    (force_read_clk_ctrl    ),  
   .ddrphy_gate_update_en  (ddrphy_gate_update_en  ),
   .update_com_val_err_flag (update_com_val_err_flag),
   .rd_fake_stop           (rd_fake_stop           ),

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


//***********************************************************************************

axi_bist_top_v1_0 #(
  .CTRL_ADDR_WIDTH     (CTRL_ADDR_WIDTH),
  .MEM_DQ_WIDTH        (MEM_DQ_WIDTH   ),
  .MEM_SPACE_AW        (MEM_SPACE_AW   )
) u_bist_top (
  .core_clk           (core_clk        ),
  .core_clk_rst_n     (core_clk_rst_n  ),
  .wr_mode            (wr_mode         ),
  .data_mode          (data_mode       ),
  .len_random_en      (len_random_en   ),
  .fix_axi_len        (fix_axi_len     ),
  .ddrc_init_done     (ddr_init_done   ),
  .read_repeat_num    (read_repeat_num ),
  .bist_stop          (bist_stop       ),
  .data_order         (data_order      ),
  .dq_inversion       (dq_inversion    ),
  .insert_err         (insert_err      ),
  .manu_clear         (manu_clear      ),
  .bist_run_led       (bist_run_led    ),
  .test_main_state    (test_main_state ),
  .axi_awaddr         (axi_awaddr      ),
  .axi_awuser_ap      (axi_awuser_ap   ),
  .axi_awuser_id      (axi_awuser_id   ),
  .axi_awlen          (axi_awlen       ),
  .axi_awready        (axi_awready     ),
  .axi_awvalid        (axi_awvalid     ),
  .axi_wdata          (axi_wdata       ),
  .axi_wstrb          (axi_wstrb       ),
  .axi_wready         (axi_wready      ),
  .test_wr_state      (test_wr_state   ),
  .axi_araddr         (axi_araddr      ),
  .axi_aruser_ap      (axi_aruser_ap   ),
  .axi_aruser_id      (axi_aruser_id   ),
  .axi_arlen          (axi_arlen       ),
  .axi_arready        (axi_arready     ),
  .axi_arvalid        (axi_arvalid     ),
  .axi_rdata          (axi_rdata       ),
  .axi_rvalid         (axi_rvalid      ),
  .err_cnt            (err_cnt         ),
  .err_flag_led       (err_flag_led    ),
  
  .err_data_out       (err_data_out    ),
  .err_flag_out       (err_flag_out    ),
  .exp_data_out       (exp_data_out    ),
  .next_err_flag      (next_err_flag   ),
  .next_err_data      (next_err_data   ),
  .err_data_pre       (err_data_pre    ),
  .err_data_aft       (err_data_aft    ),

  .result_bit_out     (result_bit_out  ),
  .test_rd_state      (test_rd_state   )
);

endmodule

