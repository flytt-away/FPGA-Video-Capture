// Created by IP Generator (Version 2022.1 build 99559)


///////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
////////////////////////////////////////////////////////////////////////////////
//
// Library:
// Filename:
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/100fs

module ipml_pcie_hsst_x4_top (

    input          i_p_refckn_1                  ,
    input          i_p_refckp_1                  ,

    input          i_p_tx_lane_pd_0              ,
    input          i_p_tx_lane_pd_1              ,
    input          i_p_tx_lane_pd_2              ,
    input          i_p_tx_lane_pd_3              ,
    input          i_p_lane_pd_0                 ,
    input          i_p_lane_pd_1                 ,
    input          i_p_lane_pd_2                 ,
    input          i_p_lane_pd_3                 ,
    input          i_p_lane_rst_0                ,
    input          i_p_lane_rst_1                ,
    input          i_p_lane_rst_2                ,
    input          i_p_lane_rst_3                ,
    input          i_p_rx_lane_pd_0              ,
    input          i_p_rx_lane_pd_1              ,
    input          i_p_rx_lane_pd_2              ,
    input          i_p_rx_lane_pd_3              ,
    output         o_p_clk2core_tx_0             ,
    input          i_p_tx0_clk_fr_core           ,
    input          i_p_tx1_clk_fr_core           ,
    input          i_p_tx2_clk_fr_core           ,
    input          i_p_tx3_clk_fr_core           ,
    input          i_p_tx0_clk2_fr_core          ,
    input          i_p_tx1_clk2_fr_core          ,
    input          i_p_tx2_clk2_fr_core          ,
    input          i_p_tx3_clk2_fr_core          ,
    output         o_p_clk2core_rx_0             ,
    input          i_p_rx0_clk_fr_core           ,
    input          i_p_rx1_clk_fr_core           ,
    input          i_p_rx2_clk_fr_core           ,
    input          i_p_rx3_clk_fr_core           ,
    input          i_p_rx0_clk2_fr_core          ,
    input          i_p_rx1_clk2_fr_core          ,
    input          i_p_rx2_clk2_fr_core          ,
    input          i_p_rx3_clk2_fr_core          ,
    input          i_p_pll_rst_0                 ,
    input          i_p_tx_pma_rst_0              ,
    input          i_p_tx_pma_rst_1              ,
    input          i_p_tx_pma_rst_2              ,
    input          i_p_tx_pma_rst_3              ,
    input          i_p_pcs_tx_rst_0              ,
    input          i_p_pcs_tx_rst_1              ,
    input          i_p_pcs_tx_rst_2              ,
    input          i_p_pcs_tx_rst_3              ,
    input          i_p_rx_pma_rst_0              ,
    input          i_p_rx_pma_rst_1              ,
    input          i_p_rx_pma_rst_2              ,
    input          i_p_rx_pma_rst_3              ,
    input          i_p_pcs_rx_rst_0              ,
    input          i_p_pcs_rx_rst_1              ,
    input          i_p_pcs_rx_rst_2              ,
    input          i_p_pcs_rx_rst_3              ,
    input          i_p_pcs_cb_rst_0              ,
    input          i_p_pcs_cb_rst_1              ,
    input          i_p_pcs_cb_rst_2              ,
    input          i_p_pcs_cb_rst_3              ,
    input  [2:0]   i_p_lx_margin_ctl_0           ,
    input  [2:0]   i_p_lx_margin_ctl_1           ,
    input  [2:0]   i_p_lx_margin_ctl_2           ,
    input  [2:0]   i_p_lx_margin_ctl_3           ,
    input          i_p_lx_swing_ctl_0            ,
    input          i_p_lx_swing_ctl_1            ,
    input          i_p_lx_swing_ctl_2            ,
    input          i_p_lx_swing_ctl_3            ,
    input  [1:0]   i_p_lx_deemp_ctl_0            ,
    input  [1:0]   i_p_lx_deemp_ctl_1            ,
    input  [1:0]   i_p_lx_deemp_ctl_2            ,
    input  [1:0]   i_p_lx_deemp_ctl_3            ,
    input          i_p_lane_sync_0               ,    
    input          i_p_lane_sync_en_0            ,
    input          i_p_rate_change_tclk_on_0     ,
    input  [1:0]   i_p_tx_ckdiv_0                ,
    input  [1:0]   i_p_tx_ckdiv_1                ,
    input  [1:0]   i_p_tx_ckdiv_2                ,
    input  [1:0]   i_p_tx_ckdiv_3                ,
    input  [1:0]   i_p_lx_rx_ckdiv_0             ,
    input  [1:0]   i_p_lx_rx_ckdiv_1             ,
    input  [1:0]   i_p_lx_rx_ckdiv_2             ,
    input  [1:0]   i_p_lx_rx_ckdiv_3             ,
    input  [1:0]   i_p_lx_elecidle_en_0          ,
    input  [1:0]   i_p_lx_elecidle_en_1          ,
    input  [1:0]   i_p_lx_elecidle_en_2          ,
    input  [1:0]   i_p_lx_elecidle_en_3          ,
    output         o_p_pll_lock_0                ,
    output         o_p_rx_sigdet_sta_0           ,
    output         o_p_rx_sigdet_sta_1           ,
    output         o_p_rx_sigdet_sta_2           ,
    output         o_p_rx_sigdet_sta_3           ,
    output         o_p_lx_cdr_align_0            ,
    output         o_p_lx_cdr_align_1            ,
    output         o_p_lx_cdr_align_2            ,
    output         o_p_lx_cdr_align_3            ,
    input          i_p_lx_rxdct_en_0             ,
    input          i_p_lx_rxdct_en_1             ,
    input          i_p_lx_rxdct_en_2             ,
    input          i_p_lx_rxdct_en_3             ,
    output         o_p_lx_rxdct_out_0            ,
    output         o_p_lx_rxdct_out_1            ,
    output         o_p_lx_rxdct_out_2            ,
    output         o_p_lx_rxdct_out_3            ,
    output         o_p_pcs_lsm_synced_0          ,
    output         o_p_pcs_lsm_synced_1          ,
    output         o_p_pcs_lsm_synced_2          ,
    output         o_p_pcs_lsm_synced_3          ,
    input          i_p_pcs_nearend_loop_0        ,
    input          i_p_pcs_farend_loop_0         ,
    input          i_p_pma_nearend_ploop_0       ,
    input          i_p_pma_nearend_sloop_0       ,
    input          i_p_pma_farend_ploop_0        ,
    input          i_p_pcs_nearend_loop_1        ,
    input          i_p_pcs_farend_loop_1         ,
    input          i_p_pma_nearend_ploop_1       ,
    input          i_p_pma_nearend_sloop_1       ,
    input          i_p_pma_farend_ploop_1        ,
    input          i_p_pcs_nearend_loop_2        ,
    input          i_p_pcs_farend_loop_2         ,
    input          i_p_pma_nearend_ploop_2       ,
    input          i_p_pma_nearend_sloop_2       ,
    input          i_p_pma_farend_ploop_2        ,
    input          i_p_pcs_nearend_loop_3        ,
    input          i_p_pcs_farend_loop_3         ,
    input          i_p_pma_nearend_ploop_3       ,
    input          i_p_pma_nearend_sloop_3       ,
    input          i_p_pma_farend_ploop_3        ,
    input          i_p_rx_polarity_invert_0      ,
    input          i_p_rx_polarity_invert_1      ,
    input          i_p_rx_polarity_invert_2      ,
    input          i_p_rx_polarity_invert_3      ,
    input          i_p_tx_beacon_en_0            ,
    input          i_p_tx_beacon_en_1            ,
    input          i_p_tx_beacon_en_2            ,
    input          i_p_tx_beacon_en_3            ,
    input          i_p_cfg_clk                   ,
    input          i_p_cfg_rst                   ,
    input          i_p_cfg_psel                  ,
    input          i_p_cfg_enable                ,
    input          i_p_cfg_write                 ,
    input  [15:0]  i_p_cfg_addr                  ,
    input  [7:0]   i_p_cfg_wdata                 ,
    output [7:0]   o_p_cfg_rdata                 ,
    output         o_p_cfg_int                   ,
    output         o_p_cfg_ready                 ,
    input          i_p_l0rxn                     ,
    input          i_p_l0rxp                     ,
    input          i_p_l1rxn                     ,
    input          i_p_l1rxp                     ,
    input          i_p_l2rxn                     ,
    input          i_p_l2rxp                     ,
    input          i_p_l3rxn                     ,
    input          i_p_l3rxp                     ,
    output         o_p_l0txn                     ,
    output         o_p_l0txp                     ,
    output         o_p_l1txn                     ,
    output         o_p_l1txp                     ,
    output         o_p_l2txn                     ,
    output         o_p_l2txp                     ,
    output         o_p_l3txn                     ,
    output         o_p_l3txp                     ,
    input  [31:0]  i_txd_0                       ,
    input  [3:0]   i_tdispsel_0                  ,
    input  [3:0]   i_tdispctrl_0                 ,
    input  [3:0]   i_txk_0                       ,
    input  [31:0]  i_txd_1                       ,
    input  [3:0]   i_tdispsel_1                  ,
    input  [3:0]   i_tdispctrl_1                 ,
    input  [3:0]   i_txk_1                       ,
    input  [31:0]  i_txd_2                       ,
    input  [3:0]   i_tdispsel_2                  ,
    input  [3:0]   i_tdispctrl_2                 ,
    input  [3:0]   i_txk_2                       ,
    input  [31:0]  i_txd_3                       ,
    input  [3:0]   i_tdispsel_3                  ,
    input  [3:0]   i_tdispctrl_3                 ,
    input  [3:0]   i_txk_3                       ,
    output [2:0]   o_rxstatus_0                  ,
    output [31:0]  o_rxd_0                       ,
    output [3:0]   o_rdisper_0                   ,
    output [3:0]   o_rdecer_0                    ,
    output [3:0]   o_rxk_0                       ,
    output [2:0]   o_rxstatus_1                  ,
    output [31:0]  o_rxd_1                       ,
    output [3:0]   o_rdisper_1                   ,
    output [3:0]   o_rdecer_1                    ,
    output [3:0]   o_rxk_1                       ,
    output [2:0]   o_rxstatus_2                  ,
    output [31:0]  o_rxd_2                       ,
    output [3:0]   o_rdisper_2                   ,
    output [3:0]   o_rdecer_2                    ,
    output [3:0]   o_rxk_2                       ,
    output [2:0]   o_rxstatus_3                  ,
    output [31:0]  o_rxd_3                       ,
    output [3:0]   o_rdisper_3                   ,
    output [3:0]   o_rdecer_3                    ,
    output [3:0]   o_rxk_3                       ,
    input          i_p_pllpowerdown_0              
);


