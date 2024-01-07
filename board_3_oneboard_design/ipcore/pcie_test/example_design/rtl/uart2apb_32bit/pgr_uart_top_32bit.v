//******************************************************************
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
`timescale 1ns/1ns
module pgr_uart_top_32bit
#(
    parameter CLK_FREQ      = 8'd50        ,
    parameter FIFO_D        = 16'd1024      ,
    parameter WORD_LEN      = 2'b11     ,
    parameter PARITY_EN     = 1'b0      ,
    parameter PARITY_TYPE   = 1'b0      ,
    parameter STOP_LEN      = 1'b0      ,
    parameter MODE          = 1'b0
)
(
    input               clk,
    input               rst_n,

    input       [7:0]   tx_fifo_wr_data,
    output              tx_fifo_wr_data_valid,
    input               tx_fifo_wr_data_req,

    output      [7:0]   rx_fifo_rd_data,
    output              rx_fifo_rd_data_valid,
    input               rx_fifo_rd_data_req,

    output              txd,
    input               rxd,

    output              rx_chk_err,
    output              rx_overrun
);

wire            clk_en;

wire            tx_fifo_rd_data_req;
wire    [7:0]   tx_fifo_rd_data;
wire            tx_fifo_rd_data_valid;

wire            rx_fifo_wr_data_req;
wire    [7:0]   rx_fifo_wr_data;
wire            rx_fifo_wr_data_valid;


pgr_clk_gen_32bit
#(
    .CLK_FREQ                   (CLK_FREQ                       )
)
u_pgr_clk_gen(
    .clk                        (clk                            ),
    .rst_n                      (rst_n                          ),
    .clk_en                     (clk_en                         )
);

pgr_fifo_top_32bit
#(
    .D          (FIFO_D      )
)
u_tx_fifo(
    .clk                        (clk                            ),
    .rst_n                      (rst_n                          ),

    .wr_data                    (tx_fifo_wr_data                ),
    .wr_req                     (tx_fifo_wr_data_req            ),
    .wr_ready                   (tx_fifo_wr_data_valid          ),

    .rd_req                     (tx_fifo_rd_data_req            ),
    .rd_data                    (tx_fifo_rd_data                ),
    .rd_valid                   (tx_fifo_rd_data_valid          )
);

pgr_fifo_top_32bit
#(
    .D          (FIFO_D      )
)
u_rx_fifo(
    .clk                        (clk                            ),
    .rst_n                      (rst_n                          ),

    .wr_data                    (rx_fifo_wr_data                ),
    .wr_req                     (rx_fifo_wr_data_req            ),
    .wr_ready                   (rx_fifo_wr_data_valid          ),

    .rd_req                     (rx_fifo_rd_data_req            ),
    .rd_data                    (rx_fifo_rd_data                ),
    .rd_valid                   (rx_fifo_rd_data_valid          )
);

pgr_uart_tx_32bit u_pgr_uart_tx(
    .clk                        (clk                            ),
    .clk_en                     (clk_en                         ),
    .rst_n                      (rst_n                          ),

    .tx_fifo_rd_data            (tx_fifo_rd_data                ),
    .tx_fifo_rd_data_valid      (tx_fifo_rd_data_valid          ),
    .tx_fifo_rd_data_req        (tx_fifo_rd_data_req            ),

    .uart_word_len              (WORD_LEN                       ),
    .uart_parity_en             (PARITY_EN                      ),
    .uart_parity_type           (PARITY_TYPE                    ),
    .uart_stop_len              (STOP_LEN                       ),
    .uart_mode                  (MODE                           ),

    .txd                        (txd                            )
);

pgr_uart_rx_32bit u_pgr_uart_rx(
    .clk                        (clk                            ),
    .rst_n                      (rst_n                          ),
    .clk_en                     (clk_en                         ),

    .rx_fifo_wr_data            (rx_fifo_wr_data                ),
    .rx_fifo_wr_data_valid      (rx_fifo_wr_data_valid          ),
    .rx_fifo_wr_data_req        (rx_fifo_wr_data_req            ),

    .uart_word_len              (WORD_LEN                       ),
    .uart_parity_en             (PARITY_EN                      ),
    .uart_parity_type           (PARITY_TYPE                    ),
    .uart_mode                  (MODE                           ),

    .rx_overrun                 (rx_overrun                     ),
    .rx_chk_err                 (rx_chk_err                     ),

    .rxd_in                     (rxd                            )
);

endmodule //pgr_uart_top
