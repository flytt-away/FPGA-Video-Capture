`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:Meyesemi 
// Engineer: Will
// 
// Create Date: 2023-03-17  
// Design Name:  
// Module Name: 
// Project Name: 
// Target Devices: Pango
// Tool Versions: 
// Description: 
//      
// Dependencies: 
// 
// Revision:
// Revision 1.0 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//将两个8bit数据拼成一个16bit RGB565数据；
`timescale 1ns/1ns

module cmos_8_16bit(
	input 				   pclk 		,   
	input 				   rst_n		,
	input				   de_i	        ,
	input	[7:0]	       pdata_i	    ,
    input                  vs_i         ,

    output  wire           pixel_clk    ,
 	output	reg			   de_o         ,
	output  reg [15:0]	   pdata_o
); 
reg			de_out1          ;
reg [15:0]	pdata_out1       ;
reg			de_out2          ;
reg [15:0]	pdata_out2       ;    
reg [1:0]   cnt             ;
wire        pclk_IOCLKBUF   ;
reg         vs_i_reg        ;
reg         enble           ;
reg [7:0] pdata_i_reg;
reg de_i_r,de_i_r1;
reg			de_out3          ;
reg [15:0]	pdata_out3       ;  
always @(posedge pclk)begin
       vs_i_reg <= vs_i ;
end
    always@(posedge pclk)
        begin
            if(!rst_n)
                enble <= 1'b0;
            else if(!vs_i_reg&&vs_i)
                enble <= 1'b1;
            else
                enble <= enble;
        end

GTP_IOCLKBUF #(
    .GATE_EN("FALSE")//
) u_GTP_IOCLKBUF (
    .CLKOUT(pclk_IOCLKBUF),// OUTPUT  
    .CLKIN(pclk), // INPUT  
    .DI(1'b1)     // INPUT  
);

GTP_IOCLKDIV #(
    .GRS_EN("TRUE"),
    .DIV_FACTOR("2")
) u_GTP_IOCLKDIV (
    .CLKDIVOUT(pixel_clk),// OUTPUT  
    .CLKIN(pclk_IOCLKBUF),    // INPUT  
    .RST_N(rst_n)     // INPUT  
);

    always@(posedge pclk)
        begin
            if(!rst_n)
                cnt <= 2'b0;
            else if(de_i == 1'b1 && cnt == 2'd1)
                cnt <= 2'b0;
            else if(de_i == 1'b1)
                cnt <= cnt + 1'b1;
        end
    

    always@(posedge pclk)
        begin
            if(!rst_n)
                pdata_i_reg <= 8'b0;
            else if(de_i == 1'b1)
                pdata_i_reg <= pdata_i;
        end
    
    always@(posedge pclk)
        begin
            if(!rst_n)
                pdata_out1 <= 16'b0;
            else if(de_i == 1'b1 && cnt == 2'd1)
                pdata_out1 <= {pdata_i_reg,pdata_i};
        end
  

   always@(posedge pclk)begin
        de_i_r <= de_i;
        de_i_r1 <= de_i_r;
   end
    always@(posedge pclk)
        begin
            if(!rst_n)
                de_out1 <= 1'b0;
            else if(!de_i_r1 && de_i_r )//上升沿
                de_out1 <= 1'b1;
            else if(de_i_r1 && !de_i_r )//下降沿
                de_out1 <= 1'b0;
            else
                de_out1 <= de_out1;
        end


 
    always@(posedge pixel_clk)begin
        de_out2<=de_out1;
        de_out3<=de_out2;
        de_o   <=de_out3;
    end
    always@(posedge pixel_clk)begin
        pdata_out2<=pdata_out1;
        pdata_out3<=pdata_out2;
        pdata_o   <=pdata_out3;
    end
endmodule