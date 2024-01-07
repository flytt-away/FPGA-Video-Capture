
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

module ipsxb_clk_gen_32bit(
    input           clk,
    input           rst_n,

    input   [15:0]  clk_div,
    output  reg     clk_en  // divided from baud
);

reg     [15:0] cnt;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cnt <= 16'b0;
    else if(cnt == (clk_div - 16'd1))
        cnt <= 16'b0;
    else
        cnt <= cnt + 16'b1;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        clk_en <= 1'b0;
    else
        clk_en <= cnt == (clk_div - 16'd1);
end


endmodule //pgr_clk_gen
