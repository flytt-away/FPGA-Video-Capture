-- Created by IP Generator (Version 2022.1 build 99559)
-- Instantiation Template
--
-- Insert the following codes into your VHDL file.
--   * Change the_instance_name to your own instance name.
--   * Change the net names in the port map.


COMPONENT pcie_test
  PORT (
    free_clk : IN STD_LOGIC;
    pclk : OUT STD_LOGIC;
    pclk_div2 : OUT STD_LOGIC;
    ref_clk : OUT STD_LOGIC;
    ref_clk_n : IN STD_LOGIC;
    ref_clk_p : IN STD_LOGIC;
    button_rst_n : IN STD_LOGIC;
    power_up_rst_n : IN STD_LOGIC;
    perst_n : IN STD_LOGIC;
    core_rst_n : OUT STD_LOGIC;
    smlh_link_up : OUT STD_LOGIC;
    rdlh_link_up : OUT STD_LOGIC;
    smlh_ltssm_state : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    p_sel : IN STD_LOGIC;
    p_strb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    p_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    p_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    p_ce : IN STD_LOGIC;
    p_we : IN STD_LOGIC;
    p_rdy : OUT STD_LOGIC;
    p_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    rxn : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    rxp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    txn : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    txp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    pcs_nearend_loop : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    pma_nearend_ploop : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    pma_nearend_sloop : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    axis_master_tvalid : OUT STD_LOGIC;
    axis_master_tready : IN STD_LOGIC;
    axis_master_tdata : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
    axis_master_tkeep : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    axis_master_tlast : OUT STD_LOGIC;
    axis_master_tuser : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    axis_slave0_tready : OUT STD_LOGIC;
    axis_slave0_tvalid : IN STD_LOGIC;
    axis_slave0_tdata : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    axis_slave0_tlast : IN STD_LOGIC;
    axis_slave0_tuser : IN STD_LOGIC;
    axis_slave1_tready : OUT STD_LOGIC;
    axis_slave1_tvalid : IN STD_LOGIC;
    axis_slave1_tdata : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    axis_slave1_tlast : IN STD_LOGIC;
    axis_slave1_tuser : IN STD_LOGIC;
    axis_slave2_tready : OUT STD_LOGIC;
    axis_slave2_tvalid : IN STD_LOGIC;
    axis_slave2_tdata : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    axis_slave2_tlast : IN STD_LOGIC;
    axis_slave2_tuser : IN STD_LOGIC;
    pm_xtlh_block_tlp : OUT STD_LOGIC;
    cfg_send_cor_err_mux : OUT STD_LOGIC;
    cfg_send_nf_err_mux : OUT STD_LOGIC;
    cfg_send_f_err_mux : OUT STD_LOGIC;
    cfg_sys_err_rc : OUT STD_LOGIC;
    cfg_aer_rc_err_mux : OUT STD_LOGIC;
    radm_cpl_timeout : OUT STD_LOGIC;
    cfg_max_rd_req_size : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    cfg_bus_master_en : OUT STD_LOGIC;
    cfg_max_payload_size : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    cfg_ext_tag_en : OUT STD_LOGIC;
    cfg_rcb : OUT STD_LOGIC;
    cfg_mem_space_en : OUT STD_LOGIC;
    cfg_pm_no_soft_rst : OUT STD_LOGIC;
    cfg_crs_sw_vis_en : OUT STD_LOGIC;
    cfg_no_snoop_en : OUT STD_LOGIC;
    cfg_relax_order_en : OUT STD_LOGIC;
    cfg_tph_req_en : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    cfg_pf_tph_st_mode : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    cfg_pbus_num : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    cfg_pbus_dev_num : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    rbar_ctrl_update : OUT STD_LOGIC;
    cfg_atomic_req_en : OUT STD_LOGIC;
    radm_idle : OUT STD_LOGIC;
    radm_q_not_empty : OUT STD_LOGIC;
    radm_qoverflow : OUT STD_LOGIC;
    diag_ctrl_bus : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    dyn_debug_info_sel : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_link_auto_bw_mux : OUT STD_LOGIC;
    cfg_bw_mgt_mux : OUT STD_LOGIC;
    cfg_pme_mux : OUT STD_LOGIC;
    debug_info_mux : OUT STD_LOGIC_VECTOR(132 DOWNTO 0);
    app_ras_des_sd_hold_ltssm : IN STD_LOGIC;
    app_ras_des_tba_ctrl : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
  );
END COMPONENT;


