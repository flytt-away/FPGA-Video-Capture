//******************************************************************
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
`timescale 1ns/1ns
module pgr_uart_tx_32bit(
    input           clk,
    input           clk_en,
    input           rst_n,

    input   [7:0]   tx_fifo_rd_data,
    input           tx_fifo_rd_data_valid,  // Transfer the data until tx_fifo is empty
    output  wire    tx_fifo_rd_data_req,

    input   [1:0]   uart_word_len,
    input           uart_parity_en,
    input           uart_parity_type,
    input           uart_stop_len,
    input           uart_mode, //0:LSBF 1:MSBF

    output  wire    txd
);

reg     [2:0]   cnt;
wire            cnt_down;
reg             clken; //5 div from clk_en
//reg             in_cyc;
//reg             tx_begin;
reg             tx_req;
wire            tx_over;
wire    [7:0]   tx_data;
wire    [7:0]   tx_data_temp;
wire    [7:0]   tx_data_revise;
reg     [11:0]  tx_frame;
reg     [3:0]   tx_len;
reg     [3:0]   tx_cnt;
reg     [11:0]  shift_reg;
reg     [7:0]   tx_data_purn;

assign cnt_down = cnt == 3'd5;  // oversample, 6 times

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        clken <= 1'b0;
    else
        clken <= cnt_down && clk_en;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cnt <= 3'b0;
    else if(clk_en)
    begin
        if(cnt_down)
            cnt <= 3'b0;
        else
            cnt <= cnt + 3'b1;
    end
end
//
//always @(posedge clk or negedge rst_n)
//begin
//    if(~rst_n)
//    begin
//        tx_data <= 8'hff;
//        tx_begin <= 1'b0;
//    end
//    else if(clken)
//    begin
//        if(~in_cyc && tx_fifo_rd_data_valid && ~tx_begin)
//        begin
//            tx_begin <= 1'b1;
//            tx_data <= tx_fifo_rd_data;
//        end
//        else
//            tx_begin <= 1'b0;
//    end
//end

assign tx_data = tx_fifo_rd_data;

assign tx_fifo_rd_data_req = tx_req & clken;

//always @(posedge clk or negedge rst_n)
//begin
//    if(~rst_n)
//        in_cyc <= 1'b0;
//    else if(clken)
//    begin
//        if(tx_begin)
//            in_cyc <= 1'b1;
//        else if(tx_over)
//            in_cyc <= 1'b0;
//    end
//end

genvar i;
generate
for(i = 0; i <= 7; i = i + 1)
begin:REV_TX
    assign tx_data_revise[i] = tx_data[7 - i];
end
endgenerate     //MSBF 2 LSBF

assign tx_data_temp = uart_mode ? (tx_data_revise >> (3 - uart_word_len)) : tx_data;
assign tx_parity = uart_parity_en ? (uart_parity_type ? (~(^tx_data_purn)) : (^tx_data_purn)) : 1'b1;

always @(*)
begin
    case({uart_word_len,uart_parity_en,uart_stop_len})
        4'b0000 : tx_len = 4'd6;
        4'b0001 : tx_len = 4'd7;
        4'b0010 : tx_len = 4'd7;
        4'b0011 : tx_len = 4'd8;
        4'b0100 : tx_len = 4'd7;
        4'b0101 : tx_len = 4'd8;
        4'b0110 : tx_len = 4'd8;
        4'b0111 : tx_len = 4'd9;
        4'b1000 : tx_len = 4'd8;
        4'b1001 : tx_len = 4'd9;
        4'b1010 : tx_len = 4'd9;
        4'b1011 : tx_len = 4'd10;
        4'b1100 : tx_len = 4'd9;
        4'b1101 : tx_len = 4'd10;
        4'b1110 : tx_len = 4'd10;
        4'b1111 : tx_len = 4'd11;
    endcase
end

always @(*)
begin
    case(uart_word_len)
        2'b00 : tx_data_purn = {3'b0,tx_data_temp[4:0]};
        2'b01 : tx_data_purn = {2'b0,tx_data_temp[5:0]};
        2'b10 : tx_data_purn = {1'b0,tx_data_temp[6:0]};
        2'b11 : tx_data_purn = {tx_data_temp};
    endcase
end

always @(*)
begin
    case(uart_word_len)
        2'b00 : tx_frame = {6'h3f,tx_parity,tx_data_temp[4:0],1'b0};
        2'b01 : tx_frame = {5'h1f,tx_parity,tx_data_temp[5:0],1'b0};
        2'b10 : tx_frame = {4'hf,tx_parity,tx_data_temp[6:0],1'b0};
        2'b11 : tx_frame = {2'h3,tx_parity,tx_data_temp,1'b0};
    endcase
end

reg valid_temp;

always@(posedge clk or negedge rst_n)
begin
   if(~rst_n)
        valid_temp <= 1'b0;
   else if(tx_fifo_rd_data_valid)
        valid_temp <= 1'b1;
    else if(tx_over && clken)
        valid_temp <= 1'b0;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        shift_reg <= 12'hfff;
        tx_cnt <= 4'b0;
        tx_req <= 1'b0;
    end
    else if(clken)
    begin
        if(tx_over)
        begin
            shift_reg <= valid_temp ? tx_frame : 12'hfff;
            tx_cnt <= 4'b0;
            tx_req <= 1;
        end
        else //if(in_cyc)
        begin
            shift_reg <= {1'b1,shift_reg[11:1]};
            tx_cnt <= tx_cnt + 4'b1;
            tx_req <= 1'b0;
        end
    end
end

assign txd = shift_reg[0];

assign tx_over = tx_cnt == tx_len;

endmodule //pgr_uart_tx
