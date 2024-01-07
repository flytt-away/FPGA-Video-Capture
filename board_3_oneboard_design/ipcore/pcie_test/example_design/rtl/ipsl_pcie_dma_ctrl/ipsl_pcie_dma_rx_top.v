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
// Filename:ipsl_pcie_dma_rx_top.v
//////////////////////////////////////////////////////////////////////////////
module ipsl_pcie_dma_rx_top #(
    parameter                           DEVICE_TYPE = 3'd0      ,   //3'd0:EP,3'd1:Legacy EP,3'd4:RC
    parameter                           ADDR_WIDTH  = 4'd9
)(
    input                               clk                     ,   //gen1:62.5MHz,gen2:125MHz
    input                               rst_n                   ,
    input           [2:0]               i_cfg_max_rd_req_size   ,
    //**********************************************************************
    //AXIS master interface
    input                               i_axis_master_tvld      ,
    output  wire                        o_axis_master_trdy      ,
    input           [127:0]             i_axis_master_tdata     ,
    input           [3:0]               i_axis_master_tkeep     ,
    input                               i_axis_master_tlast     ,
    input           [7:0]               i_axis_master_tuser     ,
    output  wire    [2:0]               o_trgt1_radm_pkt_halt   ,
//    input           [5:0]               i_radm_grant_tlp_type   ,
    //**********************************************************************
    //bar0 rd interface
    input                               i_bar0_rd_clk_en        ,
    input           [ADDR_WIDTH-1:0]    i_bar0_rd_addr          ,
    output  wire    [127:0]             o_bar0_rd_data          ,

    //bar2 rd interface
    input                               i_bar2_rd_clk_en        ,
    input           [ADDR_WIDTH-1:0]    i_bar2_rd_addr          ,
    output  wire    [127:0]             o_bar2_rd_data          ,

    //bar1 wr interface
    output  reg                         o_bar1_wr_en            ,
    output  reg     [ADDR_WIDTH-1:0]    o_bar1_wr_addr          ,
    output  reg     [127:0]             o_bar1_wr_data          ,
    output  reg     [15:0]              o_bar1_wr_byte_en       ,
    //**********************************************************************
    //to tx top
    //req rcv
    output  wire    [2:0]               o_mrd_tc                ,
    output  wire    [2:0]               o_mrd_attr              ,
    output  wire    [9:0]               o_mrd_length            ,
    output  wire    [15:0]              o_mrd_id                ,
    output  wire    [7:0]               o_mrd_tag               ,
    output  wire    [63:0]              o_mrd_addr              ,

    output  wire                        o_cpld_req_vld          ,
    input                               i_cpld_req_rdy          ,
    input                               i_cpld_tx_rdy           ,
    //cpld rcv
    output wire                         o_cpld_rcv              ,
    output wire     [7:0]               o_cpld_tag              ,
    input                               i_tag_full              ,
    //rst tlp cnt
    output wire     [63:0]              o_dma_check_result      ,
    input                               i_tx_restart

    //output  wire    [42:0]              o_dbg_bus_rx_ctrl       ,
    //output  wire    [69:0]              o_dbg_tlp_rcv_cnt
);

wire                        mwr_wr_start;
wire    [9:0]               mwr_length;
wire    [7:0]               mwr_dwbe;
wire    [127:0]             mwr_data;
wire    [3:0]               mwr_dw_vld;
wire    [63:0]              mwr_addr;

wire                        cpld_wr_start;
wire    [9:0]               cpld_length;
wire    [6:0]               cpld_low_addr;
wire    [11:0]              cpld_byte_cnt;
wire    [127:0]             cpld_data;
wire    [3:0]               cpld_dw_vld;
wire                        multicpld_flag;

wire    [1:0]               bar_hit;

//mwr wr
wire                        mwr_wr_en;
wire    [ADDR_WIDTH-1:0]    mwr_wr_addr;
wire    [127:0]             mwr_wr_data;
wire    [15:0]              mwr_wr_be;
wire    [1:0]               mwr_wr_bar_hit;
//cpld wr
wire                        cpld_wr_en;
wire    [ADDR_WIDTH-1:0]    cpld_wr_addr;
wire    [127:0]             cpld_wr_data;
wire    [15:0]              cpld_wr_be;
wire    [1:0]               cpld_wr_bar_hit;
//bar0 wr interface
reg                         bar0_wr_en;
reg     [ADDR_WIDTH-1:0]    bar0_wr_addr;
reg     [127:0]             bar0_wr_data;
reg     [15:0]              bar0_wr_byte_en;
//bar2 wr interface
wire                        bar2_wr_en;
wire    [ADDR_WIDTH-1:0]    bar2_wr_addr;
wire    [127:0]             bar2_wr_data;
wire    [15:0]              bar2_wr_byte_en;

