//******************************************************************
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
`timescale 1ns/1ns
module pgr_apb_ctr_32bit #(
    parameter CLK_FREQ = 16'd50,
    parameter AW = 16'd16,
    parameter DW = 16'd32,
    parameter SW = 16'd4
)(
    input           clk,
    input           rst_n,

    output  [7:0]   tx_fifo_wr_data,
    input           tx_fifo_wr_data_valid,
    output          tx_fifo_wr_data_req,

    input   [7:0]   rx_fifo_rd_data,
    input           rx_fifo_rd_data_valid,
    output          rx_fifo_rd_data_req,

    output            p_sel,
    output  [SW-1:0]  p_strb,
    output  [AW-1:0]  p_addr,
    output  [DW-1:0]  p_wdata,
    output            p_ce,
    output            p_we,
    input             p_rdy,
    input   [DW-1:0]  p_rdata,

    output          uart_txvld,
    input           uart_txreq,
    input   [7:0]   uart_txdata,

    input           uart_rxreq,
    output  [7:0]   uart_rxdata,
    output          uart_rxvld,

    input           apb_en,
    input           strb_en
);

wire    [AW-1:0]   addr;
wire    [SW-1:0]   strb;
wire    [DW-1:0]   wdata;
wire               we;

wire            cmd_en;
wire            cmd_done;

pgr_apb_mif_32bit #(
    .CLK_FREQ   ( CLK_FREQ    ),
    .AW           ( AW        ),
    .DW           ( DW        ),
    .SW           ( SW        )
) u_apb_mif(
    .clk                (clk                    ),
    .rst_n              (rst_n                  ),

    .strb               (strb                   ),
    .addr               (addr                   ),
    .wdata              (wdata                  ),
    .we                 (we                     ),
    .cmd_en             (cmd_en                 ),
    .cmd_done           (cmd_done               ),

    .fifo_data          (tx_fifo_wr_data        ),
    .fifo_data_valid    (tx_fifo_wr_data_valid  ),
    .fifo_data_req      (tx_fifo_wr_data_req    ),

    .apb_en             (apb_en                 ),
    .p_sel              (p_sel                  ),
    .p_strb             (p_strb                 ),
    .p_addr             (p_addr                 ),
    .p_wdata            (p_wdata                ),
    .p_ce               (p_ce                   ),
    .p_we               (p_we                   ),
    .p_rdy              (p_rdy                  ),
    .p_rdata            (p_rdata                ),

    .uart_txvld         (uart_txvld             ),
    .uart_txreq         (uart_txreq             ),
    .uart_txdata        (uart_txdata            )
);

pgr_cmd_parser_32bit #(
    .AW           ( AW       ),
    .DW           ( DW       ),
    .SW           ( SW       ),
    .CLK_FREQ     (CLK_FREQ  )
)u_cmd_parser(
    .clk                (clk                    ),
    .rst_n              (rst_n                  ),

    .fifo_data          (rx_fifo_rd_data        ),
    .fifo_data_valid    (rx_fifo_rd_data_valid  ),
    .fifo_data_req      (rx_fifo_rd_data_req    ),

    .strb               (strb                   ),
    .addr               (addr                   ),
    .wdata              (wdata                  ),
    .we                 (we                     ),
    .cmd_en             (cmd_en                 ),
    .cmd_done           (cmd_done               ),

    .uart_rxvld         (uart_rxvld             ),
    .uart_rxreq         (uart_rxreq             ),
    .uart_rxdata        (uart_rxdata            ),

    .apb_en             (apb_en                 ),
    .strb_en            (strb_en                )
);

endmodule //pgr_apb_ctr
