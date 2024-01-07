+define+IPSL_PCIE_SPEEDUP_SIM
+define+IPML_HSST_SPEEDUP_SIM
+define+DWC_DISABLE_CDC_METHOD_REPORTING
../../example_design/bench/pango_pcie_top_tb.v
../../example_design/bench/pango_pcie_top.v

../../example_design/rtl/ipsl_expd_apb_mux.v

../../example_design/bench/pango_pcie_top_sim.v
../../example_design/bench/ipsl_pcie_wrap_v1_3_sim.v

../../example_design/rtl/uart2apb_32bit/pgr_apb_ctr_32bit.v
../../example_design/rtl/uart2apb_32bit/pgr_apb_mif_32bit.v
../../example_design/rtl/uart2apb_32bit/pgr_clk_gen_32bit.v
../../example_design/rtl/uart2apb_32bit/pgr_cmd_parser_32bit.v
../../example_design/rtl/uart2apb_32bit/pgr_fifo_top_32bit.v
../../example_design/rtl/uart2apb_32bit/pgr_uart2apb_top_32bit.v
../../example_design/rtl/uart2apb_32bit/pgr_uart_rx_32bit.v
../../example_design/rtl/uart2apb_32bit/pgr_uart_top_32bit.v
../../example_design/rtl/uart2apb_32bit/pgr_uart_tx_32bit.v
../../example_design/rtl/uart2apb_32bit/fifo/pgm_distributed_fifo_ctr_v1_0.v
../../example_design/rtl/uart2apb_32bit/fifo/pgm_distributed_fifo_v1_1.v
../../example_design/rtl/uart2apb_32bit/fifo/pgm_distributed_sdpram_v1_1.v
../../example_design/rtl/uart2apb_32bit/fifo/pgr_prefetch_fifo.v
../../example_design/rtl/uart2apb_32bit/rstn_sync_32bit.v

../../example_design/rtl/ipsl_pcie_cfg_ctrl/rtl/ipsl_pcie_cfg_ctrl.v
../../example_design/rtl/ipsl_pcie_cfg_ctrl/rtl/ipsl_pcie_cfg_ctrl_apb.v
../../example_design/rtl/ipsl_pcie_cfg_ctrl/rtl/ipsl_pcie_cfg_trans.v

//dma
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipsl_pcie_dma.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/pgs_pciex4_prefetch_fifo_v1_2.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/fifo/pgs_pciex4_fifo_v1_2.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/fifo/pgs_pciex4_fifo_ctrl.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/fifo/ipm_distributed_sdpram_v1_2_distributed_fifo.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipm_distributed_sdpram_v1_2.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipsl_pcie_dma_ram/ipsl_pcie_dma_ram.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipsl_pcie_dma_ram/rtl/ipml_sdpram_v1_5_ipsl_pcie_dma_ram.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipsl_pcie_dma_controller.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipsl_pcie_dma_cpld_tx_ctrl.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipsl_pcie_dma_mrd_tx_ctrl.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipsl_pcie_dma_mwr_tx_ctrl.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipsl_pcie_dma_rx_cpld_wr_ctrl.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipsl_pcie_dma_rx_mwr_wr_ctrl.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipsl_pcie_dma_wr_ctrl.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipsl_pcie_dma_tlp_rcv.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipsl_pcie_dma_rx_top.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipsl_pcie_dma_tx_top.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipsl_pcie_dma_tlp_tx_mux.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipsl_pcie_dma_tx_cpld_rd_ctrl.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipsl_pcie_dma_tx_mwr_rd_ctrl.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipsl_pcie_dma_rd_ctrl.v
../../example_design/rtl/ipsl_pcie_dma_ctrl/ipsl_pcie_reg.v

