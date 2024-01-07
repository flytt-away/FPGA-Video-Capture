// Created by IP Generator (Version 2022.1 build 99559)
// Instantiation Template
//
// Insert the following codes into your Verilog file.
//   * Change the_instance_name to your own instance name.
//   * Change the signal names in the port associations


interpolation_ram the_instance_name (
  .wr_data(wr_data),    // input [31:0]
  .wr_addr(wr_addr),    // input [10:0]
  .wr_en(wr_en),        // input
  .wr_clk(wr_clk),      // input
  .wr_rst(wr_rst),      // input
  .rd_addr(rd_addr),    // input [10:0]
  .rd_data(rd_data),    // output [31:0]
  .rd_clk(rd_clk),      // input
  .rd_rst(rd_rst)       // input
);
