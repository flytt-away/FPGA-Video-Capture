//******************************************************************
// Copyright (c) 2015 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************

module ipml_reg_fifo_v1_0
    #( 
       parameter W = 8
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

//
reg  [W-1:0]                data_0;
reg  [W-1:0]                data_1;
reg                         wptr;
reg                         rptr;
reg                         data_valid_0;
reg                         data_valid_1;

wire                        fifo_read;
wire                        fifo_write;

// handshake
assign fifo_write = data_in_ready & data_in_valid;
assign fifo_read  = data_out_valid & data_out_ready;

always@(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        wptr <= 1'b0;
    else if (fifo_write)
        wptr <= ~wptr;
end

always@(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        rptr <= 1'b0;
    else if (fifo_read)
        rptr <= ~rptr;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        data_0 <= {W{1'b0}};
    else if (fifo_write & ~wptr)
        data_0 <= data_in;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        data_1 <= {W{1'b0}};
    else if (fifo_write & wptr)
        data_1 <= data_in;
end

// valid
assign data_out_valid = data_valid_0 | data_valid_1;
assign data_in_ready = ~data_valid_0 | ~data_valid_1;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        data_valid_0 <= 1'b0;
    else if (fifo_write & ~wptr)
        data_valid_0 <= 1'b1;
    else if (fifo_read & ~rptr)
        data_valid_0 <= 1'b0;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        data_valid_1 <= 1'b0;
    else if (fifo_write & wptr)
        data_valid_1 <= 1'b1;
    else if (fifo_read & rptr)
        data_valid_1 <= 1'b0;
end

//
assign data_out = ({W{rptr}} & data_1) | ({W{~rptr}} & data_0);

endmodule
