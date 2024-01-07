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
reg 				  pix_clk_in   ;
wire [7:0]		      r_in	       ;
wire [7:0]		      g_in	       ;
wire [7:0]		      b_in	       ;
wire				  vs_in		   ;
wire				  de_in		   ;
wire				  hs_in		   ;
wire [15 : 0]			rgb_in;
wire				  pix_clk_out  ;
wire [7:0]		      r_out	       ;
wire [7:0]		      g_out	       ;
wire [7:0]		      b_out	       ;
wire				  vs_out		   ;
wire				  de_out		   ;
wire				  hs_out		   ;
wire [15:0]			  video_data_out;

wire 				  fram0_done  ;
wire 				  fram1_done  ;
wire 				  fram2_done  ;
wire 				  fram3_done  ;

wire 				  hdmi_rst     ;
wire 				  iic_tx_scl   ;
wire 				  iic_tx_sda   ;
wire 				  iic_scl      ;
wire 				  iic_sda      ;
wire 				  hdmi_int_led ;

wire				cmos1_scl      ;
wire				cmos1_sda      ;
wire				cmos1_vsync    ;
wire				cmos1_href     ;
wire				cmos1_pclk     ;
wire				cmos1_data     ;
wire				cmos1_reset    ;

wire				cmos2_scl      ;
wire				cmos2_sda      ;
wire				cmos2_vsync    ;
wire				cmos2_href     ;
wire				cmos2_pclk     ;
wire				cmos2_data     ;
wire				cmos2_reset    ;




assign r_in = de_in? 8'h1f : 8'h00;
assign g_in = de_in? 8'h1f : 8'h00;
assign b_in = de_in? 8'h1f : 8'h00;
//assign rgb_in = de_in? 16'hffff : 'd0;

