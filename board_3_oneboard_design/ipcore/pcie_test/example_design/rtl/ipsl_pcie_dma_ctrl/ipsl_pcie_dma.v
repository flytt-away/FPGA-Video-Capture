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
// Filename:ipsl_pcie_dma.v
//////////////////////////////////////////////////////////////////////////////
module ipsl_pcie_dma #(
    parameter                           DEVICE_TYPE = 3'd0      ,   //3'd0:EP,3'd1:Legacy EP,3'd4:RC
    parameter   integer                 AXIS_SLAVE_NUM = 3      ,
    parameter                           ADDR_WIDTH  = 4'd12

)(
    input                               clk                     ,            //gen1:62.5MHz,gen2:125MHz
    input                               rst_n                   ,

    input           [7:0]               i_cfg_pbus_num          ,
    input           [4:0]               i_cfg_pbus_dev_num      ,
    input           [2:0]               i_cfg_max_rd_req_size   ,
    input           [2:0]               i_cfg_max_payload_size  ,
    //**********************************************************************
    //axis master interface
    input                               i_axis_master_tvld      ,
    output  wire                        o_axis_master_trdy      ,
    input           [127:0]             i_axis_master_tdata     ,
    input           [3:0]               i_axis_master_tkeep     ,
    input                               i_axis_master_tlast     ,
    input           [7:0]               i_axis_master_tuser     ,
    output  wire    [2:0]               o_trgt1_radm_pkt_halt   ,
//    input           [5:0]               i_radm_grant_tlp_type   ,
    //**********************************************************************
    //axis_slave0 interface
    input                               i_axis_slave0_trdy      ,
    output  wire                        o_axis_slave0_tvld      ,
    output  wire    [127:0]             o_axis_slave0_tdata     ,
    output  wire                        o_axis_slave0_tlast     ,
    output  wire                        o_axis_slave0_tuser     ,
    //axis_slave1 interface
    input                               i_axis_slave1_trdy      ,
    output  wire                        o_axis_slave1_tvld      ,
    output  wire    [127:0]             o_axis_slave1_tdata     ,
    output  wire                        o_axis_slave1_tlast     ,
    output  wire                        o_axis_slave1_tuser     ,
    //axis_slave2 interface
    input                               i_axis_slave2_trdy      ,
    output  wire                        o_axis_slave2_tvld      ,
    output  wire    [127:0]             o_axis_slave2_tdata     ,
    output  wire                        o_axis_slave2_tlast     ,
    output  wire                        o_axis_slave2_tuser     ,
    //**********************************************************************
    //credit interface
    //from pcie
    input                               i_cfg_ido_req_en        ,
    input                               i_cfg_ido_cpl_en        ,
    input           [7:0]               i_xadm_ph_cdts          ,
    input           [11:0]              i_xadm_pd_cdts          ,
    input           [7:0]               i_xadm_nph_cdts         ,
    input           [11:0]              i_xadm_npd_cdts         ,
    input           [7:0]               i_xadm_cplh_cdts        ,
    input           [11:0]              i_xadm_cpld_cdts        ,
    //**********************************************************************
    //apb interface
    input                               i_apb_psel              ,
    input           [8:0]               i_apb_paddr             ,
    input           [31:0]              i_apb_pwdata            ,
    input           [3:0]               i_apb_pstrb             ,
    input                               i_apb_pwrite            ,
    input                               i_apb_penable           ,
    output  wire                        o_apb_prdy              ,
    output  wire    [31:0]              o_apb_prdata            ,
    //cross_4kb_boundary
    output  wire                        o_cross_4kb_boundary
    //debug
    //output  wire    [159:0]             o_dbg_bus
);

//**********************************************************************
//from rx to tx
wire        [2:0]               mrd_tc;
wire        [2:0]               mrd_attr;
wire        [9:0]               mrd_length;
wire        [15:0]              mrd_id;
wire        [7:0]               mrd_tag;
wire        [63:0]              mrd_addr;

wire                            cpld_req_vld;
wire                            cpld_req_rdy;
wire                            cpld_tx_rdy;
//cpld rcv
wire                            cpld_rcv;
wire        [7:0]               cpld_tag;
wire                            tag_full;
//from dma_controller to tx
wire                            user_define_header_flag;
wire                            user_define_data_flag;
//mwr req & ack
wire                            mwr32_req;
wire                            mwr32_req_ack;
wire                            mwr64_req;
wire                            mwr64_req_ack;
//mrd req & ack
wire                            mrd32_req;
wire                            mrd32_req_ack;
wire                            mrd64_req;
wire                            mrd64_req_ack;
//req information
wire        [9:0]               req_length;
wire        [63:0]              req_addr;
wire        [31:0]              req_data;


