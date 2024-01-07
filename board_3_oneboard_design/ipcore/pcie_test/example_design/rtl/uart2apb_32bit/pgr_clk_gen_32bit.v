//******************************************************************
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
`timescale 1ns/1ns
module pgr_clk_gen_32bit
#(
    parameter   CLK_FREQ    = 8'd50
)
(
    input           clk,
    input           rst_n,
    output  reg     clk_en  // divided from baud
);

reg     [15:0] cnt;

localparam CLK_DIV = (CLK_FREQ * 1000000 + 3 * 115200) / (6 * 115200) - 2;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cnt <= 16'b0;
    else if(clk_en)
        cnt <= 16'b0;
    else
        cnt <= cnt + 16'b1;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        clk_en <= 1'b0;
    else
        clk_en <= (cnt == CLK_DIV);
end


endmodule //pgr_clk_gen