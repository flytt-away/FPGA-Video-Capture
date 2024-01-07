`timescale 1ns/1ps
module test_wr_ctrl_v1_0 #(
    parameter          DATA_PATTERN0        = 8'h55,
    parameter          DATA_PATTERN1        = 8'haa,
    parameter          DATA_PATTERN2        = 8'h7f,
    parameter          DATA_PATTERN3        = 8'h80,
    parameter          DATA_PATTERN4        = 8'h55,
    parameter          DATA_PATTERN5        = 8'haa,
    parameter          DATA_PATTERN6        = 8'h7f,
    parameter          DATA_PATTERN7        = 8'h80,
    parameter          DATA_MASK_EN         = 0,
    parameter          CTRL_ADDR_WIDTH      = 28,
    parameter          MEM_DQ_WIDTH         = 16,
    parameter          MEM_SPACE_AW         = 18
)(                        
    input                                clk                ,
    input                                rst_n              ,   
    input                                init_start         ,
    input                                write_en           ,
    input                                insert_err         ,
    output reg                           write_done_p       ,
    output reg                           init_done          ,

    input                                pattern_en         ,
    input                                random_data_en     ,
    input                                stress_test        ,
    input                                write_to_read      ,
    input                                read_repeat_en     ,
    input                                data_order         ,
    input [7:0]                          dq_inversion       ,

    input [CTRL_ADDR_WIDTH-1:0]          random_rw_addr     ,     
    input [3:0]                          random_axi_id      ,
    input [3:0]                          random_axi_len     ,
    input                                random_axi_ap      ,

    output reg [CTRL_ADDR_WIDTH-1:0]     axi_awaddr          ,
    output reg                           axi_awuser_ap       ,    
    output reg [3:0]                     axi_awuser_id       ,
    output reg [3:0]                     axi_awlen           ,
    input                                axi_awready         ,
    output reg                           axi_awvalid         ,
          
    output     [MEM_DQ_WIDTH*8-1:0]      axi_wdata        ,
    output     [MEM_DQ_WIDTH*8/8-1:0]    axi_wstrb        ,
    input                                axi_wready       ,
    output reg [2:0]                     test_wr_state
);

localparam DQ_NUM = MEM_DQ_WIDTH/8;

localparam [CTRL_ADDR_WIDTH:0] AXI_ADDR_MAX = (1'b1<<MEM_SPACE_AW);

localparam E_IDLE = 3'd0;
localparam E_WR   = 3'd1;
localparam E_END  = 3'd2;

reg [CTRL_ADDR_WIDTH:0] init_addr;
reg [CTRL_ADDR_WIDTH-1:0] normal_wr_addr;
wire [15:0] wr_data_addr;
reg [15:0] req_wr_cnt     ;
reg [15:0] execute_wr_cnt ;
wire  write_finished ;
reg [7:0] cnt_len;

reg [8*MEM_DQ_WIDTH-1:0]    wrdata_reorder;
wire[8*MEM_DQ_WIDTH-1:0]    wrdata_pre;

wire[7:0]   wr_data_random_0;
wire[7:0]   wr_data_random_1;
wire[7:0]   wr_data_random_2;
wire[7:0]   wr_data_random_3;
wire[7:0]   wr_data_random_4;
wire[7:0]   wr_data_random_5;
wire[7:0]   wr_data_random_6;
wire[7:0]   wr_data_random_7;

wire [9:0] wr_data_addr0;
wire [9:0] wr_data_addr1;
wire [9:0] wr_data_addr2;
wire [9:0] wr_data_addr3;
wire [9:0] wr_data_addr4;
wire [9:0] wr_data_addr5;
wire [9:0] wr_data_addr6;
wire [9:0] wr_data_addr7;

wire [7:0]   wr_data_r0;
wire [7:0]   wr_data_r1;
wire [7:0]   wr_data_r2;
wire [7:0]   wr_data_r3;
wire [7:0]   wr_data_r4;
wire [7:0]   wr_data_r5;
wire [7:0]   wr_data_r6;
wire [7:0]   wr_data_r7;

wire [7:0]   wr_data_0;
wire [7:0]   wr_data_1;
wire [7:0]   wr_data_2;
wire [7:0]   wr_data_3;
wire [7:0]   wr_data_4;
wire [7:0]   wr_data_5;
wire [7:0]   wr_data_6;
wire [7:0]   wr_data_7;

wire [7:0]   wr_data_mask;
wire [15:0]  prbs_din;
wire [63:0]  prbs_dout;
wire         prbs_en;
reg          prbs_din_en;        

wire [8*MEM_DQ_WIDTH-1:0]       wrdata_ch ;
reg insert_err_d1,insert_err_d2;
wire insert_err_pos;
reg insert_err_valid;
reg [7:0] delay_cnt;


assign axi_wstrb = {{DQ_NUM{wr_data_mask[7]}},{DQ_NUM{wr_data_mask[6]}},{DQ_NUM{wr_data_mask[5]}},{DQ_NUM{wr_data_mask[4]}},
                    {DQ_NUM{wr_data_mask[3]}},{DQ_NUM{wr_data_mask[2]}},{DQ_NUM{wr_data_mask[1]}},{DQ_NUM{wr_data_mask[0]}}};

always @(posedge clk or negedge rst_n)
begin
   if (!rst_n) begin
      axi_awaddr     <= 'b0; 
      axi_awuser_ap  <= 1'b0; 
      axi_awuser_id  <= 4'b0; 
      axi_awlen      <= 4'b0; 
      axi_awvalid    <= 1'b0; 
      test_wr_state          <= E_IDLE;
      write_done_p   <= 1'b0;
   end
   else begin
    if(init_start) begin
        axi_awlen <= 4'd15;
        axi_awuser_ap  <= 1'b0;
        if (axi_awaddr < (AXI_ADDR_MAX - 8'd128)) begin
            axi_awvalid <= 1;
            if(axi_awvalid&axi_awready) begin
             axi_awaddr <= axi_awaddr + 8'd128;
             axi_awuser_id  <= axi_awuser_id + 1;
            end
        end
        else if(axi_awaddr == (AXI_ADDR_MAX - 8'd128)) begin
           if(axi_awvalid&axi_awready) 
           axi_awvalid <= 0;
        end
        else
         axi_awvalid <= 0;
    end
    else begin
        if ((test_wr_state == E_IDLE) && write_en && write_finished) begin //add more condition for easy debug
         axi_awuser_id <= random_axi_id;
	       axi_awaddr    <= random_rw_addr;  
   	     axi_awlen     <= random_axi_len;
   	     axi_awuser_ap <= random_axi_ap;
   	    end 
   	    case(test_wr_state) 
  	     	 E_IDLE: begin
   	     	 	  if (write_en && write_finished)
   	     	 	     test_wr_state <= E_WR;
   	     	 end
   	     	 E_WR: begin
   	     	 	  axi_awvalid <= 1'b1;   	     	 	  
   	     	 	  if (axi_awvalid&axi_awready) begin
   	     	 	     test_wr_state <= E_END;
   	     	 	     write_done_p <= 1'b1;
   	     	 	     axi_awvalid <= 1'b0;
   	     	 	  end
   	     	 end
   	     	 E_END: begin
   	     	      axi_awvalid <= 1'b0;
   	     	 	  write_done_p <= 1'b0;
   	     	 	  if (write_finished)
   	     	 	     test_wr_state <= E_IDLE;
   	     	 end
   	     	 default: begin
   	     	 	  test_wr_state <= E_IDLE;
   	     	 end   	        
   	endcase 
    end
end
end

always @(posedge clk or negedge rst_n) 
begin
	if (!rst_n)
	init_done <= 0;
	else if((init_start==1)&&(init_addr >= AXI_ADDR_MAX) && (delay_cnt[7]==1))
	init_done <= 1;
end

always @(posedge clk or negedge rst_n) 
begin
	if (!rst_n)
	delay_cnt <= 8'd0;
	else if((init_start==1)&&(init_addr >= AXI_ADDR_MAX))
	delay_cnt <= delay_cnt + 8'd1;
end

always @(posedge clk or negedge rst_n) 
begin
   if (!rst_n) begin
     init_addr <= {(CTRL_ADDR_WIDTH+1){1'b0}};
     normal_wr_addr <= {CTRL_ADDR_WIDTH{1'b0}};  
   end
   else begin
    if(init_start) begin
      if(init_addr < AXI_ADDR_MAX)begin
        if(axi_wready)
        init_addr <= init_addr + 8;     
      end
    end
    else begin
        if(test_wr_state == E_WR)begin 
        normal_wr_addr <= axi_awaddr;
        end
        else if(test_wr_state == E_END) begin
        if(axi_wready) begin
        normal_wr_addr <= normal_wr_addr + 8;
        end
        end   
    end
end
end
assign axi_wdata = wrdata_ch ;

assign wr_data_addr = (init_start==1) ? init_addr[15:0] : normal_wr_addr[15:0];

always @(posedge clk or negedge rst_n)
   if (!rst_n) begin
   	  req_wr_cnt     <= 16'd0;
   	  execute_wr_cnt <= 16'd0;
   end
   else if (!init_start)
   begin
   	  if (axi_awvalid & axi_awready) begin
   	  	req_wr_cnt <= req_wr_cnt + axi_awlen + 1;
   	  end   	  
   	  if (axi_wready) begin
   	     execute_wr_cnt <= execute_wr_cnt + 1;
   	  end      
   end
   else begin
   	  req_wr_cnt     <= 16'd0;
   	  execute_wr_cnt <= 16'd0;   
end

assign write_finished = (req_wr_cnt == execute_wr_cnt);

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		insert_err_d1 <= 0;
		insert_err_d2 <= 0;
	end
	else begin
		insert_err_d1 <= insert_err;
		insert_err_d2 <= insert_err_d1;
	end
end

assign insert_err_pos = insert_err_d1 & ~insert_err_d2;

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)
	insert_err_valid <= 0;
	else if(insert_err_pos)
	insert_err_valid <= 1;
	else if(axi_wready)
	insert_err_valid <= 0;
end

assign wr_data_random_0 = random_data_en ? prbs_dout[7:0]   : prbs_dout[7:0] + 8'd0; 
assign wr_data_random_1 = random_data_en ? prbs_dout[15:8]  : prbs_dout[7:0] + 8'd1; 
assign wr_data_random_2 = random_data_en ? prbs_dout[23:16] : prbs_dout[7:0] + 8'd2; 
assign wr_data_random_3 = random_data_en ? prbs_dout[31:24] : prbs_dout[7:0] + 8'd3; 
assign wr_data_random_4 = random_data_en ? prbs_dout[39:32] : prbs_dout[7:0] + 8'd4; 
assign wr_data_random_5 = random_data_en ? prbs_dout[47:40] : prbs_dout[7:0] + 8'd5; 
assign wr_data_random_6 = random_data_en ? prbs_dout[55:48] : prbs_dout[7:0] + 8'd6; 
assign wr_data_random_7 = random_data_en ? prbs_dout[63:56] : prbs_dout[7:0] + 8'd7; 

assign wr_data_r0 = pattern_en ? DATA_PATTERN0 : stress_test ? wr_data_random_0 : wr_data_random_0 ;
assign wr_data_r1 = pattern_en ? DATA_PATTERN1 : stress_test ? wr_data_random_0 : wr_data_random_1 ;
assign wr_data_r2 = pattern_en ? DATA_PATTERN2 : stress_test ? wr_data_random_0 : wr_data_random_2 ;
assign wr_data_r3 = pattern_en ? DATA_PATTERN3 : stress_test ? wr_data_random_0 : wr_data_random_3 ;
assign wr_data_r4 = pattern_en ? DATA_PATTERN4 : stress_test ? wr_data_random_0 : wr_data_random_4 ;
assign wr_data_r5 = pattern_en ? DATA_PATTERN5 : stress_test ? wr_data_random_0 : wr_data_random_5 ;
assign wr_data_r6 = pattern_en ? DATA_PATTERN6 : stress_test ? wr_data_random_0 : wr_data_random_6 ;
assign wr_data_r7 = pattern_en ? DATA_PATTERN7 : stress_test ? wr_data_random_0 : wr_data_random_7 ;

assign wr_data_0 = (dq_inversion[0] ^ insert_err_valid) ? (~wr_data_r0) : wr_data_r0;
assign wr_data_1 = dq_inversion[1] ? (~wr_data_r1) : wr_data_r1;
assign wr_data_2 = dq_inversion[2] ? (~wr_data_r2) : wr_data_r2;
assign wr_data_3 = dq_inversion[3] ? (~wr_data_r3) : wr_data_r3;
assign wr_data_4 = dq_inversion[4] ? (~wr_data_r4) : wr_data_r4;
assign wr_data_5 = dq_inversion[5] ? (~wr_data_r5) : wr_data_r5;
assign wr_data_6 = dq_inversion[6] ? (~wr_data_r6) : wr_data_r6;
assign wr_data_7 = dq_inversion[7] ? (~wr_data_r7) : wr_data_r7;

assign wrdata_pre = {{DQ_NUM{wr_data_7}},{DQ_NUM{wr_data_6}},{DQ_NUM{wr_data_5}},{DQ_NUM{wr_data_4}},{DQ_NUM{wr_data_3}},{DQ_NUM{wr_data_2}},{DQ_NUM{wr_data_1}},{DQ_NUM{wr_data_0}}};

assign wrdata_ch = (stress_test | data_order) ?  wrdata_reorder : wrdata_pre  ;

integer i,j,k;
always @(*) begin
      for (i=0; i<8; i=i+1)
         for (j=0; j<DQ_NUM; j=j+1)
             for (k=0; k<8; k=k+1)        
               wrdata_reorder[i*8*DQ_NUM+j*8+k] = wrdata_pre[k*8*DQ_NUM+j*8+i];
end

assign prbs_din = wr_data_addr;
assign prbs_en = (write_to_read == 0) ? 0 : axi_wready;

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)
	prbs_din_en <= 0;
	else if(write_to_read == 0)
	prbs_din_en <= 1;
	else begin
		if(read_repeat_en==0)
		prbs_din_en <= 0;
		else if(axi_awvalid&axi_awready)
		prbs_din_en <= 1;
	  else if(axi_wready)
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

assign wr_data_mask = (DATA_MASK_EN == 1) ? prbs_dout[7:0] : 8'hff;

endmodule
