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
// Filename:ipsl_pcie_dma_tx_cpld_rd_ctrl.v
//////////////////////////////////////////////////////////////////////////////
module ipsl_pcie_dma_tx_cpld_rd_ctrl #(
    parameter                           ADDR_WIDTH  = 4'd9
)(
    input                               clk             ,   //gen1:62.5MHz,gen2:125MHz
    input                               rst_n           ,
    //**********************************************************************
    //ram interface
    input                               i_rd_en         ,
    input           [9:0]               i_rd_length     ,
    input           [63:0]              i_rd_addr       ,
    input                               i_cpld_tx_hold  ,
    input                               i_cpld_tlp_tx   ,

    output  wire                        o_gen_tlp_start ,
    output  wire    [127:0]             o_rd_data       ,
    output  wire                        o_last_data     ,
    //ram_rd
    output  wire                        o_bar_rd_clk_en ,
    output  wire    [ADDR_WIDTH-1:0]    o_bar_rd_addr   ,
    input           [127:0]             i_bar_rd_data
);

ipsl_pcie_dma_rd_ctrl #(
    .ADDR_WIDTH             (ADDR_WIDTH             )
)
u_ipsl_pcie_dma_cpld_rd_ctrl
(
    .clk                    (clk                    ),  //gen1:62.5MHz,gen2:125MHz
    .rst_n                  (rst_n                  ),
    //**********************************************************************
    //ram interface
    .i_rd_en                (i_rd_en                ),
    .i_rd_length            (i_rd_length            ),
    .i_rd_addr              (i_rd_addr              ),
    .i_tx_hold              (i_cpld_tx_hold         ),
    .i_tlp_tx               (i_cpld_tlp_tx          ),
    .o_rd_ram_hold          (                       ),//no use
    .o_gen_tlp_start        (o_gen_tlp_start        ),
    .o_rd_data              (o_rd_data              ),
    .o_last_data            (o_last_data            ),
    //ram_rd
    .o_bar_rd_clk_en        (o_bar_rd_clk_en        ),
    .o_bar_rd_addr          (o_bar_rd_addr          ),
    .i_bar_rd_data          (i_bar_rd_data          )
);

endmodule