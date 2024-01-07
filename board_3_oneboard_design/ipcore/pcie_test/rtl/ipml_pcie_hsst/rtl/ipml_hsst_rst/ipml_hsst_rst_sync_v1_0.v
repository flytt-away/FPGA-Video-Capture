///////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
///////////////////////////////////////////////////////////////////////////////
//
// Library:
// Filename:
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module ipml_hsst_rst_sync_v1_0
    (
     input                  clk,
     input                  rst_n,

     input                  sig_async,
     output reg             sig_synced
    );

//
reg                      sig_async_ff;

//single bit
always@(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        sig_async_ff <= 1'b0;
    else
        sig_async_ff <= sig_async;
end

always@(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        sig_synced <= 1'b0;
    else
        sig_synced <= sig_async_ff;
end

endmodule
