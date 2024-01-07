//******************************************************************
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
`timescale 1ns/1ns
module pgr_cmd_parser_32bit#(
    parameter AW = 8'd16,
    parameter DW = 8'd32,
    parameter SW = 8'd4,
    parameter CLK_FREQ = 8'd50
)
(
    input               clk,
    input               rst_n,

    input               apb_en,
    input               strb_en,

    input       [7:0]   fifo_data,
    input               fifo_data_valid,
    output              fifo_data_req,

    output  reg [SW-1:0]  strb,
    output      [AW-1:0]  addr,
    output      [DW-1:0]  wdata,
    output                we,

    output                cmd_en,
    input                 cmd_done,

    input                  uart_rxreq,
    output        [7:0]    uart_rxdata,
    output                 uart_rxvld
);

localparam ST_IDLE      = 5'd0;
localparam ST_W_ADDR_B0 = 5'd1;
localparam ST_W_ADDR_B1 = 5'd2;
localparam ST_W_ADDR_B2 = 5'd3;
localparam ST_W_ADDR_B3 = 5'd4;
localparam ST_W_DATA_B0 = 5'd5;
localparam ST_W_DATA_B1 = 5'd6;
localparam ST_W_DATA_B2 = 5'd7;
localparam ST_W_DATA_B3 = 5'd8;
localparam ST_W_STRB    = 5'd9;
localparam ST_W_CMD     = 5'd10;
localparam ST_WAIT      = 5'd11;
localparam ST_R_ADDR_B0 = 5'd12;
localparam ST_R_ADDR_B1 = 5'd13;
localparam ST_R_ADDR_B2 = 5'd14;
localparam ST_R_ADDR_B3 = 5'd15;
localparam ST_R_CMD     = 5'd16;

localparam ASC_w = 8'h77;
localparam ASC_r = 8'h72;

reg     [4:0]   crt_st;
reg     [4:0]   nxt_st;

reg     [7:0]   addr_b0;
reg     [7:0]   addr_b1;
reg     [7:0]   addr_b2;
reg     [7:0]   addr_b3;
reg     [7:0]   data_b0;
reg     [7:0]   data_b1;
reg     [7:0]   data_b2;
reg     [7:0]   data_b3;

assign addr = {addr_b3,addr_b2,addr_b1,addr_b0};
//assign strb = addrh[3:0];
assign wdata = {data_b3,data_b2,data_b1,data_b0};
assign we = crt_st == ST_W_CMD;
assign cmd_en = (crt_st == ST_W_CMD) | (crt_st == ST_R_CMD);

//wire in_st_idle       = crt_st == ST_IDLE;
wire in_st_w_addr_b0  = crt_st == ST_W_ADDR_B0;
wire in_st_w_addr_b1  = crt_st == ST_W_ADDR_B1;
wire in_st_w_addr_b2  = crt_st == ST_W_ADDR_B2;
wire in_st_w_addr_b3  = crt_st == ST_W_ADDR_B3;
wire in_st_w_data_b0  = crt_st == ST_W_DATA_B0;
wire in_st_w_data_b1  = crt_st == ST_W_DATA_B1;
wire in_st_w_data_b2  = crt_st == ST_W_DATA_B2;
wire in_st_w_data_b3  = crt_st == ST_W_DATA_B3;
wire in_st_r_addr_b0  = crt_st == ST_R_ADDR_B0;
wire in_st_r_addr_b1  = crt_st == ST_R_ADDR_B1;
wire in_st_r_addr_b2  = crt_st == ST_R_ADDR_B2;
wire in_st_r_addr_b3  = crt_st == ST_R_ADDR_B3;
wire in_st_w_strb     = crt_st == ST_W_STRB;

wire st_idle       = nxt_st == ST_IDLE;
wire st_w_addr_b0  = nxt_st == ST_W_ADDR_B0;
wire st_w_addr_b1  = nxt_st == ST_W_ADDR_B1;
wire st_w_addr_b2  = nxt_st == ST_W_ADDR_B2;
wire st_w_addr_b3  = nxt_st == ST_W_ADDR_B3;
wire st_w_data_b0  = nxt_st == ST_W_DATA_B0;
wire st_w_data_b1  = nxt_st == ST_W_DATA_B1;
wire st_w_data_b2  = nxt_st == ST_W_DATA_B2;
wire st_w_data_b3  = nxt_st == ST_W_DATA_B3;
wire st_r_addr_b0  = nxt_st == ST_R_ADDR_B0;
wire st_r_addr_b1  = nxt_st == ST_R_ADDR_B1;
wire st_r_addr_b2  = nxt_st == ST_R_ADDR_B2;
wire st_r_addr_b3  = nxt_st == ST_R_ADDR_B3;
wire st_w_strb     = nxt_st == ST_W_STRB;


//wire wait_fifo_data = in_st_idle | in_st_w_addr_b0 | in_st_w_addr_b1 | in_st_w_addr_b2 | in_st_w_addr_b3 | in_st_w_data_b0 | in_st_w_data_b1 |
//                      in_st_w_data_b2 | in_st_w_data_b3 | in_st_w_strb | in_st_r_addr_b0 | in_st_r_addr_b1 | in_st_r_addr_b2 | in_st_r_addr_b3;

wire wait_fifo_data = st_idle | st_w_addr_b0 | st_w_addr_b1 | st_w_addr_b2 | st_w_addr_b3 | st_w_data_b0 | st_w_data_b1 |
                      st_w_data_b2 | st_w_data_b3 | st_w_strb | st_r_addr_b0 | st_r_addr_b1 | st_r_addr_b2 | st_r_addr_b3;

localparam DATA_NUM = DW / 8 - 1;
localparam ADDR_NUM = AW / 8 - 1;

wire   [7:0]   apb_fifo_data;
wire           apb_fifo_data_valid;
reg            apb_fifo_data_req;

reg [15:0]     cnt;
wire           timeout;

assign fifo_data_req = apb_en ? apb_fifo_data_req : uart_rxreq;

assign uart_rxvld = (~apb_en) & fifo_data_valid;
assign uart_rxdata = {8{~apb_en}} & fifo_data;

assign apb_fifo_data_valid = apb_en & fifo_data_valid;
assign apb_fifo_data = {8{apb_en}} & fifo_data;

assign timeout = cnt == 100 * CLK_FREQ;

always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cnt <= 16'b0;
    else if(crt_st != 5'd0)
    begin
        if(apb_fifo_data_valid)
            cnt <= 16'b0;
        else if(timeout)
            cnt <= 16'b0;
        else
            cnt <= cnt + 16'b1;
    end
    else
        cnt <= 16'b0;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        crt_st <= ST_IDLE;
    else
        crt_st <= nxt_st;
end

always @(*)
begin
    nxt_st = crt_st;
    case(crt_st)
        ST_IDLE    :
        begin
            if(apb_fifo_data_valid)
            begin
                if(apb_fifo_data == ASC_w)
                    nxt_st = ST_W_ADDR_B0;
                else if(apb_fifo_data == ASC_r)
                    nxt_st = ST_R_ADDR_B0;
                else
                    nxt_st = crt_st;
            end
            else
                nxt_st = crt_st;
        end
        ST_W_ADDR_B0 :
        begin
            if(apb_fifo_data_valid)
            begin
                if(ADDR_NUM == 2'd0)
                    nxt_st = ST_W_DATA_B0;
                else
                    nxt_st = ST_W_ADDR_B1;
            end
            else
            begin
                if(timeout)
                    nxt_st = ST_W_CMD;
                else
                    nxt_st = ST_W_ADDR_B0;
            end
        end
        ST_W_ADDR_B1 :
        begin
            if(apb_fifo_data_valid)
            begin
                if(ADDR_NUM == 2'd1)
                    nxt_st = ST_W_DATA_B0;
                else
                    nxt_st = ST_W_ADDR_B2;
            end
            else
            begin
                if(timeout)
                    nxt_st = ST_W_CMD;
                else
                    nxt_st = ST_W_ADDR_B1;
            end
        end
        ST_W_ADDR_B2 :
        begin
            if(apb_fifo_data_valid)
            begin
                if(ADDR_NUM == 2'd2)
                    nxt_st = ST_W_DATA_B0;
                else
                    nxt_st = ST_W_ADDR_B3;
            end
            else
            begin
                if(timeout)
                    nxt_st = ST_W_CMD;
                else
                    nxt_st = ST_W_ADDR_B2;
            end
        end
        ST_W_ADDR_B3 :
        begin
            if(apb_fifo_data_valid)
                nxt_st = ST_W_DATA_B0;
            else
            begin
                if(timeout)
                    nxt_st = ST_W_CMD;
                else
                    nxt_st = ST_W_ADDR_B3;
            end
        end
        ST_W_DATA_B0  :
        begin
            if(apb_fifo_data_valid)
            begin
                if(DATA_NUM == 2'd0)
                begin
                    if(strb_en)
                        nxt_st = ST_W_STRB;
                    else
                        nxt_st = ST_W_CMD;
                end
                else
                    nxt_st = ST_W_DATA_B1;
            end
            else
            begin
                if(timeout)
                    nxt_st = ST_W_CMD;
                else
                    nxt_st = ST_W_DATA_B0;
            end
        end
        ST_W_DATA_B1  :
         begin
            if(apb_fifo_data_valid)
            begin
                if(DATA_NUM == 2'd1)
                begin
                    if(strb_en)
                        nxt_st = ST_W_STRB;
                    else
                        nxt_st = ST_W_CMD;
                end
                else
                    nxt_st = ST_W_DATA_B2;
            end
            else
            begin
                if(timeout)
                    nxt_st = ST_W_CMD;
                else
                    nxt_st = ST_W_DATA_B1;
            end
        end
        ST_W_DATA_B2  :
        begin
            if(apb_fifo_data_valid)
            begin
                if(DATA_NUM == 2'd2)
                begin
                    if(strb_en)
                        nxt_st = ST_W_STRB;
                    else
                        nxt_st = ST_W_CMD;
                end
                else
                    nxt_st = ST_W_DATA_B3;
            end
            else
            begin
                if(timeout)
                    nxt_st = ST_W_CMD;
                else
                    nxt_st = ST_W_DATA_B2;
            end
        end
        ST_W_DATA_B3  :
        begin
            if(apb_fifo_data_valid)
            begin
                if(strb_en)
                    nxt_st = ST_W_STRB;
                else
                    nxt_st = ST_W_CMD;
            end
            else
            begin
                if(timeout)
                    nxt_st = ST_W_CMD;
                else
                    nxt_st = ST_W_DATA_B3;
            end
        end
        ST_W_STRB  :
        begin
            if(apb_fifo_data_valid)
                nxt_st = ST_W_CMD;
            else
            begin
                if(timeout)
                    nxt_st = ST_W_CMD;
                else
                    nxt_st = ST_W_STRB;
            end
        end
        ST_W_CMD   :
        begin
            nxt_st = ST_WAIT;
        end
        ST_WAIT    :
        begin
            if(cmd_done)
                nxt_st = ST_IDLE;
            else
                nxt_st = ST_WAIT;
        end
        ST_R_ADDR_B0 :
        begin
            if(apb_fifo_data_valid)
            begin
                if(ADDR_NUM == 2'd0)
                    nxt_st = ST_R_CMD;
                else
                    nxt_st = ST_R_ADDR_B1;
            end
            else
            begin
                if(timeout)
                    nxt_st = ST_R_CMD;
                else
                    nxt_st = ST_R_ADDR_B0;
            end
        end
        ST_R_ADDR_B1 :
         begin
            if(apb_fifo_data_valid)
            begin
                if(ADDR_NUM == 2'd1)
                    nxt_st = ST_R_CMD;
                else
                    nxt_st = ST_R_ADDR_B2;
            end
            else
            begin
                if(timeout)
                    nxt_st = ST_R_CMD;
                else
                    nxt_st = ST_R_ADDR_B1;
            end
        end
        ST_R_ADDR_B2 :
         begin
            if(apb_fifo_data_valid)
            begin
                if(ADDR_NUM == 2'd2)
                    nxt_st = ST_R_CMD;
                else
                    nxt_st = ST_R_ADDR_B3;
            end
            else
            begin
                if(timeout)
                    nxt_st = ST_R_CMD;
                else
                    nxt_st = ST_R_ADDR_B2;
            end
        end
         ST_R_ADDR_B3 :
         begin
            if(apb_fifo_data_valid)
                nxt_st = ST_R_CMD;
            else
            begin
                if(timeout)
                    nxt_st = ST_R_CMD;
                else
                    nxt_st = ST_R_ADDR_B3;
            end
        end
        ST_R_CMD   :
        begin
            nxt_st = ST_WAIT;
        end
        default    :
        begin
            nxt_st = ST_IDLE;
        end
    endcase
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        addr_b0 <= 8'b0;
    else if((in_st_w_addr_b0 || in_st_r_addr_b0) && apb_fifo_data_valid)
        addr_b0 <= apb_fifo_data;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        addr_b1 <= 8'b0;
    else if((in_st_w_addr_b1 || in_st_r_addr_b1) && apb_fifo_data_valid)
        addr_b1 <= apb_fifo_data;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        addr_b2 <= 8'b0;
    else if((in_st_w_addr_b2 || in_st_r_addr_b2) && apb_fifo_data_valid)
        addr_b2 <= apb_fifo_data;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        addr_b3 <= 8'b0;
    else if((in_st_w_addr_b3 || in_st_r_addr_b3) && apb_fifo_data_valid)
        addr_b3 <= apb_fifo_data;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        data_b0 <= 8'b0;
    else if(in_st_w_data_b0 && apb_fifo_data_valid)
        data_b0 <= apb_fifo_data;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        data_b1 <= 8'b0;
    else if(in_st_w_data_b1 && apb_fifo_data_valid)
        data_b1 <= apb_fifo_data;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        data_b2 <= 8'b0;
    else if(in_st_w_data_b2 && apb_fifo_data_valid)
        data_b2 <= apb_fifo_data;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        data_b3 <= 8'b0;
    else if(in_st_w_data_b3 && apb_fifo_data_valid)
        data_b3 <= apb_fifo_data;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        strb <= 'b0;
    else if(in_st_w_strb && apb_fifo_data_valid)
        strb <= apb_fifo_data[SW-1:0];
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        apb_fifo_data_req <= 1'b0;
    else if(wait_fifo_data)
        apb_fifo_data_req <= 1'b1;
    else
        apb_fifo_data_req <= 1'b0;
end

endmodule //pgr_cmd_parser