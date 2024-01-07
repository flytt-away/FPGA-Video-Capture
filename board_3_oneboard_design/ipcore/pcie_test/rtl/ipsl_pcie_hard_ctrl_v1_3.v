//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2020 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
module ipsl_pcie_hard_ctrl_v1_3  #(
    parameter                   DEVICE_TYPE                     = 3'b000        ,
    parameter                   DEBUG_INFO_DW                   = 133           ,
    parameter                   TP                              = 2             ,
    parameter                   GRS_EN                          = "TRUE"        ,
    parameter                   PIN_MUX_INT_FORCE_EN            = "FALSE"       ,
    parameter                   PIN_MUX_INT_DISABLE             = "FALSE"       ,
    parameter                   DIAG_CTRL_BUS_B2                = "NORMAL"      ,
    parameter                   DYN_DEBUG_SEL_EN                = "FALSE"       ,
    parameter    integer        DEBUG_INFO_SEL                  = 0             ,
    parameter    integer        BAR_RESIZABLE                   = 21            ,
    parameter    integer        NUM_OF_RBARS                    = 3             ,
    parameter    integer        BAR_INDEX_0                     = 0             ,
    parameter    integer        BAR_INDEX_1                     = 2             ,
    parameter    integer        BAR_INDEX_2                     = 4             ,
    parameter                   TPH_DISABLE                     = "FALSE"       ,
    parameter                   MSIX_CAP_DISABLE                = "FALSE"       ,
    parameter                   MSI_CAP_DISABLE                 = "FALSE"       ,
    parameter                   MSI_PVM_DISABLE                 = "FALSE"       ,
    parameter    integer        BAR_MASK_WRITABLE               = 32            ,
    parameter    integer        APP_DEV_NUM                     = 0             ,
    parameter    integer        APP_BUS_NUM                     = 0             ,
    parameter                   RAM_MUX_EN                      = "FALSE"       ,
    parameter                   ATOMIC_DISABLE                  = "FALSE"       ,
    // cfg space reg
    parameter                   MAX_LINK_WIDTH                  = 6'b00_0100    ,
    parameter                   MAX_LINK_SPEED                  = 4'b0010       ,
    parameter                   LINK_CAPABLE                    = 6'b00_0111    ,
    parameter                   SCRAMBLE_DISABLE                = 1'b0          ,
    parameter                   AUTO_LANE_FLIP_CTRL_EN          = 1'b1          ,
    parameter                   NUM_OF_LANES                    = 5'b0_0001     ,
    parameter                   MAX_PAYLOAD_SIZE                = 3'b011        ,
    parameter                   INT_DISABLE                     = 1'b0          ,
    parameter                   PVM_SUPPORT                     = 1'b1          ,
    parameter                   MSI_64_BIT_ADDR_CAP             = 1'b1          ,
    parameter                   MSI_MULTIPLE_MSG_CAP            = 3'b101        ,
    parameter                   MSI_ENABLE                      = 1'b0          ,
    parameter                   MSI_CAP_NEXT_OFFSET             = 8'h70         ,
    parameter                   CAP_POINTER                     = 8'h50         ,
    parameter                   PCIE_CAP_NEXT_PTR               = 8'h00         ,
    parameter                   VENDOR_ID                       = 16'h0755      ,
    parameter                   DEVICE_ID                       = 16'h0755      ,
    parameter                   BASE_CLASS_CODE                 = 8'h05         ,
    parameter                   SUBCLASS_CODE                   = 8'h80         ,
    parameter                   PROGRAM_INTERFACE               = 8'h00         ,
    parameter                   REVISION_ID                     = 8'h00         ,
    parameter                   SUBSYS_DEV_ID                   = 16'h0000      ,
    parameter                   SUBSYS_VENDOR_ID                = 16'h0000      ,
    parameter                   BAR0_PREFETCH                   = 1'b0          ,
    parameter                   BAR0_TYPE                       = 2'b0          ,
    parameter                   BAR0_MEM_IO                     = 1'b0          ,
    parameter                   BAR0_ENABLED                    = 1'b1          ,
    parameter                   BAR0_MASK                       = 31'h0000_0fff ,
    parameter                   BAR1_PREFETCH                   = 1'b0          ,
    parameter                   BAR1_TYPE                       = 2'b0          ,
    parameter                   BAR1_MEM_IO                     = 1'b0          ,
    parameter                   BAR1_ENABLED                    = 1'b1          ,
    parameter                   BAR1_MASK                       = 31'h0000_07ff ,
    parameter                   BAR2_PREFETCH                   = 1'b0          ,
    parameter                   BAR2_TYPE                       = 2'b10         ,
    parameter                   BAR2_MEM_IO                     = 1'b0          ,
    parameter                   BAR2_ENABLED                    = 1'b1          ,
    parameter                   BAR2_MASK                       = 31'h0000_0fff ,
    parameter                   BAR3_PREFETCH                   = 1'b0          ,
    parameter                   BAR3_TYPE                       = 2'b0          ,
    parameter                   BAR3_MEM_IO                     = 1'b0          ,
    parameter                   BAR3_ENABLED                    = 1'b0          ,
    parameter                   BAR3_MASK                       = 31'd0         ,
    parameter                   BAR4_PREFETCH                   = 1'b0          ,
    parameter                   BAR4_TYPE                       = 2'b0          ,
    parameter                   BAR4_MEM_IO                     = 1'b0          ,
    parameter                   BAR4_ENABLED                    = 1'b0          ,
    parameter                   BAR4_MASK                       = 31'd0         ,
    parameter                   BAR5_PREFETCH                   = 1'b0          ,
    parameter                   BAR5_TYPE                       = 2'b0          ,
    parameter                   BAR5_MEM_IO                     = 1'b0          ,
    parameter                   BAR5_ENABLED                    = 1'b0          ,
    parameter                   BAR5_MASK                       = 31'd0         ,
    parameter                   ROM_BAR_ENABLE                  = 1'b0          ,
    parameter                   ROM_BAR_ENABLED                 = 1'd0          ,
    parameter                   ROM_MASK                        = 31'd0         ,
    parameter                   DO_DESKEW_FOR_SRIS              = 1'b1          ,
    parameter                   PCIE_CAP_HW_AUTO_SPEED_DISABLE  = 1'b0          ,
    parameter                   TARGET_LINK_SPEED               = 4'h1          ,

    parameter                   ECRC_CHECK_EN                   = 1'b1          ,
    parameter                   ECRC_GEN_EN                     = 1'b1          ,
    parameter                   EXT_TAG_EN                      = 1'b1          ,
    parameter                   EXT_TAG_SUPP                    = 1'b1          ,
    parameter                   PCIE_CAP_RCB                    = 1'b1          ,
    parameter                   PCIE_CAP_CRS                    = 1'b0          ,
    parameter                   PCIE_CAP_ATOMIC_EN              = 1'b0          ,

    parameter                   PCI_MSIX_ENABLE                 = 1'b0          ,
    parameter                   PCI_FUNCTION_MASK               = 1'b0          ,
    parameter                   PCI_MSIX_TABLE_SIZE             = 11'h0         ,
    parameter                   PCI_MSIX_CPA_NEXT_OFFSET        = 8'h0          ,
    parameter                   PCI_MSIX_TABLE_OFFSET           = 29'h0         ,
    parameter                   PCI_MSIX_BIR                    = 3'h0          ,
    parameter                   PCI_MSIX_PBA_OFFSET             = 29'h0         ,
    parameter                   PCI_MSIX_PBA_BIR                = 3'h0          ,
    parameter                   AER_CAP_NEXT_OFFSET             = 12'h0         ,
    parameter                   TPH_REQ_NEXT_PTR                = 12'h0         ,
    parameter                   RESBAR_BAR0_MAX_SUPP_SIZE       = 20'hf_ffff    ,
    parameter                   RESBAR_BAR0_INIT_SIZE           = 5'h13         ,
    parameter                   RESBAR_BAR1_MAX_SUPP_SIZE       = 20'hf_ffff    ,
    parameter                   RESBAR_BAR1_INIT_SIZE           = 5'h13         ,
    parameter                   RESBAR_BAR2_MAX_SUPP_SIZE       = 20'hf_ffff    ,
    parameter                   RESBAR_BAR2_INIT_SIZE           = 5'hb          ,
    parameter                   UPCONFIGURE_SUPPORT             = 1'b1
)(
    //clk & rst
    input                           mem_clk                 ,
    input                           pclk                    ,
    input                           pclk_div2               ,
    input                           button_rst              ,
    input                           power_up_rst            ,
    input                           perst                   ,
    output  wire                    core_rst_n              ,
    output  wire                    training_rst_n          ,
    input                           app_init_rst            ,
    output  wire                    phy_rst_n               ,
    //system control
    input                           rx_lane_flip_en         ,
    input                           tx_lane_flip_en         ,
    output  wire                    smlh_link_up            ,
    output  wire                    rdlh_link_up            ,
    input                           app_req_retry_en        ,
    output  wire    [4:0]           smlh_ltssm_state        ,

    //AXIS master interface
    output  wire                    axis_master_tvalid      ,
    input                           axis_master_tready      ,
    output  wire    [127:0]         axis_master_tdata       ,
    output  wire    [3:0]           axis_master_tkeep       ,
    output  wire                    axis_master_tlast       ,
    output  wire    [7:0]           axis_master_tuser       ,

    input           [2:0]           trgt1_radm_pkt_halt     ,
    output  wire    [5:0]           radm_grant_tlp_type     ,
    //AXIS slave 0 interface
    output  wire                    axis_slave0_tready      ,
    input                           axis_slave0_tvalid      ,
    input           [127:0]         axis_slave0_tdata       ,
    input                           axis_slave0_tlast       ,
    input                           axis_slave0_tuser       ,

    //AXIS slave 1 interface
    output  wire                    axis_slave1_tready      ,
    input                           axis_slave1_tvalid      ,
    input           [127:0]         axis_slave1_tdata       ,
    input                           axis_slave1_tlast       ,
    input                           axis_slave1_tuser       ,

    //AXIS slave 2 interface
    output  wire                    axis_slave2_tready      ,
    input                           axis_slave2_tvalid      ,
    input           [127:0]         axis_slave2_tdata       ,
    input                           axis_slave2_tlast       ,
    input                           axis_slave2_tuser       ,

    output  wire                    pm_xtlh_block_tlp       ,
    //apb interface
    input                           apb_sel                 ,
    input           [ 3:0]          apb_strb                ,
    input           [15:0]          apb_addr                ,
    input           [31:0]          apb_wdata               ,
    input                           apb_ce                  ,
    input                           apb_we                  ,
    output  wire                    apb_rdy                 ,
    output  wire    [31:0]          apb_rdata               ,

    input                           tx_rst_done             ,
    //Legacy Interrupt
    output  wire                    cfg_int_disable         ,
    input                           sys_int                 ,
    output  wire                    inta_grt_mux            ,
    output  wire                    intb_grt_mux            ,
    output  wire                    intc_grt_mux            ,
    output  wire                    intd_grt_mux            ,
    //MSI Interface
    input                           ven_msi_req             ,
    input           [2:0]           ven_msi_tc              ,
    input           [4:0]           ven_msi_vector          ,
    output  wire                    ven_msi_grant           ,
    input           [(32*1)-1:0]    cfg_msi_pending         ,
    output  wire                    cfg_msi_en              ,
    // MSI-X Interface
    input           [63:0]          msix_addr               ,
    input           [31:0]          msix_data               ,
    output  wire                    cfg_msix_en             ,
    output  wire                    cfg_msix_func_mask      ,
    //Power Management
    output  wire                    radm_pm_turnoff         ,
    output  wire                    radm_msg_unlock         ,
    input                           outband_pwrup_cmd       ,
    output  wire                    pm_status               ,
    output  wire    [2:0]           pm_dstate               ,
    output  wire                    aux_pm_en               ,
    output  wire                    pm_pme_en               ,
    output  wire                    pm_linkst_in_l0s        ,
    output  wire                    pm_linkst_in_l1         ,
    output  wire                    pm_linkst_in_l2         ,
    output  wire                    pm_linkst_l2_exit       ,
    input                           app_req_entr_l1         ,
    input                           app_ready_entr_l23      ,
    input                           app_req_exit_l1         ,
    input                           app_xfer_pending        ,
    output  wire                    wake                    ,
    output  wire                    radm_pm_pme             ,
    output  wire                    radm_pm_to_ack          ,
    input                           apps_pm_xmt_turnoff     ,
    input                           app_unlock_msg          ,
    input                           apps_pm_xmt_pme         ,
    input                           app_clk_pm_en           ,
    output  wire    [4:0]           pm_master_state         ,
    output  wire    [4:0]           pm_slave_state          ,
    input                           sys_aux_pwr_det         ,
    //Error Handling
    input                           app_hdr_valid           ,
    input           [127:0]         app_hdr_log             ,
    input           [12:0]          app_err_bus             ,
    input                           app_err_advisory        ,
    output  wire                    cfg_send_cor_err_mux    ,
    output  wire                    cfg_send_nf_err_mux     ,
    output  wire                    cfg_send_f_err_mux      ,
    output  wire                    cfg_sys_err_rc          ,
    output  wire                    cfg_aer_rc_err_mux      ,
    //radm timeout
    output  wire                    radm_cpl_timeout        ,
    output  wire    [2:0]           radm_timeout_cpl_tc     ,
    output  wire    [7:0]           radm_timeout_cpl_tag    ,
    output  wire    [1:0]           radm_timeout_cpl_attr   ,
    output  wire    [10:0]          radm_timeout_cpl_len    ,
    //Configuration Information Signals
    output  wire    [2:0]           cfg_max_rd_req_size     ,
    output  wire                    cfg_bus_master_en       ,
    output  wire    [2:0]           cfg_max_payload_size    ,
    output  wire                    cfg_ext_tag_en          ,
    output  wire                    cfg_rcb                 ,
    output  wire                    cfg_mem_space_en        ,
    output  wire                    cfg_pm_no_soft_rst      ,
    output  wire                    cfg_crs_sw_vis_en       ,
    output  wire                    cfg_no_snoop_en         ,
    output  wire                    cfg_relax_order_en      ,
    output  wire    [2-1:0]         cfg_tph_req_en          ,
    output  wire    [3-1:0]         cfg_pf_tph_st_mode      ,
    output  wire    [7:0]           cfg_pbus_num            ,
    output  wire    [4:0]           cfg_pbus_dev_num        ,
    output  wire                    rbar_ctrl_update        ,
    output  wire                    cfg_atomic_req_en       ,
    output  wire                    cfg_atomic_egress_block ,
    //Debug Signals
    output  wire                        radm_idle                   ,
    output  wire                        radm_q_not_empty            ,
    output  wire                        radm_qoverflow              ,
    input           [1:0]               diag_ctrl_bus               ,
    input           [3:0]               dyn_debug_info_sel          ,
    output  wire                        cfg_link_auto_bw_mux        ,
    output  wire                        cfg_bw_mgt_mux              ,
    output  wire                        cfg_pme_mux                 ,
    output  wire    [DEBUG_INFO_DW-1:0] debug_info_mux              ,
    input                               app_ras_des_sd_hold_ltssm   ,
    input           [1:0]               app_ras_des_tba_ctrl        ,
    //MISC
    output  wire                    cfg_ido_req_en          ,
    output  wire                    cfg_ido_cpl_en          ,
    output  wire    [7:0]           xadm_ph_cdts            ,
    output  wire    [11:0]          xadm_pd_cdts            ,
    output  wire    [7:0]           xadm_nph_cdts           ,
    output  wire    [11:0]          xadm_npd_cdts           ,
    output  wire    [7:0]           xadm_cplh_cdts          ,
    output  wire    [11:0]          xadm_cpld_cdts          ,
    // PIPE interface
    input                           phy_rate_chng_halt      ,
    output  wire    [1 : 0]         mac_phy_powerdown       ,
    input           [3:0]           phy_mac_rxelecidle      ,
    input           [3:0]           phy_mac_phystatus       ,
    input           [127:0]         phy_mac_rxdata          ,
    input           [15:0]          phy_mac_rxdatak         ,
    input           [3:0]           phy_mac_rxvalid         ,
    input           [(4*3)-1:0]     phy_mac_rxstatus        ,
    output  wire    [127:0]         mac_phy_txdata          ,
    output  wire    [15:0]          mac_phy_txdatak         ,

    output  wire    [3:0]           mac_phy_txdetectrx_loopback     ,
    output  wire    [3:0]           mac_phy_txelecidle_l            ,
    output  wire    [3:0]           mac_phy_txelecidle_h            ,
    output  wire    [3:0]           mac_phy_txcompliance            ,
    output  wire    [3:0]           mac_phy_rxpolarity              ,
    output  wire                    mac_phy_rate                    ,
    output  wire    [1:0]           mac_phy_txdeemph                ,
    output  wire    [2:0]           mac_phy_txmargin                ,
    output  wire                    mac_phy_txswing                 ,
    output  wire                    cfg_hw_auto_sp_dis
);

