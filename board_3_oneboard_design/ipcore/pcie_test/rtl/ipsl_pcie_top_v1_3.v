//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
module ipsl_pcie_top_v1_3 #(
    parameter                       DEVICE_TYPE                     = 3'b000        ,
    parameter                       DIAG_CTRL_BUS_B2                = "NORMAL"      ,
    parameter    integer            BAR_RESIZABLE                   = 6'b0          ,
    parameter    integer            NUM_OF_RBARS                    = 0             ,
    parameter    integer            BAR_INDEX_0                     = 0             ,
    parameter    integer            BAR_INDEX_1                     = 2             ,
    parameter    integer            BAR_INDEX_2                     = 4             ,
    parameter                       TPH_DISABLE                     = "FALSE"       ,
    parameter                       MSIX_CAP_DISABLE                = "TRUE"        ,
    parameter                       MSI_CAP_DISABLE                 = "FALSE"       ,
    parameter                       MSI_PVM_DISABLE                 = "FALSE"       ,
    parameter    integer            BAR_MASK_WRITABLE               = 6'b111111     ,
    parameter    integer            APP_DEV_NUM                     = 0             ,
    parameter    integer            APP_BUS_NUM                     = 0             ,
    parameter                       ATOMIC_DISABLE                  = "TRUE"        ,
    parameter                       HSST_LANE_NUM                   = 4             ,

    // cfg space reg
    parameter                       MAX_LINK_WIDTH                  = 6'b00_0100    ,  // x4
    parameter                       MAX_LINK_SPEED                  = 4'b0010       ,  // gen2
    parameter                       LINK_CAPABLE                    = 6'b00_0111    ,  // 4-lanes
    parameter                       SCRAMBLE_DISABLE                = 1'b0          ,
    parameter                       AUTO_LANE_FLIP_CTRL_EN          = 1'b1          ,
    parameter                       NUM_OF_LANES                    = 5'b0_0001     ,
    parameter                       MAX_PAYLOAD_SIZE                = 3'b011        ,  // 1024-bytes
    parameter                       INT_DISABLE                     = 1'b0          ,
    parameter                       PVM_SUPPORT                     = 1'b1          ,
    parameter                       MSI_64_BIT_ADDR_CAP             = 1'b1          ,
    parameter                       MSI_MULTIPLE_MSG_CAP            = 3'b101        ,
    parameter                       MSI_ENABLE                      = 1'b0          ,
    parameter                       MSI_CAP_NEXT_OFFSET             = 8'h70         ,
    parameter                       CAP_POINTER                     = 8'h50         ,
    parameter                       PCIE_CAP_NEXT_PTR               = 8'h00         ,
    parameter                       VENDOR_ID                       = 16'h0755      ,
    parameter                       DEVICE_ID                       = 16'h0755      ,
    parameter                       BASE_CLASS_CODE                 = 8'h05         ,
    parameter                       SUBCLASS_CODE                   = 8'h80         ,
    parameter                       PROGRAM_INTERFACE               = 8'h00         ,
    parameter                       REVISION_ID                     = 8'h00         ,
    parameter                       SUBSYS_DEV_ID                   = 16'h0000      ,
    parameter                       SUBSYS_VENDOR_ID                = 16'h0000      ,
    parameter                       BAR0_PREFETCH                   = 1'b0          ,
    parameter                       BAR0_TYPE                       = 2'b0          ,
    parameter                       BAR0_MEM_IO                     = 1'b0          ,
    parameter                       BAR0_ENABLED                    = 1'b1          ,
    parameter                       BAR0_MASK                       = 31'h0000_0fff ,
    parameter                       BAR1_PREFETCH                   = 1'b0          ,
    parameter                       BAR1_TYPE                       = 2'b0          ,
    parameter                       BAR1_MEM_IO                     = 1'b0          ,
    parameter                       BAR1_ENABLED                    = 1'b1          ,
    parameter                       BAR1_MASK                       = 31'h0000_07ff ,
    parameter                       BAR2_PREFETCH                   = 1'b0          ,
    parameter                       BAR2_TYPE                       = 2'b10         ,
    parameter                       BAR2_MEM_IO                     = 1'b0          ,
    parameter                       BAR2_ENABLED                    = 1'b1          ,
    parameter                       BAR2_MASK                       = 31'h0000_0fff ,
    parameter                       BAR3_PREFETCH                   = 1'b0          ,
    parameter                       BAR3_TYPE                       = 2'b0          ,
    parameter                       BAR3_MEM_IO                     = 1'b0          ,
    parameter                       BAR3_ENABLED                    = 1'b0          ,
    parameter                       BAR3_MASK                       = 31'd0         ,
    parameter                       BAR4_PREFETCH                   = 1'b0          ,
    parameter                       BAR4_TYPE                       = 2'b0          ,
    parameter                       BAR4_MEM_IO                     = 1'b0          ,
    parameter                       BAR4_ENABLED                    = 1'b0          ,
    parameter                       BAR4_MASK                       = 31'd0         ,
    parameter                       BAR5_PREFETCH                   = 1'b0          ,
    parameter                       BAR5_TYPE                       = 2'b0          ,
    parameter                       BAR5_MEM_IO                     = 1'b0          ,
    parameter                       BAR5_ENABLED                    = 1'b0          ,
    parameter                       BAR5_MASK                       = 31'd0         ,
    parameter                       ROM_BAR_ENABLE                  = 1'b0          ,
    parameter                       ROM_BAR_ENABLED                 = 1'd0          ,
    parameter                       ROM_MASK                        = 31'd0         ,
    parameter                       DO_DESKEW_FOR_SRIS              = 1'b1          ,
    parameter                       PCIE_CAP_HW_AUTO_SPEED_DISABLE  = 1'b0          ,
    parameter                       TARGET_LINK_SPEED               = 4'h1          ,

    parameter                       ECRC_CHECK_EN                   = 1'b1          ,
    parameter                       ECRC_GEN_EN                     = 1'b1          ,
    parameter                       EXT_TAG_EN                      = 1'b1          ,
    parameter                       EXT_TAG_SUPP                    = 1'b1          ,
    parameter                       PCIE_CAP_RCB                    = 1'b1          ,
    parameter                       PCIE_CAP_CRS                    = 1'b0          ,
    parameter                       PCIE_CAP_ATOMIC_EN              = 1'b0          ,

    parameter                       PCI_MSIX_ENABLE                 = 1'b0          ,
    parameter                       PCI_FUNCTION_MASK               = 1'b0          ,
    parameter                       PCI_MSIX_TABLE_SIZE             = 11'h0         ,
    parameter                       PCI_MSIX_CPA_NEXT_OFFSET        = 8'h0          ,
    parameter                       PCI_MSIX_TABLE_OFFSET           = 29'h0         ,
    parameter                       PCI_MSIX_BIR                    = 3'h0          ,
    parameter                       PCI_MSIX_PBA_OFFSET             = 29'h0         ,
    parameter                       PCI_MSIX_PBA_BIR                = 3'h0          ,
    parameter                       AER_CAP_NEXT_OFFSET             = 12'h0         ,
    parameter                       TPH_REQ_NEXT_PTR                = 12'h0         ,
    parameter                       RESBAR_BAR0_MAX_SUPP_SIZE       = 20'hf_ffff    ,
    parameter                       RESBAR_BAR0_INIT_SIZE           = 5'h13         ,
    parameter                       RESBAR_BAR1_MAX_SUPP_SIZE       = 20'hf_ffff    ,
    parameter                       RESBAR_BAR1_INIT_SIZE           = 5'h13         ,
    parameter                       RESBAR_BAR2_MAX_SUPP_SIZE       = 20'hf_ffff    ,
    parameter                       RESBAR_BAR2_INIT_SIZE           = 5'hb          ,
    parameter                       UPCONFIGURE_SUPPORT             = 1'b1
)(
    input                           free_clk                    ,
    output  wire                    pclk                        ,
    output  wire                    pclk_div2                   ,
    input                           i_button_rstn               ,
    input                           i_power_up_rstn             ,
    input                           i_perstn                    ,
    output  wire                    o_core_rst_n                ,
    //hot rst
    output  wire                    o_training_rst_n            ,
    input                           i_app_init_rst              ,

//    input                           i_apb_clk                   ,
    input                           i_apb_sel                   ,
    input           [ 3:0]          i_apb_strb                  ,
    input           [15:0]          i_apb_addr                  ,
    input           [31:0]          i_apb_wdata                 ,
    input                           i_apb_ce                    ,
    input                           i_apb_we                    ,
    output  wire                    o_apb_rdy                   ,
    output  wire    [31:0]          o_apb_rdata                 ,
    output  wire[HSST_LANE_NUM-1:0] o_txn_lane                  ,
    output  wire[HSST_LANE_NUM-1:0] o_txp_lane                  ,
    input      [HSST_LANE_NUM-1:0]  i_rxn_lane                  ,
    input      [HSST_LANE_NUM-1:0]  i_rxp_lane                  ,
    input                           i_refckn                    ,
    input                           i_refckp                    ,
    input       [HSST_LANE_NUM-1:0] i_pcs_nearend_loop          ,
    input       [HSST_LANE_NUM-1:0] i_pma_nearend_ploop         ,
    input       [HSST_LANE_NUM-1:0] i_pma_nearend_sloop         ,
    output  wire                    o_axis_master_tvalid        ,
    input                           i_axis_master_tready        ,
    output  wire    [127:0]         o_axis_master_tdata         ,
    output  wire    [3:0]           o_axis_master_tkeep         ,
    output  wire                    o_axis_master_tlast         ,
    output  wire    [7:0]           o_axis_master_tuser         ,
    input           [2:0]           i_trgt1_radm_pkt_halt       ,
    output  wire    [5:0]           o_radm_grant_tlp_type       ,
    output  wire                    o_axis_slave0_tready        ,
    input                           i_axis_slave0_tvalid        ,
    input           [127:0]         i_axis_slave0_tdata         ,
    input                           i_axis_slave0_tlast         ,
    input                           i_axis_slave0_tuser         ,
    output  wire                    o_axis_slave1_tready        ,
    input                           i_axis_slave1_tvalid        ,
    input           [127:0]         i_axis_slave1_tdata         ,
    input                           i_axis_slave1_tlast         ,
    input                           i_axis_slave1_tuser         ,
    output  wire                    o_axis_slave2_tready        ,
    input                           i_axis_slave2_tvalid        ,
    input           [127:0]         i_axis_slave2_tdata         ,
    input                           i_axis_slave2_tlast         ,
    input                           i_axis_slave2_tuser         ,
    output  wire                    o_pm_xtlh_block_tlp         ,
    output  wire                    o_cfg_int_disable           ,
    input                           i_sys_int                   ,
    output  wire                    o_inta_grt_mux              ,
    output  wire                    o_intb_grt_mux              ,
    output  wire                    o_intc_grt_mux              ,
    output  wire                    o_intd_grt_mux              ,
    input                           i_ven_msi_req               ,
    input           [2:0]           i_ven_msi_tc                ,
    input           [4:0]           i_ven_msi_vector            ,
    output  wire                    o_ven_msi_grant             ,
    input           [(32*1)-1:0]    i_cfg_msi_pending           ,
    output  wire                    o_cfg_msi_en                ,
    input           [63:0]          i_msix_addr                 ,
    input           [31:0]          i_msix_data                 ,
    output  wire                    o_cfg_msix_en               ,
    output  wire                    o_cfg_msix_func_mask        ,
    output  wire                    o_radm_pm_turnoff           ,
    output  wire                    o_radm_msg_unlock           ,
    input                           i_outband_pwrup_cmd         ,
    output  wire                    o_pm_status                 ,
    output  wire    [2:0]           o_pm_dstate                 ,
    output  wire                    o_aux_pm_en                 ,
    output  wire                    o_pm_pme_en                 ,
    output  wire                    o_pm_linkst_in_l0s          ,
    output  wire                    o_pm_linkst_in_l1           ,
    output  wire                    o_pm_linkst_in_l2           ,
    output  wire                    o_pm_linkst_l2_exit         ,
    input                           i_app_req_entr_l1           ,
    input                           i_app_ready_entr_l23        ,
    input                           i_app_req_exit_l1           ,
    input                           i_app_xfer_pending          ,
    output  wire                    o_wake                      ,
    output  wire                    o_radm_pm_pme               ,
    output  wire                    o_radm_pm_to_ack            ,
    input                           i_apps_pm_xmt_turnoff       ,
    input                           i_app_unlock_msg            ,
    input                           i_apps_pm_xmt_pme           ,
    input                           i_app_clk_pm_en             ,
    output  wire    [4:0]           o_pm_master_state           ,
    output  wire    [4:0]           o_pm_slave_state            ,
    input                           i_sys_aux_pwr_det           ,
    input                           i_app_hdr_valid             ,
    input           [127:0]         i_app_hdr_log               ,
    input           [12:0]          i_app_err_bus               ,
    input                           i_app_err_advisory          ,
    output  wire                    o_cfg_send_cor_err_mux      ,
    output  wire                    o_cfg_send_nf_err_mux       ,
    output  wire                    o_cfg_send_f_err_mux        ,
    output  wire                    o_cfg_sys_err_rc            ,
    output  wire                    o_cfg_aer_rc_err_mux        ,
    output  wire                    o_radm_cpl_timeout          ,
    output  wire    [2:0]           o_radm_timeout_cpl_tc       ,
    output  wire    [7:0]           o_radm_timeout_cpl_tag      ,
    output  wire    [1:0]           o_radm_timeout_cpl_attr     ,
    output  wire    [10:0]          o_radm_timeout_cpl_len      ,
    output  wire    [2:0]           o_cfg_max_rd_req_size       ,
    output  wire                    o_cfg_bus_master_en         ,
    output  wire    [2:0]           o_cfg_max_payload_size      ,
    output  wire                    o_cfg_ext_tag_en            ,
    output  wire                    o_cfg_rcb                   ,
    output  wire                    o_cfg_mem_space_en          ,
    output  wire                    o_cfg_pm_no_soft_rst        ,
    output  wire                    o_cfg_crs_sw_vis_en         ,
    output  wire                    o_cfg_no_snoop_en           ,
    output  wire                    o_cfg_relax_order_en        ,
    output  wire    [2-1:0]         o_cfg_tph_req_en            ,
    output  wire    [3-1:0]         o_cfg_pf_tph_st_mode        ,
    output  wire    [7:0]           o_cfg_pbus_num              ,
    output  wire    [4:0]           o_cfg_pbus_dev_num          ,
    output  wire                    o_rbar_ctrl_update          ,
    output  wire                    o_cfg_atomic_req_en         ,
    output  wire                    o_cfg_atomic_egress_block   ,
    output  wire                    o_radm_idle                 ,
    output  wire                    o_radm_q_not_empty          ,
    output  wire                    o_radm_qoverflow            ,
    input           [1:0]           i_diag_ctrl_bus             ,
    input           [3:0]           i_dyn_debug_info_sel        ,
    output  wire                    o_cfg_link_auto_bw_mux      ,
    output  wire                    o_cfg_bw_mgt_mux            ,
    output  wire                    o_cfg_pme_mux               ,
    output  wire    [132:0]         o_debug_info_mux            ,
    input                           i_app_ras_des_sd_hold_ltssm ,
    input           [1:0]           i_app_ras_des_tba_ctrl      ,
    output  wire                    o_cfg_ido_req_en            ,
    output  wire                    o_cfg_ido_cpl_en            ,
    output  wire    [7:0]           o_xadm_ph_cdts              ,
    output  wire    [11:0]          o_xadm_pd_cdts              ,
    output  wire    [7:0]           o_xadm_nph_cdts             ,
    output  wire    [11:0]          o_xadm_npd_cdts             ,
    output  wire    [7:0]           o_xadm_cplh_cdts            ,
    output  wire    [11:0]          o_xadm_cpld_cdts            ,
    input                           i_rx_lane_flip_en           ,
    input                           i_tx_lane_flip_en           ,
    output  wire                    o_smlh_link_up              ,
    output  wire                    o_rdlh_link_up              ,
    input                           i_app_req_retry_en          ,
    output  wire    [4:0]           o_smlh_ltssm_state          ,
    output  wire                    o_refck2core_0
);

