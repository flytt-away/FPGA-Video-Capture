//******************************************************************
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
`timescale 1ns/1ns
module pgr_uart2apb_top_32bit
#(
    parameter CLK_FREQ      = 8'd50        , //frequency, for 50MHz
    parameter FIFO_D        = 8'd16        , //fifo depth
    parameter WORD_LEN      = 2'b11     , //the bit width of valid data(00:5 01:6 10:7 11:8)
    parameter PARITY_EN     = 1'b0      , //0:no parity bit  1:1 parity bit
    parameter PARITY_TYPE   = 1'b0      , //the type of parity(0:even 1:odd)
    parameter STOP_LEN      = 1'b0      , //1:2 stop bit  0:1 stop bit
    parameter MODE          = 1'b0      , //0:LSBF 1:MSBF
    parameter AW            = 8'd16        , //the bit width of addr
    parameter DW            = 8'd32        , //the bit width of data
    parameter SW            = 8'd4      //the bit width of strb
)
(
    input           i_clk,
    input           i_rst_n,

    //apb enable
    output             o_p_sel,
    output  [SW-1:0]   o_p_strb,
    output  [AW-1:0]   o_p_addr,
    output  [DW-1:0]   o_p_wdata,
    output             o_p_enable,
    output             o_p_we,
    input              i_p_ready,
    input   [DW-1:0]   i_p_rdata,
    input              i_apb_en,
    input              i_strb_en,

    //uart
    output             o_uart_txd,
    input              i_uart_rxd,

    //just for debug
    output             rx_overrun,
    output             rx_chk_err,

    //apb bypass
    output             o_uart_txvld,
    input              i_uart_txreq,
    input   [7:0]      i_uart_txdata,

    input              i_uart_rxreq,
    output  [7:0]      o_uart_rxdata,
    output             o_uart_rxvld
);

wire    [7:0]   tx_fifo_wr_data;
wire            tx_fifo_wr_data_valid;
wire            tx_fifo_wr_data_req;

wire    [7:0]   rx_fifo_rd_data;
wire            rx_fifo_rd_data_valid;
wire            rx_fifo_rd_data_req;

wire            sync_rst_n;

pgr_uart_top_32bit
#(
    .CLK_FREQ       (CLK_FREQ       ),
    .FIFO_D         (FIFO_D         ),
    .WORD_LEN       (WORD_LEN       ),
    .PARITY_EN      (PARITY_EN      ),
    .PARITY_TYPE    (PARITY_TYPE    ),
    .STOP_LEN       (STOP_LEN       ),
    .MODE           (MODE           )
)
u_uart_top(
    .clk                        (i_clk                  ),
    .rst_n                      (sync_rst_n             ),

    .tx_fifo_wr_data            (tx_fifo_wr_data        ),
    .tx_fifo_wr_data_valid      (tx_fifo_wr_data_valid  ),
    .tx_fifo_wr_data_req        (tx_fifo_wr_data_req    ),

    .rx_fifo_rd_data            (rx_fifo_rd_data        ),
    .rx_fifo_rd_data_valid      (rx_fifo_rd_data_valid  ),
    .rx_fifo_rd_data_req        (rx_fifo_rd_data_req    ),

    .txd                        (o_uart_txd             ),
    .rxd                        (i_uart_rxd             ),

    .rx_overrun                 (rx_overrun             ),
    .rx_chk_err                 (rx_chk_err             )
);

pgr_apb_ctr_32bit #(
    .CLK_FREQ    ( CLK_FREQ    ),
    .AW            ( AW          ),
    .DW            ( DW          ),
    .SW            ( SW          )
) u_apb_ctr(
    .clk                        (i_clk                  ),
    .rst_n                      (sync_rst_n             ),

    .tx_fifo_wr_data            (tx_fifo_wr_data        ),
    .tx_fifo_wr_data_valid      (tx_fifo_wr_data_valid  ),
    .tx_fifo_wr_data_req        (tx_fifo_wr_data_req    ),

    .rx_fifo_rd_data            (rx_fifo_rd_data        ),
    .rx_fifo_rd_data_valid      (rx_fifo_rd_data_valid  ),
    .rx_fifo_rd_data_req        (rx_fifo_rd_data_req    ),

    .p_sel                      (o_p_sel                ),
    .p_strb                     (o_p_strb               ),
    .p_addr                     (o_p_addr               ),
    .p_wdata                    (o_p_wdata              ),
    .p_ce                       (o_p_enable             ),
    .p_we                       (o_p_we                 ),
    .p_rdy                      (i_p_ready              ),
    .p_rdata                    (i_p_rdata              ),
    .apb_en                     (i_apb_en               ),
    .strb_en                    (i_strb_en              ),

    .uart_rxvld                 (o_uart_rxvld           ),
    .uart_rxdata                (o_uart_rxdata          ),
    .uart_rxreq                 (i_uart_rxreq           ),

    .uart_txvld                 (o_uart_txvld           ),
    .uart_txdata                (i_uart_txdata          ),
    .uart_txreq                 (i_uart_txreq           )
);

rstn_sync_32bit u_rstn_sync(
    .clk                        (i_clk                  ),
    .rst_n                      (i_rst_n                ),
    .sync_rst_n                 (sync_rst_n             )
);

endmodule //pgr_uart2apb_top