//external ram interface : rcv data ram , retry buff data ram.
wire                [10-1:0]        p_dataq_addra           ;
wire                [66-1:0]        p_dataq_datain          ;
wire                [1-1:0]         p_dataq_ena             ;
wire                [1-1:0]         p_dataq_wea             ;
wire                [66-1:0]        p_dataq_dataout         ;
wire                [10-1:0]        p_dataq_addrb           ;
wire                [1-1:0]         p_dataq_enb             ;

wire                [11 -1:0]       xdlh_retryram_addr      ;
wire                [68-1:0]        xdlh_retryram_data      ;
wire                                xdlh_retryram_we        ;
wire                                xdlh_retryram_en        ;
wire                [68-1:0]        retryram_xdlh_data      ;

wire                [8:0]           p_hdrq_addra            ;
wire                [137:0]         p_hdrq_datain           ;
wire                [1-1:0]         p_hdrq_ena              ;
wire                [1-1:0]         p_hdrq_wea              ;
wire                [8:0]           p_hdrq_addrb            ;
wire                [1-1:0]         p_hdrq_enb              ;
wire                [137:0]         p_hdrq_dataout          ;

reg                 [137:0]         p_hdrq_data_in_r        ;
wire                [137:0]         p_hdrq_data_in_ram      ;
wire                [ 65:0]         p_dataq_data_in_ram     ;
wire                [  8:0]         p_hdrq_addra_in_ram     ;
wire                [  9:0]         p_dataq_addra_in_ram    ;

