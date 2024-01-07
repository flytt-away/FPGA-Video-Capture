//******************************************************************
// Copyright (c) 2015 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
`timescale 1ns/1ps
module  hsst_rst_cross_sync_v1_0 #(
    parameter RST_CNTR_WIDTH     = 16,
    parameter RST_CNTR_VALUE     = 16'hC000
)(
    // Reset and Clock
    input           clk,
    input           rstn_in,

    output  reg     rstn_out
);

//****************************************************************************//
//                      Internal Signal                                       //
//****************************************************************************//
    reg rs1;
    reg rs2;

    wire                          rstn_inner;
    reg     [3:0]                 rstn_inner_d;
    reg                           rstn_sync;
    reg     [RST_CNTR_WIDTH-1:0]  cnt_rst;

//****************************************************************************//
//                      Sequential and Logic                                  //
//****************************************************************************//
    always@(posedge clk or negedge rstn_in) 
    begin
        if(!rstn_in) 
        begin
            rs1<=0;
            rs2<=0;
        end
        else
        begin
            rs1<=1;
            rs2<=rs1;
        end
    end


    assign rstn_inner = rs2;

    `ifdef IPSL_PCIE_SPEEDUP_SIM
        initial begin
            rstn_inner_d = 4'hf; //CLM reg default value is 1
            rstn_sync    = 1'b1;
            cnt_rst      = {RST_CNTR_WIDTH{1'b1}};
            rstn_out     = 1'b1;
        end
    `endif

    always @(posedge clk or negedge rstn_inner)
    begin
        if (!rstn_inner) begin
            rstn_inner_d <= 4'h0; //CLM reg default value is 1
            rstn_sync    <= 1'b0;
            cnt_rst      <= {RST_CNTR_WIDTH{1'b1}};
            rstn_out     <= 1'b0;
        end
        else begin
            rstn_inner_d <= {rstn_inner_d[2:0], rstn_inner};

            if (rstn_inner_d[3:2] == 2'd0)
                rstn_sync <= 1'b0;
            else
                rstn_sync <= 1'b1;

            if (~rstn_sync) begin
                cnt_rst <= {RST_CNTR_WIDTH{1'b1}};
                rstn_out   <= 1'b0;
            end
            else if (cnt_rst == RST_CNTR_VALUE)
                rstn_out <= 1'b1;
            else begin
                rstn_out <= 1'b0;
                cnt_rst <= cnt_rst + {{(RST_CNTR_WIDTH-1){1'b0}}, 1'b1};
            end
        end
    end
endmodule