// ********************* UI parameters *********************


//-- wire INNER RESET & HSST  ---//

wire            P_PLL_READY_0           ; // input  wire                    
wire            P_PLL_READY_1           ; // input  wire                    
wire            P_RX_SIGDET_STATUS_0    ; // input  wire                    
wire            P_RX_SIGDET_STATUS_1    ; // input  wire                    
wire            P_RX_SIGDET_STATUS_2    ; // input  wire                    
wire            P_RX_SIGDET_STATUS_3    ; // input  wire                    
wire            P_LX_CDR_ALIGN_0        ; // input  wire                    
wire            P_LX_CDR_ALIGN_1        ; // input  wire                    
wire            P_LX_CDR_ALIGN_2        ; // input  wire                    
wire            P_LX_CDR_ALIGN_3        ; // input  wire                    
wire            P_PLLPOWERDOWN_0        ; // output wire                    
wire            P_PLLPOWERDOWN_1        ; // output wire                    
wire            P_PLL_RST_0             ; // output wire                    
wire            P_PLL_RST_1             ; // output wire                    
wire            P_LANE_SYNC_0           ; // output wire                    
wire            P_LANE_SYNC_1           ; // output wire
wire            P_LANE_SYNC_EN_0        ; // output wire
wire            P_LANE_SYNC_EN_1        ; // output wire
wire            P_RATE_CHANGE_TCLK_ON_0 ; // output wire                   
wire            P_RATE_CHANGE_TCLK_ON_1 ; // output wire                   
wire            P_TX_LANE_PD_0          ; // output wire                   
wire            P_TX_LANE_PD_1          ; // output wire                   
wire            P_TX_LANE_PD_2          ; // output wire                   
wire            P_TX_LANE_PD_3          ; // output wire                   
wire    [2 : 0] P_TX_RATE_0             ; // output wire    [2 : 0]         
wire    [2 : 0] P_TX_RATE_1             ; // output wire    [2 : 0]         
wire    [2 : 0] P_TX_RATE_2             ; // output wire    [2 : 0]         
wire    [2 : 0] P_TX_RATE_3             ; // output wire    [2 : 0]         
wire            P_TX_PMA_RST_0          ; // output wire                    
wire            P_TX_PMA_RST_1          ; // output wire                    
wire            P_TX_PMA_RST_2          ; // output wire                    
wire            P_TX_PMA_RST_3          ; // output wire                    
wire            P_PCS_TX_RST_0          ; // output wire                    
wire            P_PCS_TX_RST_1          ; // output wire                    
wire            P_PCS_TX_RST_2          ; // output wire                    
wire            P_PCS_TX_RST_3          ; // output wire                    
wire            P_RX_PMA_RST_0          ; // output wire                    
wire            P_RX_PMA_RST_1          ; // output wire                    
wire            P_RX_PMA_RST_2          ; // output wire                    
wire            P_RX_PMA_RST_3          ; // output wire                    
wire            P_LANE_PD_0             ; // output wire                    
wire            P_LANE_PD_1             ; // output wire                    
wire            P_LANE_PD_2             ; // output wire                    
wire            P_LANE_PD_3             ; // output wire                    
wire            P_LANE_RST_0            ; // output wire                    
wire            P_LANE_RST_1            ; // output wire                    
wire            P_LANE_RST_2            ; // output wire                    
wire            P_LANE_RST_3            ; // output wire                    
wire            P_RX_LANE_PD_0          ; // output wire                    
wire            P_RX_LANE_PD_1          ; // output wire                    
wire            P_RX_LANE_PD_2          ; // output wire                    
wire            P_RX_LANE_PD_3          ; // output wire                    
wire            P_PCS_RX_RST_0          ; // output wire                    
wire            P_PCS_RX_RST_1          ; // output wire                    
wire            P_PCS_RX_RST_2          ; // output wire                    
wire            P_PCS_RX_RST_3          ; // output wire                    
wire    [2 : 0] P_RX_RATE_0             ; // output wire    [2 : 0]          
wire    [2 : 0] P_RX_RATE_1             ; // output wire    [2 : 0]         
wire    [2 : 0] P_RX_RATE_2             ; // output wire    [2 : 0]         
wire    [2 : 0] P_RX_RATE_3             ; // output wire    [2 : 0]         
wire            P_PCS_CB_RST_0          ; // output wire                    
wire            P_PCS_CB_RST_1          ; // output wire                    
wire            P_PCS_CB_RST_2          ; // output wire                    
wire            P_PCS_CB_RST_3          ; // output wire                    
wire            i_force_rxfsm_det_0     ; // input  wire                    
wire            i_force_rxfsm_det_1     ; // input  wire                    
wire            i_force_rxfsm_det_2     ; // input  wire                    
wire            i_force_rxfsm_det_3     ; // input  wire                    
wire            i_force_rxfsm_cdr_0     ; // input  wire                    
wire            i_force_rxfsm_cdr_1     ; // input  wire                    
wire            i_force_rxfsm_cdr_2     ; // input  wire                    
wire            i_force_rxfsm_cdr_3     ; // input  wire                    
wire            i_force_rxfsm_lsm_0     ; // input  wire                    
wire            i_force_rxfsm_lsm_1     ; // input  wire                    
wire            i_force_rxfsm_lsm_2     ; // input  wire                    
wire            i_force_rxfsm_lsm_3     ; // input  wire                    

wire    [3:0]   P_TCLK2FABRIC           ; // output wire    
wire    [3:0]   P_RCLK2FABRIC           ; // output wire    
wire    [3:0]   P_PCS_WORD_ALIGN_EN     ; // input  wire    
wire    [3:0]   P_RX_POLARITY_INVERT    ; // input  wire    
wire    [3:0]   P_PCS_MCB_EXT_EN        ; // input  wire    
wire    [3:0]   P_PCS_LSM_SYNCED        ; // output wire    
wire    [3:0]   P_PCS_RX_MCB_STATUS     ; // output wire    
wire    [3:0]   P_PCS_NEAREND_LOOP      ; // input  wire    
wire    [3:0]   P_PCS_FAREND_LOOP       ; // input  wire    
wire    [3:0]   P_PMA_NEAREND_PLOOP     ; // input  wire    
wire    [3:0]   P_PMA_NEAREND_SLOOP     ; // input  wire    
wire    [3:0]   P_PMA_FAREND_PLOOP      ; // input  wire    


