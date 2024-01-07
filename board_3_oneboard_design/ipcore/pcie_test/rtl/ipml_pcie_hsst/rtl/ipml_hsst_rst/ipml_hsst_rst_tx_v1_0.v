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
module  ipml_hsst_rst_tx_v1_0#( 
    parameter FREE_CLOCK_FREQ         = 100           , //Unit is MHz, free clock  freq from GUI Freq: 0~200MHz
    parameter CH0_TX_ENABLE           = "TRUE"        , //TRUE:lane0 TX Reset Logic used, FALSE: lane0 TX Reset Logic remove
    parameter CH1_TX_ENABLE           = "TRUE"        , //TRUE:lane1 TX Reset Logic used, FALSE: lane1 TX Reset Logic remove
    parameter CH2_TX_ENABLE           = "TRUE"        , //TRUE:lane2 TX Reset Logic used, FALSE: lane2 TX Reset Logic remove
    parameter CH3_TX_ENABLE           = "TRUE"        , //TRUE:lane3 TX Reset Logic used, FALSE: lane3 TX Reset Logic remove
    parameter CH0_MULT_LANE_MODE      = 1             , //Lane0 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    parameter CH1_MULT_LANE_MODE      = 1             , //Lane1 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    parameter CH2_MULT_LANE_MODE      = 1             , //Lane2 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    parameter CH3_MULT_LANE_MODE      = 1             , //Lane3 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    parameter P_LX_TX_CKDIV_0         = 0             ,
    parameter P_LX_TX_CKDIV_1         = 0             ,
    parameter P_LX_TX_CKDIV_2         = 0             ,
    parameter P_LX_TX_CKDIV_3         = 0             ,
    parameter CH0_TX_PLL_SEL          = 0             ,//Lane0 --> 1:PLL1  0:PLL0
    parameter CH1_TX_PLL_SEL          = 0             ,//Lane1 --> 1:PLL1  0:PLL0
    parameter CH2_TX_PLL_SEL          = 0             ,//Lane2 --> 1:PLL1  0:PLL0
    parameter CH3_TX_PLL_SEL          = 0             ,//Lane3 --> 1:PLL1  0:PLL0
    parameter PCS_TX_CLK_EXPLL_USE_CH0     =  "FALSE" ,//TRUE: Fabric  PLL USE
    parameter PCS_TX_CLK_EXPLL_USE_CH1     =  "FALSE" ,
    parameter PCS_TX_CLK_EXPLL_USE_CH2     =  "FALSE" ,
    parameter PCS_TX_CLK_EXPLL_USE_CH3     =  "FALSE"
)(
    //User Side 
    input  wire                   clk                     ,
    input  wire                   i_txlane_rst_0          ,
    input  wire                   i_txlane_rst_1          ,
    input  wire                   i_txlane_rst_2          ,
    input  wire                   i_txlane_rst_3          ,
    input  wire                   i_pll_done_0            ,
    input  wire                   i_pll_done_1            ,
    input  wire                   P_LANE_RST_0            ,
    input  wire                   P_LANE_RST_1            ,
    input  wire                   P_LANE_RST_2            ,
    input  wire                   P_LANE_RST_3            ,
    input  wire                   i_tx_rate_chng_0        ,
    input  wire                   i_tx_rate_chng_1        ,
    input  wire                   i_tx_rate_chng_2        ,
    input  wire                   i_tx_rate_chng_3        ,
    input  wire                   i_pll_lock_tx_0         ,
    input  wire                   i_pll_lock_tx_1         ,
    input  wire                   i_pll_lock_tx_2         ,
    input  wire                   i_pll_lock_tx_3         ,
    input  wire    [2 : 0]        i_txckdiv_0             ,
    input  wire    [2 : 0]        i_txckdiv_1             ,
    input  wire    [2 : 0]        i_txckdiv_2             ,
    input  wire    [2 : 0]        i_txckdiv_3             ,
    output wire                   o_txlane_done_0         ,
    output wire                   o_txlane_done_1         ,
    output wire                   o_txlane_done_2         ,
    output wire                   o_txlane_done_3         ,
    output wire                   o_txckdiv_done_0        ,
    output wire                   o_txckdiv_done_1        ,
    output wire                   o_txckdiv_done_2        ,
    output wire                   o_txckdiv_done_3        ,
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
    output reg                    P_LANE_SYNC_0           ,
    output reg                    P_LANE_SYNC_1           ,
    output reg                    P_LANE_SYNC_EN_0        ,
    output reg                    P_LANE_SYNC_EN_1        ,
    output reg                    P_RATE_CHANGE_TCLK_ON_0 ,
    output reg                    P_RATE_CHANGE_TCLK_ON_1      
);


