///////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
///////////////////////////////////////////////////////////////////////////////
//
// Library:
// Filename:
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module  ipml_hsst_rst_rx_v1_1#(
    parameter FREE_CLOCK_FREQ              = 100          , //unit is MHz, free clock  freq from GUI
    parameter CH0_RX_ENABLE                = "TRUE"       , //TRUE:lane0 RX Reset Logic used, FALSE: lane0 RX Reset Logic remove
    parameter CH1_RX_ENABLE                = "TRUE"       , //TRUE:lane1 RX Reset Logic used, FALSE: lane1 RX Reset Logic remove
    parameter CH2_RX_ENABLE                = "TRUE"       , //TRUE:lane2 RX Reset Logic used, FALSE: lane2 RX Reset Logic remove
    parameter CH3_RX_ENABLE                = "TRUE"       , //TRUE:lane3 RX Reset Logic used, FALSE: lane3 RX Reset Logic remove
    parameter CH0_MULT_LANE_MODE           = 1            , //Lane0 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    parameter CH1_MULT_LANE_MODE           = 1            , //Lane1 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    parameter CH2_MULT_LANE_MODE           = 1            , //Lane2 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    parameter CH3_MULT_LANE_MODE           = 1            , //Lane3 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    parameter CH0_RXPCS_ALIGN_TIMER        = 10000        , //Word Alignment Wait time, when match the RXPMA will be Reset
    parameter CH1_RXPCS_ALIGN_TIMER        = 10000        , //Word Alignment Wait time, when match the RXPMA will be Reset
    parameter CH2_RXPCS_ALIGN_TIMER        = 10000        , //Word Alignment Wait time, when match the RXPMA will be Reset
    parameter CH3_RXPCS_ALIGN_TIMER        = 10000        , //Word Alignment Wait time, when match the RXPMA will be Reset
    parameter PCS_CH0_BYPASS_WORD_ALIGN    = "FALSE"      , //TRUE: Lane0 Bypass Word Alignment, FALSE: Lane0 No Bypass Word Alignment
    parameter PCS_CH1_BYPASS_WORD_ALIGN    = "FALSE"      , //TRUE: Lane1 Bypass Word Alignment, FALSE: Lane1 No Bypass Word Alignment
    parameter PCS_CH2_BYPASS_WORD_ALIGN    = "FALSE"      , //TRUE: Lane2 Bypass Word Alignment, FALSE: Lane0 No Bypass Word Alignment
    parameter PCS_CH3_BYPASS_WORD_ALIGN    = "FALSE"      , //TRUE: Lane3 Bypass Word Alignment, FALSE: Lane0 No Bypass Word Alignment
    parameter PCS_CH0_BYPASS_BONDING       = "FALSE"      , //TRUE: Lane0 Bypass Channel Bonding, FALSE: Lane0 No Bypass Channel Bonding
    parameter PCS_CH1_BYPASS_BONDING       = "FALSE"      , //TRUE: Lane1 Bypass Channel Bonding, FALSE: Lane1 No Bypass Channel Bonding
    parameter PCS_CH2_BYPASS_BONDING       = "FALSE"      , //TRUE: Lane2 Bypass Channel Bonding, FALSE: Lane2 No Bypass Channel Bonding
    parameter PCS_CH3_BYPASS_BONDING       = "FALSE"      , //TRUE: Lane3 Bypass Channel Bonding, FALSE: Lane3 No Bypass Channel Bonding
    parameter PCS_CH0_BYPASS_CTC           = "FALSE"      , //TRUE: Lane0 Bypass CTC, FALSE: Lane0 No Bypass CTC
    parameter PCS_CH1_BYPASS_CTC           = "FALSE"      , //TRUE: Lane1 Bypass CTC, FALSE: Lane1 No Bypass CTC
    parameter PCS_CH2_BYPASS_CTC           = "FALSE"      , //TRUE: Lane2 Bypass CTC, FALSE: Lane2 No Bypass CTC
    parameter PCS_CH3_BYPASS_CTC           = "FALSE"      , //TRUE: Lane3 Bypass CTC, FALSE: Lane3 No Bypass CTC
    parameter LX_RX_CKDIV_0                = 0            ,
    parameter LX_RX_CKDIV_1                = 0            ,
    parameter LX_RX_CKDIV_2                = 0            ,
    parameter LX_RX_CKDIV_3                = 0            ,
    parameter CH0_RX_PLL_SEL               = 0            ,//Lane0 --> 1:PLL1  0:PLL0
    parameter CH1_RX_PLL_SEL               = 0            ,//Lane1 --> 1:PLL1  0:PLL0
    parameter CH2_RX_PLL_SEL               = 0            ,//Lane2 --> 1:PLL1  0:PLL0
    parameter CH3_RX_PLL_SEL               = 0            ,//Lane3 --> 1:PLL1  0:PLL0
    parameter PCS_RX_CLK_EXPLL_USE_CH0     = "FALSE"      ,
    parameter PCS_RX_CLK_EXPLL_USE_CH1     = "FALSE"      ,
    parameter PCS_RX_CLK_EXPLL_USE_CH2     = "FALSE"      ,
    parameter PCS_RX_CLK_EXPLL_USE_CH3     = "FALSE"
)(
    // Reset and Clock
    input  wire                   clk                     ,
    input  wire                   i_hsst_fifo_clr_0       ,
    input  wire                   i_hsst_fifo_clr_1       ,
    input  wire                   i_hsst_fifo_clr_2       ,
    input  wire                   i_hsst_fifo_clr_3       ,
    // HSST Reset Control Signal
    input  wire                   P_LANE_RST_0            ,
    input  wire                   P_LANE_RST_1            ,
    input  wire                   P_LANE_RST_2            ,
    input  wire                   P_LANE_RST_3            ,
    input  wire                   i_rxlane_rst_0          ,
    input  wire                   i_rxlane_rst_1          ,
    input  wire                   i_rxlane_rst_2          ,
    input  wire                   i_rxlane_rst_3          ,
    input  wire                   i_rx_rate_chng_0        ,
    input  wire                   i_rx_rate_chng_1        ,
    input  wire                   i_rx_rate_chng_2        ,
    input  wire                   i_rx_rate_chng_3        ,
    input  wire   [2:0]           i_rxckdiv_0             ,
    input  wire   [2:0]           i_rxckdiv_1             ,
    input  wire   [2:0]           i_rxckdiv_2             ,
    input  wire   [2:0]           i_rxckdiv_3             ,
    input  wire                   i_pcs_cb_rst_0          ,
    input  wire                   i_pcs_cb_rst_1          ,
    input  wire                   i_pcs_cb_rst_2          ,
    input  wire                   i_pcs_cb_rst_3          ,
    input  wire                   i_force_rxfsm_det_0     ,//Debug signal for loopback mode
    input  wire                   i_force_rxfsm_det_1     ,//Debug signal for loopback mode
    input  wire                   i_force_rxfsm_det_2     ,//Debug signal for loopback mode
    input  wire                   i_force_rxfsm_det_3     ,//Debug signal for loopback mode
    input  wire                   i_force_rxfsm_lsm_0     ,//Debug signal for loopback mode
    input  wire                   i_force_rxfsm_lsm_1     ,//Debug signal for loopback mode
    input  wire                   i_force_rxfsm_lsm_2     ,//Debug signal for loopback mode
    input  wire                   i_force_rxfsm_lsm_3     ,//Debug signal for loopback mode
    input  wire                   i_force_rxfsm_cdr_0     ,//Debug signal for loopback mode
    input  wire                   i_force_rxfsm_cdr_1     ,//Debug signal for loopback mode
    input  wire                   i_force_rxfsm_cdr_2     ,//Debug signal for loopback mode
    input  wire                   i_force_rxfsm_cdr_3     ,//Debug signal for loopback mode
    input  wire                   i_pll_lock_rx_0         ,
    input  wire                   i_pll_lock_rx_1         ,
    input  wire                   i_pll_lock_rx_2         ,
    input  wire                   i_pll_lock_rx_3         ,
    input  wire                   P_RX_SIGDET_STATUS_0    ,
    input  wire                   P_RX_SIGDET_STATUS_1    ,
    input  wire                   P_RX_SIGDET_STATUS_2    ,
    input  wire                   P_RX_SIGDET_STATUS_3    , 
    input  wire                   P_RX_READY_0            ,
    input  wire                   P_RX_READY_1            ,
    input  wire                   P_RX_READY_2            ,
    input  wire                   P_RX_READY_3            ,
    input  wire                   P_PCS_LSM_SYNCED_0      ,
    input  wire                   P_PCS_LSM_SYNCED_1      ,
    input  wire                   P_PCS_LSM_SYNCED_2      ,
    input  wire                   P_PCS_LSM_SYNCED_3      ,
    input  wire                   P_PCS_RX_MCB_STATUS_0   ,
    input  wire                   P_PCS_RX_MCB_STATUS_1   ,
    input  wire                   P_PCS_RX_MCB_STATUS_2   ,
    input  wire                   P_PCS_RX_MCB_STATUS_3   ,
    output wire                   P_PCS_CB_RST_0          ,
    output wire                   P_PCS_CB_RST_1          ,
    output wire                   P_PCS_CB_RST_2          ,
    output wire                   P_PCS_CB_RST_3          ,
    output wire                   P_RX_LANE_PD_0          ,
    output wire                   P_RX_LANE_PD_1          ,
    output wire                   P_RX_LANE_PD_2          ,
    output wire                   P_RX_LANE_PD_3          ,
    output wire                   P_RX_PMA_RST_0          ,
    output wire                   P_RX_PMA_RST_1          ,
    output wire                   P_RX_PMA_RST_2          ,
    output wire                   P_RX_PMA_RST_3          ,
    output wire                   P_PCS_RX_RST_0          ,
    output wire                   P_PCS_RX_RST_1          ,
    output wire                   P_PCS_RX_RST_2          ,
    output wire                   P_PCS_RX_RST_3          ,
    output wire    [2 : 0]        P_RX_RATE_0             , 
    output wire    [2 : 0]        P_RX_RATE_1             ,
    output wire    [2 : 0]        P_RX_RATE_2             ,
    output wire    [2 : 0]        P_RX_RATE_3             ,
    output wire                   o_rxlane_done_0         ,
    output wire                   o_rxlane_done_1         ,
    output wire                   o_rxlane_done_2         ,
    output wire                   o_rxlane_done_3         ,
    output wire                   o_rxckdiv_done_0        ,
    output wire                   o_rxckdiv_done_1        ,
    output wire                   o_rxckdiv_done_2        ,
    output wire                   o_rxckdiv_done_3        
);

