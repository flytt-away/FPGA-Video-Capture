
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

`timescale 1ns/1ps

module ipsxb_uart_ctrl_32bit #(
    parameter CLK_DIV_P       = 'd72         ,
    parameter DFT_CTRL_BUS_0  = 32'h0000_0000,
    parameter DFT_CTRL_BUS_1  = 32'h0000_0000,
    parameter DFT_CTRL_BUS_2  = 32'h0000_0000,
    parameter DFT_CTRL_BUS_3  = 32'h0000_0000,
    parameter DFT_CTRL_BUS_4  = 32'h0000_0000,
    parameter DFT_CTRL_BUS_5  = 32'h0000_0000,
    parameter DFT_CTRL_BUS_6  = 32'h0000_0000,
    parameter DFT_CTRL_BUS_7  = 32'h0000_0000,
    parameter DFT_CTRL_BUS_8  = 32'h0000_0000,
    parameter DFT_CTRL_BUS_9  = 32'h0000_0000,
    parameter DFT_CTRL_BUS_10 = 32'h0000_0000,
    parameter DFT_CTRL_BUS_11 = 32'h0000_0000,
    parameter DFT_CTRL_BUS_12 = 32'h0000_0000,
    parameter DFT_CTRL_BUS_13 = 32'h0000_0000,
    parameter DFT_CTRL_BUS_14 = 32'h0000_0000,
    parameter DFT_CTRL_BUS_15 = 32'h0000_0000
)(
    input           clk                     ,
    input           rst_n                   ,

    output  [31:0]  tx_fifo_wr_data         ,
    input           tx_fifo_wr_data_valid   ,
    output          tx_fifo_wr_data_req     ,

    input   [7:0]   rx_fifo_rd_data         ,
    input           rx_fifo_rd_data_valid   ,
    output          rx_fifo_rd_data_req     ,

    output          read_req                ,
    input           read_ack                ,
    output  [8:0]   uart_rd_addr            ,

    output  [31:0]  ctrl_bus_0              ,
    output  [31:0]  ctrl_bus_1              ,
    output  [31:0]  ctrl_bus_2              ,
    output  [31:0]  ctrl_bus_3              ,
    output  [31:0]  ctrl_bus_4              ,
    output  [31:0]  ctrl_bus_5              ,
    output  [31:0]  ctrl_bus_6              ,
    output  [31:0]  ctrl_bus_7              ,
    output  [31:0]  ctrl_bus_8              ,
    output  [31:0]  ctrl_bus_9              ,
    output  [31:0]  ctrl_bus_10             ,
    output  [31:0]  ctrl_bus_11             ,
    output  [31:0]  ctrl_bus_12             ,
    output  [31:0]  ctrl_bus_13             ,
    output  [31:0]  ctrl_bus_14             ,
    output  [31:0]  ctrl_bus_15             ,

    input   [31:0]  status_bus
);

wire    [23:0]  addr                       ;
wire    [31:0]  data                       ;
wire            we                         ;
wire            cmd_en                     ;
wire            ver_cmd_en                 ;

wire            cmd_done                   ;
wire            ver_cmd_done               ;
wire    [31:0]  ver_tx_fifo_wr_data        ;
wire            ver_tx_fifo_wr_data_req    ;

assign cmd_done = ver_cmd_done;
assign tx_fifo_wr_data = ver_tx_fifo_wr_data;
assign tx_fifo_wr_data_req = ver_tx_fifo_wr_data_req;

assign ver_cmd_en = cmd_en;
assign uart_rd_addr = addr[8:0];

ipsxb_cmd_parser_32bit u_cmd_parser(
    .clk                (clk                    ),
    .rst_n              (rst_n                  ),

    .fifo_data          (rx_fifo_rd_data        ),
    .fifo_data_valid    (rx_fifo_rd_data_valid  ),
    .fifo_data_req      (rx_fifo_rd_data_req    ),

    .addr               (addr                   ),
    .data               (data                   ),
    .we                 (we                     ),
    .cmd_en             (cmd_en                 ),
    .cmd_done           (cmd_done               )
);

ipsxb_ver_ctrl_32bit #(
    .DFT_CTRL_BUS_0     (DFT_CTRL_BUS_0         ),
    .DFT_CTRL_BUS_1     (DFT_CTRL_BUS_1         ),
    .DFT_CTRL_BUS_2     (DFT_CTRL_BUS_2         ),
    .DFT_CTRL_BUS_3     (DFT_CTRL_BUS_3         ),
    .DFT_CTRL_BUS_4     (DFT_CTRL_BUS_4         ),
    .DFT_CTRL_BUS_5     (DFT_CTRL_BUS_5         ),
    .DFT_CTRL_BUS_6     (DFT_CTRL_BUS_6         ),
    .DFT_CTRL_BUS_7     (DFT_CTRL_BUS_7         ),
    .DFT_CTRL_BUS_8     (DFT_CTRL_BUS_8         ),
    .DFT_CTRL_BUS_9     (DFT_CTRL_BUS_9         ),
    .DFT_CTRL_BUS_10    (DFT_CTRL_BUS_10        ),
    .DFT_CTRL_BUS_11    (DFT_CTRL_BUS_11        ),
    .DFT_CTRL_BUS_12    (DFT_CTRL_BUS_12        ),
    .DFT_CTRL_BUS_13    (DFT_CTRL_BUS_13        ),
    .DFT_CTRL_BUS_14    (DFT_CTRL_BUS_14        ),
    .DFT_CTRL_BUS_15    (DFT_CTRL_BUS_15        )
)u_ver_ctrl(
    .clk                (clk                    ),
    .rst_n              (rst_n                  ),

    .addr               (addr[8:0]              ),
    .data               (data                   ),
    .we                 (we                     ),
    .cmd_en             (ver_cmd_en             ),
    .cmd_done           (ver_cmd_done           ),

    .fifo_data          (ver_tx_fifo_wr_data    ),
    .fifo_data_valid    (tx_fifo_wr_data_valid  ),
    .fifo_data_req      (ver_tx_fifo_wr_data_req),

    .read_req           (read_req               ),
    .read_ack           (read_ack               ),

    .ctrl_bus_0         (ctrl_bus_0             ),
    .ctrl_bus_1         (ctrl_bus_1             ),
    .ctrl_bus_2         (ctrl_bus_2             ),
    .ctrl_bus_3         (ctrl_bus_3             ),
    .ctrl_bus_4         (ctrl_bus_4             ),
    .ctrl_bus_5         (ctrl_bus_5             ),
    .ctrl_bus_6         (ctrl_bus_6             ),
    .ctrl_bus_7         (ctrl_bus_7             ),
    .ctrl_bus_8         (ctrl_bus_8             ),
    .ctrl_bus_9         (ctrl_bus_9             ),
    .ctrl_bus_10        (ctrl_bus_10            ),
    .ctrl_bus_11        (ctrl_bus_11            ),
    .ctrl_bus_12        (ctrl_bus_12            ),
    .ctrl_bus_13        (ctrl_bus_13            ),
    .ctrl_bus_14        (ctrl_bus_14            ),
    .ctrl_bus_15        (ctrl_bus_15            ),

    .status_bus         (status_bus             )
);

endmodule