//axis_slave0 interface
wire                            dma_axis_slave0_trdy ;
wire                            dma_axis_slave0_tvld ;
wire        [127:0]             dma_axis_slave0_tdata;
wire                            dma_axis_slave0_tlast;
wire                            dma_axis_slave0_tuser;
//axis_slave1 interface
wire                            dma_axis_slave1_trdy ;
wire                            dma_axis_slave1_tvld ;
wire        [127:0]             dma_axis_slave1_tdata;
wire                            dma_axis_slave1_tlast;
wire                            dma_axis_slave1_tuser;
//axis_slave2 interface
wire                            dma_axis_slave2_trdy ;
wire                            dma_axis_slave2_tvld ;
wire        [127:0]             dma_axis_slave2_tdata;
wire                            dma_axis_slave2_tlast;
wire                            dma_axis_slave2_tuser;

//**********************************************************************
//bar0 rd interface
wire                            bar0_rd_clk_en;
wire        [ADDR_WIDTH-1:0]    bar0_rd_addr;
wire        [127:0]             bar0_rd_data;
//bar1 wr interface
wire                            bar1_wr_en;
wire        [ADDR_WIDTH-1:0]    bar1_wr_addr;
wire        [127:0]             bar1_wr_data;
wire        [15:0]              bar1_wr_byte_en;
//bar2 rd interface
wire                            bar2_rd_clk_en;
wire        [ADDR_WIDTH-1:0]    bar2_rd_addr;
wire        [127:0]             bar2_rd_data;
//**********************************************************************
//rst tlp cnt
wire                            tx_restart;
wire        [63:0]              dma_check_result;
//debug bus
//wire        [42:0]              dbg_bus_rx_ctrl;
//wire        [43:0]              dbg_bus_mrd_tx;
//wire        [72:0]              dbg_bus_mwr_tx;

//assign o_dbg_bus = {
//                    dbg_bus_mwr_tx, //159:87
//                    dbg_bus_mrd_tx, //86:43
//                    dbg_bus_rx_ctrl //42:0
//                    };
wire        [7:0]               cfg_pbus_num;
wire        [4:0]               cfg_pbus_dev_num;
wire        [2:0]               cfg_max_rd_req_size;
wire        [2:0]               cfg_max_payload_size;
ipsl_pcie_reg #(
    .SIG_WIDTH                  (4'd8                       )
)
u_cfg_pbus_num_reg
(
    .clk                        (clk                        ),
    .sig                        (i_cfg_pbus_num             ),
    .sig_reg                    (cfg_pbus_num               )
);

ipsl_pcie_reg #(
    .SIG_WIDTH                  (3'd5                       )
)
u_cfg_pbus_dev_num_reg
(
    .clk                        (clk                        ),
    .sig                        (i_cfg_pbus_dev_num         ),
    .sig_reg                    (cfg_pbus_dev_num           )
);

ipsl_pcie_reg #(
    .SIG_WIDTH                  (2'd3                       )
)
u_max_rd_req_size_reg
(
    .clk                        (clk                        ),
    .sig                        (i_cfg_max_rd_req_size      ),
    .sig_reg                    (cfg_max_rd_req_size        )
);

ipsl_pcie_reg #(
    .SIG_WIDTH                  (2'd3                       )
)
u_max_payload_size_reg
(
    .clk                        (clk                        ),
    .sig                        (i_cfg_max_payload_size     ),
    .sig_reg                    (cfg_max_payload_size       )
);

