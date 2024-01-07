//******************************************************************
// Copyright (c) 2015 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
`timescale 1ns/1ps
module hsstl_rst4mcrsw_rx_init_v1_0(
    input   wire                         clk,
    input   wire                         rst_n,
    input   wire                         rxlane_soft_rst_n,

    input   wire                         ltssm_in_recovery,

    input   wire                         P_LX_ALOS_STA,
    input   wire                         P_LX_CDR_ALIGN,
    input   wire                         P_PCS_LSM_SYNCED,

    input   wire                         main_rst_align,
    input   wire                         main_pll_loss_rst,
    input   wire                         cur_rate,
    output  wire    [3:0]                rx_init_fsm,
    output  wire                         s_LX_ALOS_STA,
    output  wire                         s_LX_CDR_ALIGN,
    output  wire                         s_PCS_LSM_SYNCED,
    output  wire                         s_LX_ALOS_STA_deb,
    output  wire                         s_LX_CDR_ALIGN_deb,

    input   wire                         P_RX_LANE_POWERUP,
    output  wire                         P_RX_PMA_RSTN,
    output  wire                         P_RX_PLL_RSTN,
    output  wire                         P_PCS_RX_RSTN,
    output  wire                         P_PCS_CB_RSTN,
    output  wire                         init_done
);

localparam LOSS_DEB_RISE_CNTR_WIDTH       = 12;
localparam LOSS_DEB_RISE_CNTR_VALUE       = 4;
localparam CDR_ALIGN_DEB_RISE_CNTR_WIDTH  = 12;
localparam CDR_ALIGN_DEB_RISE_CNTR_VALUE  = 2048;

wire                        rx_rst_n               ;

assign rx_rst_n = rst_n & rxlane_soft_rst_n;

// ALOS, CDR_ALIGN, PCS_LSM_SYNCED sync per lane
ipsl_pcie_sync_v1_0 loss_signal_multi_sw_sync (.clk(clk), .rst_n(rx_rst_n), .sig_async(P_LX_ALOS_STA),    .sig_synced(s_LX_ALOS_STA));
ipsl_pcie_sync_v1_0 cdr_align_multi_sw_sync   (.clk(clk), .rst_n(rx_rst_n), .sig_async(P_LX_CDR_ALIGN),   .sig_synced(s_LX_CDR_ALIGN));
ipsl_pcie_sync_v1_0 word_align_multi_sw_sync  (.clk(clk), .rst_n(rx_rst_n), .sig_async(P_PCS_LSM_SYNCED), .sig_synced(s_PCS_LSM_SYNCED));

// ALOS, CDR_ALIGN debounce per lane
hsst_rst_debounce_v1_0 #(.RISE_CNTR_WIDTH(LOSS_DEB_RISE_CNTR_WIDTH),       .RISE_CNTR_VALUE(LOSS_DEB_RISE_CNTR_VALUE), .ACTIVE_HIGH(1))
loss_signal_multi_sw_deb(.clk(clk), .rst_n(rx_rst_n), .signal_b(s_LX_ALOS_STA),    .signal_deb(s_LX_ALOS_STA_deb));

hsst_rst_debounce_v1_0 #(.RISE_CNTR_WIDTH(CDR_ALIGN_DEB_RISE_CNTR_WIDTH),  .RISE_CNTR_VALUE(CDR_ALIGN_DEB_RISE_CNTR_VALUE))
cdr_align_multi_sw_deb  (.clk(clk), .rst_n(rx_rst_n), .signal_b(s_LX_CDR_ALIGN),   .signal_deb(s_LX_CDR_ALIGN_deb));

// RX Reset FSM
hsstl_rst4mcrsw_rx_rst_initfsm_v1_0 rx_rst_initfsm_multi_sw_lane(
    .clk                (clk                ),
    .rst_n              (rx_rst_n           ),
    .P_RX_LANE_POWERUP  (P_RX_LANE_POWERUP  ),
    .main_rst_align     (main_rst_align     ),
    .main_pll_loss_rst  (main_pll_loss_rst  ),
    .loss_signal        (s_LX_ALOS_STA      ),
    .cdr_align          (s_LX_CDR_ALIGN     ),
    .word_align         (s_PCS_LSM_SYNCED   ),
    .cur_rate           (cur_rate           ),
    .rx_init_fsm        (rx_init_fsm        ),
    .P_RX_PMA_RSTN      (P_RX_PMA_RSTN      ),
    .P_RX_PLL_RSTN      (P_RX_PLL_RSTN      ),
    .P_PCS_RX_RSTN      (P_PCS_RX_RSTN      ),
    .P_PCS_CB_RSTN      (P_PCS_CB_RSTN      ),
    .init_done          (init_done          )
);

endmodule
