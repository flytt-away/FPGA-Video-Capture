//******************************************************************
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
`timescale 1ns/1ns
module pgr_apb_mif_32bit
#(
    parameter CLK_FREQ = 8'd50,
    parameter AW = 8'd16,
    parameter DW = 8'd32,
    parameter SW = 8'd4
)(
    input               clk,
    input               rst_n,

    input       [SW-1:0]  strb,
    input       [AW-1:0]  addr,
    input       [DW-1:0]  wdata,
    input                 we,
    input                 cmd_en,
    output                cmd_done,

    output      [7:0]   fifo_data,
    input               fifo_data_valid,
    output              fifo_data_req,

    output  reg            p_sel,
    output  reg [SW-1:0]   p_strb,
    output  reg [AW-1:0]   p_addr,
    output  reg [DW-1:0]   p_wdata,
    output  reg            p_ce,
    output  reg            p_we,
    input                  p_rdy,
    input       [DW-1:0]   p_rdata,
    input                  apb_en,

    output              uart_txvld,
    input               uart_txreq,
    input       [7:0]   uart_txdata
);


reg     [7:0]  cnt;
reg            time_out;

always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        time_out <= 1'b0;
    else if(cnt == 8'hff)
        time_out <= 1'b1;
    else
        time_out <= 1'b0;
end

//assign time_out = cnt == 8'hff;

reg     [7:0]   apb_fifo_data;
wire            apb_fifo_data_valid;
reg             apb_fifo_data_req;

assign fifo_data = apb_en ? apb_fifo_data : uart_txdata;
assign apb_fifo_data_valid = apb_en & fifo_data_valid;
assign uart_txvld = (~apb_en) & fifo_data_valid;
assign fifo_data_req = apb_en ? apb_fifo_data_req : uart_txreq;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cnt <= 8'b0;
    else if(~p_ce)
        cnt <= 8'b0;
    else
        cnt <= cnt + 8'b1;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        p_addr <= 'b0;
    else if(cmd_en)
        p_addr <= addr;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        p_strb <= 'b0;
    else if(cmd_en)
        p_strb <= strb;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        p_wdata <= 'b0;
    else if(cmd_en)
        p_wdata <= wdata;
end

//modify for gen psel signal by wenbin at @2019.8.23
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        p_sel <= 1'b0;
    else if(p_rdy)
        p_sel <= 1'b0;
    else if(time_out)
        p_sel <= 1'b0;
    else if(cmd_en)
        p_sel <= 1'b1;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        p_ce <= 1'b0;
    else if(p_rdy)
        p_ce <= 1'b0;
    else if(time_out)
        p_ce <= 1'b0;
    else if(p_sel)
        p_ce <= 1'b1;
end


always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        p_we <= 1'b0;
    else if(p_rdy)
        p_we <= 1'b0;
    else if(time_out)
        p_we <= 1'b0;
    else if(cmd_en)
        p_we <= we;
end

assign cmd_done = p_ce & (p_rdy | time_out);

reg     [DW-1:0]   rdata;
reg                rdata_valid;

//always@(posedge clk or negedge rst_n)
//begin
//    if(~rst_n)
//        rdata <= 'b0;
//    else if(cmd_done)
//        rdata <= p_rdata;
//end

always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        rdata_valid <= 1'b0;
    else if(cmd_done && (~p_we))
        rdata_valid <= 1'b1;
    else
        rdata_valid <=1'b0;
end

localparam TX_INTERVAL = 6 * (((CLK_FREQ * 1000000 + 3 * 115200) / (6 * 115200)) - 2);
localparam BYTE_NUM = DW / 8;

//assign fifo_data = time_out ? 32'b0 : p_rdata;
//assign fifo_data_req = cmd_done & fifo_data_valid & ~p_we;
assign trans_start = rdata_valid & apb_fifo_data_valid;


// get APB read data,and write it into tx_fifo
reg clk_cnt_start1;
reg	[15:0]	clk_cnt;
reg	[1:0]	trans_cnt;

reg tx_enable;

always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        tx_enable <= 1'b0;
    else if(clk_cnt == (TX_INTERVAL-1))
        tx_enable <= 1'b1;
    else
        tx_enable <= 1'b0;
end

//wire    tx_enable = clk_cnt == TX_INTERVAL;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n) begin
        apb_fifo_data_req <= 1'b0;
        apb_fifo_data <= 8'b0;
        rdata <= 'b0;
    end
    else if(cmd_done & (~p_we))
        rdata <= p_rdata;
    else if(trans_start) begin
        apb_fifo_data <= rdata[7:0];
        apb_fifo_data_req <= 1'b1;
        rdata <= (rdata >> 8);
    end
    else if(tx_enable && (trans_cnt == 2'd1) && (BYTE_NUM > 1)) begin
    	apb_fifo_data <= rdata[7:0];
        apb_fifo_data_req <= 1'b1;
        rdata <= (rdata >> 8);
    end
    else if(tx_enable && (trans_cnt == 2'd2) && (BYTE_NUM > 2)) begin
    	apb_fifo_data <= rdata[7:0];
        apb_fifo_data_req <= 1'b1;
        rdata <= (rdata >> 8);
    end
    else if(tx_enable && (trans_cnt == 2'd3) && (BYTE_NUM > 3)) begin
    	apb_fifo_data <= rdata[7:0];
        apb_fifo_data_req <= 1'b1;
        rdata <= (rdata >> 8);
    end
    else
        apb_fifo_data_req <= 1'b0;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        clk_cnt_start1 <= 1'b0;
    else if(trans_start)
        clk_cnt_start1 <= 1'b1;
    else if(trans_cnt == (BYTE_NUM-1))
        clk_cnt_start1 <= 1'b0;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n) begin
        clk_cnt <= 16'b0;
    end
    else if(trans_start) begin
        clk_cnt <= 16'b0;
    end
    else if(tx_enable) begin
    	  clk_cnt <= 16'b0;
    end
    else if(clk_cnt_start1) begin
        clk_cnt <= clk_cnt + 16'b1;
    end
end


always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        trans_cnt <= 2'd0;
    end
    else
    begin
        if(clk_cnt == (TX_INTERVAL-1))
            trans_cnt <= trans_cnt + 2'd1;
        else if(trans_cnt == (BYTE_NUM-1))
            trans_cnt <= 2'b0;
    end
end
endmodule //pgr_apb_mif