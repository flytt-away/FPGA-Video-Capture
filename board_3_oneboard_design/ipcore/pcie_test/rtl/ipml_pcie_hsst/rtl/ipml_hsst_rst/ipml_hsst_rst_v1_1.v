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
module  ipml_hsst_rst_v1_1#(
    parameter INNER_RST_EN                 = "TRUE"       , //TRUE: HSST Reset Auto Control, FALSE: HSST Reset Control by User
    parameter FREE_CLOCK_FREQ              = 100          , //Unit is MHz, free clock  freq from GUI Freq: 0~200MHz
    parameter CH0_TX_ENABLE                = "TRUE"       , //TRUE:lane0 TX Reset Logic used, FALSE: lane0 TX Reset Logic remove
    parameter CH1_TX_ENABLE                = "TRUE"       , //TRUE:lane1 TX Reset Logic used, FALSE: lane1 TX Reset Logic remove
    parameter CH2_TX_ENABLE                = "TRUE"       , //TRUE:lane2 TX Reset Logic used, FALSE: lane2 TX Reset Logic remove
    parameter CH3_TX_ENABLE                = "TRUE"       , //TRUE:lane3 TX Reset Logic used, FALSE: lane3 TX Reset Logic remove
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
    parameter PCS_CH2_BYPASS_WORD_ALIGN    = "FALSE"      , //TRUE: Lane2 Bypass Word Alignment, FALSE: Lane2 No Bypass Word Alignment
    parameter PCS_CH3_BYPASS_WORD_ALIGN    = "FALSE"      , //TRUE: Lane3 Bypass Word Alignment, FALSE: Lane3 No Bypass Word Alignment
    parameter PCS_CH0_BYPASS_BONDING       = "FALSE"      , //TRUE: Lane0 Bypass Channel Bonding, FALSE: Lane0 No Bypass Channel Bonding
    parameter PCS_CH1_BYPASS_BONDING       = "FALSE"      , //TRUE: Lane1 Bypass Channel Bonding, FALSE: Lane1 No Bypass Channel Bonding
    parameter PCS_CH2_BYPASS_BONDING       = "FALSE"      , //TRUE: Lane2 Bypass Channel Bonding, FALSE: Lane2 No Bypass Channel Bonding
    parameter PCS_CH3_BYPASS_BONDING       = "FALSE"      , //TRUE: Lane3 Bypass Channel Bonding, FALSE: Lane3 No Bypass Channel Bonding
    parameter PCS_CH0_BYPASS_CTC           = "TRUE"       , //TRUE: Lane0 Bypass CTC, FALSE: Lane0 No Bypass CTC
    parameter PCS_CH1_BYPASS_CTC           = "TRUE"       , //TRUE: Lane1 Bypass CTC, FALSE: Lane1 No Bypass CTC
    parameter PCS_CH2_BYPASS_CTC           = "TRUE"       , //TRUE: Lane2 Bypass CTC, FALSE: Lane2 No Bypass CTC
    parameter PCS_CH3_BYPASS_CTC           = "TRUE"       , //TRUE: Lane3 Bypass CTC, FALSE: Lane3 No Bypass CTC
    parameter P_LX_TX_CKDIV_0              =  0           , //TX initial clock division value
    parameter P_LX_TX_CKDIV_1              =  0           , //TX initial clock division value
    parameter P_LX_TX_CKDIV_2              =  0           , //TX initial clock division value
    parameter P_LX_TX_CKDIV_3              =  0           , //TX initial clock division value
    parameter LX_RX_CKDIV_0                =  0           , //RX initial clock division value
    parameter LX_RX_CKDIV_1                =  0           , //RX initial clock division value
    parameter LX_RX_CKDIV_2                =  0           , //RX initial clock division value
    parameter LX_RX_CKDIV_3                =  0           , //RX initial clock division value
    parameter CH0_TX_PLL_SEL               =  0           ,//Lane0 --> 1:PLL1  0:PLL0
    parameter CH1_TX_PLL_SEL               =  0           ,//Lane1 --> 1:PLL1  0:PLL0
    parameter CH2_TX_PLL_SEL               =  0           ,//Lane2 --> 1:PLL1  0:PLL0
    parameter CH3_TX_PLL_SEL               =  0           ,//Lane3 --> 1:PLL1  0:PLL0
    parameter CH0_RX_PLL_SEL               =  0           ,//Lane0 --> 1:PLL1  0:PLL0
    parameter CH1_RX_PLL_SEL               =  0           ,//Lane1 --> 1:PLL1  0:PLL0
    parameter CH2_RX_PLL_SEL               =  0           ,//Lane2 --> 1:PLL1  0:PLL0
    parameter CH3_RX_PLL_SEL               =  0           ,//Lane3 --> 1:PLL1  0:PLL0
    parameter PLL_NUBER                    =  1           ,
    parameter PCS_TX_CLK_EXPLL_USE_CH0     =  "FALSE"     ,//TRUE: Fabric  PLL USE
    parameter PCS_TX_CLK_EXPLL_USE_CH1     =  "FALSE"     ,
    parameter PCS_TX_CLK_EXPLL_USE_CH2     =  "FALSE"     ,
    parameter PCS_TX_CLK_EXPLL_USE_CH3     =  "FALSE"     ,
    parameter PCS_RX_CLK_EXPLL_USE_CH0     =  "FALSE"     ,
    parameter PCS_RX_CLK_EXPLL_USE_CH1     =  "FALSE"     ,
    parameter PCS_RX_CLK_EXPLL_USE_CH2     =  "FALSE"     ,
    parameter PCS_RX_CLK_EXPLL_USE_CH3     =  "FALSE"
)(
    //BOTH NEED
    input  wire                   i_pll_lock_tx_0         ,
    input  wire                   i_pll_lock_tx_1         ,
    input  wire                   i_pll_lock_tx_2         ,
    input  wire                   i_pll_lock_tx_3         ,
    input  wire                   i_pll_lock_rx_0         ,
    input  wire                   i_pll_lock_rx_1         ,
    input  wire                   i_pll_lock_rx_2         ,
    input  wire                   i_pll_lock_rx_3         ,
    //--- User Side ---
    //INNER_RST_EN is TRUE 
    input  wire                   i_free_clk              ,
    input  wire                   i_pll_rst_0             ,
    input  wire                   i_pll_rst_1             ,
    input  wire                   i_wtchdg_clr_0          ,
    input  wire                   i_wtchdg_clr_1          ,
    input  wire                   i_lane_pd_0             ,
    input  wire                   i_lane_pd_1             ,
    input  wire                   i_lane_pd_2             ,
    input  wire                   i_lane_pd_3             ,
    input  wire                   i_txlane_rst_0          ,
    input  wire                   i_txlane_rst_1          ,
    input  wire                   i_txlane_rst_2          ,
    input  wire                   i_txlane_rst_3          ,
    input  wire                   i_rxlane_rst_0          ,
    input  wire                   i_rxlane_rst_1          ,
    input  wire                   i_rxlane_rst_2          ,
    input  wire                   i_rxlane_rst_3          ,
    input  wire                   i_tx_rate_chng_0        ,
    input  wire                   i_tx_rate_chng_1        ,
    input  wire                   i_tx_rate_chng_2        ,
    input  wire                   i_tx_rate_chng_3        ,
    input  wire                   i_rx_rate_chng_0        ,
    input  wire                   i_rx_rate_chng_1        ,
    input  wire                   i_rx_rate_chng_2        ,
    input  wire                   i_rx_rate_chng_3        ,
    input  wire    [1 : 0]        i_txckdiv_0             ,
    input  wire    [1 : 0]        i_txckdiv_1             ,
    input  wire    [1 : 0]        i_txckdiv_2             ,
    input  wire    [1 : 0]        i_txckdiv_3             ,
    input  wire    [1 : 0]        i_rxckdiv_0             ,
    input  wire    [1 : 0]        i_rxckdiv_1             ,
    input  wire    [1 : 0]        i_rxckdiv_2             ,
    input  wire    [1 : 0]        i_rxckdiv_3             ,
    input  wire                   i_pcs_cb_rst_0          ,
    input  wire                   i_pcs_cb_rst_1          ,
    input  wire                   i_pcs_cb_rst_2          ,
    input  wire                   i_pcs_cb_rst_3          ,
    input  wire                   i_hsst_fifo_clr_0       ,
    input  wire                   i_hsst_fifo_clr_1       ,
    input  wire                   i_hsst_fifo_clr_2       ,
    input  wire                   i_hsst_fifo_clr_3       ,
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
    output wire    [1 : 0]        o_wtchdg_st_0           ,
    output wire    [1 : 0]        o_wtchdg_st_1           ,
    output wire                   o_pll_done_0            ,
    output wire                   o_pll_done_1            ,
    output wire                   o_txlane_done_0         ,
    output wire                   o_txlane_done_1         ,
    output wire                   o_txlane_done_2         ,
    output wire                   o_txlane_done_3         ,
    output wire                   o_tx_ckdiv_done_0       ,
    output wire                   o_tx_ckdiv_done_1       ,
    output wire                   o_tx_ckdiv_done_2       ,
    output wire                   o_tx_ckdiv_done_3       ,
    output wire                   o_rxlane_done_0         ,
    output wire                   o_rxlane_done_1         ,
    output wire                   o_rxlane_done_2         ,
    output wire                   o_rxlane_done_3         ,
    output wire                   o_rx_ckdiv_done_0       ,
    output wire                   o_rx_ckdiv_done_1       ,
    output wire                   o_rx_ckdiv_done_2       ,
    output wire                   o_rx_ckdiv_done_3       ,
    //INNER_RST_EN is FALSE
    input  wire                   i_f_pllpowerdown_0        ,
    input  wire                   i_f_pllpowerdown_1        ,
    input  wire                   i_f_pll_rst_0             ,
    input  wire                   i_f_pll_rst_1             ,
    input  wire                   i_f_lane_sync_0           ,
    input  wire                   i_f_lane_sync_1           ,
    input  wire                   i_f_lane_sync_en_0        ,
    input  wire                   i_f_lane_sync_en_1        ,
    input  wire                   i_f_rate_change_tclk_on_0 ,
    input  wire                   i_f_rate_change_tclk_on_1 ,
    input  wire                   i_f_tx_lane_pd_0          ,
    input  wire                   i_f_tx_lane_pd_1          ,
    input  wire                   i_f_tx_lane_pd_2          ,
    input  wire                   i_f_tx_lane_pd_3          ,
    input  wire                   i_f_tx_pma_rst_0          ,
    input  wire                   i_f_tx_pma_rst_1          ,
    input  wire                   i_f_tx_pma_rst_2          ,
    input  wire                   i_f_tx_pma_rst_3          ,
    input  wire    [1 : 0]        i_f_tx_ckdiv_0            ,
    input  wire    [1 : 0]        i_f_tx_ckdiv_1            ,
    input  wire    [1 : 0]        i_f_tx_ckdiv_2            ,
    input  wire    [1 : 0]        i_f_tx_ckdiv_3            ,
    input  wire                   i_f_pcs_tx_rst_0          ,
    input  wire                   i_f_pcs_tx_rst_1          ,
    input  wire                   i_f_pcs_tx_rst_2          ,
    input  wire                   i_f_pcs_tx_rst_3          ,
    input  wire                   i_f_lane_pd_0             ,
    input  wire                   i_f_lane_pd_1             ,
    input  wire                   i_f_lane_pd_2             ,
    input  wire                   i_f_lane_pd_3             ,
    input  wire                   i_f_lane_rst_0            ,
    input  wire                   i_f_lane_rst_1            ,
    input  wire                   i_f_lane_rst_2            ,
    input  wire                   i_f_lane_rst_3            ,
    input  wire                   i_f_rx_lane_pd_0          ,
    input  wire                   i_f_rx_lane_pd_1          ,
    input  wire                   i_f_rx_lane_pd_2          ,
    input  wire                   i_f_rx_lane_pd_3          ,
    input  wire                   i_f_rx_pma_rst_0          ,
    input  wire                   i_f_rx_pma_rst_1          ,
    input  wire                   i_f_rx_pma_rst_2          ,
    input  wire                   i_f_rx_pma_rst_3          ,
    input  wire                   i_f_pcs_rx_rst_0          ,
    input  wire                   i_f_pcs_rx_rst_1          ,
    input  wire                   i_f_pcs_rx_rst_2          ,
    input  wire                   i_f_pcs_rx_rst_3          ,
    input  wire    [1 : 0]        i_f_lx_rx_ckdiv_0         ,
    input  wire    [1 : 0]        i_f_lx_rx_ckdiv_1         ,
    input  wire    [1 : 0]        i_f_lx_rx_ckdiv_2         ,
    input  wire    [1 : 0]        i_f_lx_rx_ckdiv_3         ,
    input  wire                   i_f_pcs_cb_rst_0          ,
    input  wire                   i_f_pcs_cb_rst_1          ,
    input  wire                   i_f_pcs_cb_rst_2          ,
    input  wire                   i_f_pcs_cb_rst_3          ,
    
    //--- Hsst Side ---
    input  wire                   P_PLL_READY_0           ,
    input  wire                   P_PLL_READY_1           ,
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
    output wire                   P_PLLPOWERDOWN_0        ,
    output wire                   P_PLLPOWERDOWN_1        ,
    output wire                   P_PLL_RST_0             ,
    output wire                   P_PLL_RST_1             ,
    output wire                   P_LANE_SYNC_0           ,
    output wire                   P_LANE_SYNC_1           ,
    output wire                   P_LANE_SYNC_EN_0        ,
    output wire                   P_LANE_SYNC_EN_1        ,
    output wire                   P_RATE_CHANGE_TCLK_ON_0 ,
    output wire                   P_RATE_CHANGE_TCLK_ON_1 ,
    output wire                   P_TX_LANE_PD_0          ,
    output wire                   P_TX_LANE_PD_1          ,
    output wire                   P_TX_LANE_PD_2          ,
    output wire                   P_TX_LANE_PD_3          ,
    output wire    [2 : 0]        P_TX_RATE_0             ,
    output wire    [2 : 0]        P_TX_RATE_1             ,
    output wire    [2 : 0]        P_TX_RATE_2             ,
    output wire    [2 : 0]        P_TX_RATE_3             ,
    output wire                   P_TX_PMA_RST_0          ,
    output wire                   P_TX_PMA_RST_1          ,
    output wire                   P_TX_PMA_RST_2          ,
    output wire                   P_TX_PMA_RST_3          ,
    output wire                   P_PCS_TX_RST_0          ,
    output wire                   P_PCS_TX_RST_1          ,
    output wire                   P_PCS_TX_RST_2          ,
    output wire                   P_PCS_TX_RST_3          ,
    output wire                   P_RX_PMA_RST_0          ,
    output wire                   P_RX_PMA_RST_1          ,
    output wire                   P_RX_PMA_RST_2          ,
    output wire                   P_RX_PMA_RST_3          ,
    output wire                   P_LANE_PD_0             ,
    output wire                   P_LANE_PD_1             ,
    output wire                   P_LANE_PD_2             ,
    output wire                   P_LANE_PD_3             ,
    output wire                   P_LANE_RST_0            ,
    output wire                   P_LANE_RST_1            ,
    output wire                   P_LANE_RST_2            ,
    output wire                   P_LANE_RST_3            ,
    output wire                   P_RX_LANE_PD_0          ,
    output wire                   P_RX_LANE_PD_1          ,
    output wire                   P_RX_LANE_PD_2          ,
    output wire                   P_RX_LANE_PD_3          ,
    output wire                   P_PCS_RX_RST_0          ,
    output wire                   P_PCS_RX_RST_1          ,
    output wire                   P_PCS_RX_RST_2          ,
    output wire                   P_PCS_RX_RST_3          ,
    output wire    [2 : 0]        P_RX_RATE_0             , 
    output wire    [2 : 0]        P_RX_RATE_1             ,
    output wire    [2 : 0]        P_RX_RATE_2             ,
    output wire    [2 : 0]        P_RX_RATE_3             ,
    output wire                   P_PCS_CB_RST_0          ,
    output wire                   P_PCS_CB_RST_1          ,
    output wire                   P_PCS_CB_RST_2          ,
    output wire                   P_PCS_CB_RST_3                   
);


