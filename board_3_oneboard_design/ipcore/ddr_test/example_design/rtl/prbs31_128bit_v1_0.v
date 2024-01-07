//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS RESERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TQ PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
/////////////////////////////////////////////////////////////////////////////
// Revision:1.0(initial)
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module prbs31_128bit_v1_0 #(
    parameter PRBS_INIT = 128'b0,
    parameter PRBS_GEN_EN = 1'b0
)(
input clk,
input rstn,
input clk_en,

input cnt_mode,
input [127:0] din,
output [127:0] dout,
input insert_er,
output reg error
);

wire [128:1] Y;
wire [128:1] X;
wire [128:1] y_comb;
reg  [128:1] latch_y_all;
reg  [128:1] latch_y;
reg  [2:0] insert_er_d;

assign  Y[128] = X[31] ^ X[28] ^ 1 ;
assign  Y[127] = X[30] ^ X[27] ^ 1 ;
assign  Y[126] = X[29] ^ X[26] ^ 1 ;
assign  Y[125] = X[28] ^ X[25] ^ 1 ;
assign  Y[124] = X[27] ^ X[24] ^ 1 ;
assign  Y[123] = X[26] ^ X[23] ^ 1 ;
assign  Y[122] = X[25] ^ X[22] ^ 1 ;
assign  Y[121] = X[24] ^ X[21] ^ 1 ;
assign  Y[120] = X[23] ^ X[20] ^ 1 ;
assign  Y[119] = X[22] ^ X[19] ^ 1 ;
assign  Y[118] = X[21] ^ X[18] ^ 1 ;
assign  Y[117] = X[20] ^ X[17] ^ 1 ;
assign  Y[116] = X[19] ^ X[16] ^ 1 ;
assign  Y[115] = X[18] ^ X[15] ^ 1 ;
assign  Y[114] = X[17] ^ X[14] ^ 1 ;
assign  Y[113] = X[16] ^ X[13] ^ 1 ;
assign  Y[112] = X[15] ^ X[12] ^ 1 ;
assign  Y[111] = X[14] ^ X[11] ^ 1 ;
assign  Y[110] = X[13] ^ X[10] ^ 1 ;
assign  Y[109] = X[12] ^ X[9] ^ 1 ;
assign  Y[108] = X[11] ^ X[8] ^ 1 ;
assign  Y[107] = X[10] ^ X[7] ^ 1 ;
assign  Y[106] = X[9] ^ X[6] ^ 1 ;
assign  Y[105] = X[8] ^ X[5] ^ 1 ;
assign  Y[104] = X[7] ^ X[4] ^ 1 ;
assign  Y[103] = X[6] ^ X[3] ^ 1 ;
assign  Y[102] = X[5] ^ X[2] ^ 1 ;
assign  Y[101] = X[4] ^ X[1] ^ 1 ;
assign  Y[100] = X[31] ^ X[28] ^ X[3] ^ 0 ;
assign  Y[99] = X[30] ^ X[27] ^ X[2] ^ 0 ;
assign  Y[98] = X[29] ^ X[26] ^ X[1] ^ 0 ;
assign  Y[97] = X[31] ^ X[25] ^ 1 ;
assign  Y[96] = X[30] ^ X[24] ^ 1 ;
assign  Y[95] = X[29] ^ X[23] ^ 1 ;
assign  Y[94] = X[28] ^ X[22] ^ 1 ;
assign  Y[93] = X[27] ^ X[21] ^ 1 ;
assign  Y[92] = X[26] ^ X[20] ^ 1 ;
assign  Y[91] = X[25] ^ X[19] ^ 1 ;
assign  Y[90] = X[24] ^ X[18] ^ 1 ;
assign  Y[89] = X[23] ^ X[17] ^ 1 ;
assign  Y[88] = X[22] ^ X[16] ^ 1 ;
assign  Y[87] = X[21] ^ X[15] ^ 1 ;
assign  Y[86] = X[20] ^ X[14] ^ 1 ;
assign  Y[85] = X[19] ^ X[13] ^ 1 ;
assign  Y[84] = X[18] ^ X[12] ^ 1 ;
assign  Y[83] = X[17] ^ X[11] ^ 1 ;
assign  Y[82] = X[16] ^ X[10] ^ 1 ;
assign  Y[81] = X[15] ^ X[9] ^ 1 ;
assign  Y[80] = X[14] ^ X[8] ^ 1 ;
assign  Y[79] = X[13] ^ X[7] ^ 1 ;
assign  Y[78] = X[12] ^ X[6] ^ 1 ;
assign  Y[77] = X[11] ^ X[5] ^ 1 ;
assign  Y[76] = X[10] ^ X[4] ^ 1 ;
assign  Y[75] = X[9] ^ X[3] ^ 1 ;
assign  Y[74] = X[8] ^ X[2] ^ 1 ;
assign  Y[73] = X[7] ^ X[1] ^ 1 ;
assign  Y[72] = X[31] ^ X[28] ^ X[6] ^ 0 ;
assign  Y[71] = X[30] ^ X[27] ^ X[5] ^ 0 ;
assign  Y[70] = X[29] ^ X[26] ^ X[4] ^ 0 ;
assign  Y[69] = X[28] ^ X[25] ^ X[3] ^ 0 ;
assign  Y[68] = X[27] ^ X[24] ^ X[2] ^ 0 ;
assign  Y[67] = X[26] ^ X[23] ^ X[1] ^ 0 ;
assign  Y[66] = X[31] ^ X[28] ^ X[25] ^ X[22] ^ 1 ;
assign  Y[65] = X[30] ^ X[27] ^ X[24] ^ X[21] ^ 1 ;
assign  Y[64] = X[29] ^ X[26] ^ X[23] ^ X[20] ^ 1 ;
assign  Y[63] = X[28] ^ X[25] ^ X[22] ^ X[19] ^ 1 ;
assign  Y[62] = X[27] ^ X[24] ^ X[21] ^ X[18] ^ 1 ;
assign  Y[61] = X[26] ^ X[23] ^ X[20] ^ X[17] ^ 1 ;
assign  Y[60] = X[25] ^ X[22] ^ X[19] ^ X[16] ^ 1 ;
assign  Y[59] = X[24] ^ X[21] ^ X[18] ^ X[15] ^ 1 ;
assign  Y[58] = X[23] ^ X[20] ^ X[17] ^ X[14] ^ 1 ;
assign  Y[57] = X[22] ^ X[19] ^ X[16] ^ X[13] ^ 1 ;
assign  Y[56] = X[21] ^ X[18] ^ X[15] ^ X[12] ^ 1 ;
assign  Y[55] = X[20] ^ X[17] ^ X[14] ^ X[11] ^ 1 ;
assign  Y[54] = X[19] ^ X[16] ^ X[13] ^ X[10] ^ 1 ;
assign  Y[53] = X[18] ^ X[15] ^ X[12] ^ X[9] ^ 1 ;
assign  Y[52] = X[17] ^ X[14] ^ X[11] ^ X[8] ^ 1 ;
assign  Y[51] = X[16] ^ X[13] ^ X[10] ^ X[7] ^ 1 ;
assign  Y[50] = X[15] ^ X[12] ^ X[9] ^ X[6] ^ 1 ;
assign  Y[49] = X[14] ^ X[11] ^ X[8] ^ X[5] ^ 1 ;
assign  Y[48] = X[13] ^ X[10] ^ X[7] ^ X[4] ^ 1 ;
assign  Y[47] = X[12] ^ X[9] ^ X[6] ^ X[3] ^ 1 ;
assign  Y[46] = X[11] ^ X[8] ^ X[5] ^ X[2] ^ 1 ;
assign  Y[45] = X[10] ^ X[7] ^ X[4] ^ X[1] ^ 1 ;
assign  Y[44] = X[31] ^ X[28] ^ X[9] ^ X[6] ^ X[3] ^ 0 ;
assign  Y[43] = X[30] ^ X[27] ^ X[8] ^ X[5] ^ X[2] ^ 0 ;
assign  Y[42] = X[29] ^ X[26] ^ X[7] ^ X[4] ^ X[1] ^ 0 ;
assign  Y[41] = X[31] ^ X[25] ^ X[6] ^ X[3] ^ 1 ;
assign  Y[40] = X[30] ^ X[24] ^ X[5] ^ X[2] ^ 1 ;
assign  Y[39] = X[29] ^ X[23] ^ X[4] ^ X[1] ^ 1 ;
assign  Y[38] = X[31] ^ X[22] ^ X[3] ^ 0 ;
assign  Y[37] = X[30] ^ X[21] ^ X[2] ^ 0 ;
assign  Y[36] = X[29] ^ X[20] ^ X[1] ^ 0 ;
assign  Y[35] = X[31] ^ X[19] ^ 1 ;
assign  Y[34] = X[30] ^ X[18] ^ 1 ;
assign  Y[33] = X[29] ^ X[17] ^ 1 ;
assign  Y[32] = X[28] ^ X[16] ^ 1 ;
assign  Y[31] = X[27] ^ X[15] ^ 1 ;
assign  Y[30] = X[26] ^ X[14] ^ 1 ;
assign  Y[29] = X[25] ^ X[13] ^ 1 ;
assign  Y[28] = X[24] ^ X[12] ^ 1 ;
assign  Y[27] = X[23] ^ X[11] ^ 1 ;
assign  Y[26] = X[22] ^ X[10] ^ 1 ;
assign  Y[25] = X[21] ^ X[9] ^ 1 ;
assign  Y[24] = X[20] ^ X[8] ^ 1 ;
assign  Y[23] = X[19] ^ X[7] ^ 1 ;
assign  Y[22] = X[18] ^ X[6] ^ 1 ;
assign  Y[21] = X[17] ^ X[5] ^ 1 ;
assign  Y[20] = X[16] ^ X[4] ^ 1 ;
assign  Y[19] = X[15] ^ X[3] ^ 1 ;
assign  Y[18] = X[14] ^ X[2] ^ 1 ;
assign  Y[17] = X[13] ^ X[1] ^ 1 ;
assign  Y[16] = X[31] ^ X[28] ^ X[12] ^ 0 ;
assign  Y[15] = X[30] ^ X[27] ^ X[11] ^ 0 ;
assign  Y[14] = X[29] ^ X[26] ^ X[10] ^ 0 ;
assign  Y[13] = X[28] ^ X[25] ^ X[9] ^ 0 ;
assign  Y[12] = X[27] ^ X[24] ^ X[8] ^ 0 ;
assign  Y[11] = X[26] ^ X[23] ^ X[7] ^ 0 ;
assign  Y[10] = X[25] ^ X[22] ^ X[6] ^ 0 ;
assign  Y[9] = X[24] ^ X[21] ^ X[5] ^ 0 ;
assign  Y[8] = X[23] ^ X[20] ^ X[4] ^ 0 ;
assign  Y[7] = X[22] ^ X[19] ^ X[3] ^ 0 ;
assign  Y[6] = X[21] ^ X[18] ^ X[2] ^ 0 ;
assign  Y[5] = X[20] ^ X[17] ^ X[1] ^ 0 ;
assign  Y[4] = X[31] ^ X[28] ^ X[19] ^ X[16] ^ 1 ;
assign  Y[3] = X[30] ^ X[27] ^ X[18] ^ X[15] ^ 1 ;
assign  Y[2] = X[29] ^ X[26] ^ X[17] ^ X[14] ^ 1 ;
assign  Y[1] = X[28] ^ X[25] ^ X[16] ^ X[13] ^ 1 ;

assign y_comb[128:1] = cnt_mode ? (latch_y + 128'b1) : (PRBS_GEN_EN ? Y[128:1] : din[127:0]);

always @(posedge clk or negedge rstn)
   if (!rstn) begin
      latch_y         <= PRBS_INIT;
      latch_y_all     <= PRBS_INIT;
   end
   else if (clk_en) begin
      latch_y         <= y_comb; 
      latch_y_all     <= Y;
   end
   
always @(posedge clk or negedge rstn)
   if (!rstn) begin
      insert_er_d       <= 3'b0;
      error            <= 1'b0;
   end
   else if (clk_en) begin
      insert_er_d       <= {insert_er_d[1:0], insert_er};
      error            <= latch_y_all != latch_y; //for cfg_prbs_mode 1~6
   end

assign X = latch_y;

assign dout[127:1]  = X[128:2];

assign dout[0] = (insert_er_d[2] ^ insert_er_d[1]) ? (~X[1]) : X[1];

endmodule