localparam PLL_LOCK_RISE_CNTR_WIDTH    = 12  ;
`ifdef IPML_HSST_SPEEDUP_SIM
localparam PLL_LOCK_RISE_CNTR_VALUE    = 20  ;
`else
localparam PLL_LOCK_RISE_CNTR_VALUE    = 2048;
`endif

//****************************************************************************//
//                      Internal Signal                                       //
//****************************************************************************//
wire  [4-1    :0] i_tx_rate_chng      ;
wire  [4-1    :0] i_txlane_rstn       ;
wire  [4-1    :0] i_pll_lock_tx       ;
wire  [4*3-1  :0] l_txckdiv           ;
wire  [4-1    :0] s_txlane_rstn       ;
wire  [4-1    :0] l_tx_lane_rstn      ;
wire  [4-1    :0] s_pll_lock_tx       ;
wire  [4-1    :0] s_pll_lock_tx_deb   ;
wire  [4-1    :0] l_pll_lock_tx_deb   ;
wire              pll0_sync_ch2       ;
wire              pll0_sync_ch3       ;
wire              pll0_sync_en_ch2    ;
wire              pll0_sync_en_ch3    ;
wire              pll1_sync_ch2       ;
wire              pll1_sync_ch3       ;
wire              pll1_sync_en_ch2    ;
wire              pll1_sync_en_ch3    ;
wire              pll0_rate_change_ch2;
wire              pll0_rate_change_ch3;
wire              pll1_rate_change_ch2;
wire              pll1_rate_change_ch3;
wire              LANE_SYNC_0         ;
wire              LANE_SYNC_1         ;
wire              LANE_SYNC_EN_0      ;
wire              LANE_SYNC_EN_1      ;
wire              RATE_CHANGE_TCLK_ON_0     ;
wire              RATE_CHANGE_TCLK_ON_1     ;
//txfsm output
wire  [4-1    :0] o_tx_lane_pd        ;
wire  [4-1    :0] o_lane_sync         ;
wire  [4-1    :0] o_lane_sync_en      ;
wire  [4-1    :0] o_rate_change_on    ;
wire  [4*3-1  :0] o_tx_ckdiv          ;
wire  [4-1    :0] o_tx_pma_rst        ;
wire  [4-1    :0] o_pcs_tx_rst        ;
wire  [4-1    :0] p_txlane_done       ; 
wire  [4-1    :0] p_txckdiv_done      ;
//tx output
wire  [4-1    :0] p_tx_lane_pd        ;
wire  [4-1    :0] p_lane_sync         ;
wire  [4-1    :0] p_lane_sync_en      ;
wire  [4-1    :0] p_rate_change_on    ;
wire  [4*3-1  :0] p_tx_ckdiv          ;
wire  [4-1    :0] p_tx_pma_rst        ;
wire  [4-1    :0] p_pcs_tx_rst        ;
wire  [4-1    :0] o_txlane_done       ; 
wire  [4-1    :0] o_txckdiv_done      ;
//for rst sync
reg               lane_sync_0_ff      ;
reg               lane_sync_1_ff      ;
reg               lane_sync_en_0_ff   ;
reg               lane_sync_en_1_ff   ;
reg               rate_change_tclk_on_0_ff  ;
reg               rate_change_tclk_on_1_ff  ;

//****************************************************************************//
//                      Sequential and Logic                                  //
//****************************************************************************//

//signal generate
assign i_txlane_rstn = {~i_txlane_rst_3,~i_txlane_rst_2,~i_txlane_rst_1,~i_txlane_rst_0};
assign i_pll_lock_tx = {i_pll_lock_tx_3,i_pll_lock_tx_2,i_pll_lock_tx_1,i_pll_lock_tx_0};

//Sync  signal and Debounce signal
genvar i;
generate
for(i=0; i<4; i=i+1) begin:SYNC_TXLANE
    ipml_hsst_rst_sync_v1_0 txlane_rstn_sync (.clk(clk), .rst_n(i_txlane_rstn[i]), .sig_async(1'b1), .sig_synced(s_txlane_rstn[i]));
    ipml_hsst_rst_sync_v1_0 i_pll_lock_rstn_sync (.clk(clk), .rst_n(l_tx_lane_rstn[i]), .sig_async(i_pll_lock_tx[i]), .sig_synced(s_pll_lock_tx[i]));
    ipml_hsst_rst_debounce_v1_0  #(.RISE_CNTR_WIDTH(PLL_LOCK_RISE_CNTR_WIDTH), .RISE_CNTR_VALUE(PLL_LOCK_RISE_CNTR_VALUE))
pll_lock_deb             (.clk(clk), .rst_n(l_tx_lane_rstn[i]), .signal_b(s_pll_lock_tx[i]), .signal_deb(s_pll_lock_tx_deb[i]));
end
endgenerate

//-----  Instance Txlane Rst Fsm Module -----------
//Lane0
generate
if(CH0_TX_ENABLE=="TRUE") begin : TXLANE0_ENABLE //Lane is Enable
        ipml_hsst_txlane_rst_fsm_v1_0#(
            .LANE_BONDING             (CH0_MULT_LANE_MODE             ),
            .FREE_CLOCK_FREQ          (FREE_CLOCK_FREQ                ),
            .P_LX_TX_CKDIV            (P_LX_TX_CKDIV_0                ),
            .PCS_TX_CLK_EXPLL_USE_CH  (PCS_TX_CLK_EXPLL_USE_CH0       )
        ) txlane_rst_fsm0 (
            .clk                    (clk                            ),
            .rst_n                  (l_tx_lane_rstn       [0      ] ),
            .i_tx_rate_chng         (i_tx_rate_chng       [0      ] ),
            .i_txckdiv              (l_txckdiv            [0*3 +:3] ),
            .i_pll_lock_tx          (l_pll_lock_tx_deb    [0      ] ),
            .P_TX_LANE_PD           (o_tx_lane_pd         [0      ] ),
            .P_TX_RATE              (o_tx_ckdiv           [0*3 +:3] ),
            .P_TX_PMA_RST           (o_tx_pma_rst         [0      ] ), 
            .P_PCS_TX_RST           (o_pcs_tx_rst         [0      ] ),
            .o_txlane_done          (p_txlane_done        [0      ] ), 
            .o_txckdiv_done         (p_txckdiv_done       [0      ] ),
            .lane_sync              (o_lane_sync          [0      ] ),
            .lane_sync_en           (o_lane_sync_en       [0      ] ),
            .rate_change_on         (o_rate_change_on     [0      ] )
        );
end
else begin : TXLANE0_DISABLE //Lane is disable
    assign o_tx_lane_pd         [0]         = 1'b1;
    assign o_lane_sync          [0]         = 1'b0;
    assign o_lane_sync_en       [0]         = 1'b0;
    assign o_rate_change_on     [0]         = 1'b1;
    assign o_tx_ckdiv           [0*3 +:3]   = 3'b0;
    assign o_tx_pma_rst         [0]         = 1'b1;
    assign o_pcs_tx_rst         [0]         = 1'b1;
    assign p_txlane_done        [0]         = 1'b0; 
    assign p_txckdiv_done       [0]         = 1'b0; 
end
endgenerate

//Lane1
generate
if((CH1_TX_ENABLE=="TRUE") && (CH1_MULT_LANE_MODE   == 1)) begin : TXLANE1_ENABLE //Lane is Enable and no bonding
        ipml_hsst_txlane_rst_fsm_v1_0#(
            .LANE_BONDING             (CH1_MULT_LANE_MODE             ),
            .FREE_CLOCK_FREQ          (FREE_CLOCK_FREQ                ),
            .P_LX_TX_CKDIV            (P_LX_TX_CKDIV_1                ),
            .PCS_TX_CLK_EXPLL_USE_CH  (PCS_TX_CLK_EXPLL_USE_CH1       )
        ) txlane_rst_fsm1 (
            .clk                    (clk                            ),
            .rst_n                  (l_tx_lane_rstn       [1      ] ),
            .i_tx_rate_chng         (i_tx_rate_chng       [1      ] ),
            .i_txckdiv              (l_txckdiv            [1*3 +:3] ),
            .i_pll_lock_tx          (l_pll_lock_tx_deb    [1      ] ),
            .P_TX_LANE_PD           (o_tx_lane_pd         [1      ] ),
            .P_TX_RATE              (o_tx_ckdiv           [1*3 +:3] ),
            .P_TX_PMA_RST           (o_tx_pma_rst         [1      ] ),
            .P_PCS_TX_RST           (o_pcs_tx_rst         [1      ] ),
            .o_txlane_done          (p_txlane_done        [1      ] ), 
            .o_txckdiv_done         (p_txckdiv_done       [1      ] ),
            .lane_sync              (o_lane_sync          [1      ] ),
            .lane_sync_en           (o_lane_sync_en       [1      ] ),
            .rate_change_on         (o_rate_change_on     [1      ] )
        );
end
else begin : TXLANE1_DISABLE //Lane is disable or use Lane0 fsm
    assign o_tx_lane_pd         [1]         = 1'b1;
    assign o_lane_sync          [1]         = 1'b0;
    assign o_lane_sync_en       [1]         = 1'b0;
    assign o_rate_change_on     [1]         = 1'b1;
    assign o_tx_ckdiv           [1*3 +:3]   = 3'b0;
    assign o_tx_pma_rst         [1]         = 1'b1;
    assign o_pcs_tx_rst         [1]         = 1'b1;
    assign p_txlane_done        [1]         = 1'b0; 
    assign p_txckdiv_done       [1]         = 1'b0;
end
endgenerate

//Lane2
generate
if((CH2_TX_ENABLE=="TRUE") && (CH0_MULT_LANE_MODE  != 4 )) begin : TXLANE2_ENABLE //Lane is Enable and no 4LANE bonding
        ipml_hsst_txlane_rst_fsm_v1_0#(
            .LANE_BONDING             (CH2_MULT_LANE_MODE             ),
            .FREE_CLOCK_FREQ          (FREE_CLOCK_FREQ                ),
            .P_LX_TX_CKDIV            (P_LX_TX_CKDIV_2                ),
            .PCS_TX_CLK_EXPLL_USE_CH  (PCS_TX_CLK_EXPLL_USE_CH2       )
        ) txlane_rst_fsm2 (
            .clk                    (clk                            ),
            .rst_n                  (l_tx_lane_rstn       [2      ] ),
            .i_tx_rate_chng         (i_tx_rate_chng       [2      ] ),
            .i_txckdiv              (l_txckdiv            [2*3 +:3] ),
            .i_pll_lock_tx          (l_pll_lock_tx_deb    [2      ] ),
            .P_TX_LANE_PD           (o_tx_lane_pd         [2      ] ),
            .P_TX_RATE              (o_tx_ckdiv           [2*3 +:3] ),
            .P_TX_PMA_RST           (o_tx_pma_rst         [2      ] ),
            .P_PCS_TX_RST           (o_pcs_tx_rst         [2      ] ),
            .o_txlane_done          (p_txlane_done        [2      ] ), 
            .o_txckdiv_done         (p_txckdiv_done       [2      ] ),
            .lane_sync              (o_lane_sync          [2      ] ),
            .lane_sync_en           (o_lane_sync_en       [2      ] ),
            .rate_change_on         (o_rate_change_on     [2      ] )
        );
end
else begin : TXLANE2_DISABLE //Lane is disable or use Lane0 fsm
    assign o_tx_lane_pd         [2]         = 1'b1;
    assign o_lane_sync          [2]         = 1'b0;
    assign o_lane_sync_en       [2]         = 1'b0;
    assign o_rate_change_on     [2]         = 1'b1;
    assign o_tx_ckdiv           [2*3+:3]    = 3'b0;
    assign o_tx_pma_rst         [2]         = 1'b1;
    assign o_pcs_tx_rst         [2]         = 1'b1;
    assign p_txlane_done        [2]         = 1'b0;
    assign p_txckdiv_done       [2]         = 1'b0; 
end
endgenerate

//Lane3
generate
if((CH3_TX_ENABLE=="TRUE") && (CH3_MULT_LANE_MODE   == 1)) begin : TXLANE3_ENABLE //Lane is Enable and no bonding
        ipml_hsst_txlane_rst_fsm_v1_0#(
            .LANE_BONDING             (CH3_MULT_LANE_MODE             ),
            .FREE_CLOCK_FREQ          (FREE_CLOCK_FREQ                ),
            .P_LX_TX_CKDIV            (P_LX_TX_CKDIV_3                ),
            .PCS_TX_CLK_EXPLL_USE_CH  (PCS_TX_CLK_EXPLL_USE_CH3       )
        ) txlane_rst_fsm3 (
            .clk                    (clk                            ),
            .rst_n                  (l_tx_lane_rstn       [3      ] ),
            .i_tx_rate_chng         (i_tx_rate_chng       [3      ] ),
            .i_txckdiv              (l_txckdiv            [3*3 +:3] ),
            .i_pll_lock_tx          (l_pll_lock_tx_deb    [3      ] ),
            .P_TX_LANE_PD           (o_tx_lane_pd         [3      ] ),
            .P_TX_RATE              (o_tx_ckdiv           [3*3 +:3] ),
            .P_TX_PMA_RST           (o_tx_pma_rst         [3      ] ),
            .P_PCS_TX_RST           (o_pcs_tx_rst         [3      ] ),
            .o_txlane_done          (p_txlane_done        [3      ] ), 
            .o_txckdiv_done         (p_txckdiv_done       [3      ] ),
            .lane_sync              (o_lane_sync          [3      ] ),
            .lane_sync_en           (o_lane_sync_en       [3      ] ),
            .rate_change_on         (o_rate_change_on     [3      ] )
        );
end
else begin : TXLANE3_DISABLE //Lane is disable
    assign o_tx_lane_pd         [3]         = 1'b1;
    assign o_lane_sync          [3]         = 1'b0;
    assign o_lane_sync_en       [3]         = 1'b0;
    assign o_rate_change_on     [3]         = 1'b1;
    assign o_tx_ckdiv           [3*3+:3]    = 3'b0;
    assign o_tx_pma_rst         [3]         = 1'b1;
    assign o_pcs_tx_rst         [3]         = 1'b1;
    assign p_txlane_done        [3]         = 1'b0;
    assign p_txckdiv_done       [3]         = 1'b0; 
end
endgenerate

generate
if(CH0_MULT_LANE_MODE==4) begin:FOUR_LANE_MODE
    //From USER
    assign l_tx_lane_rstn         = {3'b0,~P_LANE_RST_0 & s_txlane_rstn[0]}; //From lane0 control signal
    assign i_tx_rate_chng         = {3'b0,i_tx_rate_chng_0};
    assign l_txckdiv              = {9'b0,i_txckdiv_0};
    assign l_pll_lock_tx_deb      = {3'b0,s_pll_lock_tx_deb[0]};
    //To HSST
    assign p_tx_lane_pd           = {4{o_tx_lane_pd             [0]}};
    assign p_lane_sync            = {4{o_lane_sync              [0]}};
    assign p_lane_sync_en         = {4{o_lane_sync_en           [0]}};
    assign p_rate_change_on       = {4{o_rate_change_on         [0]}};
    assign p_tx_ckdiv             = {4{o_tx_ckdiv             [2:0]}};
    assign p_tx_pma_rst           = {4{o_tx_pma_rst             [0]}};
    assign p_pcs_tx_rst           = {4{o_pcs_tx_rst             [0]}};
    assign o_txlane_done          = {4{p_txlane_done            [0]}};
    assign o_txckdiv_done         = {4{p_txckdiv_done           [0]}};
end
else if(CH0_MULT_LANE_MODE==2 && CH2_MULT_LANE_MODE==2) begin: TWO_LANE_MODE
   //From USER
    assign l_tx_lane_rstn         = {1'b0,~P_LANE_RST_2 & s_txlane_rstn[2],1'b0,~P_LANE_RST_0 & s_txlane_rstn[0]};
    assign i_tx_rate_chng         = {1'b0,i_tx_rate_chng_2,1'b0,i_tx_rate_chng_0};
    assign l_txckdiv              = {3'b0,i_txckdiv_2,3'b0,i_txckdiv_0};
    assign l_pll_lock_tx_deb      = {1'b0,s_pll_lock_tx_deb[2],1'b0,s_pll_lock_tx_deb[0]};
    //To HSST
    assign p_tx_lane_pd           = {{2{o_tx_lane_pd             [2]}},{2{o_tx_lane_pd             [0]}}};
    assign p_lane_sync            = {{2{o_lane_sync              [2]}},{2{o_lane_sync              [0]}}};
    assign p_lane_sync_en         = {{2{o_lane_sync_en           [2]}},{2{o_lane_sync_en           [0]}}};
    assign p_rate_change_on       = {{2{o_rate_change_on         [2]}},{2{o_rate_change_on         [0]}}};
    assign p_tx_ckdiv             = {{2{o_tx_ckdiv             [8:6]}},{2{o_tx_ckdiv             [2:0]}}};
    assign p_tx_pma_rst           = {{2{o_tx_pma_rst             [2]}},{2{o_tx_pma_rst             [0]}}};
    assign p_pcs_tx_rst           = {{2{o_pcs_tx_rst             [2]}},{2{o_pcs_tx_rst             [0]}}};
    assign o_txlane_done          = {{2{p_txlane_done            [2]}},{2{p_txlane_done            [0]}}};
    assign o_txckdiv_done         = {{2{p_txckdiv_done           [2]}},{2{p_txckdiv_done           [0]}}};
end
else if(CH0_MULT_LANE_MODE==2) begin:TWO_LANE_MODE0
    //From USER
    assign l_tx_lane_rstn         = {~P_LANE_RST_3 & s_txlane_rstn[3],~P_LANE_RST_2 & s_txlane_rstn[2],1'b0,~P_LANE_RST_0 & s_txlane_rstn[0]};
    assign i_tx_rate_chng         = {i_tx_rate_chng_3,i_tx_rate_chng_2,1'b0,i_tx_rate_chng_0};
    assign l_txckdiv              = {i_txckdiv_3,i_txckdiv_2,3'b0,i_txckdiv_0};
    assign l_pll_lock_tx_deb      = {s_pll_lock_tx_deb[3],s_pll_lock_tx_deb[2],1'b0,s_pll_lock_tx_deb[0]};
    //To HSST
    assign p_tx_lane_pd           = {o_tx_lane_pd             [3],o_tx_lane_pd             [2],{2{o_tx_lane_pd             [0]}}};
    assign p_lane_sync            = {o_lane_sync              [3],o_lane_sync              [2],{2{o_lane_sync              [0]}}};
    assign p_lane_sync_en         = {o_lane_sync_en           [3],o_lane_sync_en           [2],{2{o_lane_sync_en           [0]}}};
    assign p_rate_change_on       = {o_rate_change_on         [3],o_rate_change_on         [2],{2{o_rate_change_on         [0]}}};
    assign p_tx_ckdiv             = {o_tx_ckdiv             [11:9],o_tx_ckdiv             [8:6],{2{o_tx_ckdiv             [2:0]}}};
    assign p_tx_pma_rst           = {o_tx_pma_rst             [3],o_tx_pma_rst             [2],{2{o_tx_pma_rst             [0]}}};
    assign p_pcs_tx_rst           = {o_pcs_tx_rst             [3],o_pcs_tx_rst             [2],{2{o_pcs_tx_rst             [0]}}};
    assign o_txlane_done          = {p_txlane_done            [3],p_txlane_done            [2],{2{p_txlane_done            [0]}}};
    assign o_txckdiv_done         = {p_txckdiv_done           [3],p_txckdiv_done           [2],{2{p_txckdiv_done           [0]}}};
end
else if(CH2_MULT_LANE_MODE==2) begin:TWO_LANE_MODE1
    //From USER
    assign l_tx_lane_rstn         = {1'b0,~P_LANE_RST_2 & s_txlane_rstn[2],~P_LANE_RST_1 & s_txlane_rstn[1],~P_LANE_RST_0 & s_txlane_rstn[0]};
    assign i_tx_rate_chng         = {1'b0,i_tx_rate_chng_2,i_tx_rate_chng_1,i_tx_rate_chng_0};
    assign l_txckdiv              = {3'b0,i_txckdiv_2,i_txckdiv_1,i_txckdiv_0};
    assign l_pll_lock_tx_deb      = {1'b0,s_pll_lock_tx_deb[2],s_pll_lock_tx_deb[1],s_pll_lock_tx_deb[0]};
    //To HSST      
    assign p_tx_lane_pd           = {{2{o_tx_lane_pd             [2]}},o_tx_lane_pd             [1],o_tx_lane_pd             [0]};
    assign p_lane_sync            = {{2{o_lane_sync              [2]}},o_lane_sync              [1],o_lane_sync              [0]};
    assign p_lane_sync_en         = {{2{o_lane_sync_en           [2]}},o_lane_sync_en           [1],o_lane_sync_en           [0]};
    assign p_rate_change_on       = {{2{o_rate_change_on         [2]}},o_rate_change_on         [1],o_rate_change_on         [0]};
    assign p_tx_ckdiv             = {{2{o_tx_ckdiv             [8:6]}},o_tx_ckdiv             [5:3],o_tx_ckdiv             [2:0]};
    assign p_tx_pma_rst           = {{2{o_tx_pma_rst             [2]}},o_tx_pma_rst             [1],o_tx_pma_rst             [0]};
    assign p_pcs_tx_rst           = {{2{o_pcs_tx_rst             [2]}},o_pcs_tx_rst             [1],o_pcs_tx_rst             [0]};
    assign o_txlane_done          = {{2{p_txlane_done            [2]}},p_txlane_done            [1],p_txlane_done            [0]};
    assign o_txckdiv_done         = {{2{p_txckdiv_done           [2]}},p_txckdiv_done           [1],p_txckdiv_done           [0]};
end
else begin:ONE_LANE_MODE
    //From USER
    assign l_tx_lane_rstn         = {~P_LANE_RST_3 & s_txlane_rstn[3],~P_LANE_RST_2 & s_txlane_rstn[2],~P_LANE_RST_1 & s_txlane_rstn[1],~P_LANE_RST_0 & s_txlane_rstn[0]};
    assign i_tx_rate_chng         = {i_tx_rate_chng_3,i_tx_rate_chng_2,i_tx_rate_chng_1,i_tx_rate_chng_0};
    assign l_txckdiv              = {i_txckdiv_3,i_txckdiv_2,i_txckdiv_1,i_txckdiv_0};
    assign l_pll_lock_tx_deb      = {s_pll_lock_tx_deb[3],s_pll_lock_tx_deb[2],s_pll_lock_tx_deb[1],s_pll_lock_tx_deb[0]};
    //To HSST      
    assign p_tx_lane_pd           = {o_tx_lane_pd        [3],o_tx_lane_pd        [2],o_tx_lane_pd        [1],o_tx_lane_pd        [0]};
    assign p_lane_sync            = {o_lane_sync              [3],o_lane_sync              [2],o_lane_sync              [1],o_lane_sync              [0]};
    assign p_lane_sync_en         = {o_lane_sync_en           [3],o_lane_sync_en           [2],o_lane_sync_en           [1],o_lane_sync_en           [0]};
    assign p_rate_change_on       = {o_rate_change_on         [3],o_rate_change_on         [2],o_rate_change_on         [1],o_rate_change_on         [0]};
    assign p_tx_ckdiv             = {o_tx_ckdiv             [11:9],o_tx_ckdiv             [8:6],o_tx_ckdiv             [5:3],o_tx_ckdiv             [2:0]};
    assign p_tx_pma_rst           = {o_tx_pma_rst             [3],o_tx_pma_rst             [2],o_tx_pma_rst             [1],o_tx_pma_rst             [0]};
    assign p_pcs_tx_rst           = {o_pcs_tx_rst             [3],o_pcs_tx_rst             [2],o_pcs_tx_rst             [1],o_pcs_tx_rst             [0]};
    assign o_txlane_done          = {p_txlane_done            [3],p_txlane_done            [2],p_txlane_done            [1],p_txlane_done            [0]};
    assign o_txckdiv_done         = {p_txckdiv_done           [3],p_txckdiv_done           [2],p_txckdiv_done           [1],p_txckdiv_done           [0]};
end
endgenerate

assign o_txlane_done_0        = o_txlane_done[0];
assign o_txlane_done_1        = o_txlane_done[1];
assign o_txlane_done_2        = o_txlane_done[2];
assign o_txlane_done_3        = o_txlane_done[3];
assign o_txckdiv_done_0       = o_txckdiv_done[0];
assign o_txckdiv_done_1       = o_txckdiv_done[1];
assign o_txckdiv_done_2       = o_txckdiv_done[2];
assign o_txckdiv_done_3       = o_txckdiv_done[3];
assign P_TX_LANE_PD_0         = p_tx_lane_pd  [0];
assign P_TX_LANE_PD_1         = p_tx_lane_pd  [1];
assign P_TX_LANE_PD_2         = p_tx_lane_pd  [2];
assign P_TX_LANE_PD_3         = p_tx_lane_pd  [3];
assign P_TX_RATE_0            = p_tx_ckdiv  [2:0];
assign P_TX_RATE_1            = p_tx_ckdiv  [5:3];
assign P_TX_RATE_2            = p_tx_ckdiv  [8:6];
assign P_TX_RATE_3            = p_tx_ckdiv [11:9];
assign P_TX_PMA_RST_0         = p_tx_pma_rst  [0];
assign P_TX_PMA_RST_1         = p_tx_pma_rst  [1];
assign P_TX_PMA_RST_2         = p_tx_pma_rst  [2];
assign P_TX_PMA_RST_3         = p_tx_pma_rst  [3];
assign P_PCS_TX_RST_0         = p_pcs_tx_rst  [0];
assign P_PCS_TX_RST_1         = p_pcs_tx_rst  [1];
assign P_PCS_TX_RST_2         = p_pcs_tx_rst  [2];
assign P_PCS_TX_RST_3         = p_pcs_tx_rst  [3];
//PLL SYNC && RATE_CHANGE generate
assign pll0_sync_ch2    = (CH2_TX_PLL_SEL == 0) ? p_lane_sync[2] : 1'b0 ;
assign pll0_sync_ch3    = (CH3_TX_PLL_SEL == 0) ? p_lane_sync[3] : 1'b0 ;
assign pll1_sync_ch2    = (CH2_TX_PLL_SEL == 0) ? 1'b0 : p_lane_sync[2] ;
assign pll1_sync_ch3    = (CH3_TX_PLL_SEL == 0) ? 1'b0 : p_lane_sync[3] ;
assign LANE_SYNC_0      = p_lane_sync[0] || p_lane_sync[1] || pll0_sync_ch2 || pll0_sync_ch3 ;
assign LANE_SYNC_1      = pll1_sync_ch2 || pll1_sync_ch3 ;
assign pll0_sync_en_ch2 = (CH2_TX_PLL_SEL == 0) ? p_lane_sync_en[2] : 1'b0 ;
assign pll0_sync_en_ch3 = (CH3_TX_PLL_SEL == 0) ? p_lane_sync_en[3] : 1'b0 ;
assign pll1_sync_en_ch2 = (CH2_TX_PLL_SEL == 0) ? 1'b0 : p_lane_sync_en[2] ;
assign pll1_sync_en_ch3 = (CH3_TX_PLL_SEL == 0) ? 1'b0 : p_lane_sync_en[3] ;
assign LANE_SYNC_EN_0   = p_lane_sync_en[0] || p_lane_sync_en[1] || pll0_sync_en_ch2 || pll0_sync_en_ch3 ;
assign LANE_SYNC_EN_1   = pll1_sync_en_ch2 || pll1_sync_en_ch3 ;
assign pll0_rate_change_ch2    = (CH2_TX_PLL_SEL == 0) ? p_rate_change_on[2] : 1'b1 ;
assign pll0_rate_change_ch3    = (CH3_TX_PLL_SEL == 0) ? p_rate_change_on[3] : 1'b1 ;
assign pll1_rate_change_ch2    = (CH2_TX_PLL_SEL == 0) ? 1'b1 : p_rate_change_on[2] ;
assign pll1_rate_change_ch3    = (CH3_TX_PLL_SEL == 0) ? 1'b1 : p_rate_change_on[3] ;
assign RATE_CHANGE_TCLK_ON_0   = p_rate_change_on[0] && p_rate_change_on[1] && pll0_rate_change_ch2 && pll0_rate_change_ch3 ;
assign RATE_CHANGE_TCLK_ON_1   = pll1_rate_change_ch2 && pll1_rate_change_ch3 ;

always @ (posedge clk or negedge i_pll_done_0) begin
    if(!i_pll_done_0)
        lane_sync_0_ff        <= 1'b0          ;
    else
        lane_sync_0_ff        <= LANE_SYNC_0   ;
end

always @ (posedge clk or negedge i_pll_done_0) begin
    if(!i_pll_done_0)
        P_LANE_SYNC_0         <= 1'b0          ;
    else
        P_LANE_SYNC_0         <= lane_sync_0_ff;
end

always @ (posedge clk or negedge i_pll_done_0) begin
    if(!i_pll_done_0)
        lane_sync_en_0_ff         <= 1'b0          ;
    else
        lane_sync_en_0_ff         <= LANE_SYNC_EN_0;
end

always @ (posedge clk or negedge i_pll_done_0) begin
    if(!i_pll_done_0)
        P_LANE_SYNC_EN_0         <= 1'b0             ;
    else
        P_LANE_SYNC_EN_0         <= lane_sync_en_0_ff;
end

always @ (posedge clk or negedge i_pll_done_0) begin
    if(!i_pll_done_0)
        rate_change_tclk_on_0_ff         <= 1'b0                 ;
    else
        rate_change_tclk_on_0_ff         <= RATE_CHANGE_TCLK_ON_0;
end

always @ (posedge clk or negedge i_pll_done_0) begin
    if(!i_pll_done_0)
        P_RATE_CHANGE_TCLK_ON_0         <= 1'b0                    ;
    else
        P_RATE_CHANGE_TCLK_ON_0         <= rate_change_tclk_on_0_ff;
end

always @ (posedge clk or negedge i_pll_done_1) begin
    if(!i_pll_done_1)
        lane_sync_1_ff        <= 1'b0          ;
    else
        lane_sync_1_ff        <= LANE_SYNC_1   ;
end

always @ (posedge clk or negedge i_pll_done_1) begin
    if(!i_pll_done_1)
        P_LANE_SYNC_1         <= 1'b0          ;
    else
        P_LANE_SYNC_1         <= lane_sync_1_ff;
end

always @ (posedge clk or negedge i_pll_done_1) begin
    if(!i_pll_done_1)
        lane_sync_en_1_ff         <= 1'b0          ;
    else
        lane_sync_en_1_ff         <= LANE_SYNC_EN_1;
end

always @ (posedge clk or negedge i_pll_done_1) begin
    if(!i_pll_done_1)
        P_LANE_SYNC_EN_1         <= 1'b0             ;
    else
        P_LANE_SYNC_EN_1         <= lane_sync_en_1_ff;
end

always @ (posedge clk or negedge i_pll_done_1) begin
    if(!i_pll_done_1)
        rate_change_tclk_on_1_ff         <= 1'b0                 ;
    else
        rate_change_tclk_on_1_ff         <= RATE_CHANGE_TCLK_ON_1;
end

always @ (posedge clk or negedge i_pll_done_1) begin
    if(!i_pll_done_1)
        P_RATE_CHANGE_TCLK_ON_1         <= 1'b0                    ;
    else
        P_RATE_CHANGE_TCLK_ON_1         <= rate_change_tclk_on_1_ff;
end

endmodule