ipsl_pcie_dma_rx_top #(
    .DEVICE_TYPE                (DEVICE_TYPE                ),  //3'd0:EP,3'd1:Legacy EP,3'd4:RC
    .ADDR_WIDTH                 (ADDR_WIDTH                 )
)
u_ipsl_pcie_dma_rx_top
(
    .clk                        (clk                        ),  //gen1:62.5MHz,gen2:125MHz
    .rst_n                      (rst_n                      ),
    .i_cfg_max_rd_req_size      (cfg_max_rd_req_size        ),  //input [2:0]
    //**********************************************************************
    //axis master interface
    .i_axis_master_tvld         (i_axis_master_tvld         ),
    .o_axis_master_trdy         (o_axis_master_trdy         ),
    .i_axis_master_tdata        (i_axis_master_tdata        ),
    .i_axis_master_tkeep        (i_axis_master_tkeep        ),
    .i_axis_master_tlast        (i_axis_master_tlast        ),
    .i_axis_master_tuser        (i_axis_master_tuser        ),
    .o_trgt1_radm_pkt_halt      (o_trgt1_radm_pkt_halt      ),
//    .i_radm_grant_tlp_type      (i_radm_grant_tlp_type      ),
    //**********************************************************************
    //bar0 rd interface
    .i_bar0_rd_clk_en           (bar0_rd_clk_en             ),
    .i_bar0_rd_addr             (bar0_rd_addr               ),
    .o_bar0_rd_data             (bar0_rd_data               ),
    //bar2 rd interface
    .i_bar2_rd_clk_en           (bar2_rd_clk_en             ),
    .i_bar2_rd_addr             (bar2_rd_addr               ),
    .o_bar2_rd_data             (bar2_rd_data               ),
    //bar1 wr interface
    .o_bar1_wr_en               (bar1_wr_en                 ),
    .o_bar1_wr_addr             (bar1_wr_addr               ),
    .o_bar1_wr_data             (bar1_wr_data               ),
    .o_bar1_wr_byte_en          (bar1_wr_byte_en            ),
    //**********************************************************************
    //to tx top
    //req rcv
    .o_mrd_tc                   (mrd_tc                     ),
    .o_mrd_attr                 (mrd_attr                   ),
    .o_mrd_length               (mrd_length                 ),
    .o_mrd_id                   (mrd_id                     ),
    .o_mrd_tag                  (mrd_tag                    ),
    .o_mrd_addr                 (mrd_addr                   ),

    .o_cpld_req_vld             (cpld_req_vld               ),
    .i_cpld_req_rdy             (cpld_req_rdy               ),
    .i_cpld_tx_rdy              (cpld_tx_rdy                ),
    //cpld rcv
    .o_cpld_rcv                 (cpld_rcv                   ),
    .o_cpld_tag                 (cpld_tag                   ),
    .i_tag_full                 (tag_full                   ),
    //rst tlp cnt
    .o_dma_check_result         (dma_check_result           ),
    .i_tx_restart               (tx_restart                 )

    //.o_dbg_bus_rx_ctrl          (dbg_bus_rx_ctrl            )
);

ipsl_pcie_dma_controller #(
    .DEVICE_TYPE                (DEVICE_TYPE                ),  //3'd0:EP,3'd1:Legacy EP,3'd4:RC
    .ADDR_WIDTH                 (ADDR_WIDTH                 )
)
u_ipsl_pcie_dma_controller
(
    .clk                        (clk                        ),  //gen1:62.5MHz,gen2:125MHz
    .rst_n                      (rst_n                      ),
    //**********************************************************************
    //bar1 wr interface
    .i_bar1_wr_en               (bar1_wr_en                 ),
    .i_bar1_wr_addr             (bar1_wr_addr               ),
    .i_bar1_wr_data             (bar1_wr_data               ),
    .i_bar1_wr_byte_en          (bar1_wr_byte_en            ),
    //**********************************************************************
    //apb interface
    .i_apb_psel                 (i_apb_psel                 ),
    .i_apb_paddr                (i_apb_paddr                ),
    .i_apb_pwdata               (i_apb_pwdata               ),
    .i_apb_pstrb                (i_apb_pstrb                ),
    .i_apb_pwrite               (i_apb_pwrite               ),
    .i_apb_penable              (i_apb_penable              ),
    .o_apb_prdy                 (o_apb_prdy                 ),
    .o_apb_prdata               (o_apb_prdata               ),
    //**********************************************************************
    .o_user_define_data_flag    (user_define_data_flag      ),

    //**********************************************************************
    //to tx top
    //mwr req & ack
    .o_mwr32_req                (mwr32_req                  ),
    .i_mwr32_req_ack            (mwr32_req_ack              ),
    .o_mwr64_req                (mwr64_req                  ),
    .i_mwr64_req_ack            (mwr64_req_ack              ),
    //mrd req & ack
    .o_mrd32_req                (mrd32_req                  ),
    .i_mrd32_req_ack            (mrd32_req_ack              ),
    .o_mrd64_req                (mrd64_req                  ),
    .i_mrd64_req_ack            (mrd64_req_ack              ),
    //req information
    .o_req_length               (req_length                 ),
    .o_req_addr                 (req_addr                   ),
    .o_req_data                 (req_data                   ),
    .o_cross_4kb_boundary       (o_cross_4kb_boundary       ),
    //rst tlp cnt
    .i_dma_check_result         (dma_check_result           ),
    .o_tx_restart               (tx_restart                 )
);

