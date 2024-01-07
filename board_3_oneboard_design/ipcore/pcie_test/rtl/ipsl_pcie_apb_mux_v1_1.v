//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
module ipsl_pcie_apb_mux_v1_1 (
    //from uart domain
    input                   i_uart_clk     ,
    input                   i_uart_rst_n   ,
    input                   i_uart_p_sel   ,
    input           [3:0]   i_uart_p_strb  ,
    input           [15:0]  i_uart_p_addr  ,
    input           [31:0]  i_uart_p_wdata ,
    input                   i_uart_p_ce    ,
    input                   i_uart_p_we    ,
    output  wire            o_uart_p_rdy   ,
    output  wire    [31:0]  o_uart_p_rdata ,
    //to pcie domain
    input                   i_pcie_clk     ,
    input                   i_pcie_rst_n   ,
    output  wire            o_pcie_p_sel   ,
    output  wire    [3:0]   o_pcie_p_strb  ,
    output  wire    [15:0]  o_pcie_p_addr  ,
    output  wire    [31:0]  o_pcie_p_wdata ,
    output  wire            o_pcie_p_ce    ,
    output  wire            o_pcie_p_we    ,
    input                   i_pcie_p_rdy   ,
    input           [31:0]  i_pcie_p_rdata ,
    //to hsstlp domain
    input                   i_hsst_clk     ,
    input                   i_hsst_rst_n   ,
    output  wire            o_hsst_p_sel   ,
    output  wire    [3:0]   o_hsst_p_strb  ,
    output  wire    [15:0]  o_hsst_p_addr  ,
    output  wire    [31:0]  o_hsst_p_wdata ,
    output  wire            o_hsst_p_ce    ,
    output  wire            o_hsst_p_we    ,
    input                   i_hsst_p_rdy   ,
    input           [31:0]  i_hsst_p_rdata
);

wire            pcie_p_sel  ;
wire    [3:0]   pcie_p_strb ;
wire    [15:0]  pcie_p_addr ;
wire    [31:0]  pcie_p_wdata;
wire            pcie_p_ce   ;
wire            pcie_p_we   ;
wire            pcie_p_rdy  ;
wire    [31:0]  pcie_p_rdata;

//apb mux
assign o_hsst_p_sel   = ((i_uart_p_addr[15:12] <  4'h2) || (i_uart_p_addr[15:12] >7)) ? i_uart_p_sel   : 1'b0 ;

assign pcie_p_sel     = (i_uart_p_addr[15:12] == 4'h7) ? i_uart_p_sel   : 1'b0 ;

assign o_uart_p_rdy   = ((i_uart_p_addr[15:12] <  4'h2) || (i_uart_p_addr[15:12] >7)) ? i_hsst_p_rdy   :
                        (i_uart_p_addr[15:12] == 4'h7) ? pcie_p_rdy     : 1'b0 ;

assign o_uart_p_rdata = ((i_uart_p_addr[15:12] <  4'h2) || (i_uart_p_addr[15:12] >7)) ? i_hsst_p_rdata :
                        (i_uart_p_addr[15:12] == 4'h7) ? pcie_p_rdata   : 32'b0;

//apb2hsst
assign o_hsst_p_strb  = ((i_uart_p_addr[15:12] <  4'h2) || (i_uart_p_addr[15:12] >7)) ? i_uart_p_strb  : 4'b0  ;
assign o_hsst_p_addr  = ((i_uart_p_addr[15:12] <  4'h2) || (i_uart_p_addr[15:12] >7)) ? i_uart_p_addr  : 16'b0 ;
assign o_hsst_p_wdata = ((i_uart_p_addr[15:12] <  4'h2) || (i_uart_p_addr[15:12] >7)) ? i_uart_p_wdata : 32'b0 ;
assign o_hsst_p_ce    = ((i_uart_p_addr[15:12] <  4'h2) || (i_uart_p_addr[15:12] >7)) ? i_uart_p_ce    : 1'b0  ;
assign o_hsst_p_we    = ((i_uart_p_addr[15:12] <  4'h2) || (i_uart_p_addr[15:12] >7)) ? i_uart_p_we    : 1'b0  ;

//apb2pcie
assign pcie_p_strb    = (i_uart_p_addr[15:12] == 4'h7) ? i_uart_p_strb  : 4'b0  ;
assign pcie_p_addr    = (i_uart_p_addr[15:12] == 4'h7) ? i_uart_p_addr  : 16'b0 ;
assign pcie_p_wdata   = (i_uart_p_addr[15:12] == 4'h7) ? i_uart_p_wdata : 32'b0 ;
assign pcie_p_ce      = (i_uart_p_addr[15:12] == 4'h7) ? i_uart_p_ce    : 1'b0  ;
assign pcie_p_we      = (i_uart_p_addr[15:12] == 4'h7) ? i_uart_p_we    : 1'b0  ;

ipsl_pcie_apb_cross_v1_0 u_pcie_apb_cross(
    //from src domain
    .i_src_clk                (i_uart_clk    ),
    .i_src_rst_n              (i_uart_rst_n  ),
    .i_src_p_sel              (pcie_p_sel    ),
    .i_src_p_strb             (pcie_p_strb   ),
    .i_src_p_addr             (pcie_p_addr   ),
    .i_src_p_wdata            (pcie_p_wdata  ),
    .i_src_p_ce               (pcie_p_ce     ),
    .i_src_p_we               (pcie_p_we     ),
    .o_src_p_rdy              (pcie_p_rdy    ),
    .o_src_p_rdata            (pcie_p_rdata  ),
    //to target domain
    .i_des_clk                (i_pcie_clk    ),
    .i_des_rst_n              (i_pcie_rst_n  ),
    .o_des_p_sel              (o_pcie_p_sel  ),
    .o_des_p_strb             (o_pcie_p_strb ),
    .o_des_p_addr             (o_pcie_p_addr ),
    .o_des_p_wdata            (o_pcie_p_wdata),
    .o_des_p_ce               (o_pcie_p_ce   ),
    .o_des_p_we               (o_pcie_p_we   ),
    .i_des_p_rdy              (i_pcie_p_rdy  ),
    .i_des_p_rdata            (i_pcie_p_rdata)
);

endmodule
