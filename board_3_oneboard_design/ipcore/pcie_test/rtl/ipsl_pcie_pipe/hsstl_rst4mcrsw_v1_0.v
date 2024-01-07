//******************************************************************
// Copyright (c) 2015 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
`timescale 1ns/1ps
module hsstl_rst4mcrsw_v1_0 #(
    parameter LINK_X1_WIDTH  = 0, //1 = x4
    parameter FORCE_LANE_REV = 0  //1 = Lane Reversal
)(
    input   wire                        clk,
    input   wire                        ext_rst_n,
    input   wire                        txpll_soft_rst_n,
//    input   wire                        txlane_soft_rst_n,
    input   wire    [3:0]               rxlane_soft_rst_n,
    input   wire                        wtchdg_clr,

    input   wire                        ltssm_in_recovery,
    input   wire                        rate,             // 0 = 2.5GT/s;   1 = 5.0GT/s
    input   wire    [1:0]               link_num,             // 0 = x4, 2=x2, 1=x1
    input   wire                        link_num_flag,
    input   wire                        P_PLL_LOCK,
    input   wire                        P_LX_ALOS_STA_0,
    input   wire                        P_LX_ALOS_STA_1,
    input   wire                        P_LX_ALOS_STA_2,
    input   wire                        P_LX_ALOS_STA_3,
    input   wire                        P_LX_CDR_ALIGN_0,
    input   wire                        P_LX_CDR_ALIGN_1,
    input   wire                        P_LX_CDR_ALIGN_2,
    input   wire                        P_LX_CDR_ALIGN_3,
    input   wire    [3:0]               P_PCS_LSM_SYNCED,

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
    output  wire                        tx_rst_done,

    output  wire    [3:0]               rx_main_fsm,
    output  wire    [3:0]               rx_init_fsm0,
    output  wire    [3:0]               rx_init_fsm1,
    output  wire    [3:0]               rx_init_fsm2,
    output  wire    [3:0]               rx_init_fsm3,
    output  wire    [3:0]               s_PCS_LSM_SYNCED,
    output  wire    [3:0]               s_LX_ALOS_STA_deb,
    output  wire    [3:0]               s_LX_CDR_ALIGN_deb,
    output  wire    [3:0]               init_done,

    output  wire    [3:0]               P_PMA_RX_PD,
    output  wire                        P_PMA_RX_RST_0,
    output  wire                        P_PMA_RX_RST_1,
    output  wire                        P_PMA_RX_RST_2,
    output  wire                        P_PMA_RX_RST_3,
    output  wire                        P_PCS_RX_RST_0,
    output  wire                        P_PCS_RX_RST_1,
    output  wire                        P_PCS_RX_RST_2,
    output  wire                        P_PCS_RX_RST_3,
    output  wire    [2:0]               P_LX_RX_RATE_0,
    output  wire    [2:0]               P_LX_RX_RATE_1,
    output  wire    [2:0]               P_LX_RX_RATE_2,
    output  wire    [2:0]               P_LX_RX_RATE_3,
    output  wire    [3:0]               P_TX_PD_CLKPATH,
    output  wire    [3:0]               P_TX_PD_PISO,
    output  wire    [3:0]               P_TX_PD_DRIVER,   
    output  wire    [3:0]               P_PCS_CB_RST,
    output  wire                        rate_done,
    output  wire    [3:0]               hsst_ch_ready,


    input mac_clk_req_n,
    output  phy_clk_req_n

);

localparam RST_CNTR_WIDTH = 16;
`ifdef IPSL_PCIE_SPEEDUP_SIM
localparam RST_CNTR_VALUE = 16'h000C;
`else
localparam RST_CNTR_VALUE = 16'hC000;
`endif

wire                                    rst_n;

wire                                    s_rate;
wire                                    s_ltssm_in_recovery;