localparam SIGDET_DEB_RISE_CNTR_WIDTH     = 12;
localparam SIGDET_DEB_RISE_CNTR_VALUE     = 4;
localparam CDR_ALIGN_DEB_RISE_CNTR_WIDTH  = 12;
`ifdef IPML_HSST_SPEEDUP_SIM
localparam CDR_ALIGN_DEB_RISE_CNTR_VALUE  = 20;
localparam PLL_LOCK_RISE_CNTR_VALUE       = 20;
`else
localparam CDR_ALIGN_DEB_RISE_CNTR_VALUE  = 2048;
localparam PLL_LOCK_RISE_CNTR_VALUE       = 2048;
`endif
localparam PLL_LOCK_RISE_CNTR_WIDTH    = 12  ;
//****************************************************************************//
//                      Internal Signal                                       //
//****************************************************************************//
wire  [4-1    :0] i_rxlane_rstn         ;
wire  [4-1    :0] i_rx_rate_chng        ;
wire  [4*3-1  :0] i_rxckdiv             ;
wire  [4-1    :0] i_pll_lock_rx         ;
wire  [4-1    :0] P_LX_SIGDET_STA       ;
wire  [4-1    :0] P_LX_CDR_ALIGN        ;
wire  [4-1    :0] P_PCS_LSM_SYNCED      ;
wire  [4-1    :0] P_PCS_RX_MCB_STATUS   ;

wire  [4-1    :0] s_rxlane_rstn         ;
wire  [4-1    :0] p_rxlane_rstn         ;
wire  [4-1    :0] s_LX_SIGDET_STA       ;
wire  [4-1    :0] s_LX_SIGDET_STA_deb   ;
wire  [4-1    :0] s_LX_CDR_ALIGN        ;
wire  [4-1    :0] s_LX_CDR_ALIGN_deb    ;
wire  [4-1    :0] s_PCS_LSM_SYNCED      ;
wire  [4-1    :0] s_P_PCS_RX_MCB_STATUS ;
wire  [4-1    :0] fifo_clr_en           ;
wire  [4-1    :0] rxlane_done           ;
wire  [4-1    :0] fifoclr_sig           ;
wire  [4-1    :0] p_force_rxfsm_det     ;
wire  [4-1    :0] p_force_rxfsm_lsm     ;
wire  [4-1    :0] p_force_rxfsm_cdr     ;
wire  [4-1    :0] p_pcs_cb_rst          ;
wire  [4-1    :0] sigdet                ;
wire  [4-1    :0] cdr_align             ;
wire  [4-1    :0] word_align            ;
wire  [4-1    :0] bonding               ;
wire  [4-1    :0] s_pll_lock_rx         ;
wire  [4-1    :0] s_pll_lock_rx_deb     ;
wire              fifoclr_sig_0         ;
wire              fifoclr_sig_1         ;
wire              fifoclr_sig_2         ;
wire              fifoclr_sig_3         ;
//****************************************************************************//
//                      Sequential and Logic                                  //
//****************************************************************************//

generate
if(CH0_MULT_LANE_MODE==4) begin:FOUR_LANE_MODE
    assign i_rxlane_rstn    = {4{~i_rxlane_rst_0 }};
    assign i_rx_rate_chng   = {4{i_rx_rate_chng_0}};
    assign i_rxckdiv        = {4{i_rxckdiv_0     }};
    assign i_pll_lock_rx    = {4{i_pll_lock_rx_0}};
    assign p_pcs_cb_rst     = {4{i_pcs_cb_rst_0}};
    assign p_force_rxfsm_det= {4{i_force_rxfsm_det_0}};
    assign p_force_rxfsm_lsm= {4{i_force_rxfsm_lsm_0}};
    assign p_force_rxfsm_cdr= {4{i_force_rxfsm_cdr_0}};
end
else if(CH0_MULT_LANE_MODE==2 && CH2_MULT_LANE_MODE==2) begin: TWO_LANE_MODE
    assign i_rxlane_rstn     = {{2{~i_rxlane_rst_2 }},{2{~i_rxlane_rst_0 }}};
    assign i_rx_rate_chng    = {{2{i_rx_rate_chng_2}},{2{i_rx_rate_chng_0}}};
    assign i_rxckdiv         = {{2{i_rxckdiv_2     }},{2{i_rxckdiv_0     }}};
    assign i_pll_lock_rx     = {{2{i_pll_lock_rx_2}},{2{i_pll_lock_rx_0}}};
    assign p_pcs_cb_rst      = {{2{i_pcs_cb_rst_2}},{2{i_pcs_cb_rst_0}}};
    assign p_force_rxfsm_det = {{2{i_force_rxfsm_det_2}},{2{i_force_rxfsm_det_0}}};
    assign p_force_rxfsm_lsm = {{2{i_force_rxfsm_lsm_2}},{2{i_force_rxfsm_lsm_0}}};
    assign p_force_rxfsm_cdr = {{2{i_force_rxfsm_cdr_2}},{2{i_force_rxfsm_cdr_0}}};
end
else if(CH0_MULT_LANE_MODE==2) begin:TWO_LANE_MODE0
    assign i_rxlane_rstn     = {~i_rxlane_rst_3 ,~i_rxlane_rst_2 ,{2{~i_rxlane_rst_0 }}};
    assign i_rx_rate_chng    = {i_rx_rate_chng_3,i_rx_rate_chng_2,{2{i_rx_rate_chng_0}}};
    assign i_rxckdiv         = {i_rxckdiv_3     ,i_rxckdiv_2     ,{2{i_rxckdiv_0     }}};
    assign i_pll_lock_rx     = {i_pll_lock_rx_3,i_pll_lock_rx_2,{2{i_pll_lock_rx_0}}};
    assign p_pcs_cb_rst      = {i_pcs_cb_rst_3,i_pcs_cb_rst_2,{2{i_pcs_cb_rst_0}}};
    assign p_force_rxfsm_det = {i_force_rxfsm_det_3,i_force_rxfsm_det_2,{2{i_force_rxfsm_det_0}}};
    assign p_force_rxfsm_lsm = {i_force_rxfsm_lsm_3,i_force_rxfsm_lsm_2,{2{i_force_rxfsm_lsm_0}}};
    assign p_force_rxfsm_cdr = {i_force_rxfsm_cdr_3,i_force_rxfsm_cdr_2,{2{i_force_rxfsm_cdr_0}}};
end
else if(CH2_MULT_LANE_MODE==2) begin:TWO_LANE_MODE1
    assign i_rxlane_rstn     = {{2{~i_rxlane_rst_2 }},~i_rxlane_rst_1 ,~i_rxlane_rst_0 };
    assign i_rx_rate_chng    = {{2{i_rx_rate_chng_2}},i_rx_rate_chng_1,i_rx_rate_chng_0};
    assign i_rxckdiv         = {{2{i_rxckdiv_2     }},i_rxckdiv_1     ,i_rxckdiv_0     };
    assign i_pll_lock_rx     = {{2{i_pll_lock_rx_2}},i_pll_lock_rx_1,i_pll_lock_rx_0};
    assign p_pcs_cb_rst      = {{2{i_pcs_cb_rst_2}},i_pcs_cb_rst_1,i_pcs_cb_rst_0};
    assign p_force_rxfsm_det = {{2{i_force_rxfsm_det_2}},i_force_rxfsm_det_1,i_force_rxfsm_det_0};
    assign p_force_rxfsm_lsm = {{2{i_force_rxfsm_lsm_2}},i_force_rxfsm_lsm_1,i_force_rxfsm_lsm_0};
    assign p_force_rxfsm_cdr = {{2{i_force_rxfsm_cdr_2}},i_force_rxfsm_cdr_1,i_force_rxfsm_cdr_0};
end
else begin:ONE_LANE_MODE
    assign i_rxlane_rstn     = {~i_rxlane_rst_3 ,~i_rxlane_rst_2 ,~i_rxlane_rst_1 ,~i_rxlane_rst_0 };
    assign i_rx_rate_chng    = {i_rx_rate_chng_3,i_rx_rate_chng_2,i_rx_rate_chng_1,i_rx_rate_chng_0};
    assign i_rxckdiv         = {i_rxckdiv_3     ,i_rxckdiv_2     ,i_rxckdiv_1     ,i_rxckdiv_0     };
    assign i_pll_lock_rx     = {i_pll_lock_rx_3,i_pll_lock_rx_2,i_pll_lock_rx_1,i_pll_lock_rx_0};
    assign p_pcs_cb_rst      = {i_pcs_cb_rst_3,i_pcs_cb_rst_2,i_pcs_cb_rst_1,i_pcs_cb_rst_0};
    assign p_force_rxfsm_det = {i_force_rxfsm_det_3,i_force_rxfsm_det_2,i_force_rxfsm_det_1,i_force_rxfsm_det_0};
    assign p_force_rxfsm_lsm = {i_force_rxfsm_lsm_3,i_force_rxfsm_lsm_2,i_force_rxfsm_lsm_1,i_force_rxfsm_lsm_0};
    assign p_force_rxfsm_cdr = {i_force_rxfsm_cdr_3,i_force_rxfsm_cdr_2,i_force_rxfsm_cdr_1,i_force_rxfsm_cdr_0};
end
endgenerate

assign P_LX_SIGDET_STA      = {P_RX_SIGDET_STATUS_3 , P_RX_SIGDET_STATUS_2 , P_RX_SIGDET_STATUS_1 , P_RX_SIGDET_STATUS_0  };
assign P_LX_CDR_ALIGN       = {P_RX_READY_3, P_RX_READY_2, P_RX_READY_1, P_RX_READY_0 };
assign P_PCS_LSM_SYNCED     = {P_PCS_LSM_SYNCED_3 , P_PCS_LSM_SYNCED_2 , P_PCS_LSM_SYNCED_1 , P_PCS_LSM_SYNCED_0  };
assign P_PCS_RX_MCB_STATUS  = {P_PCS_RX_MCB_STATUS_3 , P_PCS_RX_MCB_STATUS_2 , P_PCS_RX_MCB_STATUS_1 , P_PCS_RX_MCB_STATUS_0  };

genvar i;
generate
for(i=0; i<4; i=i+1) begin:SYNC_RXLANE
//Sync Reset signal
    ipml_hsst_rst_sync_v1_0 rxlane_rstn_sync (.clk(clk), .rst_n(i_rxlane_rstn[i]), .sig_async(1'b1), .sig_synced(s_rxlane_rstn[i]));
    
    // ALOS, CDR_ALIGN, PCS_LSM_SYNCED sync per lane
    ipml_hsst_rst_sync_v1_0 i_pll_lock_sync  (.clk(clk), .rst_n(p_rxlane_rstn[i]), .sig_async(i_pll_lock_rx[i]),       .sig_synced(s_pll_lock_rx[i]));
    ipml_hsst_rst_sync_v1_0 sigdet_sync      (.clk(clk), .rst_n(p_rxlane_rstn[i]), .sig_async(P_LX_SIGDET_STA[i]),       .sig_synced(s_LX_SIGDET_STA[i]));
    ipml_hsst_rst_sync_v1_0 cdr_align_sync   (.clk(clk), .rst_n(p_rxlane_rstn[i]), .sig_async(P_LX_CDR_ALIGN[i]),      .sig_synced(s_LX_CDR_ALIGN[i]));
    ipml_hsst_rst_sync_v1_0 word_align_sync  (.clk(clk), .rst_n(p_rxlane_rstn[i]), .sig_async(P_PCS_LSM_SYNCED[i]),    .sig_synced(s_PCS_LSM_SYNCED[i]));
    ipml_hsst_rst_sync_v1_0 bonding_sync     (.clk(clk), .rst_n(p_rxlane_rstn[i]), .sig_async(P_PCS_RX_MCB_STATUS[i]), .sig_synced(s_P_PCS_RX_MCB_STATUS[i]));
   
    // ALOS, CDR_ALIGN debounce per lane
    ipml_hsst_rst_debounce_v1_0 #(.RISE_CNTR_WIDTH(SIGDET_DEB_RISE_CNTR_WIDTH),     .RISE_CNTR_VALUE(SIGDET_DEB_RISE_CNTR_VALUE))
    sigdet_deb(.clk(clk), .rst_n(p_rxlane_rstn[i]), .signal_b(s_LX_SIGDET_STA[i]),    .signal_deb(s_LX_SIGDET_STA_deb[i]));
    
    ipml_hsst_rst_debounce_v1_0 #(.RISE_CNTR_WIDTH(CDR_ALIGN_DEB_RISE_CNTR_WIDTH),  .RISE_CNTR_VALUE(CDR_ALIGN_DEB_RISE_CNTR_VALUE))
    cdr_align_deb  (.clk(clk), .rst_n(p_rxlane_rstn[i]), .signal_b(s_LX_CDR_ALIGN[i]),   .signal_deb(s_LX_CDR_ALIGN_deb[i]));

    ipml_hsst_rst_debounce_v1_0 #(.RISE_CNTR_WIDTH(PLL_LOCK_RISE_CNTR_WIDTH),  .RISE_CNTR_VALUE(PLL_LOCK_RISE_CNTR_VALUE))
    i_pll_lock_deb (.clk(clk), .rst_n(p_rxlane_rstn[i]), .signal_b(s_pll_lock_rx[i]),   .signal_deb(s_pll_lock_rx_deb[i]));
end
endgenerate

assign p_rxlane_rstn = {~P_LANE_RST_3,~P_LANE_RST_2,~P_LANE_RST_1,~P_LANE_RST_0} & s_rxlane_rstn;
assign sigdet        = s_LX_SIGDET_STA_deb   | p_force_rxfsm_det;
assign cdr_align     = s_LX_CDR_ALIGN_deb    | p_force_rxfsm_cdr;
assign word_align    = s_PCS_LSM_SYNCED      | p_force_rxfsm_lsm;
assign bonding       = s_P_PCS_RX_MCB_STATUS | p_force_rxfsm_lsm;

//Lane 0
generate
if(CH0_RX_ENABLE=="TRUE") begin:RXLANE0_ENABLE
    ipml_hsst_rxlane_rst_fsm_v1_1#(
        .FREE_CLOCK_FREQ            (FREE_CLOCK_FREQ                ),
        .CH_MULT_LANE_MODE          (CH0_MULT_LANE_MODE             ),
        .CH_RXPCS_ALIGN_TIMER       (CH0_RXPCS_ALIGN_TIMER          ),
        .CH_BYPASS_WORD_ALIGN       (PCS_CH0_BYPASS_WORD_ALIGN      ),
        .CH_BYPASS_BONDING          (PCS_CH0_BYPASS_BONDING         ),
        .CH_BYPASS_CTC              (PCS_CH0_BYPASS_CTC             ),
        .LX_RX_CKDIV                (LX_RX_CKDIV_0                  ),
        .PCS_RX_CLK_EXPLL_USE       (PCS_RX_CLK_EXPLL_USE_CH0       )
    ) rxlane_fsm0 (
        .clk                        (clk                            ),
        .rst_n                      (p_rxlane_rstn          [0]     ),
        .fifo_clr_en                (fifo_clr_en            [0]     ),
        .i_rx_rate_chng             (i_rx_rate_chng         [0]     ),
        .i_rxckdiv                  (i_rxckdiv              [2:0]   ),
        .sigdet                     (sigdet                 [0]     ),
        .cdr_align                  (cdr_align              [0]     ),
        .word_align                 (word_align             [0]     ),
        .bonding                    (bonding                [0]     ),
        .i_pcs_cb_rst               (p_pcs_cb_rst           [0]     ),
        .i_pll_lock_rx              (s_pll_lock_rx_deb      [0]     ), 
        .P_RX_LANE_PD               (P_RX_LANE_PD_0                 ),
        .P_RX_PMA_RST               (P_RX_PMA_RST_0                 ),
        .P_PCS_RX_RST               (P_PCS_RX_RST_0                 ),
        .P_RX_RATE                  (P_RX_RATE_0                    ),
        .P_PCS_CB_RST               (P_PCS_CB_RST_0                 ),
        .o_rxckdiv_done             (o_rxckdiv_done_0               ),       
        .o_rxlane_done              (o_rxlane_done_0                ),
        .fifoclr_sig                (fifoclr_sig_0                  )
    );
end
else begin:RXLANE0_DISABLE
    assign P_RX_LANE_PD_0                  = 1'b1;
    assign P_RX_PMA_RST_0                  = 1'b1;
    assign P_PCS_RX_RST_0                  = 1'b1;
    assign P_RX_RATE_0                     = 3'b0;
    assign P_PCS_CB_RST_0                  = 1'b0;
    assign o_rxckdiv_done_0                = 1'b0; 
    assign o_rxlane_done_0                 = 1'b0;   
end
endgenerate

//Lane 1
generate
if(CH1_RX_ENABLE=="TRUE") begin:RXLANE1_ENABLE
    ipml_hsst_rxlane_rst_fsm_v1_1#(
        .FREE_CLOCK_FREQ            (FREE_CLOCK_FREQ                ),
        .CH_MULT_LANE_MODE          (CH1_MULT_LANE_MODE             ),
        .CH_RXPCS_ALIGN_TIMER       (CH1_RXPCS_ALIGN_TIMER          ),
        .CH_BYPASS_WORD_ALIGN       (PCS_CH1_BYPASS_WORD_ALIGN      ),
        .CH_BYPASS_BONDING          (PCS_CH1_BYPASS_BONDING         ),
        .CH_BYPASS_CTC              (PCS_CH1_BYPASS_CTC             ),
        .LX_RX_CKDIV                (LX_RX_CKDIV_1                  ),
        .PCS_RX_CLK_EXPLL_USE       (PCS_RX_CLK_EXPLL_USE_CH1       )
    ) rxlane_fsm1 (
        .clk                        (clk                            ),
        .rst_n                      (p_rxlane_rstn          [1]     ),
        .fifo_clr_en                (fifo_clr_en            [1]     ),
        .i_rx_rate_chng             (i_rx_rate_chng         [1]     ),
        .i_rxckdiv                  (i_rxckdiv              [5:3]   ),
        .sigdet                     (sigdet                 [1]     ),
        .cdr_align                  (cdr_align              [1]     ),
        .word_align                 (word_align             [1]     ),
        .bonding                    (bonding                [1]     ),
        .i_pcs_cb_rst               (p_pcs_cb_rst           [1]     ),
        .i_pll_lock_rx              (s_pll_lock_rx_deb      [1]     ), 
        .P_RX_LANE_PD               (P_RX_LANE_PD_1                 ),
        .P_RX_PMA_RST               (P_RX_PMA_RST_1                 ),
        .P_PCS_RX_RST               (P_PCS_RX_RST_1                 ),
        .P_RX_RATE                  (P_RX_RATE_1                    ),
        .P_PCS_CB_RST               (P_PCS_CB_RST_1                 ),
        .o_rxckdiv_done             (o_rxckdiv_done_1               ),       
        .o_rxlane_done              (o_rxlane_done_1                ),
        .fifoclr_sig                (fifoclr_sig_1                  )
    );
end
else begin:RXLANE1_DISABLE
    assign P_RX_LANE_PD_1                  = 1'b1;
    assign P_RX_PMA_RST_1                  = 1'b1;
    assign P_PCS_RX_RST_1                  = 1'b1;
    assign P_RX_RATE_1                     = 3'b0;
    assign P_PCS_CB_RST_1                  = 1'b0;
    assign o_rxckdiv_done_1                = 1'b0; 
    assign o_rxlane_done_1                 = 1'b0;   
end
endgenerate

//Lane 2
generate
if(CH2_RX_ENABLE=="TRUE") begin:RXLANE2_ENABLE
    ipml_hsst_rxlane_rst_fsm_v1_1#(
        .FREE_CLOCK_FREQ            (FREE_CLOCK_FREQ                ),
        .CH_MULT_LANE_MODE          (CH2_MULT_LANE_MODE             ),
        .CH_RXPCS_ALIGN_TIMER       (CH2_RXPCS_ALIGN_TIMER          ),
        .CH_BYPASS_WORD_ALIGN       (PCS_CH2_BYPASS_WORD_ALIGN      ),
        .CH_BYPASS_BONDING          (PCS_CH2_BYPASS_BONDING         ),
        .CH_BYPASS_CTC              (PCS_CH2_BYPASS_CTC             ),
        .LX_RX_CKDIV                (LX_RX_CKDIV_2                  ),
        .PCS_RX_CLK_EXPLL_USE       (PCS_RX_CLK_EXPLL_USE_CH2       )
    ) rxlane_fsm2 (
        .clk                        (clk                            ),
        .rst_n                      (p_rxlane_rstn          [2]     ),
        .fifo_clr_en                (fifo_clr_en            [2]     ),
        .i_rx_rate_chng             (i_rx_rate_chng         [2]     ),
        .i_rxckdiv                  (i_rxckdiv              [8:6]   ),
        .sigdet                     (sigdet                 [2]     ),
        .cdr_align                  (cdr_align              [2]     ),
        .word_align                 (word_align             [2]     ),
        .bonding                    (bonding                [2]     ),
        .i_pcs_cb_rst               (p_pcs_cb_rst           [2]     ),
        .i_pll_lock_rx              (s_pll_lock_rx_deb      [2]     ), 
        .P_RX_LANE_PD               (P_RX_LANE_PD_2                 ),
        .P_RX_PMA_RST               (P_RX_PMA_RST_2                 ),
        .P_PCS_RX_RST               (P_PCS_RX_RST_2                 ),
        .P_RX_RATE                  (P_RX_RATE_2                    ),
        .P_PCS_CB_RST               (P_PCS_CB_RST_2                 ),
        .o_rxckdiv_done             (o_rxckdiv_done_2               ),       
        .o_rxlane_done              (o_rxlane_done_2                ),
        .fifoclr_sig                (fifoclr_sig_2                  )
    );
end
else begin:RXLANE2_DISABLE
    assign P_RX_LANE_PD_2                  = 1'b1;
    assign P_RX_PMA_RST_2                  = 1'b1;
    assign P_PCS_RX_RST_2                  = 1'b1;
    assign P_RX_RATE_2                     = 3'b0;
    assign P_PCS_CB_RST_2                  = 1'b0;
    assign o_rxckdiv_done_2                = 1'b0; 
    assign o_rxlane_done_2                 = 1'b0;   
end
endgenerate

//Lane 3
generate
if(CH3_RX_ENABLE=="TRUE") begin:RXLANE3_ENABLE
    ipml_hsst_rxlane_rst_fsm_v1_1#(
        .FREE_CLOCK_FREQ            (FREE_CLOCK_FREQ                ),
        .CH_MULT_LANE_MODE          (CH3_MULT_LANE_MODE             ),
        .CH_RXPCS_ALIGN_TIMER       (CH3_RXPCS_ALIGN_TIMER          ),
        .CH_BYPASS_WORD_ALIGN       (PCS_CH3_BYPASS_WORD_ALIGN      ),
        .CH_BYPASS_BONDING          (PCS_CH3_BYPASS_BONDING         ),
        .CH_BYPASS_CTC              (PCS_CH3_BYPASS_CTC             ),
        .LX_RX_CKDIV                (LX_RX_CKDIV_3                  ),
        .PCS_RX_CLK_EXPLL_USE       (PCS_RX_CLK_EXPLL_USE_CH3       )
    ) rxlane_fsm3 (
        .clk                        (clk                            ),
        .rst_n                      (p_rxlane_rstn          [3]     ),
        .fifo_clr_en                (fifo_clr_en            [3]     ),
        .i_rx_rate_chng             (i_rx_rate_chng         [3]     ),
        .i_rxckdiv                  (i_rxckdiv              [11:9]  ),
        .sigdet                     (sigdet                 [3]     ),
        .cdr_align                  (cdr_align              [3]     ),
        .word_align                 (word_align             [3]     ),
        .bonding                    (bonding                [3]     ),
        .i_pcs_cb_rst               (p_pcs_cb_rst           [3]     ),
        .i_pll_lock_rx              (s_pll_lock_rx_deb      [3]     ), 
        .P_RX_LANE_PD               (P_RX_LANE_PD_3                 ),
        .P_RX_PMA_RST               (P_RX_PMA_RST_3                 ),
        .P_PCS_RX_RST               (P_PCS_RX_RST_3                 ),
        .P_RX_RATE                  (P_RX_RATE_3                    ),
        .P_PCS_CB_RST               (P_PCS_CB_RST_3                 ),
        .o_rxckdiv_done             (o_rxckdiv_done_3               ),       
        .o_rxlane_done              (o_rxlane_done_3                ),
        .fifoclr_sig                (fifoclr_sig_3                  )
    );
end
else begin:RXLANE3_DISABLE
    assign P_RX_LANE_PD_3                  = 1'b1;
    assign P_RX_PMA_RST_3                  = 1'b1;
    assign P_PCS_RX_RST_3                  = 1'b1;
    assign P_RX_RATE_3                     = 3'b0;
    assign P_PCS_CB_RST_3                  = 1'b0;
    assign o_rxckdiv_done_3                = 1'b0; 
    assign o_rxlane_done_3                 = 1'b0;   
end
endgenerate

assign fifoclr_sig = {fifoclr_sig_3,fifoclr_sig_2,fifoclr_sig_1,fifoclr_sig_0};

ipml_hsst_fifo_clr_v1_0#(
    .CH0_RX_ENABLE                (CH0_RX_ENABLE            ), //TRUE:lane0 RX Reset Logic used, FALSE: lane0 RX Reset Logic remove
    .CH1_RX_ENABLE                (CH1_RX_ENABLE            ), //TRUE:lane1 RX Reset Logic used, FALSE: lane1 RX Reset Logic remove
    .CH2_RX_ENABLE                (CH2_RX_ENABLE            ), //TRUE:lane2 RX Reset Logic used, FALSE: lane2 RX Reset Logic remove
    .CH3_RX_ENABLE                (CH3_RX_ENABLE            ), //TRUE:lane3 RX Reset Logic used, FALSE: lane3 RX Reset Logic remove
    .CH0_MULT_LANE_MODE           (CH0_MULT_LANE_MODE       ), //Lane0 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    .CH1_MULT_LANE_MODE           (CH1_MULT_LANE_MODE       ), //Lane1 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    .CH2_MULT_LANE_MODE           (CH2_MULT_LANE_MODE       ), //Lane2 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    .CH3_MULT_LANE_MODE           (CH3_MULT_LANE_MODE       ), //Lane3 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    .PCS_CH0_BYPASS_BONDING       (PCS_CH0_BYPASS_BONDING   ), //TRUE: Lane0 Bypass Channel Bonding, FALSE: Lane0 No Bypass Channel Bonding
    .PCS_CH1_BYPASS_BONDING       (PCS_CH1_BYPASS_BONDING   ), //TRUE: Lane1 Bypass Channel Bonding, FALSE: Lane1 No Bypass Channel Bonding
    .PCS_CH2_BYPASS_BONDING       (PCS_CH2_BYPASS_BONDING   ), //TRUE: Lane2 Bypass Channel Bonding, FALSE: Lane2 No Bypass Channel Bonding
    .PCS_CH3_BYPASS_BONDING       (PCS_CH3_BYPASS_BONDING   )  //TRUE: Lane3 Bypass Channel Bonding, FALSE: Lane3 No Bypass Channel Bonding
) fifo_clr (
    .clk                          (clk                      ),
    .rst_n                        (p_rxlane_rstn            ),
    .i_hsst_fifo_clr_0            (i_hsst_fifo_clr_0        ),
    .i_hsst_fifo_clr_1            (i_hsst_fifo_clr_1        ),
    .i_hsst_fifo_clr_2            (i_hsst_fifo_clr_2        ),
    .i_hsst_fifo_clr_3            (i_hsst_fifo_clr_3        ),
    .cdr_align                    (s_LX_CDR_ALIGN_deb       ),
    .rxlane_done                  (fifoclr_sig              ),
    .fifo_clr_en                  (fifo_clr_en              )
);

endmodule
