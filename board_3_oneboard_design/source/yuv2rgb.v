module yuv2rgb(
    input clk,
    input [7:0] y_in,
    input [7:0] u_in,
    input [7:0] v_in,
    input vs_in,
    input hs_in,
    input de_in,
    output [7:0] r_out,
    output [7:0] g_out,
    output [7:0] b_out,
    output vs_out,
    output hs_out,
    output de_out
);

reg[17: 0]	mult_y_for_r_18b=0;
reg[17: 0]	mult_y_for_g_18b=0;
reg[17: 0]	mult_y_for_b_18b=0;
reg[17: 0]	mult_u_for_r_18b=0;
reg[17: 0]	mult_u_for_g_18b=0;
reg[17: 0]	mult_u_for_b_18b=0;
reg[17: 0]	mult_v_for_r_18b=0;
reg[17: 0]	mult_v_for_g_18b=0;
reg[17: 0]	mult_v_for_b_18b=0;


reg[17: 0]	add_r_0_18b=0;
reg[17: 0]	add_g_0_18b=0;
reg[17: 0]	add_b_0_18b=0;
reg[17: 0]	add_r_1_18b=0;
reg[17: 0]	add_g_1_18b=0;
reg[17: 0]	add_b_1_18b=0;


reg[17: 0] result_r_18b=0;
reg[17: 0] result_g_18b=0;
reg[17: 0] result_b_18b=0;
     
reg[9:0] r_tmp=0;
reg[9:0] g_tmp=0;
reg[9:0] b_tmp=0;

reg vs_r;
reg hs_r;
reg de_r;
reg vs_r2;
reg hs_r2;
reg de_r2;
reg vs_r3;
reg hs_r3;
reg de_r3;
reg vs_r4;
reg hs_r4;
reg de_r4;
/*----------------一级流水-乘法--------------*/
always @(posedge clk)begin
    mult_y_for_r_18b <= ((y_in<<8));
    mult_y_for_g_18b <= ((y_in<<8));
    mult_y_for_b_18b <= ((y_in<<8));
end

always @(posedge clk)begin
    mult_u_for_r_18b <= 18'b0;
    mult_u_for_g_18b <= ((u_in<<6)+(u_in<<4)+(u_in<<3));
    mult_u_for_b_18b <= ((u_in<<8)+(u_in<<7)+(u_in<<6)+(u_in<<2)+(u_in<<1));
end
	
always @(posedge clk)begin
    mult_v_for_r_18b <= ((v_in<<8)+(v_in<<6)+(v_in<<5)+(v_in<<2)+(v_in<<1)+(v_in));
    mult_v_for_g_18b <= ((v_in<<7)+(v_in<<5)+(v_in<<4)+(v_in<<2)+(v_in<<1)+(v_in));
    mult_v_for_b_18b <= 0;
end

always @(posedge clk)begin
    vs_r <= vs_in;
    hs_r <= hs_in;
    de_r <= de_in;
    vs_r2 <= vs_r;
    hs_r2 <= hs_r;
    de_r2 <= de_r;
    vs_r3 <= vs_r2;
    hs_r3 <= hs_r2;
    de_r3 <= de_r2;
    vs_r4 <= vs_r3;
    hs_r4 <= hs_r3;
    de_r4 <= de_r3;
end
/*---------------二级流水-分正负项加--------------*/
always @(posedge clk)begin
    add_r_0_18b <= mult_y_for_r_18b + mult_u_for_r_18b + mult_v_for_r_18b;//+
    add_r_1_18b <= 45940;//-
end
always @(posedge clk)begin
    add_g_0_18b <= mult_y_for_g_18b + 34678;//+
    add_g_1_18b <= mult_u_for_g_18b + mult_v_for_g_18b;//-
end
always @(posedge clk)begin
    add_b_0_18b <= mult_y_for_b_18b + mult_u_for_b_18b + mult_v_for_b_18b;//+
    add_b_1_18b <= 58065;//-
end
/*---------------三级流水-求和--------------*/
assign	sign_r = (add_r_0_18b >= add_r_1_18b);
assign	sign_g = (add_g_0_18b >= add_g_1_18b);
assign	sign_b = (add_b_0_18b >= add_b_1_18b);

always @(posedge clk)begin
    result_r_18b <= sign_r ? (add_r_0_18b - add_r_1_18b) : 18'd0;
    result_g_18b <= sign_g ? (add_g_0_18b - add_g_1_18b) : 18'd0;
    result_b_18b <= sign_b ? (add_b_0_18b - add_b_1_18b) : 18'd0;
end
/*---------------四级流水-进位表示--------------*/
always @(posedge clk)
begin
    r_tmp <= result_r_18b[15:8] + {9'd0,result_r_18b[7]};
    g_tmp <= result_g_18b[15:8] + {9'd0,result_g_18b[7]};
    b_tmp <= result_b_18b[15:8] + {9'd0,result_b_18b[7]};
end
/*----输出----*/
assign	r_out 	= (r_tmp[9:8] == 2'b00) ? r_tmp[7 : 0] : 8'hFF;
assign	g_out 	= (g_tmp[9:8] == 2'b00) ? g_tmp[7 : 0] : 8'hFF;
assign	b_out 	= (b_tmp[9:8] == 2'b00) ? b_tmp[7 : 0] : 8'hFF;
assign  vs_out  =  vs_r4;
assign  hs_out  =  hs_r4;
assign  de_out  =  de_r4;

endmodule