// rst_n cross sync and debounce
hsst_rst_cross_sync_v1_0 #(.RST_CNTR_WIDTH(RST_CNTR_WIDTH), .RST_CNTR_VALUE(RST_CNTR_VALUE))
ext_rstn_debounce         (.clk(clk), .rstn_in(ext_rst_n),  .rstn_out(ext_rst_n_sync));

ipsl_pcie_sync_v1_0 mac_clk_req_n_sync     (.clk(clk), .rst_n(ext_rst_n_sync), .sig_async(mac_clk_req_n),  .sig_synced(mac_clk_req_n_s));

assign phy_clk_req_n = mac_clk_req_n_s; //assume that ref clk source can be controlled directly

assign rst_n = ext_rst_n_sync & (~ mac_clk_req_n_s);
//******************************************************************************************************************************************
ipsl_pcie_sync_v1_0 rate_multi_sw_sync     (.clk(clk), .rst_n(rst_n), .sig_async(rate),              .sig_synced(s_rate));
ipsl_pcie_sync_v1_0 st_recvr_multi_sw_sync (.clk(clk), .rst_n(rst_n), .sig_async(ltssm_in_recovery), .sig_synced(s_ltssm_in_recovery));

hsstl_rst4mcrsw_tx_v1_0 hsst_tx_rst_mcrsw(
    .clk                      (clk                  ),
    .rst_n                    (rst_n                ),
    .txpll_soft_rst_n         (txpll_soft_rst_n     ),
//    .txlane_soft_rst_n        (txlane_soft_rst_n    ),
    .wtchdg_clr               (wtchdg_clr           ),
    .P_PLL_LOCK               (P_PLL_LOCK           ),
//    .ltssm_in_recovery        (s_ltssm_in_recovery  ),
    .rate                     (s_rate               ),
    .tx_fsm                   (tx_fsm               ),
    .s_P_PLL_LOCK_deb         (s_P_PLL_LOCK_deb     ),
    .pll_lock_wtchdg_rst_n    (pll_lock_wtchdg_rst_n),
    .P_PMA_LANE_PD            (P_PMA_LANE_PD        ),
    .P_PMA_LANE_RST           (P_PMA_LANE_RST       ),
    .P_HSST_RST               (P_HSST_RST           ),
    .P_PLLPOWERDOWN_0         (P_PLLPOWERDOWN_0     ),
    .P_PLLPOWERDOWN_1         (P_PLLPOWERDOWN_1     ),    
    .P_PLL_RST_0              (P_PLL_RST_0          ),
    .P_PLL_RST_1              (P_PLL_RST_1          ),    
    .P_PMA_TX_PD              (P_PMA_TX_PD          ),
    .P_RATE_CHG_TXPCLK_ON_0   (P_RATE_CHG_TXPCLK_ON_0),
    .P_RATE_CHG_TXPCLK_ON_1   (P_RATE_CHG_TXPCLK_ON_1),    
    .P_LANE_SYNC_0            (P_LANE_SYNC_0        ),
    .P_LANE_SYNC_EN_0         (P_LANE_SYNC_EN_0     ),
    .P_LANE_SYNC_1            (P_LANE_SYNC_1        ),
    .P_PMA_TX_RATE_0          (P_PMA_TX_RATE_0      ),
    .P_PMA_TX_RATE_1          (P_PMA_TX_RATE_1      ),
    .P_PMA_TX_RATE_2          (P_PMA_TX_RATE_2      ),
    .P_PMA_TX_RATE_3          (P_PMA_TX_RATE_3      ),
    .P_PMA_TX_RST_0           (P_PMA_TX_RST_0       ),
    .P_PMA_TX_RST_1           (P_PMA_TX_RST_1       ),
    .P_PMA_TX_RST_2           (P_PMA_TX_RST_2       ),
    .P_PMA_TX_RST_3           (P_PMA_TX_RST_3       ),
    .P_PCS_TX_RST_0           (P_PCS_TX_RST_0       ),
    .P_PCS_TX_RST_1           (P_PCS_TX_RST_1       ),
    .P_PCS_TX_RST_2           (P_PCS_TX_RST_2       ),
    .P_PCS_TX_RST_3           (P_PCS_TX_RST_3       ),
    .P_TX_PD_CLKPATH          (P_TX_PD_CLKPATH      ),
    .P_TX_PD_PISO             (P_TX_PD_PISO         ),
    .P_TX_PD_DRIVER           (P_TX_PD_DRIVER       ),
    .tx_rst_done              (tx_rst_done          )
);

