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
module  ipml_hsst_lane_powerup_v1_0#( 
    parameter FREE_CLOCK_FREQ         = 100           , //Unit is MHz, free clock  freq from GUI Freq: 0~200MHz
    parameter CH0_TX_ENABLE           = "TRUE"        , //TRUE:lane0 TX Reset Logic used, FALSE: lane0 TX Reset Logic remove
    parameter CH1_TX_ENABLE           = "TRUE"        , //TRUE:lane1 TX Reset Logic used, FALSE: lane1 TX Reset Logic remove
    parameter CH2_TX_ENABLE           = "TRUE"        , //TRUE:lane2 TX Reset Logic used, FALSE: lane2 TX Reset Logic remove
    parameter CH3_TX_ENABLE           = "TRUE"        , //TRUE:lane3 TX Reset Logic used, FALSE: lane3 TX Reset Logic remove
    parameter CH0_RX_ENABLE           = "TRUE"        , //TRUE:lane0 RX Reset Logic used, FALSE: lane0 RX Reset Logic remove
    parameter CH1_RX_ENABLE           = "TRUE"        , //TRUE:lane1 RX Reset Logic used, FALSE: lane1 RX Reset Logic remove
    parameter CH2_RX_ENABLE           = "TRUE"        , //TRUE:lane2 RX Reset Logic used, FALSE: lane2 RX Reset Logic remove
    parameter CH3_RX_ENABLE           = "TRUE"        , //TRUE:lane3 RX Reset Logic used, FALSE: lane3 RX Reset Logic remove
    parameter CH0_MULT_LANE_MODE      = 1             , //Lane0 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    parameter CH1_MULT_LANE_MODE      = 1             , //Lane1 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    parameter CH2_MULT_LANE_MODE      = 1             , //Lane2 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    parameter CH3_MULT_LANE_MODE      = 1             , //Lane3 --> 1: Singel Lane 2:Two Lane 4:Four Lane
    parameter CH0_TX_PLL_SEL          = 0             ,//Lane0 --> 1:PLL1  0:PLL0
    parameter CH1_TX_PLL_SEL          = 0             ,//Lane1 --> 1:PLL1  0:PLL0
    parameter CH2_TX_PLL_SEL          = 0             ,//Lane2 --> 1:PLL1  0:PLL0
    parameter CH3_TX_PLL_SEL          = 0             ,//Lane3 --> 1:PLL1  0:PLL0
    parameter CH0_RX_PLL_SEL          = 0             ,//Lane0 --> 1:PLL1  0:PLL0
    parameter CH1_RX_PLL_SEL          = 0             ,//Lane1 --> 1:PLL1  0:PLL0
    parameter CH2_RX_PLL_SEL          = 0             ,//Lane2 --> 1:PLL1  0:PLL0
    parameter CH3_RX_PLL_SEL          = 0              //Lane3 --> 1:PLL1  0:PLL0
)(
    // Reset and Clock 
    input  wire                   clk                     ,
    input  wire                   i_lane_pd_0             ,
    input  wire                   i_lane_pd_1             ,
    input  wire                   i_lane_pd_2             ,
    input  wire                   i_lane_pd_3             ,
    input  wire                   o_pll_done_0            ,
    input  wire                   o_pll_done_1            ,
    output wire                   P_LANE_PD_0             ,
    output wire                   P_LANE_PD_1             ,
    output wire                   P_LANE_PD_2             ,
    output wire                   P_LANE_PD_3             ,
    output wire                   P_LANE_RST_0            ,
    output wire                   P_LANE_RST_1            ,
    output wire                   P_LANE_RST_2            ,
    output wire                   P_LANE_RST_3                 
);

