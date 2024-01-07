
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

module ipsxb_seu_uart_tx(
    input  wire         clk                     ,
    input  wire         clk_en                  ,
    input  wire         rst_n                   ,

    input  wire [31:0]  tx_fifo_rd_data         ,
    input  wire         tx_fifo_rd_data_valid   ,  // Transfer the data until tx_fifo is empty
    output reg          tx_fifo_rd_data_req     ,

    output reg          txd
);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam END   = 2'b11;

reg  [1:0]   tx_cs             ;
reg  [1:0]   tx_ns             ;
reg  [5:0]   tx_data_cnt       ;
wire         data_end          ;
reg  [2:0]   cnt               ;
wire         bit_en            ; //5 div from clk_en
reg          transmitting      ;
wire [37:0]  tx_frame_data     ;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cnt <= 3'd0;
    else if(~transmitting)
        cnt <= 3'd0;
    else if(clk_en)
    begin
        if(cnt == 3'd5)
            cnt <= 3'd0;
        else
            cnt <= cnt + 3'd1;
    end
    else;
end

assign bit_en = (cnt == 3'd5) && clk_en;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        tx_cs <= IDLE;
    else if(bit_en)
        tx_cs <= tx_ns;
    else;
end

always@(*)
begin
    case(tx_cs)
        IDLE: begin
            if(transmitting)
                tx_ns = START;
            else
                tx_ns = IDLE;
        end
        START: begin
            tx_ns = DATA;
        end
        DATA: begin
            if(data_end)
                tx_ns = END;
            else
                tx_ns = DATA;
        end
        END: begin
            if(transmitting && tx_fifo_rd_data_valid)
                tx_ns = START;
            else
                tx_ns = IDLE;
        end
        default: begin
            tx_ns = IDLE;
        end
    endcase
end

//read data from fifo ,once a time
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        transmitting <= 0; 
    else if(tx_fifo_rd_data_valid) 
        transmitting <= 1;        
    else if(~tx_fifo_rd_data_valid && (tx_cs == END) && bit_en)
        transmitting <= 0;        
    else;
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tx_fifo_rd_data_req <= 0;
    else if(tx_fifo_rd_data_valid && transmitting && data_end && bit_en)
        tx_fifo_rd_data_req <= 1;
    else
        tx_fifo_rd_data_req <= 0;
end

//tx data cnt
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tx_data_cnt <= 6'd0;
    else if(tx_cs == DATA) 
        if(bit_en) 
            tx_data_cnt <= tx_data_cnt + 6'd1;
        else;
    else
        tx_data_cnt <= 6'd0;
end

assign data_end = tx_data_cnt == 6'd37;

assign tx_frame_data = {tx_fifo_rd_data[31:24],2'b01,tx_fifo_rd_data[23:16],2'b01,tx_fifo_rd_data[15:8],2'b01,tx_fifo_rd_data[7:0]};

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        txd <= 1'b1;
    else if(tx_cs == START) 
        txd <= 1'b0;
    else if(tx_cs == DATA)
        txd <= tx_frame_data[tx_data_cnt];
    else
        txd <= 1'b1;
end

endmodule 
