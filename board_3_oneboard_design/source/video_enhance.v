module video_enhance(
input  wire            pix_clk,
input  wire            vs_in,
input  wire            hs_in,
input  wire            de_in,
input  wire [7 : 0]    r_in,
input  wire [7 : 0]    g_in,
input  wire [7 : 0]    b_in,

output wire            vs_out,
output wire            hs_out,
output wire            de_out,
output wire [7 : 0]    r_out,
output wire [7 : 0]    g_out,
output wire [7 : 0]    b_out,

input  wire [7 : 0]   video_enhance_lightdown_num,
input  wire           video_enhance_lightdown_sw ,
input  wire [7 : 0]   video_enhance_darkup_num   ,
input  wire           video_enhance_darkup_sw    

   );

wire [7 : 0] y_out;
wire [7 : 0] u_out;
wire [7 : 0] v_out;

//wire [7 : 0] r_out;
//wire [7 : 0] g_out;
//wire [7 : 0] b_out;

wire         yuv_vs_out;
wire         yuv_hs_out;
wire         yuv_de_out;

rgb2yuv video_enhance_rgb2yuv(
.clk   (pix_clk),//input        
.r_in  (r_in),//input  [7:0] 
.g_in  (g_in),//input  [7:0] 
.b_in  (b_in),//input  [7:0] 
.vs_in (vs_in),//input        
.hs_in (hs_in),//input        
.de_in (de_in),//input        
.y_out (y_out),//output [7:0] 
.u_out (u_out),//output [7:0] 
.v_out (v_out),//output [7:0] 
.vs_out(yuv_vs_out),//output       
.hs_out(yuv_hs_out),//output       
.de_out(yuv_de_out), //output
.video_enhance_lightdown_num(video_enhance_lightdown_num),// input  wire [7 : 0]          
.video_enhance_lightdown_sw (video_enhance_lightdown_sw ),// input  wire           
.video_enhance_darkup_num   (video_enhance_darkup_num   ),// input  wire [7 : 0]   
.video_enhance_darkup_sw    (video_enhance_darkup_sw    ) // input  wire           
         
);

yuv2rgb video_enhance_yuv2rgb(
.clk   (pix_clk),//input       
.y_in  (y_out),//input [7:0] 
.u_in  (u_out),//input [7:0] 
.v_in  (v_out),//input [7:0] 
.vs_in (yuv_vs_out),//input       
.hs_in (yuv_hs_out),//input       
.de_in (yuv_de_out),//input       
.r_out (r_out),//output [7:0]
.g_out (g_out),//output [7:0]
.b_out (b_out),//output [7:0]
.vs_out(vs_out),//output      
.hs_out(hs_out),//output      
.de_out(de_out) //output      
);

endmodule