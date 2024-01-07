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
module ms7210_ctrl(
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
    assign device_id = 8'hB2;
function [23:0] cmd_data;
input [5:0] index;
    begin
        case(index)
            6'd0     : cmd_data = {16'h1281,8'h04};
            6'd1     : cmd_data = {16'h0016,8'h04};//
            6'd2     : cmd_data = {16'h0009,8'h01};//
            6'd3     : cmd_data = {16'h0007,8'h09};//
            6'd4     : cmd_data = {16'h0008,8'hF0};//
            6'd5     : cmd_data = {16'h000A,8'hF0};//
            6'd6     : cmd_data = {16'h0006,8'h11};//
            6'd7     : cmd_data = {16'h0531,8'h84};//
            6'd8     : cmd_data = {16'h0900,8'h20};//
            6'd9     : cmd_data = {16'h0901,8'h47};//
            6'd10    : cmd_data = {16'h0904,8'h09};
            6'd11    : cmd_data = {16'h0923,8'h07};//
            6'd12    : cmd_data = {16'h0924,8'h44};//
            6'd13    : cmd_data = {16'h0925,8'h44};//
            6'd14    : cmd_data = {16'h090F,8'h80};//
            6'd15    : cmd_data = {16'h091F,8'h07};//
            6'd16    : cmd_data = {16'h0920,8'h1E};//  INT EN
            6'd17    : cmd_data = {16'h0018,8'h20};//
            6'd18    : cmd_data = {16'h05c0,8'hFE};//
            6'd19    : cmd_data = {16'h000B,8'h00};//  seting
            6'd20    : cmd_data = {16'h0507,8'h06};
            6'd21    : cmd_data = {16'h0906,8'h04};//
            6'd22    : cmd_data = {16'h0920,8'h5E};//
            6'd23    : cmd_data = {16'h0926,8'hDD};//
            6'd24    : cmd_data = {16'h0927,8'h0D};//
            6'd25    : cmd_data = {16'h0928,8'h88};//
            6'd26    : cmd_data = {16'h0929,8'h08};//
            6'd27    : cmd_data = {16'h0910,8'h01};//
            6'd28    : cmd_data = {16'h000B,8'h11};//
            6'd29    : cmd_data = {16'h050E,8'h00};//
            6'd30    : cmd_data = {16'h050A,8'h82};
            6'd31    : cmd_data = {16'h0509,8'h02};//
            6'd32    : cmd_data = {16'h050B,8'h0D};//
            6'd33    : cmd_data = {16'h050D,8'h06};//
            6'd34    : cmd_data = {16'h050D,8'h11};//
            6'd35    : cmd_data = {16'h050D,8'h58};//
            6'd36    : cmd_data = {16'h050D,8'h00};//
            6'd37    : cmd_data = {16'h050D,8'h00};//
            6'd38    : cmd_data = {16'h050D,8'h00};//
            6'd39    : cmd_data = {16'h050D,8'h00};//
            6'd40    : cmd_data = {16'h050D,8'h00};
            6'd41    : cmd_data = {16'h050D,8'h00};//
            6'd42    : cmd_data = {16'h050D,8'h00};//
            6'd43    : cmd_data = {16'h050D,8'h00};//
            6'd44    : cmd_data = {16'h050D,8'h00};//
            6'd45    : cmd_data = {16'h050D,8'h00};//
            6'd46    : cmd_data = {16'h050D,8'h00};//
            6'd47    : cmd_data = {16'h050E,8'h40};//
            6'd48    : cmd_data = {16'h0507,8'h00};//
       endcase 
    end
endfunction
    //===========================================================================
    //  MS7210 driver control FSM
    //===========================================================================
    parameter    IDLE   = 6'b00_0001;
    parameter    CONECT = 6'b00_0010;
    parameter    INIT   = 6'b00_0100;
    parameter    WAIT   = 6'b00_1000;
    parameter    SETING = 6'b01_0000;
    parameter    STA_RD = 6'b10_0000;
    reg [ 5:0]   state;
    reg [ 5:0]   state_n;
    reg [ 4:0]   dri_cnt;
    reg [21:0]   delay_cnt;
    reg [ 5:0]   cmd_index;

    reg          busy_1d;
    wire         busy_falling;
    
    assign busy_falling = ((~busy) & busy_1d);
    always @(posedge clk)
    begin
        busy_1d <= busy;
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
            IDLE     : begin
                state_n = CONECT;
            end
            CONECT   : begin
                if(dri_cnt == 5'd1 && busy_falling && data_out == 8'h5A)
                    state_n = INIT;
                else
                    state_n = state;
            end
            INIT     : begin
                if(dri_cnt == 5'd18 && busy_falling)
                    state_n = WAIT;
                else
                    state_n = state;
            end
            WAIT     : begin
                if(delay_cnt == 22'h30D399)//)//
                    state_n = SETING;
                else
                    state_n = state;
            end
            SETING   : begin
                if(dri_cnt == 5'd29 && busy_falling)
                    state_n = STA_RD;
                else
                    state_n = state;
            end
            STA_RD   : begin
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
                WAIT     ,
                STA_RD   : dri_cnt <= 5'd0;
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
                        if(dri_cnt == 5'd18)
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
                        if(dri_cnt == 5'd29)
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
            if(delay_cnt == 22'h30D399)
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
                WAIT     : iic_trig <= (delay_cnt == 22'h30D399);
                CONECT   ,
                INIT     ,
                SETING   ,
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
                INIT     ,
                STA_RD   ,
                WAIT     : w_r <= w_r;
                SETING   : begin
                    if(dri_cnt == 5'd29 && busy_falling)
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
                INIT     ,
                SETING   :begin
                    if(byte_over)
                        cmd_index <= cmd_index + 1'b1;
                    else
                        cmd_index <= cmd_index;
                end
                WAIT     ,
                STA_RD   : cmd_index <= cmd_index;
                default  : cmd_index <= 6'd0;
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
                SETING   :begin
                	addr    <= cmd_iic[23:8];
                    data_in <= cmd_iic[ 7:0];
                end
                STA_RD   :begin
                    addr    <= 16'h0502;
                    data_in <= 8'd0;
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
    	else if(state == STA_RD)// && busy_falling)
    	    init_over <= 1'b1;
    end

endmodule
