// Created by IP Generator (Version 2022.1 build 99559)


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
//
// Library:
// Filename: ipsl_pcie_wrap_v1_3_sim.v
//////////////////////////////////////////////////////////////////////////////
module ipsl_pcie_wrap_v1_3_sim

# (
    parameter    integer    APP_DEV_NUM     = 0 ,   // set device_number,RC only

    parameter    integer    APP_BUS_NUM     = 0     // set bus_number,RC only
)

(
    //clk and rst
    input                           free_clk            ,
    output  wire                    pclk                ,
    output  wire                    pclk_div2           ,
    output  wire                    ref_clk             ,
    input                           ref_clk_n           ,
    input                           ref_clk_p           ,
    input                           button_rst_n        ,
    input                           power_up_rst_n      ,
    input                           perst_n             ,
    output  wire                    core_rst_n          ,

    //APB interface to  DBI cfg
//    input                           p_clk               ,
    input                           p_sel               ,
    input           [ 3:0]          p_strb              ,
    input           [15:0]          p_addr              ,
    input           [31:0]          p_wdata             ,
    input                           p_ce                ,
    input                           p_we                ,
    output  wire                    p_rdy               ,
    output  wire    [31:0]          p_rdata             ,

    //PHY diff signals

    input           [1:0]           rxn                 ,
    input           [1:0]           rxp                 ,
    output  wire    [1:0]           txn                 ,
    output  wire    [1:0]           txp                 ,
    input           [1:0]           pcs_nearend_loop    ,
    input           [1:0]           pma_nearend_ploop   ,
    input           [1:0]           pma_nearend_sloop   ,

    //AXIS master interface
    output  wire                    axis_master_tvalid  ,
    input                           axis_master_tready  ,
    output  wire    [127:0]         axis_master_tdata   ,
    output  wire    [3:0]           axis_master_tkeep   ,
    output  wire                    axis_master_tlast   ,
    output  wire    [7:0]           axis_master_tuser   ,

    //axis slave 0 interface
    output  wire                    axis_slave0_tready  ,
    input                           axis_slave0_tvalid  ,
    input           [127:0]         axis_slave0_tdata   ,
    input                           axis_slave0_tlast   ,
    input                           axis_slave0_tuser   ,

    //axis slave 1 interface
    output  wire                    axis_slave1_tready  ,
    input                           axis_slave1_tvalid  ,
    input           [127:0]         axis_slave1_tdata   ,
    input                           axis_slave1_tlast   ,
    input                           axis_slave1_tuser   ,
    //axis slave 2 interface
    output  wire                    axis_slave2_tready  ,
    input                           axis_slave2_tvalid  ,
    input           [127:0]         axis_slave2_tdata   ,
    input                           axis_slave2_tlast   ,
    input                           axis_slave2_tuser   ,

    output  wire                    pm_xtlh_block_tlp   ,     //ask about the processing latency

    output  wire                    cfg_send_cor_err_mux ,
    output  wire                    cfg_send_nf_err_mux  ,
    output  wire                    cfg_send_f_err_mux   ,
    output  wire                    cfg_sys_err_rc       ,
    output  wire                    cfg_aer_rc_err_mux   ,

    //radm timeout
    output  wire                    radm_cpl_timeout     ,

    output  wire    [7:0]           cfg_pbus_num         ,
    output  wire    [4:0]           cfg_pbus_dev_num     ,

    //configuration signals
    output  wire    [2:0]           cfg_max_rd_req_size  ,
    output  wire                    cfg_bus_master_en    ,
    output  wire    [2:0]           cfg_max_payload_size ,
    output  wire                    cfg_ext_tag_en       ,
    output  wire                    cfg_rcb              ,
    output  wire                    cfg_mem_space_en     ,
    output  wire                    cfg_pm_no_soft_rst   ,
    output  wire                    cfg_crs_sw_vis_en    ,
    output  wire                    cfg_no_snoop_en      ,
    output  wire                    cfg_relax_order_en   ,
    output  wire    [2-1:0]         cfg_tph_req_en       ,
    output  wire    [3-1:0]         cfg_pf_tph_st_mode   ,
    output  wire                    rbar_ctrl_update     ,
    output  wire                    cfg_atomic_req_en    ,

    //debug signals
    output  wire                    radm_idle                 ,
    output  wire                    radm_q_not_empty          ,
    output  wire                    radm_qoverflow            ,
    input           [1:0]           diag_ctrl_bus             ,
    output  wire                    cfg_link_auto_bw_mux      , //merge cfg_link_auto_bw_msi and cfg_link_auto_bw_int
    output  wire                    cfg_bw_mgt_mux            , //merge cfg_bw_mgt_int and cfg_bw_mgt_msi
    output  wire                    cfg_pme_mux               , //merge cfg_pme_int and cfg_pme_msi
    input                           app_ras_des_sd_hold_ltssm ,
    input           [1:0]           app_ras_des_tba_ctrl      ,

    input           [3:0]           dyn_debug_info_sel        ,
    output  wire    [132:0]         debug_info_mux            ,

    //system signal
    output  wire                    smlh_link_up              ,
    output  wire                    rdlh_link_up              ,
    output  wire    [4:0]           smlh_ltssm_state
);

    localparam               DEVICE_TYPE                    = 3'b100;

