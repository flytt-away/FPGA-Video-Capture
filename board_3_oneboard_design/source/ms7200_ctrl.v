`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:Meyesemi 
// Engineer: Will
// 
// Create Date: 2023-01-29 20:31  
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
`define UD #1
module ms7200_ctrl(
    input               clk,
    input               rstn,
                        
    output reg          init_over,
    output        [7:0] device_id,
    output reg          iic_trig ,
    output reg          w_r      ,
    output reg   [15:0] addr     ,
    output reg   [ 7:0] data_in  ,
    input               busy     ,
    input        [ 7:0] data_out ,
    input               byte_over 
);
    assign device_id = 8'h56;
function [23:0] cmd_data;
input [9:0] index;
    begin
        case(index)
            9'd0   : cmd_data = {16'h0204, 8'h02};
            9'd1   : cmd_data = {16'h0205, 8'h40};
            9'd2   : cmd_data = {16'h0004, 8'h01};
            9'd3   : cmd_data = {16'h0009, 8'h26};
            9'd4   : cmd_data = {16'h102E, 8'h01};
            9'd5   : cmd_data = {16'h1025, 8'hB0};
            9'd6   : cmd_data = {16'h102D, 8'h83};
            9'd7   : cmd_data = {16'h1000, 8'h20};
            9'd8   : cmd_data = {16'h100F, 8'h04};
            9'd9   : cmd_data = {16'h0003, 8'hC3};
            9'd10  : cmd_data = {16'h103B, 8'h02};
            9'd11  : cmd_data = {16'h00E1, 8'h00};
            9'd12  : cmd_data = {16'h00A8, 8'h08};
            9'd13  : cmd_data = {16'h000A, 8'h00};
            9'd14  : cmd_data = {16'h0016, 8'h02};
            9'd15  : cmd_data = {16'h00E2, 8'h01};
            9'd16  : cmd_data = {16'h00C2, 8'h14};
            9'd17  : cmd_data = {16'h102D, 8'hC7};
            9'd18  : cmd_data = {16'h1005, 8'h04};
            9'd19  : cmd_data = {16'h1003, 8'h14};
            9'd20  : cmd_data = {16'h1004, 8'h01};
            9'd21  : cmd_data = {16'h1000, 8'h60};
            9'd22  : cmd_data = {16'h1020, 8'h13};
            9'd23  : cmd_data = {16'h1021, 8'h04};
            9'd24  : cmd_data = {16'h1022, 8'h04};
            9'd25  : cmd_data = {16'h1023, 8'h0C};
            9'd26  : cmd_data = {16'h102B, 8'h33};
            9'd27  : cmd_data = {16'h102C, 8'h33};
            9'd28  : cmd_data = {16'h00F0, 8'h10};
            9'd29  : cmd_data = {16'h000C, 8'h80};
            9'd30  : cmd_data = {16'h0D00, 8'h00};
            9'd31  : cmd_data = {16'h0D01, 8'hFF};
            9'd32  : cmd_data = {16'h0D02, 8'hFF};
            9'd33  : cmd_data = {16'h0D03, 8'hFF};
            9'd34  : cmd_data = {16'h0D04, 8'hFF};
            9'd35  : cmd_data = {16'h0D05, 8'hFF};
            9'd36  : cmd_data = {16'h0D06, 8'hFF};
            9'd37  : cmd_data = {16'h0D07, 8'h00};
            9'd38  : cmd_data = {16'h0D00, 8'h00};
            9'd39  : cmd_data = {16'h0D01, 8'hFF};
            9'd40  : cmd_data = {16'h0D02, 8'hFF};
            9'd41  : cmd_data = {16'h0D03, 8'hFF};
            9'd42  : cmd_data = {16'h0D04, 8'hFF};
            9'd43  : cmd_data = {16'h0D05, 8'hFF};
            9'd44  : cmd_data = {16'h0D06, 8'hFF};
            9'd45  : cmd_data = {16'h0D07, 8'h00};
            9'd46  : cmd_data = {16'h0D08, 8'h4C};
            9'd47  : cmd_data = {16'h0D09, 8'h2D};
            9'd48  : cmd_data = {16'h0D0A, 8'hFF};
            9'd49  : cmd_data = {16'h0D0B, 8'h0D};
            9'd50  : cmd_data = {16'h0D0C, 8'h58};
            9'd51  : cmd_data = {16'h0D0D, 8'h4D};
            9'd52  : cmd_data = {16'h0D0E, 8'h51};
            9'd53  : cmd_data = {16'h0D0F, 8'h30};
            9'd54  : cmd_data = {16'h0D10, 8'h1C};
            9'd55  : cmd_data = {16'h0D11, 8'h1C};
            9'd56  : cmd_data = {16'h0D12, 8'h01};
            9'd57  : cmd_data = {16'h0D13, 8'h03};
            9'd58  : cmd_data = {16'h0D14, 8'h80};
            9'd59  : cmd_data = {16'h0D15, 8'h3D};
            9'd60  : cmd_data = {16'h0D16, 8'h23};
            9'd61  : cmd_data = {16'h0D17, 8'h78};
            9'd62  : cmd_data = {16'h0D18, 8'h2A};
            9'd63  : cmd_data = {16'h0D19, 8'h5F};
            9'd64  : cmd_data = {16'h0D1A, 8'hB1};
            9'd65  : cmd_data = {16'h0D1B, 8'hA2};
            9'd66  : cmd_data = {16'h0D1C, 8'h57};
            9'd67  : cmd_data = {16'h0D1D, 8'h4F};
            9'd68  : cmd_data = {16'h0D1E, 8'hA2};
            9'd69  : cmd_data = {16'h0D1F, 8'h28};
            9'd70  : cmd_data = {16'h0D20, 8'h0F};
            9'd71  : cmd_data = {16'h0D21, 8'h50};
            9'd72  : cmd_data = {16'h0D22, 8'h54};
            9'd73  : cmd_data = {16'h0D23, 8'hBF};
            9'd74  : cmd_data = {16'h0D24, 8'hEF};
            9'd75  : cmd_data = {16'h0D25, 8'h80};
            9'd76  : cmd_data = {16'h0D26, 8'h71};
            9'd77  : cmd_data = {16'h0D27, 8'h4F};
            9'd78  : cmd_data = {16'h0D28, 8'h81};
            9'd79  : cmd_data = {16'h0D29, 8'h00};
            9'd80  : cmd_data = {16'h0D2A, 8'h81};
            9'd81  : cmd_data = {16'h0D2B, 8'hC0};
            9'd82  : cmd_data = {16'h0D2C, 8'h81};
            9'd83  : cmd_data = {16'h0D2D, 8'h80};
            9'd84  : cmd_data = {16'h0D2E, 8'h95};
            9'd85  : cmd_data = {16'h0D2F, 8'h00};
            9'd86  : cmd_data = {16'h0D30, 8'hA9};
            9'd87  : cmd_data = {16'h0D31, 8'hC0};
            9'd88  : cmd_data = {16'h0D32, 8'hB3};
            9'd89  : cmd_data = {16'h0D33, 8'h00};
            9'd90  : cmd_data = {16'h0D34, 8'h01};
            9'd91  : cmd_data = {16'h0D35, 8'h01};
            9'd92  : cmd_data = {16'h0D36, 8'h04};
            9'd93  : cmd_data = {16'h0D37, 8'h74};
            9'd94  : cmd_data = {16'h0D38, 8'h00};
            9'd95  : cmd_data = {16'h0D39, 8'h30};
            9'd96  : cmd_data = {16'h0D3A, 8'hF2};
            9'd97  : cmd_data = {16'h0D3B, 8'h70};
            9'd98  : cmd_data = {16'h0D3C, 8'h5A};
            9'd99  : cmd_data = {16'h0D3D, 8'h80};
            9'd100 : cmd_data = {16'h0D3E, 8'hB0};
            9'd101 : cmd_data = {16'h0D3F, 8'h58};
            9'd102 : cmd_data = {16'h0D40, 8'h8A};
            9'd103 : cmd_data = {16'h0D41, 8'h00};
            9'd104 : cmd_data = {16'h0D42, 8'h60};
            9'd105 : cmd_data = {16'h0D43, 8'h59};
            9'd106 : cmd_data = {16'h0D44, 8'h21};
            9'd107 : cmd_data = {16'h0D45, 8'h00};
            9'd108 : cmd_data = {16'h0D46, 8'h00};
            9'd109 : cmd_data = {16'h0D47, 8'h1E};
            9'd110 : cmd_data = {16'h0D48, 8'h00};
            9'd111 : cmd_data = {16'h0D49, 8'h00};
            9'd112 : cmd_data = {16'h0D4A, 8'h00};
            9'd113 : cmd_data = {16'h0D4B, 8'hFD};
            9'd114 : cmd_data = {16'h0D4C, 8'h00};
            9'd115 : cmd_data = {16'h0D4D, 8'h18};
            9'd116 : cmd_data = {16'h0D4E, 8'h4B};
            9'd117 : cmd_data = {16'h0D4F, 8'h1E};
            9'd118 : cmd_data = {16'h0D50, 8'h5A};
            9'd119 : cmd_data = {16'h0D51, 8'h1E};
            9'd120 : cmd_data = {16'h0D52, 8'h00};
            9'd121 : cmd_data = {16'h0D53, 8'h0A};
            9'd122 : cmd_data = {16'h0D54, 8'h20};
            9'd123 : cmd_data = {16'h0D55, 8'h20};
            9'd124 : cmd_data = {16'h0D56, 8'h20};
            9'd125 : cmd_data = {16'h0D57, 8'h20};
            9'd126 : cmd_data = {16'h0D58, 8'h20};
            9'd127 : cmd_data = {16'h0D59, 8'h20};
            9'd128 : cmd_data = {16'h0D5A, 8'h00};
            9'd129 : cmd_data = {16'h0D5B, 8'h00};
            9'd130 : cmd_data = {16'h0D5C, 8'h00};
            9'd131 : cmd_data = {16'h0D5D, 8'hFC};
            9'd132 : cmd_data = {16'h0D5E, 8'h00};
            9'd133 : cmd_data = {16'h0D5F, 8'h55};
            9'd134 : cmd_data = {16'h0D60, 8'h32};
            9'd135 : cmd_data = {16'h0D61, 8'h38};
            9'd136 : cmd_data = {16'h0D62, 8'h48};
            9'd137 : cmd_data = {16'h0D63, 8'h37};
            9'd138 : cmd_data = {16'h0D64, 8'h35};
            9'd139 : cmd_data = {16'h0D65, 8'h78};
            9'd140 : cmd_data = {16'h0D66, 8'h0A};
            9'd141 : cmd_data = {16'h0D67, 8'h20};
            9'd142 : cmd_data = {16'h0D68, 8'h20};
            9'd143 : cmd_data = {16'h0D69, 8'h20};
            9'd144 : cmd_data = {16'h0D6A, 8'h20};
            9'd145 : cmd_data = {16'h0D6B, 8'h20};
            9'd146 : cmd_data = {16'h0D6C, 8'h00};
            9'd147 : cmd_data = {16'h0D6D, 8'h00};
            9'd148 : cmd_data = {16'h0D6E, 8'h00};
            9'd149 : cmd_data = {16'h0D6F, 8'hFF};
            9'd150 : cmd_data = {16'h0D70, 8'h00};
            9'd151 : cmd_data = {16'h0D71, 8'h48};
            9'd152 : cmd_data = {16'h0D72, 8'h54};
            9'd153 : cmd_data = {16'h0D73, 8'h50};
            9'd154 : cmd_data = {16'h0D74, 8'h4B};
            9'd155 : cmd_data = {16'h0D75, 8'h37};
            9'd156 : cmd_data = {16'h0D76, 8'h30};
            9'd157 : cmd_data = {16'h0D77, 8'h30};
            9'd158 : cmd_data = {16'h0D78, 8'h30};
            9'd159 : cmd_data = {16'h0D79, 8'h35};
            9'd160 : cmd_data = {16'h0D7A, 8'h31};
            9'd161 : cmd_data = {16'h0D7B, 8'h0A};
            9'd162 : cmd_data = {16'h0D7C, 8'h20};
            9'd163 : cmd_data = {16'h0D7D, 8'h20};
            9'd164 : cmd_data = {16'h0D7E, 8'h01};
            9'd165 : cmd_data = {16'h0D7F, 8'hF7};
            9'd166 : cmd_data = {16'h0D80, 8'h02};
            9'd167 : cmd_data = {16'h0D81, 8'h03};
            9'd168 : cmd_data = {16'h0D82, 8'h26};
            9'd169 : cmd_data = {16'h0D83, 8'hF0};
            9'd170 : cmd_data = {16'h0D84, 8'h4B};
            9'd171 : cmd_data = {16'h0D85, 8'h5F};
            9'd172 : cmd_data = {16'h0D86, 8'h10};
            9'd173 : cmd_data = {16'h0D87, 8'h04};
            9'd174 : cmd_data = {16'h0D88, 8'h1F};
            9'd175 : cmd_data = {16'h0D89, 8'h13};
            9'd176 : cmd_data = {16'h0D8A, 8'h03};
            9'd177 : cmd_data = {16'h0D8B, 8'h12};
            9'd178 : cmd_data = {16'h0D8C, 8'h20};
            9'd179 : cmd_data = {16'h0D8D, 8'h22};
            9'd180 : cmd_data = {16'h0D8E, 8'h5E};
            9'd181 : cmd_data = {16'h0D8F, 8'h5D};
            9'd182 : cmd_data = {16'h0D90, 8'h23};
            9'd183 : cmd_data = {16'h0D91, 8'h09};
            9'd184 : cmd_data = {16'h0D92, 8'h07};
            9'd185 : cmd_data = {16'h0D93, 8'h07};
            9'd186 : cmd_data = {16'h0D94, 8'h83};
            9'd187 : cmd_data = {16'h0D95, 8'h01};
            9'd188 : cmd_data = {16'h0D96, 8'h00};
            9'd189 : cmd_data = {16'h0D97, 8'h00};
            9'd190 : cmd_data = {16'h0D98, 8'h6D};
            9'd191 : cmd_data = {16'h0D99, 8'h03};
            9'd192 : cmd_data = {16'h0D9A, 8'h0C};
            9'd193 : cmd_data = {16'h0D9B, 8'h00};
            9'd194 : cmd_data = {16'h0D9C, 8'h10};
            9'd195 : cmd_data = {16'h0D9D, 8'h00};
            9'd196 : cmd_data = {16'h0D9E, 8'h80};
            9'd197 : cmd_data = {16'h0D9F, 8'h3C};
            9'd198 : cmd_data = {16'h0DA0, 8'h20};
            9'd199 : cmd_data = {16'h0DA1, 8'h10};
            9'd200 : cmd_data = {16'h0DA2, 8'h60};
            9'd201 : cmd_data = {16'h0DA3, 8'h01};
            9'd202 : cmd_data = {16'h0DA4, 8'h02};
            9'd203 : cmd_data = {16'h0DA5, 8'h03};
            9'd204 : cmd_data = {16'h0DA6, 8'h02};
            9'd205 : cmd_data = {16'h0DA7, 8'h3A};
            9'd206 : cmd_data = {16'h0DA8, 8'h80};
            9'd207 : cmd_data = {16'h0DA9, 8'h18};
            9'd208 : cmd_data = {16'h0DAA, 8'h71};
            9'd209 : cmd_data = {16'h0DAB, 8'h38};
            9'd210 : cmd_data = {16'h0DAC, 8'h2D};
            9'd211 : cmd_data = {16'h0DAD, 8'h40};
            9'd212 : cmd_data = {16'h0DAE, 8'h58};
            9'd213 : cmd_data = {16'h0DAF, 8'h2C};
            9'd214 : cmd_data = {16'h0DB0, 8'h45};
            9'd215 : cmd_data = {16'h0DB1, 8'h00};
            9'd216 : cmd_data = {16'h0DB2, 8'h60};
            9'd217 : cmd_data = {16'h0DB3, 8'h59};
            9'd218 : cmd_data = {16'h0DB4, 8'h21};
            9'd219 : cmd_data = {16'h0DB5, 8'h00};
            9'd220 : cmd_data = {16'h0DB6, 8'h00};
            9'd221 : cmd_data = {16'h0DB7, 8'h1E};
            9'd222 : cmd_data = {16'h0DB8, 8'h02};
            9'd223 : cmd_data = {16'h0DB9, 8'h3A};
            9'd224 : cmd_data = {16'h0DBA, 8'h80};
            9'd225 : cmd_data = {16'h0DBB, 8'hD0};
            9'd226 : cmd_data = {16'h0DBC, 8'h72};
            9'd227 : cmd_data = {16'h0DBD, 8'h38};
            9'd228 : cmd_data = {16'h0DBE, 8'h2D};
            9'd229 : cmd_data = {16'h0DBF, 8'h40};
            9'd230 : cmd_data = {16'h0DC0, 8'h10};
            9'd231 : cmd_data = {16'h0DC1, 8'h2C};
            9'd232 : cmd_data = {16'h0DC2, 8'h45};
            9'd233 : cmd_data = {16'h0DC3, 8'h80};
            9'd234 : cmd_data = {16'h0DC4, 8'h60};
            9'd235 : cmd_data = {16'h0DC5, 8'h59};
            9'd236 : cmd_data = {16'h0DC6, 8'h21};
            9'd237 : cmd_data = {16'h0DC7, 8'h00};
            9'd238 : cmd_data = {16'h0DC8, 8'h00};
            9'd239 : cmd_data = {16'h0DC9, 8'h1E};
            9'd240 : cmd_data = {16'h0DCA, 8'h01};
            9'd241 : cmd_data = {16'h0DCB, 8'h1D};
            9'd242 : cmd_data = {16'h0DCC, 8'h00};
            9'd243 : cmd_data = {16'h0DCD, 8'h72};
            9'd244 : cmd_data = {16'h0DCE, 8'h51};
            9'd245 : cmd_data = {16'h0DCF, 8'hD0};
            9'd246 : cmd_data = {16'h0DD0, 8'h1E};
            9'd247 : cmd_data = {16'h0DD1, 8'h20};
            9'd248 : cmd_data = {16'h0DD2, 8'h6E};
            9'd249 : cmd_data = {16'h0DD3, 8'h28};
            9'd250 : cmd_data = {16'h0DD4, 8'h55};
            9'd251 : cmd_data = {16'h0DD5, 8'h00};
            9'd252 : cmd_data = {16'h0DD6, 8'h60};
            9'd253 : cmd_data = {16'h0DD7, 8'h59};
            9'd254 : cmd_data = {16'h0DD8, 8'h21};
            9'd255 : cmd_data = {16'h0DD9, 8'h00};
            9'd256 : cmd_data = {16'h0DDA, 8'h00};
            9'd257 : cmd_data = {16'h0DDB, 8'h1E};
            9'd258 : cmd_data = {16'h0DDC, 8'h56};
            9'd259 : cmd_data = {16'h0DDD, 8'h5E};
            9'd260 : cmd_data = {16'h0DDE, 8'h00};
            9'd261 : cmd_data = {16'h0DDF, 8'hA0};
            9'd262 : cmd_data = {16'h0DE0, 8'hA0};
            9'd263 : cmd_data = {16'h0DE1, 8'hA0};
            9'd264 : cmd_data = {16'h0DE2, 8'h29};
            9'd265 : cmd_data = {16'h0DE3, 8'h50};
            9'd266 : cmd_data = {16'h0DE4, 8'h30};
            9'd267 : cmd_data = {16'h0DE5, 8'h20};
            9'd268 : cmd_data = {16'h0DE6, 8'h35};
            9'd269 : cmd_data = {16'h0DE7, 8'h00};
            9'd270 : cmd_data = {16'h0DE8, 8'h60};
            9'd271 : cmd_data = {16'h0DE9, 8'h59};
            9'd272 : cmd_data = {16'h0DEA, 8'h21};
            9'd273 : cmd_data = {16'h0DEB, 8'h00};
            9'd274 : cmd_data = {16'h0DEC, 8'h00};
            9'd275 : cmd_data = {16'h0DED, 8'h1A};
            9'd276 : cmd_data = {16'h0DEE, 8'h00};
            9'd277 : cmd_data = {16'h0DEF, 8'h00};
            9'd278 : cmd_data = {16'h0DF0, 8'h00};
            9'd279 : cmd_data = {16'h0DF1, 8'h00};
            9'd280 : cmd_data = {16'h0DF2, 8'h00};
            9'd281 : cmd_data = {16'h0DF3, 8'h00};
            9'd282 : cmd_data = {16'h0DF4, 8'h00};
            9'd283 : cmd_data = {16'h0DF5, 8'h00};
            9'd284 : cmd_data = {16'h0DF6, 8'h00};
            9'd285 : cmd_data = {16'h0DF7, 8'h00};
            9'd286 : cmd_data = {16'h0DF8, 8'h00};
            9'd287 : cmd_data = {16'h0DF9, 8'h00};
            9'd288 : cmd_data = {16'h0DFA, 8'h00};
            9'd289 : cmd_data = {16'h0DFB, 8'h00};
            9'd290 : cmd_data = {16'h0DFC, 8'h00};
            9'd291 : cmd_data = {16'h0DFD, 8'h00};
            9'd292 : cmd_data = {16'h0DFE, 8'h00};
            9'd293 : cmd_data = {16'h0DFF, 8'hA8};
            9'd294 : cmd_data = {16'h000C, 8'h00};
            9'd295 : cmd_data = {16'h000A, 8'h04};
            9'd296 : cmd_data = {16'h2000, 8'h0F};
            9'd297 : cmd_data = {16'h2001, 8'h00};
            9'd298 : cmd_data = {16'h2002, 8'h00};
            9'd299 : cmd_data = {16'h2003, 8'h01}; 
            
            9'd300 : cmd_data = {16'h209C, 8'h00};
            9'd301 : cmd_data = {16'h209D, 8'h00};
            9'd302 : cmd_data = {16'h209E, 8'h00};
            9'd303 : cmd_data = {16'h209F, 8'h00};
             
            9'd304 : cmd_data = {16'h1010, 8'h01};
            9'd305 : cmd_data = {16'h1024, 8'h00};
            9'd306 : cmd_data = {16'h0200, 8'h00};
            9'd307 : cmd_data = {16'h1024, 8'h70};
            9'd308 : cmd_data = {16'h0200, 8'h07};
            9'd309 : cmd_data = {16'h0215, 8'h01};
            9'd310 : cmd_data = {16'h0215, 8'h00};
       endcase 
    end
