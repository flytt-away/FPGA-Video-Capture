
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

module ipsxb_seu_rs232_intf
#(
    parameter CLK_DIV_P     = 16'd145    ,
    parameter FIFO_D        = 1024      
)
(
    input               clk                        ,
    input               rst_n                      ,

    input       [31:0]  tx_fifo_wr_data,
    output reg          tx_fifo_wr_data_valid,
    input               tx_fifo_wr_data_req,

    output      [7:0]   rx_fifo_rd_data            ,
    output              rx_fifo_rd_data_valid      ,
    input               rx_fifo_rd_data_req        ,

    output              txd                        ,
    input               rxd
);

wire            clk_en;

wire            tx_fifo_rd_data_req;
wire    [31:0]  tx_fifo_rd_data;
wire            tx_fifo_rd_data_valid;

wire            rx_fifo_wr_data_req;
wire    [7:0]   rx_fifo_wr_data;
reg             rx_fifo_wr_data_valid;

assign rx_fifo_rd_data       = rx_fifo_wr_data;
assign rx_fifo_rd_data_valid = ~rx_fifo_wr_data_valid;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        rx_fifo_wr_data_valid <= 1'b1;
    else if(rx_fifo_wr_data_req)
        rx_fifo_wr_data_valid <= 1'b0;
    else if(rx_fifo_rd_data_req)
        rx_fifo_wr_data_valid <= 1'b1;
    else;
end

assign tx_fifo_rd_data       = tx_fifo_wr_data;
assign tx_fifo_rd_data_valid = ~tx_fifo_wr_data_valid;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        tx_fifo_wr_data_valid <= 1'b1;
    else if(tx_fifo_wr_data_req)
        tx_fifo_wr_data_valid <= 1'b0;
    else if(tx_fifo_rd_data_req)
        tx_fifo_wr_data_valid <= 1'b1;
    else;
end

ipsxb_clk_gen_32bit u_ipsxb_clk_gen(
    .clk                        (clk                            ),
    .rst_n                      (rst_n                          ),

    .clk_div                    (CLK_DIV_P                      ),
    .clk_en                     (clk_en                         )
);

ipsxb_seu_uart_tx u_ipsxb_seu_uart_tx(
    .clk                        (clk                            ),
    .clk_en                     (clk_en                         ),
    .rst_n                      (rst_n                          ),

    .tx_fifo_rd_data            (tx_fifo_rd_data                ),
    .tx_fifo_rd_data_valid      (tx_fifo_rd_data_valid          ),
    .tx_fifo_rd_data_req        (tx_fifo_rd_data_req            ),

    .txd                        (txd                            )
);

ipsxb_seu_uart_rx u_ipsxb_seu_uart_rx(
    .clk                        (clk                            ),
    .rst_n                      (rst_n                          ),
    .clk_en                     (clk_en                         ),

    .rx_fifo_wr_data            (rx_fifo_wr_data                ),
    .rx_fifo_wr_data_valid      (rx_fifo_wr_data_valid          ),
    .rx_fifo_wr_data_req        (rx_fifo_wr_data_req            ),

    .rxd_in                     (rxd                            )
);

endmodule 
