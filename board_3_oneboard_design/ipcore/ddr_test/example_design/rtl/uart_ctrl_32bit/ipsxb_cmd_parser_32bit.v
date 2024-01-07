
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

module ipsxb_cmd_parser_32bit(
    input               clk,
    input               rst_n,

    input       [7:0]   fifo_data,
    input               fifo_data_valid,
    output  reg         fifo_data_req,
    
    output      [23:0]  addr,
    output      [31:0]  data,
    output              we,
    output              cmd_en,
    input               cmd_done
);

localparam ST_IDLE    = 4'd0;
localparam ST_W_ADDRL = 4'd1;
localparam ST_W_ADDRM = 4'd2;
localparam ST_W_ADDRH = 4'd3;
localparam ST_W_DATA_B0 = 4'd4;
localparam ST_W_DATA_B1 = 4'd5;
localparam ST_W_DATA_B2 = 4'd6;
localparam ST_W_DATA_B3 = 4'd7;
localparam ST_W_CMD   = 4'd8;
localparam ST_WAIT    = 4'd9;
localparam ST_R_ADDRL = 4'd10;
localparam ST_R_ADDRM = 4'd11;
localparam ST_R_ADDRH = 4'd12;
localparam ST_R_CMD   = 4'd13;

localparam ASC_w = 8'h77;
localparam ASC_r = 8'h72;

reg     [3:0]   crt_st;
reg     [3:0]   nxt_st;

reg     [7:0]   addrl;
reg     [7:0]   addrm;
reg     [7:0]   addrh;
reg     [7:0]   data_b0;
reg     [7:0]   data_b1;
reg     [7:0]   data_b2;
reg     [7:0]   data_b3;
assign addr = {addrh,addrm,addrl};
assign data = {data_b3,data_b2,data_b1,data_b0};
assign we = crt_st == ST_W_CMD;
assign cmd_en = (crt_st == ST_W_CMD) | (crt_st == ST_R_CMD);

wire in_st_idle    = crt_st == ST_IDLE;
wire in_st_w_addrl = crt_st == ST_W_ADDRL;
wire in_st_w_addrm = crt_st == ST_W_ADDRM;
wire in_st_w_addrh = crt_st == ST_W_ADDRH;
wire in_st_w_data_b0  = crt_st == ST_W_DATA_B0;
wire in_st_w_data_b1  = crt_st == ST_W_DATA_B1;
wire in_st_w_data_b2  = crt_st == ST_W_DATA_B2;
wire in_st_w_data_b3  = crt_st == ST_W_DATA_B3;
wire in_st_r_addrl = crt_st == ST_R_ADDRL;
wire in_st_r_addrm = crt_st == ST_R_ADDRM;
wire in_st_r_addrh = crt_st == ST_R_ADDRH;
wire wait_fifo_data = in_st_idle | in_st_w_addrl | in_st_w_addrm | in_st_w_addrh | in_st_w_data_b0 | in_st_w_data_b1 | 
                      in_st_w_data_b2 | in_st_w_data_b3 | in_st_r_addrl | in_st_r_addrm | in_st_r_addrh;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        crt_st <= ST_IDLE;
    else
        crt_st <= nxt_st;
end

always @(*)
begin
    nxt_st = crt_st;
    case(crt_st)
        ST_IDLE    :
        begin
            if(fifo_data_valid)
            begin
                if(fifo_data == ASC_w)
                    nxt_st = ST_W_ADDRL;
                else if(fifo_data == ASC_r)
                    nxt_st = ST_R_ADDRL;
                else
                    nxt_st = crt_st;
            end
            else
                nxt_st = crt_st;
        end
        ST_W_ADDRL :
        begin
            if(fifo_data_valid)
                nxt_st = ST_W_ADDRM;
            else
                nxt_st = ST_W_ADDRL;
        end
        ST_W_ADDRM :
        begin
            if(fifo_data_valid)
                nxt_st = ST_W_ADDRH;
            else
                nxt_st = ST_W_ADDRM;
        end               
        ST_W_ADDRH :
        begin
            if(fifo_data_valid)
                nxt_st = ST_W_DATA_B0;
            else
                nxt_st = crt_st;
        end 
        ST_W_DATA_B0  :
        begin
            if(fifo_data_valid)
                nxt_st = ST_W_DATA_B1;
            else
                nxt_st = crt_st;
        end
        ST_W_DATA_B1  :
        begin
            if(fifo_data_valid)
                nxt_st = ST_W_DATA_B2;
            else
                nxt_st = crt_st;
        end
        ST_W_DATA_B2  :
        begin
            if(fifo_data_valid)
                nxt_st = ST_W_DATA_B3;
            else
                nxt_st = crt_st;
        end
        ST_W_DATA_B3  :
        begin
            if(fifo_data_valid)
                nxt_st = ST_W_CMD;
            else
                nxt_st = crt_st;
        end
        ST_W_CMD   :
        begin
            nxt_st = ST_WAIT;
        end
        ST_WAIT    :
        begin
            if(cmd_done)
                nxt_st = ST_IDLE;
            else
                nxt_st = crt_st;
        end
        ST_R_ADDRL :
        begin
            if(fifo_data_valid)
                nxt_st = ST_R_ADDRM;
            else
                nxt_st = crt_st;
        end
        ST_R_ADDRM :
        begin
            if(fifo_data_valid)
                nxt_st = ST_R_ADDRH;
            else
                nxt_st = crt_st;
        end
        ST_R_ADDRH :
        begin
            if(fifo_data_valid)
                nxt_st = ST_R_CMD;
            else
                nxt_st = crt_st;
        end
        ST_R_CMD   :
        begin
            nxt_st = ST_WAIT;
        end
        default    :
        begin
            nxt_st = ST_IDLE;
        end
    endcase
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        addrl <= 8'b0;
    else if((in_st_w_addrl | in_st_r_addrl) && fifo_data_valid)
        addrl <= fifo_data;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        addrm <= 8'b0;
    else if((in_st_w_addrm | in_st_r_addrm) && fifo_data_valid)
        addrm <= fifo_data;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        addrh <= 8'b0;
    else if((in_st_w_addrh | in_st_r_addrh) && fifo_data_valid)
        addrh <= fifo_data;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        data_b0 <= 8'b0;
    else if(in_st_w_data_b0 && fifo_data_valid)
        data_b0 <= fifo_data;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        data_b1 <= 8'b0;
    else if(in_st_w_data_b1 && fifo_data_valid)
        data_b1 <= fifo_data;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        data_b2 <= 8'b0;
    else if(in_st_w_data_b2 && fifo_data_valid)
        data_b2 <= fifo_data;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        data_b3 <= 8'b0;
    else if(in_st_w_data_b3 && fifo_data_valid)
        data_b3 <= fifo_data;
end

always @(*)
begin
    if(wait_fifo_data && fifo_data_valid)
        fifo_data_req = 1'b1;
    else
        fifo_data_req = 1'b0;
end

endmodule //pgr_cmd_parser
