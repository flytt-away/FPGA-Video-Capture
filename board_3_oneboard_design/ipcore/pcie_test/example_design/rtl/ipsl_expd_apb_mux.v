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
module ipsl_expd_apb_mux (
    //from uart domain
    input                   i_uart_clk          ,
    input                   i_uart_rst_n        ,
    input                   i_uart_p_sel        ,
    input           [3:0]   i_uart_p_strb       ,
    input           [15:0]  i_uart_p_addr       ,
    input           [31:0]  i_uart_p_wdata      ,
    input                   i_uart_p_ce         ,
    input                   i_uart_p_we         ,
    output  wire            o_uart_p_rdy        ,
    output  wire    [31:0]  o_uart_p_rdata      ,
    //to dma domain
    input                   i_pclk_div2_clk     ,
    input                   i_pclk_div2_rst_n   ,
    //
    output  wire    [3:0]   o_pclk_div2_p_strb  ,
    output  wire    [15:0]  o_pclk_div2_p_addr  ,
    output  wire    [31:0]  o_pclk_div2_p_wdata ,
    output  wire            o_pclk_div2_p_ce    ,
    output  wire            o_pclk_div2_p_we    ,

    output  wire            o_pcie_p_sel        ,
    input                   i_pcie_p_rdy        ,
    input           [31:0]  i_pcie_p_rdata      ,

    output  wire            o_dma_p_sel         ,
    input                   i_dma_p_rdy         ,
    input           [31:0]  i_dma_p_rdata       ,
    //to cfg domain
    output  wire            o_cfg_p_sel         ,
    input                   i_cfg_p_rdy         ,
    input           [31:0]  i_cfg_p_rdata
);

wire            expd_sel            ;
wire            expd_rdy            ;
wire    [31:0]  expd_rdata          ;

wire            pclk_div2_p_sel     ;

wire            pclk_div2_p_rdy     ;
wire    [31:0]  pclk_div2_p_rdata   ;

//apb mux
assign o_pcie_p_sel     = ((i_uart_p_addr[15:12] < 4'h2) || (i_uart_p_addr[15:12] >=7)) ? i_uart_p_sel     : 1'b0  ;

assign expd_sel         = ((i_uart_p_addr[15:12] < 4'h2) || (i_uart_p_addr[15:12] >=7)) ? 1'b0             : i_uart_p_sel ;

assign o_uart_p_rdy     = ((i_uart_p_addr[15:12] < 4'h2) || (i_uart_p_addr[15:12] >=7)) ? i_pcie_p_rdy     : expd_rdy;

assign o_uart_p_rdata   = ((i_uart_p_addr[15:12] < 4'h2) || (i_uart_p_addr[15:12] >=7)) ? i_pcie_p_rdata   : expd_rdata ;

ipsl_pcie_apb_cross_v1_0 u_pcie_expd_apb_cross(
    //from src domain
    .i_src_clk               (i_uart_clk             ),
    .i_src_rst_n             (i_uart_rst_n           ),
    .i_src_p_sel             (expd_sel               ),
    .i_src_p_strb            (i_uart_p_strb          ),
    .i_src_p_addr            (i_uart_p_addr          ),
    .i_src_p_wdata           (i_uart_p_wdata         ),
    .i_src_p_ce              (i_uart_p_ce            ),
    .i_src_p_we              (i_uart_p_we            ),
    .o_src_p_rdy             (expd_rdy               ),
    .o_src_p_rdata           (expd_rdata             ),
    //to target domain
    .i_des_clk               (i_pclk_div2_clk        ),
    .i_des_rst_n             (i_pclk_div2_rst_n      ),
    .o_des_p_sel             (pclk_div2_p_sel        ),
    .o_des_p_strb            (o_pclk_div2_p_strb     ),
    .o_des_p_addr            (o_pclk_div2_p_addr     ),
    .o_des_p_wdata           (o_pclk_div2_p_wdata    ),
    .o_des_p_ce              (o_pclk_div2_p_ce       ),
    .o_des_p_we              (o_pclk_div2_p_we       ),
    .i_des_p_rdy             (pclk_div2_p_rdy        ),
    .i_des_p_rdata           (pclk_div2_p_rdata      )
);

assign o_dma_p_sel       = (o_pclk_div2_p_addr[15:12] == 4'h3) ? pclk_div2_p_sel   : 1'b0  ;

assign o_cfg_p_sel       = (o_pclk_div2_p_addr[15:12] == 4'h4) ? pclk_div2_p_sel   : 1'b0  ;

assign pclk_div2_p_rdy   = (o_pclk_div2_p_addr[15:12] == 4'h3) ? i_dma_p_rdy       :
                           (o_pclk_div2_p_addr[15:12] == 4'h4) ? i_cfg_p_rdy       : 1'b0  ;

assign pclk_div2_p_rdata = (o_pclk_div2_p_addr[15:12] == 4'h3) ? i_dma_p_rdata     :
                           (o_pclk_div2_p_addr[15:12] == 4'h4) ? i_cfg_p_rdata     : 32'b0 ;

endmodule