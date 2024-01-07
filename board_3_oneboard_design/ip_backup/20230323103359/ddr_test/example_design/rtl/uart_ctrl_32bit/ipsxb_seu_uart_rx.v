
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

module ipsxb_seu_uart_rx(
    input              clk                     ,
    input              rst_n                   ,
    input              clk_en                  ,

    output reg  [7:0]  rx_fifo_wr_data         ,
    input              rx_fifo_wr_data_valid   ,
    output wire        rx_fifo_wr_data_req     ,

    input              rxd_in
);

reg  [1:0]   rxd_d               ;
reg  [2:0]   rxd_tmp             ;
reg          rxd_r1              ;
reg          rxd_r2              ;
wire         rxd                 ;
wire         rxd_neg             ;
reg          in_cyc              ;
reg  [3:0]   rx_cnt              ;
reg  [2:0]   cnt                 ;
wire         rx_over             ;
wire         rx_sample           ;
reg          rx_req              ;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        rxd_d <= 2'b11;
    else
        rxd_d <= {rxd_d[0],rxd_in};
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        rxd_tmp <= 3'b111;
    else if(clk_en)
        rxd_tmp <= {rxd_tmp[1:0],rxd_d[1]};
    else;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        rxd_r1 <= 1'b1;
    else if(clk_en)
    begin
        if(rxd_tmp == 3'b111)
            rxd_r1 <= 1'b1;
        else if(rxd_tmp == 3'b000)
            rxd_r1 <= 1'b0;
        else;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        rxd_r2 <= 1'b1;
    else if(clk_en)
        rxd_r2 <= rxd_r1;
end

assign rxd = rxd_r2;
assign rxd_neg = rxd_r2 & ~rxd_r1;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        in_cyc <= 1'b0;
    else if(clk_en)
    begin
        if(rxd_neg)
            in_cyc <= 1'b1;
        else if(rx_over && rx_sample)
            in_cyc <= 1'b0;
    end
end

assign cnt_down  = cnt == 3'd5;
assign rx_sample = cnt == 3'd2;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cnt <= 3'b0;
    else if(clk_en)
    begin
        if(cnt_down)
            cnt <= 3'b0;
        else if(~in_cyc)
            cnt <= 3'b0;
        else
            cnt <= cnt + 3'b1;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        rx_fifo_wr_data <= 8'b0;
        rx_cnt <= 4'd9;
    end
    else if(clk_en)
    begin
        if(~in_cyc)
        begin
            rx_fifo_wr_data <= 8'b0;
            rx_cnt <= 4'd9;
        end
        else if(rx_sample)
        begin
            rx_fifo_wr_data <= {rxd,rx_fifo_wr_data[7:1]};
            rx_cnt <= rx_cnt + 4'hf; // rx_cnt = rx_cnt - 1;
        end
    end
end

assign rx_over = rx_cnt == 4'd1;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        rx_req <= 1'b0;
    else if(clk_en)
    begin
        if(rx_sample && rx_over)
            rx_req <= 1'b1;
    end
    else
        rx_req <= 1'b0;
end

assign rx_fifo_wr_data_req = rx_req && rx_fifo_wr_data_valid;

endmodule