//****************************************************************************//
//                      Internal Signal                                       //
//****************************************************************************//
//CTC Enable, TX/RX Reused Same Rate Change Port
wire       p_rx_rate_chng_0;
wire       p_rx_rate_chng_1;
wire       p_rx_rate_chng_2;
wire       p_rx_rate_chng_3;
wire [2:0] p_rxckdiv_0;
wire [2:0] p_rxckdiv_1;
wire [2:0] p_rxckdiv_2;
wire [2:0] p_rxckdiv_3;

//****************************************************************************//
//                      Sequential and Logic                                  //
//****************************************************************************//
assign   p_rx_rate_chng_0 = (CH0_TX_ENABLE=="TRUE" && PCS_CH0_BYPASS_CTC=="FALSE") ? i_tx_rate_chng_0 : i_rx_rate_chng_0;
assign   p_rx_rate_chng_1 = (CH1_TX_ENABLE=="TRUE" && PCS_CH1_BYPASS_CTC=="FALSE") ? i_tx_rate_chng_1 : i_rx_rate_chng_1;
assign   p_rx_rate_chng_2 = (CH2_TX_ENABLE=="TRUE" && PCS_CH2_BYPASS_CTC=="FALSE") ? i_tx_rate_chng_2 : i_rx_rate_chng_2;
assign   p_rx_rate_chng_3 = (CH3_TX_ENABLE=="TRUE" && PCS_CH3_BYPASS_CTC=="FALSE") ? i_tx_rate_chng_3 : i_rx_rate_chng_3;