../../rtl/ipml_pcie_hsst/rtl/ipml_hsst_rst/ipml_hsst_fifo_clr_v1_0.v
../../rtl/ipml_pcie_hsst/rtl/ipml_hsst_rst/ipml_hsst_lane_powerup_v1_0.v
../../rtl/ipml_pcie_hsst/rtl/ipml_hsst_rst/ipml_hsst_pll_rst_fsm_v1_0.v
../../rtl/ipml_pcie_hsst/rtl/ipml_hsst_rst/ipml_hsst_rst_debounce_v1_0.v
../../rtl/ipml_pcie_hsst/rtl/ipml_hsst_rst/ipml_hsst_rst_pll_v1_0.v
../../rtl/ipml_pcie_hsst/rtl/ipml_hsst_rst/ipml_hsst_rst_rx_v1_1.v
../../rtl/ipml_pcie_hsst/rtl/ipml_hsst_rst/ipml_hsst_rst_sync_v1_0.v
../../rtl/ipml_pcie_hsst/rtl/ipml_hsst_rst/ipml_hsst_rst_tx_v1_0.v
../../rtl/ipml_pcie_hsst/rtl/ipml_hsst_rst/ipml_hsst_rst_v1_1.v
../../rtl/ipml_pcie_hsst/rtl/ipml_hsst_rst/ipml_hsst_rst_wtchdg_v1_0.v
../../rtl/ipml_pcie_hsst/rtl/ipml_hsst_rst/ipml_hsst_rxlane_rst_fsm_v1_1.v
../../rtl/ipml_pcie_hsst/rtl/ipml_hsst_rst/ipml_hsst_txlane_rst_fsm_v1_0.v

../../rtl/ipml_pcie_hsst/rtl/ipml_pcie_hsst_x1_wrapper_v1_3e.v
../../rtl/ipml_pcie_hsst/rtl/ipml_pcie_hsst_x2_wrapper_v1_3e.v
../../rtl/ipml_pcie_hsst/rtl/ipml_pcie_hsst_x4_wrapper_v1_3e.v
../../rtl/ipml_pcie_hsst/ipml_pcie_hsst_x1_top.v
../../rtl/ipml_pcie_hsst/ipml_pcie_hsst_x2_top.v
../../rtl/ipml_pcie_hsst/ipml_pcie_hsst_x4_top.v

../../rtl/ipsl_pcie_pipe/hsstl_phy_mac_rdata_proc.v
../../rtl/ipsl_pcie_pipe/hsst_rst_cross_sync_v1_0.v
../../rtl/ipsl_pcie_pipe/hsst_rst_debounce_v1_0.v
../../rtl/ipsl_pcie_pipe/hsst_rst_wtchdg_v1_0.v
../../rtl/ipsl_pcie_pipe/hsstl_rst4mcrsw_rx_init_v1_0.v
../../rtl/ipsl_pcie_pipe/hsstl_rst4mcrsw_rx_rst_fsm_v1_0.v
../../rtl/ipsl_pcie_pipe/hsstl_rst4mcrsw_rx_rst_initfsm_v1_0.v
../../rtl/ipsl_pcie_pipe/hsstl_rst4mcrsw_rx_v1_0.v
../../rtl/ipsl_pcie_pipe/hsstl_rst4mcrsw_tx_rst_fsm_v1_1.v
../../rtl/ipsl_pcie_pipe/hsstl_rst4mcrsw_tx_v1_0.v
../../rtl/ipsl_pcie_pipe/hsstl_rst4mcrsw_v1_0.v

../../rtl/ipsl_pcie_ext_ram/ipsl_pcie_ext_rcvd_ram/ipsl_pcie_ext_rcvd_ram.v
../../rtl/ipsl_pcie_ext_ram/ipsl_pcie_ext_rcvd_ram/rtl/ipml_sdpram_v1_5_ipsl_pcie_ext_rcvd_ram.v
../../rtl/ipsl_pcie_ext_ram/ipsl_pcie_ext_rcvh_ram/ipsl_pcie_ext_rcvh_ram.v
../../rtl/ipsl_pcie_ext_ram/ipsl_pcie_ext_rcvh_ram/rtl/ipml_sdpram_v1_5_ipsl_pcie_ext_rcvh_ram.v
../../rtl/ipsl_pcie_ext_ram/ipsl_pcie_retryd_ram/ipsl_pcie_retryd_ram.v
../../rtl/ipsl_pcie_ext_ram/ipsl_pcie_retryd_ram/rtl/ipml_spram_v1_4_ipsl_pcie_retryd_ram.v
../../rtl/ipsl_pcie_apb_cross_v1_0.v
../../rtl/ipsl_pcie_apb_mux_v1_1.v
../../rtl/ipsl_pcie_apb2dbi_v1_0.v
../../rtl/ipsl_pcie_cfg_init_v1_3.v
../../rtl/ipsl_pcie_hard_ctrl_v1_3.v
../../rtl/ipsl_pcie_seio_intf_v1_0.v
../../rtl/ipsl_pcie_soft_phy_v1_2a.v
../../rtl/ipsl_pcie_sync_v1_0.v
../../rtl/ipsl_pcie_top_v1_3.v

../../pcie_test.v