endfunction
    //===========================================================================
    //  MS7210 driver control FSM
    //===========================================================================
    parameter    IDLE   = 7'b000_0001;
    parameter    CONECT = 7'b000_0010;
    parameter    INIT   = 7'b000_0100;
    parameter    WAIT   = 7'b000_1000;
    parameter    STA_RD = 7'b001_0000;
    parameter    SETING = 7'b010_0000;
    parameter    RD_BAK = 7'b100_0000;
    reg [ 6:0]   state/*synthesis PAP_MARK_DEBUG="true"*/;
    reg [ 6:0]   state_n;
    reg [ 8:0]   dri_cnt;
    reg [23:0]   delay_cnt;
    reg [ 8:0]   cmd_index/*synthesis PAP_MARK_DEBUG="true"*/;
    reg [31:0]   freq_rec/*synthesis PAP_MARK_DEBUG="true"*/;
    reg [31:0]   freq_rec_1d/*synthesis PAP_MARK_DEBUG="true"*/;
    reg [31:0]   freq_rec_2d/*synthesis PAP_MARK_DEBUG="true"*/;

    reg          busy_1d;
    wire         busy_falling;
    
    assign busy_falling = ((~busy) & busy_1d);
    always @(posedge clk)
    begin
        busy_1d <= busy;
        
