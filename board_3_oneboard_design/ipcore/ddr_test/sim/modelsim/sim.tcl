if {[file exists work]} {
  file delete -force work  
}
vlib work
vmap work work


#set LIB_DIR  C:/pango/PDS_2022.1/ip/system_ip/ipsxb_hmic_s/ipsxb_hmic_eval/ipsxb_hmic_s/../../../../../arch/vendor/pango/verilog/simulation

set LIB_DIR  D:/FPGA/PANGOMICRO/PDS/PDS_2022.1/ip/system_ip/ipsxb_hmic_s/ipsxb_hmic_eval/ipsxb_hmic_s/../../../../../arch/vendor/pango/verilog/simulation

vlib work
vlog -sv -work work -mfcu -incr -f ../modelsim/sim_file_list.f -y $LIB_DIR +libext+.v +incdir+../../example_design/bench/mem/ 
#vsim -suppress 3486,3680,3781 +nowarn1 -c -sva -lib work ddr_test_top_tb -l sim.log
vsim -novopt -suppress 3486,3680,3781  -c ddr_test_top_tb -L work -l sim.log
do wave.do
#run 180us