`ifdef IPSL_PCIE_SPEEDUP_SIM
    localparam               DIAG_CTRL_BUS_B2               = "FAST_LINK_MODE";
    `else
    localparam               DIAG_CTRL_BUS_B2               = "NORMAL";
    `endif

    localparam               MSI_CAP_DISABLE                = "TRUE";

    localparam               MSIX_CAP_DISABLE               = "TRUE";

    localparam               MSI_PVM_DISABLE                = "TRUE";

    localparam               ATOMIC_DISABLE                 = "TRUE";

    localparam               TPH_DISABLE                    = "TRUE";

    // cfg space reg

    localparam               MAX_LINK_WIDTH                 = 6'd2   ;  //@IPC enum 6'd1,6'd2,6'd4

    localparam               MAX_LINK_SPEED                 = 4'd2   ;  //@IPC enum 4'd1,4'd2

    localparam               LINK_CAPABLE                   = 6'd3   ;  //@IPC enum 6'd1,6'd3,6'd7

    localparam               SCRAMBLE_DISABLE               = 1'b0;   //@IPC bool

    localparam               AUTO_LANE_FLIP_CTRL_EN         = 1'b0;   //@IPC bool

    localparam               NUM_OF_LANES                   = 5'b1   ;   //@IPC bool

    localparam               MAX_PAYLOAD_SIZE               = 3'd0   ;   //@IPC enum 3'd0,3'd1,3'd2,3'd3

    localparam               INT_DISABLE                    = 1'b1;   //@IPC bool

    localparam               MSI_ENABLE                     = 1'b0;   //@IPC bool

    localparam               MSI_64_BIT_ADDR_CAP            = 1'b0;   //@IPC bool

    localparam               MSI_MULTIPLE_MSG_CAP           = 3'd0   ;   //@IPC enum 3'd0,3'd1,3'd2,3'd3,3'd4,3'd5

    localparam               PVM_SUPPORT                    = 1'b0    ;   //@IPC bool

    localparam               CAP_POINTER                    = 8'h70    ;

    localparam               PCIE_CAP_NEXT_PTR              = 8'h00    ;

    localparam               VENDOR_ID                      = 16'h0755   ; //@IPC string

    localparam               DEVICE_ID                      = 16'h0755   ; //@IPC string

    localparam               BASE_CLASS_CODE                 = 8'h06   ; //@IPC string

    localparam               SUBCLASS_CODE                   = 8'h00    ; //@IPC string

    localparam               PROGRAM_INTERFACE               = 8'h00    ; //@IPC string

    localparam               REVISION_ID                    = 8'h00    ; //@IPC string

    localparam               SUBSYS_VENDOR_ID               = 16'h0000   ; //@IPC string

    localparam               SUBSYS_DEV_ID                  = 16'h0000   ; //@IPC string

    localparam               BAR0_PREFETCH                   = 1'b0   ;   //@IPC enum 1'b0,1'b1

    localparam               BAR0_TYPE                       = 2'd0   ;   //@IPC enum 2'd0,2'd2

    localparam               BAR0_MEM_IO                     = 1'b0   ;   //@IPC enum 1'b0,1'b1

    localparam               BAR0_ENABLED                    = 1'b1    ;   //@IPC bool

    localparam               BAR0_MASK                       = 31'hfff   ; //@IPC string

    localparam               BAR1_MEM_IO                     = 1'b0   ;   //@IPC enum 1'b0,1'b1

    localparam               BAR1_ENABLED                    = 1'b1    ;   //@IPC bool

    localparam               BAR1_MASK                       = 31'hfff   ; //@IPC string

    localparam               BAR2_PREFETCH                   = 1'b0   ;   //@IPC enum 1'b0,1'b1

    localparam               BAR2_TYPE                       = 2'd0   ;   //@IPC enum 2'd0,2'd2

    localparam               BAR2_MEM_IO                     = 1'b0   ;   //@IPC enum 1'b0,1'b1

    localparam               BAR2_ENABLED                    = 1'b0    ;   //@IPC bool

    localparam               BAR2_MASK                       = 31'h0   ; //@IPC string

    localparam               BAR3_MEM_IO                     = 1'b0   ;   //@IPC enum 1'b0,1'b1

    localparam               BAR3_ENABLED                    = 1'b0    ;   //@IPC bool

    localparam               BAR3_MASK                       = 31'h0   ; //@IPC string

    localparam               BAR4_PREFETCH                   = 1'b0   ;   //@IPC enum 1'b0,1'b1

    localparam               BAR4_TYPE                       = 2'd0   ;   //@IPC enum 2'd0,2'd2

    localparam               BAR4_MEM_IO                     = 1'b0   ;   //@IPC enum 1'b0,1'b1

    localparam               BAR4_ENABLED                    = 1'b0    ;   //@IPC bool

    localparam               BAR4_MASK                       = 31'h0   ; //@IPC string

    localparam               BAR5_MEM_IO                     = 1'b0   ;   //@IPC enum 1'b0,1'b1

    localparam               BAR5_ENABLED                    = 1'b0    ;   //@IPC bool

    localparam               BAR5_MASK                       = 31'h0   ; //@IPC string


    localparam               ROM_BAR_ENABLE                 = 1'b0    ;   //@IPC bool

    localparam               ROM_BAR_ENABLED                = 1'b0    ;   //@IPC bool

    localparam               ROM_MASK                       = 31'h0   ; //@IPC string

    localparam               DO_DESKEW_FOR_SRIS             = 1'b1      ;

    localparam               PCIE_CAP_HW_AUTO_SPEED_DISABLE = 1'b0    ;   //@IPC bool

    localparam               TARGET_LINK_SPEED              = 4'h2      ;  //@IPC enum 4'h1,4'h2

    localparam               ECRC_CHECK_EN                  = 1'b1     ;  //@IPC bool

    localparam               ECRC_GEN_EN                    = 1'b0     ;  //@IPC bool

    localparam               EXT_TAG_EN                     = 1'b1     ;  //@IPC bool

    localparam               EXT_TAG_SUPP                   = 1'b1     ;  //@IPC bool

    localparam               PCIE_CAP_RCB                   = 1'b1   ;   //@IPC enum 1'b0,1'b1

    localparam               PCIE_CAP_CRS                   = 1'b0     ;  //@IPC bool

    localparam               PCIE_CAP_ATOMIC_EN             = 1'b0     ;  //@IPC bool

    localparam               PCI_MSIX_ENABLE                = 1'b0     ;  //@IPC bool

    localparam               PCI_FUNCTION_MASK              = 1'b0      ;

    localparam               PCI_MSIX_TABLE_SIZE            = 11'h1   ; //@IPC string

    localparam               PCI_MSIX_CPA_NEXT_OFFSET       = 8'h0      ;

    localparam               PCI_MSIX_TABLE_OFFSET          = 29'h0   ; //@IPC string

    localparam               PCI_MSIX_BIR                   = 3'd0   ;   //@IPC enum 1'b0,1'b1

    localparam               PCI_MSIX_PBA_OFFSET            = 29'h0   ; //@IPC string

    localparam               PCI_MSIX_PBA_BIR               = 3'd0   ;   //@IPC enum 1'b0,1'b1

    localparam               AER_CAP_NEXT_OFFSET            = 12'h0    ;


    localparam               TPH_REQ_NEXT_PTR               = 12'h0    ;

    localparam  integer     BAR_RESIZABLE                   = 6'b000000         ;
    localparam  integer     NUM_OF_RBARS                    = 3                 ;
    localparam  integer     BAR_INDEX_0                     = 0                 ;
    localparam  integer     BAR_INDEX_1                     = 1                 ;
    localparam  integer     BAR_INDEX_2                     = 2                 ;
    localparam  integer     BAR_MASK_WRITABLE               = 6'b111111         ;
    localparam              RESBAR_BAR0_MAX_SUPP_SIZE       = 20'hf_ffff        ;
    localparam              RESBAR_BAR0_INIT_SIZE           = 5'h0              ;
    localparam              RESBAR_BAR1_MAX_SUPP_SIZE       = 20'hf_ffff        ;
    localparam              RESBAR_BAR1_INIT_SIZE           = 5'h0              ;
    localparam              RESBAR_BAR2_MAX_SUPP_SIZE       = 20'hf_ffff        ;
    localparam              RESBAR_BAR2_INIT_SIZE           = 5'h0              ;

    localparam               UPCONFIGURE_SUPPORT            = 1'b1     ;  //@IPC bool

localparam  integer     HSST_LANE_NUM = 2   ;

`ifdef IPSL_PCIE_SPEEDUP_SIM
    initial
    $display("HSST_X2_LANE MODE!");