wire         i_free_clk                    = 1'b0;
wire         i_pll_rst_0                   = 1'b0;
wire         i_pll_rst_1                   = 1'b0;
wire         i_wtchdg_clr_0                = 1'b0;
wire         i_wtchdg_clr_1                = 1'b0;
wire         i_lane_pd_0                   = 1'b0;
wire         i_lane_pd_1                   = 1'b0;
wire         i_lane_pd_2                   = 1'b0;
wire         i_lane_pd_3                   = 1'b0;
wire         i_txlane_rst_0                = 1'b0;
wire         i_txlane_rst_1                = 1'b0;
wire         i_txlane_rst_2                = 1'b0;
wire         i_txlane_rst_3                = 1'b0;
wire         i_rxlane_rst_0                = 1'b0;
wire         i_rxlane_rst_1                = 1'b0;
wire         i_rxlane_rst_2                = 1'b0;
wire         i_rxlane_rst_3                = 1'b0;
wire         i_tx_rate_chng_0              = 1'b0;
wire         i_tx_rate_chng_1              = 1'b0;
wire         i_tx_rate_chng_2              = 1'b0;
wire         i_tx_rate_chng_3              = 1'b0;     
wire [1:0]   i_txckdiv_0                   = 3                             ;
wire [1:0]   i_txckdiv_1                   = 3                             ;
wire [1:0]   i_txckdiv_2                   = 3                             ;
wire [1:0]   i_txckdiv_3                   = 3                             ;
wire         i_rx_rate_chng_0              = 1'b0;
wire         i_rx_rate_chng_1              = 1'b0;
wire         i_rx_rate_chng_2              = 1'b0;
wire         i_rx_rate_chng_3              = 1'b0;   
wire [1:0]   i_rxckdiv_0                   = 3                             ;
wire [1:0]   i_rxckdiv_1                   = 3                             ;
wire [1:0]   i_rxckdiv_2                   = 3                             ;
wire [1:0]   i_rxckdiv_3                   = 3                             ;
wire         i_pcs_cb_rst_0                = 1'b0;         
wire         i_hsst_fifo_clr_0             = 1'b0;         
assign       i_force_rxfsm_det_0           = 1'b0;
assign       i_force_rxfsm_cdr_0           = 1'b0;
assign       i_force_rxfsm_lsm_0           = 1'b0;
wire         i_pcs_cb_rst_1                = 1'b0;         
wire         i_hsst_fifo_clr_1             = 1'b0;         
assign       i_force_rxfsm_det_1           = 1'b0;
assign       i_force_rxfsm_cdr_1           = 1'b0;
assign       i_force_rxfsm_lsm_1           = 1'b0;
wire         i_pcs_cb_rst_2                = 1'b0;         
wire         i_hsst_fifo_clr_2             = 1'b0;         
assign       i_force_rxfsm_det_2           = 1'b0;
assign       i_force_rxfsm_cdr_2           = 1'b0;
assign       i_force_rxfsm_lsm_2           = 1'b0;
wire         i_pcs_cb_rst_3                = 1'b0;         
wire         i_hsst_fifo_clr_3             = 1'b0;         
assign       i_force_rxfsm_det_3           = 1'b0;
assign       i_force_rxfsm_cdr_3           = 1'b0;
assign       i_force_rxfsm_lsm_3           = 1'b0;
wire [1:0]   o_wtchdg_st_0                 ;
wire [1:0]   o_wtchdg_st_1                 ;
wire         o_pll_done_0                  ;
wire         o_pll_done_1                  ;
wire         o_txlane_done_0               ;
wire         o_txlane_done_1               ;
wire         o_txlane_done_2               ;
wire         o_txlane_done_3               ;
wire         o_tx_ckdiv_done_0             ;
wire         o_tx_ckdiv_done_1             ;
wire         o_tx_ckdiv_done_2             ;
wire         o_tx_ckdiv_done_3             ;
wire         o_rxlane_done_0               ;
wire         o_rxlane_done_1               ;
wire         o_rxlane_done_2               ;
wire         o_rxlane_done_3               ;
wire         o_rx_ckdiv_done_0             ;
wire         o_rx_ckdiv_done_1             ;
wire         o_rx_ckdiv_done_2             ;
wire         o_rx_ckdiv_done_3             ;
wire         i_p_pllpowerdown_1            = 1'b1;
assign       o_p_clk2core_tx_0             = P_TCLK2FABRIC[0];
wire         i_pll_lock_tx_0               = 1'b1;
wire         i_pll_lock_tx_1               = 1'b1;
wire         i_pll_lock_tx_2               = 1'b1;
wire         i_pll_lock_tx_3               = 1'b1;
assign       o_p_clk2core_rx_0             = P_RCLK2FABRIC[0];
wire         i_pll_lock_rx_0               = 1'b1;
wire         i_pll_lock_rx_1               = 1'b1;
wire         i_pll_lock_rx_2               = 1'b1;
wire         i_pll_lock_rx_3               = 1'b1;
wire         o_p_refck2core_0              ;
wire         o_p_refck2core_1              ;
wire         i_p_pll_rst_1                 = 1'b1;
wire         i_p_rx_highz_0                =1'b0;
wire         i_p_rx_highz_1                =1'b0;
wire         i_p_rx_highz_2                =1'b0;
wire         i_p_rx_highz_3                =1'b0;
wire         i_p_lane_sync_1               =1'b0;
wire         i_p_lane_sync_en_1            =1'b0;
wire         i_p_rate_change_tclk_on_1     =1'b1;
assign       o_p_pll_lock_0                = P_PLL_READY_0;
assign       o_p_rx_sigdet_sta_0           = P_RX_SIGDET_STATUS_0;
assign       o_p_rx_sigdet_sta_1           = P_RX_SIGDET_STATUS_1;
assign       o_p_rx_sigdet_sta_2           = P_RX_SIGDET_STATUS_2;
assign       o_p_rx_sigdet_sta_3           = P_RX_SIGDET_STATUS_3;
assign       o_p_lx_cdr_align_0            = P_LX_CDR_ALIGN_0;
assign       o_p_lx_cdr_align_1            = P_LX_CDR_ALIGN_1;
assign       o_p_lx_cdr_align_2            = P_LX_CDR_ALIGN_2;
assign       o_p_lx_cdr_align_3            = P_LX_CDR_ALIGN_3;
wire [1:0]   o_p_lx_oob_sta_0              ;
wire [1:0]   o_p_lx_oob_sta_1              ;
wire [1:0]   o_p_lx_oob_sta_2              ;
wire [1:0]   o_p_lx_oob_sta_3              ;
wire         i_p_rxgear_slip_0             = 1'b0;
wire         i_p_rxgear_slip_1             = 1'b0;
wire         i_p_rxgear_slip_2             = 1'b0;
wire         i_p_rxgear_slip_3             = 1'b0;
assign       P_PCS_WORD_ALIGN_EN[0]        = 1'b0;
assign       P_PCS_WORD_ALIGN_EN[1]        = 1'b0;
assign       P_PCS_WORD_ALIGN_EN[2]        = 1'b0;
assign       P_PCS_WORD_ALIGN_EN[3]        = 1'b0;
assign       P_PCS_MCB_EXT_EN[0]           = 1'b0;
assign       P_PCS_MCB_EXT_EN[1]           = 1'b0;
assign       P_PCS_MCB_EXT_EN[2]           = 1'b0;
assign       P_PCS_MCB_EXT_EN[3]           = 1'b0;
assign       o_p_pcs_lsm_synced_0          = P_PCS_LSM_SYNCED[0];
assign       o_p_pcs_lsm_synced_1          = P_PCS_LSM_SYNCED[1];
assign       o_p_pcs_lsm_synced_2          = P_PCS_LSM_SYNCED[2];
assign       o_p_pcs_lsm_synced_3          = P_PCS_LSM_SYNCED[3];
assign       P_PCS_NEAREND_LOOP[0]         = i_p_pcs_nearend_loop_0; 
assign       P_PCS_FAREND_LOOP[0]          = i_p_pcs_farend_loop_0;  
assign       P_PMA_NEAREND_PLOOP[0]        = i_p_pma_nearend_ploop_0;
assign       P_PMA_NEAREND_SLOOP[0]        = i_p_pma_nearend_sloop_0;
assign       P_PMA_FAREND_PLOOP[0]         = i_p_pma_farend_ploop_0; 
assign       P_PCS_NEAREND_LOOP[1]         = i_p_pcs_nearend_loop_1; 
assign       P_PCS_FAREND_LOOP[1]          = i_p_pcs_farend_loop_1;  
assign       P_PMA_NEAREND_PLOOP[1]        = i_p_pma_nearend_ploop_1;
assign       P_PMA_NEAREND_SLOOP[1]        = i_p_pma_nearend_sloop_1;
assign       P_PMA_FAREND_PLOOP[1]         = i_p_pma_farend_ploop_1; 
assign       P_PCS_NEAREND_LOOP[2]         = i_p_pcs_nearend_loop_2; 
assign       P_PCS_FAREND_LOOP[2]          = i_p_pcs_farend_loop_2;  
assign       P_PMA_NEAREND_PLOOP[2]        = i_p_pma_nearend_ploop_2;
assign       P_PMA_NEAREND_SLOOP[2]        = i_p_pma_nearend_sloop_2;
assign       P_PMA_FAREND_PLOOP[2]         = i_p_pma_farend_ploop_2; 
assign       P_PCS_NEAREND_LOOP[3]         = i_p_pcs_nearend_loop_3; 
assign       P_PCS_FAREND_LOOP[3]          = i_p_pcs_farend_loop_3;  
assign       P_PMA_NEAREND_PLOOP[3]        = i_p_pma_nearend_ploop_3;
assign       P_PMA_NEAREND_SLOOP[3]        = i_p_pma_nearend_sloop_3;
assign       P_PMA_FAREND_PLOOP[3]         = i_p_pma_farend_ploop_3; 
assign       P_RX_POLARITY_INVERT[0]       = i_p_rx_polarity_invert_0;
assign       P_RX_POLARITY_INVERT[1]       = i_p_rx_polarity_invert_1;
assign       P_RX_POLARITY_INVERT[2]       = i_p_rx_polarity_invert_2;
assign       P_RX_POLARITY_INVERT[3]       = i_p_rx_polarity_invert_3;
wire [45:0]  i_p_tdata_0                   = {i_p_lx_elecidle_en_0,
                                              i_txk_0[3],i_tdispctrl_0[3],i_tdispsel_0[3],i_txd_0[31:24],
                                              i_txk_0[2],i_tdispctrl_0[2],i_tdispsel_0[2],i_txd_0[23:16],
                                              i_txk_0[1],i_tdispctrl_0[1],i_tdispsel_0[1],i_txd_0[15:8],
                                              i_txk_0[0],i_tdispctrl_0[0],i_tdispsel_0[0],i_txd_0[7:0]};
wire [45:0]  i_p_tdata_1                   = {i_p_lx_elecidle_en_1,
                                              i_txk_1[3],i_tdispctrl_1[3],i_tdispsel_1[3],i_txd_1[31:24],
                                              i_txk_1[2],i_tdispctrl_1[2],i_tdispsel_1[2],i_txd_1[23:16],
                                              i_txk_1[1],i_tdispctrl_1[1],i_tdispsel_1[1],i_txd_1[15:8],
                                              i_txk_1[0],i_tdispctrl_1[0],i_tdispsel_1[0],i_txd_1[7:0]};
wire [45:0]  i_p_tdata_2                   = {i_p_lx_elecidle_en_2,
                                              i_txk_2[3],i_tdispctrl_2[3],i_tdispsel_2[3],i_txd_2[31:24],
                                              i_txk_2[2],i_tdispctrl_2[2],i_tdispsel_2[2],i_txd_2[23:16],
                                              i_txk_2[1],i_tdispctrl_2[1],i_tdispsel_2[1],i_txd_2[15:8],
                                              i_txk_2[0],i_tdispctrl_2[0],i_tdispsel_2[0],i_txd_2[7:0]};
