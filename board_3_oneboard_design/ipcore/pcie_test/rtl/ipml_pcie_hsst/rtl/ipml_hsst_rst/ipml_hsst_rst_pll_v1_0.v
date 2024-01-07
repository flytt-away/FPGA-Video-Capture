///////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
///////////////////////////////////////////////////////////////////////////////
//
// Library:
// Filename:
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module  ipml_hsst_rst_pll_v1_0#( 
    parameter FREE_CLOCK_FREQ         = 100            ,//Unit is MHz, free clock  freq from GUI Freq: 0~200MHz
    parameter PLL_NUBER               = 1
)(
    //User Side 
    input  wire                   clk                     ,
    input  wire                   i_pll_rst_0             ,
    input  wire                   i_pll_rst_1             ,
    input  wire                   P_PLL_READY_0           ,
    input  wire                   P_PLL_READY_1           ,
    input  wire                   i_wtchdg_clr_0          ,
    input  wire                   i_wtchdg_clr_1          ,
    output wire    [1 : 0]        o_wtchdg_st_0           ,
    output wire    [1 : 0]        o_wtchdg_st_1           ,
    output wire                   o_pll_done_0            ,
    output wire                   o_pll_done_1            ,
    output wire                   P_PLLPOWERDOWN_0        ,
    output wire                   P_PLLPOWERDOWN_1        ,
    output wire                   P_PLL_RST_0             ,
    output wire                   P_PLL_RST_1             
);


localparam PLL_LOCK_RISE_CNTR_WIDTH    = 12  ;
localparam PLL_LOCK_RISE_CNTR_VALUE    = 2048;
localparam PLL_LOCK_WTCHDG_CNTR1_WIDTH = 10  ;
localparam PLL_LOCK_WTCHDG_CNTR2_WIDTH = 10  ;

//****************************************************************************//
//                      Internal Signal                                       //
//****************************************************************************//
wire              pll_lock_0          ;
wire              wtchdg_rstn_0       ;
wire              pll_rstn_0          ;
wire              s_pll_rstn_0        ;
wire              s_pll_ready_0       ;
wire              i_pll_rstn_0        ;
//****************************************************************************//
//                      Sequential and Logic                                  //
//****************************************************************************//
assign    i_pll_rstn_0 = ~i_pll_rst_0 ;
//Sync signal
ipml_hsst_rst_sync_v1_0 pll0_rstn_sync (.clk(clk), .rst_n(i_pll_rstn_0), .sig_async(1'b1), .sig_synced(s_pll_rstn_0));
ipml_hsst_rst_sync_v1_0 pll0_lock_sync (.clk(clk), .rst_n(s_pll_rstn_0), .sig_async(P_PLL_READY_0), .sig_synced(s_pll_ready_0));

//Debounce
ipml_hsst_rst_debounce_v1_0  #(.RISE_CNTR_WIDTH(PLL_LOCK_RISE_CNTR_WIDTH), .RISE_CNTR_VALUE(PLL_LOCK_RISE_CNTR_VALUE))
pll0_lock_deb             (.clk(clk), .rst_n(s_pll_rstn_0), .signal_b(s_pll_ready_0), .signal_deb(pll_lock_0));

ipml_hsst_rst_wtchdg_v1_0  #(.WTCHDG_CNTR1_WIDTH(PLL_LOCK_WTCHDG_CNTR1_WIDTH), .WTCHDG_CNTR2_WIDTH(PLL_LOCK_WTCHDG_CNTR2_WIDTH))
pll0_lock_wtchdg       (.clk(clk), .rst_n(s_pll_rstn_0), .wtchdg_clr(i_wtchdg_clr_0), .wtchdg_in(s_pll_ready_0), .wtchdg_rst_n(wtchdg_rstn_0), .wtchdg_st(o_wtchdg_st_0));

assign pll_rstn_0  =  wtchdg_rstn_0 && s_pll_rstn_0  ;

//-----  Instance pll Rst Fsm Module -----------
ipml_hsst_pll_rst_fsm_v1_0#(
    .FREE_CLOCK_FREQ    (FREE_CLOCK_FREQ    )
) pll_rst_fsm_0 (
    .clk                (clk                ),
    .rst_n              (pll_rstn_0         ),
    .pll_lock           (pll_lock_0         ),
    .P_PLLPOWERDOWN     (P_PLLPOWERDOWN_0   ),
    .P_PLL_RST          (P_PLL_RST_0        ),
    .o_pll_done         (o_pll_done_0       ) 
);

generate
if(PLL_NUBER == 2) begin : PLL_FSM_2_GENERATE
//****************************************************************************//
//                      Internal Signal                                       //
//****************************************************************************//
wire              pll_lock_1          ;
wire              wtchdg_rstn_1       ;
wire              pll_rstn_1          ;
wire              s_pll_rstn_1        ;
wire              s_pll_ready_1       ;
wire              i_pll_rstn_1        ;
//****************************************************************************//
//                      Sequential and Logic                                  //
//****************************************************************************//
assign    i_pll_rstn_1 = ~i_pll_rst_1 ;
//Sync signal
ipml_hsst_rst_sync_v1_0 pll1_rstn_sync (.clk(clk), .rst_n(i_pll_rstn_1), .sig_async(1'b1), .sig_synced(s_pll_rstn_1));
ipml_hsst_rst_sync_v1_0 pll1_lock_sync (.clk(clk), .rst_n(s_pll_rstn_1), .sig_async(P_PLL_READY_1), .sig_synced(s_pll_ready_1));

//Debounce
ipml_hsst_rst_debounce_v1_0  #(.RISE_CNTR_WIDTH(PLL_LOCK_RISE_CNTR_WIDTH), .RISE_CNTR_VALUE(PLL_LOCK_RISE_CNTR_VALUE))
pll1_lock_deb             (.clk(clk), .rst_n(s_pll_rstn_1), .signal_b(s_pll_ready_1), .signal_deb(pll_lock_1));

ipml_hsst_rst_wtchdg_v1_0  #(.WTCHDG_CNTR1_WIDTH(PLL_LOCK_WTCHDG_CNTR1_WIDTH), .WTCHDG_CNTR2_WIDTH(PLL_LOCK_WTCHDG_CNTR2_WIDTH))
pll1_lock_wtchdg       (.clk(clk), .rst_n(s_pll_rstn_1), .wtchdg_clr(i_wtchdg_clr_1), .wtchdg_in(s_pll_ready_1), .wtchdg_rst_n(wtchdg_rstn_1), .wtchdg_st(o_wtchdg_st_1));

assign pll_rstn_1  =  wtchdg_rstn_1 && s_pll_rstn_1  ;

//-----  Instance pll Rst Fsm Module -----------
ipml_hsst_pll_rst_fsm_v1_0#(
    .FREE_CLOCK_FREQ    (FREE_CLOCK_FREQ    )
) pll_rst_fsm_1 (
    .clk                (clk                ),
    .rst_n              (pll_rstn_1         ),
    .pll_lock           (pll_lock_1         ),
    .P_PLLPOWERDOWN     (P_PLLPOWERDOWN_1   ),
    .P_PLL_RST          (P_PLL_RST_1        ),
    .o_pll_done         (o_pll_done_1       ) 
);
end
else  begin : PLL_FSM_2_NO_GENERATE
    assign o_wtchdg_st_1    =    2'b0;
    assign o_pll_done_1     =    1'b0;
    assign P_PLLPOWERDOWN_1 =    1'b1;
    assign P_PLL_RST_1      =    1'b1;
end
endgenerate

endmodule