`endif

//hot rst
wire    app_init_rst;
wire    training_rst_n;

assign  app_init_rst = 1'b0;

//system ctrl
wire            rx_lane_flip_en     ;
wire            tx_lane_flip_en     ;
wire            app_req_retry_en    ;

assign rx_lane_flip_en      = 1'b0;
assign tx_lane_flip_en      = 1'b0;
assign app_req_retry_en     = 1'b0;


//Rcv_Queue_Manage
wire  [2:0]            trgt1_radm_pkt_halt ;
wire  [5:0]            radm_grant_tlp_type ;

assign trgt1_radm_pkt_halt = 3'b0;

//legacy interrupt
wire                  cfg_int_disable     ;
wire                  sys_int             ;
wire                  inta_grt_mux        ;
wire                  intb_grt_mux        ;
wire                  intc_grt_mux        ;
wire                  intd_grt_mux        ;

assign sys_int = 1'b0;

//msi
wire  [4:0]           ven_msi_vector      ;
wire  [(32*1)-1:0]    cfg_msi_pending     ;
wire                  cfg_msi_en          ;

assign ven_msi_vector   = 5'b0;
assign cfg_msi_pending  = 32'b0;

//msi
wire                  ven_msi_req         ;
wire  [2:0]           ven_msi_tc          ;
wire                  ven_msi_grant       ;

assign ven_msi_req      = 1'b0;
assign ven_msi_tc       = 3'b0;

// MSI-X interface
wire  [63:0]          msix_addr           ;
wire  [31:0]          msix_data           ;
wire                  cfg_msix_en         ;
wire                  cfg_msix_func_mask  ;

assign msix_addr        = 64'b0;
assign msix_data        = 32'b0;

//unlock message
wire                  radm_msg_unlock     ;
wire                  app_unlock_msg      ;

assign app_unlock_msg = 1'b0;

//power management
wire                  radm_pm_turnoff     ;
wire                  outband_pwrup_cmd   ;
wire                  pm_status           ;
wire  [2:0]           pm_dstate           ;
wire                  aux_pm_en           ;
wire                  pm_pme_en           ;
wire                  pm_linkst_in_l0s    ;
wire                  pm_linkst_in_l1     ;
wire                  pm_linkst_in_l2     ;
wire                  pm_linkst_l2_exit   ;
wire                  app_req_entr_l1     ;
wire                  app_ready_entr_l23  ;
wire                  app_req_exit_l1     ;
wire                  app_xfer_pending    ;
wire                  wake                ;
wire                  radm_pm_pme         ;
wire                  radm_pm_to_ack      ;
wire                  apps_pm_xmt_turnoff ;
wire                  apps_pm_xmt_pme     ;
wire [4:0]            pm_master_state     ;
wire [4:0]            pm_slave_state      ;

assign outband_pwrup_cmd    = 1'b0;
assign app_req_entr_l1      = 1'b0;
assign app_ready_entr_l23   = 1'b0;
assign app_req_exit_l1      = 1'b0;
assign app_xfer_pending     = 1'b0;
assign apps_pm_xmt_turnoff  = 1'b0;
assign apps_pm_xmt_pme      = 1'b0;

//error handling
wire                   app_hdr_valid        ;
wire   [127:0]         app_hdr_log          ;
wire   [12:0]          app_err_bus          ;
wire                   app_err_advisory     ;

assign app_hdr_valid    = 1'b0;
assign app_hdr_log      = 128'b0;
assign app_err_bus      = 13'b0;
assign app_err_advisory = 1'b0;

//radm timeout
wire  [2:0]           radm_timeout_cpl_tc  ;
wire  [7:0]           radm_timeout_cpl_tag ;
wire  [1:0]           radm_timeout_cpl_attr;
wire  [10:0]          radm_timeout_cpl_len ;

//misc
wire                  cfg_ido_req_en            ;
wire                  cfg_ido_cpl_en            ;
wire  [7:0]           xadm_ph_cdts              ;
wire  [11:0]          xadm_pd_cdts              ;
wire  [7:0]           xadm_nph_cdts             ;
wire  [11:0]          xadm_npd_cdts             ;
wire  [7:0]           xadm_cplh_cdts            ;
wire  [11:0]          xadm_cpld_cdts            ;



//-------------------------------PCIE IP WRAP include PHY
ipsl_pcie_top_v1_3 #(
    .DEVICE_TYPE                    (DEVICE_TYPE                    ),
    .DIAG_CTRL_BUS_B2               (DIAG_CTRL_BUS_B2               ),      // "NORMAL" "FAST_LINK_MODE"
    .BAR_RESIZABLE                  (BAR_RESIZABLE                  ),      // 0: no resizable bar, 1: bar0 resizable, 2: bar1 resizable, 3: bar0-1 resizable, ... 56: bar3-bar5 resizable;  Please do not set more than 3 resizable bars at the same   time  Default value is 21 which is 6'b010101
    .NUM_OF_RBARS                   (NUM_OF_RBARS                   ),      // 0: no resizable bar, 1: one resizable bar, 2: two resizable bars, 3: three resizable bars  Default value is 3
    .BAR_INDEX_0                    (BAR_INDEX_0                    ),      // set bar index0 in resizable bar control register,   0: bar0 resizable 1: bar1 resizable 2: bar2 resizable ... 5: bar5 resizable  Default value is 0
    .BAR_INDEX_1                    (BAR_INDEX_1                    ),      // set bar index1 in resizable bar control register,   0: bar0 resizable 1: bar1 resizable 2: bar2 resizable ... 5: bar5 resizable  Default value is 2
    .BAR_INDEX_2                    (BAR_INDEX_2                    ),      // set bar index2 in resizable bar control register,   0: bar0 resizable 1: bar1 resizable 2: bar2 resizable ... 5: bar5 resizable  Default value is 4
    .BAR_MASK_WRITABLE              (BAR_MASK_WRITABLE              ),      // 0: no writable bar, 1: bar0 writable, 2: bar1 writable, 3: bar3 writable, ... 63: bar0-5 writable
    .TPH_DISABLE                    (TPH_DISABLE                    ),      // FALSE, TRUE
    .MSI_CAP_DISABLE                (MSI_CAP_DISABLE                ),      // FALSE, TRUE
    .MSI_PVM_DISABLE                (MSI_PVM_DISABLE                ),      // FALSE, TRUE
    .ATOMIC_DISABLE                 (ATOMIC_DISABLE                 ),      // FALSE, TRUE
    .MSIX_CAP_DISABLE               (MSIX_CAP_DISABLE               ),      // FALSE, TRUE

    .APP_DEV_NUM                    (APP_DEV_NUM                    ),      // set device_number
    .APP_BUS_NUM                    (APP_BUS_NUM                    ),      // set bus_number

    .HSST_LANE_NUM                  (HSST_LANE_NUM                  ),
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
) u_pcie_top (
    .i_button_rstn                  (button_rst_n                   ),
    .i_power_up_rstn                (power_up_rst_n                 ),
    .i_perstn                       (perst_n                        ),
    .o_core_rst_n                   (core_rst_n                     ),
    .o_training_rst_n               (training_rst_n                 ),
    .i_app_init_rst                 (app_init_rst                   ),
    .free_clk                       (free_clk                       ),
    .pclk                           (pclk                           ),
    .pclk_div2                      (pclk_div2                      ),
    //APB
//    .i_apb_clk                      (p_clk                          ),
    .i_apb_sel                      (p_sel                          ),
    .i_apb_strb                     (p_strb                         ),
    .i_apb_addr                     (p_addr                         ),
    .i_apb_wdata                    (p_wdata                        ),
    .i_apb_ce                       (p_ce                           ),
    .i_apb_we                       (p_we                           ),
    .o_apb_rdy                      (p_rdy                          ),
    .o_apb_rdata                    (p_rdata                        ),
    //diff signals
    .o_txn_lane                     (txn                            ),
    .o_txp_lane                     (txp                            ),
    .i_rxn_lane                     (rxn                            ),
    .i_rxp_lane                     (rxp                            ),
    .i_refckn                       (ref_clk_n                      ),
    .i_refckp                       (ref_clk_p                      ),
    .i_pcs_nearend_loop             (pcs_nearend_loop               ),
    .i_pma_nearend_ploop            (pma_nearend_ploop              ),
    .i_pma_nearend_sloop            (pma_nearend_sloop              ),
    //AXIS master interface
    .o_axis_master_tvalid           (axis_master_tvalid             ),
    .i_axis_master_tready           (axis_master_tready             ),
    .o_axis_master_tdata            (axis_master_tdata              ),
    .o_axis_master_tkeep            (axis_master_tkeep              ),
    .o_axis_master_tlast            (axis_master_tlast              ),
    .o_axis_master_tuser            (axis_master_tuser              ),
    .i_trgt1_radm_pkt_halt          (trgt1_radm_pkt_halt            ),
    .o_radm_grant_tlp_type          (radm_grant_tlp_type            ),
    //axis slave 0 interface
    .o_axis_slave0_tready           (axis_slave0_tready             ),
    .i_axis_slave0_tvalid           (axis_slave0_tvalid             ),
    .i_axis_slave0_tdata            (axis_slave0_tdata              ),
    .i_axis_slave0_tlast            (axis_slave0_tlast              ),
    .i_axis_slave0_tuser            (axis_slave0_tuser              ),
    //axis slave 1 interface
    .o_axis_slave1_tready           (axis_slave1_tready             ),
    .i_axis_slave1_tvalid           (axis_slave1_tvalid             ),
    .i_axis_slave1_tdata            (axis_slave1_tdata              ),
    .i_axis_slave1_tlast            (axis_slave1_tlast              ),
    .i_axis_slave1_tuser            (axis_slave1_tuser              ),
    //axis slave 2 interface
    .o_axis_slave2_tready           (axis_slave2_tready             ),
    .i_axis_slave2_tvalid           (axis_slave2_tvalid             ),
    .i_axis_slave2_tdata            (axis_slave2_tdata              ),
    .i_axis_slave2_tlast            (axis_slave2_tlast              ),
    .i_axis_slave2_tuser            (axis_slave2_tuser              ),
    .o_pm_xtlh_block_tlp            (pm_xtlh_block_tlp              ),
    //INT
    .o_cfg_int_disable              (cfg_int_disable                ),
    .i_sys_int                      (sys_int                        ),
    .o_inta_grt_mux                 (inta_grt_mux                   ),
    .o_intb_grt_mux                 (intb_grt_mux                   ),
    .o_intc_grt_mux                 (intc_grt_mux                   ),
    .o_intd_grt_mux                 (intd_grt_mux                   ),
    //MSI
    .i_ven_msi_req                  (ven_msi_req                    ),
    .i_ven_msi_tc                   (ven_msi_tc                     ),
    .i_ven_msi_vector               (ven_msi_vector                 ),
    .o_ven_msi_grant                (ven_msi_grant                  ),
    .i_cfg_msi_pending              (cfg_msi_pending                ),
    .o_cfg_msi_en                   (cfg_msi_en                     ),
    //MSI-X
    .i_msix_addr                    (msix_addr                      ),
    .i_msix_data                    (msix_data                      ),
    .o_cfg_msix_en                  (cfg_msix_en                    ),
    .o_cfg_msix_func_mask           (cfg_msix_func_mask             ),
    //unlock message
    .o_radm_msg_unlock              (radm_msg_unlock                ),
    .i_app_unlock_msg               (app_unlock_msg                 ),
    //power management
    .o_radm_pm_turnoff              (radm_pm_turnoff                ),
    .i_outband_pwrup_cmd            (outband_pwrup_cmd              ),
    .o_pm_status                    (pm_status                      ),
    .o_pm_dstate                    (pm_dstate                      ),
    .o_aux_pm_en                    (aux_pm_en                      ),
    .o_pm_pme_en                    (pm_pme_en                      ),
    .o_pm_linkst_in_l0s             (pm_linkst_in_l0s               ),
    .o_pm_linkst_in_l1              (pm_linkst_in_l1                ),
    .o_pm_linkst_in_l2              (pm_linkst_in_l2                ),
    .o_pm_linkst_l2_exit            (pm_linkst_l2_exit              ),
    .i_app_req_entr_l1              (app_req_entr_l1                ),
    .i_app_ready_entr_l23           (app_ready_entr_l23             ),
    .i_app_req_exit_l1              (app_req_exit_l1                ),
    .i_app_xfer_pending             (app_xfer_pending               ),
    .o_wake                         (wake                           ),
    .o_radm_pm_pme                  (radm_pm_pme                    ),
    .o_radm_pm_to_ack               (radm_pm_to_ack                 ),
    .i_apps_pm_xmt_turnoff          (apps_pm_xmt_turnoff            ),
    .i_apps_pm_xmt_pme              (apps_pm_xmt_pme                ),
    .i_app_clk_pm_en                (1'b0                           ),
    .o_pm_master_state              (pm_master_state                ),
    .o_pm_slave_state               (pm_slave_state                 ),
    .i_sys_aux_pwr_det              (1'b1                           ),
    //error handling
    .i_app_hdr_valid                (app_hdr_valid                  ),
    .i_app_hdr_log                  (app_hdr_log                    ),
    .i_app_err_bus                  (app_err_bus                    ),
    .i_app_err_advisory             (app_err_advisory               ),
    .o_cfg_send_cor_err_mux         (cfg_send_cor_err_mux           ),
    .o_cfg_send_nf_err_mux          (cfg_send_nf_err_mux            ),
    .o_cfg_send_f_err_mux           (cfg_send_f_err_mux             ),
    .o_cfg_sys_err_rc               (cfg_sys_err_rc                 ),
    .o_cfg_aer_rc_err_mux           (cfg_aer_rc_err_mux             ),
    //radm timeout
    .o_radm_cpl_timeout             (radm_cpl_timeout               ),
    .o_radm_timeout_cpl_tc          (radm_timeout_cpl_tc            ),
    .o_radm_timeout_cpl_tag         (radm_timeout_cpl_tag           ),
    .o_radm_timeout_cpl_attr        (radm_timeout_cpl_attr          ),
    .o_radm_timeout_cpl_len         (radm_timeout_cpl_len           ),
    //configuration signals
    .o_cfg_max_rd_req_size          (cfg_max_rd_req_size            ),
    .o_cfg_bus_master_en            (cfg_bus_master_en              ),
    .o_cfg_max_payload_size         (cfg_max_payload_size           ),
    .o_cfg_ext_tag_en               (cfg_ext_tag_en                 ),
    .o_cfg_rcb                      (cfg_rcb                        ),
    .o_cfg_mem_space_en             (cfg_mem_space_en               ),
    .o_cfg_pm_no_soft_rst           (cfg_pm_no_soft_rst             ),
    .o_cfg_crs_sw_vis_en            (cfg_crs_sw_vis_en              ),
    .o_cfg_no_snoop_en              (cfg_no_snoop_en                ),
    .o_cfg_relax_order_en           (cfg_relax_order_en             ),
    .o_cfg_tph_req_en               (cfg_tph_req_en                 ),
    .o_cfg_pf_tph_st_mode           (cfg_pf_tph_st_mode             ),
    .o_cfg_pbus_num                 (cfg_pbus_num                   ),
    .o_cfg_pbus_dev_num             (cfg_pbus_dev_num               ),
    .o_rbar_ctrl_update             (rbar_ctrl_update               ),
    .o_cfg_atomic_req_en            (cfg_atomic_req_en              ),
    .o_cfg_atomic_egress_block      (                               ),
    //debug signals
    .o_radm_idle                    (radm_idle                      ),
    .o_radm_q_not_empty             (radm_q_not_empty               ),
    .o_radm_qoverflow               (radm_qoverflow                 ),
    .i_diag_ctrl_bus                (diag_ctrl_bus                  ),
    .i_dyn_debug_info_sel           (dyn_debug_info_sel             ),
    .o_cfg_link_auto_bw_mux         (cfg_link_auto_bw_mux           ),
    .o_cfg_bw_mgt_mux               (cfg_bw_mgt_mux                 ),
    .o_cfg_pme_mux                  (cfg_pme_mux                    ),
    .o_debug_info_mux               (debug_info_mux                 ),
    .i_app_ras_des_sd_hold_ltssm    (app_ras_des_sd_hold_ltssm      ),
    .i_app_ras_des_tba_ctrl         (app_ras_des_tba_ctrl           ),
    //misc
    .o_cfg_ido_req_en               (cfg_ido_req_en                 ),
    .o_cfg_ido_cpl_en               (cfg_ido_cpl_en                 ),
    .o_xadm_ph_cdts                 (xadm_ph_cdts                   ),
    .o_xadm_pd_cdts                 (xadm_pd_cdts                   ),
    .o_xadm_nph_cdts                (xadm_nph_cdts                  ),
    .o_xadm_npd_cdts                (xadm_npd_cdts                  ),
    .o_xadm_cplh_cdts               (xadm_cplh_cdts                 ),
    .o_xadm_cpld_cdts               (xadm_cpld_cdts                 ),
    //system signal
    .i_rx_lane_flip_en              (rx_lane_flip_en                ),
    .i_tx_lane_flip_en              (tx_lane_flip_en                ),
    .o_smlh_link_up                 (smlh_link_up                   ),
    .o_rdlh_link_up                 (rdlh_link_up                   ),
    .i_app_req_retry_en             (app_req_retry_en               ),
    .o_smlh_ltssm_state             (smlh_ltssm_state               ),
    .o_refck2core_0                 (ref_clk                        )
);

endmodule
