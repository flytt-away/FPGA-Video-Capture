module rgb2yuv(
    input clk,
    input [7:0] r_in,
    input [7:0] g_in,
    input [7:0] b_in,
    input vs_in,
    input hs_in,
    input de_in,
    output [7:0] y_out,
    output [7:0] u_out,
    output [7:0] v_out,
    output vs_out,
    output hs_out,
    output de_out,
    input  wire [7 : 0]   video_enhance_lightdown_num/* synthesis PAP_MARK_DEBUG="1" */,
    input  wire           video_enhance_lightdown_sw /* synthesis PAP_MARK_DEBUG="1" */,
    input  wire [7 : 0]   video_enhance_darkup_num   /* synthesis PAP_MARK_DEBUG="1" */,
    input  wire           video_enhance_darkup_sw   /* synthesis PAP_MARK_DEBUG="1" */
);

reg[15: 0]	mult_r_for_y_16b=0;
reg[15: 0]	mult_r_for_u_16b=0;
reg[15: 0]	mult_r_for_v_16b=0;
reg[15: 0]	mult_g_for_y_16b=0;
reg[15: 0]	mult_g_for_u_16b=0;
reg[15: 0]	mult_g_for_v_16b=0;
reg[15: 0]	mult_b_for_y_16b=0;
reg[15: 0]	mult_b_for_u_16b=0;
reg[15: 0]	mult_b_for_v_16b=0;


reg[15: 0]	add_y_16b=0;
reg[15: 0]	add_u_16b=0;
reg[15: 0]	add_v_16b=0;
     
reg[15:0] y_tmp=0/* synthesis PAP_MARK_DEBUG="1" */;
reg[7:0] u_tmp=0;
reg[7:0] v_tmp=0;

reg vs_r/* synthesis PAP_MARK_DEBUG="1" */;
reg hs_r/* synthesis PAP_MARK_DEBUG="1" */;
reg de_r/* synthesis PAP_MARK_DEBUG="1" */;
reg vs_r2/* synthesis PAP_MARK_DEBUG="1" */;
reg hs_r2/* synthesis PAP_MARK_DEBUG="1" */;
reg de_r2/* synthesis PAP_MARK_DEBUG="1" */;
reg vs_r3/* synthesis PAP_MARK_DEBUG="1" */;
reg hs_r3/* synthesis PAP_MARK_DEBUG="1" */;
reg de_r3/* synthesis PAP_MARK_DEBUG="1" */;

wire y_big;
wire [4:0]add/* synthesis PAP_MARK_DEBUG="1" */;
wire [4:0]sub/* synthesis PAP_MARK_DEBUG="1" */;
/*----------------一级流水-乘法--------------*/
always @(posedge clk)begin
    mult_r_for_y_16b <= ((r_in<<6)+(r_in<<3)+(r_in<<2)+(r_in));
    mult_r_for_u_16b <= ((r_in<<5)+(r_in<<3)+(r_in<<1)+(r_in));
    mult_r_for_v_16b <= ((r_in<<7));
end

always @(posedge clk)begin
    mult_g_for_y_16b <= ((g_in<<7)+(g_in<<4)+(g_in<<2)+(g_in<<1));
    mult_g_for_u_16b <= ((g_in<<6)+(g_in<<4)+(g_in<<2)+(g_in));
    mult_g_for_v_16b <= ((g_in<<6)+(g_in<<5)+(g_in<<3)+(g_in<<1)+(g_in));
end
	
always @(posedge clk)begin
    mult_b_for_y_16b <= ((b_in<<4)+(b_in<<3)+(b_in<<2)+(b_in));
    mult_b_for_u_16b <= ((b_in<<7));
    mult_b_for_v_16b <= ((b_in<<4)+(b_in<<2)+(b_in));
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
end
/*---------------二级流水-分正负项加--------------*/
always @(posedge clk)begin
    add_y_16b <= mult_r_for_y_16b + mult_g_for_y_16b + mult_b_for_y_16b;
end
always @(posedge clk)begin
    add_u_16b <= - mult_r_for_u_16b - mult_g_for_u_16b + mult_b_for_u_16b + 32768;
end
always @(posedge clk)begin
    add_v_16b <= mult_r_for_v_16b - mult_g_for_v_16b - mult_b_for_v_16b + 32768;
end
/*---------------三级流水-进位表示--------------*/
always @(posedge clk)
begin
    y_tmp <= add_y_16b[15:8] + {7'd0,add_y_16b[7]};
    //y_tmp <= add_y_16b[15:8] * add_y_16b[15:8];
    u_tmp <= add_u_16b[15:8] + {7'd0,add_u_16b[7]};
    v_tmp <= add_v_16b[15:8] + {7'd0,add_v_16b[7]};
end
/*----输出----*/

assign  add     = video_enhance_darkup_sw    ? ((y_tmp[7:0] > video_enhance_darkup_num   ) ? 0 : ((video_enhance_darkup_num - y_tmp[7:0])>>3))    : 0;
assign  sub     = video_enhance_lightdown_sw ? ((y_tmp[7:0] < video_enhance_lightdown_num) ? 0 : ((y_tmp[7:0] - video_enhance_lightdown_num)>>3)) : 0;
//assign	y_out 	= (y_tmp <= 128) ? y_tmp[7:0]+8'b0001_0000 : y_tmp[7:0]-8'b0001_0000;
//assign	y_out 	= (y_tmp[7:0] > 222) ? y_tmp[7:0] : y_tmp[7:0] + 32;
//assign	y_out 	= y_tmp[7:0];
assign	y_out 	=  y_tmp[7:0] + add - sub;//;
assign	u_out 	= u_tmp[7:0];
assign	v_out 	= v_tmp[7:0];
assign  vs_out  =  vs_r3;
assign  hs_out  =  hs_r3;
assign  de_out  =  de_r3;

endmodule