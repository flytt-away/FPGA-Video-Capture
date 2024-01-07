onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ddr_test_top_tb/u_test_ddr/PROJECT_MODE
add wave -noupdate /ddr_test_top_tb/u_test_ddr/ref_clk
add wave -noupdate /ddr_test_top_tb/u_test_ddr/ddr_ip_clk
add wave -noupdate /ddr_test_top_tb/u_test_ddr/ddr_init_done
add wave -noupdate /ddr_test_top_tb/u_test_ddr/ddr_ip_rst_n
add wave -noupdate /ddr_test_top_tb/u_test_ddr/pix_clk_in
add wave -noupdate /ddr_test_top_tb/u_test_ddr/rst_board
add wave -noupdate /ddr_test_top_tb/u_test_ddr/hdmi_rst
add wave -noupdate /ddr_test_top_tb/u_test_ddr/rstn_1ms
add wave -noupdate /ddr_test_top_tb/u_test_ddr/hdmi_int_led
add wave -noupdate -expand -group HDMI_VIDEO_IN /ddr_test_top_tb/u_test_ddr/vs_in
add wave -noupdate -expand -group HDMI_VIDEO_IN /ddr_test_top_tb/u_test_ddr/de_in
add wave -noupdate -expand -group HDMI_VIDEO_IN -radix unsigned /ddr_test_top_tb/u_test_ddr/de_in_cnt
add wave -noupdate -expand -group HDMI_VIDEO_IN /ddr_test_top_tb/u_test_ddr/rgb_in
add wave -noupdate -expand -group ZOOM_DATA /ddr_test_top_tb/u_test_ddr/vs_in
add wave -noupdate -expand -group ZOOM_DATA /ddr_test_top_tb/u_test_ddr/zoom_de_out
add wave -noupdate -expand -group ZOOM_DATA /ddr_test_top_tb/u_test_ddr/zoom_de_in_cnt
add wave -noupdate -expand -group ZOOM_DATA /ddr_test_top_tb/u_test_ddr/zoom_data_out
add wave -noupdate -expand -group CMOS1 /ddr_test_top_tb/u_test_ddr/cmos1_pclk
add wave -noupdate -expand -group CMOS1 /ddr_test_top_tb/u_test_ddr/cmos1_href
add wave -noupdate -expand -group CMOS1 /ddr_test_top_tb/u_test_ddr/cmos1_vsync
add wave -noupdate -expand -group CMOS1 /ddr_test_top_tb/u_test_ddr/cmos1_data
add wave -noupdate -expand -group CMOS1 /ddr_test_top_tb/u_test_ddr/cmos1_pclk_16bit
add wave -noupdate -expand -group CMOS1 /ddr_test_top_tb/u_test_ddr/sim/cmos1_8_16bit/pixel_clk
add wave -noupdate -expand -group CMOS1 /ddr_test_top_tb/u_test_ddr/cmos1_href_16bit
add wave -noupdate -expand -group CMOS1 /ddr_test_top_tb/u_test_ddr/cmos1_d_16bit
add wave -noupdate -expand -group CMOS2 /ddr_test_top_tb/u_test_ddr/cmos2_pclk
add wave -noupdate -expand -group CMOS2 /ddr_test_top_tb/u_test_ddr/cmos2_d_d0
add wave -noupdate -expand -group CMOS2 /ddr_test_top_tb/u_test_ddr/cmos2_href_d0
add wave -noupdate -expand -group CMOS2 /ddr_test_top_tb/u_test_ddr/cmos2_vsync_d0
add wave -noupdate -expand -group CMOS2 /ddr_test_top_tb/u_test_ddr/cmos2_data
add wave -noupdate -expand -group CMOS2 /ddr_test_top_tb/u_test_ddr/cmos2_pclk_16bit
add wave -noupdate -expand -group CMOS2 /ddr_test_top_tb/u_test_ddr/cmos2_d_16bit
add wave -noupdate -expand -group CMOS2 /ddr_test_top_tb/u_test_ddr/cmos2_href_16bit
add wave -noupdate -expand -group AXI_WRITE /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M_AXI_ACLK
add wave -noupdate -expand -group AXI_WRITE /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/arbitration_wr_state
add wave -noupdate -expand -group AXI_WRITE -expand -group AXI_Master_Write /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M1_AXI_AWVALID
add wave -noupdate -expand -group AXI_WRITE -expand -group AXI_Master_Write /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M1_AXI_AWREADY
add wave -noupdate -expand -group AXI_WRITE -expand -group AXI_Master_Write /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M1_AXI_AWADDR
add wave -noupdate -expand -group AXI_WRITE -expand -group AXI_Master_Write /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M1_AXI_WDATA
add wave -noupdate -expand -group AXI_WRITE -expand -group AXI_Master_Write /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M1_AXI_WLAST
add wave -noupdate -expand -group AXI_WRITE -expand -group AXI_Master_Write /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M1_AXI_WREADY
add wave -noupdate -expand -group AXI_WRITE -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/u_axi_full_m0/w_fifo_state
add wave -noupdate -expand -group AXI_WRITE -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/wfifo0_rd_water_level
add wave -noupdate -expand -group AXI_WRITE -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/u_axi_full_m0/r_wr_addr_cnt
add wave -noupdate -expand -group AXI_WRITE -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M0_AXI_AWVALID
add wave -noupdate -expand -group AXI_WRITE -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M0_AXI_AWREADY
add wave -noupdate -expand -group AXI_WRITE -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M0_AXI_AWADDR
add wave -noupdate -expand -group AXI_WRITE -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M0_AXI_WDATA
add wave -noupdate -expand -group AXI_WRITE -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M0_AXI_WREADY
add wave -noupdate -expand -group AXI_WRITE -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M0_AXI_WLAST
add wave -noupdate -expand -group AXI_WRITE -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/u_axi_full_m0/r_wfifo_rd_req
add wave -noupdate -expand -group AXI_WRITE -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/u_axi_full_m0/r_wfifo_pre_rd_req
add wave -noupdate -expand -group AXI_WRITE -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/u_axi_full_m0/r_wfifo_pre_rd_flag
add wave -noupdate -expand -group AXI_WRITE -expand -group M1 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M1_AXI_WDATA
add wave -noupdate -expand -group AXI_WRITE -expand -group M1 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/u_axi_full_m1/r_wr_addr_cnt
add wave -noupdate -expand -group AXI_WRITE -expand -group M1 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/wfifo1_rd_water_level
add wave -noupdate -expand -group AXI_WRITE -expand -group M1 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M1_AXI_AWVALID
add wave -noupdate -expand -group AXI_WRITE -expand -group M1 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M1_AXI_AWREADY
add wave -noupdate -expand -group AXI_WRITE -expand -group M1 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M1_AXI_AWADDR
add wave -noupdate -expand -group AXI_WRITE -expand -group M1 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M1_AXI_WLAST
add wave -noupdate -expand -group AXI_WRITE -expand -group M1 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M1_AXI_WREADY
add wave -noupdate -expand -group AXI_WRITE -expand -group M2 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/wfifo2_rd_water_level
add wave -noupdate -expand -group AXI_WRITE -expand -group M2 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/u_axi_full_m2/r_wr_addr_cnt
add wave -noupdate -expand -group AXI_WRITE -expand -group M2 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M2_AXI_WDATA
add wave -noupdate -expand -group AXI_WRITE -expand -group M2 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M2_AXI_AWVALID
add wave -noupdate -expand -group AXI_WRITE -expand -group M2 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M2_AXI_AWREADY
add wave -noupdate -expand -group AXI_WRITE -expand -group M2 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M2_AXI_AWADDR
add wave -noupdate -expand -group AXI_WRITE -expand -group M2 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M2_AXI_WLAST
add wave -noupdate -expand -group AXI_WRITE -expand -group M2 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M2_AXI_WREADY
add wave -noupdate -expand -group AXI_WRITE -expand -group M3 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/wfifo3_rd_water_level
add wave -noupdate -expand -group AXI_WRITE -expand -group M3 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/u_axi_full_m3/r_wr_addr_cnt
add wave -noupdate -expand -group AXI_WRITE -expand -group M3 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M3_AXI_WDATA
add wave -noupdate -expand -group AXI_WRITE -expand -group M3 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M3_AXI_AWVALID
add wave -noupdate -expand -group AXI_WRITE -expand -group M3 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M3_AXI_AWREADY
add wave -noupdate -expand -group AXI_WRITE -expand -group M3 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M3_AXI_AWADDR
add wave -noupdate -expand -group AXI_WRITE -expand -group M3 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M3_AXI_WLAST
add wave -noupdate -expand -group AXI_WRITE -expand -group M3 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M3_AXI_WREADY
add wave -noupdate -expand -group Write_done /ddr_test_top_tb/u_test_ddr/fram0_done
add wave -noupdate -expand -group Write_done /ddr_test_top_tb/u_test_ddr/fram1_done
add wave -noupdate -expand -group Write_done /ddr_test_top_tb/u_test_ddr/fram2_done
add wave -noupdate -expand -group Write_done /ddr_test_top_tb/u_test_ddr/fram3_done
add wave -noupdate -expand -group AXI_READ /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M_AXI_ACLK
add wave -noupdate -expand -group AXI_READ /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/arbitration_rd_state
add wave -noupdate -expand -group AXI_READ -group AXI_Master_Read /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M_AXI_ARADDR
add wave -noupdate -expand -group AXI_READ -group AXI_Master_Read /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M_AXI_ARVALID
add wave -noupdate -expand -group AXI_READ -group AXI_Master_Read /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M_AXI_ARREADY
add wave -noupdate -expand -group AXI_READ -group AXI_Master_Read /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M_AXI_RVALID
add wave -noupdate -expand -group AXI_READ -group AXI_Master_Read /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M_AXI_RLAST
add wave -noupdate -expand -group AXI_READ -group AXI_Master_Read /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M_AXI_RDATA
add wave -noupdate -expand -group AXI_READ -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M0_AXI_ARVALID
add wave -noupdate -expand -group AXI_READ -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/rfifo0_wr_water_level
add wave -noupdate -expand -group AXI_READ -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/u_axi_full_m0/r_rd_addr_cnt
add wave -noupdate -expand -group AXI_READ -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M0_AXI_ARREADY
add wave -noupdate -expand -group AXI_READ -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M0_AXI_ARADDR
add wave -noupdate -expand -group AXI_READ -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M0_AXI_RDATA
add wave -noupdate -expand -group AXI_READ -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M0_AXI_RVALID
add wave -noupdate -expand -group AXI_READ -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M0_AXI_RLAST
add wave -noupdate -expand -group AXI_READ -expand -group M0 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/u_axi_full_m0/r_fifo_state
add wave -noupdate -expand -group AXI_READ -group M1 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M1_AXI_ARVALID
add wave -noupdate -expand -group AXI_READ -group M1 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/rfifo1_wr_water_level
add wave -noupdate -expand -group AXI_READ -group M1 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/u_axi_full_m1/r_wr_addr_cnt
add wave -noupdate -expand -group AXI_READ -group M1 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M1_AXI_ARREADY
add wave -noupdate -expand -group AXI_READ -group M1 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M1_AXI_ARADDR
add wave -noupdate -expand -group AXI_READ -group M1 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M1_AXI_RDATA
add wave -noupdate -expand -group AXI_READ -group M1 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M1_AXI_RLAST
add wave -noupdate -expand -group AXI_READ -group M1 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M1_AXI_RVALID
add wave -noupdate -expand -group AXI_READ -group M2 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M2_AXI_ARVALID
add wave -noupdate -expand -group AXI_READ -group M2 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/rfifo2_wr_water_level
add wave -noupdate -expand -group AXI_READ -group M2 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/u_axi_full_m2/r_rd_addr_cnt
add wave -noupdate -expand -group AXI_READ -group M2 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M2_AXI_ARREADY
add wave -noupdate -expand -group AXI_READ -group M2 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M2_AXI_ARADDR
add wave -noupdate -expand -group AXI_READ -group M2 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M2_AXI_RDATA
add wave -noupdate -expand -group AXI_READ -group M2 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M2_AXI_RLAST
add wave -noupdate -expand -group AXI_READ -group M2 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M2_AXI_RVALID
add wave -noupdate -expand -group AXI_READ -group M3 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M3_AXI_ARVALID
add wave -noupdate -expand -group AXI_READ -group M3 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/rfifo3_wr_water_level
add wave -noupdate -expand -group AXI_READ -group M3 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/u_axi_full_m3/r_rd_addr_cnt
add wave -noupdate -expand -group AXI_READ -group M3 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M3_AXI_ARREADY
add wave -noupdate -expand -group AXI_READ -group M3 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M3_AXI_ARADDR
add wave -noupdate -expand -group AXI_READ -group M3 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M3_AXI_RDATA
add wave -noupdate -expand -group AXI_READ -group M3 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M3_AXI_RLAST
add wave -noupdate -expand -group AXI_READ -group M3 /ddr_test_top_tb/u_test_ddr/user_axi_m_arbitration/M3_AXI_RVALID
add wave -noupdate -expand -group HDMI_OUT /ddr_test_top_tb/u_test_ddr/ddr_ip_rst_n
add wave -noupdate -expand -group HDMI_OUT /ddr_test_top_tb/u_test_ddr/fram0_done
add wave -noupdate -expand -group HDMI_OUT /ddr_test_top_tb/u_test_ddr/fram1_done
add wave -noupdate -expand -group HDMI_OUT /ddr_test_top_tb/u_test_ddr/fram2_done
add wave -noupdate -expand -group HDMI_OUT /ddr_test_top_tb/u_test_ddr/fram3_done
add wave -noupdate -expand -group HDMI_OUT /ddr_test_top_tb/u_test_ddr/video_pre_rd_flag
add wave -noupdate -expand -group HDMI_OUT /ddr_test_top_tb/u_test_ddr/pix_clk_out
add wave -noupdate -expand -group HDMI_OUT /ddr_test_top_tb/u_test_ddr/r_vs_out
add wave -noupdate -expand -group HDMI_OUT /ddr_test_top_tb/u_test_ddr/r_de_out
add wave -noupdate -expand -group HDMI_OUT /ddr_test_top_tb/u_test_ddr/r_r_out
add wave -noupdate -expand -group HDMI_OUT /ddr_test_top_tb/u_test_ddr/r_g_out
add wave -noupdate -expand -group HDMI_OUT /ddr_test_top_tb/u_test_ddr/r_b_out
add wave -noupdate -expand -group HDMI_OUT /ddr_test_top_tb/u_test_ddr/video0_rd_en
add wave -noupdate -expand -group HDMI_OUT /ddr_test_top_tb/u_test_ddr/video1_rd_en
add wave -noupdate -expand -group HDMI_OUT /ddr_test_top_tb/u_test_ddr/video2_rd_en
add wave -noupdate -expand -group HDMI_OUT /ddr_test_top_tb/u_test_ddr/video3_rd_en
add wave -noupdate -expand -group HDMI_OUT /ddr_test_top_tb/u_test_ddr/x_act
add wave -noupdate -expand -group HDMI_OUT /ddr_test_top_tb/u_test_ddr/y_act
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5303750000 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 316
configure wave -valuecolwidth 181
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1000000
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 fs} {49122088900 fs}
