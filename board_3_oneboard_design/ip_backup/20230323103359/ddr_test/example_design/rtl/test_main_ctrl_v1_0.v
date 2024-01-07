////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2015 Shenzhen Pango Microsystems CO.,LTD                       
// All Rights Reserved.                                                         
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module test_main_ctrl_v1_0 #(
parameter CTRL_ADDR_WIDTH = 28,
parameter MEM_DQ_WIDTH = 16,
parameter MEM_SPACE_AW = 18
)(
   input clk,
   input rst_n,
   input [1:0] wr_mode,
   input [1:0] data_mode,  
   input       len_random_en,
   input [3:0] fix_axi_len,
   input       bist_stop     ,
   output wire pattern_en    ,
   output wire random_data_en,
   output wire read_repeat_en,
   output wire stress_test   ,
   output wire write_to_read , 

   output [CTRL_ADDR_WIDTH-1:0] random_rw_addr,
   output [3:0] random_axi_id,
   output [3:0] random_axi_len,
   output       random_axi_ap,
        
   input ddrc_init_done,
   output reg init_start,
   input init_done,
   output reg write_en,
   input  write_done_p,
   output reg read_en,
   input  read_done_p,
   output reg bist_run_led,
   output reg [3:0] test_main_state   
);

wire [127:0] prbs_dout;
wire random_write_en;
reg [1:0] wr_mode_d0;
reg [1:0] wr_mode_d1;
reg [1:0] data_mode_d0;
reg [1:0] data_mode_d1;
//wire write_to_read;
reg [17:0] run_led_cnt;
reg [3:0] fix_axi_len_d0;
reg [3:0] fix_axi_len_d1;
reg len_random_en_d0;
reg len_random_en_d1;

localparam E_IDLE      = 4'd0;
localparam E_INIT      = 4'd1;
localparam E_WR        = 4'd2;
localparam E_RD        = 4'd3;
localparam E_END       = 4'd4;

reg ddrc_init_done_d0;
reg ddrc_init_done_d1;

always @(posedge clk or negedge rst_n)
if (!rst_n) begin
  ddrc_init_done_d0 <= 0;
  ddrc_init_done_d1 <= 0;
end
else begin
  ddrc_init_done_d0 <= ddrc_init_done;
  ddrc_init_done_d1 <= ddrc_init_done_d0;
end

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)begin
		wr_mode_d0 <= 2'b00;
		wr_mode_d1 <= 2'b00;
	end
	else begin
		wr_mode_d0 <= wr_mode;
		wr_mode_d1 <= wr_mode_d0;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)begin
		data_mode_d0 <= 2'b00;
		data_mode_d1 <= 2'b00;
	end
	else begin
		data_mode_d0 <= data_mode;
		data_mode_d1 <= data_mode_d0;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)begin
		len_random_en_d0 <= 0;
		len_random_en_d1 <= 0;
	end
	else begin
		len_random_en_d0 <= len_random_en;
		len_random_en_d1 <= len_random_en_d0;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)begin
		fix_axi_len_d0 <= 4'b0;
		fix_axi_len_d1 <= 4'b0;
	end
	else begin
		fix_axi_len_d0 <= fix_axi_len;
		fix_axi_len_d1 <= fix_axi_len_d0;
	end
end

assign read_repeat_en = wr_mode_d1[0];
assign write_to_read = wr_mode_d1[1];
assign pattern_en = data_mode_d1 == 2'b11;
assign random_data_en = data_mode_d1 == 2'b00;
assign stress_test = data_mode_d1 == 2'b10;

//reg [3:0] test_main_state;
always @(posedge clk or negedge rst_n)
   if (!rst_n) begin
      test_main_state    <= E_IDLE;
      write_en <= 1'b0;
      read_en  <= 1'b0;
      init_start <= 1'b0;
   end
   else begin
            case (test_main_state)
               E_IDLE: begin
                  if (ddrc_init_done_d1)
                  begin
                  	if(write_to_read)
                  	test_main_state <= E_WR;
                  	else
                  	test_main_state <= E_INIT;
                  end
                  else
                  test_main_state <= E_IDLE;
               end
               E_INIT : begin
                init_start <= 1'b1;
                if(init_done) begin
                test_main_state <= E_WR;
                init_start <= 1'b0;
                end
            end
               E_WR: begin
                  if (write_done_p) begin
                     write_en <= 1'b0;
                     if(write_to_read)
                     test_main_state <= E_RD;
                     else
                     test_main_state <= E_END;
                  end
                  else if(bist_stop)
                     write_en <= 1'b0;
                  else
                     write_en <= 1'b1;
               end
               E_RD: begin
                  if (read_done_p) begin
                     read_en <= 1'b0;
                     if(write_to_read)
                     test_main_state <= E_WR;
                     else
                     test_main_state <= E_END;
                  end
                  else if(bist_stop)
                     read_en <= 1'b0;
                  else
                     read_en <= 1'b1;                  
               end               
               E_END: begin
               	  if (random_write_en)
               	     test_main_state <= E_WR;
               	  else
               	     test_main_state <= E_RD;
               end
               default: begin
                  test_main_state <= E_IDLE;
               end                                               
      endcase
   end

assign prbs_clk_en = (~write_to_read & write_done_p) | read_done_p;

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        run_led_cnt <= 18'd0;
    else if(read_done_p|write_done_p)
        run_led_cnt <= run_led_cnt + 18'd1;
    else;
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        bist_run_led <= 1'b0;
    else if((&run_led_cnt)&(read_done_p|write_done_p))
        bist_run_led <= ~bist_run_led;
end

prbs31_128bit_v1_0  #(
.PRBS_INIT  (128'h1234_5678_9abc_def0_8686_2016_0707_336a),
.PRBS_GEN_EN (1'b1)
)
I_prbs31_128bit(
.clk       (clk),
.rstn      (rst_n),
.clk_en    (prbs_clk_en),

.cnt_mode  (1'b0   ),
.din       (128'd0),
.dout      (prbs_dout),
.insert_er (1'b0),
.error     ()
);

wire [CTRL_ADDR_WIDTH-1:0] random_rw_addr_mask = {CTRL_ADDR_WIDTH{1'b0}} + {(MEM_SPACE_AW-1){1'b1}};

assign random_rw_addr  =  {prbs_dout[96+CTRL_ADDR_WIDTH-4:96], 3'd0} & random_rw_addr_mask;
assign random_axi_id   =  prbs_dout[39:36];
assign random_axi_len  =  (len_random_en_d1==1) ? prbs_dout[35:32] : fix_axi_len_d1;
assign random_write_en =  prbs_dout[0];
assign random_axi_ap   = 0;

endmodule