ipsl_pcie_dma_tx_top #(
//    .DEVICE_TYPE                (DEVICE_TYPE                ),          //3'd0:EP,3'd1:Legacy EP,3'd4:RC
    .ADDR_WIDTH                 (ADDR_WIDTH                 )
)
u_ipsl_pcie_dma_tx_top
(
    .clk                        (clk                        ),  //gen1:62.5MHz,gen2:125MHz
    .rst_n                      (rst_n                      ),
    .i_cfg_pbus_num             (cfg_pbus_num               ),  //input [7:0]
    .i_cfg_pbus_dev_num         (cfg_pbus_dev_num           ),  //input [4:0]
    .i_cfg_max_rd_req_size      (cfg_max_rd_req_size        ),  //input [2:0]
    .i_cfg_max_payload_size     (cfg_max_payload_size       ),  //input [2:0]
    //**********************************************************************
    //axis_slave0 interface
    .i_axis_slave0_trdy         (dma_axis_slave0_trdy       ),
    .o_axis_slave0_tvld         (dma_axis_slave0_tvld       ),
    .o_axis_slave0_tdata        (dma_axis_slave0_tdata      ),
    .o_axis_slave0_tlast        (dma_axis_slave0_tlast      ),
    .o_axis_slave0_tuser        (dma_axis_slave0_tuser      ),
    //axis_slave1 interface
    .i_axis_slave1_trdy         (dma_axis_slave1_trdy       ),
    .o_axis_slave1_tvld         (dma_axis_slave1_tvld       ),
    .o_axis_slave1_tdata        (dma_axis_slave1_tdata      ),
    .o_axis_slave1_tlast        (dma_axis_slave1_tlast      ),
    .o_axis_slave1_tuser        (dma_axis_slave1_tuser      ),
    //axis_slave2 interface
    .i_axis_slave2_trdy         (dma_axis_slave2_trdy       ),
    .o_axis_slave2_tvld         (dma_axis_slave2_tvld       ),
    .o_axis_slave2_tdata        (dma_axis_slave2_tdata      ),
    .o_axis_slave2_tlast        (dma_axis_slave2_tlast      ),
    .o_axis_slave2_tuser        (dma_axis_slave2_tuser      ),
    //**********************************************************************
    //from dma_controller
    .i_user_define_data_flag    (user_define_data_flag      ),

    .i_mwr32_req                (mwr32_req                  ),
    .o_mwr32_req_ack            (mwr32_req_ack              ),
    .i_mwr64_req                (mwr64_req                  ),
    .o_mwr64_req_ack            (mwr64_req_ack              ),

    .i_mrd32_req                (mrd32_req                  ),
    .o_mrd32_req_ack            (mrd32_req_ack              ),
    .i_mrd64_req                (mrd64_req                  ),
    .o_mrd64_req_ack            (mrd64_req_ack              ),

    .i_req_length               (req_length                 ),
    .i_req_addr                 (req_addr                   ),
    .i_req_data                 (req_data                   ),

    //**********************************************************************
    //bar0 rd interface
    .o_bar0_rd_clk_en           (bar0_rd_clk_en             ),
    .o_bar0_rd_addr             (bar0_rd_addr               ),
    .i_bar0_rd_data             (bar0_rd_data               ),
    //bar2 rd interface
    .o_bar2_rd_clk_en           (bar2_rd_clk_en             ),
    .o_bar2_rd_addr             (bar2_rd_addr               ),
    .i_bar2_rd_data             (bar2_rd_data               ),
    //**********************************************************************
    //from rx top
    //req rcv
    .i_mrd_tc                   (mrd_tc                     ),
    .i_mrd_attr                 (mrd_attr                   ),
    .i_mrd_length               (mrd_length                 ),
    .i_mrd_id                   (mrd_id                     ),
    .i_mrd_tag                  (mrd_tag                    ),
    .i_mrd_addr                 (mrd_addr                   ),

    .i_cpld_req_vld             (cpld_req_vld               ),
    .o_cpld_req_rdy             (cpld_req_rdy               ),
    .o_cpld_tx_rdy              (cpld_tx_rdy                ),
    //cpld rcv
    .i_cpld_rcv                 (cpld_rcv                   ),
    .i_cpld_tag                 (cpld_tag                   ),
    .o_tag_full                 (tag_full                   ),
    //rst tlp cnt
    .i_tx_restart               (tx_restart                 )
    //debug
    //.o_dbg_bus_mrd_tx           (dbg_bus_mrd_tx             ),
    //.o_dbg_bus_mwr_tx           (dbg_bus_mwr_tx             )
);