test_ddr #(
  .PROJECT_MODE		   (1),
  .VIDEO_LENGTH        (),
  .VIDEO_HIGTH         (),
  .ZOOM_VIDEO_LENGTH   (),
  .ZOOM_VIDEO_HIGTH    (),
  .PIXEL_WIDTH         (),    
  .MEM_ROW_ADDR_WIDTH  (),
  .MEM_COL_ADDR_WIDTH  (),
  .MEM_BADDR_WIDTH     (),
  .MEM_DQ_WIDTH        (),
  .MEM_DM_WIDTH        (),
  .MEM_DQS_WIDTH       (),
  .M_AXI_BRUST_LEN     (),
  .RW_ADDR_MIN         (),
  .RW_ADDR_MAX         (),//@540p  518400个地址   
  .CTRL_ADDR_WIDTH     ()
)
u_test_ddr(
	.  ref_clk         (pll_refclk_in),//  input                                
	.  rst_board       (ddr_rstn),//  input                                
	.  ddr_pll_lock    (),//  output                               
	.  ddr_init_done   (dfi_init_complete),//  output                               
	//DDR 
	.  mem_rst_n       (mem_rst_n),//  output                               
	.  mem_ck          (mem_ck   ),//  output                               
	.  mem_ck_n        (mem_ck_n ),//  output                               
	.  mem_cke         (mem_cke  ),//  output                               
	.  mem_cs_n        (mem_cs_n ),//  output                               
	.  mem_ras_n       (mem_ras_n),//  output                               
	.  mem_cas_n       (mem_cas_n),//  output                               
	.  mem_we_n        (mem_we_n ),//  output                               
	.  mem_odt         (mem_odt  ),//  output                               
	.  mem_a           (mem_a    ),//  output     [MEM_ROW_ADDR_WIDTH-1:0]  
	.  mem_ba          (mem_ba   ),//  output     [MEM_BADDR_WIDTH-1:0]     
	.  mem_dqs         (mem_dqs  ),//  inout      [MEM_DQS_WIDTH-1:0]       
	.  mem_dqs_n       (mem_dqs_n),//  inout      [MEM_DQS_WIDTH-1:0]       
	.  mem_dq          (mem_dq   ),//  inout      [MEM_DQ_WIDTH-1:0]        
	.  mem_dm          (mem_dm   ),
//  output     [MEM_DM_WIDTH-1:0]        
	//MS72XX配置
	.    hdmi_rst      (hdmi_rst    ),//  output wire                          
	.    iic_tx_scl    (iic_tx_scl  ),//  output                               
	.    iic_tx_sda    (iic_tx_sda  ),//  inout                                
	.    iic_scl       (iic_scl     ),//  output                               
	.    iic_sda       (iic_sda     ),//  inout                                
	.    hdmi_int_led  (hdmi_int_led),//  output     MS72XX初始化完成信号
    //画面输入成功信号	
	.    fram0_done    (fram0_done),//  output wire                          
	.    fram1_done    (fram1_done),//  output wire                          
	.    fram2_done    (fram2_done),//  output wire                          
	.    fram3_done    (fram3_done),//  output wire                          
	//HDMI IN
	.    pix_clk_in    (pix_clk_in),//  input wire //HDMI输入时钟 1080p @148.5Mhz                          
	.    vs_in         (vs_in	  ),//  input wire   //帧同步                		                        
	.    hs_in         (hs_in	  ),//  input wire //行同步                                                
	.    de_in         (de_in	  ),//  input wire   //数据有效信号          		                        
	.    r_in          (r_in      ),//  input wire [7 : 0]                   
	.    g_in          (g_in      ),//  input wire [7 : 0]                   
	.    b_in          (b_in      ),//  input wire [7 : 0]                   
	//HDMI OUT
	.  pix_clk_out     (),//  output                               
	.  r_vs_out        (),//  output reg                           
	.  r_hs_out        (),//  output reg                           
	.  r_de_out        (),//  output reg                           
	.  r_r_out         (r_out),//  output reg  [7 : 0]                  
	.  r_g_out         (g_out),//  output reg  [7 : 0]                  
	.  r_b_out         (b_out),//  output reg  [7 : 0]                  
	//coms1	
	.cmos1_scl         (cmos1_scl  ),//  inout          cmos1 i2c                                              
	.cmos1_sda         (cmos1_sda  ),//  inout          cmos1 i2c                                              
	.cmos1_vsync       (vs_in	   ),//  input          cmos1 vsync          			                     
	.cmos1_href        (de_in 	   ),//  input          cmos1 hsync refrence,data valid                        
	.cmos1_pclk        (pix_clk_in ),//  input          cmos1 pxiel clock                                      
	.cmos1_data        (8'hff	   ),//  input   [7:0]  cmos1 data                                             
	.cmos1_reset       (cmos1_reset),//  output         cmos1 reset         			                     
	//coms2
	.cmos2_scl         (cmos2_scl  ),//  inout          cmos2 i2c                                         
	.cmos2_sda         (cmos2_sda  ),//  inout          cmos2 i2c                                         
	.cmos2_vsync       (vs_in	   ),//  input          cmos2 vsync                                       
	.cmos2_href        (de_in 	   ),//  input          cmos2 hsync refrence,data valid                   
	.cmos2_pclk        (pix_clk_in ),//  input          cmos2 pxiel clock                                 
	.cmos2_data        (8'hff	   ),//  input   [7:0]  cmos2 data                                        
	.cmos2_reset       (cmos2_reset) //  output                               
);

sync_gen_tb user_sync_gen_tb//1080P
(
    .clk		(pix_clk_in),
    .rstn		(dfi_init_complete),
    .vs_out		(vs_in),
    .hs_out		(hs_in),
    .de_out		(de_in),
    .de_re		(),
    .x_act		(),
    .y_act      ()
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

always #(PLL_REFCLK_IN_PERIOD / 2)  pll_refclk_in = ~pll_refclk_in;//50mhz，10ns做一次反转

//always #(20000 / 2)  free_clk = ~free_clk;

always #3367 pix_clk_in = ~pix_clk_in;//@148.5mhz
initial begin

#1 
pll_refclk_in = 0;
free_clk = 0;
pix_clk_in = 0;
//default input from keyboard
ddr_rstn = 1'b1;


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

//$display("%t keyboard reset sequence finished!", $time);

//@ (posedge dfi_init_complete);
//$display("%t dfi_init_complete is high now!", $time);
//#100000000;
//$finish;

end

initial 
begin
 $fsdbDumpfile("ddr_test_top_tb.fsdb");
 $fsdbDumpvars(0,"ddr_test_top_tb");
end

endmodule 

