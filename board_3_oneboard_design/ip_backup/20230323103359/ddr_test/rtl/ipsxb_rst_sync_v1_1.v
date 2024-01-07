////////////////////////////////////////////////////////////////
// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
////////////////////////////////////////////////////////////////
//Description:
//Author:  wxxiao
//History: v1.0
////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module ipsxb_rst_sync_v1_1 #
    (
    parameter DATA_WIDTH = 1'd1, //
    parameter DFT_VALUE  = {DATA_WIDTH{1'b0}}
    )
    (
     input   wire                   clk,
     input   wire                   rst_n,
     input   wire  [DATA_WIDTH-1:0] sig_async,
     output  wire  [DATA_WIDTH-1:0] sig_synced
    );

reg     [DATA_WIDTH-1:0]  sig_async_r1;
reg     [DATA_WIDTH-1:0]  sig_async_r2;

always@(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        sig_async_r1 <= DFT_VALUE;
        sig_async_r2 <= DFT_VALUE;
    end
    else
    begin
        sig_async_r1 <= sig_async;
        sig_async_r2 <= sig_async_r1;
    end
end

assign sig_synced = sig_async_r2;

endmodule
