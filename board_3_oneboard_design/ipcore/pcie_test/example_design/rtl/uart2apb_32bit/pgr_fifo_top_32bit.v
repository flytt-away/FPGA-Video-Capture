//******************************************************************
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
`timescale 1ns/1ns
module pgr_fifo_top_32bit
#(
    parameter D = 16'd1024
)
(
    input               clk,
    input               rst_n,

    input       [7:0]   wr_data,
    input               wr_req,
    output              wr_ready,

    input               rd_req,
    output      [7:0]   rd_data,
    output              rd_valid
);

pgr_prefetch_fifo
#(
    .D                  (D                  ), //should be 2^N
    .W                  (8                  ),
    .TYPE               ("Distributed"      )  // "Distributed" or "DRM"
)
u_prefetch_fifo(
    .clk                (clk                ),
    .rst_n              (rst_n              ),

    .data_in_valid      (wr_req             ),
    .data_in            (wr_data            ),
    .data_in_ready      (wr_ready           ),

    .data_out_ready     (rd_req             ),
    .data_out           (rd_data            ),
    .data_out_valid     (rd_valid           )
);

endmodule //fifo