wire [HSST_LANE_NUM*32-1:0]     phy_mac_rxdata              ;
wire [HSST_LANE_NUM*4-1:0]      phy_mac_rxdatak             ;

wire                            i_phy_rate_chng_halt        ;
wire [1:0]                      mac_phy_powerdown           ;
wire [HSST_LANE_NUM-1:0]        phy_mac_rxelecidle          ;
wire [3:0]          		phy_mac_phystatus           ;
wire [HSST_LANE_NUM-1:0]        phy_mac_rxvalid             ;
wire [HSST_LANE_NUM*3-1:0]      phy_mac_rxstatus            ;
wire [127:0]                    mac_phy_txdata              ;
wire [15:0]                     mac_phy_txdatak             ;
wire [3:0]                      mac_phy_txdetectrx_loopback ;
wire [3:0]                      mac_phy_txelecidle_h        ;
wire [3:0]                      mac_phy_txelecidle_l        ;
wire [3:0]                      mac_phy_txcompliance        ;
wire [3:0]                      mac_phy_rxpolarity          ;
wire                            mac_phy_rate                ;
wire [1:0]                      mac_phy_txdeemph            ;
wire [2:0]                      mac_phy_txmargin            ;
wire                            mac_phy_txswing             ;
wire                            phy_rst_n                   ;

