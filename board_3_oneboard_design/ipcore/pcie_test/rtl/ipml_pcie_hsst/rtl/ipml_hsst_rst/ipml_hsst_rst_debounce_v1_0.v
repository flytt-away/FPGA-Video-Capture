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
module ipml_hsst_rst_debounce_v1_0 #(
    parameter RISE_CNTR_WIDTH = 12,
    parameter RISE_CNTR_VALUE = 12'd2048,
    parameter ACTIVE_HIGH     = 1'b0 // 0 : active@low, 1 : active@high
)(
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire                          signal_b,
    output wire                          signal_deb
);

wire                          signal_b_mux;
reg                           signal_b_ff;
reg                           signal_b_neg;
reg                           signal_deb_pre;
reg     [RISE_CNTR_WIDTH-1:0] rise_cnt;

assign signal_b_mux = (ACTIVE_HIGH == 1'b1) ? ~signal_b : signal_b;
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        signal_b_ff  <= 1'b0;
        signal_b_neg <= 1'b0;
    end
    else
    begin
        signal_b_ff  <= signal_b_mux;
        signal_b_neg <= ~signal_b_mux & signal_b_ff;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        rise_cnt <= {RISE_CNTR_WIDTH{1'b0}};
    else if (signal_b_neg)
        rise_cnt <= {RISE_CNTR_WIDTH{1'b0}};
    else if (rise_cnt == RISE_CNTR_VALUE)
        rise_cnt <= rise_cnt;
    else if (signal_b_mux)
        rise_cnt <= rise_cnt + {{RISE_CNTR_WIDTH-1{1'b0}}, 1'b1};
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        signal_deb_pre <= 1'b0;
    else if (signal_b_neg)
        signal_deb_pre <= 1'b0;
    else if (rise_cnt == RISE_CNTR_VALUE)
        signal_deb_pre <= 1'b1;
end

assign signal_deb = (ACTIVE_HIGH == 1'b1) ? ~signal_deb_pre : signal_deb_pre;

endmodule