wire                [71:0]          retryram_xdlh_data_i    ;
wire                [71:0]          p_dataq_dataout_i       ;
wire                [143:0]         p_hdrq_dataout_i        ;

reg                                 core_rst_n_mem          ;
reg                                 core_rst_n_mem_r1       ;
wire                                mem_rst_n               ;
wire                                s_mem_rst_n             ;

//seio
wire                                sedo                        ;
wire                                sedo_en                     ;
wire                                sedi                        ;
wire                                sedi_ack                    ;

// APB2DBI
reg                 [31:0]          dbi_addr                    ;
reg                 [31:0]          dbi_din                     ;
reg                                 dbi_cs                      ;
reg                                 dbi_cs2                     ;
reg                 [3:0]           dbi_wr                      ;
reg                                 app_dbi_ro_wr_disable       ;


wire                                app_ltssm_enable            ;
wire                                dbi_halt                    ;
wire                                lbc_dbi_ack                 ;
wire                [31:0]          lbc_dbi_dout                ;
wire                                init_finish                 ;
wire                [31:0]          init_dbi_addr               ;
wire                [31:0]          init_dbi_din                ;
wire                                init_dbi_cs                 ;
wire                                init_dbi_cs2                ;
wire                [3:0]           init_dbi_wr                 ;
wire                                init_app_dbi_ro_wr_disable  ;
wire                [31:0]          if_dbi_addr                 ;
wire                [31:0]          if_dbi_din                  ;
wire                                if_dbi_cs                   ;
wire                                if_dbi_cs2                  ;
wire                [3:0]           if_dbi_wr                   ;
wire                                if_app_dbi_ro_wr_disable    ;
wire                                s_tx_rst_done               ;