the_instance_name : pcie_test
  PORT MAP (
    free_clk => free_clk,
    pclk => pclk,
    pclk_div2 => pclk_div2,
    ref_clk => ref_clk,
    ref_clk_n => ref_clk_n,
    ref_clk_p => ref_clk_p,
    button_rst_n => button_rst_n,
    power_up_rst_n => power_up_rst_n,
    perst_n => perst_n,
    core_rst_n => core_rst_n,
    smlh_link_up => smlh_link_up,
    rdlh_link_up => rdlh_link_up,
    smlh_ltssm_state => smlh_ltssm_state,
    p_sel => p_sel,
    p_strb => p_strb,
    p_addr => p_addr,
    p_wdata => p_wdata,
    p_ce => p_ce,
    p_we => p_we,
    p_rdy => p_rdy,
    p_rdata => p_rdata,
    rxn => rxn,
    rxp => rxp,
    txn => txn,
    txp => txp,
    pcs_nearend_loop => pcs_nearend_loop,
    pma_nearend_ploop => pma_nearend_ploop,
    pma_nearend_sloop => pma_nearend_sloop,
    axis_master_tvalid => axis_master_tvalid,
    axis_master_tready => axis_master_tready,
    axis_master_tdata => axis_master_tdata,
    axis_master_tkeep => axis_master_tkeep,
    axis_master_tlast => axis_master_tlast,
    axis_master_tuser => axis_master_tuser,
    axis_slave0_tready => axis_slave0_tready,
    axis_slave0_tvalid => axis_slave0_tvalid,
    axis_slave0_tdata => axis_slave0_tdata,
    axis_slave0_tlast => axis_slave0_tlast,
    axis_slave0_tuser => axis_slave0_tuser,
    axis_slave1_tready => axis_slave1_tready,
    axis_slave1_tvalid => axis_slave1_tvalid,
    axis_slave1_tdata => axis_slave1_tdata,
    axis_slave1_tlast => axis_slave1_tlast,
    axis_slave1_tuser => axis_slave1_tuser,
    axis_slave2_tready => axis_slave2_tready,
    axis_slave2_tvalid => axis_slave2_tvalid,
    axis_slave2_tdata => axis_slave2_tdata,
    axis_slave2_tlast => axis_slave2_tlast,
    axis_slave2_tuser => axis_slave2_tuser,
    pm_xtlh_block_tlp => pm_xtlh_block_tlp,
    cfg_send_cor_err_mux => cfg_send_cor_err_mux,
    cfg_send_nf_err_mux => cfg_send_nf_err_mux,
    cfg_send_f_err_mux => cfg_send_f_err_mux,
    cfg_sys_err_rc => cfg_sys_err_rc,
    cfg_aer_rc_err_mux => cfg_aer_rc_err_mux,
    radm_cpl_timeout => radm_cpl_timeout,
    cfg_max_rd_req_size => cfg_max_rd_req_size,
    cfg_bus_master_en => cfg_bus_master_en,
    cfg_max_payload_size => cfg_max_payload_size,
    cfg_ext_tag_en => cfg_ext_tag_en,
    cfg_rcb => cfg_rcb,
    cfg_mem_space_en => cfg_mem_space_en,
    cfg_pm_no_soft_rst => cfg_pm_no_soft_rst,
    cfg_crs_sw_vis_en => cfg_crs_sw_vis_en,
    cfg_no_snoop_en => cfg_no_snoop_en,
    cfg_relax_order_en => cfg_relax_order_en,
    cfg_tph_req_en => cfg_tph_req_en,
    cfg_pf_tph_st_mode => cfg_pf_tph_st_mode,
    cfg_pbus_num => cfg_pbus_num,
    cfg_pbus_dev_num => cfg_pbus_dev_num,
    rbar_ctrl_update => rbar_ctrl_update,
    cfg_atomic_req_en => cfg_atomic_req_en,
    radm_idle => radm_idle,
    radm_q_not_empty => radm_q_not_empty,
    radm_qoverflow => radm_qoverflow,
    diag_ctrl_bus => diag_ctrl_bus,
    dyn_debug_info_sel => dyn_debug_info_sel,
    cfg_link_auto_bw_mux => cfg_link_auto_bw_mux,
    cfg_bw_mgt_mux => cfg_bw_mgt_mux,
    cfg_pme_mux => cfg_pme_mux,
    debug_info_mux => debug_info_mux,
    app_ras_des_sd_hold_ltssm => app_ras_des_sd_hold_ltssm,
    app_ras_des_tba_ctrl => app_ras_des_tba_ctrl
  );