generate
    if (AXIS_SLAVE_NUM == 1)
    begin:axis_slave_num_1
        ipsl_pcie_dma_tlp_tx_mux #(
            .AXIS_SLAVE_NUM             (AXIS_SLAVE_NUM         )
        )
        u_pcie_dma_tlp_tx_mux
        (
            .clk                         (clk                   ),   //gen1:62.5MHz,gen2:125MHz
            .rst_n                       (rst_n                 ),
            //**********************************************************************
            //from dma
            //axis_slave0 interface
            .o_dma_axis_slave0_trdy      (dma_axis_slave0_trdy  ),
            .i_dma_axis_slave0_tvld      (dma_axis_slave0_tvld  ),
            .i_dma_axis_slave0_tdata     (dma_axis_slave0_tdata ),
            .i_dma_axis_slave0_tlast     (dma_axis_slave0_tlast ),
            .i_dma_axis_slave0_tuser     (dma_axis_slave0_tuser ),
            //axis_slave1 interface
            .o_dma_axis_slave1_trdy      (dma_axis_slave1_trdy  ),
            .i_dma_axis_slave1_tvld      (dma_axis_slave1_tvld  ),
            .i_dma_axis_slave1_tdata     (dma_axis_slave1_tdata ),
            .i_dma_axis_slave1_tlast     (dma_axis_slave1_tlast ),
            .i_dma_axis_slave1_tuser     (dma_axis_slave1_tuser ),
            //axis_slave2 interface
            .o_dma_axis_slave2_trdy      (dma_axis_slave2_trdy  ),
            .i_dma_axis_slave2_tvld      (dma_axis_slave2_tvld  ),
            .i_dma_axis_slave2_tdata     (dma_axis_slave2_tdata ),
            .i_dma_axis_slave2_tlast     (dma_axis_slave2_tlast ),
            .i_dma_axis_slave2_tuser     (dma_axis_slave2_tuser ),
            //credit interface
            //from pcie
            .i_cfg_ido_req_en            (i_cfg_ido_req_en      ),
            .i_cfg_ido_cpl_en            (i_cfg_ido_cpl_en      ),
            .i_xadm_ph_cdts              (i_xadm_ph_cdts        ),
            .i_xadm_pd_cdts              (i_xadm_pd_cdts        ),
            .i_xadm_nph_cdts             (i_xadm_nph_cdts       ),
            .i_xadm_npd_cdts             (i_xadm_npd_cdts       ),
            .i_xadm_cplh_cdts            (i_xadm_cplh_cdts      ),
            .i_xadm_cpld_cdts            (i_xadm_cpld_cdts      ),
            //pcie_axis_slave0
            .i_pcie_axis_slave_trdy      (i_axis_slave0_trdy    ),
            .o_pcie_axis_slave_tvld      (o_axis_slave0_tvld    ),
            .o_pcie_axis_slave_tdata     (o_axis_slave0_tdata   ),
            .o_pcie_axis_slave_tlast     (o_axis_slave0_tlast   ),
            .o_pcie_axis_slave_tuser     (o_axis_slave0_tuser   )
        );

        assign o_axis_slave1_tvld  = 1'b0;
        assign o_axis_slave1_tdata = 128'b0;
        assign o_axis_slave1_tlast = 1'b0;
        assign o_axis_slave1_tuser = 1'b0;

        assign o_axis_slave2_tvld  = 1'b0;
        assign o_axis_slave2_tdata = 128'b0;
        assign o_axis_slave2_tlast = 1'b0;
        assign o_axis_slave2_tuser = 1'b0;
    end
    else if (AXIS_SLAVE_NUM == 2)
    begin:axis_slave_num_2
        ipsl_pcie_dma_tlp_tx_mux #(
            .AXIS_SLAVE_NUM             (AXIS_SLAVE_NUM         )
        )
        u_pcie_dma_tlp_tx_mux
        (
            .clk                         (clk                   ),   //gen1:62.5MHz,gen2:125MHz
            .rst_n                       (rst_n                 ),
            //**********************************************************************
            //from dma
            //axis_slave0 interface
            .o_dma_axis_slave0_trdy      (                      ),
            .i_dma_axis_slave0_tvld      (1'b0                  ),
            .i_dma_axis_slave0_tdata     (128'b0                ),
            .i_dma_axis_slave0_tlast     (1'b0                  ),
            .i_dma_axis_slave0_tuser     (1'b0                  ),
            //axis_slave1 interface
            .o_dma_axis_slave1_trdy      (dma_axis_slave1_trdy  ),
            .i_dma_axis_slave1_tvld      (dma_axis_slave1_tvld  ),
            .i_dma_axis_slave1_tdata     (dma_axis_slave1_tdata ),
            .i_dma_axis_slave1_tlast     (dma_axis_slave1_tlast ),
            .i_dma_axis_slave1_tuser     (dma_axis_slave1_tuser ),
            //axis_slave2 interface
            .o_dma_axis_slave2_trdy      (dma_axis_slave2_trdy  ),
            .i_dma_axis_slave2_tvld      (dma_axis_slave2_tvld  ),
            .i_dma_axis_slave2_tdata     (dma_axis_slave2_tdata ),
            .i_dma_axis_slave2_tlast     (dma_axis_slave2_tlast ),
            .i_dma_axis_slave2_tuser     (dma_axis_slave2_tuser ),
            //credit interface
            //from pcie
            .i_cfg_ido_req_en            (i_cfg_ido_req_en      ),
            .i_cfg_ido_cpl_en            (i_cfg_ido_cpl_en      ),
            .i_xadm_ph_cdts              (i_xadm_ph_cdts        ),
            .i_xadm_pd_cdts              (i_xadm_pd_cdts        ),
            .i_xadm_nph_cdts             (i_xadm_nph_cdts       ),
            .i_xadm_npd_cdts             (i_xadm_npd_cdts       ),
            .i_xadm_cplh_cdts            (i_xadm_cplh_cdts      ),
            .i_xadm_cpld_cdts            (i_xadm_cpld_cdts      ),
            //pcie_axis_slave0
            .i_pcie_axis_slave_trdy      (i_axis_slave1_trdy    ),
            .o_pcie_axis_slave_tvld      (o_axis_slave1_tvld    ),
            .o_pcie_axis_slave_tdata     (o_axis_slave1_tdata   ),
            .o_pcie_axis_slave_tlast     (o_axis_slave1_tlast   ),
            .o_pcie_axis_slave_tuser     (o_axis_slave1_tuser   )
        );

        assign dma_axis_slave0_trdy = i_axis_slave0_trdy    ;
        assign o_axis_slave0_tvld   = dma_axis_slave0_tvld  ;
        assign o_axis_slave0_tdata  = dma_axis_slave0_tdata ;
        assign o_axis_slave0_tlast  = dma_axis_slave0_tlast ;
        assign o_axis_slave0_tuser  = dma_axis_slave0_tuser ;

        assign o_axis_slave2_tvld  = 1'b0;
        assign o_axis_slave2_tdata = 128'b0;
        assign o_axis_slave2_tlast = 1'b0;
        assign o_axis_slave2_tuser = 1'b0;
    end
    else if (AXIS_SLAVE_NUM == 3)
    begin:axis_slave_num_3
        assign dma_axis_slave0_trdy = i_axis_slave0_trdy    ;
        assign o_axis_slave0_tvld   = dma_axis_slave0_tvld  ;
        assign o_axis_slave0_tdata  = dma_axis_slave0_tdata ;
        assign o_axis_slave0_tlast  = dma_axis_slave0_tlast ;
        assign o_axis_slave0_tuser  = dma_axis_slave0_tuser ;

        assign dma_axis_slave1_trdy = i_axis_slave1_trdy    ;
        assign o_axis_slave1_tvld   = dma_axis_slave1_tvld  ;
        assign o_axis_slave1_tdata  = dma_axis_slave1_tdata ;
        assign o_axis_slave1_tlast  = dma_axis_slave1_tlast ;
        assign o_axis_slave1_tuser  = dma_axis_slave1_tuser ;

        assign dma_axis_slave2_trdy = i_axis_slave2_trdy    ;
        assign o_axis_slave2_tvld   = dma_axis_slave2_tvld  ;
        assign o_axis_slave2_tdata  = dma_axis_slave2_tdata ;
        assign o_axis_slave2_tlast  = dma_axis_slave2_tlast ;
        assign o_axis_slave2_tuser  = dma_axis_slave2_tuser ;
    end
endgenerate

endmodule