hsstl_rst4mcrsw_rx_v1_0 #(
    .LINK_X1_WIDTH            (LINK_X1_WIDTH         ),
    .FORCE_LANE_REV           (FORCE_LANE_REV        )
) hsst_rx_rst_mcrsw (
    .clk                      (clk                   ),
    .rst_n                    (rst_n                 ),
    .rxlane_soft_rst_n        (rxlane_soft_rst_n     ),
    .tx_rst_done              (tx_rst_done           ),
    .P_LX_ALOS_STA_0          (P_LX_ALOS_STA_0       ),
    .P_LX_ALOS_STA_1          (P_LX_ALOS_STA_1       ),
    .P_LX_ALOS_STA_2          (P_LX_ALOS_STA_2       ),
    .P_LX_ALOS_STA_3          (P_LX_ALOS_STA_3       ),
    .P_LX_CDR_ALIGN_0         (P_LX_CDR_ALIGN_0      ),
    .P_LX_CDR_ALIGN_1         (P_LX_CDR_ALIGN_1      ),
    .P_LX_CDR_ALIGN_2         (P_LX_CDR_ALIGN_2      ),
    .P_LX_CDR_ALIGN_3         (P_LX_CDR_ALIGN_3      ),
    .P_PCS_LSM_SYNCED         (P_PCS_LSM_SYNCED      ),
    .ltssm_in_recovery        (s_ltssm_in_recovery   ),
    .rate                     (s_rate                ),
    .link_num                 (link_num              ),
    .link_num_flag            (link_num_flag         ),
    .rx_main_fsm              (rx_main_fsm           ),
    .rx_init_fsm0             (rx_init_fsm0          ),
    .rx_init_fsm1             (rx_init_fsm1          ),
    .rx_init_fsm2             (rx_init_fsm2          ),
    .rx_init_fsm3             (rx_init_fsm3          ),
    .s_PCS_LSM_SYNCED         (s_PCS_LSM_SYNCED      ),
    .s_LX_ALOS_STA_deb        (s_LX_ALOS_STA_deb     ),
    .s_LX_CDR_ALIGN_deb       (s_LX_CDR_ALIGN_deb    ),
    .init_done                (init_done             ),
    .P_PMA_RX_PD              (P_PMA_RX_PD           ),
    .P_PMA_RX_RST_0           (P_PMA_RX_RST_0        ),
    .P_PMA_RX_RST_1           (P_PMA_RX_RST_1        ),
    .P_PMA_RX_RST_2           (P_PMA_RX_RST_2        ),
    .P_PMA_RX_RST_3           (P_PMA_RX_RST_3        ),
    .P_PCS_RX_RST_0           (P_PCS_RX_RST_0        ),
    .P_PCS_RX_RST_1           (P_PCS_RX_RST_1        ),
    .P_PCS_RX_RST_2           (P_PCS_RX_RST_2        ),
    .P_PCS_RX_RST_3           (P_PCS_RX_RST_3        ),
    .P_LX_RX_RATE_0           (P_LX_RX_RATE_0        ),
    .P_LX_RX_RATE_1           (P_LX_RX_RATE_1        ),
    .P_LX_RX_RATE_2           (P_LX_RX_RATE_2        ),
    .P_LX_RX_RATE_3           (P_LX_RX_RATE_3        ),
    .P_PCS_CB_RST             (P_PCS_CB_RST          ),
    .rate_done                (rate_done             ),
    .hsst_ch_ready            (hsst_ch_ready         )
);

endmodule