ipsl_pcie_dma_tlp_rcv #(
    .DEVICE_TYPE            (DEVICE_TYPE            )
)
u_ipsl_pcie_dma_tlp_rcv
(
    .clk                    (clk                    ),  //gen1:62.5MHz,gen2:125MHz
    .rst_n                  (rst_n                  ),

    //**********************************************************************
    //AXIS master interface
    .i_axis_master_tvld     (i_axis_master_tvld     ),
    .o_axis_master_trdy     (o_axis_master_trdy     ),
    .i_axis_master_tdata    (i_axis_master_tdata    ),
    .i_axis_master_tkeep    (i_axis_master_tkeep    ),
    .i_axis_master_tlast    (i_axis_master_tlast    ),
    .i_axis_master_tuser    (i_axis_master_tuser    ),
    .o_trgt1_radm_pkt_halt  (o_trgt1_radm_pkt_halt  ),
//    .i_radm_grant_tlp_type  (i_radm_grant_tlp_type  ),

    //**********************************************************************
    //to mwr write control
    .o_mwr_wr_start         (mwr_wr_start           ),
    .o_mwr_length           (mwr_length             ),
    .o_mwr_dwbe             (mwr_dwbe               ),
    .o_mwr_data             (mwr_data               ),
    .o_mwr_dw_vld           (mwr_dw_vld             ),
    .o_mwr_addr             (mwr_addr               ),
    //to cpld write control
    .o_cpld_wr_start        (cpld_wr_start          ),
    .o_cpld_length          (cpld_length            ),
    .o_cpld_low_addr        (cpld_low_addr          ),
    .o_cpld_byte_cnt        (cpld_byte_cnt          ),
    .o_cpld_data            (cpld_data              ),
    .o_cpld_dw_vld          (cpld_dw_vld            ),
    .o_multicpld_flag       (multicpld_flag         ),
    //write bar hit
    .o_bar_hit              (bar_hit                ),
    //**********************************************************************
    //to tx top
    //req rcv
    .o_mrd_tc               (o_mrd_tc               ),
    .o_mrd_attr             (o_mrd_attr             ),
    .o_mrd_length           (o_mrd_length           ),
    .o_mrd_id               (o_mrd_id               ),
    .o_mrd_tag              (o_mrd_tag              ),
    .o_mrd_addr             (o_mrd_addr             ),

    .o_cpld_req_vld         (o_cpld_req_vld         ),
    .i_cpld_req_rdy         (i_cpld_req_rdy         ),
    .i_cpld_tx_rdy          (i_cpld_tx_rdy          ),
    //cpld rcv
    .o_cpld_rcv             (o_cpld_rcv             ),
    .o_cpld_tag             (o_cpld_tag             ),
    .i_tag_full             (i_tag_full             ),
    //rst tlp cnt
    .o_dma_check_result     (o_dma_check_result     ),
    .i_tx_restart           (i_tx_restart           )
    //.o_dbg_bus              (o_dbg_bus_rx_ctrl      ),
    //.o_dbg_tlp_rcv_cnt      (o_dbg_tlp_rcv_cnt      )
);


ipsl_pcie_dma_rx_cpld_wr_ctrl #(
    .ADDR_WIDTH             (ADDR_WIDTH             )
)
u_cpld_wr_ctrl
(
    .clk                    (clk                    ),  //gen1:62.5MHz,gen2:125MHz
    .rst_n                  (rst_n                  ),
    .i_cfg_max_rd_req_size  (i_cfg_max_rd_req_size  ),  //input [2:0]
    //****************************************
    .i_cpld_wr_start        (cpld_wr_start          ),
    .i_cpld_length          (cpld_length            ),
    .i_cpld_low_addr        (cpld_low_addr          ),
    .i_cpld_byte_cnt        (cpld_byte_cnt          ),
    .i_cpld_data            (cpld_data              ),
    .i_cpld_dw_vld          (cpld_dw_vld            ),
    .i_cpld_tag             (o_cpld_tag             ),
    .i_bar_hit              (bar_hit                ),
    .i_multicpld_flag       (multicpld_flag         ),
    //****************************************
    .o_cpld_wr_en           (cpld_wr_en             ),
    .o_cpld_wr_addr         (cpld_wr_addr           ),
    .o_cpld_wr_data         (cpld_wr_data           ),
    .o_cpld_wr_be           (cpld_wr_be             ),
    .o_cpld_wr_bar_hit      (cpld_wr_bar_hit        )
);

