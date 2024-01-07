//******************************************************************
// Copyright (c) 2015 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
`timescale 1ns/1ps
module hsstl_rst4mcrsw_tx_v1_0(
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire                        txpll_soft_rst_n,
//    input   wire                        txlane_soft_rst_n,
    input   wire                        wtchdg_clr,

    input   wire                        P_PLL_LOCK,

//    input   wire                        ltssm_in_recovery,
    input   wire                        rate,             // 0 = 2.5GT/s;   1 = 5.0GT/s

    output  wire    [3:0]               tx_fsm,
    output  wire                        s_P_PLL_LOCK_deb,
    output  wire                        pll_lock_wtchdg_rst_n,

    output  wire    [3:0]               P_PMA_LANE_PD,
    output  wire    [3:0]               P_PMA_LANE_RST,
    output  wire                        P_HSST_RST,
    output  wire                        P_PLLPOWERDOWN_0,
    output  wire                        P_PLLPOWERDOWN_1,    
    output  wire                        P_PLL_RST_0,
    output  wire                        P_PLL_RST_1,
    output  wire    [3:0]               P_PMA_TX_PD,
    output  wire                        P_RATE_CHG_TXPCLK_ON_0,
    output  wire                        P_RATE_CHG_TXPCLK_ON_1,
    output  wire                        P_LANE_SYNC_0,
    output  wire                        P_LANE_SYNC_EN_0,
    output  wire                        P_LANE_SYNC_1,
    output  wire    [2:0]               P_PMA_TX_RATE_0,
    output  wire    [2:0]               P_PMA_TX_RATE_1,
    output  wire    [2:0]               P_PMA_TX_RATE_2,
    output  wire    [2:0]               P_PMA_TX_RATE_3,
    output  wire                        P_PMA_TX_RST_0,
    output  wire                        P_PMA_TX_RST_1,
    output  wire                        P_PMA_TX_RST_2,
    output  wire                        P_PMA_TX_RST_3,
    output  wire                        P_PCS_TX_RST_0,
    output  wire                        P_PCS_TX_RST_1,
    output  wire                        P_PCS_TX_RST_2,
    output  wire                        P_PCS_TX_RST_3,
    output  wire    [3:0]               P_TX_PD_CLKPATH,
    output  wire    [3:0]               P_TX_PD_PISO,
    output  wire    [3:0]               P_TX_PD_DRIVER,   
    output  wire                        tx_rst_done
);

localparam PLL_LOCK_RISE_CNTR_WIDTH    = 12  ;
localparam PLL_LOCK_RISE_CNTR_VALUE    = 2048;
localparam PLL_LOCK_WTCHDG_CNTR1_WIDTH = 10  ;
localparam PLL_LOCK_WTCHDG_CNTR2_WIDTH = 10  ;
wire                        P_TX_PD_CLKPATH0;
wire                        P_TX_PD_PISO0;
wire                        P_TX_PD_DRIVER0;
wire                        s_P_PLL_LOCK;

wire                        tx_rst_fsm_rst_n;

assign tx_rst_fsm_rst_n = rst_n & pll_lock_wtchdg_rst_n;

ipsl_pcie_sync_v1_0 pll_lock_multi_sw_sync (.clk(clk), .rst_n(rst_n), .sig_async(P_PLL_LOCK), .sig_synced(s_P_PLL_LOCK));

hsst_rst_debounce_v1_0  #(.RISE_CNTR_WIDTH(PLL_LOCK_RISE_CNTR_WIDTH), .RISE_CNTR_VALUE(PLL_LOCK_RISE_CNTR_VALUE))
pll_lock_multi_sw_deb    (.clk(clk), .rst_n(rst_n), .signal_b(s_P_PLL_LOCK), .signal_deb(s_P_PLL_LOCK_deb));

hsst_rst_wtchdg_v1_0    #(.WTCHDG_CNTR1_WIDTH(PLL_LOCK_WTCHDG_CNTR1_WIDTH), .WTCHDG_CNTR2_WIDTH(PLL_LOCK_WTCHDG_CNTR2_WIDTH))
pll_lock_multi_sw_wtchdg (.clk(clk), .rst_n(rst_n), .wtchdg_clr(wtchdg_clr), .wtchdg_in(s_P_PLL_LOCK), .wtchdg_rst_n(pll_lock_wtchdg_rst_n));

hsstl_rst4mcrsw_tx_rst_fsm_v1_1 tx_rst_fsm_multi_sw_lane(
    .clk                   (clk                     ),
    .rst_n                 (tx_rst_fsm_rst_n        ),
    .pll_rst_n             (txpll_soft_rst_n        ),
    //.lane_rst_n            (txlane_soft_rst_n       ),
    .pll_ready             (s_P_PLL_LOCK_deb        ),
    //.ltssm_in_recovery     (ltssm_in_recovery       ),
    .clk_remove            (1'b0), 
    .rate                  (rate                    ),
    .hsst_fsm              (tx_fsm                  ),
    .P_PMA_LANE_PD         (P_PMA_LANE_PD_0         ),
    .P_PMA_LANE_RST        (P_PMA_LANE_RST_0        ),
    .P_HSST_RST            (P_HSST_RST              ),
    .P_PLLPOWERDOWN        (P_PLLPOWERDOWN_0        ),
    .P_PLL_RST             (P_PLL_RST_0             ),
    .P_PMA_TX_PD           (P_PMA_TX_PD_0           ),
    .P_PMA_TX_RST          (P_PMA_TX_RST_0          ),    
    .P_RATE_CHG_TXPCLK_ON  (P_RATE_CHG_TXPCLK_ON_0  ),
    .P_LANE_SYNC           (P_LANE_SYNC_0           ),
    .P_LANE_SYNC_EN        (P_LANE_SYNC_EN_0),
    .P_PMA_TX_RATE         (P_PMA_TX_RATE_0         ),
    .P_TX_PD_CLKPATH       (P_TX_PD_CLKPATH0         ),
    .P_TX_PD_PISO          (P_TX_PD_PISO0            ),
    .P_TX_PD_DRIVER        (P_TX_PD_DRIVER0          ),

    .P_PCS_TX_RST          (P_PCS_TX_RST_0          ),
    .tx_rst_done           (tx_rst_done             )
);

assign P_PLLPOWERDOWN_1       = P_PLLPOWERDOWN_0;//1'b1;   //pll1 powerdown
assign P_PLL_RST_1            = P_PLL_RST_0;//1'b1;   //pll1 in reset
 
assign P_RATE_CHG_TXPCLK_ON_1 = 1'b1;
assign P_LANE_SYNC_1          = 1'b0;

assign P_PMA_TX_RATE_1        = P_PMA_TX_RATE_0;
assign P_PMA_TX_RATE_2        = P_PMA_TX_RATE_0;
assign P_PMA_TX_RATE_3        = P_PMA_TX_RATE_0;

assign P_PMA_TX_RST_1         = P_PMA_TX_RST_0;
assign P_PMA_TX_RST_2         = P_PMA_TX_RST_0;
assign P_PMA_TX_RST_3         = P_PMA_TX_RST_0;

assign P_PMA_LANE_PD          = {4{P_PMA_LANE_PD_0}};
assign P_PMA_LANE_RST         = {4{P_PMA_LANE_RST_0}};
assign P_PMA_TX_PD            = {4{P_PMA_TX_PD_0}};

assign P_PCS_TX_RST_1         = P_PCS_TX_RST_0;
assign P_PCS_TX_RST_2         = P_PCS_TX_RST_0;
assign P_PCS_TX_RST_3         = P_PCS_TX_RST_0;
assign P_TX_PD_CLKPATH        = {4{P_TX_PD_CLKPATH0}};
assign P_TX_PD_PISO           = {4{P_TX_PD_PISO0}};
assign P_TX_PD_DRIVER         = {4{P_TX_PD_DRIVER0}};
endmodule
