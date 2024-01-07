-- Created by IP Generator (Version 2022.1 build 99559)
-- Instantiation Template
--
-- Insert the following codes into your VHDL file.
--   * Change the_instance_name to your own instance name.
--   * Change the net names in the port map.


COMPONENT ddr_test
  PORT (
    resetn : IN STD_LOGIC;
    ddr_init_done : OUT STD_LOGIC;
    ddrphy_clkin : OUT STD_LOGIC;
    pll_lock : OUT STD_LOGIC;
    axi_awaddr : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
    axi_awuser_ap : IN STD_LOGIC;
    axi_awuser_id : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    axi_awlen : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    axi_awready : OUT STD_LOGIC;
    axi_awvalid : IN STD_LOGIC;
    axi_wstrb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    axi_wready : OUT STD_LOGIC;
    axi_wusero_id : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    axi_wusero_last : OUT STD_LOGIC;
    axi_araddr : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
    axi_aruser_ap : IN STD_LOGIC;
    axi_aruser_id : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    axi_arlen : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    axi_arready : OUT STD_LOGIC;
    axi_arvalid : IN STD_LOGIC;
    axi_rdata : OUT STD_LOGIC_VECTOR(255 DOWNTO 0);
    axi_rid : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    axi_rlast : OUT STD_LOGIC;
    axi_rvalid : OUT STD_LOGIC;
    apb_clk : IN STD_LOGIC;
    apb_rst_n : IN STD_LOGIC;
    apb_sel : IN STD_LOGIC;
    apb_enable : IN STD_LOGIC;
    apb_addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    apb_write : IN STD_LOGIC;
    apb_ready : OUT STD_LOGIC;
    apb_wdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    apb_rdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    apb_int : OUT STD_LOGIC;
    debug_data : OUT STD_LOGIC_VECTOR(135 DOWNTO 0);
    debug_slice_state : OUT STD_LOGIC_VECTOR(51 DOWNTO 0);
    debug_calib_ctrl : OUT STD_LOGIC_VECTOR(21 DOWNTO 0);
    ck_dly_set_bin : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    force_ck_dly_en : IN STD_LOGIC;
    force_ck_dly_set_bin : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dll_step : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    dll_lock : OUT STD_LOGIC;
    init_read_clk_ctrl : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    init_slip_step : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    force_read_clk_ctrl : IN STD_LOGIC;
    ddrphy_gate_update_en : IN STD_LOGIC;
    update_com_val_err_flag : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    rd_fake_stop : IN STD_LOGIC;
    mem_rst_n : OUT STD_LOGIC;
    mem_ck : OUT STD_LOGIC;
    mem_ck_n : OUT STD_LOGIC;
    mem_cke : OUT STD_LOGIC;
    mem_cs_n : OUT STD_LOGIC;
    mem_ras_n : OUT STD_LOGIC;
    mem_cas_n : OUT STD_LOGIC;
    mem_we_n : OUT STD_LOGIC;
    mem_odt : OUT STD_LOGIC;
    mem_a : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
    mem_ba : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    mem_dqs : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    mem_dqs_n : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    mem_dq : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    mem_dm : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
  );
END COMPONENT;


the_instance_name : ddr_test
  PORT MAP (
    resetn => resetn,
    ddr_init_done => ddr_init_done,
    ddrphy_clkin => ddrphy_clkin,
    pll_lock => pll_lock,
    axi_awaddr => axi_awaddr,
    axi_awuser_ap => axi_awuser_ap,
    axi_awuser_id => axi_awuser_id,
    axi_awlen => axi_awlen,
    axi_awready => axi_awready,
    axi_awvalid => axi_awvalid,
    axi_wstrb => axi_wstrb,
    axi_wready => axi_wready,
    axi_wusero_id => axi_wusero_id,
    axi_wusero_last => axi_wusero_last,
    axi_araddr => axi_araddr,
    axi_aruser_ap => axi_aruser_ap,
    axi_aruser_id => axi_aruser_id,
    axi_arlen => axi_arlen,
    axi_arready => axi_arready,
    axi_arvalid => axi_arvalid,
    axi_rdata => axi_rdata,
    axi_rid => axi_rid,
    axi_rlast => axi_rlast,
    axi_rvalid => axi_rvalid,
    apb_clk => apb_clk,
    apb_rst_n => apb_rst_n,
    apb_sel => apb_sel,
    apb_enable => apb_enable,
    apb_addr => apb_addr,
    apb_write => apb_write,
    apb_ready => apb_ready,
    apb_wdata => apb_wdata,
    apb_rdata => apb_rdata,
    apb_int => apb_int,
    debug_data => debug_data,
    debug_slice_state => debug_slice_state,
    debug_calib_ctrl => debug_calib_ctrl,
    ck_dly_set_bin => ck_dly_set_bin,
    force_ck_dly_en => force_ck_dly_en,
    force_ck_dly_set_bin => force_ck_dly_set_bin,
    dll_step => dll_step,
    dll_lock => dll_lock,
    init_read_clk_ctrl => init_read_clk_ctrl,
    init_slip_step => init_slip_step,
    force_read_clk_ctrl => force_read_clk_ctrl,
    ddrphy_gate_update_en => ddrphy_gate_update_en,
    update_com_val_err_flag => update_com_val_err_flag,
    rd_fake_stop => rd_fake_stop,
    mem_rst_n => mem_rst_n,
    mem_ck => mem_ck,
    mem_ck_n => mem_ck_n,
    mem_cke => mem_cke,
    mem_cs_n => mem_cs_n,
    mem_ras_n => mem_ras_n,
    mem_cas_n => mem_cas_n,
    mem_we_n => mem_we_n,
    mem_odt => mem_odt,
    mem_a => mem_a,
    mem_ba => mem_ba,
    mem_dqs => mem_dqs,
    mem_dqs_n => mem_dqs_n,
    mem_dq => mem_dq,
    mem_dm => mem_dm
  );
