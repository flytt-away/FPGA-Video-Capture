// Created by IP Generator (Version 2022.1 build 99559)



`timescale 1 ps / 1 ps
module ddr_test_top_tb;

`include "../../example_design/bench/mem/ddr3_parameters.vh"


parameter real CLKIN_FREQ  = 50.0;


parameter PLL_REFCLK_IN_PERIOD = 1000000 / CLKIN_FREQ;


parameter MEM_ADDR_WIDTH = 15;

parameter MEM_BADDR_WIDTH = 3;

parameter MEM_DQ_WIDTH = 32;


parameter MEM_DM_WIDTH         = MEM_DQ_WIDTH/8;
parameter MEM_DQS_WIDTH        = MEM_DQ_WIDTH/8;
parameter MEM_NUM              = MEM_DQ_WIDTH/16;

reg                           pll_refclk_in    ;
reg                           free_clk         ;
reg                           ddr_rstn         ;
reg                           uart_rxd         ;
wire                          uart_txd         ;
reg                           grs_n            ; 
wire                          mem_rst_n        ; 
wire                          mem_ck           ;
wire                          mem_ck_n         ;
wire                          mem_cke          ;
wire                          mem_cs_n         ;
wire                          mem_ras_n        ;
wire                          mem_cas_n        ;
wire                          mem_we_n         ;
wire                          mem_odt          ;
wire [ MEM_ADDR_WIDTH-1:0]    mem_a            ;  
wire [MEM_BADDR_WIDTH-1:0]    mem_ba           ;  
wire [  MEM_DQS_WIDTH-1:0]    mem_dqs          ;  
wire [  MEM_DQS_WIDTH-1:0]    mem_dqs_n        ;  
wire [   MEM_DQ_WIDTH-1:0]    mem_dq           ;  
wire [   MEM_DM_WIDTH-1:0]    mem_dm           ;
wire [      ADDR_BITS-1:0]    mem_addr         ; 
wire                          dfi_init_complete;


test_ddr u_ddr(
    .ref_clk           (pll_refclk_in    ),
    .free_clk          (free_clk         ),
    .rst_board         (ddr_rstn         ),
    .pll_lock          (                 ),         
    .ddr_init_done     (dfi_init_complete),
    .uart_rxd          (uart_rxd         ),
    .uart_txd          (uart_txd         ),
    
    .mem_rst_n         (mem_rst_n        ),                       
    .mem_ck            (mem_ck           ),
    .mem_ck_n          (mem_ck_n         ),
    .mem_cke           (mem_cke          ),

    .mem_cs_n          (mem_cs_n         ),
 
    .mem_ras_n         (mem_ras_n        ),
    .mem_cas_n         (mem_cas_n        ),
    .mem_we_n          (mem_we_n         ), 
    .mem_odt           (mem_odt          ),
    .mem_a             (mem_a            ),   
    .mem_ba            (mem_ba           ),   
    .mem_dqs           (mem_dqs          ),
    .mem_dqs_n         (mem_dqs_n        ),
    .mem_dq            (mem_dq           ),
    .mem_dm            (mem_dm           ),
    
    .heart_beat_led    (                 ),
    .err_flag_led      (                 )

);

reg  [MEM_NUM:0]              mem_ck_dly;
reg  [MEM_NUM:0]              mem_ck_n_dly;

always @ (*)
begin
    mem_ck_dly[0]   <=  mem_ck;
    mem_ck_n_dly[0] <=  mem_ck_n;
end

assign mem_addr = {{(ADDR_BITS-MEM_ADDR_WIDTH){1'b0}},{mem_a}};

genvar gen_mem;                                                    
generate                                                         
for(gen_mem=0; gen_mem<MEM_NUM; gen_mem=gen_mem+1) begin   : i_mem 
    
    always @ (*)
    begin
        mem_ck_dly[gen_mem+1] <= #50 mem_ck_dly[gen_mem];
        mem_ck_n_dly[gen_mem+1] <= #50 mem_ck_n_dly[gen_mem];
    end
 
    ddr3      mem_core (
    
    .rst_n             (mem_rst_n                        ),
    .ck                (mem_ck_dly[gen_mem+1]            ),
    .ck_n              (mem_ck_n_dly[gen_mem+1]          ),

    .cs_n              (mem_cs_n                         ),

    .addr              (mem_addr                         ),
    .dq                (mem_dq[16*gen_mem+15:16*gen_mem] ),
    .dqs               (mem_dqs[2*gen_mem+1:2*gen_mem]   ),
    .dqs_n             (mem_dqs_n[2*gen_mem+1:2*gen_mem] ),
    .dm_tdqs           (mem_dm[2*gen_mem+1:2*gen_mem]    ),
    .tdqs_n            (                                 ),
    .cke               (mem_cke                          ),
    .odt               (mem_odt                          ),
    .ras_n             (mem_ras_n                        ),
    .cas_n             (mem_cas_n                        ),
    .we_n              (mem_we_n                         ),
    .ba                (mem_ba                           )
    );
end     
endgenerate


/********************clk and init******************/

always #(PLL_REFCLK_IN_PERIOD / 2)  pll_refclk_in = ~pll_refclk_in;

always #(20000 / 2)  free_clk = ~free_clk;


initial begin

#1 
pll_refclk_in = 0;
free_clk = 0;

//default input from keyboard
ddr_rstn = 1'b1;
uart_rxd = 1'b1;

end
/*******************end of clk and init*******************/


//GTP_GRS I_GTP_GRS(
GTP_GRS GRS_INST(
		.GRS_N (grs_n)
	);
initial begin
grs_n = 1'b0;
#5000 grs_n = 1'b1;
end

initial begin

//reset the bu_top
#10000 ddr_rstn = 1'b0;
#50000 ddr_rstn = 1'b1;
$display("%t keyboard reset sequence finished!", $time);

@ (posedge dfi_init_complete);
$display("%t dfi_init_complete is high now!", $time);
#100000000;
$finish;
end

initial 
begin
 $fsdbDumpfile("ddr_test_top_tb.fsdb");
 $fsdbDumpvars(0,"ddr_test_top_tb");
end

endmodule 