wire [45:0]  i_p_tdata_3                   = {i_p_lx_elecidle_en_3,
                                              i_txk_3[3],i_tdispctrl_3[3],i_tdispsel_3[3],i_txd_3[31:24],
                                              i_txk_3[2],i_tdispctrl_3[2],i_tdispsel_3[2],i_txd_3[23:16],
                                              i_txk_3[1],i_tdispctrl_3[1],i_tdispsel_3[1],i_txd_3[15:8],
                                              i_txk_3[0],i_tdispctrl_3[0],i_tdispsel_3[0],i_txd_3[7:0]};
wire [46:0]  o_p_rdata_0                   ;

assign       o_rxstatus_0                  = o_p_rdata_0[46:44];
assign       o_rxd_0                       = {o_p_rdata_0[40:33],o_p_rdata_0[29:22],o_p_rdata_0[18:11],o_p_rdata_0[7:0]};
assign       o_rdisper_0                   = {o_p_rdata_0[41],o_p_rdata_0[30],o_p_rdata_0[19],o_p_rdata_0[8]};
assign       o_rdecer_0                    = {o_p_rdata_0[42],o_p_rdata_0[31],o_p_rdata_0[20],o_p_rdata_0[9]};
assign       o_rxk_0                       = {o_p_rdata_0[43],o_p_rdata_0[32],o_p_rdata_0[21],o_p_rdata_0[10]};
wire [46:0]  o_p_rdata_1                   ;

assign       o_rxstatus_1                  = o_p_rdata_1[46:44];
assign       o_rxd_1                       = {o_p_rdata_1[40:33],o_p_rdata_1[29:22],o_p_rdata_1[18:11],o_p_rdata_1[7:0]};
assign       o_rdisper_1                   = {o_p_rdata_1[41],o_p_rdata_1[30],o_p_rdata_1[19],o_p_rdata_1[8]};
assign       o_rdecer_1                    = {o_p_rdata_1[42],o_p_rdata_1[31],o_p_rdata_1[20],o_p_rdata_1[9]};
assign       o_rxk_1                       = {o_p_rdata_1[43],o_p_rdata_1[32],o_p_rdata_1[21],o_p_rdata_1[10]};
wire [46:0]  o_p_rdata_2                   ;

assign       o_rxstatus_2                  = o_p_rdata_2[46:44];
assign       o_rxd_2                       = {o_p_rdata_2[40:33],o_p_rdata_2[29:22],o_p_rdata_2[18:11],o_p_rdata_2[7:0]};
assign       o_rdisper_2                   = {o_p_rdata_2[41],o_p_rdata_2[30],o_p_rdata_2[19],o_p_rdata_2[8]};
assign       o_rdecer_2                    = {o_p_rdata_2[42],o_p_rdata_2[31],o_p_rdata_2[20],o_p_rdata_2[9]};
assign       o_rxk_2                       = {o_p_rdata_2[43],o_p_rdata_2[32],o_p_rdata_2[21],o_p_rdata_2[10]};
wire [46:0]  o_p_rdata_3                   ;

assign       o_rxstatus_3                  = o_p_rdata_3[46:44];
assign       o_rxd_3                       = {o_p_rdata_3[40:33],o_p_rdata_3[29:22],o_p_rdata_3[18:11],o_p_rdata_3[7:0]};
assign       o_rdisper_3                   = {o_p_rdata_3[41],o_p_rdata_3[30],o_p_rdata_3[19],o_p_rdata_3[8]};
assign       o_rdecer_3                    = {o_p_rdata_3[42],o_p_rdata_3[31],o_p_rdata_3[20],o_p_rdata_3[9]};
assign       o_rxk_3                       = {o_p_rdata_3[43],o_p_rdata_3[32],o_p_rdata_3[21],o_p_rdata_3[10]};


