// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module prbs15_64bit_v1_0 #(
    parameter PRBS_INIT   = 16'h00
)
(
    input         clk            ,
    input         rst_n          ,
    input         prbs_en        ,
    
    input         din_en         ,
    input  [15:0] din            ,
    output [63:0] dout           
);

wire [63:0] Y;
reg  [63:0] O;
wire [15:0] X;

assign  Y[63]    = X[11] ^  X[7]  ^ 1 ;                     //Y[46] ^ Y[45] ^ 1 ;
assign  Y[62]    = X[10] ^  X[6]  ^ 1 ;                     //Y[45] ^ Y[44] ^ 1 ;
assign  Y[61]    = X[9]  ^  X[5]  ^ 1 ;                     //Y[44] ^ Y[43] ^ 1 ;
assign  Y[60]    = X[8]  ^  X[4]  ^ 1 ;                     //Y[43] ^ Y[42] ^ 1 ;
assign  Y[59]    = X[7]  ^  X[3]  ^ 1 ;                     //Y[42] ^ Y[41] ^ 1 ;
assign  Y[58]    = X[6]  ^  X[2]  ^ 1 ;                     //Y[41] ^ Y[40] ^ 1 ;
assign  Y[57]    = X[5]  ^  X[1]  ^ 1 ;                     //Y[40] ^ Y[39] ^ 1 ;
assign  Y[56]    = X[4]  ^  X[0]  ^ 1 ;                     //Y[39] ^ Y[38] ^ 1 ;
assign  Y[55]    = X[3]  ^  X[14] ^ X[13] ;                 //Y[38] ^ Y[37] ^ 1 ;
assign  Y[54]    = X[2]  ^  X[13] ^ X[12] ^ 1;              //Y[37] ^ Y[36] ^ 1 ;
assign  Y[53]    = X[1]  ^  X[12] ^ X[11] ^ 1;              //Y[36] ^ Y[35] ^ 1 ;
assign  Y[52]    = X[0]  ^  X[11] ^ X[10] ;                 //Y[35] ^ Y[34] ^ 1 ;
assign  Y[51]    = X[14] ^  X[10] ^ X[13] ^ X[9] ;          //Y[34] ^ Y[33] ^ 1 ;
assign  Y[50]    = X[13] ^  X[9]  ^ X[12] ^ X[8] ^ 1 ;      //Y[33] ^ Y[32] ^ 1 ;
assign  Y[49]    = X[12] ^  X[11] ^ X[8]  ^ X[7] ;          //Y[32] ^ Y[46] ^ Y[45] ;
assign  Y[48]    = X[11] ^  X[10] ^ X[7]  ^ X[6] ;          //Y[46] ^ Y[44] ;

assign  Y[47]    = X[12] ^  X[10] ^ X[11] ^ X[9]  ^ 1 ;     //Y[30] ^ Y[29] ^ 1 ;
assign  Y[46]    = X[11] ^  X[9]  ^ X[10] ^ X[8]  ^ 1 ;     //Y[29] ^ Y[28] ^ 1 ;
assign  Y[45]    = X[10] ^  X[8]  ^ X[9]  ^ X[7]  ^ 1 ;     //Y[28] ^ Y[27] ^ 1 ;
assign  Y[44]    = X[9]  ^  X[7]  ^ X[8]  ^ X[6]  ^ 1 ;     //Y[27] ^ Y[26] ^ 1 ;
assign  Y[43]    = X[8]  ^  X[6]  ^ X[7]  ^ X[5]  ^ 1 ;     //Y[26] ^ Y[25] ^ 1 ;
assign  Y[42]    = X[7]  ^  X[5]  ^ X[6]  ^ X[4]  ^ 1 ;     //Y[25] ^ Y[24] ^ 1 ;
assign  Y[41]    = X[6]  ^  X[4]  ^ X[5]  ^ X[3]  ^ 1 ;     //Y[24] ^ Y[23] ^ 1 ;
assign  Y[40]    = X[5]  ^  X[3]  ^ X[4]  ^ X[2]  ^ 1 ;     //Y[23] ^ Y[22] ^ 1 ;
assign  Y[39]    = X[4]  ^  X[2]  ^ X[3]  ^ X[1]  ^ 1 ;     //Y[22] ^ Y[21] ^ 1 ;
assign  Y[38]    = X[3]  ^  X[1]  ^ X[2]  ^ X[0]  ^ 1 ;     //Y[21] ^ Y[20] ^ 1 ;
assign  Y[37]    = X[2]  ^  X[0]  ^ X[1]  ^ X[14] ^ X[13] ; //Y[20] ^ Y[19] ^ 1 ;
assign  Y[36]    = X[1]  ^  X[14] ^ X[0]  ^ X[12] ;         //Y[19] ^ Y[18] ^ 1 ;
assign  Y[35]    = X[0]  ^  X[14] ^ X[11] ;                 //Y[18] ^ Y[17] ^ 1 ;
assign  Y[34]    = X[14] ^  X[10] ^ 1 ;                     //Y[17] ^ Y[16] ^ 1 ;
assign  Y[33]    = X[13] ^  X[9]  ^ 0 ;                     //Y[16] ^ Y[30] ^ Y[29] ;
assign  Y[32]    = X[12] ^  X[8]  ^ 0 ;                     //Y[30] ^ Y[28] ;

