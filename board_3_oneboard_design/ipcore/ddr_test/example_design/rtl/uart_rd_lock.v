`timescale 1ns/1ns
module uart_rd_lock
(
    input                                core_clk           ,
    input                                core_rst_n         ,

    input                                uart_read_req      ,
    output reg                           uart_read_ack      ,
    input [8:0]                          uart_read_addr     ,

    input [31:0]                         status_bus_80          ,
    input [31:0]                         status_bus_81          ,
    input [31:0]                         status_bus_82          ,
    input [31:0]                         status_bus_83          ,
    input [31:0]                         status_bus_84          ,
    input [31:0]                         status_bus_85          ,
    input [31:0]                         status_bus_86          ,
    input [31:0]                         status_bus_87          ,
    input [31:0]                         status_bus_88          ,
    input [31:0]                         status_bus_89          ,
    input [31:0]                         status_bus_8a          ,
    input [31:0]                         status_bus_8b          ,
    input [31:0]                         status_bus_8c          ,
    input [31:0]                         status_bus_8d          ,
    input [31:0]                         status_bus_8e          ,
    input [31:0]                         status_bus_8f          ,

    input [31:0]                         status_bus_90          ,
    input [31:0]                         status_bus_91          ,
    input [31:0]                         status_bus_92          ,
    input [31:0]                         status_bus_93          ,
    input [31:0]                         status_bus_94          ,
    input [31:0]                         status_bus_95          ,
    input [31:0]                         status_bus_96          ,
    input [31:0]                         status_bus_97          ,
    input [31:0]                         status_bus_98          ,
    input [31:0]                         status_bus_99          ,
    input [31:0]                         status_bus_9a          ,
    input [31:0]                         status_bus_9b          ,
    input [31:0]                         status_bus_9c          ,
    input [31:0]                         status_bus_9d          ,
    input [31:0]                         status_bus_9e          ,
    input [31:0]                         status_bus_9f          ,

    input [31:0]                         status_bus_a0          ,
    input [31:0]                         status_bus_a1          ,
    input [31:0]                         status_bus_a2          ,
    input [31:0]                         status_bus_a3          ,
    input [31:0]                         status_bus_a4          ,
    input [31:0]                         status_bus_a5          ,
    input [31:0]                         status_bus_a6          ,
    input [31:0]                         status_bus_a7          ,
    input [31:0]                         status_bus_a8          ,
    input [31:0]                         status_bus_a9          ,
    input [31:0]                         status_bus_aa          ,
    input [31:0]                         status_bus_ab          ,
    input [31:0]                         status_bus_ac          ,
    input [31:0]                         status_bus_ad          ,
    input [31:0]                         status_bus_ae          ,
    input [31:0]                         status_bus_af          ,

    input [31:0]                         status_bus_b0          ,
    input [31:0]                         status_bus_b1          ,
    input [31:0]                         status_bus_b2          ,
    input [31:0]                         status_bus_b3          ,
    input [31:0]                         status_bus_b4          ,
    input [31:0]                         status_bus_b5          ,
    input [31:0]                         status_bus_b6          ,
    input [31:0]                         status_bus_b7          ,
    input [31:0]                         status_bus_b8          ,
    input [31:0]                         status_bus_b9          ,
    input [31:0]                         status_bus_ba          ,
    input [31:0]                         status_bus_bb          ,
    input [31:0]                         status_bus_bc          ,
    input [31:0]                         status_bus_bd          ,
    input [31:0]                         status_bus_be          ,
    input [31:0]                         status_bus_bf          ,

    input [31:0]                         status_bus_c0          ,
    input [31:0]                         status_bus_c1          ,
    input [31:0]                         status_bus_c2          ,
    input [31:0]                         status_bus_c3          ,
    input [31:0]                         status_bus_c4          ,
    input [31:0]                         status_bus_c5          ,
    input [31:0]                         status_bus_c6          ,
    input [31:0]                         status_bus_c7          ,
    input [31:0]                         status_bus_c8          ,
    input [31:0]                         status_bus_c9          ,
    input [31:0]                         status_bus_ca          ,
    input [31:0]                         status_bus_cb          ,
    input [31:0]                         status_bus_cc          ,
    input [31:0]                         status_bus_cd          ,
    input [31:0]                         status_bus_ce          ,
    input [31:0]                         status_bus_cf          ,

    input [31:0]                         status_bus_d0          ,
    input [31:0]                         status_bus_d1          ,
    input [31:0]                         status_bus_d2          ,
    input [31:0]                         status_bus_d3          ,
    input [31:0]                         status_bus_d4          ,
    input [31:0]                         status_bus_d5          ,
    input [31:0]                         status_bus_d6          ,
    input [31:0]                         status_bus_d7          ,
    input [31:0]                         status_bus_d8          ,
    input [31:0]                         status_bus_d9          ,
    input [31:0]                         status_bus_da          ,
    input [31:0]                         status_bus_db          ,
    input [31:0]                         status_bus_dc          ,
    input [31:0]                         status_bus_dd          ,
    input [31:0]                         status_bus_de          ,
    input [31:0]                         status_bus_df          ,

    input [31:0]                         status_bus_e0          ,
    input [31:0]                         status_bus_e1          ,
    input [31:0]                         status_bus_e2          ,
    input [31:0]                         status_bus_e3          ,
    input [31:0]                         status_bus_e4          ,
    input [31:0]                         status_bus_e5          ,
    input [31:0]                         status_bus_e6          ,
    input [31:0]                         status_bus_e7          ,
    input [31:0]                         status_bus_e8          ,
    input [31:0]                         status_bus_e9          ,
    input [31:0]                         status_bus_ea          ,
    input [31:0]                         status_bus_eb          ,
    input [31:0]                         status_bus_ec          ,
    input [31:0]                         status_bus_ed          ,
    input [31:0]                         status_bus_ee          ,
    input [31:0]                         status_bus_ef          ,
    
    input [31:0]                         status_bus_f0          ,
    input [31:0]                         status_bus_f1          ,
    input [31:0]                         status_bus_f2          ,
    input [31:0]                         status_bus_f3          ,
    input [31:0]                         status_bus_f4          ,
    input [31:0]                         status_bus_f5          ,
    input [31:0]                         status_bus_f6          ,
    input [31:0]                         status_bus_f7          ,
    input [31:0]                         status_bus_f8          ,
    input [31:0]                         status_bus_f9          ,
    input [31:0]                         status_bus_fa          ,
    input [31:0]                         status_bus_fb          ,
    input [31:0]                         status_bus_fc          ,
    input [31:0]                         status_bus_fd          ,
    input [31:0]                         status_bus_fe          ,
    input [31:0]                         status_bus_ff          ,

    output reg [31:0]                    status_bus_lock
);

reg  uart_read_req_syn1;
reg  uart_read_req_syn2;
reg  uart_read_req_syn3;
wire uart_read_req_inv;
reg  uart_read_req_inv_d1;
reg  uart_read_req_inv_d2;

wire [32*8-1:0] status_bus_0;
wire [32*8-1:0] status_bus_1;
wire [32*8-1:0] status_bus_2;
wire [32*8-1:0] status_bus_3;
wire [32*8-1:0] status_bus_4;
wire [32*8-1:0] status_bus_5;
wire [32*8-1:0] status_bus_6;
wire [32*8-1:0] status_bus_7;
wire [32*8-1:0] status_bus_8;
wire [32*8-1:0] status_bus_9;
wire [32*8-1:0] status_bus_a;
wire [32*8-1:0] status_bus_b;
wire [32*8-1:0] status_bus_c;
wire [32*8-1:0] status_bus_d;
wire [32*8-1:0] status_bus_e;
wire [32*8-1:0] status_bus_f;

reg  [32*8-1:0] status_bus_sel_0;
reg  [32*8-1:0] status_bus_sel_1;
reg  [32*8-1:0] status_bus_sel_2;
reg  [32*8-1:0] status_bus_sel_3;
reg  [32*8-1:0] status_bus_sel_4;
reg  [32*8-1:0] status_bus_sel_5;
reg  [32*8-1:0] status_bus_sel_6;
reg  [32*8-1:0] status_bus_sel_7;

reg  [32*8-1:0] status_bus_sel;

always @(posedge core_clk or negedge core_rst_n)
begin
    if(!core_rst_n)
    begin
       uart_read_req_syn1 <= 1'b0;
       uart_read_req_syn2 <= 1'b0;
       uart_read_req_syn3 <= 1'b0;
    end
    else
    begin
       uart_read_req_syn1 <= uart_read_req;
       uart_read_req_syn2 <= uart_read_req_syn1;
       uart_read_req_syn3 <= uart_read_req_syn2;
    end
end

assign uart_read_req_inv = uart_read_req_syn3 ^ uart_read_req_syn2;

always @(posedge core_clk or negedge core_rst_n)
begin
    if(!core_rst_n)
       uart_read_req_inv_d1 <= 1'b0;
    else
       uart_read_req_inv_d1 <= uart_read_req_inv;
end

always @(posedge core_clk or negedge core_rst_n)
begin
    if(!core_rst_n)
       uart_read_req_inv_d2 <= 1'b0;
    else
       uart_read_req_inv_d2 <= uart_read_req_inv_d1;
end

always @(posedge core_clk or negedge core_rst_n)
begin
    if(!core_rst_n)
        uart_read_ack <= 1'b0;
    else if(uart_read_req_inv_d2)
        uart_read_ack <= ~uart_read_ack;
    else;
end

//******************************** status 8x ********************************//
assign status_bus_0 = {status_bus_f0,
                       status_bus_e0,
                       status_bus_d0,
                       status_bus_c0,
                       status_bus_b0,
                       status_bus_a0,
                       status_bus_90,
                       status_bus_80};

assign status_bus_1 = {status_bus_f1,
                       status_bus_e1,
                       status_bus_d1,
                       status_bus_c1,
                       status_bus_b1,
                       status_bus_a1,
                       status_bus_91,
                       status_bus_81};

assign status_bus_2 = {status_bus_f2,
                       status_bus_e2,
                       status_bus_d2,
                       status_bus_c2,
                       status_bus_b2,
                       status_bus_a2,
                       status_bus_92,
                       status_bus_82};

assign status_bus_3 = {status_bus_f3,
                       status_bus_e3,
                       status_bus_d3,
                       status_bus_c3,
                       status_bus_b3,
                       status_bus_a3,
                       status_bus_93,
                       status_bus_83};

assign status_bus_4 = {status_bus_f4,
                       status_bus_e4,
                       status_bus_d4,
                       status_bus_c4,
                       status_bus_b4,
                       status_bus_a4,
                       status_bus_94,
                       status_bus_84};

assign status_bus_5 = {status_bus_f5,
                       status_bus_e5,
                       status_bus_d5,
                       status_bus_c5,
                       status_bus_b5,
                       status_bus_a5,
                       status_bus_95,
                       status_bus_85};

assign status_bus_6 = {status_bus_f6,
                       status_bus_e6,
                       status_bus_d6,
                       status_bus_c6,
                       status_bus_b6,
                       status_bus_a6,
                       status_bus_96,
                       status_bus_86};

assign status_bus_7 = {status_bus_f7,
                       status_bus_e7,
                       status_bus_d7,
                       status_bus_c7,
                       status_bus_b7,
                       status_bus_a7,
                       status_bus_97,
                       status_bus_87};

assign status_bus_8 = {status_bus_f8,
                       status_bus_e8,
                       status_bus_d8,
                       status_bus_c8,
                       status_bus_b8,
                       status_bus_a8,
                       status_bus_98,
                       status_bus_88};

assign status_bus_9 = {status_bus_f9,
                       status_bus_e9,
                       status_bus_d9,
                       status_bus_c9,
                       status_bus_b9,
                       status_bus_a9,
                       status_bus_99,
                       status_bus_89};

assign status_bus_a = {status_bus_fa,
                       status_bus_ea,
                       status_bus_da,
                       status_bus_ca,
                       status_bus_ba,
                       status_bus_aa,
                       status_bus_9a,
                       status_bus_8a};

assign status_bus_b = {status_bus_fb,
                       status_bus_eb,
                       status_bus_db,
                       status_bus_cb,
                       status_bus_bb,
                       status_bus_ab,
                       status_bus_9b,
                       status_bus_8b};

assign status_bus_c = {status_bus_fc,
                       status_bus_ec,
                       status_bus_dc,
                       status_bus_cc,
                       status_bus_bc,
                       status_bus_ac,
                       status_bus_9c,
                       status_bus_8c};

assign status_bus_d = {status_bus_fd,
                       status_bus_ed,
                       status_bus_dd,
                       status_bus_cd,
                       status_bus_bd,
                       status_bus_ad,
                       status_bus_9d,
                       status_bus_8d};

assign status_bus_e = {status_bus_fe,
                       status_bus_ee,
                       status_bus_de,
                       status_bus_ce,
                       status_bus_be,
                       status_bus_ae,
                       status_bus_9e,
                       status_bus_8e};

assign status_bus_f = {status_bus_ff,
                       status_bus_ef,
                       status_bus_df,
                       status_bus_cf,
                       status_bus_bf,
                       status_bus_af,
                       status_bus_9f,
                       status_bus_8f};

genvar i;
generate
for(i=0;i<8;i=i+1) begin:status_gen
    always @(posedge core_clk or negedge core_rst_n)
    begin
        if(!core_rst_n)
            status_bus_sel_0[i*32+31:i*32] <= 32'b0;
        else if(uart_read_req_inv)
        begin
            case(uart_read_addr[0])
                1'b0: status_bus_sel_0[i*32+31:i*32] <= status_bus_0[i*32+31:i*32];
                1'b1: status_bus_sel_0[i*32+31:i*32] <= status_bus_1[i*32+31:i*32];
                default : status_bus_sel_0[i*32+31:i*32] <= 32'b0;
            endcase
        end
        else;
    end

    always @(posedge core_clk or negedge core_rst_n)
    begin
        if(!core_rst_n)
            status_bus_sel_1[i*32+31:i*32] <= 32'b0;
        else if(uart_read_req_inv)
        begin
            case(uart_read_addr[0])
                1'b0: status_bus_sel_1[i*32+31:i*32] <= status_bus_2[i*32+31:i*32];
                1'b1: status_bus_sel_1[i*32+31:i*32] <= status_bus_3[i*32+31:i*32];
                default : status_bus_sel_1[i*32+31:i*32] <= 32'b0;
            endcase
        end
        else;
    end

    always @(posedge core_clk or negedge core_rst_n)
    begin
        if(!core_rst_n)
            status_bus_sel_2[i*32+31:i*32] <= 32'b0;
        else if(uart_read_req_inv)
        begin
            case(uart_read_addr[0])
                1'b0: status_bus_sel_2[i*32+31:i*32] <= status_bus_4[i*32+31:i*32];
                1'b1: status_bus_sel_2[i*32+31:i*32] <= status_bus_5[i*32+31:i*32];
                default : status_bus_sel_2[i*32+31:i*32] <= 32'b0;
            endcase
        end
        else;
    end

    always @(posedge core_clk or negedge core_rst_n)
    begin
        if(!core_rst_n)
            status_bus_sel_3[i*32+31:i*32] <= 32'b0;
        else if(uart_read_req_inv)
        begin
            case(uart_read_addr[0])
                1'b0: status_bus_sel_3[i*32+31:i*32] <= status_bus_6[i*32+31:i*32];
                1'b1: status_bus_sel_3[i*32+31:i*32] <= status_bus_7[i*32+31:i*32];
                default : status_bus_sel_3[i*32+31:i*32] <= 32'b0;
            endcase
        end
        else;
    end

    always @(posedge core_clk or negedge core_rst_n)
    begin
        if(!core_rst_n)
            status_bus_sel_4[i*32+31:i*32] <= 32'b0;
        else if(uart_read_req_inv)
        begin
            case(uart_read_addr[0])
                1'b0: status_bus_sel_4[i*32+31:i*32] <= status_bus_8[i*32+31:i*32];
                1'b1: status_bus_sel_4[i*32+31:i*32] <= status_bus_9[i*32+31:i*32];
                default : status_bus_sel_4[i*32+31:i*32] <= 32'b0;
            endcase
        end
        else;
    end

    always @(posedge core_clk or negedge core_rst_n)
    begin
        if(!core_rst_n)
            status_bus_sel_5[i*32+31:i*32] <= 32'b0;
        else if(uart_read_req_inv)
        begin
            case(uart_read_addr[0])
                1'b0: status_bus_sel_5[i*32+31:i*32] <= status_bus_a[i*32+31:i*32];
                1'b1: status_bus_sel_5[i*32+31:i*32] <= status_bus_b[i*32+31:i*32];
                default : status_bus_sel_5[i*32+31:i*32] <= 32'b0;
            endcase
        end
        else;
    end

    always @(posedge core_clk or negedge core_rst_n)
    begin
        if(!core_rst_n)
            status_bus_sel_6[i*32+31:i*32] <= 32'b0;
        else if(uart_read_req_inv)
        begin
            case(uart_read_addr[0])
                1'b0: status_bus_sel_6[i*32+31:i*32] <= status_bus_c[i*32+31:i*32];
                1'b1: status_bus_sel_6[i*32+31:i*32] <= status_bus_d[i*32+31:i*32];
                default : status_bus_sel_6[i*32+31:i*32] <= 32'b0;
            endcase
        end
        else;
    end

    always @(posedge core_clk or negedge core_rst_n)
    begin
        if(!core_rst_n)
            status_bus_sel_7[i*32+31:i*32] <= 32'b0;
        else if(uart_read_req_inv)
        begin
            case(uart_read_addr[0])
                1'b0: status_bus_sel_7[i*32+31:i*32] <= status_bus_e[i*32+31:i*32];
                1'b1: status_bus_sel_7[i*32+31:i*32] <= status_bus_f[i*32+31:i*32];
                default : status_bus_sel_7[i*32+31:i*32] <= 32'b0;
            endcase
        end
        else;
    end

    always @(posedge core_clk or negedge core_rst_n)
    begin
        if(!core_rst_n)
            status_bus_sel[i*32+31:i*32] <= 32'b0;
        else if(uart_read_req_inv_d1)
        begin
            case(uart_read_addr[3:1])
                3'h0: status_bus_sel[i*32+31:i*32] <= status_bus_sel_0[i*32+31:i*32];
                3'h1: status_bus_sel[i*32+31:i*32] <= status_bus_sel_1[i*32+31:i*32];
                3'h2: status_bus_sel[i*32+31:i*32] <= status_bus_sel_2[i*32+31:i*32];
                3'h3: status_bus_sel[i*32+31:i*32] <= status_bus_sel_3[i*32+31:i*32];
                3'h4: status_bus_sel[i*32+31:i*32] <= status_bus_sel_4[i*32+31:i*32];
                3'h5: status_bus_sel[i*32+31:i*32] <= status_bus_sel_5[i*32+31:i*32];
                3'h6: status_bus_sel[i*32+31:i*32] <= status_bus_sel_6[i*32+31:i*32];
                3'h7: status_bus_sel[i*32+31:i*32] <= status_bus_sel_7[i*32+31:i*32];
                default : status_bus_sel[i*32+31:i*32] <= 32'b0;
            endcase
        end
        else;
    end
end
endgenerate

always @(posedge core_clk or negedge core_rst_n)
begin
    if(!core_rst_n)
        status_bus_lock <= 32'b0;
    else if(uart_read_req_inv_d2)
    begin
        case(uart_read_addr[8:4])
            5'h08: status_bus_lock <= status_bus_sel[32*0 +: 32];
            5'h09: status_bus_lock <= status_bus_sel[32*1 +: 32];
            5'h0a: status_bus_lock <= status_bus_sel[32*2 +: 32];
            5'h0b: status_bus_lock <= status_bus_sel[32*3 +: 32];
            5'h0c: status_bus_lock <= status_bus_sel[32*4 +: 32];
            5'h0d: status_bus_lock <= status_bus_sel[32*5 +: 32];
            5'h0e: status_bus_lock <= status_bus_sel[32*6 +: 32];
	    5'h0f: status_bus_lock <= status_bus_sel[32*7 +: 32];
            default : status_bus_lock <= 32'b0;
        endcase
    end
    else;
end

endmodule