`ifdef IPML_HSST_SPEEDUP_SIM
localparam integer LANE_PD_CNTR_VALUE                  = 2*((1*FREE_CLOCK_FREQ)); //add 50 percent margin
localparam integer LANE_RST_CNTR_VALUE                 = 2*((2*FREE_CLOCK_FREQ)); //add 50 percent margin
`else
localparam integer LANE_PD_CNTR_VALUE                  = 2*((40*FREE_CLOCK_FREQ)); //add 50 percent margin
localparam integer LANE_RST_CNTR_VALUE                 = 2*((41*FREE_CLOCK_FREQ)); //add 50 percent margin
`endif
//Counter Width
localparam         CNTR_WIDTH                        = 14 ;

//****************************************************************************//
//                      Internal Signal                                       //
//****************************************************************************//
wire  [4-1    :0] o_lane_pd           ;
wire  [4-1    :0] o_lane_rst          ;
wire  [4-1    :0] p_lane_pd           ;
wire  [4-1    :0] p_lane_rst          ;
//****************************************************************************//
//                      Sequential and Logic                                  //
//****************************************************************************//
//-----  Instance Lane Powerup Logic Module -----------
//Lane0
generate
if(CH0_TX_ENABLE=="TRUE" || CH0_RX_ENABLE=="TRUE") begin : LANE0_ENABLE //Lane is Enable
    //signal
    wire                      i_lane_pd_n_0      ;
    wire                      s_lane_pd_n_0      ;
    wire                      lane_pd_n_0        ;
    reg                       o_lane_pd_0        ;
    reg                       o_lane_rst_0       ;
    reg  [CNTR_WIDTH-1 : 0]   cntr0              ;
    //logic
    assign i_lane_pd_n_0    = ~i_lane_pd_0       ;
    ipml_hsst_rst_sync_v1_0 lane_pd_n_0_sync (.clk(clk), .rst_n(i_lane_pd_n_0), .sig_async(1'b1), .sig_synced(s_lane_pd_n_0));
    assign lane_pd_n_0      = s_lane_pd_n_0 && o_pll_done_0 ;
    
    always @(posedge clk or negedge lane_pd_n_0)
    begin
        if(!lane_pd_n_0)
            cntr0                   <= {CNTR_WIDTH{1'b0}}   ;
        else if (cntr0 == LANE_RST_CNTR_VALUE)
            cntr0                   <= cntr0                ;
        else
            cntr0 <= cntr0 + {{CNTR_WIDTH-1{1'b0}},{1'b1}}  ;
    end

    always @(posedge clk or negedge lane_pd_n_0)
    begin
        if(!lane_pd_n_0)
            o_lane_pd_0             <= 1'b1                 ;
        else if (cntr0 == LANE_PD_CNTR_VALUE)
            o_lane_pd_0             <= 1'b0                 ;
        else
            o_lane_pd_0             <= o_lane_pd_0          ;
    end

    always @(posedge clk or negedge lane_pd_n_0)
    begin
        if(!lane_pd_n_0)
            o_lane_rst_0            <= 1'b1                 ;
        else if (cntr0 == LANE_RST_CNTR_VALUE)
            o_lane_rst_0            <= 1'b0                 ;
        else
            o_lane_rst_0            <= o_lane_rst_0         ;
    end

    assign o_lane_pd [0]     = o_lane_pd_0                  ;
    assign o_lane_rst[0]     = o_lane_rst_0                 ;
end
else begin : LANE0_DISABLE //Lane is disable
    assign o_lane_pd [0]     = 1'b1                         ;
    assign o_lane_rst[0]     = 1'b1                         ;                           
end
endgenerate

//Lane1
generate
if((CH1_TX_ENABLE=="TRUE" || CH1_RX_ENABLE=="TRUE") && (CH1_MULT_LANE_MODE   == 1)) begin : LANE1_ENABLE //Lane is Enable
    //signal
    wire                      i_lane_pd_n_1      ;
    wire                      s_lane_pd_n_1      ;
    wire                      lane_pd_n_1        ;
    reg                       o_lane_pd_1        ;
    reg                       o_lane_rst_1       ;
    reg  [CNTR_WIDTH-1 : 0]   cntr1              ;
    //logic
    assign i_lane_pd_n_1    = ~i_lane_pd_1       ;
    ipml_hsst_rst_sync_v1_0 lane_pd_n_1_sync (.clk(clk), .rst_n(i_lane_pd_n_1), .sig_async(1'b1), .sig_synced(s_lane_pd_n_1));
    assign lane_pd_n_1      = s_lane_pd_n_1 && o_pll_done_0 ;
    
    always @(posedge clk or negedge lane_pd_n_1)
    begin
        if(!lane_pd_n_1)
            cntr1                   <= {CNTR_WIDTH{1'b0}}   ;
        else if (cntr1 == LANE_RST_CNTR_VALUE)
            cntr1                   <= cntr1                ;
        else
            cntr1 <= cntr1 + {{CNTR_WIDTH-1{1'b0}},{1'b1}}  ;
    end

    always @(posedge clk or negedge lane_pd_n_1)
    begin
        if(!lane_pd_n_1)
            o_lane_pd_1             <= 1'b1                 ;
        else if (cntr1 == LANE_PD_CNTR_VALUE)
            o_lane_pd_1             <= 1'b0                 ;
        else
            o_lane_pd_1             <= o_lane_pd_1          ;
    end

    always @(posedge clk or negedge lane_pd_n_1)
    begin
        if(!lane_pd_n_1)
            o_lane_rst_1            <= 1'b1                 ;
        else if (cntr1 == LANE_RST_CNTR_VALUE)
            o_lane_rst_1            <= 1'b0                 ;
        else
            o_lane_rst_1            <= o_lane_rst_1         ;
    end
    
    assign o_lane_pd [1]     = o_lane_pd_1                  ;
    assign o_lane_rst[1]     = o_lane_rst_1                 ;
end
else begin : LANE1_DISABLE //Lane is disable
    assign o_lane_pd [1]     = 1'b1                         ;
    assign o_lane_rst[1]     = 1'b1                         ;                           
end
endgenerate

//Lane2
generate
if((CH2_TX_ENABLE=="TRUE" || CH2_RX_ENABLE=="TRUE") && (CH2_MULT_LANE_MODE   != 4)) begin : LANE2_ENABLE //Lane is Enable
    //signal
    wire                      i_lane_pd_n_2      ;
    wire                      s_lane_pd_n_2      ;
    wire                      lane_pd_n_2        ;
    wire                      pll_done_2         ;
    reg                       o_lane_pd_2        ;
    reg                       o_lane_rst_2       ;
    reg  [CNTR_WIDTH-1 : 0]   cntr2              ;
    //logic
    assign i_lane_pd_n_2    = ~i_lane_pd_2       ;
    ipml_hsst_rst_sync_v1_0 lane_pd_n_2_sync (.clk(clk), .rst_n(i_lane_pd_n_2), .sig_async(1'b1), .sig_synced(s_lane_pd_n_2));
    assign pll_done_2       = (CH2_TX_ENABLE=="TRUE") ? ((CH2_TX_PLL_SEL==0) ? o_pll_done_0 : o_pll_done_1) :
                                                        ((CH2_RX_PLL_SEL==0) ? o_pll_done_0 : o_pll_done_1) ;
    assign lane_pd_n_2      = s_lane_pd_n_2 && pll_done_2 ;
    
    always @(posedge clk or negedge lane_pd_n_2)
    begin
        if(!lane_pd_n_2)
            cntr2                   <= {CNTR_WIDTH{1'b0}}   ;
        else if (cntr2 == LANE_RST_CNTR_VALUE)
            cntr2                   <= cntr2                ;
        else
            cntr2 <= cntr2 + {{CNTR_WIDTH-1{1'b0}},{1'b1}}  ;
    end

    always @(posedge clk or negedge lane_pd_n_2)
    begin
        if(!lane_pd_n_2)
            o_lane_pd_2             <= 1'b1                 ;
        else if (cntr2 == LANE_PD_CNTR_VALUE)
            o_lane_pd_2             <= 1'b0                 ;
        else
            o_lane_pd_2             <= o_lane_pd_2          ;
    end

    always @(posedge clk or negedge lane_pd_n_2)
    begin
        if(!lane_pd_n_2)
            o_lane_rst_2            <= 1'b1                 ;
        else if (cntr2 == LANE_RST_CNTR_VALUE)
            o_lane_rst_2            <= 1'b0                 ;
        else
            o_lane_rst_2            <= o_lane_rst_2         ;
    end
    
    assign o_lane_pd [2]     = o_lane_pd_2                  ;
    assign o_lane_rst[2]     = o_lane_rst_2                 ;
end
else begin : LANE2_DISABLE //Lane is disable
    assign o_lane_pd [2]     = 1'b1                         ;
    assign o_lane_rst[2]     = 1'b1                         ;                           
end
endgenerate

//Lane3
generate
if((CH3_TX_ENABLE=="TRUE" || CH3_RX_ENABLE=="TRUE") && (CH3_MULT_LANE_MODE   == 1)) begin : LANE3_ENABLE //Lane is Enable
    //signal
    wire                      i_lane_pd_n_3      ;
    wire                      s_lane_pd_n_3      ;
    wire                      lane_pd_n_3        ;
    wire                      pll_done_3         ;
    reg                       o_lane_pd_3        ;
    reg                       o_lane_rst_3       ;
    reg  [CNTR_WIDTH-1 : 0]   cntr3              ;
    //logic
    assign i_lane_pd_n_3    = ~i_lane_pd_3       ;
    ipml_hsst_rst_sync_v1_0 lane_pd_n_3_sync (.clk(clk), .rst_n(i_lane_pd_n_3), .sig_async(1'b1), .sig_synced(s_lane_pd_n_3));
    assign pll_done_3       = (CH3_TX_ENABLE=="TRUE") ? ((CH3_TX_PLL_SEL==0) ? o_pll_done_0 : o_pll_done_1) :
                                                        ((CH3_RX_PLL_SEL==0) ? o_pll_done_0 : o_pll_done_1) ;
    assign lane_pd_n_3      = s_lane_pd_n_3 && pll_done_3 ;
    
    always @(posedge clk or negedge lane_pd_n_3)
    begin
        if(!lane_pd_n_3)
            cntr3                   <= {CNTR_WIDTH{1'b0}}   ;
        else if (cntr3 == LANE_RST_CNTR_VALUE)
            cntr3                   <= cntr3                ;
        else
            cntr3 <= cntr3 + {{CNTR_WIDTH-1{1'b0}},{1'b1}}  ;
    end

    always @(posedge clk or negedge lane_pd_n_3)
    begin
        if(!lane_pd_n_3)
            o_lane_pd_3             <= 1'b1                 ;
        else if (cntr3 == LANE_PD_CNTR_VALUE)
            o_lane_pd_3             <= 1'b0                 ;
        else
            o_lane_pd_3             <= o_lane_pd_3          ;
    end

    always @(posedge clk or negedge lane_pd_n_3)
    begin
        if(!lane_pd_n_3)
            o_lane_rst_3            <= 1'b1                 ;
        else if (cntr3 == LANE_RST_CNTR_VALUE)
            o_lane_rst_3            <= 1'b0                 ;
        else
            o_lane_rst_3            <= o_lane_rst_3         ;
    end
    
    assign o_lane_pd [3]     = o_lane_pd_3                  ;
    assign o_lane_rst[3]     = o_lane_rst_3                 ;
end
else begin : LANE3_DISABLE //Lane is disable
    assign o_lane_pd [3]     = 1'b1                         ;
    assign o_lane_rst[3]     = 1'b1                         ;                           
end
endgenerate

generate
if(CH0_MULT_LANE_MODE==4) begin:FOUR_LANE_MODE
    //To HSST
    assign p_lane_pd           = {4{o_lane_pd             [0]}};
    assign p_lane_rst          = {4{o_lane_rst            [0]}};
end
else if(CH0_MULT_LANE_MODE==2 && CH2_MULT_LANE_MODE==2) begin: TWO_LANE_MODE
    //To HSST
    assign p_lane_pd           = {{2{o_lane_pd             [2]}},{2{o_lane_pd             [0]}}};
    assign p_lane_rst          = {{2{o_lane_rst            [2]}},{2{o_lane_rst            [0]}}};
end
else if(CH0_MULT_LANE_MODE==2) begin:TWO_LANE_MODE0
    //To HSST
    assign p_lane_pd           = {o_lane_pd             [3],o_lane_pd             [2],{2{o_lane_pd             [0]}}};
    assign p_lane_rst          = {o_lane_rst            [3],o_lane_rst            [2],{2{o_lane_rst            [0]}}};
end
else if(CH2_MULT_LANE_MODE==2) begin:TWO_LANE_MODE1
    //To HSST      
    assign p_lane_pd           = {{2{o_lane_pd             [2]}},o_lane_pd             [1],o_lane_pd             [0]};
    assign p_lane_rst          = {{2{o_lane_rst            [2]}},o_lane_rst            [1],o_lane_rst            [0]};
end
else begin:ONE_LANE_MODE
    //To HSST      
    assign p_lane_pd           = {o_lane_pd        [3],o_lane_pd        [2],o_lane_pd        [1],o_lane_pd        [0]};
    assign p_lane_rst          = {o_lane_rst       [3],o_lane_rst       [2],o_lane_rst       [1],o_lane_rst       [0]};
end
endgenerate

assign P_LANE_PD_0            = p_lane_pd[0] ;
assign P_LANE_PD_1            = p_lane_pd[1] ;
assign P_LANE_PD_2            = p_lane_pd[2] ;
assign P_LANE_PD_3            = p_lane_pd[3] ;
assign P_LANE_RST_0           = p_lane_rst[0];
assign P_LANE_RST_1           = p_lane_rst[1];
assign P_LANE_RST_2           = p_lane_rst[2];
assign P_LANE_RST_3           = p_lane_rst[3];

endmodule