wire                            ref_clk                     ;
wire                            tx_rst_done                 ;

wire                            apb_core_rst_n              ;

wire                            hsst_p_sel                  ;
wire                            hsst_p_ce                   ;
wire                            hsst_p_we                   ;
wire  [15:0]                    hsst_p_addr                 ;
wire  [31:0]                    hsst_p_wdata                ;
wire  [7:0]                     hsst_p_rdata                ;
wire                            hsst_p_rdy                  ;

wire                            pcie_p_sel                  ;
wire  [3:0]                     pcie_p_strb                 ;
wire  [15:0]                    pcie_p_addr                 ;
wire  [31:0]                    pcie_p_wdata                ;
wire                            pcie_p_ce                   ;
wire                            pcie_p_we                   ;
wire                            pcie_p_rdy                  ;
wire  [31:0]                    pcie_p_rdata                ;

assign ref_clk = o_refck2core_0;

//=============================================================================
//  RST SYNC
//=============================================================================
ipsl_pcie_sync_v1_0 u_core_rstn_sync (
    //.clk                            (i_apb_clk                  ),
    .clk                            (ref_clk                    ),
    .rst_n                          (o_core_rst_n               ),
    .sig_async                      (1'b1                       ),
    .sig_synced                     (apb_core_rst_n             )
);

//=============================================================================
//  APB MUX
//=============================================================================
ipsl_pcie_apb_mux_v1_1 u_pcie_apb_mux (
    //from uart domain
    //.i_uart_clk                     (i_apb_clk                  ),
    .i_uart_clk                     (ref_clk                    ),
    .i_uart_rst_n                   (apb_core_rst_n             ),
    .i_uart_p_sel                   (i_apb_sel                  ),
    .i_uart_p_strb                  (i_apb_strb                 ),
    .i_uart_p_addr                  (i_apb_addr                 ),
    .i_uart_p_wdata                 (i_apb_wdata                ),
    .i_uart_p_ce                    (i_apb_ce                   ),
    .i_uart_p_we                    (i_apb_we                   ),
    .o_uart_p_rdy                   (o_apb_rdy                  ),
    .o_uart_p_rdata                 (o_apb_rdata                ),
    //to pcie domain
    .i_pcie_clk                     (pclk_div2                  ),
    .i_pcie_rst_n                   (o_core_rst_n               ),
    .o_pcie_p_sel                   (pcie_p_sel                 ),
    .o_pcie_p_strb                  (pcie_p_strb                ),
    .o_pcie_p_addr                  (pcie_p_addr                ),
    .o_pcie_p_wdata                 (pcie_p_wdata               ),
    .o_pcie_p_ce                    (pcie_p_ce                  ),
    .o_pcie_p_we                    (pcie_p_we                  ),
    .i_pcie_p_rdy                   (pcie_p_rdy                 ),
    .i_pcie_p_rdata                 (pcie_p_rdata               ),
    //to hsstlp domain
    .i_hsst_clk                     (ref_clk                    ),
    .i_hsst_rst_n                   (apb_core_rst_n             ),
    .o_hsst_p_sel                   (hsst_p_sel                 ),
    .o_hsst_p_strb                  (                           ),
    .o_hsst_p_addr                  (hsst_p_addr                ),
    .o_hsst_p_wdata                 (hsst_p_wdata               ),
    .o_hsst_p_ce                    (hsst_p_ce                  ),
    .o_hsst_p_we                    (hsst_p_we                  ),
    .i_hsst_p_rdy                   (hsst_p_rdy                 ),
    .i_hsst_p_rdata                 ({24'b0,hsst_p_rdata}       )
);

//=============================================================================
//  PCIE_HARD_CTRL
//=============================================================================
ipsl_pcie_hard_ctrl_v1_3  #(
    .DEVICE_TYPE                    (DEVICE_TYPE                    ),
    .DEBUG_INFO_DW                  (133                            ),
    .TP                             (2                              ),
    .GRS_EN                         ("FALSE"                        ),      // FALSE, TRUE
    .PIN_MUX_INT_FORCE_EN           ("FALSE"                        ),      // FALSE, TRUE
    .PIN_MUX_INT_DISABLE            ("FALSE"                        ),      // FALSE, TURE
    .DIAG_CTRL_BUS_B2               (DIAG_CTRL_BUS_B2               ),      // "NORMAL" "FAST_LINK_MODE"
    .DYN_DEBUG_SEL_EN               ("TRUE"                         ),      // FALSE, TRUE
    .DEBUG_INFO_SEL                 (0                              ),      // set debug_info_mux, 0-15
    .BAR_RESIZABLE                  (BAR_RESIZABLE                  ),      // 0: no resizable bar, 1: bar0 resizable, 2: bar1 resizable, 3: bar0-1 resizable, ... 56: bar3-bar5 resizable;  Please do not set more than 3 resizable bars at the same   time  Default value is 21 which is 6'b010101
    .NUM_OF_RBARS                   (NUM_OF_RBARS                   ),      // 0: no resizable bar, 1: one resizable bar, 2: two resizable bars, 3: three resizable bars  Default value is 3
    .BAR_INDEX_0                    (BAR_INDEX_0                    ),      // set bar index0 in resizable bar control register,   0: bar0 resizable 1: bar1 resizable 2: bar2 resizable ... 5: bar5 resizable  Default value is 0
    .BAR_INDEX_1                    (BAR_INDEX_1                    ),      // set bar index1 in resizable bar control register,   0: bar0 resizable 1: bar1 resizable 2: bar2 resizable ... 5: bar5 resizable  Default value is 2
    .BAR_INDEX_2                    (BAR_INDEX_2                    ),      // set bar index2 in resizable bar control register,   0: bar0 resizable 1: bar1 resizable 2: bar2 resizable ... 5: bar5 resizable  Default value is 4
    .TPH_DISABLE                    (TPH_DISABLE                    ),      // FALSE, TRUE
    .MSIX_CAP_DISABLE               (MSIX_CAP_DISABLE               ),      // FALSE, TRUE
    .MSI_CAP_DISABLE                (MSI_CAP_DISABLE                ),      // FALSE, TRUE
    .MSI_PVM_DISABLE                (MSI_PVM_DISABLE                ),      // FALSE, TRUE
    .BAR_MASK_WRITABLE              (BAR_MASK_WRITABLE              ),      // 0: no writable bar, 1: bar0 writable, 2: bar1 writable, 3: bar3 writable, ... 63: bar0-5 writable
    .APP_DEV_NUM                    (APP_DEV_NUM                    ),      // set device_number
    .APP_BUS_NUM                    (APP_BUS_NUM                    ),      // set bus_number
    .RAM_MUX_EN                     ("TRUE"                         ),      // FALSE, TRUE
    .ATOMIC_DISABLE                 (ATOMIC_DISABLE                 ),      // FALSE, TRUE
    // cfg space reg
    .MAX_LINK_WIDTH                 (MAX_LINK_WIDTH                 ),
    .MAX_LINK_SPEED                 (MAX_LINK_SPEED                 ),
    .LINK_CAPABLE                   (LINK_CAPABLE                   ),
    .SCRAMBLE_DISABLE               (SCRAMBLE_DISABLE               ),
    .AUTO_LANE_FLIP_CTRL_EN         (AUTO_LANE_FLIP_CTRL_EN         ),
    .NUM_OF_LANES                   (NUM_OF_LANES                   ),
    .MAX_PAYLOAD_SIZE               (MAX_PAYLOAD_SIZE               ),
    .INT_DISABLE                    (INT_DISABLE                    ),
    .PVM_SUPPORT                    (PVM_SUPPORT                    ),
    .MSI_64_BIT_ADDR_CAP            (MSI_64_BIT_ADDR_CAP            ),
    .MSI_MULTIPLE_MSG_CAP           (MSI_MULTIPLE_MSG_CAP           ),
    .MSI_ENABLE                     (MSI_ENABLE                     ),
    .CAP_POINTER                    (CAP_POINTER                    ),
    .PCIE_CAP_NEXT_PTR              (PCIE_CAP_NEXT_PTR              ),
    .VENDOR_ID                      (VENDOR_ID                      ),
    .DEVICE_ID                      (DEVICE_ID                      ),
    .BASE_CLASS_CODE                (BASE_CLASS_CODE                ),
    .SUBCLASS_CODE                  (SUBCLASS_CODE                  ),
    .PROGRAM_INTERFACE              (PROGRAM_INTERFACE              ),
    .REVISION_ID                    (REVISION_ID                    ),
    .SUBSYS_DEV_ID                  (SUBSYS_DEV_ID                  ),
    .SUBSYS_VENDOR_ID               (SUBSYS_VENDOR_ID               ),
    .BAR0_PREFETCH                  (BAR0_PREFETCH                  ),
    .BAR0_TYPE                      (BAR0_TYPE                      ),
    .BAR0_MEM_IO                    (BAR0_MEM_IO                    ),
    .BAR0_ENABLED                   (BAR0_ENABLED                   ),
    .BAR0_MASK                      (BAR0_MASK                      ),
    .BAR1_MEM_IO                    (BAR1_MEM_IO                    ),
    .BAR1_ENABLED                   (BAR1_ENABLED                   ),
    .BAR1_MASK                      (BAR1_MASK                      ),
    .BAR2_PREFETCH                  (BAR2_PREFETCH                  ),
    .BAR2_TYPE                      (BAR2_TYPE                      ),
    .BAR2_MEM_IO                    (BAR2_MEM_IO                    ),
    .BAR2_ENABLED                   (BAR2_ENABLED                   ),
    .BAR2_MASK                      (BAR2_MASK                      ),
    .BAR3_MEM_IO                    (BAR3_MEM_IO                    ),
    .BAR3_ENABLED                   (BAR3_ENABLED                   ),
    .BAR3_MASK                      (BAR3_MASK                      ),
    .BAR4_PREFETCH                  (BAR4_PREFETCH                  ),
    .BAR4_TYPE                      (BAR4_TYPE                      ),
    .BAR4_MEM_IO                    (BAR4_MEM_IO                    ),
    .BAR4_ENABLED                   (BAR4_ENABLED                   ),
    .BAR4_MASK                      (BAR4_MASK                      ),
    .BAR5_MEM_IO                    (BAR5_MEM_IO                    ),
    .BAR5_ENABLED                   (BAR5_ENABLED                   ),
    .BAR5_MASK                      (BAR5_MASK                      ),
    .ROM_BAR_ENABLE                 (ROM_BAR_ENABLE                 ),
    .ROM_BAR_ENABLED                (ROM_BAR_ENABLED                ),
    .ROM_MASK                       (ROM_MASK                       ),
    .DO_DESKEW_FOR_SRIS             (DO_DESKEW_FOR_SRIS             ),
    .PCIE_CAP_HW_AUTO_SPEED_DISABLE (PCIE_CAP_HW_AUTO_SPEED_DISABLE ),
    .TARGET_LINK_SPEED              (TARGET_LINK_SPEED              ),

    .ECRC_CHECK_EN                  (ECRC_CHECK_EN                  ),
    .ECRC_GEN_EN                    (ECRC_GEN_EN                    ),
    .EXT_TAG_EN                     (EXT_TAG_EN                     ),
    .EXT_TAG_SUPP                   (EXT_TAG_SUPP                   ),
    .PCIE_CAP_RCB                   (PCIE_CAP_RCB                   ),
    .PCIE_CAP_CRS                   (PCIE_CAP_CRS                   ),
    .PCIE_CAP_ATOMIC_EN             (PCIE_CAP_ATOMIC_EN             ),

    .PCI_MSIX_ENABLE                (PCI_MSIX_ENABLE                ),
    .PCI_FUNCTION_MASK              (PCI_FUNCTION_MASK              ),
    .PCI_MSIX_TABLE_SIZE            (PCI_MSIX_TABLE_SIZE            ),
    .PCI_MSIX_CPA_NEXT_OFFSET       (PCI_MSIX_CPA_NEXT_OFFSET       ),
    .PCI_MSIX_TABLE_OFFSET          (PCI_MSIX_TABLE_OFFSET          ),
    .PCI_MSIX_BIR                   (PCI_MSIX_BIR                   ),
    .PCI_MSIX_PBA_OFFSET            (PCI_MSIX_PBA_OFFSET            ),
    .PCI_MSIX_PBA_BIR               (PCI_MSIX_PBA_BIR               ),
    .AER_CAP_NEXT_OFFSET            (AER_CAP_NEXT_OFFSET            ),
    .TPH_REQ_NEXT_PTR               (TPH_REQ_NEXT_PTR               ),
    .RESBAR_BAR0_MAX_SUPP_SIZE      (RESBAR_BAR0_MAX_SUPP_SIZE      ),
    .RESBAR_BAR0_INIT_SIZE          (RESBAR_BAR0_INIT_SIZE          ),
    .RESBAR_BAR1_MAX_SUPP_SIZE      (RESBAR_BAR1_MAX_SUPP_SIZE      ),
    .RESBAR_BAR1_INIT_SIZE          (RESBAR_BAR1_INIT_SIZE          ),
    .RESBAR_BAR2_MAX_SUPP_SIZE      (RESBAR_BAR2_MAX_SUPP_SIZE      ),
    .RESBAR_BAR2_INIT_SIZE          (RESBAR_BAR2_INIT_SIZE          ),
    .UPCONFIGURE_SUPPORT            (UPCONFIGURE_SUPPORT            )
) u_pcie_hard_ctrl (
    .mem_clk                        (pclk                           ), // input
    .pclk                           (pclk                           ), // input
    .pclk_div2                      (pclk_div2                      ), // input
    .button_rst                     (!i_button_rstn                 ), // input
    .power_up_rst                   (!i_power_up_rstn               ), // input
    .perst                          (!i_perstn                      ), // input
    .core_rst_n                     (o_core_rst_n                   ), // output
    .training_rst_n                 (o_training_rst_n               ), // output
    .app_init_rst                   (i_app_init_rst                 ), // input
    .phy_rst_n                      (phy_rst_n                      ), // output
    .rx_lane_flip_en                (i_rx_lane_flip_en              ), // input
    .tx_lane_flip_en                (i_tx_lane_flip_en              ), // input
    .smlh_link_up                   (o_smlh_link_up                 ), // output
    .rdlh_link_up                   (o_rdlh_link_up                 ), // output
    .app_req_retry_en               (i_app_req_retry_en             ), // input
    .smlh_ltssm_state               (o_smlh_ltssm_state             ), // output  [4:0]
    .axis_master_tvalid             (o_axis_master_tvalid           ), // output
    .axis_master_tready             (i_axis_master_tready           ), // input
    .axis_master_tdata              (o_axis_master_tdata            ), // output [127:0]
    .axis_master_tkeep              (o_axis_master_tkeep            ), // output [3:0]
    .axis_master_tlast              (o_axis_master_tlast            ), // output
    .axis_master_tuser              (o_axis_master_tuser            ), // output [7:0]
    .trgt1_radm_pkt_halt            (i_trgt1_radm_pkt_halt          ), // input  [2:0]
    .radm_grant_tlp_type            (o_radm_grant_tlp_type          ), // output [5:0]
    .axis_slave0_tready             (o_axis_slave0_tready           ), // output
    .axis_slave0_tvalid             (i_axis_slave0_tvalid           ), // input
    .axis_slave0_tdata              (i_axis_slave0_tdata            ), // input  [127:0]
    .axis_slave0_tlast              (i_axis_slave0_tlast            ), // input
    .axis_slave0_tuser              (i_axis_slave0_tuser            ), // input
    .axis_slave1_tready             (o_axis_slave1_tready           ), // output
    .axis_slave1_tvalid             (i_axis_slave1_tvalid           ), // input
    .axis_slave1_tdata              (i_axis_slave1_tdata            ), // input  [127:0]
    .axis_slave1_tlast              (i_axis_slave1_tlast            ), // input
    .axis_slave1_tuser              (i_axis_slave1_tuser            ), // input
    .axis_slave2_tready             (o_axis_slave2_tready           ), // output
    .axis_slave2_tvalid             (i_axis_slave2_tvalid           ), // input
    .axis_slave2_tdata              (i_axis_slave2_tdata            ), // input  [127:0]
    .axis_slave2_tlast              (i_axis_slave2_tlast            ), // input
    .axis_slave2_tuser              (i_axis_slave2_tuser            ), // input
    .pm_xtlh_block_tlp              (o_pm_xtlh_block_tlp            ), // output
    //APB
    .apb_sel                        (pcie_p_sel                     ), // input
    .apb_strb                       (pcie_p_strb                    ), // input
    .apb_addr                       (pcie_p_addr                    ), // input
    .apb_wdata                      (pcie_p_wdata                   ), // input
    .apb_ce                         (pcie_p_ce                      ), // input
    .apb_we                         (pcie_p_we                      ), // input
    .apb_rdy                        (pcie_p_rdy                     ), // output
    .apb_rdata                      (pcie_p_rdata                   ), // output
    .cfg_int_disable                (o_cfg_int_disable              ), // output
    .tx_rst_done                    (tx_rst_done                    ), // input
    .sys_int                        (i_sys_int                      ), // input
    .inta_grt_mux                   (o_inta_grt_mux                 ), // output
    .intb_grt_mux                   (o_intb_grt_mux                 ), // output
    .intc_grt_mux                   (o_intc_grt_mux                 ), // output
    .intd_grt_mux                   (o_intd_grt_mux                 ), // output
    .ven_msi_req                    (i_ven_msi_req                  ), // input
    .ven_msi_tc                     (i_ven_msi_tc                   ), // input   [2:0]
    .ven_msi_vector                 (i_ven_msi_vector               ), // input   [4:0]
    .ven_msi_grant                  (o_ven_msi_grant                ), // output
    .cfg_msi_pending                (i_cfg_msi_pending              ), // input   [(32*1)-1:0]
    .cfg_msi_en                     (o_cfg_msi_en                   ), // output
    .msix_addr                      (i_msix_addr                    ), // input   [63:0]
    .msix_data                      (i_msix_data                    ), // input   [31:0]
    .cfg_msix_en                    (o_cfg_msix_en                  ), // output
    .cfg_msix_func_mask             (o_cfg_msix_func_mask           ), // output
    .radm_pm_turnoff                (o_radm_pm_turnoff              ), // output
    .radm_msg_unlock                (o_radm_msg_unlock              ), // output
    .outband_pwrup_cmd              (i_outband_pwrup_cmd            ), // input
    .pm_status                      (o_pm_status                    ), // output
    .pm_dstate                      (o_pm_dstate                    ), // output  [2:0]
    .aux_pm_en                      (o_aux_pm_en                    ), // output
    .pm_pme_en                      (o_pm_pme_en                    ), // output
    .pm_linkst_in_l0s               (o_pm_linkst_in_l0s             ), // output
    .pm_linkst_in_l1                (o_pm_linkst_in_l1              ), // output
    .pm_linkst_in_l2                (o_pm_linkst_in_l2              ), // output
    .pm_linkst_l2_exit              (o_pm_linkst_l2_exit            ), // output
    .app_req_entr_l1                (i_app_req_entr_l1              ), // input
    .app_ready_entr_l23             (i_app_ready_entr_l23           ), // input
    .app_req_exit_l1                (i_app_req_exit_l1              ), // input
    .app_xfer_pending               (i_app_xfer_pending             ), // input
    .wake                           (o_wake                         ), // output
    .radm_pm_pme                    (o_radm_pm_pme                  ), // output
    .radm_pm_to_ack                 (o_radm_pm_to_ack               ), // output
    .apps_pm_xmt_turnoff            (i_apps_pm_xmt_turnoff          ), // input
    .app_unlock_msg                 (i_app_unlock_msg               ), // input
    .apps_pm_xmt_pme                (i_apps_pm_xmt_pme              ), // input
    .app_clk_pm_en                  (i_app_clk_pm_en                ), // input
    .pm_master_state                (o_pm_master_state              ), // output [4:0]
    .pm_slave_state                 (o_pm_slave_state               ), // output [4:0]
    .sys_aux_pwr_det                (i_sys_aux_pwr_det              ), // input
    .app_hdr_valid                  (i_app_hdr_valid                ), // input
    .app_hdr_log                    (i_app_hdr_log                  ), // input   [127:0]
    .app_err_bus                    (i_app_err_bus                  ), // input   [12:0]
    .app_err_advisory               (i_app_err_advisory             ), // input
    .cfg_send_cor_err_mux           (o_cfg_send_cor_err_mux         ), // output
    .cfg_send_nf_err_mux            (o_cfg_send_nf_err_mux          ), // output
    .cfg_send_f_err_mux             (o_cfg_send_f_err_mux           ), // output
    .cfg_sys_err_rc                 (o_cfg_sys_err_rc               ), // output
    .cfg_aer_rc_err_mux             (o_cfg_aer_rc_err_mux           ), // output
    .radm_cpl_timeout               (o_radm_cpl_timeout             ), // output
    .radm_timeout_cpl_tc            (o_radm_timeout_cpl_tc          ), // output  [2:0]
    .radm_timeout_cpl_tag           (o_radm_timeout_cpl_tag         ), // output  [7:0]
    .radm_timeout_cpl_attr          (o_radm_timeout_cpl_attr        ), // output  [1:0]
    .radm_timeout_cpl_len           (o_radm_timeout_cpl_len         ), // output  [10:0]
    .cfg_max_rd_req_size            (o_cfg_max_rd_req_size          ), // output [2:0]
    .cfg_bus_master_en              (o_cfg_bus_master_en            ), // output
    .cfg_max_payload_size           (o_cfg_max_payload_size         ), // output [2:0]
    .cfg_ext_tag_en                 (o_cfg_ext_tag_en               ), // output
    .cfg_rcb                        (o_cfg_rcb                      ), // output
    .cfg_mem_space_en               (o_cfg_mem_space_en             ), // output
    .cfg_pm_no_soft_rst             (o_cfg_pm_no_soft_rst           ), // output
    .cfg_crs_sw_vis_en              (o_cfg_crs_sw_vis_en            ), // output
    .cfg_no_snoop_en                (o_cfg_no_snoop_en              ), // output
    .cfg_relax_order_en             (o_cfg_relax_order_en           ), // output
    .cfg_tph_req_en                 (o_cfg_tph_req_en               ), // output [2-1:0]
    .cfg_pf_tph_st_mode             (o_cfg_pf_tph_st_mode           ), // output [3-1:0]
    .cfg_pbus_num                   (o_cfg_pbus_num                 ), // output [7:0]
    .cfg_pbus_dev_num               (o_cfg_pbus_dev_num             ), // output [4:0]
    .rbar_ctrl_update               (o_rbar_ctrl_update             ), // output
    .cfg_atomic_req_en              (o_cfg_atomic_req_en            ), // output
    .cfg_atomic_egress_block        (o_cfg_atomic_egress_block      ), // output
    .radm_idle                      (o_radm_idle                    ), // output
    .radm_q_not_empty               (o_radm_q_not_empty             ), // output
    .radm_qoverflow                 (o_radm_qoverflow               ), // output
    .diag_ctrl_bus                  (i_diag_ctrl_bus                ), // input   [1:0]
    .dyn_debug_info_sel             (i_dyn_debug_info_sel           ), // input   [3:0]
    .cfg_link_auto_bw_mux           (o_cfg_link_auto_bw_mux         ), // output
    .cfg_bw_mgt_mux                 (o_cfg_bw_mgt_mux               ), // output
    .cfg_pme_mux                    (o_cfg_pme_mux                  ), // output
    .debug_info_mux                 (o_debug_info_mux               ), // output  [132:0]
    .app_ras_des_sd_hold_ltssm      (i_app_ras_des_sd_hold_ltssm    ), // input
    .app_ras_des_tba_ctrl           (i_app_ras_des_tba_ctrl         ), // input   [1:0]
    .cfg_ido_req_en                 (o_cfg_ido_req_en               ), // output
    .cfg_ido_cpl_en                 (o_cfg_ido_cpl_en               ), // output
    .xadm_ph_cdts                   (o_xadm_ph_cdts                 ), // output  [7:0]
    .xadm_pd_cdts                   (o_xadm_pd_cdts                 ), // output  [11:0]
    .xadm_nph_cdts                  (o_xadm_nph_cdts                ), // output  [7:0]
    .xadm_npd_cdts                  (o_xadm_npd_cdts                ), // output  [11:0]
    .xadm_cplh_cdts                 (o_xadm_cplh_cdts               ), // output  [7:0]
    .xadm_cpld_cdts                 (o_xadm_cpld_cdts               ), // output  [11:0]
    .phy_rate_chng_halt             (i_phy_rate_chng_halt           ), // input
    .mac_phy_powerdown              (mac_phy_powerdown              ), // output  [1 : 0]
    .phy_mac_rxelecidle             ({{(4-HSST_LANE_NUM){1'b1}},phy_mac_rxelecidle} ), // input   max[3:0]
    .phy_mac_phystatus              (phy_mac_phystatus              ), // input   [3:0]
    .phy_mac_rxdata                 ({{(128-HSST_LANE_NUM*32){1'b0}},phy_mac_rxdata}), // input  max[127:0]
    .phy_mac_rxdatak                ({{(16-HSST_LANE_NUM*4){1'b0}},phy_mac_rxdatak} ), // input max[15:0]
    .phy_mac_rxvalid                ({{(4-HSST_LANE_NUM){1'b0}},phy_mac_rxvalid}    ), // input  max[3:0]
    .phy_mac_rxstatus               ({{(12-HSST_LANE_NUM*3){1'b0}},phy_mac_rxstatus}), // input  max[(4*3)-1:0]
    .mac_phy_txdata                 (mac_phy_txdata                 ), // output  [127:0]
    .mac_phy_txdatak                (mac_phy_txdatak                ), // output  [15:0]
    .mac_phy_txdetectrx_loopback    (mac_phy_txdetectrx_loopback    ), // output  [3:0]
    .mac_phy_txelecidle_l           (mac_phy_txelecidle_l           ), // output  [3:0]
    .mac_phy_txelecidle_h           (mac_phy_txelecidle_h           ), // output  [3:0]
    .mac_phy_txcompliance           (mac_phy_txcompliance           ), // output  [3:0]
    .mac_phy_rxpolarity             (mac_phy_rxpolarity             ), // output  [3:0]
    .mac_phy_rate                   (mac_phy_rate                   ), // output
    .mac_phy_txdeemph               (mac_phy_txdeemph               ), // output  [1:0]
    .mac_phy_txmargin               (mac_phy_txmargin               ), // output  [2:0]
    .mac_phy_txswing                (mac_phy_txswing                )  // output
    //.cfg_hw_auto_sp_dis           (cfg_hw_auto_sp_dis             ) // output
);

ipsl_pcie_soft_phy_v1_2a #(
    .HSST_LANE_NUM                  (HSST_LANE_NUM                  )
) u_pcie_soft_phy (
    .button_rst_n                   (i_button_rstn                  ), // input
    .external_rstn                  (i_power_up_rstn                ), // input
    .phy_rst_n                      (phy_rst_n                      ), // input
    .P_TXN                          (o_txn_lane                     ), // output
    .P_TXP                          (o_txp_lane                     ), // output
    .P_RXN                          (i_rxn_lane                     ), // input
    .P_RXP                          (i_rxp_lane                     ), // input
    .P_REFCKN                       (i_refckn                       ), // input
    .P_REFCKP                       (i_refckp                       ), // input
    .P_REFCK2CORE_0                 (o_refck2core_0                 ), // output
    .free_clk                       (free_clk                       ),
    .pclk                           (pclk                           ), // output
    .pclk_div2                      (pclk_div2                      ), // output
    .i_p_cfg_psel                   (hsst_p_sel                     ), // input
    .i_p_cfg_enable                 (hsst_p_ce                      ), // input
    .i_p_cfg_write                  (hsst_p_we                      ), // input
    .i_p_cfg_addr                   (hsst_p_addr                    ), // input  [15:0]
    .i_p_cfg_wdata                  (hsst_p_wdata[7:0]              ), // input  [7:0]
    .o_p_cfg_rdata                  (hsst_p_rdata                   ), // output [7:0]
    .o_p_cfg_int                    (                               ), // output
    .o_p_cfg_ready                  (hsst_p_rdy                     ), // output
    .tx_rst_done                    (tx_rst_done                    ), // output
    .mac_phy_powerdown              (mac_phy_powerdown              ), // input    [1:0]
    .phy_mac_rxelecidle             (phy_mac_rxelecidle             ), // output   [3:0]
    .phy_mac_phystatus              (phy_mac_phystatus              ), // output   [3:0]
    .phy_mac_rxdata                 (phy_mac_rxdata                 ), // output   [127:0]
    .phy_mac_rxdatak                (phy_mac_rxdatak                ), // output   [15:0]
    .phy_mac_rxvalid                (phy_mac_rxvalid                ), // output   [3:0]
    .phy_mac_rxstatus               (phy_mac_rxstatus               ), // output   [(4*3)-1:0]
    .mac_phy_txdata                 (mac_phy_txdata[0+:HSST_LANE_NUM*32]), // input    max[127:0]
    .mac_phy_txdatak                (mac_phy_txdatak[0+:HSST_LANE_NUM*4]), // input    max[15:0]
    .mac_phy_txdetectrx_loopback    (mac_phy_txdetectrx_loopback[0+:HSST_LANE_NUM]), // input    max[3:0]
    .mac_phy_txelecidle_h           (mac_phy_txelecidle_h[0+:HSST_LANE_NUM]), // input   max[3:0]
    .mac_phy_txelecidle_l           (mac_phy_txelecidle_l[0+:HSST_LANE_NUM]), // input   max[3:0]
    .mac_phy_txcompliance           (mac_phy_txcompliance[0+:HSST_LANE_NUM]), // input   max[3:0]
    .mac_phy_rxpolarity             (mac_phy_rxpolarity[0+:HSST_LANE_NUM]), // input    [3:0]
    .mac_phy_rate                   (mac_phy_rate                   ), // input
    .mac_phy_txdeemph               (mac_phy_txdeemph               ), // input    [1:0]
    .mac_phy_txmargin               (mac_phy_txmargin               ), // input    [2:0]
    .mac_phy_txswing                (mac_phy_txswing                ), // input
    .pcs_nearend_loop               (i_pcs_nearend_loop[0+:HSST_LANE_NUM] ), // input    max[3:0]
    .pma_nearend_ploop              (i_pma_nearend_ploop[0+:HSST_LANE_NUM]), // input    max[3:0]
    .pma_nearend_sloop              (i_pma_nearend_sloop[0+:HSST_LANE_NUM]), // input    max[3:0]
    .phy_rate_chng_halt             (i_phy_rate_chng_halt           )  // output   reg
);

endmodule
