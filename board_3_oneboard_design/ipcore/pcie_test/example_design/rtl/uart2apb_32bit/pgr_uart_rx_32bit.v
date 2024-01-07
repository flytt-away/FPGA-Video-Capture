//******************************************************************
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
`timescale 1ns/1ns
module pgr_uart_rx_32bit(
    input               clk,
    input               rst_n,
    input               clk_en,

    output  wire[7:0]   rx_fifo_wr_data,
    input               rx_fifo_wr_data_valid,
    output  wire        rx_fifo_wr_data_req,

    input       [1:0]   uart_word_len,
    input               uart_parity_en,
    input               uart_parity_type,
    input               uart_mode, //0:LSBF 1:MSBF

    output  reg         rx_chk_err,
    output  reg         rx_overrun,

    input               rxd_in
);

reg     [1:0]   rxd_d;
reg     [2:0]   rxd_tmp;
reg             rxd_r1;
reg             rxd_r2;
reg             rxd;
wire            rxd_neg;
reg     [3:0]   rx_cnt;
reg     [2:0]   cnt;
reg     [8:0]   rx_data;
reg     [3:0]   rx_len_left;
wire    [7:0]   rx_word_temp;
wire    [7:0]   rx_word_revise;
wire            rx_over;
wire            rx_chk;
wire            rx_err;
reg             rx_req;
reg     [2:0]   cnt_judge;
wire            cnt_down;
reg in_cyc;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cnt_judge <= 3'b0;
    else if(clk_en)
    begin
        if(cnt_down)
            cnt_judge <= 3'b0;
        else
        begin
            if(in_cyc)
            cnt_judge <= cnt_judge + rxd_r2;
        else
            cnt_judge <= 3'b0;
        end
    end
end

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
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        rxd_r2 <= 1'b1;
    else if(clk_en)
        rxd_r2 <= rxd_r1;
end

//assign rxd = rxd_r2;

always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        rxd <= 1'b0;
    else if(cnt_down)
    begin
        if(cnt_judge < 3'd3)
            rxd <= 1'b0;
        else
            rxd <= 1'b1;
    end
end

assign rxd_neg = rxd_r2 & (~rxd_r1);

reg rx_sample;

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

assign rx_over = rx_cnt == rx_len_left;

assign cnt_down = cnt == 3'd5;
//assign rx_sample = cnt == 3'd2;

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

always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        rx_sample <= 1'b0;
    else
    begin
        if(cnt_down)
            rx_sample <= 1'b1;
        else
            rx_sample <=1'b0;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        rx_data <= 9'b0;
        rx_cnt <= 4'd9;
    end
    else if(clk_en)
    begin
        if(~in_cyc)
        begin
            rx_data <= 9'b0;
            rx_cnt <= 4'd9;
        end
        else if(rx_sample)
        begin
            rx_data <= {rxd,rx_data[8:1]};
            rx_cnt <= rx_cnt + 4'hf; // rx_cnt = rx_cnt - 1;
        end
    end
end

always @(*)
begin
    case({uart_word_len,uart_parity_en})
        3'b000 : rx_len_left = 3'd4;
        3'b001 : rx_len_left = 3'd3;
        3'b010 : rx_len_left = 3'd3;
        3'b011 : rx_len_left = 3'd2;
        3'b100 : rx_len_left = 3'd2;
        3'b101 : rx_len_left = 3'd1;
        3'b110 : rx_len_left = 3'd1;
        3'b111 : rx_len_left = 3'd0;
    endcase
end

assign rx_word_temp = uart_parity_en ? rx_data[7:0] : rx_data[8:1];

genvar i;
generate
for(i = 0; i <= 7; i = i + 1)
begin:REV_TX
    assign rx_word_revise[i] = rx_word_temp[7 - i];
end
endgenerate     //MSBF 2 LSBF

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

assign rx_fifo_wr_data_req = rx_req && rx_fifo_wr_data_valid && (~rx_err);

assign rx_fifo_wr_data = uart_mode ? rx_word_revise : (rx_word_temp >> (rx_len_left - {2'b00,(~uart_parity_en)}));

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        rx_overrun <= 1'b0;
    else if(rx_req && (~rx_fifo_wr_data_valid))
        rx_overrun <= 1'b1;
    else
        rx_overrun <= 1'b0;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        rx_chk_err <= 1'b0;
    else if(rx_req)
        rx_chk_err <= rx_err;
end

assign rx_err = uart_parity_en ? (rx_chk ^ uart_parity_type) : 1'b0;
assign rx_chk = ^rx_data;

endmodule //pgr_uart_rx
