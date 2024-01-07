`timescale 1ns/1ps
module test_rd_ctrl_v1_0 #(
   parameter DATA_PATTERN0        = 8'h55,
   parameter DATA_PATTERN1        = 8'haa,
   parameter DATA_PATTERN2        = 8'h7f,
   parameter DATA_PATTERN3        = 8'h80,
   parameter DATA_PATTERN4        = 8'h55,
   parameter DATA_PATTERN5        = 8'haa,
   parameter DATA_PATTERN6        = 8'h7f,
   parameter DATA_PATTERN7        = 8'h80,
   parameter DATA_MASK_EN         = 0,
   parameter CTRL_ADDR_WIDTH      = 28,
   parameter MEM_DQ_WIDTH         = 16,
   parameter MEM_SPACE_AW         = 18
   
)(
   input                                clk           ,
   input                                rst_n         ,   
   input                                pattern_en    ,
   input                                random_data_en,
   input                                read_repeat_en,
   input [3:0]                          read_repeat_num,
   
   input                                stress_test   ,
   input                                write_to_read ,
   input                                data_order    ,
   input [7:0]                          dq_inversion  ,
   input [CTRL_ADDR_WIDTH-1:0]          random_rw_addr,
   input [3:0]                          random_axi_id ,
   input [3:0]                          random_axi_len,
   input                                random_axi_ap ,
   input                                read_en       ,
   output reg                           read_done_p   ,
   
    output reg [CTRL_ADDR_WIDTH-1:0]    axi_araddr     ,
    output reg                          axi_aruser_ap  ,    
    output reg [3:0]                    axi_aruser_id  ,
    output reg [3:0]                    axi_arlen      ,
    input                               axi_arready    ,
    output reg                          axi_arvalid    ,

    input   [MEM_DQ_WIDTH*8-1:0]        axi_rdata      ,
    //input   [3:0]                       axi_rid        ,
    //input                               axi_rlast      ,
    input                               axi_rvalid     ,
    output reg [7:0]                    err_cnt,
    output reg                          err_flag_led   ,
    output  reg[MEM_DQ_WIDTH*8-1:0]     err_data_out ,    
    output  reg[MEM_DQ_WIDTH*8-1:0]     err_flag_out ,
    output  reg[MEM_DQ_WIDTH*8-1:0]     exp_data_out ,    
    input                               manu_clear   ,
    output reg                          next_err_flag,
    output reg [15:0]                   result_bit_out,                         
    output reg [2:0]                    test_rd_state,
    output reg [MEM_DQ_WIDTH*8-1:0]     next_err_data,
    output reg [MEM_DQ_WIDTH*8-1:0]     err_data_pre ,
    output reg [MEM_DQ_WIDTH*8-1:0]     err_data_aft  
);

localparam E_IDLE = 3'd0;
localparam E_RD   = 3'd1;
localparam E_END  = 3'd2;
localparam DQ_NUM = MEM_DQ_WIDTH/8; 

reg [15:0] req_rd_cnt;
reg [15:0] execute_rd_cnt;
wire  read_finished;

wire [15:0] rd_data_addr;
wire [9:0] rd_data_addr0;
wire [9:0] rd_data_addr1;
wire [9:0] rd_data_addr2;
wire [9:0] rd_data_addr3;
wire [9:0] rd_data_addr4;
wire [9:0] rd_data_addr5;
wire [9:0] rd_data_addr6;
wire [9:0] rd_data_addr7;
wire [7:0] rd_data_random_0;
wire [7:0] rd_data_random_1;
wire [7:0] rd_data_random_2;
wire [7:0] rd_data_random_3;
wire [7:0] rd_data_random_4;
wire [7:0] rd_data_random_5;
wire [7:0] rd_data_random_6;
wire [7:0] rd_data_random_7;
wire [7:0] rd_data_r0;
wire [7:0] rd_data_r1;
wire [7:0] rd_data_r2;
wire [7:0] rd_data_r3;
wire [7:0] rd_data_r4;
wire [7:0] rd_data_r5;
wire [7:0] rd_data_r6;
wire [7:0] rd_data_r7;
wire [7:0] rd_data_0;
wire [7:0] rd_data_1;
wire [7:0] rd_data_2;
wire [7:0] rd_data_3;
wire [7:0] rd_data_4;
wire [7:0] rd_data_5;
wire [7:0] rd_data_6;
wire [7:0] rd_data_7;
wire [MEM_DQ_WIDTH*8-1:0] rddata_exp_pre;
wire [MEM_DQ_WIDTH*8-1:0] rddata_exp;
reg  [MEM_DQ_WIDTH*8-1:0]  rddata_exp_reorder;

reg [MEM_DQ_WIDTH*8-1:0] rddata_exp_d1;
reg [MEM_DQ_WIDTH*8-1:0] rddata_exp_d2;

reg [MEM_DQ_WIDTH*8-1:0] data_err ;
reg err;
reg [MEM_DQ_WIDTH*8-1:0] rddata_mask;
reg [MEM_DQ_WIDTH*8-1:0] rddata_mask_d1;
wire [15:0]  prbs_din;
wire [63:0]  prbs_dout;
wire         prbs_en;
reg          prbs_din_en;

reg         axi_rvalid_d1;
reg         axi_rvalid_d2;
reg [CTRL_ADDR_WIDTH-1:0] normal_rd_addr;
reg [3:0] cnt_len;
reg [3:0] rd_cnt;
reg [MEM_DQ_WIDTH*8-1:0]      axi_rdata_d1 ;
reg [MEM_DQ_WIDTH*8-1:0]      axi_rdata_d2 ;
reg [MEM_DQ_WIDTH*8-1:0]      axi_rdata_d3 ;
reg manu_clear_d1,manu_clear_d2;
reg [3:0]  read_repeat_num_d0;
reg [3:0]  read_repeat_num_d1;
reg read_finished_d0;
reg read_finished_d1;
wire read_finished_pos;
reg [3:0] result_cnt;
reg result_bit_lock;
wire [7:0] rd_data_mask;

always @(posedge clk or negedge rst_n)
begin
  if (!rst_n)begin
   	read_repeat_num_d0 <= 4'd0;
   	read_repeat_num_d1 <= 4'd0;
  end
  else begin
  	read_repeat_num_d0 <= read_repeat_num;
   	read_repeat_num_d1 <= read_repeat_num_d0;
  end
end

always @(posedge clk or negedge rst_n)
begin
   if (!rst_n)
   test_rd_state  <= E_IDLE;
   else begin      
    case (test_rd_state)
       E_IDLE: begin
         if (read_en & read_finished)
         test_rd_state <= E_RD;
       end
       E_RD: begin                
         if (axi_arvalid&axi_arready)
         test_rd_state <= E_END;
      end
      E_END: begin
         if (read_finished)
         test_rd_state <= E_IDLE;
      end
      default: begin
      	  test_rd_state <= E_IDLE;
      end
    endcase     
   end
end        

always @(posedge clk or negedge rst_n)
begin
   if (!rst_n) begin
      axi_araddr     <= {CTRL_ADDR_WIDTH{1'b0}}; 
      axi_aruser_id  <= 4'b0; 
      axi_arlen      <= 4'b0; 
      axi_aruser_ap  <= 1'b0;
   end
   else if((test_rd_state == E_IDLE) & read_en & read_finished)
   begin
      axi_aruser_id <= random_axi_id;
      axi_araddr <= random_rw_addr;
      axi_arlen  <=  random_axi_len; 
      axi_aruser_ap <= random_axi_ap;  	         
   end
end

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		 axi_arvalid    <= 1'b0; 
     read_done_p    <= 1'b0;
     rd_cnt         <= 4'd0;
	end
	else begin
		  case (test_rd_state)
       E_IDLE: begin
		     read_done_p <= 1'b0 ;
		     axi_arvalid <= 1'b0;
         end
       E_RD: begin
           axi_arvalid <= 1'b1;                  
           if (axi_arvalid&axi_arready) begin
              axi_arvalid <= 1'b0; 
              if(read_repeat_en) begin
                if(rd_cnt==read_repeat_num_d1)
                rd_cnt <= 4'd0;
                else 
                rd_cnt <= rd_cnt + 4'd1;
              end
              if(read_repeat_en) begin
                if(rd_cnt==read_repeat_num_d1)
                read_done_p <= 1'b1;
                else 
                read_done_p <= 1'b0;
              end
              else
              read_done_p <= 1'b1;
           end
      end
      E_END: begin
           axi_arvalid <= 1'b0;
           read_done_p <= 1'b0;
      end
      default: begin
      	   axi_arvalid <= 1'b0;
           read_done_p <= 1'b0;
      end
    endcase  
	end
end


always @(posedge clk or negedge rst_n)
begin
   if (!rst_n) begin
     normal_rd_addr <= {CTRL_ADDR_WIDTH{1'b0}};
     cnt_len <= 4'd0; 
   end
   else begin 
    if(test_rd_state == E_RD) begin 
      normal_rd_addr <= axi_araddr;
      cnt_len <= 4'd0;  
    end
    else if(test_rd_state == E_END) begin
      if(cnt_len <= axi_arlen) begin
        if(axi_rvalid) begin
          normal_rd_addr <= normal_rd_addr + 8;
          cnt_len <= cnt_len + 4'd1;
        end
    end
    end
end
end

always @(posedge clk or negedge rst_n)
   if (!rst_n) begin
   	  req_rd_cnt     <= 16'd0;
   	  execute_rd_cnt <= 16'd0;
   end
   else begin
   	  if (axi_arvalid & axi_arready) begin
   	  	 req_rd_cnt <= req_rd_cnt + {8'd0,axi_arlen} + 1;
   	  end   	  
   	  if (axi_rvalid) begin
   	     execute_rd_cnt <= execute_rd_cnt + 1;
   	  end      
   end

assign  read_finished = (req_rd_cnt == execute_rd_cnt);

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        axi_rvalid_d1 <= 1'b0;
        axi_rvalid_d2 <= 1'b0;
    end
    else
    begin
        axi_rvalid_d1 <= axi_rvalid;
        axi_rvalid_d2 <= axi_rvalid_d1;
    end
end

assign rd_data_addr = normal_rd_addr[15:0];

assign rd_data_random_0 = random_data_en ?  prbs_dout[7:0]   : prbs_dout[7:0] + 8'd0; 
assign rd_data_random_1 = random_data_en ?  prbs_dout[15:8]  : prbs_dout[7:0] + 8'd1; 
assign rd_data_random_2 = random_data_en ?  prbs_dout[23:16] : prbs_dout[7:0] + 8'd2; 
assign rd_data_random_3 = random_data_en ?  prbs_dout[31:24] : prbs_dout[7:0] + 8'd3; 
assign rd_data_random_4 = random_data_en ?  prbs_dout[39:32] : prbs_dout[7:0] + 8'd4; 
assign rd_data_random_5 = random_data_en ?  prbs_dout[47:40] : prbs_dout[7:0] + 8'd5; 
assign rd_data_random_6 = random_data_en ?  prbs_dout[55:48] : prbs_dout[7:0] + 8'd6; 
assign rd_data_random_7 = random_data_en ?  prbs_dout[63:56] : prbs_dout[7:0] + 8'd7; 

assign rd_data_r0 = pattern_en ? DATA_PATTERN0 : stress_test ? rd_data_random_0 : rd_data_random_0 ;
assign rd_data_r1 = pattern_en ? DATA_PATTERN1 : stress_test ? rd_data_random_0 : rd_data_random_1 ;
assign rd_data_r2 = pattern_en ? DATA_PATTERN2 : stress_test ? rd_data_random_0 : rd_data_random_2 ;
assign rd_data_r3 = pattern_en ? DATA_PATTERN3 : stress_test ? rd_data_random_0 : rd_data_random_3 ;
assign rd_data_r4 = pattern_en ? DATA_PATTERN4 : stress_test ? rd_data_random_0 : rd_data_random_4 ;
assign rd_data_r5 = pattern_en ? DATA_PATTERN5 : stress_test ? rd_data_random_0 : rd_data_random_5 ;
assign rd_data_r6 = pattern_en ? DATA_PATTERN6 : stress_test ? rd_data_random_0 : rd_data_random_6 ;
assign rd_data_r7 = pattern_en ? DATA_PATTERN7 : stress_test ? rd_data_random_0 : rd_data_random_7 ;

assign rd_data_0 = dq_inversion[0] ? (~rd_data_r0) : rd_data_r0;
assign rd_data_1 = dq_inversion[1] ? (~rd_data_r1) : rd_data_r1;
assign rd_data_2 = dq_inversion[2] ? (~rd_data_r2) : rd_data_r2;
assign rd_data_3 = dq_inversion[3] ? (~rd_data_r3) : rd_data_r3;
assign rd_data_4 = dq_inversion[4] ? (~rd_data_r4) : rd_data_r4;
assign rd_data_5 = dq_inversion[5] ? (~rd_data_r5) : rd_data_r5;
assign rd_data_6 = dq_inversion[6] ? (~rd_data_r6) : rd_data_r6;
assign rd_data_7 = dq_inversion[7] ? (~rd_data_r7) : rd_data_r7;

assign rddata_exp_pre = {{DQ_NUM{rd_data_7}},{DQ_NUM{rd_data_6}},{DQ_NUM{rd_data_5}},{DQ_NUM{rd_data_4}},{DQ_NUM{rd_data_3}},{DQ_NUM{rd_data_2}},{DQ_NUM{rd_data_1}},{DQ_NUM{rd_data_0}}};

assign rddata_exp = (stress_test | data_order) ?  rddata_exp_reorder : rddata_exp_pre  ;

integer i,j,k;
always @(*) begin
      for (i=0; i<8; i=i+1)
         for (j=0; j<DQ_NUM; j=j+1)
             for (k=0; k<8; k=k+1)        
               rddata_exp_reorder[i*8*DQ_NUM+j*8+k] = rddata_exp_pre[k*8*DQ_NUM+j*8+i];
end

assign prbs_din = rd_data_addr;
assign prbs_en = (write_to_read == 0) ? 0 : axi_rvalid;

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)
	prbs_din_en <= 0;
	else if(write_to_read == 0)
	prbs_din_en <= 1;
	else begin
		if(read_repeat_en==0)
		prbs_din_en <= 0;
		else if(axi_arvalid&axi_arready)
		prbs_din_en <= 1;
	  else if(axi_rvalid)
	  prbs_din_en <= 0;
  end
end

prbs15_64bit_v1_0 #(
 .PRBS_INIT (16'h0)
)
u_prbs15_64bit
(
 .clk            (clk    ),
 .rst_n          (rst_n  ),
 .prbs_en        (prbs_en ),    
 .din_en         (prbs_din_en),
 .din            (prbs_din),
 .dout           (prbs_dout)
);

assign rd_data_mask = (DATA_MASK_EN == 1) ? prbs_dout[7:0] : 8'hff;
always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)
  axi_rdata_d1  <= {MEM_DQ_WIDTH{8'h0}} ;
  else if(axi_rvalid)
  axi_rdata_d1 <= axi_rdata;
  else 
  axi_rdata_d1 <=  axi_rdata_d1 ;
end

always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)
  axi_rdata_d2  <= {MEM_DQ_WIDTH{8'h0}} ;
  else 
  axi_rdata_d2 <= axi_rdata_d1;
end

always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)
  axi_rdata_d3  <= {MEM_DQ_WIDTH{8'h0}} ;
  else 
  axi_rdata_d3 <= axi_rdata_d2;
end
        
always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)
  rddata_exp_d1  <= {MEM_DQ_WIDTH{8'h0}} ;
  else if( axi_rvalid )
  rddata_exp_d1 <= rddata_exp;
  else 
  rddata_exp_d1 <=  rddata_exp_d1; 
end    

always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)
  rddata_exp_d2  <= {MEM_DQ_WIDTH{8'h0}} ;
  else 
  rddata_exp_d2 <= rddata_exp_d1;
end    

always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)
  rddata_mask  <= {MEM_DQ_WIDTH{8'h0}} ;
  else if( axi_rvalid )
  rddata_mask <= {{(DQ_NUM*8){rd_data_mask[7]}},{(DQ_NUM*8){rd_data_mask[6]}},{(DQ_NUM*8){rd_data_mask[5]}},{(DQ_NUM*8){rd_data_mask[4]}},
                  {(DQ_NUM*8){rd_data_mask[3]}},{(DQ_NUM*8){rd_data_mask[2]}},{(DQ_NUM*8){rd_data_mask[1]}},{(DQ_NUM*8){rd_data_mask[0]}}};  //0:mask 
  else 
  rddata_mask <=  rddata_mask; 
end 

always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)
  rddata_mask_d1  <= {MEM_DQ_WIDTH{8'h0}} ;
  else 
  rddata_mask_d1 <= rddata_mask;
end 

always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)
	data_err <= {MEM_DQ_WIDTH{8'h0}};
	else
	data_err <= (axi_rdata_d1 ^ rddata_exp_d1) & rddata_mask;
end

always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)
	err <= 0;
	else
	err <= |((axi_rdata_d1 ^ rddata_exp_d1) & rddata_mask);
end


always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        err_cnt <= 8'b0;
        err_flag_led <= 1'b0;
    end
    else if(manu_clear_d2)
    begin
        err_cnt <= 8'b0;
        err_flag_led <= 1'b0;
    end
    else if(err && axi_rvalid_d2)
    begin
        if(err_cnt == 8'hff)
            err_cnt <= err_cnt;
        else
        err_cnt <= err_cnt + 8'b1;
        err_flag_led <= 1'b1;
    end
end     

always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)begin
		read_finished_d0 <= 0;
		read_finished_d1 <= 0;
	end
	else begin
		read_finished_d0 <= read_finished;
		read_finished_d1 <= read_finished_d0;
	end
end
assign read_finished_pos = read_finished_d0 & ~read_finished_d1;

always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)
	result_cnt <= 4'd0;
	else if(read_repeat_en) begin
		if(read_finished_pos)begin
			if(result_cnt==read_repeat_num_d1)
			result_cnt <= 4'd0;
			else
			result_cnt <= result_cnt + 4'd1;
		end
	end
	else
	result_cnt <= 4'd0;
end

always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)
	result_bit_lock <= 0;
	else if(manu_clear_d2)
	result_bit_lock <= 0;
	else if(read_repeat_en) begin
		if(read_finished_pos & (result_cnt==read_repeat_num_d1) & err_flag_led)
		result_bit_lock <= 1;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)
	result_bit_out <= 16'h0;
	else if(manu_clear_d2)
	result_bit_out <= 16'h0;
	else if(err & axi_rvalid_d2 & ~result_bit_lock)
	begin
		for(i=0;i<16;i=i+1)
		if(i == result_cnt)
		result_bit_out[i] <= 1;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)begin
		manu_clear_d2 <= 0;
		manu_clear_d1 <= 0;
	end
	else begin
		manu_clear_d2 <= manu_clear_d1;
		manu_clear_d1 <= manu_clear;
	end
end   

always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)begin
		err_data_out <= {MEM_DQ_WIDTH{8'h0}} ;
		err_flag_out <= {MEM_DQ_WIDTH{8'h0}} ;
		exp_data_out <= {MEM_DQ_WIDTH{8'h0}} ;
	end
	else if(err & axi_rvalid_d2 & ~err_flag_led)begin
		err_data_out <= axi_rdata_d2;
	  err_flag_out <= data_err;
	  exp_data_out <= rddata_exp_d2 & rddata_mask_d1;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)
	err_data_pre <= {MEM_DQ_WIDTH{8'h0}};		
	else if(err_flag_led == 0) 
	err_data_pre <= axi_rdata_d3;
end

always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)
	err_data_aft <= {MEM_DQ_WIDTH{8'h0}};		
	else if(err_flag_led == 0) 
	err_data_aft <= axi_rdata_d1;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    next_err_flag <= 1'b0;
    else if(manu_clear_d2)
    next_err_flag <= 1'b0;
    else if(err & axi_rvalid_d2 & err_flag_led)
    next_err_flag <= 1'b1;
end

always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)begin
		next_err_data <= {MEM_DQ_WIDTH{8'h0}} ;
	end
	else if(err & axi_rvalid_d2 & err_flag_led & ~next_err_flag)begin
		next_err_data <= axi_rdata_d2;
	end
end
    
 endmodule
    
      	  	
