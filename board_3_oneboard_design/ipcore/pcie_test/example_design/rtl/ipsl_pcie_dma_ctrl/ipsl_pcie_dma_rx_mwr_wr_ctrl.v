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
// Filename:ipsl_pcie_dma_rx_mwr_wr_ctrl.v
//////////////////////////////////////////////////////////////////////////////
module ipsl_pcie_dma_rx_mwr_wr_ctrl #(
    parameter                           ADDR_WIDTH = 4'd9
)(
    input                               clk             ,   //gen1:62.5MHz,gen2:125MHz
    input                               rst_n           ,

    //**********************************************************************
    input                               i_mwr_wr_start  ,
    input           [9:0]               i_mwr_length    ,
    input           [7:0]               i_mwr_dwbe      ,
    input           [127:0]             i_mwr_data      ,
    input           [3:0]               i_mwr_dw_vld    ,
    input           [63:0]              i_mwr_addr      ,
    input           [1:0]               i_bar_hit       ,

    //**********************************************************************
    //ram write control
    output  wire                        o_mwr_wr_en     ,
    output  wire    [ADDR_WIDTH-1:0]    o_mwr_wr_addr   ,
    output  wire    [127:0]             o_mwr_wr_data   ,
    output  wire    [15:0]              o_mwr_wr_be     ,
    output  wire    [1:0]               o_mwr_wr_bar_hit
);

ipsl_pcie_dma_wr_ctrl #(
    .ADDR_WIDTH         (ADDR_WIDTH         )
)
ipsl_pcie_dma_mwr_wr_ctrl
(
    .clk                (clk                ),  //gen1:62.5MHz,gen2:125MHz
    .rst_n              (rst_n              ),

    //**********************************************************************
    .i_wr_start         (i_mwr_wr_start     ),
    .i_length           (i_mwr_length       ),
    .i_dwbe             (i_mwr_dwbe         ),
    .i_data             (i_mwr_data         ),
    .i_dw_vld           (i_mwr_dw_vld       ),
    .i_addr             (i_mwr_addr         ),
    .i_bar_hit          (i_bar_hit          ),

    //**********************************************************************
    //ram write control
    .o_wr_en            (o_mwr_wr_en       ),
    .o_wr_addr          (o_mwr_wr_addr     ),
    .o_wr_data          (o_mwr_wr_data     ),
    .o_wr_be            (o_mwr_wr_be       ),
    .o_wr_bar_hit       (o_mwr_wr_bar_hit  )
);

endmodule