ipsl_pcie_dma_rx_mwr_wr_ctrl #(
    .ADDR_WIDTH             (ADDR_WIDTH             )
)
u_mwr_wr_ctrl
(
    .clk                    (clk                    ),  //gen1:62.5MHz,gen2:125MHz
    .rst_n                  (rst_n                  ),
    //****************************************
    .i_mwr_wr_start         (mwr_wr_start           ),
    .i_mwr_length           (mwr_length             ),
    .i_mwr_dwbe             (mwr_dwbe               ),
    .i_mwr_data             (mwr_data               ),
    .i_mwr_dw_vld           (mwr_dw_vld             ),
    .i_mwr_addr             (mwr_addr               ),
    .i_bar_hit              (bar_hit                ),
    //****************************************
    .o_mwr_wr_en            (mwr_wr_en              ),
    .o_mwr_wr_addr          (mwr_wr_addr            ),
    .o_mwr_wr_data          (mwr_wr_data            ),
    .o_mwr_wr_be            (mwr_wr_be              ),
    .o_mwr_wr_bar_hit       (mwr_wr_bar_hit         )
);

//bar0 interface
always@(*)
begin
    if(mwr_wr_bar_hit == 2'b0)
    begin
        bar0_wr_en       = mwr_wr_en;
        bar0_wr_addr     = mwr_wr_addr;
        bar0_wr_data     = mwr_wr_data;
        bar0_wr_byte_en  = mwr_wr_be;
    end
    else
    begin
        bar0_wr_en       = 1'b0;
        bar0_wr_addr     = {ADDR_WIDTH{1'b0}};
        bar0_wr_data     = 128'b0;
        bar0_wr_byte_en  = 16'b0;
    end
end

//bar1 interface
always@(*)
begin
    if(bar_hit == 2'b1 && (DEVICE_TYPE == 3'b000 || DEVICE_TYPE == 3'b001))
    begin
        o_bar1_wr_en       = 1'b1;
        o_bar1_wr_addr     = mwr_addr[ADDR_WIDTH-1:0];
        o_bar1_wr_data     = mwr_data;
        o_bar1_wr_byte_en  = {{4{mwr_dwbe[3]}},{4{mwr_dwbe[2]}},{4{mwr_dwbe[1]}},{4{mwr_dwbe[0]}}};
    end
    else
    begin
        o_bar1_wr_en       = 1'b0;
        o_bar1_wr_addr     = {ADDR_WIDTH{1'b0}};
        o_bar1_wr_data     = 128'b0;
        o_bar1_wr_byte_en  = 16'b0;
    end
end

assign bar2_wr_en       = cpld_wr_en;
assign bar2_wr_addr     = cpld_wr_addr;
assign bar2_wr_data     = cpld_wr_data;
assign bar2_wr_byte_en  = cpld_wr_be;

ipsl_pcie_dma_ram ipsl_pcie_dma_bar0 (
    .wr_data            (bar0_wr_data               ),  // input [127:0]
    .wr_addr            (bar0_wr_addr               ),  // input [8:0]
    .wr_en              (bar0_wr_en                 ),  // input
    .wr_byte_en         (bar0_wr_byte_en            ),  // input [15:0]
    .wr_clk             (clk                        ),  // input
    .wr_rst             (~rst_n                     ),  // input
    .rd_addr            (i_bar0_rd_addr             ),  // input [8:0]
    .rd_data            (o_bar0_rd_data             ),  // output [127:0]
    .rd_clk             (clk                        ),  // input
    .rd_clk_en          (i_bar0_rd_clk_en           ),  // input
    .rd_rst             (~rst_n                     )   // input
);

ipsl_pcie_dma_ram ipsl_pcie_dma_bar2 (
    .wr_data            (bar2_wr_data               ),  // input [127:0]
    .wr_addr            (bar2_wr_addr               ),  // input [8:0]
    .wr_en              (bar2_wr_en                 ),  // input
    .wr_byte_en         (bar2_wr_byte_en            ),  // input [15:0]
    .wr_clk             (clk                        ),  // input
    .wr_rst             (~rst_n                     ),  // input
    .rd_addr            (i_bar2_rd_addr             ),  // input [8:0]
    .rd_data            (o_bar2_rd_data             ),  // output [127:0]
    .rd_clk             (clk                        ),  // input
    .rd_clk_en          (i_bar2_rd_clk_en           ),  // input
    .rd_rst             (~rst_n                     )   // input
);

endmodule