//        if(state_n ==STA_RD && dri_cnt == 9'd3 && byte_over)
//        begin
            freq_rec_1d <= freq_rec;
//        end
        
        if(state_n ==STA_RD && dri_cnt == 9'd2 && busy_falling)
        begin
            freq_rec_2d <= freq_rec_1d;
        end
    end
    
    reg freq_ensure/*synthesis PAP_MARK_DEBUG="true"*/;
//    assign freq_ensure = (freq_rec_1d[17:16]==2'b00) && (freq_rec[17:16] == 2'b10);
    
    always @(posedge clk)
    begin
    	if(!rstn)
    	    freq_ensure <= 1'b0;
    	else if(state_n == SETING)
    	    freq_ensure <= 1'b0;
    	else if(state_n ==STA_RD && dri_cnt == 9'd2 && busy_falling && (freq_rec_2d[17:16]==2'b00) && (freq_rec_1d[17:16] == 2'b10))
    	    freq_ensure <= 1'b1;
        else
            freq_ensure <= freq_ensure;
    end
    //===========================================================================
    //  MS7210 driver control FSM    First Step
    always @(posedge clk)
    begin
        if(!rstn)
            state <= IDLE;
        else
            state <= state_n;
    end
    
    //===========================================================================
    //  MS7210 driver control FSM    Second Step
    always @(*)
    begin
        state_n = state;
        case(state)
            IDLE     : begin   //000_0001
                state_n = CONECT;
            end
            CONECT   : begin   //000_0010
                if(dri_cnt == 5'd1 && busy_falling && data_out == 8'h5A)//)//
                    state_n = INIT;
                else
                    state_n = state;
            end
            INIT     : begin   //000_0100
                if(dri_cnt == 9'd299 && busy_falling)
                    state_n = STA_RD;//WAIT;
                else
                    state_n = state;
            end
            WAIT     : begin   //000_1000
                if(delay_cnt == 24'h989680)//)//
                    state_n = STA_RD;//RD_BAK;//SETING;//
                else
                    state_n = state;
            end
            STA_RD   : begin   //001_0000
                if(dri_cnt == 9'd3 && busy_falling && freq_ensure)//freq_rec[15:0] > 16'h5000)
                    state_n = SETING;//WAIT;//
                else
                    state_n = state;
            end
            SETING   : begin   //010_0000
                if(dri_cnt == 5'd6 && busy_falling)
                    state_n = STA_RD;
                else
                    state_n = state;
            end
            RD_BAK     : begin   //100_0000
                if(dri_cnt == 9'd299 && busy_falling)
                    state_n = WAIT;
                else
                    state_n = state;
            end
            default  : begin
                state_n = IDLE;
            end
        endcase
    end
    
    //===========================================================================
    //  MS7210 driver control FSM    Third Step
    always @(posedge clk)
    begin
        if(!rstn)
            dri_cnt <= 5'd0;
        else
        begin
            case(state)
                IDLE     ,
                WAIT     : dri_cnt <= 5'd0;
                CONECT   : begin
                    if(busy_falling)
                    begin
                        if(dri_cnt == 5'd1)
                            dri_cnt <= 5'd0;
                        else
                            dri_cnt <= dri_cnt + 5'd1;
                    end
                    else
                        dri_cnt <= dri_cnt;
                end
                INIT     : begin
                    if(busy_falling)
                    begin
                        if(dri_cnt == 9'd299)
                            dri_cnt <= 5'd0;
                        else
                            dri_cnt <= dri_cnt + 5'd1;
                    end
                    else
                        dri_cnt <= dri_cnt;
                end
                STA_RD   : begin
                    if(busy_falling)
                    begin
                        if(dri_cnt == 5'd3)
                            dri_cnt <= 5'd0;
                        else
                            dri_cnt <= dri_cnt + 5'd1;
                    end
                    else
                        dri_cnt <= dri_cnt;
                end
                SETING   : begin
                    if(busy_falling)
                    begin
                        if(dri_cnt == 5'd6)
                            dri_cnt <= 5'd0;
                        else
                            dri_cnt <= dri_cnt + 5'd1;
                    end
                    else
                        dri_cnt <= dri_cnt;
                end
                RD_BAK   : begin
                    if(busy_falling)
                    begin
                        if(dri_cnt == 9'd299)
                            dri_cnt <= 5'd0;
                        else
                            dri_cnt <= dri_cnt + 5'd1;
                    end
                    else
                        dri_cnt <= dri_cnt;
                end
                default  : dri_cnt <= 5'd0;
            endcase
        end
    end
    
    always @(posedge clk)
    begin
        if(state == WAIT)
        begin
            if(delay_cnt == 24'h989680)//)//
                delay_cnt <= 22'd0;
            else
                delay_cnt <= delay_cnt + 22'd1;
        end
        else
            delay_cnt <= 22'd0;
    end
    
    always @(posedge clk)
    begin
        if(!rstn)
            iic_trig <= 1'd0;
        else
        begin
            case(state)
                IDLE     : iic_trig <= 1'b1;
                WAIT     : iic_trig <= (delay_cnt == 24'h989680);//);//
                CONECT   ,
                INIT     ,
                SETING   ,
                RD_BAK   ,
                STA_RD   : iic_trig <= busy_falling;
                default  : iic_trig <= 1'd0;
            endcase
        end
    end
    
    always @(posedge clk)
    begin
        if(!rstn)
            w_r <= 1'd1;
        else
        begin
            case(state)
                IDLE     : w_r <= 1'b1;
                CONECT   : begin
                    if(dri_cnt == 5'd0 && busy_falling)
                        w_r <= 1'b0;
                    else if(dri_cnt == 5'd1 && busy_falling)
                        w_r <= 1'b1;
                    else
                        w_r <= w_r;
                end
                INIT     : begin
                    if(dri_cnt == 9'd299 && busy_falling)
                        w_r <= 1'b0;
                    else
                        w_r <= w_r;
                end
                STA_RD   : begin
                    if(dri_cnt == 9'd3 && busy_falling && freq_ensure)//freq_rec[15:0] > 16'h5000)
                        w_r <= 1'b1;
                    else
                        w_r <= w_r;
                end
                RD_BAK   ,
                WAIT     : w_r <= w_r;
                SETING   : begin
                    if(dri_cnt == 5'd6 && busy_falling)
                        w_r <= 1'b0;
                    else
                        w_r <= w_r;
                end
                default  : w_r <= 1'b1;
            endcase
        end
    end
    
    always @(posedge clk)
    begin
        if(!rstn)
            cmd_index <= 6'd0;
        else
        begin
            case(state)
                IDLE     : cmd_index <= 6'd0;
                CONECT   : cmd_index <= 6'd0;
                INIT     : begin
                    if(byte_over)
                    begin
//                    	if(dri_cnt == 9'd299)
//                    	    cmd_index <= cmd_index - 4'd6;
//                    	else
                            cmd_index <= cmd_index + 1'b1;
                    end
                    else
                        cmd_index <= cmd_index;
                end
                WAIT     : cmd_index <= cmd_index;
                RD_BAK   :begin
//                    if(byte_over)
//                        cmd_index <= cmd_index + 1'b1;
//                    else
                        cmd_index <= cmd_index;
                end
                SETING   ,
                STA_RD   : begin
//                	if(byte_over)
//                	begin
//                		if(dri_cnt == 9'd3 && freq_rec[15:0] == 0)
//                		    cmd_index <= cmd_index - 3'd3;
//                		else
//                            cmd_index <= cmd_index + 1'b1;
//                    end
//                    else
                        cmd_index <= cmd_index;
                end
                default  : cmd_index <= 6'd0;
            endcase
        end
    end
    
    always @(posedge clk)
    begin
        if(!rstn)
            freq_rec <= 31'd0;
        else
        begin
            case(state)
                IDLE     ,
                INIT     ,
                WAIT     ,
                RD_BAK   ,
                CONECT   : freq_rec <= freq_rec;
                STA_RD   : begin
                	if(byte_over)
                	begin
                		case(dri_cnt)
                			9'd0    : freq_rec <= {freq_rec[31:8],data_out};
                			9'd1    : freq_rec <= {freq_rec[31:16],data_out,freq_rec[7:0]};
                			9'd2    : freq_rec <= {freq_rec[31:24],data_out,freq_rec[15:0]};
                			9'd3    : freq_rec <= {data_out,freq_rec[23:0]};
                			default : freq_rec <= freq_rec;
                	    endcase
                	end
                	else
                	    freq_rec <= freq_rec;
                end
                SETING   : freq_rec <= freq_rec;
                default  : freq_rec <= 6'd0;
            endcase
        end
    end
    
    reg [23:0] cmd_iic;
    always@(posedge clk)
	begin
		if(~rstn)
			cmd_iic <= 0;
		else if(state == IDLE)
			cmd_iic <= 24'd0;
        else //if(state == WAIT || state == SETING)
            cmd_iic <= cmd_data(cmd_index);
	end
    
    always @(posedge clk)
    begin
        if(!rstn)
        begin
            addr    <= 16'd0;
            data_in <= 8'd0;
        end
        else
        begin
            case(state)
                IDLE     : begin
                    addr    <= 16'h0003;
                    data_in <= 8'h5A;
                end
                CONECT   : begin
                    if(dri_cnt == 5'd1 && busy_falling && data_out == 8'h5A)
                    begin
                        addr    <= cmd_iic[23:8];
                        data_in <= cmd_iic[ 7:0];
                    end
                    else
                    begin
                        addr    <= addr;
                        data_in <= data_in;
                    end
                end
                INIT     ,
                WAIT     ,
                RD_BAK   :begin
                	addr    <= cmd_iic[23:8];
                    data_in <= cmd_iic[ 7:0];
                end
                STA_RD   :begin
                	case(dri_cnt)
                		9'd0   : begin
                			addr    <= 16'h209C;
                            data_in <= 8'h00;
                		end
                		9'd1   : begin
                			addr    <= 16'h209D;
                            data_in <= 8'h00;
                		end
                		9'd2   : begin
                			addr    <= 16'h209E;
                            data_in <= 8'h00;
                		end
                		9'd3   : begin
                			addr    <= 16'h209F;
                            data_in <= 8'h00;
                		end
                		default: begin
                			addr    <= 0;
                            data_in <= 0;
                		end
                    endcase
                end
                SETING   : begin
                	case(dri_cnt)
                		9'd0   : begin
                			addr    <= 16'h1010;
                            data_in <= 8'h01;
                		end
                		9'd1   : begin
                			addr    <= 16'h1024;
                            data_in <= 8'h00;
                		end
                		9'd2   : begin
                			addr    <= 16'h0200;
                            data_in <= 8'h0;
                		end
                		9'd3   : begin
                			addr    <= 16'h1024;
                            data_in <= 8'h70;
                		end
                		9'd4   : begin
                			addr    <= 16'h0200;
                            data_in <= 8'h07;
                		end
                		9'd5   : begin
                			addr    <= 16'h0215;
                            data_in <= 8'h01;
                		end
                		9'd6   : begin
                			addr    <= 16'h0215;
                            data_in <= 8'h00;
                		end
                		default: begin
                			addr    <= 16'h0215;
                            data_in <= 8'h00;
                		end
                    endcase
                end
                default  : begin
                    addr    <= 0;
                    data_in <= 0;
                end
            endcase
        end
    end

    always @(posedge clk)
    begin
    	if(!rstn)
    	    init_over <= 1'b0;
    	else if(state == SETING && dri_cnt == 5'd6 && busy_falling)
    	    init_over <= 1'b1;
    	else
    	    init_over <= init_over;
    end

endmodule
