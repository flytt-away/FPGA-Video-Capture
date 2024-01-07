onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ddr_test_top_tb/user_zoom/clk
add wave -noupdate /ddr_test_top_tb/user_zoom/rstn
add wave -noupdate /ddr_test_top_tb/user_zoom/vs_in
add wave -noupdate /ddr_test_top_tb/user_zoom/hs_in
add wave -noupdate /ddr_test_top_tb/user_zoom/de_in
add wave -noupdate /ddr_test_top_tb/user_zoom/video_data_in
add wave -noupdate /ddr_test_top_tb/user_zoom/vs_out
add wave -noupdate /ddr_test_top_tb/user_zoom/hs_out
add wave -noupdate -color {Sky Blue} /ddr_test_top_tb/user_zoom/de_out
add wave -noupdate /ddr_test_top_tb/user_zoom/pix_data0
add wave -noupdate /ddr_test_top_tb/user_zoom/pix_data1
add wave -noupdate /ddr_test_top_tb/user_zoom/pix_data2
add wave -noupdate /ddr_test_top_tb/user_zoom/pix_data3
add wave -noupdate /ddr_test_top_tb/user_zoom/interpolation_cnt_state
add wave -noupdate /ddr_test_top_tb/user_zoom/interpolation_data_save
add wave -noupdate /ddr_test_top_tb/user_zoom/interpolation_data_save_flag
add wave -noupdate -radix unsigned /ddr_test_top_tb/user_zoom/interpolation_cnt
add wave -noupdate /ddr_test_top_tb/user_zoom/interpolation_data_state
add wave -noupdate /ddr_test_top_tb/user_zoom/r_ram0_wr_data
add wave -noupdate /ddr_test_top_tb/user_zoom/r_ram0_wr_addr
add wave -noupdate -color Magenta /ddr_test_top_tb/user_zoom/r_ram1_wr_data
add wave -noupdate -color Magenta /ddr_test_top_tb/user_zoom/r_ram1_wr_addr
add wave -noupdate /ddr_test_top_tb/user_zoom/r_ram0_wr_en
add wave -noupdate /ddr_test_top_tb/user_zoom/r_ram1_wr_en
add wave -noupdate /ddr_test_top_tb/user_zoom/interpolation_done0
add wave -noupdate /ddr_test_top_tb/user_zoom/interpolation_done1
add wave -noupdate -radix unsigned /ddr_test_top_tb/user_zoom/bilinear_interpolation_cnt
add wave -noupdate -radix unsigned /ddr_test_top_tb/user_zoom/bilinear_interpolation_flag
add wave -noupdate -radix unsigned /ddr_test_top_tb/user_zoom/r_ram0_rd_addr
add wave -noupdate -radix unsigned /ddr_test_top_tb/user_zoom/r_ram1_rd_addr
add wave -noupdate /ddr_test_top_tb/video_data_out
add wave -noupdate /ddr_test_top_tb/user_zoom/ram0_rd_data
add wave -noupdate /ddr_test_top_tb/user_zoom/ram1_rd_data
add wave -noupdate -color {Sky Blue} /ddr_test_top_tb/user_zoom/de_out
add wave -noupdate /ddr_test_top_tb/user_zoom/clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14699772 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 376
configure wave -valuecolwidth 100
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
WaveRestoreZoom {14248523 ps} {15565857 ps}