ipml_hsst_rst_v1_1#(    
    .INNER_RST_EN                  ("FALSE"                       ), //TRUE: HSST Reset Auto Control, FALSE: HSST Reset Control by User
    .FREE_CLOCK_FREQ               (100.0                         ), //Unit is MHz, free clock  freq from GUI Freq: 0~200MHz 
    .CH0_TX_ENABLE                 ("TRUE"                        ), //TRUE:lane0 TX Reset Logic used, FALSE: lane0 TX Reset Logic remove 
    .CH1_TX_ENABLE                 ("TRUE"                        ), //TRUE:lane1 TX Reset Logic used, FALSE: lane1 TX Reset Logic remove 
    .CH2_TX_ENABLE                 ("TRUE"                        ), //TRUE:lane2 TX Reset Logic used, FALSE: lane2 TX Reset Logic remove 
    .CH3_TX_ENABLE                 ("TRUE"                        ), //TRUE:lane3 TX Reset Logic used, FALSE: lane3 TX Reset Logic remove 
    .CH0_RX_ENABLE                 ("TRUE"                        ), //TRUE:lane0 RX Reset Logic used, FALSE: lane0 RX Reset Logic remove 
    .CH1_RX_ENABLE                 ("TRUE"                        ), //TRUE:lane1 RX Reset Logic used, FALSE: lane1 RX Reset Logic remove
    .CH2_RX_ENABLE                 ("TRUE"                        ), //TRUE:lane2 RX Reset Logic used, FALSE: lane2 RX Reset Logic remove
    .CH3_RX_ENABLE                 ("TRUE"                        ), //TRUE:lane3 RX Reset Logic used, FALSE: lane3 RX Reset Logic remove
    .CH0_MULT_LANE_MODE            (4                             ), //Lane0 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    .CH1_MULT_LANE_MODE            (4                             ), //Lane1 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    .CH2_MULT_LANE_MODE            (4                             ), //Lane2 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    .CH3_MULT_LANE_MODE            (4                             ), //Lane3 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    .CH0_RXPCS_ALIGN_TIMER         (65535                         ), //Word Alignment Wait time, when match the RXPMA will be Reset
    .CH1_RXPCS_ALIGN_TIMER         (65535                         ), //Word Alignment Wait time, when match the RXPMA will be Reset
    .CH2_RXPCS_ALIGN_TIMER         (65535                         ), //Word Alignment Wait time, when match the RXPMA will be Reset
    .CH3_RXPCS_ALIGN_TIMER         (65535                         ), //Word Alignment Wait time, when match the RXPMA will be Reset
    .PCS_CH0_BYPASS_WORD_ALIGN     ("FALSE"                       ), //TRUE: Lane0 Bypass Word Alignment or OUTSIDE Mode, FALSE: Lane0 No Bypass Word Alignment
    .PCS_CH1_BYPASS_WORD_ALIGN     ("FALSE"                       ), //TRUE: Lane1 Bypass Word Alignment or OUTSIDE Mode, FALSE: Lane1 No Bypass Word Alignment
    .PCS_CH2_BYPASS_WORD_ALIGN     ("FALSE"                       ), //TRUE: Lane2 Bypass Word Alignment or OUTSIDE Mode, FALSE: Lane0 No Bypass Word Alignment
    .PCS_CH3_BYPASS_WORD_ALIGN     ("FALSE"                       ), //TRUE: Lane3 Bypass Word Alignment or OUTSIDE Mode, FALSE: Lane0 No Bypass Word Alignment
    .PCS_CH0_BYPASS_BONDING        ("TRUE"                        ), //TRUE: Lane0 Bypass Channel Bonding, FALSE: Lane0 No Bypass Channel Bonding
    .PCS_CH1_BYPASS_BONDING        ("TRUE"                        ), //TRUE: Lane1 Bypass Channel Bonding, FALSE: Lane1 No Bypass Channel Bonding
    .PCS_CH2_BYPASS_BONDING        ("TRUE"                        ), //TRUE: Lane2 Bypass Channel Bonding, FALSE: Lane2 No Bypass Channel Bonding
    .PCS_CH3_BYPASS_BONDING        ("TRUE"                        ), //TRUE: Lane3 Bypass Channel Bonding, FALSE: Lane3 No Bypass Channel Bonding
    .PCS_CH0_BYPASS_CTC            ("FALSE"                       ), //TRUE: Lane0 Bypass CTC, FALSE: Lane0 No Bypass CTC
    .PCS_CH1_BYPASS_CTC            ("FALSE"                       ), //TRUE: Lane1 Bypass CTC, FALSE: Lane1 No Bypass CTC
    .PCS_CH2_BYPASS_CTC            ("FALSE"                       ), //TRUE: Lane2 Bypass CTC, FALSE: Lane2 No Bypass CTC
    .PCS_CH3_BYPASS_CTC            ("FALSE"                       ), //TRUE: Lane3 Bypass CTC, FALSE: Lane3 No Bypass CTC
    .P_LX_TX_CKDIV_0               (3                             ), //TX initial clock division value
    .P_LX_TX_CKDIV_1               (3                             ), //TX initial clock division value
    .P_LX_TX_CKDIV_2               (3                             ), //TX initial clock division value
    .P_LX_TX_CKDIV_3               (3                             ), //TX initial clock division value
    .LX_RX_CKDIV_0                 (3                             ), //RX initial clock division value
    .LX_RX_CKDIV_1                 (3                             ), //RX initial clock division value
    .LX_RX_CKDIV_2                 (3                             ), //RX initial clock division value
    .LX_RX_CKDIV_3                 (3                             ), //RX initial clock division value
    .CH0_TX_PLL_SEL                (0                             ), //Lane0 --> 1:PLL1  0:PLL0
    .CH1_TX_PLL_SEL                (0                             ), //Lane1 --> 1:PLL1  0:PLL0
    .CH2_TX_PLL_SEL                (0                             ), //Lane2 --> 1:PLL1  0:PLL0
    .CH3_TX_PLL_SEL                (0                             ), //Lane3 --> 1:PLL1  0:PLL0
    .CH0_RX_PLL_SEL                (0                             ), //Lane0 --> 1:PLL1  0:PLL0
    .CH1_RX_PLL_SEL                (0                             ), //Lane1 --> 1:PLL1  0:PLL0
    .CH2_RX_PLL_SEL                (0                             ), //Lane2 --> 1:PLL1  0:PLL0
    .CH3_RX_PLL_SEL                (0                             ), //Lane3 --> 1:PLL1  0:PLL0
    .PLL_NUBER                     (1                             ), //1 or 2          
    .PCS_TX_CLK_EXPLL_USE_CH0      ("TRUE"                        ), //
    .PCS_TX_CLK_EXPLL_USE_CH1      ("TRUE"                        ), //
    .PCS_TX_CLK_EXPLL_USE_CH2      ("TRUE"                        ), //
    .PCS_TX_CLK_EXPLL_USE_CH3      ("TRUE"                        ), //
    .PCS_RX_CLK_EXPLL_USE_CH0      ("TRUE"                        ), //
    .PCS_RX_CLK_EXPLL_USE_CH1      ("TRUE"                        ), //
    .PCS_RX_CLK_EXPLL_USE_CH2      ("TRUE"                        ), //
    .PCS_RX_CLK_EXPLL_USE_CH3      ("TRUE"                        )  //
) U_IPML_HSST_RST (
    //BOTH NEED
    .i_pll_lock_tx_0               (i_pll_lock_tx_0               ), // input  wire                   
    .i_pll_lock_tx_1               (i_pll_lock_tx_1               ), // input  wire                   
    .i_pll_lock_tx_2               (i_pll_lock_tx_2               ), // input  wire                   
    .i_pll_lock_tx_3               (i_pll_lock_tx_3               ), // input  wire                   
    .i_pll_lock_rx_0               (i_pll_lock_rx_0               ), // input  wire                   
    .i_pll_lock_rx_1               (i_pll_lock_rx_1               ), // input  wire                   
    .i_pll_lock_rx_2               (i_pll_lock_rx_2               ), // input  wire                   
    .i_pll_lock_rx_3               (i_pll_lock_rx_3               ), // input  wire                   
    //--- User Side ---
    //INNER_RST_EN is TRUE 
    .i_free_clk                    (i_free_clk                    ), // input  wire                    
    .i_pll_rst_0                   (i_pll_rst_0                   ), // input  wire                    
    .i_pll_rst_1                   (i_pll_rst_1                   ), // input  wire                    
    .i_wtchdg_clr_0                (i_wtchdg_clr_0                ), // input  wire                    
    .i_wtchdg_clr_1                (i_wtchdg_clr_1                ), // input  wire
    .i_lane_pd_0                   (i_lane_pd_0                   ), // input  wire
    .i_lane_pd_1                   (i_lane_pd_1                   ), // input  wire
    .i_lane_pd_2                   (i_lane_pd_2                   ), // input  wire
    .i_lane_pd_3                   (i_lane_pd_3                   ), // input  wire
    .i_txlane_rst_0                (i_txlane_rst_0                ), // input  wire                    
    .i_txlane_rst_1                (i_txlane_rst_1                ), // input  wire                    
    .i_txlane_rst_2                (i_txlane_rst_2                ), // input  wire                    
    .i_txlane_rst_3                (i_txlane_rst_3                ), // input  wire                    
    .i_rxlane_rst_0                (i_rxlane_rst_0                ), // input  wire                    
    .i_rxlane_rst_1                (i_rxlane_rst_1                ), // input  wire                    
    .i_rxlane_rst_2                (i_rxlane_rst_2                ), // input  wire                    
    .i_rxlane_rst_3                (i_rxlane_rst_3                ), // input  wire                    
    .i_tx_rate_chng_0              (i_tx_rate_chng_0              ), // input  wire
    .i_tx_rate_chng_1              (i_tx_rate_chng_1              ), // input  wire
    .i_tx_rate_chng_2              (i_tx_rate_chng_2              ), // input  wire
    .i_tx_rate_chng_3              (i_tx_rate_chng_3              ), // input  wire
    .i_rx_rate_chng_0              (i_rx_rate_chng_0              ), // input  wire                    
    .i_rx_rate_chng_1              (i_rx_rate_chng_1              ), // input  wire                    
    .i_rx_rate_chng_2              (i_rx_rate_chng_2              ), // input  wire                    
    .i_rx_rate_chng_3              (i_rx_rate_chng_3              ), // input  wire                    
    .i_txckdiv_0                   (i_txckdiv_0                   ), // input  wire    [1 : 0]         
    .i_txckdiv_1                   (i_txckdiv_1                   ), // input  wire    [1 : 0]         
    .i_txckdiv_2                   (i_txckdiv_2                   ), // input  wire    [1 : 0]         
    .i_txckdiv_3                   (i_txckdiv_3                   ), // input  wire    [1 : 0]         
    .i_rxckdiv_0                   (i_rxckdiv_0                   ), // input  wire    [1 : 0]         
    .i_rxckdiv_1                   (i_rxckdiv_1                   ), // input  wire    [1 : 0]         
    .i_rxckdiv_2                   (i_rxckdiv_2                   ), // input  wire    [1 : 0]         
    .i_rxckdiv_3                   (i_rxckdiv_3                   ), // input  wire    [1 : 0]         
    .i_pcs_cb_rst_0                (i_pcs_cb_rst_0                ), // input  wire                    
    .i_pcs_cb_rst_1                (i_pcs_cb_rst_1                ), // input  wire                    
    .i_pcs_cb_rst_2                (i_pcs_cb_rst_2                ), // input  wire                    
    .i_pcs_cb_rst_3                (i_pcs_cb_rst_3                ), // input  wire                    
    .i_hsst_fifo_clr_0             (i_hsst_fifo_clr_0             ), // input  wire                    
    .i_hsst_fifo_clr_1             (i_hsst_fifo_clr_1             ), // input  wire                    
    .i_hsst_fifo_clr_2             (i_hsst_fifo_clr_2             ), // input  wire                    
    .i_hsst_fifo_clr_3             (i_hsst_fifo_clr_3             ), // input  wire         
    .i_force_rxfsm_det_0           (i_force_rxfsm_det_0           ), // input  wire                   Debug signal for loopback mode
    .i_force_rxfsm_lsm_0           (i_force_rxfsm_lsm_0           ), // input  wire                   Debug signal for loopback mode
    .i_force_rxfsm_cdr_0           (i_force_rxfsm_cdr_0           ), // input  wire                   Debug signal for loopback mode
    .i_force_rxfsm_det_1           (i_force_rxfsm_det_1           ), // input  wire                   Debug signal for loopback mode
    .i_force_rxfsm_lsm_1           (i_force_rxfsm_lsm_1           ), // input  wire                   Debug signal for loopback mode
    .i_force_rxfsm_cdr_1           (i_force_rxfsm_cdr_1           ), // input  wire                   Debug signal for loopback mode
    .i_force_rxfsm_det_2           (i_force_rxfsm_det_2           ), // input  wire                   Debug signal for loopback mode
    .i_force_rxfsm_lsm_2           (i_force_rxfsm_lsm_2           ), // input  wire                   Debug signal for loopback mode
    .i_force_rxfsm_cdr_2           (i_force_rxfsm_cdr_2           ), // input  wire                   Debug signal for loopback mode
    .i_force_rxfsm_det_3           (i_force_rxfsm_det_3           ), // input  wire                   Debug signal for loopback mode
    .i_force_rxfsm_lsm_3           (i_force_rxfsm_lsm_3           ), // input  wire                   Debug signal for loopback mode
    .i_force_rxfsm_cdr_3           (i_force_rxfsm_cdr_3           ), // input  wire                   Debug signal for loopback mode
    .o_wtchdg_st_0                 (o_wtchdg_st_0                 ), // output wire    [1 : 0]         
    .o_wtchdg_st_1                 (o_wtchdg_st_1                 ), // output wire    [1 : 0]         
    .o_pll_done_0                  (o_pll_done_0                  ), // output wire                    
    .o_pll_done_1                  (o_pll_done_1                  ), // output wire                    
    .o_txlane_done_0               (o_txlane_done_0               ), // output wire                    
    .o_txlane_done_1               (o_txlane_done_1               ), // output wire                    
    .o_txlane_done_2               (o_txlane_done_2               ), // output wire                    
    .o_txlane_done_3               (o_txlane_done_3               ), // output wire                    
    .o_tx_ckdiv_done_0             (o_tx_ckdiv_done_0             ), // output wire                    
    .o_tx_ckdiv_done_1             (o_tx_ckdiv_done_1             ), // output wire                    
    .o_tx_ckdiv_done_2             (o_tx_ckdiv_done_2             ), // output wire                    
    .o_tx_ckdiv_done_3             (o_tx_ckdiv_done_3             ), // output wire                    
    .o_rxlane_done_0               (o_rxlane_done_0               ), // output wire                    
    .o_rxlane_done_1               (o_rxlane_done_1               ), // output wire                    
    .o_rxlane_done_2               (o_rxlane_done_2               ), // output wire                    
    .o_rxlane_done_3               (o_rxlane_done_3               ), // output wire                    
    .o_rx_ckdiv_done_0             (o_rx_ckdiv_done_0             ), // output wire                    
    .o_rx_ckdiv_done_1             (o_rx_ckdiv_done_1             ), // output wire                    
    .o_rx_ckdiv_done_2             (o_rx_ckdiv_done_2             ), // output wire                    
    .o_rx_ckdiv_done_3             (o_rx_ckdiv_done_3             ), // output wire                    
    //INNER_RST_EN is FALSE
    .i_f_pllpowerdown_0            (i_p_pllpowerdown_0            ), // input  wire                   
    .i_f_pllpowerdown_1            (i_p_pllpowerdown_1            ), // input  wire                   
    .i_f_pll_rst_0                 (i_p_pll_rst_0                 ), // input  wire                   
    .i_f_pll_rst_1                 (i_p_pll_rst_1                 ), // input  wire                   
    .i_f_lane_sync_0               (i_p_lane_sync_0               ), // input  wire          
    .i_f_lane_sync_1               (i_p_lane_sync_1               ), // input  wire          
    .i_f_lane_sync_en_0            (i_p_lane_sync_en_0            ), // input  wire
    .i_f_lane_sync_en_1            (i_p_lane_sync_en_1            ), // input  wire
    .i_f_rate_change_tclk_on_0     (i_p_rate_change_tclk_on_0     ), // input  wire
    .i_f_rate_change_tclk_on_1     (i_p_rate_change_tclk_on_1     ), // input  wire
    .i_f_tx_lane_pd_0              (i_p_tx_lane_pd_0              ), // input  wire    
    .i_f_tx_lane_pd_1              (i_p_tx_lane_pd_1              ), // input  wire    
    .i_f_tx_lane_pd_2              (i_p_tx_lane_pd_2              ), // input  wire    
    .i_f_tx_lane_pd_3              (i_p_tx_lane_pd_3              ), // input  wire    
    .i_f_tx_pma_rst_0              (i_p_tx_pma_rst_0              ), // input  wire                   
    .i_f_tx_pma_rst_1              (i_p_tx_pma_rst_1              ), // input  wire                   
    .i_f_tx_pma_rst_2              (i_p_tx_pma_rst_2              ), // input  wire                   
    .i_f_tx_pma_rst_3              (i_p_tx_pma_rst_3              ), // input  wire                   
    .i_f_tx_ckdiv_0                (i_p_tx_ckdiv_0                ), // input  wire    [1 : 0]        
    .i_f_tx_ckdiv_1                (i_p_tx_ckdiv_1                ), // input  wire    [1 : 0]        
    .i_f_tx_ckdiv_2                (i_p_tx_ckdiv_2                ), // input  wire    [1 : 0]        
    .i_f_tx_ckdiv_3                (i_p_tx_ckdiv_3                ), // input  wire    [1 : 0]        
    .i_f_pcs_tx_rst_0              (i_p_pcs_tx_rst_0              ), // input  wire                   
    .i_f_pcs_tx_rst_1              (i_p_pcs_tx_rst_1              ), // input  wire                   
    .i_f_pcs_tx_rst_2              (i_p_pcs_tx_rst_2              ), // input  wire                   
    .i_f_pcs_tx_rst_3              (i_p_pcs_tx_rst_3              ), // input  wire                   
    .i_f_lane_pd_0                 (i_p_lane_pd_0                 ), // input  wire                   
    .i_f_lane_pd_1                 (i_p_lane_pd_1                 ), // input  wire                   
    .i_f_lane_pd_2                 (i_p_lane_pd_2                 ), // input  wire                   
    .i_f_lane_pd_3                 (i_p_lane_pd_3                 ), // input  wire                   
    .i_f_lane_rst_0                (i_p_lane_rst_0                ), // input  wire                   
    .i_f_lane_rst_1                (i_p_lane_rst_1                ), // input  wire                   
    .i_f_lane_rst_2                (i_p_lane_rst_2                ), // input  wire                   
    .i_f_lane_rst_3                (i_p_lane_rst_3                ), // input  wire                   
    .i_f_rx_lane_pd_0              (i_p_rx_lane_pd_0              ), // input  wire                   
    .i_f_rx_lane_pd_1              (i_p_rx_lane_pd_1              ), // input  wire                   
    .i_f_rx_lane_pd_2              (i_p_rx_lane_pd_2              ), // input  wire                   
    .i_f_rx_lane_pd_3              (i_p_rx_lane_pd_3              ), // input  wire                   
    .i_f_rx_pma_rst_0              (i_p_rx_pma_rst_0              ), // input  wire                   
    .i_f_rx_pma_rst_1              (i_p_rx_pma_rst_1              ), // input  wire                   
    .i_f_rx_pma_rst_2              (i_p_rx_pma_rst_2              ), // input  wire                   
    .i_f_rx_pma_rst_3              (i_p_rx_pma_rst_3              ), // input  wire                   
    .i_f_pcs_rx_rst_0              (i_p_pcs_rx_rst_0              ), // input  wire                   
    .i_f_pcs_rx_rst_1              (i_p_pcs_rx_rst_1              ), // input  wire                   
    .i_f_pcs_rx_rst_2              (i_p_pcs_rx_rst_2              ), // input  wire                   
    .i_f_pcs_rx_rst_3              (i_p_pcs_rx_rst_3              ), // input  wire                   
    .i_f_lx_rx_ckdiv_0             (i_p_lx_rx_ckdiv_0             ), // input  wire    [1 : 0]        
    .i_f_lx_rx_ckdiv_1             (i_p_lx_rx_ckdiv_1             ), // input  wire    [1 : 0]        
    .i_f_lx_rx_ckdiv_2             (i_p_lx_rx_ckdiv_2             ), // input  wire    [1 : 0]        
    .i_f_lx_rx_ckdiv_3             (i_p_lx_rx_ckdiv_3             ), // input  wire    [1 : 0]       
    .i_f_pcs_cb_rst_0              (i_p_pcs_cb_rst_0              ), // input  wire                   
    .i_f_pcs_cb_rst_1              (i_p_pcs_cb_rst_1              ), // input  wire                   
    .i_f_pcs_cb_rst_2              (i_p_pcs_cb_rst_2              ), // input  wire                   
    .i_f_pcs_cb_rst_3              (i_p_pcs_cb_rst_3              ), // input  wire                   

    //--- Hsst Side ---
    .P_PLL_READY_0                 (P_PLL_READY_0                 ), // input  wire                   
    .P_PLL_READY_1                 (P_PLL_READY_1                 ), // input  wire                   
    .P_RX_SIGDET_STATUS_0          (P_RX_SIGDET_STATUS_0          ), // input  wire                    
    .P_RX_SIGDET_STATUS_1          (P_RX_SIGDET_STATUS_1          ), // input  wire                    
    .P_RX_SIGDET_STATUS_2          (P_RX_SIGDET_STATUS_2          ), // input  wire                    
    .P_RX_SIGDET_STATUS_3          (P_RX_SIGDET_STATUS_3          ), // input  wire                    
    .P_RX_READY_0                  (P_LX_CDR_ALIGN_0              ), // input  wire                    
    .P_RX_READY_1                  (P_LX_CDR_ALIGN_1              ), // input  wire                    
    .P_RX_READY_2                  (P_LX_CDR_ALIGN_2              ), // input  wire                    
    .P_RX_READY_3                  (P_LX_CDR_ALIGN_3              ), // input  wire                    
    .P_PCS_LSM_SYNCED_0            (P_PCS_LSM_SYNCED[0]           ), // input  wire             
    .P_PCS_LSM_SYNCED_1            (P_PCS_LSM_SYNCED[1]           ), // input  wire             
    .P_PCS_LSM_SYNCED_2            (P_PCS_LSM_SYNCED[2]           ), // input  wire             
    .P_PCS_LSM_SYNCED_3            (P_PCS_LSM_SYNCED[3]           ), // input  wire             
    .P_PCS_RX_MCB_STATUS_0         (P_PCS_RX_MCB_STATUS[0]        ), // input  wire          
    .P_PCS_RX_MCB_STATUS_1         (P_PCS_RX_MCB_STATUS[1]        ), // input  wire          
    .P_PCS_RX_MCB_STATUS_2         (P_PCS_RX_MCB_STATUS[2]        ), // input  wire          
    .P_PCS_RX_MCB_STATUS_3         (P_PCS_RX_MCB_STATUS[3]        ), // input  wire          
    .P_PLLPOWERDOWN_0              (P_PLLPOWERDOWN_0              ), // output wire                    
    .P_PLLPOWERDOWN_1              (P_PLLPOWERDOWN_1              ), // output wire                    
    .P_PLL_RST_0                   (P_PLL_RST_0                   ), // output wire                    
    .P_PLL_RST_1                   (P_PLL_RST_1                   ), // output wire                    
    .P_LANE_SYNC_0                 (P_LANE_SYNC_0                 ), // output wire
    .P_LANE_SYNC_1                 (P_LANE_SYNC_1                 ), // output wire
    .P_LANE_SYNC_EN_0              (P_LANE_SYNC_EN_0              ), // output wire
    .P_LANE_SYNC_EN_1              (P_LANE_SYNC_EN_1              ), // output wire
    .P_RATE_CHANGE_TCLK_ON_0       (P_RATE_CHANGE_TCLK_ON_0       ), // output wire
    .P_RATE_CHANGE_TCLK_ON_1       (P_RATE_CHANGE_TCLK_ON_1       ), // output wire
    .P_TX_LANE_PD_0                (P_TX_LANE_PD_0                ), // output wire                   
    .P_TX_LANE_PD_1                (P_TX_LANE_PD_1                ), // output wire                   
    .P_TX_LANE_PD_2                (P_TX_LANE_PD_2                ), // output wire                   
    .P_TX_LANE_PD_3                (P_TX_LANE_PD_3                ), // output wire                   
    .P_TX_RATE_0                   (P_TX_RATE_0                   ), // output wire    [2 : 0]       
    .P_TX_RATE_1                   (P_TX_RATE_1                   ), // output wire    [2 : 0]       
    .P_TX_RATE_2                   (P_TX_RATE_2                   ), // output wire    [2 : 0]       
    .P_TX_RATE_3                   (P_TX_RATE_3                   ), // output wire    [2 : 0]       
    .P_TX_PMA_RST_0                (P_TX_PMA_RST_0                ), // output wire                    
    .P_TX_PMA_RST_1                (P_TX_PMA_RST_1                ), // output wire                    
    .P_TX_PMA_RST_2                (P_TX_PMA_RST_2                ), // output wire                    
    .P_TX_PMA_RST_3                (P_TX_PMA_RST_3                ), // output wire                    
    .P_PCS_TX_RST_0                (P_PCS_TX_RST_0                ), // output wire                    
    .P_PCS_TX_RST_1                (P_PCS_TX_RST_1                ), // output wire                    
    .P_PCS_TX_RST_2                (P_PCS_TX_RST_2                ), // output wire                    
    .P_PCS_TX_RST_3                (P_PCS_TX_RST_3                ), // output wire  
    .P_RX_PMA_RST_0                (P_RX_PMA_RST_0                ), // output wire                   
    .P_RX_PMA_RST_1                (P_RX_PMA_RST_1                ), // output wire                   
    .P_RX_PMA_RST_2                (P_RX_PMA_RST_2                ), // output wire                   
    .P_RX_PMA_RST_3                (P_RX_PMA_RST_3                ), // output wire                   
    .P_LANE_PD_0                   (P_LANE_PD_0                   ), // output wire                   
    .P_LANE_PD_1                   (P_LANE_PD_1                   ), // output wire                   
    .P_LANE_PD_2                   (P_LANE_PD_2                   ), // output wire                   
    .P_LANE_PD_3                   (P_LANE_PD_3                   ), // output wire                   
    .P_LANE_RST_0                  (P_LANE_RST_0                  ), // output wire                   
    .P_LANE_RST_1                  (P_LANE_RST_1                  ), // output wire                   
    .P_LANE_RST_2                  (P_LANE_RST_2                  ), // output wire                   
    .P_LANE_RST_3                  (P_LANE_RST_3                  ), // output wire                   
    .P_RX_LANE_PD_0                (P_RX_LANE_PD_0                ), // output wire                   
    .P_RX_LANE_PD_1                (P_RX_LANE_PD_1                ), // output wire                   
    .P_RX_LANE_PD_2                (P_RX_LANE_PD_2                ), // output wire                   
    .P_RX_LANE_PD_3                (P_RX_LANE_PD_3                ), // output wire                   
    .P_PCS_RX_RST_0                (P_PCS_RX_RST_0                ), // output wire                   
    .P_PCS_RX_RST_1                (P_PCS_RX_RST_1                ), // output wire                   
    .P_PCS_RX_RST_2                (P_PCS_RX_RST_2                ), // output wire                   
    .P_PCS_RX_RST_3                (P_PCS_RX_RST_3                ), // output wire                   
    .P_RX_RATE_0                   (P_RX_RATE_0                   ), // output wire    [2 : 0]         
    .P_RX_RATE_1                   (P_RX_RATE_1                   ), // output wire    [2 : 0]        
    .P_RX_RATE_2                   (P_RX_RATE_2                   ), // output wire    [2 : 0]        
    .P_RX_RATE_3                   (P_RX_RATE_3                   ), // output wire    [2 : 0]       
    .P_PCS_CB_RST_0                (P_PCS_CB_RST_0                ), // output wire
    .P_PCS_CB_RST_1                (P_PCS_CB_RST_1                ), // output wire
    .P_PCS_CB_RST_2                (P_PCS_CB_RST_2                ), // output wire
    .P_PCS_CB_RST_3                (P_PCS_CB_RST_3                )  // output wire
);