// External RAMs begin
always @ (posedge mem_clk or negedge core_rst_n)
begin
    if(~core_rst_n)
    begin
        core_rst_n_mem_r1   <= 1'b0;
        core_rst_n_mem      <= 1'b0;
    end
    else
    begin
        core_rst_n_mem_r1   <= 1'b1;
        core_rst_n_mem      <= core_rst_n_mem_r1;
    end
end

`ifndef RAM_OUTPUT_MUX_DISABLE

    always @ (posedge mem_clk or negedge core_rst_n_mem )
        if(~core_rst_n_mem)
            p_hdrq_data_in_r <= 138'h0;
        else
            p_hdrq_data_in_r <= p_hdrq_datain;

    assign p_hdrq_data_in_ram   = {p_hdrq_datain[68:0],p_hdrq_data_in_r[68:0]};
    assign p_hdrq_addra_in_ram  =  p_dataq_addra[8:0];
    assign p_dataq_data_in_ram  =  p_hdrq_datain[65:0];
    assign p_dataq_addra_in_ram =  p_dataq_addra;

`else
    assign p_hdrq_data_in_ram   = p_hdrq_datain;
    assign p_hdrq_addra_in_ram  = p_hdrq_addra;
    assign p_dataq_data_in_ram  = p_dataq_datain;
    assign p_dataq_addra_in_ram = p_dataq_addra;

