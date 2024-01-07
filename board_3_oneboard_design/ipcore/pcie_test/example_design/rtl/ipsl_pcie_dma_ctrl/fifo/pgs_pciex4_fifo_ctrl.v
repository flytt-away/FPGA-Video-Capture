//******************************************************************
// Copyright (c) 2015 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************

`timescale 1ns/1ps

module pgs_pciex4_fifo_ctrl #(
    parameter  ADDR_WIDTH  = 9     
)
( input                                 clk            , 
  input                                 rst_n          , 
  input                                 w_en           , 
  output reg [ADDR_WIDTH-1 : 0]         wr_addr         ,
  output reg                            wfull          , 
                                                  
  input                                 r_en           , 
  output reg  [ADDR_WIDTH-1 : 0]        rd_addr        , 
  output reg                            rempty           

);

reg [ADDR_WIDTH-1 : 0] fifo_cnt;
 
always@(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        fifo_cnt <= {ADDR_WIDTH{1'b0}};
    else
        case({w_en, r_en})
           2'b10: fifo_cnt <= fifo_cnt + {{(ADDR_WIDTH-1){1'b0}}, 1'b1};
           2'b01: fifo_cnt <= fifo_cnt - {{(ADDR_WIDTH-1){1'b0}}, 1'b1};
        endcase
end

always@(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        wr_addr <=  {ADDR_WIDTH{1'b0}};
    else if(w_en)
        wr_addr <= wr_addr + {{(ADDR_WIDTH-1){1'b0}}, 1'b1};
end

always@(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        rd_addr <=  {ADDR_WIDTH{1'b0}};
    else if(r_en)
        rd_addr <= rd_addr + {{(ADDR_WIDTH-1){1'b0}}, 1'b1};
end

//FIFO full
always@(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        wfull <= 1'b0;
    else if ( (fifo_cnt == {{(ADDR_WIDTH-1){1'b1}}, 1'b0}) & w_en & ~r_en )
        wfull <= 1'b1;
    else if (~w_en & r_en)
        wfull <= 1'b0;
end

//FIFO empty
always@(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        rempty <= 1'b1;
    else if ( (fifo_cnt == {{(ADDR_WIDTH-1){1'b0}}, 1'b1}) & ~w_en & r_en )
        rempty <= 1'b1;
    else if (w_en & ~r_en)
        rempty <= 1'b0;
end

endmodule