ipml_pcie_hsst_x4_wrapper_v1_3e  U_GTP_HSST_WRAPPER ( 
    //APB
    .P_CFG_CLK                         (i_p_cfg_clk                  ), // input          
    .P_CFG_RST                         (i_p_cfg_rst                  ), // input          
    .P_CFG_PSEL                        (i_p_cfg_psel                 ), // input          
    .P_CFG_ENABLE                      (i_p_cfg_enable               ), // input          
    .P_CFG_WRITE                       (i_p_cfg_write                ), // input          
    .P_CFG_ADDR                        (i_p_cfg_addr                 ), // input  [15:0]  
    .P_CFG_WDATA                       (i_p_cfg_wdata                ), // input  [7:0]   
    .P_CFG_RDATA                       (o_p_cfg_rdata                ), // output [7:0]   
    .P_CFG_INT                         (o_p_cfg_int                  ), // output         
    .P_CFG_READY                       (o_p_cfg_ready                ), // output         
    //PLL Common
    .P_HSST_RST                        (1'b0                         ), // input to be done
    //PLL0
    .P_PLLPOWERDOWN_0                  (P_PLLPOWERDOWN_0             ), // input          
    .P_PLL_RST_0                       (P_PLL_RST_0                  ), // input          
    .P_LANE_SYNC_0                     (P_LANE_SYNC_0                ), // input 
    .P_LANE_SYNC_EN_0                  (P_LANE_SYNC_EN_0             ), // input to be done 
    .P_RATE_CHANGE_TCLK_ON_0           (P_RATE_CHANGE_TCLK_ON_0      ), // input

    .P_PLL_REF_CLK_0                   (1'b0                         ), // input     
    
    .P_REFCK2CORE_0                    (o_p_refck2core_0             ), // output         
    .P_PLL_READY_0                     (P_PLL_READY_0                ), // output         

            
    //PLL1
    .P_PLLPOWERDOWN_1                  (P_PLLPOWERDOWN_1             ), // input          
    .P_PLL_RST_1                       (P_PLL_RST_1                  ), // input          
    .P_LANE_SYNC_1                     (P_LANE_SYNC_1                ), // input    
    .P_LANE_SYNC_EN_1                  (P_LANE_SYNC_EN_1             ), // input to be done 
    .P_RATE_CHANGE_TCLK_ON_1           (P_RATE_CHANGE_TCLK_ON_1      ), // input   

    .P_PLL_REF_CLK_1                   (1'b0                         ), // input     
    
    .P_REFCK2CORE_1                    (o_p_refck2core_1             ), // output         
    .P_PLL_READY_1                     (P_PLL_READY_1                ), // output         
    

    .P_REFCLKN_1                       (i_p_refckn_1                 ), // input          
    .P_REFCLKP_1                       (i_p_refckp_1                 ), // input

    .P_TCLK2FABRIC                     (P_TCLK2FABRIC                ), // output
    .P_RCLK2FABRIC                     (P_RCLK2FABRIC                ), // output
    .P_PCS_WORD_ALIGN_EN               (P_PCS_WORD_ALIGN_EN          ), // input
    .P_RX_POLARITY_INVERT              (P_RX_POLARITY_INVERT         ), // input 
    .P_PCS_MCB_EXT_EN                  (P_PCS_MCB_EXT_EN             ), // input             
    .P_PCS_NEAREND_LOOP                (P_PCS_NEAREND_LOOP           ), // input             
    .P_PCS_FAREND_LOOP                 (P_PCS_FAREND_LOOP            ), // input             
    .P_PMA_NEAREND_PLOOP               (P_PMA_NEAREND_PLOOP          ), // input             
    .P_PMA_NEAREND_SLOOP               (P_PMA_NEAREND_SLOOP          ), // input             
    .P_PMA_FAREND_PLOOP                (P_PMA_FAREND_PLOOP           ), // input             
    .P_PCS_LSM_SYNCED                  (P_PCS_LSM_SYNCED             ), // output  
    .P_PCS_RX_MCB_STATUS               (P_PCS_RX_MCB_STATUS          ), // output   
    .P_TX_PMA_RST_0                    (P_TX_PMA_RST_0               ), // input               
    .P_TX_LANE_PD_0                    (P_TX_LANE_PD_0               ), // input               
    .P_LANE_PD_0                       (P_LANE_PD_0                  ), // input               
    .P_LANE_RST_0                      (P_LANE_RST_0                 ), // input               
    .P_RX_LANE_PD_0                    (P_RX_LANE_PD_0               ), // input               
    .P_TX0_CLK_FR_CORE                 (i_p_tx0_clk_fr_core          ), // input          
    .P_TX0_CLK2_FR_CORE                (i_p_tx0_clk2_fr_core         ), // input          
    .P_RX0_CLK_FR_CORE                 (i_p_rx0_clk_fr_core          ), // input          
    .P_RX0_CLK2_FR_CORE                (i_p_rx0_clk2_fr_core         ), // input          
    .P_RX_PMA_RST_0                    (P_RX_PMA_RST_0               ), // input          
    .P_PCS_TX_RST_0                    (P_PCS_TX_RST_0               ), // input          
    .P_PCS_RX_RST_0                    (P_PCS_RX_RST_0               ), // input          
    .P_PCS_CB_RST_0                    (P_PCS_CB_RST_0               ), // input          
    .P_TX_MARGIN_0                     (i_p_lx_margin_ctl_0          ), // input  [2:0]   
    .P_TX_SWING_0                      (i_p_lx_swing_ctl_0           ), // input          
    .P_TX_DEEMP_0                      (i_p_lx_deemp_ctl_0           ), // input  [1:0]  
    .P_RX_HIGHZ_0                      (i_p_rx_highz_0               ), // input 
    .P_TX_BEACON_EN_0                  (i_p_tx_beacon_en_0           ), // input              
    .P_RXGEAR_SLIP_0                   (i_p_rxgear_slip_0            ), // input              
    .P_TX_RATE_0                       (P_TX_RATE_0                  ), // input  [2:0]   
    .P_RX_RATE_0                       (P_RX_RATE_0                  ), // input  [2:0]   
    .P_RX_SIGDET_STATUS_0              (P_RX_SIGDET_STATUS_0         ), // output         
    .P_RX_READY_0                      (P_LX_CDR_ALIGN_0             ), // output         
    .P_RX_SATA_COMINIT_0               (o_p_lx_oob_sta_0[0]          ), // output         
    .P_RX_SATA_COMWAKE_0               (o_p_lx_oob_sta_0[1]          ), // output         
    .P_TX_RXDET_REQ_0                  (i_p_lx_rxdct_en_0            ), // input       
    .P_TX_RXDET_STATUS_0               (o_p_lx_rxdct_out_0           ), // output         
    .P_TDATA_0                         (i_p_tdata_0                  ), // input  [45:0]  
    .P_RDATA_0                         (o_p_rdata_0                  ), // output [46:0]  
    .P_TX_SDN0                         (o_p_l0txn                    ), // output         
    .P_TX_SDP0                         (o_p_l0txp                    ), // output         

    .P_RX_SDN0                         (i_p_l0rxn                    ),
    .P_RX_SDP0                         (i_p_l0rxp                    ),
    .P_TX_PMA_RST_1                    (P_TX_PMA_RST_1               ), // input               
    .P_TX_LANE_PD_1                    (P_TX_LANE_PD_1               ), // input               
    .P_LANE_PD_1                       (P_LANE_PD_1                  ), // input               
    .P_LANE_RST_1                      (P_LANE_RST_1                 ), // input               
    .P_RX_LANE_PD_1                    (P_RX_LANE_PD_1               ), // input               
    .P_TX1_CLK_FR_CORE                 (i_p_tx1_clk_fr_core          ), // input          
    .P_TX1_CLK2_FR_CORE                (i_p_tx1_clk2_fr_core         ), // input          
    .P_RX1_CLK_FR_CORE                 (i_p_rx1_clk_fr_core          ), // input          
    .P_RX1_CLK2_FR_CORE                (i_p_rx1_clk2_fr_core         ), // input          
    .P_RX_PMA_RST_1                    (P_RX_PMA_RST_1               ), // input          
    .P_PCS_TX_RST_1                    (P_PCS_TX_RST_1               ), // input          
    .P_PCS_RX_RST_1                    (P_PCS_RX_RST_1               ), // input          
    .P_PCS_CB_RST_1                    (P_PCS_CB_RST_1               ), // input          
    .P_TX_MARGIN_1                     (i_p_lx_margin_ctl_1          ), // input  [2:1]   
    .P_TX_SWING_1                      (i_p_lx_swing_ctl_1           ), // input          
    .P_TX_DEEMP_1                      (i_p_lx_deemp_ctl_1           ), // input  [1:1]  
    .P_RX_HIGHZ_1                      (i_p_rx_highz_1               ), // input 
    .P_TX_BEACON_EN_1                  (i_p_tx_beacon_en_1           ), // input              
    .P_RXGEAR_SLIP_1                   (i_p_rxgear_slip_1            ), // input              
    .P_TX_RATE_1                       (P_TX_RATE_1                  ), // input  [2:1]   
    .P_RX_RATE_1                       (P_RX_RATE_1                  ), // input  [2:1]   
    .P_RX_SIGDET_STATUS_1              (P_RX_SIGDET_STATUS_1         ), // output         
    .P_RX_READY_1                      (P_LX_CDR_ALIGN_1             ), // output         
    .P_RX_SATA_COMINIT_1               (o_p_lx_oob_sta_1[0]          ), // output         
    .P_RX_SATA_COMWAKE_1               (o_p_lx_oob_sta_1[1]          ), // output         
    .P_TX_RXDET_REQ_1                  (i_p_lx_rxdct_en_1            ), // input       
    .P_TX_RXDET_STATUS_1               (o_p_lx_rxdct_out_1           ), // output         
    .P_TDATA_1                         (i_p_tdata_1                  ), // input  [45:1]  
    .P_RDATA_1                         (o_p_rdata_1                  ), // output [46:1]  
    .P_TX_SDN1                         (o_p_l1txn                    ), // output         
    .P_TX_SDP1                         (o_p_l1txp                    ), // output         

    .P_RX_SDN1                         (i_p_l1rxn                    ),
    .P_RX_SDP1                         (i_p_l1rxp                    ),
    .P_TX_PMA_RST_2                    (P_TX_PMA_RST_2               ), // input               
    .P_TX_LANE_PD_2                    (P_TX_LANE_PD_2               ), // input               
    .P_LANE_PD_2                       (P_LANE_PD_2                  ), // input               
    .P_LANE_RST_2                      (P_LANE_RST_2                 ), // input               
    .P_RX_LANE_PD_2                    (P_RX_LANE_PD_2               ), // input               
    .P_TX2_CLK_FR_CORE                 (i_p_tx2_clk_fr_core          ), // input          
    .P_TX2_CLK2_FR_CORE                (i_p_tx2_clk2_fr_core         ), // input          
    .P_RX2_CLK_FR_CORE                 (i_p_rx2_clk_fr_core          ), // input          
    .P_RX2_CLK2_FR_CORE                (i_p_rx2_clk2_fr_core         ), // input          
    .P_RX_PMA_RST_2                    (P_RX_PMA_RST_2               ), // input          
    .P_PCS_TX_RST_2                    (P_PCS_TX_RST_2               ), // input          
    .P_PCS_RX_RST_2                    (P_PCS_RX_RST_2               ), // input          
    .P_PCS_CB_RST_2                    (P_PCS_CB_RST_2               ), // input          
    .P_TX_MARGIN_2                     (i_p_lx_margin_ctl_2          ), // input  [2:2]   
    .P_TX_SWING_2                      (i_p_lx_swing_ctl_2           ), // input          
    .P_TX_DEEMP_2                      (i_p_lx_deemp_ctl_2           ), // input  [1:2]  
    .P_RX_HIGHZ_2                      (i_p_rx_highz_2               ), // input 
    .P_TX_BEACON_EN_2                  (i_p_tx_beacon_en_2           ), // input              
    .P_RXGEAR_SLIP_2                   (i_p_rxgear_slip_2            ), // input              
    .P_TX_RATE_2                       (P_TX_RATE_2                  ), // input  [2:2]   
    .P_RX_RATE_2                       (P_RX_RATE_2                  ), // input  [2:2]   
    .P_RX_SIGDET_STATUS_2              (P_RX_SIGDET_STATUS_2         ), // output         
    .P_RX_READY_2                      (P_LX_CDR_ALIGN_2             ), // output         
    .P_RX_SATA_COMINIT_2               (o_p_lx_oob_sta_2[0]          ), // output         
    .P_RX_SATA_COMWAKE_2               (o_p_lx_oob_sta_2[1]          ), // output         
    .P_TX_RXDET_REQ_2                  (i_p_lx_rxdct_en_2            ), // input       
    .P_TX_RXDET_STATUS_2               (o_p_lx_rxdct_out_2           ), // output         
    .P_TDATA_2                         (i_p_tdata_2                  ), // input  [45:2]  
    .P_RDATA_2                         (o_p_rdata_2                  ), // output [46:2]  
    .P_TX_SDN2                         (o_p_l2txn                    ), // output         
    .P_TX_SDP2                         (o_p_l2txp                    ), // output         

    .P_RX_SDN2                         (i_p_l2rxn                    ),
    .P_RX_SDP2                         (i_p_l2rxp                    ),
    .P_TX_PMA_RST_3                    (P_TX_PMA_RST_3               ), // input               
    .P_TX_LANE_PD_3                    (P_TX_LANE_PD_3               ), // input               
    .P_LANE_PD_3                       (P_LANE_PD_3                  ), // input               
    .P_LANE_RST_3                      (P_LANE_RST_3                 ), // input               
    .P_RX_LANE_PD_3                    (P_RX_LANE_PD_3               ), // input               
    .P_TX3_CLK_FR_CORE                 (i_p_tx3_clk_fr_core          ), // input          
    .P_TX3_CLK2_FR_CORE                (i_p_tx3_clk2_fr_core         ), // input          
    .P_RX3_CLK_FR_CORE                 (i_p_rx3_clk_fr_core          ), // input          
    .P_RX3_CLK2_FR_CORE                (i_p_rx3_clk2_fr_core         ), // input          
    .P_RX_PMA_RST_3                    (P_RX_PMA_RST_3               ), // input          
    .P_PCS_TX_RST_3                    (P_PCS_TX_RST_3               ), // input          
    .P_PCS_RX_RST_3                    (P_PCS_RX_RST_3               ), // input          
    .P_PCS_CB_RST_3                    (P_PCS_CB_RST_3               ), // input          
    .P_TX_MARGIN_3                     (i_p_lx_margin_ctl_3          ), // input  [2:3]   
    .P_TX_SWING_3                      (i_p_lx_swing_ctl_3           ), // input          
    .P_TX_DEEMP_3                      (i_p_lx_deemp_ctl_3           ), // input  [1:3]  
    .P_RX_HIGHZ_3                      (i_p_rx_highz_3               ), // input 
    .P_TX_BEACON_EN_3                  (i_p_tx_beacon_en_3           ), // input              
    .P_RXGEAR_SLIP_3                   (i_p_rxgear_slip_3            ), // input              
    .P_TX_RATE_3                       (P_TX_RATE_3                  ), // input  [2:3]   
    .P_RX_RATE_3                       (P_RX_RATE_3                  ), // input  [2:3]   
    .P_RX_SIGDET_STATUS_3              (P_RX_SIGDET_STATUS_3         ), // output         
    .P_RX_READY_3                      (P_LX_CDR_ALIGN_3             ), // output         
    .P_RX_SATA_COMINIT_3               (o_p_lx_oob_sta_3[0]          ), // output         
    .P_RX_SATA_COMWAKE_3               (o_p_lx_oob_sta_3[1]          ), // output         
    .P_TX_RXDET_REQ_3                  (i_p_lx_rxdct_en_3            ), // input       
    .P_TX_RXDET_STATUS_3               (o_p_lx_rxdct_out_3           ), // output         
    .P_TDATA_3                         (i_p_tdata_3                  ), // input  [45:3]  
    .P_RDATA_3                         (o_p_rdata_3                  ), // output [46:3]  

    .P_RX_SDN3                         (i_p_l3rxn                    ),
    .P_RX_SDP3                         (i_p_l3rxp                    ),
    .P_TX_SDN3                         (o_p_l3txn                    ), // output         
    .P_TX_SDP3                         (o_p_l3txp                    )  // output  
);



endmodule    