assign   p_rxckdiv_0      = (CH0_TX_ENABLE=="TRUE" && PCS_CH0_BYPASS_CTC=="FALSE") ? {1'b0,i_txckdiv_0} : {1'b0,i_rxckdiv_0};
assign   p_rxckdiv_1      = (CH1_TX_ENABLE=="TRUE" && PCS_CH1_BYPASS_CTC=="FALSE") ? {1'b0,i_txckdiv_1} : {1'b0,i_rxckdiv_1};
assign   p_rxckdiv_2      = (CH2_TX_ENABLE=="TRUE" && PCS_CH2_BYPASS_CTC=="FALSE") ? {1'b0,i_txckdiv_2} : {1'b0,i_rxckdiv_2};
assign   p_rxckdiv_3      = (CH3_TX_ENABLE=="TRUE" && PCS_CH3_BYPASS_CTC=="FALSE") ? {1'b0,i_txckdiv_3} : {1'b0,i_rxckdiv_3};

generate
if(INNER_RST_EN=="TRUE") begin : AUTO_MODE
    ipml_hsst_rst_pll_v1_0#(
        .FREE_CLOCK_FREQ                (FREE_CLOCK_FREQ            ),
        .PLL_NUBER                      (PLL_NUBER                  )
    ) ipml_hsst_rst_pll (
        .clk                            (i_free_clk                 ),//I
        .i_pll_rst_0                    (i_pll_rst_0                ),//I
        .i_pll_rst_1                    (i_pll_rst_1                ),//I
        .P_PLL_READY_0                  (P_PLL_READY_0              ),//I
        .P_PLL_READY_1                  (P_PLL_READY_1              ),//I
        .i_wtchdg_clr_0                 (i_wtchdg_clr_0             ),//I
        .i_wtchdg_clr_1                 (i_wtchdg_clr_1             ),//I
        .o_wtchdg_st_0                  (o_wtchdg_st_0              ),//O
        .o_wtchdg_st_1                  (o_wtchdg_st_1              ),//O
        .o_pll_done_0                   (o_pll_done_0               ),//O
        .o_pll_done_1                   (o_pll_done_1               ),//O
        .P_PLLPOWERDOWN_0               (P_PLLPOWERDOWN_0           ),//O
        .P_PLLPOWERDOWN_1               (P_PLLPOWERDOWN_1           ),//O
        .P_PLL_RST_0                    (P_PLL_RST_0                ),//O
        .P_PLL_RST_1                    (P_PLL_RST_1                )//O
    );
    
    ipml_hsst_lane_powerup_v1_0#(
        .FREE_CLOCK_FREQ                (FREE_CLOCK_FREQ            ),
        .CH0_TX_ENABLE                  (CH0_TX_ENABLE              ),
        .CH1_TX_ENABLE                  (CH1_TX_ENABLE              ),
        .CH2_TX_ENABLE                  (CH2_TX_ENABLE              ),
        .CH3_TX_ENABLE                  (CH3_TX_ENABLE              ),
        .CH0_RX_ENABLE                  (CH0_RX_ENABLE              ),
        .CH1_RX_ENABLE                  (CH1_RX_ENABLE              ),
        .CH2_RX_ENABLE                  (CH2_RX_ENABLE              ),
        .CH3_RX_ENABLE                  (CH3_RX_ENABLE              ),
        .CH0_MULT_LANE_MODE             (CH0_MULT_LANE_MODE         ),
        .CH1_MULT_LANE_MODE             (CH1_MULT_LANE_MODE         ),
        .CH2_MULT_LANE_MODE             (CH2_MULT_LANE_MODE         ),
        .CH3_MULT_LANE_MODE             (CH3_MULT_LANE_MODE         ),
        .CH0_TX_PLL_SEL                 (CH0_TX_PLL_SEL             ),
        .CH1_TX_PLL_SEL                 (CH1_TX_PLL_SEL             ),
        .CH2_TX_PLL_SEL                 (CH2_TX_PLL_SEL             ),
        .CH3_TX_PLL_SEL                 (CH3_TX_PLL_SEL             ),
        .CH0_RX_PLL_SEL                 (CH0_RX_PLL_SEL             ),
        .CH1_RX_PLL_SEL                 (CH1_RX_PLL_SEL             ),
        .CH2_RX_PLL_SEL                 (CH2_RX_PLL_SEL             ),
        .CH3_RX_PLL_SEL                 (CH3_RX_PLL_SEL             )
    ) ipml_hsst_lane_powerup (
        .clk                            (i_free_clk                 ),//I
        .i_lane_pd_0                    (i_lane_pd_0                ),//I
        .i_lane_pd_1                    (i_lane_pd_1                ),//I
        .i_lane_pd_2                    (i_lane_pd_2                ),//I
        .i_lane_pd_3                    (i_lane_pd_3                ),//I
        .o_pll_done_0                   (o_pll_done_0               ),//I
        .o_pll_done_1                   (o_pll_done_1               ),//I
        .P_LANE_PD_0                    (P_LANE_PD_0                ),//O
        .P_LANE_PD_1                    (P_LANE_PD_1                ),//O
        .P_LANE_PD_2                    (P_LANE_PD_2                ),//O
        .P_LANE_PD_3                    (P_LANE_PD_3                ),//O
        .P_LANE_RST_0                   (P_LANE_RST_0               ),//O
        .P_LANE_RST_1                   (P_LANE_RST_1               ),//O
        .P_LANE_RST_2                   (P_LANE_RST_2               ),//O
        .P_LANE_RST_3                   (P_LANE_RST_3               ) //O
    );

    ipml_hsst_rst_tx_v1_0#(
        .FREE_CLOCK_FREQ                (FREE_CLOCK_FREQ            ),
        .CH0_TX_ENABLE                  (CH0_TX_ENABLE              ),
        .CH1_TX_ENABLE                  (CH1_TX_ENABLE              ),
        .CH2_TX_ENABLE                  (CH2_TX_ENABLE              ),
        .CH3_TX_ENABLE                  (CH3_TX_ENABLE              ),
        .CH0_MULT_LANE_MODE             (CH0_MULT_LANE_MODE         ),
        .CH1_MULT_LANE_MODE             (CH1_MULT_LANE_MODE         ),
        .CH2_MULT_LANE_MODE             (CH2_MULT_LANE_MODE         ),
        .CH3_MULT_LANE_MODE             (CH3_MULT_LANE_MODE         ),
        .P_LX_TX_CKDIV_0                (P_LX_TX_CKDIV_0            ),
        .P_LX_TX_CKDIV_1                (P_LX_TX_CKDIV_1            ),
        .P_LX_TX_CKDIV_2                (P_LX_TX_CKDIV_2            ),
        .P_LX_TX_CKDIV_3                (P_LX_TX_CKDIV_3            ),
        .CH0_TX_PLL_SEL                 (CH0_TX_PLL_SEL             ),
        .CH1_TX_PLL_SEL                 (CH1_TX_PLL_SEL             ),
        .CH2_TX_PLL_SEL                 (CH2_TX_PLL_SEL             ),
        .CH3_TX_PLL_SEL                 (CH3_TX_PLL_SEL             ),
        .PCS_TX_CLK_EXPLL_USE_CH0       (PCS_TX_CLK_EXPLL_USE_CH0   ),
        .PCS_TX_CLK_EXPLL_USE_CH1       (PCS_TX_CLK_EXPLL_USE_CH1   ),
        .PCS_TX_CLK_EXPLL_USE_CH2       (PCS_TX_CLK_EXPLL_USE_CH2   ),
        .PCS_TX_CLK_EXPLL_USE_CH3       (PCS_TX_CLK_EXPLL_USE_CH3   )
    ) ipml_hsst_rst_tx (
        .clk                            (i_free_clk                 ),//I
        .i_txlane_rst_0                 (i_txlane_rst_0             ),//I
        .i_txlane_rst_1                 (i_txlane_rst_1             ),//I
        .i_txlane_rst_2                 (i_txlane_rst_2             ),//I
        .i_txlane_rst_3                 (i_txlane_rst_3             ),//I
        .i_pll_done_0                   (o_pll_done_0               ),//I
        .i_pll_done_1                   (o_pll_done_1               ),//I
        .P_LANE_RST_0                   (P_LANE_RST_0               ),//I
        .P_LANE_RST_1                   (P_LANE_RST_1               ),//I
        .P_LANE_RST_2                   (P_LANE_RST_2               ),//I
        .P_LANE_RST_3                   (P_LANE_RST_3               ),//I
        .i_tx_rate_chng_0               (i_tx_rate_chng_0           ),//I
        .i_tx_rate_chng_1               (i_tx_rate_chng_1           ),//I
        .i_tx_rate_chng_2               (i_tx_rate_chng_2           ),//I
        .i_tx_rate_chng_3               (i_tx_rate_chng_3           ),//I
        .i_pll_lock_tx_0                (i_pll_lock_tx_0            ),//I
        .i_pll_lock_tx_1                (i_pll_lock_tx_1            ),//I
        .i_pll_lock_tx_2                (i_pll_lock_tx_2            ),//I
        .i_pll_lock_tx_3                (i_pll_lock_tx_3            ),//I
        .i_txckdiv_0                    ({1'b0,i_txckdiv_0}         ),//I
        .i_txckdiv_1                    ({1'b0,i_txckdiv_1}         ),//I
        .i_txckdiv_2                    ({1'b0,i_txckdiv_2}         ),//I
        .i_txckdiv_3                    ({1'b0,i_txckdiv_3}         ),//I
        .o_txlane_done_0                (o_txlane_done_0            ),//O
        .o_txlane_done_1                (o_txlane_done_1            ),//O
        .o_txlane_done_2                (o_txlane_done_2            ),//O
        .o_txlane_done_3                (o_txlane_done_3            ),//O
        .o_txckdiv_done_0               (o_tx_ckdiv_done_0          ),//O
        .o_txckdiv_done_1               (o_tx_ckdiv_done_1          ),//O
        .o_txckdiv_done_2               (o_tx_ckdiv_done_2          ),//O
        .o_txckdiv_done_3               (o_tx_ckdiv_done_3          ),//O
        .P_TX_LANE_PD_0                 (P_TX_LANE_PD_0             ),//O
        .P_TX_LANE_PD_1                 (P_TX_LANE_PD_1             ),//O
        .P_TX_LANE_PD_2                 (P_TX_LANE_PD_2             ),//O
        .P_TX_LANE_PD_3                 (P_TX_LANE_PD_3             ),//O
        .P_TX_RATE_0                    (P_TX_RATE_0                ),//O
        .P_TX_RATE_1                    (P_TX_RATE_1                ),//O
        .P_TX_RATE_2                    (P_TX_RATE_2                ),//O
        .P_TX_RATE_3                    (P_TX_RATE_3                ),//O
        .P_TX_PMA_RST_0                 (P_TX_PMA_RST_0             ),//O
        .P_TX_PMA_RST_1                 (P_TX_PMA_RST_1             ),//O
        .P_TX_PMA_RST_2                 (P_TX_PMA_RST_2             ),//O
        .P_TX_PMA_RST_3                 (P_TX_PMA_RST_3             ),//O
        .P_PCS_TX_RST_0                 (P_PCS_TX_RST_0             ),//O
        .P_PCS_TX_RST_1                 (P_PCS_TX_RST_1             ),//O
        .P_PCS_TX_RST_2                 (P_PCS_TX_RST_2             ),//O
        .P_PCS_TX_RST_3                 (P_PCS_TX_RST_3             ),//O
        .P_LANE_SYNC_0                  (P_LANE_SYNC_0              ),//O
        .P_LANE_SYNC_1                  (P_LANE_SYNC_1              ),//O
        .P_LANE_SYNC_EN_0               (P_LANE_SYNC_EN_0           ),//O
        .P_LANE_SYNC_EN_1               (P_LANE_SYNC_EN_1           ),//O
        .P_RATE_CHANGE_TCLK_ON_0        (P_RATE_CHANGE_TCLK_ON_0    ),//O
        .P_RATE_CHANGE_TCLK_ON_1        (P_RATE_CHANGE_TCLK_ON_1    )//O
    );
    
    ipml_hsst_rst_rx_v1_1#(
        .FREE_CLOCK_FREQ                (FREE_CLOCK_FREQ            ),
        .CH0_RX_ENABLE                  (CH0_RX_ENABLE              ),
        .CH1_RX_ENABLE                  (CH1_RX_ENABLE              ),
        .CH2_RX_ENABLE                  (CH2_RX_ENABLE              ),
        .CH3_RX_ENABLE                  (CH3_RX_ENABLE              ),
        .CH0_MULT_LANE_MODE             (CH0_MULT_LANE_MODE         ), 
        .CH1_MULT_LANE_MODE             (CH1_MULT_LANE_MODE         ), 
        .CH2_MULT_LANE_MODE             (CH2_MULT_LANE_MODE         ), 
        .CH3_MULT_LANE_MODE             (CH3_MULT_LANE_MODE         ),
        .CH0_RXPCS_ALIGN_TIMER          (CH0_RXPCS_ALIGN_TIMER      ), 
        .CH1_RXPCS_ALIGN_TIMER          (CH1_RXPCS_ALIGN_TIMER      ), 
        .CH2_RXPCS_ALIGN_TIMER          (CH2_RXPCS_ALIGN_TIMER      ), 
        .CH3_RXPCS_ALIGN_TIMER          (CH3_RXPCS_ALIGN_TIMER      ), 
        .PCS_CH0_BYPASS_WORD_ALIGN      (PCS_CH0_BYPASS_WORD_ALIGN  ),
        .PCS_CH1_BYPASS_WORD_ALIGN      (PCS_CH1_BYPASS_WORD_ALIGN  ),
        .PCS_CH2_BYPASS_WORD_ALIGN      (PCS_CH2_BYPASS_WORD_ALIGN  ),
        .PCS_CH3_BYPASS_WORD_ALIGN      (PCS_CH3_BYPASS_WORD_ALIGN  ),
        .PCS_CH0_BYPASS_BONDING         (PCS_CH0_BYPASS_BONDING     ),  
        .PCS_CH1_BYPASS_BONDING         (PCS_CH1_BYPASS_BONDING     ),   
        .PCS_CH2_BYPASS_BONDING         (PCS_CH2_BYPASS_BONDING     ),  
        .PCS_CH3_BYPASS_BONDING         (PCS_CH3_BYPASS_BONDING     ),  
        .PCS_CH0_BYPASS_CTC             (PCS_CH0_BYPASS_CTC         ),      
        .PCS_CH1_BYPASS_CTC             (PCS_CH1_BYPASS_CTC         ),      
        .PCS_CH2_BYPASS_CTC             (PCS_CH2_BYPASS_CTC         ),       
        .PCS_CH3_BYPASS_CTC             (PCS_CH3_BYPASS_CTC         ),
        .LX_RX_CKDIV_0                  (LX_RX_CKDIV_0              ),
        .LX_RX_CKDIV_1                  (LX_RX_CKDIV_1              ),
        .LX_RX_CKDIV_2                  (LX_RX_CKDIV_2              ),
        .LX_RX_CKDIV_3                  (LX_RX_CKDIV_3              ),
        .CH0_RX_PLL_SEL                 (CH0_RX_PLL_SEL             ),
        .CH1_RX_PLL_SEL                 (CH1_RX_PLL_SEL             ),
        .CH2_RX_PLL_SEL                 (CH2_RX_PLL_SEL             ),
        .CH3_RX_PLL_SEL                 (CH3_RX_PLL_SEL             ),
        .PCS_RX_CLK_EXPLL_USE_CH0       (PCS_RX_CLK_EXPLL_USE_CH0   ),
        .PCS_RX_CLK_EXPLL_USE_CH1       (PCS_RX_CLK_EXPLL_USE_CH1   ),
        .PCS_RX_CLK_EXPLL_USE_CH2       (PCS_RX_CLK_EXPLL_USE_CH2   ),
        .PCS_RX_CLK_EXPLL_USE_CH3       (PCS_RX_CLK_EXPLL_USE_CH3   )
    ) ipml_hsst_rst_rx (
        .clk                            (i_free_clk                 ),//I
        .i_hsst_fifo_clr_0              (i_hsst_fifo_clr_0          ),//I
        .i_hsst_fifo_clr_1              (i_hsst_fifo_clr_1          ),//I
        .i_hsst_fifo_clr_2              (i_hsst_fifo_clr_2          ),//I
        .i_hsst_fifo_clr_3              (i_hsst_fifo_clr_3          ),//I
        .P_LANE_RST_0                   (P_LANE_RST_0               ),//I
        .P_LANE_RST_1                   (P_LANE_RST_1               ),//I
        .P_LANE_RST_2                   (P_LANE_RST_2               ),//I
        .P_LANE_RST_3                   (P_LANE_RST_3               ),//I
        .i_rxlane_rst_0                 (i_rxlane_rst_0             ),//I
        .i_rxlane_rst_1                 (i_rxlane_rst_1             ),//I
        .i_rxlane_rst_2                 (i_rxlane_rst_2             ),//I
        .i_rxlane_rst_3                 (i_rxlane_rst_3             ),//I
        .i_rx_rate_chng_0               (p_rx_rate_chng_0           ),//I
        .i_rx_rate_chng_1               (p_rx_rate_chng_1           ),//I
        .i_rx_rate_chng_2               (p_rx_rate_chng_2           ),//I
        .i_rx_rate_chng_3               (p_rx_rate_chng_3           ),//I
        .i_rxckdiv_0                    (p_rxckdiv_0                ),//I
        .i_rxckdiv_1                    (p_rxckdiv_1                ),//I
        .i_rxckdiv_2                    (p_rxckdiv_2                ),//I
        .i_rxckdiv_3                    (p_rxckdiv_3                ),//I
        .i_force_rxfsm_det_0            (i_force_rxfsm_det_0        ),//I
        .i_force_rxfsm_det_1            (i_force_rxfsm_det_1        ),//I
        .i_force_rxfsm_det_2            (i_force_rxfsm_det_2        ),//I
        .i_force_rxfsm_det_3            (i_force_rxfsm_det_3        ),//I
        .i_force_rxfsm_lsm_0            (i_force_rxfsm_lsm_0        ),//I
        .i_force_rxfsm_lsm_1            (i_force_rxfsm_lsm_1        ),//I
        .i_force_rxfsm_lsm_2            (i_force_rxfsm_lsm_2        ),//I
        .i_force_rxfsm_lsm_3            (i_force_rxfsm_lsm_3        ),//I
        .i_force_rxfsm_cdr_0            (i_force_rxfsm_cdr_0        ),//I
        .i_force_rxfsm_cdr_1            (i_force_rxfsm_cdr_1        ),//I
        .i_force_rxfsm_cdr_2            (i_force_rxfsm_cdr_2        ),//I
        .i_force_rxfsm_cdr_3            (i_force_rxfsm_cdr_3        ),//I
        .i_pcs_cb_rst_0                 (i_pcs_cb_rst_0             ),//I
        .i_pcs_cb_rst_1                 (i_pcs_cb_rst_1             ),//I
        .i_pcs_cb_rst_2                 (i_pcs_cb_rst_2             ),//I
        .i_pcs_cb_rst_3                 (i_pcs_cb_rst_3             ),//I
        .i_pll_lock_rx_0                (i_pll_lock_rx_0            ),//I
        .i_pll_lock_rx_1                (i_pll_lock_rx_1            ),//I
        .i_pll_lock_rx_2                (i_pll_lock_rx_2            ),//I
        .i_pll_lock_rx_3                (i_pll_lock_rx_3            ),//I
        .P_RX_SIGDET_STATUS_0           (P_RX_SIGDET_STATUS_0       ),//I
        .P_RX_SIGDET_STATUS_1           (P_RX_SIGDET_STATUS_1       ),//I
        .P_RX_SIGDET_STATUS_2           (P_RX_SIGDET_STATUS_2       ),//I
        .P_RX_SIGDET_STATUS_3           (P_RX_SIGDET_STATUS_3       ),//I
        .P_RX_READY_0                   (P_RX_READY_0               ),//I
        .P_RX_READY_1                   (P_RX_READY_1               ),//I
        .P_RX_READY_2                   (P_RX_READY_2               ),//I
        .P_RX_READY_3                   (P_RX_READY_3               ),//I
        .P_PCS_LSM_SYNCED_0             (P_PCS_LSM_SYNCED_0         ),//I
        .P_PCS_LSM_SYNCED_1             (P_PCS_LSM_SYNCED_1         ),//I
        .P_PCS_LSM_SYNCED_2             (P_PCS_LSM_SYNCED_2         ),//I
        .P_PCS_LSM_SYNCED_3             (P_PCS_LSM_SYNCED_3         ),//I
        .P_PCS_RX_MCB_STATUS_0          (P_PCS_RX_MCB_STATUS_0      ),//I
        .P_PCS_RX_MCB_STATUS_1          (P_PCS_RX_MCB_STATUS_1      ),//I
        .P_PCS_RX_MCB_STATUS_2          (P_PCS_RX_MCB_STATUS_2      ),//I
        .P_PCS_RX_MCB_STATUS_3          (P_PCS_RX_MCB_STATUS_3      ),//I
        .P_RX_LANE_PD_0                 (P_RX_LANE_PD_0             ),//O
        .P_RX_LANE_PD_1                 (P_RX_LANE_PD_1             ),//O
        .P_RX_LANE_PD_2                 (P_RX_LANE_PD_2             ),//O
        .P_RX_LANE_PD_3                 (P_RX_LANE_PD_3             ),//O
        .P_RX_PMA_RST_0                 (P_RX_PMA_RST_0             ),//O
        .P_RX_PMA_RST_1                 (P_RX_PMA_RST_1             ),//O
        .P_RX_PMA_RST_2                 (P_RX_PMA_RST_2             ),//O
        .P_RX_PMA_RST_3                 (P_RX_PMA_RST_3             ),//O
        .P_PCS_RX_RST_0                 (P_PCS_RX_RST_0             ),//O
        .P_PCS_RX_RST_1                 (P_PCS_RX_RST_1             ),//O
        .P_PCS_RX_RST_2                 (P_PCS_RX_RST_2             ),//O
        .P_PCS_RX_RST_3                 (P_PCS_RX_RST_3             ),//O
        .P_RX_RATE_0                    (P_RX_RATE_0                ),//O
        .P_RX_RATE_1                    (P_RX_RATE_1                ),//O
        .P_RX_RATE_2                    (P_RX_RATE_2                ),//O
        .P_RX_RATE_3                    (P_RX_RATE_3                ),//O
        .P_PCS_CB_RST_0                 (P_PCS_CB_RST_0             ),//O
        .P_PCS_CB_RST_1                 (P_PCS_CB_RST_1             ),//O
        .P_PCS_CB_RST_2                 (P_PCS_CB_RST_2             ),//O
        .P_PCS_CB_RST_3                 (P_PCS_CB_RST_3             ),//O
        .o_rxlane_done_0                (o_rxlane_done_0            ),//O
        .o_rxlane_done_1                (o_rxlane_done_1            ),//O
        .o_rxlane_done_2                (o_rxlane_done_2            ),//O
        .o_rxlane_done_3                (o_rxlane_done_3            ),//O
        .o_rxckdiv_done_0               (o_rx_ckdiv_done_0          ),//O
        .o_rxckdiv_done_1               (o_rx_ckdiv_done_1          ),//O
        .o_rxckdiv_done_2               (o_rx_ckdiv_done_2          ),//O
        .o_rxckdiv_done_3               (o_rx_ckdiv_done_3          )//O
    );
end
else begin : USER_MODE
    assign o_wtchdg_st_0           = 2'b0                  ;
    assign o_wtchdg_st_1           = 2'b0                  ;
    assign o_pll_done_0            = 1'b0                  ;
    assign o_pll_done_1            = 1'b0                  ;
    assign o_txlane_done_0         = 1'b0                  ;
    assign o_txlane_done_1         = 1'b0                  ;
    assign o_txlane_done_2         = 1'b0                  ;
    assign o_txlane_done_3         = 1'b0                  ;
    assign o_tx_ckdiv_done_0       = 1'b0                  ;
    assign o_tx_ckdiv_done_1       = 1'b0                  ;
    assign o_tx_ckdiv_done_2       = 1'b0                  ;
    assign o_tx_ckdiv_done_3       = 1'b0                  ;
    assign o_rxlane_done_0         = 1'b0                  ;
    assign o_rxlane_done_1         = 1'b0                  ;
    assign o_rxlane_done_2         = 1'b0                  ;
    assign o_rxlane_done_3         = 1'b0                  ;
    assign o_rx_ckdiv_done_0       = 1'b0                  ;
    assign o_rx_ckdiv_done_1       = 1'b0                  ;
    assign o_rx_ckdiv_done_2       = 1'b0                  ;
    assign o_rx_ckdiv_done_3       = 1'b0                  ;
    //Direct To HSST
    assign P_PLLPOWERDOWN_0        = i_f_pllpowerdown_0    ;
    assign P_PLLPOWERDOWN_1        = i_f_pllpowerdown_1    ;
    assign P_PLL_RST_0             = i_f_pll_rst_0         ;
    assign P_PLL_RST_1             = i_f_pll_rst_1         ;
    assign P_LANE_SYNC_0           = i_f_lane_sync_0       ;
    assign P_LANE_SYNC_1           = i_f_lane_sync_1       ;
    assign P_LANE_SYNC_EN_0        = i_f_lane_sync_en_0    ;
    assign P_LANE_SYNC_EN_1        = i_f_lane_sync_en_1    ;
    assign P_RATE_CHANGE_TCLK_ON_0 = i_f_rate_change_tclk_on_0    ;
    assign P_RATE_CHANGE_TCLK_ON_1 = i_f_rate_change_tclk_on_1    ;
    assign P_TX_LANE_PD_0          = i_f_tx_lane_pd_0      ;
    assign P_TX_LANE_PD_1          = i_f_tx_lane_pd_1      ;
    assign P_TX_LANE_PD_2          = i_f_tx_lane_pd_2      ;
    assign P_TX_LANE_PD_3          = i_f_tx_lane_pd_3      ;
    assign P_TX_RATE_0             = {1'b0,i_f_tx_ckdiv_0}        ;
    assign P_TX_RATE_1             = {1'b0,i_f_tx_ckdiv_1}        ;
    assign P_TX_RATE_2             = {1'b0,i_f_tx_ckdiv_2}        ;
    assign P_TX_RATE_3             = {1'b0,i_f_tx_ckdiv_3}        ;
    assign P_TX_PMA_RST_0          = i_f_tx_pma_rst_0      ;
    assign P_TX_PMA_RST_1          = i_f_tx_pma_rst_1      ;
    assign P_TX_PMA_RST_2          = i_f_tx_pma_rst_2      ;
    assign P_TX_PMA_RST_3          = i_f_tx_pma_rst_3      ;
    assign P_PCS_TX_RST_0          = i_f_pcs_tx_rst_0      ;
    assign P_PCS_TX_RST_1          = i_f_pcs_tx_rst_1      ;
    assign P_PCS_TX_RST_2          = i_f_pcs_tx_rst_2      ;
    assign P_PCS_TX_RST_3          = i_f_pcs_tx_rst_3      ;
    assign P_LANE_PD_0             = i_f_lane_pd_0         ;
    assign P_LANE_PD_1             = i_f_lane_pd_1         ;
    assign P_LANE_PD_2             = i_f_lane_pd_2         ;
    assign P_LANE_PD_3             = i_f_lane_pd_3         ;
    assign P_LANE_RST_0            = i_f_lane_rst_0        ;
    assign P_LANE_RST_1            = i_f_lane_rst_1        ;
    assign P_LANE_RST_2            = i_f_lane_rst_2        ;
    assign P_LANE_RST_3            = i_f_lane_rst_3        ;
    assign P_RX_LANE_PD_0          = i_f_rx_lane_pd_0      ;
    assign P_RX_LANE_PD_1          = i_f_rx_lane_pd_1      ;
    assign P_RX_LANE_PD_2          = i_f_rx_lane_pd_2      ;
    assign P_RX_LANE_PD_3          = i_f_rx_lane_pd_3      ;
    assign P_RX_PMA_RST_0          = i_f_rx_pma_rst_0      ;
    assign P_RX_PMA_RST_1          = i_f_rx_pma_rst_1      ;
    assign P_RX_PMA_RST_2          = i_f_rx_pma_rst_2      ;
    assign P_RX_PMA_RST_3          = i_f_rx_pma_rst_3      ;
    assign P_PCS_RX_RST_0          = i_f_pcs_rx_rst_0      ;
    assign P_PCS_RX_RST_1          = i_f_pcs_rx_rst_1      ;
    assign P_PCS_RX_RST_2          = i_f_pcs_rx_rst_2      ;
    assign P_PCS_RX_RST_3          = i_f_pcs_rx_rst_3      ;
    assign P_RX_RATE_0             = {1'b0,i_f_lx_rx_ckdiv_0}     ;
    assign P_RX_RATE_1             = {1'b0,i_f_lx_rx_ckdiv_1}     ;
    assign P_RX_RATE_2             = {1'b0,i_f_lx_rx_ckdiv_2}     ;
    assign P_RX_RATE_3             = {1'b0,i_f_lx_rx_ckdiv_3}     ;
    assign P_PCS_CB_RST_0          = i_f_pcs_cb_rst_0      ;
    assign P_PCS_CB_RST_1          = i_f_pcs_cb_rst_1      ;
    assign P_PCS_CB_RST_2          = i_f_pcs_cb_rst_2      ;
    assign P_PCS_CB_RST_3          = i_f_pcs_cb_rst_3      ;
end
endgenerate

endmodule