assign  Y[31]    = X[13] ^  X[11] ^ 1 ;                     //Y[14] ^ Y[13] ^ 1 ;
assign  Y[30]    = X[12] ^  X[10] ^ 1 ;                     //Y[13] ^ Y[12] ^ 1 ;
assign  Y[29]    = X[11] ^  X[9]  ^ 1 ;                     //Y[12] ^ Y[11] ^ 1 ;
assign  Y[28]    = X[10] ^  X[8]  ^ 1 ;                     //Y[11] ^ Y[10] ^ 1 ;
assign  Y[27]    = X[9]  ^  X[7]  ^ 1 ;                     //Y[10] ^ Y[9]  ^ 1 ;
assign  Y[26]    = X[8]  ^  X[6]  ^ 1 ;                     //Y[9]  ^ Y[8]  ^ 1 ;
assign  Y[25]    = X[7]  ^  X[5]  ^ 1 ;                     //Y[8]  ^ Y[7]  ^ 1 ;
assign  Y[24]    = X[6]  ^  X[4]  ^ 1 ;                     //Y[7]  ^ Y[6]  ^ 1 ;
assign  Y[23]    = X[5]  ^  X[3]  ^ 1 ;                     //Y[6]  ^ Y[5]  ^ 1 ;
assign  Y[22]    = X[4]  ^  X[2]  ^ 1 ;                     //Y[5]  ^ Y[4]  ^ 1 ;
assign  Y[21]    = X[3]  ^  X[1]  ^ 1 ;                     //Y[4]  ^ Y[3]  ^ 1 ;
assign  Y[20]    = X[2]  ^  X[0]  ^ 1 ;                     //Y[3]  ^ Y[2]  ^ 1 ;
assign  Y[19]    = X[1]  ^  X[14] ^ X[13] ;                 //Y[2]  ^ Y[1]  ^ 1 ;
assign  Y[18]    = X[0]  ^  X[13] ^ X[12] ^ 1 ;             //Y[1]  ^ Y[0]  ^ 1;
assign  Y[17]    = X[14] ^  X[12] ^ X[13] ^ X[11] ;         //Y[0]  ^ Y[14] ^ Y[13] ;
assign  Y[16]    = X[13] ^  X[12] ^ X[11] ^ X[10] ;         //Y[14] ^ Y[12] ;
//assign  Y[15:2]  = X[14:1] ^ X[13:0] ^ 14'h3fff ;         // Y = X15 + X14 + 1
assign  Y[15]    = X[14] ^  X[13] ^ 1 ;
assign  Y[14]    = X[13] ^  X[12] ^ 1 ;
assign  Y[13]    = X[12] ^  X[11] ^ 1 ;
assign  Y[12]    = X[11] ^  X[10] ^ 1 ;
assign  Y[11]    = X[10] ^  X[9]  ^ 1 ;
assign  Y[10]    = X[9]  ^  X[8]  ^ 1 ;
assign  Y[9]     = X[8]  ^  X[7]  ^ 1 ;
assign  Y[8]     = X[7]  ^  X[6]  ^ 1 ;
assign  Y[7]     = X[6]  ^  X[5]  ^ 1 ;
assign  Y[6]     = X[5]  ^  X[4]  ^ 1 ;
assign  Y[5]     = X[4]  ^  X[3]  ^ 1 ;
assign  Y[4]     = X[3]  ^  X[2]  ^ 1 ;
assign  Y[3]     = X[2]  ^  X[1]  ^ 1 ;
assign  Y[2]     = X[1]  ^  X[0]  ^ 1 ;
assign  Y[1]     = X[0]  ^  X[14] ^ X[13] ^ 0 ;                // X[0] ^ Y[15]  ^ 1;
assign  Y[0]     = X[14] ^  X[12] ^ 0 ;                        // Y[14] ^ Y[15] ^ 1;


assign X = (din_en==1) ? din : O[63:48] ;

always@(posedge clk or negedge rst_n)
begin
   if(!rst_n) begin
      O   <= PRBS_INIT;
   end
   else if (prbs_en) begin
      O   <= Y;
   end
   else begin
      O   <= O;
   end
end

assign dout  = Y;

endmodule