// Created by IP Generator (Version 2022.1 build 99559)
// Instantiation Template
//
// Insert the following codes into your Verilog file.
//   * Change the_instance_name to your own instance name.
//   * Change the signal names in the port associations


pcie_test the_instance_name (
  .free_clk(free_clk),                                      // input
  .pclk(pclk),                                              // output
  .pclk_div2(pclk_div2),                                    // output
  .ref_clk(ref_clk),                                        // output
  .ref_clk_n(ref_clk_n),                                    // input
  .ref_clk_p(ref_clk_p),                                    // input
  .button_rst_n(button_rst_n),                              // input
  .power_up_rst_n(power_up_rst_n),                          // input
  .perst_n(perst_n),                                        // input
  .core_rst_n(core_rst_n),                                  // output
  .smlh_link_up(smlh_link_up),                              // output
  .rdlh_link_up(rdlh_link_up),                              // output
  .smlh_ltssm_state(smlh_ltssm_state),                      // output [4:0]
  .p_sel(p_sel),                                            // input
  .p_strb(p_strb),                                          // input [3:0]
  .p_addr(p_addr),                                          // input [15:0]
  .p_wdata(p_wdata),                                        // input [31:0]
  .p_ce(p_ce),                                              // input
  .p_we(p_we),                                              // input
  .p_rdy(p_rdy),                                            // output
  .p_rdata(p_rdata),                                        // output [31:0]
  .rxn(rxn),                                                // input [1:0]
  .rxp(rxp),                                                // input [1:0]
  .txn(txn),                                                // output [1:0]
  .txp(txp),                                                // output [1:0]
  .pcs_nearend_loop(pcs_nearend_loop),                      // input [1:0]
  .pma_nearend_ploop(pma_nearend_ploop),                    // input [1:0]
  .pma_nearend_sloop(pma_nearend_sloop),                    // input [1:0]
  .axis_master_tvalid(axis_master_tvalid),                  // output
  .axis_master_tready(axis_master_tready),                  // input
  .axis_master_tdata(axis_master_tdata),                    // output [127:0]
  .axis_master_tkeep(axis_master_tkeep),                    // output [3:0]
  .axis_master_tlast(axis_master_tlast),                    // output
  .axis_master_tuser(axis_master_tuser),                    // output [7:0]
  .axis_slave0_tready(axis_slave0_tready),                  // output
  .axis_slave0_tvalid(axis_slave0_tvalid),                  // input
  .axis_slave0_tdata(axis_slave0_tdata),                    // input [127:0]
  .axis_slave0_tlast(axis_slave0_tlast),                    // input
  .axis_slave0_tuser(axis_slave0_tuser),                    // input
  .axis_slave1_tready(axis_slave1_tready),                  // output
  .axis_slave1_tvalid(axis_slave1_tvalid),                  // input
  .axis_slave1_tdata(axis_slave1_tdata),                    // input [127:0]
  .axis_slave1_tlast(axis_slave1_tlast),                    // input
  .axis_slave1_tuser(axis_slave1_tuser),                    // input
  .axis_slave2_tready(axis_slave2_tready),                  // output
  .axis_slave2_tvalid(axis_slave2_tvalid),                  // input
  .axis_slave2_tdata(axis_slave2_tdata),                    // input [127:0]
  .axis_slave2_tlast(axis_slave2_tlast),                    // input
  .axis_slave2_tuser(axis_slave2_tuser),                    // input
  .pm_xtlh_block_tlp(pm_xtlh_block_tlp),                    // output
  .cfg_send_cor_err_mux(cfg_send_cor_err_mux),              // output
  .cfg_send_nf_err_mux(cfg_send_nf_err_mux),                // output
  .cfg_send_f_err_mux(cfg_send_f_err_mux),                  // output
  .cfg_sys_err_rc(cfg_sys_err_rc),                          // output
  .cfg_aer_rc_err_mux(cfg_aer_rc_err_mux),                  // output
  .radm_cpl_timeout(radm_cpl_timeout),                      // output
  .cfg_max_rd_req_size(cfg_max_rd_req_size),                // output [2:0]
  .cfg_bus_master_en(cfg_bus_master_en),                    // output
  .cfg_max_payload_size(cfg_max_payload_size),              // output [2:0]
  .cfg_ext_tag_en(cfg_ext_tag_en),                          // output
  .cfg_rcb(cfg_rcb),                                        // output
  .cfg_mem_space_en(cfg_mem_space_en),                      // output
  .cfg_pm_no_soft_rst(cfg_pm_no_soft_rst),                  // output
  .cfg_crs_sw_vis_en(cfg_crs_sw_vis_en),                    // output
  .cfg_no_snoop_en(cfg_no_snoop_en),                        // output
  .cfg_relax_order_en(cfg_relax_order_en),                  // output
  .cfg_tph_req_en(cfg_tph_req_en),                          // output [1:0]
  .cfg_pf_tph_st_mode(cfg_pf_tph_st_mode),                  // output [2:0]
  .cfg_pbus_num(cfg_pbus_num),                              // output [7:0]
  .cfg_pbus_dev_num(cfg_pbus_dev_num),                      // output [4:0]
  .rbar_ctrl_update(rbar_ctrl_update),                      // output
  .cfg_atomic_req_en(cfg_atomic_req_en),                    // output
  .radm_idle(radm_idle),                                    // output
  .radm_q_not_empty(radm_q_not_empty),                      // output
  .radm_qoverflow(radm_qoverflow),                          // output
  .diag_ctrl_bus(diag_ctrl_bus),                            // input [1:0]
  .dyn_debug_info_sel(dyn_debug_info_sel),                  // input [3:0]
  .cfg_link_auto_bw_mux(cfg_link_auto_bw_mux),              // output
  .cfg_bw_mgt_mux(cfg_bw_mgt_mux),                          // output
  .cfg_pme_mux(cfg_pme_mux),                                // output
  .debug_info_mux(debug_info_mux),                          // output [132:0]
  .app_ras_des_sd_hold_ltssm(app_ras_des_sd_hold_ltssm),    // input
  .app_ras_des_tba_ctrl(app_ras_des_tba_ctrl)               // input [1:0]
);
