//******************************************************************
// Copyright (c) 2015 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************

`timescale 1ns/1ps

module pgr_prefetch_fifo
    #( 
       parameter D = 16, //should be 2^N
       parameter W = 8,
       parameter TYPE = "Distributed"  // "Distributed" or "DRM"
     )
    (
      input                     clk,
      input                     rst_n,

      input                     data_in_valid,
      input  [W-1:0]            data_in,
      output                    data_in_ready,

      input                     data_out_ready,
      output [W-1:0]            data_out,
      output                    data_out_valid
    );

//===================================================================
//     Type        |  Latency   |   ADDR_WIDTH   |   Data width
// "Distributed"   |    2       |      4~10      |     1~256
// "DRM"           |    3       |      9~20      |     1~1152
//===================================================================

reg                         fifo_vld;
reg                         rd_en_ff1;
reg  [2:0]                  shift_vld;
reg  [W-1:0]                rd_data_ff1;

wire [W-1:0]                rd_data;
wire                        pop;
wire                        wr_en;
wire                        rd_en;
wire                        empty;
wire                        full;
wire                        rst;

//
assign wr_en = data_in_valid & ~full;
assign data_in_ready = ~full;
assign rst = ~rst_n;

//
localparam DEPTH = (D < 16) ? 16 : D;
assign rd_en = ~empty & data_out_ready;
assign data_out_valid = fifo_vld;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        fifo_vld <= 1'b0;
    else if (rd_en)
        fifo_vld <= 1'b1;
    else
        fifo_vld <= 1'b0;
end

assign data_out = rd_data_ff1;
always@(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        rd_data_ff1 <= 1'b0;
    else if (rd_en)
        rd_data_ff1 <= rd_data;
end

// distributed_fifo
pgm_distributed_fifo_v1_1
    #(
      .DATA_WIDTH ( W           ),
      .ADDR_WIDTH ( log2(DEPTH) ),
      .OUT_REG    ( 0           ),
      .FIFO_TYPE  ( "SYNC_FIFO" )
     )
    pgm_distributed_fifo_v1_0
    (
    .wr_data        ( data_in  ),
    .wr_en          ( wr_en    ),
    .wr_clk         ( clk      ),
    .full           ( full     ),
    .wr_rst         ( rst      ),
    .almost_full    (          ),
    .wr_water_level (          ),
    .rd_data        ( rd_data  ),
    .rd_en          ( rd_en    ),
    .rd_clk         ( clk      ),
    .empty          ( empty    ),
    .rd_rst         ( rst      ),
    .rd_water_level (          ),
    .almost_empty   (          )
    );

// Log 2
function integer log2;
    input integer dep;
    begin
        log2 = 0;
        while (dep > 1)
        begin
            dep  = dep >> 1;
            log2 = log2 + 1;
        end
    end
endfunction

endmodule