`endif

assign #TP retryram_xdlh_data   = retryram_xdlh_data_i[67:0];
assign #TP p_dataq_dataout      = p_dataq_dataout_i[65 :0];
assign #TP p_hdrq_dataout       = p_hdrq_dataout_i[137:0];

assign mem_rst_n    = ~button_rst && ~perst;

ipsl_pcie_sync_v1_0  mem_button_rstn_sync (.clk(mem_clk), .rst_n(mem_rst_n), .sig_async(1'b1),  .sig_synced(s_mem_rst_n));

ipsl_pcie_ext_rcvd_ram u_pcie_iip_exrcvdata_rams(
    .wr_addr    (p_dataq_addra_in_ram       ),
    .rd_addr    (p_dataq_addrb              ),
    .wr_data    ({6'b0,p_dataq_data_in_ram} ),
    .wr_en      (p_dataq_ena                ),
    .rd_data    (p_dataq_dataout_i          ),
    .wr_clk     (mem_clk                    ),
    .rd_clk     (mem_clk                    ),
    .rd_rst     (~s_mem_rst_n               ),
    .wr_rst     (~s_mem_rst_n               )
);

ipsl_pcie_ext_rcvh_ram u_pcie_iip_exrcvhdr_rams(
    .wr_addr    (p_hdrq_addra_in_ram        ),
    .rd_addr    (p_hdrq_addrb               ),
    .wr_data    ({6'b0,p_hdrq_data_in_ram}  ),
    .wr_en      (p_hdrq_ena                 ),
    .rd_data    (p_hdrq_dataout_i           ),
    .wr_clk     (mem_clk                    ),
    .rd_clk     (mem_clk                    ),
    .rd_rst     (~s_mem_rst_n               ),
    .wr_rst     (~s_mem_rst_n               )
);

ipsl_pcie_retryd_ram u_pcie_iip_exretry_rams(
    .addr       (xdlh_retryram_addr         ),
    .wr_data    ({4'b0,xdlh_retryram_data}  ),
    .wr_en      (xdlh_retryram_we           ),
    .rd_data    (retryram_xdlh_data_i       ),
    .clk        (mem_clk                    ),
    .rst        (~s_mem_rst_n               )
);
// External RAMs end

// SEIO begin
ipsl_pcie_seio_intf_v1_0 u_pcie_seio(
    .pclk_div2      (pclk_div2      ),
    .user_rst_n     (core_rst_n     ),

    .sedo_in        (sedo           ),
    .sedo_en_in     (sedo_en        ),
    .sedi           (sedi           ),
    .sedi_ack       (sedi_ack       )
);
// SEIO end

// Configuration Initial begin
ipsl_pcie_sync_v1_0  tx_rst_done_sync (.clk(pclk_div2), .rst_n(core_rst_n), .sig_async(tx_rst_done),  .sig_synced(s_tx_rst_done));

ipsl_pcie_cfg_init_v1_3 #(
    .DEVICE_TYPE                    (DEVICE_TYPE                    ),
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
    .MSI_CAP_NEXT_OFFSET            (MSI_CAP_NEXT_OFFSET            ),
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
    .BAR1_PREFETCH                  (BAR1_PREFETCH                  ),
    .BAR1_TYPE                      (BAR1_TYPE                      ),
    .BAR1_MEM_IO                    (BAR1_MEM_IO                    ),
    .BAR1_ENABLED                   (BAR1_ENABLED                   ),
    .BAR1_MASK                      (BAR1_MASK                      ),
    .BAR2_PREFETCH                  (BAR2_PREFETCH                  ),
    .BAR2_TYPE                      (BAR2_TYPE                      ),
    .BAR2_MEM_IO                    (BAR2_MEM_IO                    ),
    .BAR2_ENABLED                   (BAR2_ENABLED                   ),
    .BAR2_MASK                      (BAR2_MASK                      ),
    .BAR3_PREFETCH                  (BAR3_PREFETCH                  ),
    .BAR3_TYPE                      (BAR3_TYPE                      ),
    .BAR3_MEM_IO                    (BAR3_MEM_IO                    ),
    .BAR3_ENABLED                   (BAR3_ENABLED                   ),
    .BAR3_MASK                      (BAR3_MASK                      ),
    .BAR4_PREFETCH                  (BAR4_PREFETCH                  ),
    .BAR4_TYPE                      (BAR4_TYPE                      ),
    .BAR4_MEM_IO                    (BAR4_MEM_IO                    ),
    .BAR4_ENABLED                   (BAR4_ENABLED                   ),
    .BAR4_MASK                      (BAR4_MASK                      ),
    .BAR5_PREFETCH                  (BAR5_PREFETCH                  ),
    .BAR5_TYPE                      (BAR5_TYPE                      ),
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
) u_pcie_cfg_init(
    .clk                            (pclk_div2                      ), //input
    .rst_n                          (core_rst_n                     ), //input
    .start                          (s_tx_rst_done                  ), //input
    .dbi_ack                        (lbc_dbi_ack                    ), //input
    .dbi_cs                         (init_dbi_cs                    ), //output reg
    .dbi_cs2                        (init_dbi_cs2                   ), //output reg
    .dbi_addr                       (init_dbi_addr                  ), //output reg  [31:0]
    .dbi_din                        (init_dbi_din                   ), //output reg  [31:0]
    .dbi_wr                         (init_dbi_wr                    ), //output reg  [3:0]
    .dbi_ro_wr_disable              (init_app_dbi_ro_wr_disable     ), //output reg
    .init_finish                    (init_finish                    )  //output reg
);

assign app_ltssm_enable = init_finish;
// Configuration Initial end

// APB2DBI begin
assign dbi_halt = phy_rate_chng_halt;

ipsl_pcie_apb2dbi_v1_0 u_pcie_apb2dbi(
    .pclk_div2                      (pclk_div2                  ),
    .apb_rst_n                      (core_rst_n                 ),
    .p_sel                          (apb_sel                    ),
    .p_strb                         (apb_strb                   ),
    .p_addr                         (apb_addr                   ),
    .p_wdata                        (apb_wdata                  ),
    .p_ce                           (apb_ce                     ),
    .p_we                           (apb_we                     ),
    .p_rdy                          (apb_rdy                    ),
    .p_rdata                        (apb_rdata                  ),
    .dbi_addr                       (if_dbi_addr                ),
    .dbi_din                        (if_dbi_din                 ),
    .dbi_cs                         (if_dbi_cs                  ),
    .dbi_cs2                        (if_dbi_cs2                 ),
    .dbi_wr                         (if_dbi_wr                  ),
    .app_dbi_ro_wr_disable          (if_app_dbi_ro_wr_disable    ),
    .lbc_dbi_ack                    (lbc_dbi_ack                ),
    .lbc_dbi_dout                   (lbc_dbi_dout               ),
    .dbi_halt                       (dbi_halt                   ) 
);

always @(*) begin
    if (!init_finish) begin
        dbi_addr              = init_dbi_addr               ;
        dbi_din               = init_dbi_din                ;
        dbi_cs                = init_dbi_cs                 ;
        dbi_cs2               = init_dbi_cs2                ;
        dbi_wr                = init_dbi_wr                 ;
        app_dbi_ro_wr_disable = init_app_dbi_ro_wr_disable  ;
    end else begin
        dbi_addr              = if_dbi_addr                 ;
        dbi_din               = if_dbi_din                  ;
        dbi_cs                = if_dbi_cs                   ;
        dbi_cs2               = if_dbi_cs2                  ;
        dbi_wr                = if_dbi_wr                   ;
        app_dbi_ro_wr_disable = if_app_dbi_ro_wr_disable    ;
    end
end
// APB2DBI end

// GTP_PCIEGEN2 instance begin
GTP_PCIEGEN2#(
    .GRS_EN                     (GRS_EN                     ),
    .PIN_MUX_INT_FORCE_EN       (PIN_MUX_INT_FORCE_EN       ),
    .PIN_MUX_INT_DISABLE        (PIN_MUX_INT_DISABLE        ),
    .DIAG_CTRL_BUS_B2           (DIAG_CTRL_BUS_B2           ),
    .DYN_DEBUG_SEL_EN           (DYN_DEBUG_SEL_EN           ),
    .DEBUG_INFO_SEL             (DEBUG_INFO_SEL             ),
    .BAR_RESIZABLE              (BAR_RESIZABLE              ),
    .NUM_OF_RBARS               (NUM_OF_RBARS               ),
    .BAR_INDEX_0                (BAR_INDEX_0                ),
    .BAR_INDEX_1                (BAR_INDEX_1                ),
    .BAR_INDEX_2                (BAR_INDEX_2                ),
    .TPH_DISABLE                (TPH_DISABLE                ),
    .MSIX_CAP_DISABLE           (MSIX_CAP_DISABLE           ),
    .MSI_CAP_DISABLE            (MSI_CAP_DISABLE            ),
    .MSI_PVM_DISABLE            (MSI_PVM_DISABLE            ),
    .BAR_MASK_WRITABLE          (BAR_MASK_WRITABLE          ),
    .APP_DEV_NUM                (APP_DEV_NUM                ),
    .APP_BUS_NUM                (APP_BUS_NUM                ),
    .RAM_MUX_EN                 (RAM_MUX_EN                 ),
    .ATOMIC_DISABLE             (ATOMIC_DISABLE             ) 
)u_pcie(
    .MEM_CLK                    (mem_clk                    ),
    .PCLK                       (pclk                       ),
    .PCLK_DIV2                  (pclk_div2                  ),
    .BUTTON_RST                 (button_rst                 ),
    .POWER_UP_RST               (power_up_rst               ),
    .PERST                      (perst                      ),
    .CORE_RST_N                 (core_rst_n                 ),
    .TRAINING_RST_N             (training_rst_n             ),
    .APP_INIT_RST               (app_init_rst               ),
    .PHY_RST_N                  (phy_rst_n                  ),
    .DEVICE_TYPE                (DEVICE_TYPE                ),
    .RX_LANE_FLIP_EN            (rx_lane_flip_en            ),
    .TX_LANE_FLIP_EN            (tx_lane_flip_en            ),
    .APP_LTSSM_EN               (app_ltssm_enable           ),
    .SMLH_LINK_UP               (smlh_link_up               ),
    .RDLH_LINK_UP               (rdlh_link_up               ),
    .APP_REQ_RETRY_EN           (app_req_retry_en           ),
    .SMLH_LTSSM_STATE           (smlh_ltssm_state           ),

//*********************************************************************
//AXIS master interface
    .AXIS_MASTER_TVALID         (axis_master_tvalid         ),
    .AXIS_MASTER_TREADY         (axis_master_tready         ),
    .AXIS_MASTER_TDATA          (axis_master_tdata          ),
    .AXIS_MASTER_TKEEP          (axis_master_tkeep          ),
    .AXIS_MASTER_TLAST          (axis_master_tlast          ),
    .AXIS_MASTER_TUSER          (axis_master_tuser          ),
    .TRGT1_RADM_PKT_HALT        (trgt1_radm_pkt_halt        ),
    .RADM_GRANT_TLP_TYPE        (radm_grant_tlp_type        ),
//*********************************************************************
//axis slave 0 interface
    .AXIS_SLAVE0_TREADY         (axis_slave0_tready         ),
    .AXIS_SLAVE0_TVALID         (axis_slave0_tvalid         ),
    .AXIS_SLAVE0_TDATA          (axis_slave0_tdata          ),
    .AXIS_SLAVE0_TLAST          (axis_slave0_tlast          ),
    .AXIS_SLAVE0_TUSER          (axis_slave0_tuser          ),

//axis slave 1 interface
    .AXIS_SLAVE1_TREADY         (axis_slave1_tready         ),
    .AXIS_SLAVE1_TVALID         (axis_slave1_tvalid         ),
    .AXIS_SLAVE1_TDATA          (axis_slave1_tdata          ),
    .AXIS_SLAVE1_TLAST          (axis_slave1_tlast          ),
    .AXIS_SLAVE1_TUSER          (axis_slave1_tuser          ),

//axis slave 2 interface
    .AXIS_SLAVE2_TREADY         (axis_slave2_tready         ),
    .AXIS_SLAVE2_TVALID         (axis_slave2_tvalid         ),
    .AXIS_SLAVE2_TDATA          (axis_slave2_tdata          ),
    .AXIS_SLAVE2_TLAST          (axis_slave2_tlast          ),
    .AXIS_SLAVE2_TUSER          (axis_slave2_tuser          ),

    .PM_XTLH_BLOCK_TLP          (pm_xtlh_block_tlp          ),
//*********************************************************************
// DBI interface
    .DBI_ADDR                   (dbi_addr                   ),
    .DBI_DIN                    (dbi_din                    ),
    .DBI_CS                     (dbi_cs                     ),
    .DBI_CS2                    (dbi_cs2                    ),
    .DBI_WR                     (dbi_wr                     ),
    .APP_DBI_RO_WR_DISABLE      (app_dbi_ro_wr_disable      ),
    .LBC_DBI_ACK                (lbc_dbi_ack                ),
    .LBC_DBI_DOUT               (lbc_dbi_dout               ),
// ELBI to SEIO interface
    .SEDO                       (sedo                       ),
    .SEDO_EN                    (sedo_en                    ),
    .SEDI                       (sedi                       ),
    .SEDI_ACK                   (sedi_ack                   ),
//**********************************************************************
//legacy interrupt
    .CFG_INT_DISABLE            (cfg_int_disable            ),
    .SYS_INT                    (sys_int                    ),
    .INTA_GRT_MUX               (inta_grt_mux               ),
    .INTB_GRT_MUX               (intb_grt_mux               ),
    .INTC_GRT_MUX               (intc_grt_mux               ),
    .INTD_GRT_MUX               (intd_grt_mux               ),

//msi
    .VEN_MSI_REQ                (ven_msi_req                ),
    .VEN_MSI_TC                 (ven_msi_tc                 ),
    .VEN_MSI_VECTOR             (ven_msi_vector             ),
    .VEN_MSI_GRANT              (ven_msi_grant              ),
    .CFG_MSI_PENDING            (cfg_msi_pending            ),
    .CFG_MSI_EN                 (cfg_msi_en                 ),

// MSI-X interface
    .MSIX_ADDR                  (msix_addr                  ),
    .MSIX_DATA                  (msix_data                  ),
    .CFG_MSIX_EN                (cfg_msix_en                ),
    .CFG_MSIX_FUNC_MASK         (cfg_msix_func_mask         ),
//**********************************************************************
//power management
    .RADM_PM_TURNOFF            (radm_pm_turnoff            ),
    .RADM_MSG_UNLOCK            (radm_msg_unlock            ),
    .OUTBAND_PWRUP_CMD          (outband_pwrup_cmd          ),
    .PM_STATUS                  (pm_status                  ),
    .PM_DSTATE                  (pm_dstate                  ),
    .AUX_PM_EN                  (aux_pm_en                  ),
    .PM_PME_EN                  (pm_pme_en                  ),
    .PM_LINKST_IN_L0S           (pm_linkst_in_l0s           ),
    .PM_LINKST_IN_L1            (pm_linkst_in_l1            ),
    .PM_LINKST_IN_L2            (pm_linkst_in_l2            ),
    .PM_LINKST_L2_EXIT          (pm_linkst_l2_exit          ),
    .APP_REQ_ENTR_L1            (app_req_entr_l1            ),
    .APP_READY_ENTR_L23         (app_ready_entr_l23         ),
    .APP_REQ_EXIT_L1            (app_req_exit_l1            ),
    .APP_XFER_PENDING           (app_xfer_pending           ),
    .WAKE                       (wake                       ),
    .RADM_PM_PME                (radm_pm_pme                ),
    .RADM_PM_TO_ACK             (radm_pm_to_ack             ),
    .APPS_PM_XMT_TURNOFF        (apps_pm_xmt_turnoff        ),
    .APP_UNLOCK_MSG             (app_unlock_msg             ),
    .APPS_PM_XMT_PME            (apps_pm_xmt_pme            ),
    .APP_CLK_PM_EN              (app_clk_pm_en              ),
    .PM_MASTER_STATE            (pm_master_state            ),
    .PM_SLAVE_STATE             (pm_slave_state             ),
    .SYS_AUX_PWR_DET            (sys_aux_pwr_det            ),
//**********************************************************************
//error handling
    .APP_HDR_VALID              (app_hdr_valid              ),
    .APP_HDR_LOG                (app_hdr_log                ),
    .APP_ERR_BUS                (app_err_bus                ),
    .APP_ERR_ADVISORY           (app_err_advisory           ),
    .CFG_SEND_COR_ERR_MUX       (cfg_send_cor_err_mux       ),
    .CFG_SEND_NF_ERR_MUX        (cfg_send_nf_err_mux        ),
    .CFG_SEND_F_ERR_MUX         (cfg_send_f_err_mux         ),
    .CFG_SYS_ERR_RC             (cfg_sys_err_rc             ),
    .CFG_AER_RC_ERR_MUX         (cfg_aer_rc_err_mux         ),
//radm timeout
    .RADM_CPL_TIMEOUT           (radm_cpl_timeout           ),
    .RADM_TIMEOUT_CPL_TC        (radm_timeout_cpl_tc        ),
    .RADM_TIMEOUT_CPL_TAG       (radm_timeout_cpl_tag       ),
    .RADM_TIMEOUT_CPL_ATTR      (radm_timeout_cpl_attr      ),
    .RADM_TIMEOUT_CPL_LEN       (radm_timeout_cpl_len       ),

//**********************************************************************
//configuration signals
    .CFG_MAX_RD_REQ_SIZE        (cfg_max_rd_req_size        ),
    .CFG_BUS_MASTER_EN          (cfg_bus_master_en          ),
    .CFG_MAX_PAYLOAD_SIZE       (cfg_max_payload_size       ),
    .CFG_RCB                    (cfg_rcb                    ),
    .CFG_MEM_SPACE_EN           (cfg_mem_space_en           ),
    .CFG_PM_NO_SOFT_RST         (cfg_pm_no_soft_rst         ),
    .CFG_CRS_SW_VIS_EN          (cfg_crs_sw_vis_en          ),
    .CFG_NO_SNOOP_EN            (cfg_no_snoop_en            ),
    .CFG_RELAX_ORDER_EN         (cfg_relax_order_en         ),
    .CFG_TPH_REQ_EN             (cfg_tph_req_en             ),
    .CFG_PF_TPH_ST_MODE         (cfg_pf_tph_st_mode         ),
    .CFG_PBUS_NUM               (cfg_pbus_num               ),
    .CFG_PBUS_DEV_NUM           (cfg_pbus_dev_num           ),
    .RBAR_CTRL_UPDATE           (rbar_ctrl_update           ),
    .CFG_ATOMIC_REQ_EN          (cfg_atomic_req_en          ),
    .CFG_ATOMIC_EGRESS_BLOCK    (cfg_atomic_egress_block    ),
    .CFG_EXT_TAG_EN             (cfg_ext_tag_en             ),
//**********************************************************************
//debug signals
    .RADM_IDLE                  (radm_idle                  ),
    .RADM_Q_NOT_EMPTY           (radm_q_not_empty           ),
    .RADM_QOVERFLOW             (radm_qoverflow             ),
    .DIAG_CTRL_BUS              (diag_ctrl_bus              ),
    .DYN_DEBUG_INFO_SEL         (dyn_debug_info_sel         ),
    .CFG_LINK_AUTO_BW_MUX       (cfg_link_auto_bw_mux       ),
    .CFG_BW_MGT_MUX             (cfg_bw_mgt_mux             ),
    .CFG_PME_MUX                (cfg_pme_mux                ),
    .DEBUG_INFO_MUX             (debug_info_mux             ),
    .APP_RAS_DES_SD_HOLD_LTSSM  (app_ras_des_sd_hold_ltssm  ),
    .APP_RAS_DES_TBA_CTRL       (app_ras_des_tba_ctrl       ),

//misc
    .CFG_IDO_REQ_EN             (cfg_ido_req_en             ),
    .CFG_IDO_CPL_EN             (cfg_ido_cpl_en             ),
    .XADM_PH_CDTS               (xadm_ph_cdts               ),
    .XADM_PD_CDTS               (xadm_pd_cdts               ),
    .XADM_NPH_CDTS              (xadm_nph_cdts              ),
    .XADM_NPD_CDTS              (xadm_npd_cdts              ),
    .XADM_CPLH_CDTS             (xadm_cplh_cdts             ),
    .XADM_CPLD_CDTS             (xadm_cpld_cdts             ),
//**********************************************************************
// PIPE interface
    .MAC_PHY_POWERDOWN          (mac_phy_powerdown          ),
    .PHY_MAC_RXELECIDLE         (phy_mac_rxelecidle         ),
    .PHY_MAC_PHYSTATUS          (phy_mac_phystatus          ),
    .PHY_MAC_RXDATA             (phy_mac_rxdata             ),
    .PHY_MAC_RXDATAK            (phy_mac_rxdatak            ),
    .PHY_MAC_RXVALID            (phy_mac_rxvalid            ),
    .PHY_MAC_RXSTATUS           (phy_mac_rxstatus           ),
    .MAC_PHY_TXDATA             (mac_phy_txdata             ),
    .MAC_PHY_TXDATAK            (mac_phy_txdatak            ),
    .MAC_PHY_TXDETECTRX_LOOPBACK(mac_phy_txdetectrx_loopback),
    .MAC_PHY_TXELECIDLE_L       (mac_phy_txelecidle_l       ),
    .MAC_PHY_TXELECIDLE_H       (mac_phy_txelecidle_h       ),
    .MAC_PHY_TXCOMPLIANCE       (mac_phy_txcompliance       ),
    .MAC_PHY_RXPOLARITY         (mac_phy_rxpolarity         ),
    .MAC_PHY_RATE               (mac_phy_rate               ),
    .MAC_PHY_TXDEEMPH           (mac_phy_txdeemph           ),
    .MAC_PHY_TXMARGIN           (mac_phy_txmargin           ),
    .MAC_PHY_TXSWING            (mac_phy_txswing            ),
    .CFG_HW_AUTO_SP_DIS         (cfg_hw_auto_sp_dis         ),

    .P_DATAQ_DATAOUT            (p_dataq_dataout            ),
    .P_DATAQ_ADDRA              (p_dataq_addra              ),
    .P_DATAQ_ADDRB              (p_dataq_addrb              ),
    .P_DATAQ_DATAIN             (p_dataq_datain             ),
    .P_DATAQ_ENA                (p_dataq_ena                ),
    .P_DATAQ_ENB                (p_dataq_enb                ),
    .P_DATAQ_WEA                (p_dataq_wea                ),

    .XDLH_RETRYRAM_ADDR         (xdlh_retryram_addr         ),
    .XDLH_RETRYRAM_DATA         (xdlh_retryram_data         ),
    .XDLH_RETRYRAM_WE           (xdlh_retryram_we           ),
    .XDLH_RETRYRAM_EN           (xdlh_retryram_en           ),
    .RETRYRAM_XDLH_DATA         (retryram_xdlh_data         ),

    .P_HDRQ_ADDRA               (p_hdrq_addra               ),
    .P_HDRQ_ADDRB               (p_hdrq_addrb               ),
    .P_HDRQ_DATAIN              (p_hdrq_datain              ),
    .P_HDRQ_ENA                 (p_hdrq_ena                 ),
    .P_HDRQ_ENB                 (p_hdrq_enb                 ),
    .P_HDRQ_WEA                 (p_hdrq_wea                 ),
    .P_HDRQ_DATAOUT             (p_hdrq_dataout             ),

    .RAM_TEST_EN                (1'b0                       ),
    .RAM_TEST_ADDRH             (1'b0                       ),
    .RETRY_TEST_DATA_EN         (1'b0                       ),
    .RAM_TEST_MODE_N            (1'b1                       )
);
// GTP_PCIEGEN2 instance end

endmodule
