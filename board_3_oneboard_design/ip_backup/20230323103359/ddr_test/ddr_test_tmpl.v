// Created by IP Generator (Version 2022.1 build 99559)
// Instantiation Template
//
// Insert the following codes into your Verilog file.
//   * Change the_instance_name to your own instance name.
//   * Change the signal names in the port associations


ddr_test the_instance_name (
  .resetn(resetn),                                      // input
  .ddr_init_done(ddr_init_done),                        // output
  .ddrphy_clkin(ddrphy_clkin),                          // output
  .pll_lock(pll_lock),                                  // output
  .axi_awaddr(axi_awaddr),                              // input [27:0]
  .axi_awuser_ap(axi_awuser_ap),                        // input
  .axi_awuser_id(axi_awuser_id),                        // input [3:0]
  .axi_awlen(axi_awlen),                                // input [3:0]
  .axi_awready(axi_awready),                            // output
  .axi_awvalid(axi_awvalid),                            // input
  .axi_wstrb(axi_wstrb),                                // input [31:0]
  .axi_wready(axi_wready),                              // output
  .axi_wusero_id(axi_wusero_id),                        // output [3:0]
  .axi_wusero_last(axi_wusero_last),                    // output
  .axi_araddr(axi_araddr),                              // input [27:0]
  .axi_aruser_ap(axi_aruser_ap),                        // input
  .axi_aruser_id(axi_aruser_id),                        // input [3:0]
  .axi_arlen(axi_arlen),                                // input [3:0]
  .axi_arready(axi_arready),                            // output
  .axi_arvalid(axi_arvalid),                            // input
  .axi_rdata(axi_rdata),                                // output [255:0]
  .axi_rid(axi_rid),                                    // output [3:0]
  .axi_rlast(axi_rlast),                                // output
  .axi_rvalid(axi_rvalid),                              // output
  .apb_clk(apb_clk),                                    // input
  .apb_rst_n(apb_rst_n),                                // input
  .apb_sel(apb_sel),                                    // input
  .apb_enable(apb_enable),                              // input
  .apb_addr(apb_addr),                                  // input [7:0]
  .apb_write(apb_write),                                // input
  .apb_ready(apb_ready),                                // output
  .apb_wdata(apb_wdata),                                // input [15:0]
  .apb_rdata(apb_rdata),                                // output [15:0]
  .apb_int(apb_int),                                    // output
  .debug_data(debug_data),                              // output [135:0]
  .debug_slice_state(debug_slice_state),                // output [51:0]
  .debug_calib_ctrl(debug_calib_ctrl),                  // output [21:0]
  .ck_dly_set_bin(ck_dly_set_bin),                      // output [7:0]
  .force_ck_dly_en(force_ck_dly_en),                    // input
  .force_ck_dly_set_bin(force_ck_dly_set_bin),          // input [7:0]
  .dll_step(dll_step),                                  // output [7:0]
  .dll_lock(dll_lock),                                  // output
  .init_read_clk_ctrl(init_read_clk_ctrl),              // input [1:0]
  .init_slip_step(init_slip_step),                      // input [3:0]
  .force_read_clk_ctrl(force_read_clk_ctrl),            // input
  .ddrphy_gate_update_en(ddrphy_gate_update_en),        // input
  .update_com_val_err_flag(update_com_val_err_flag),    // output [3:0]
  .rd_fake_stop(rd_fake_stop),                          // input
  .mem_rst_n(mem_rst_n),                                // output
  .mem_ck(mem_ck),                                      // output
  .mem_ck_n(mem_ck_n),                                  // output
  .mem_cke(mem_cke),                                    // output
  .mem_cs_n(mem_cs_n),                                  // output
  .mem_ras_n(mem_ras_n),                                // output
  .mem_cas_n(mem_cas_n),                                // output
  .mem_we_n(mem_we_n),                                  // output
  .mem_odt(mem_odt),                                    // output
  .mem_a(mem_a),                                        // output [14:0]
  .mem_ba(mem_ba),                                      // output [2:0]
  .mem_dqs(mem_dqs),                                    // inout [3:0]
  .mem_dqs_n(mem_dqs_n),                                // inout [3:0]
  .mem_dq(mem_dq),                                      // inout [31:0]
  .mem_dm(mem_dm)                                       // output [3:0]
);
