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
module  ipml_hsst_rxlane_rst_fsm_v1_1#(
    parameter FREE_CLOCK_FREQ          = 100        , //unit is MHz, free clock  freq from GUI
    parameter CH_MULT_LANE_MODE        = 1          , //1: 1lane 2:2lane 4:4lane
    parameter CH_RXPCS_ALIGN_TIMER     = 10000      , //maximum is 65535
    parameter CH_BYPASS_WORD_ALIGN     = "FALSE"    , //TRUE: Lane Bypass Word Alignment, FALSE: Lane No Bypass Word Alignment
    parameter CH_BYPASS_BONDING        = "FALSE"    , //TRUE: Lane Bypass Channel Bonding, FALSE: Lane No Bypass Channel Bonding
    parameter CH_BYPASS_CTC            = "FALSE"    , //TRUE: Lane Bypass CTC, FALSE: Lane No Bypass CTC
    parameter LX_RX_CKDIV              = 0          ,
    parameter PCS_RX_CLK_EXPLL_USE     = "FALSE"          
)(
    // Reset and Clock
    input  wire                   clk                   ,
    input  wire                   rst_n                 ,
    // HSST Reset Control Signal
    input  wire                   fifo_clr_en           ,
    input  wire                   i_rx_rate_chng        ,
    input  wire   [2:0]           i_rxckdiv             ,
    input  wire                   sigdet                ,
    input  wire                   cdr_align             ,
    input  wire                   word_align            ,
    input  wire                   bonding               ,
    input  wire                   i_pll_lock_rx         ,
    input  wire                   i_pcs_cb_rst          ,
    output reg                    P_RX_LANE_PD          ,
    output reg                    P_RX_PMA_RST          ,
    output reg                    P_PCS_RX_RST          ,
    output reg    [2:0]           P_RX_RATE             ,
    output wire                   P_PCS_CB_RST          ,
    output reg                    o_rxckdiv_done        ,
    output reg                    o_rxlane_done         ,
    output reg                    fifoclr_sig       
);

//RX Lane Power Up
`ifdef IPML_HSST_SPEEDUP_SIM
localparam integer RX_PD_CNTR_VALUE                  = 2*((1*FREE_CLOCK_FREQ)); //add 50 percent margin
localparam integer RX_PCS_CNTR_VALUE                 = 2*((1*FREE_CLOCK_FREQ)); //add 50 percent margin
`else
localparam integer RX_PD_CNTR_VALUE                  = 2*((40*FREE_CLOCK_FREQ)); //add 50 percent margin
localparam integer RX_PCS_CNTR_VALUE                 = 2*((10*FREE_CLOCK_FREQ)); //add 50 percent margin
`endif
localparam integer RX_CDR_WAIT_CNTR_VALUE            = 224*FREE_CLOCK_FREQ+2048;// max time : (16*8191/600)+2+2048 cycle
localparam integer RX_PMA_CNTR_VALUE                 = 2*((1*FREE_CLOCK_FREQ)); //add 50 percent margin
localparam integer RX_RST_DONE_DLY_CNTR_VALUE        = 32;//add for rxlane_done is active but fabric clock is none by wenbin at @2019.9.26
//RX Lane Rate Change
localparam integer RX_RATE_CHANGE_PMA_R_CNTR_VALUE   = 2*((0.05*FREE_CLOCK_FREQ)); //add 50 percent margin
localparam integer RX_RATE_CHANGE_PMA_F_CNTR_VALUE   = 2*((0.1*FREE_CLOCK_FREQ)); //add 50 percent margin
//Counter Width
localparam         CNTR_WIDTH0                       = 13 ;
localparam         CNTR_WIDTH1                       = 8  ;
localparam         CNTR_WIDTH2                       = 15 ;
localparam         CNTR_WIDTH3                       = 11 ;
localparam         CNTR_WIDTH4                       = 6  ;
localparam         CNTR_WIDTH5                       = 5  ;
localparam         CNTR_WIDTH6                       = log2(CH_RXPCS_ALIGN_TIMER);
//RX Lane FSM Status
localparam RX_LANE_IDLE         = 4'd0;
localparam RX_LANE_RXPD         = 4'd1;
localparam RX_LANE_PMA_RST      = 4'd2;
localparam RX_LANE_SIGNAL_WAIT  = 4'd3;
localparam RX_LANE_CDR_WAIT     = 4'd4;
localparam RX_LANE_PCS_RST      = 4'd5;
localparam RX_LANE_ALIGN_WAIT   = 4'd6;
localparam RX_LANE_BONDING_WAIT = 4'd7;
localparam RX_LANE_DONE         = 4'd8;
localparam RX_LANE_CB_RST       = 4'd9;
localparam RX_CKDIV_ONLY        = 4'd10;

//****************************************************************************//
//                      Internal Signal                                       //
//****************************************************************************//
reg     [CNTR_WIDTH0-1  : 0] cntr0                ;
reg     [CNTR_WIDTH1-1  : 0] cntr1                ;
reg     [CNTR_WIDTH2-1  : 0] cntr2                ;
reg     [CNTR_WIDTH3-1  : 0] cntr3                ;
reg     [CNTR_WIDTH4-1  : 0] cntr4                ;
reg     [CNTR_WIDTH5-1  : 0] cntr5                ;
reg     [CNTR_WIDTH6-1  : 0] cntr6                ;
reg     [3            : 0] rxlane_rst_fsm       ;
reg     [3            : 0] next_state           ;
reg     [1            : 0] i_rx_rate_chng_ff    ;
reg                        i_rx_rate_chng_posedge   ;
wire                       rxlane_word_align_en ;
wire                       rxlane_bonding_en    ;
wire                       rxlane_mult_en       ;
wire                       expll_lock_rx        ;
reg     [2            : 0] i_rxckdiv_ff         ;
reg     [2            : 0] rxckdiv              ;
//****************************************************************************//
//                      Sequential and Logic                                  //
//****************************************************************************//
assign rxlane_word_align_en     = (CH_BYPASS_WORD_ALIGN=="FALSE") ? 1'b1 : 1'b0;
assign rxlane_bonding_en        = (CH_BYPASS_BONDING=="FALSE")    ? 1'b1 : 1'b0;
assign rxlane_mult_en           = (CH_MULT_LANE_MODE==2 || CH_MULT_LANE_MODE==4) ? 1'b1 : 1'b0;
assign expll_lock_rx            = (PCS_RX_CLK_EXPLL_USE=="FALSE") ? 1'b1 : i_pll_lock_rx;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        i_rx_rate_chng_ff     <= 2'b00;
    else 
        i_rx_rate_chng_ff     <= {i_rx_rate_chng_ff[0],i_rx_rate_chng};
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        i_rxckdiv_ff     <= 3'b000;
    else 
        i_rxckdiv_ff     <= i_rxckdiv;
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        i_rx_rate_chng_posedge     <= 1'b0;
    else if (rxlane_rst_fsm == RX_CKDIV_ONLY)
        i_rx_rate_chng_posedge     <= 1'b0;
    else if (i_rx_rate_chng_ff[0] & (!i_rx_rate_chng_ff[1]))
        i_rx_rate_chng_posedge     <= 1'b1;
    else ;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rxckdiv                  <= 3'b000;
    else if (!i_rx_rate_chng_posedge && i_rx_rate_chng_ff[0] && (!i_rx_rate_chng_ff[1]) && rxlane_rst_fsm != RX_CKDIV_ONLY)
        rxckdiv                  <= i_rxckdiv_ff;
    else ;
end
 

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rxlane_rst_fsm     <=   RX_LANE_IDLE   ;
    end
    else begin
        rxlane_rst_fsm     <=   next_state ;
    end
end

always @(*)
begin
    case(rxlane_rst_fsm)
        RX_LANE_IDLE        :
            next_state     =   RX_LANE_RXPD ;
        RX_LANE_RXPD        :
        begin
            if(cntr0 == RX_PD_CNTR_VALUE)
                next_state = RX_LANE_PMA_RST ;
            else
                next_state = RX_LANE_RXPD ;
        end
        RX_LANE_PMA_RST     :
        begin
            if(cntr1 == RX_PMA_CNTR_VALUE)
                next_state = RX_LANE_SIGNAL_WAIT ;
            else
                next_state = RX_LANE_PMA_RST ;
        end
        RX_LANE_SIGNAL_WAIT :
        begin
            if(i_rx_rate_chng_posedge)
                next_state = RX_CKDIV_ONLY ;
            else if (sigdet)
                next_state = RX_LANE_CDR_WAIT ;
            else
                next_state = RX_LANE_SIGNAL_WAIT ;
        end
        RX_LANE_CDR_WAIT    :
        begin
            if(!sigdet || cntr2 == RX_CDR_WAIT_CNTR_VALUE)
                next_state = RX_LANE_PMA_RST ;
            else if (i_rx_rate_chng_posedge)
                next_state = RX_CKDIV_ONLY ;
            else if (cdr_align && expll_lock_rx )
                next_state = RX_LANE_PCS_RST ;
            else
                next_state = RX_LANE_CDR_WAIT ;
        end
        RX_LANE_PCS_RST     :
        begin
            if(!sigdet || !cdr_align)
                next_state = RX_LANE_PMA_RST ;
            else if (i_rx_rate_chng_posedge)
                next_state = RX_CKDIV_ONLY ;
            else if (cntr3 == RX_PCS_CNTR_VALUE )
                if (rxlane_word_align_en)
                    next_state = RX_LANE_ALIGN_WAIT ;
                else
                    next_state = RX_LANE_DONE ;
            else
                next_state = RX_LANE_PCS_RST ;
        end
        RX_LANE_ALIGN_WAIT  :
        begin
            if(!sigdet || !cdr_align)
                next_state = RX_LANE_PMA_RST ;
            else if (i_rx_rate_chng_posedge)
                next_state = RX_CKDIV_ONLY ;
            else if (!word_align)
                    if(cntr6 == CH_RXPCS_ALIGN_TIMER)
                        next_state = RX_LANE_PMA_RST ;
                    else
                        next_state = RX_LANE_ALIGN_WAIT ;
            else
                next_state = RX_LANE_BONDING_WAIT ;
        end
        RX_LANE_BONDING_WAIT:
        begin
            if(!sigdet || !cdr_align)
                next_state = RX_LANE_PMA_RST ;
            else if (i_rx_rate_chng_posedge)
                next_state = RX_CKDIV_ONLY ;
            else if (i_pcs_cb_rst && rxlane_bonding_en)
                next_state = RX_LANE_CB_RST  ;
            else if (bonding || !rxlane_bonding_en)
                next_state = RX_LANE_DONE ;
            else
                next_state = RX_LANE_BONDING_WAIT ;
        end
        RX_LANE_DONE        :
        begin
            if(!sigdet || !cdr_align)
                next_state = RX_LANE_PMA_RST ;
            else if (i_rx_rate_chng_posedge)
                next_state = RX_CKDIV_ONLY ;
            else if (fifo_clr_en && rxlane_mult_en)
                next_state = RX_LANE_PCS_RST ;
            else if (i_pcs_cb_rst)
                next_state = RX_LANE_CB_RST  ;
            else
                next_state = RX_LANE_DONE ;
        end
        RX_LANE_CB_RST      :
        begin
            if(!sigdet || !cdr_align)
                next_state = RX_LANE_PMA_RST ;
            else if (i_rx_rate_chng_posedge)
                next_state = RX_CKDIV_ONLY ;
            else if(!i_pcs_cb_rst)
                next_state = RX_LANE_BONDING_WAIT ;
            else
                next_state = RX_LANE_CB_RST ;
        end
        RX_CKDIV_ONLY       :
        begin
            if(cntr5 == RX_RATE_CHANGE_PMA_F_CNTR_VALUE)
                next_state = RX_LANE_SIGNAL_WAIT ;
            else
                next_state = RX_CKDIV_ONLY ;
        end
        default             :
        begin
            next_state     = RX_LANE_IDLE  ;
        end
    endcase
end

always @(posedge clk or negedge rst_n) 
begin
    if(!rst_n) 
    begin
        cntr0                   <= {CNTR_WIDTH0{1'b0}};
        cntr1                   <= {CNTR_WIDTH1{1'b0}};
        cntr2                   <= {CNTR_WIDTH2{1'b0}};
        cntr3                   <= {CNTR_WIDTH3{1'b0}};
        cntr4                   <= {CNTR_WIDTH4{1'b0}};
        cntr5                   <= {CNTR_WIDTH5{1'b0}};
        cntr6                   <= {CNTR_WIDTH6{1'b0}};
        P_RX_LANE_PD            <= 1'b1;
        P_RX_PMA_RST            <= 1'b1;
        P_PCS_RX_RST            <= 1'b1;
        P_RX_RATE               <= LX_RX_CKDIV;
        o_rxckdiv_done          <= 1'b0;       
        o_rxlane_done           <= 1'b0;
        fifoclr_sig             <= 1'b0 ;
    end
    else 
    begin
        case (rxlane_rst_fsm)
            RX_LANE_IDLE        :   
            begin
                cntr0                   <= {CNTR_WIDTH0{1'b0}};
                cntr1                   <= {CNTR_WIDTH1{1'b0}};
                cntr2                   <= {CNTR_WIDTH2{1'b0}};
                cntr3                   <= {CNTR_WIDTH3{1'b0}};
                cntr4                   <= {CNTR_WIDTH4{1'b0}};
                cntr5                   <= {CNTR_WIDTH5{1'b0}};
                cntr6                   <= {CNTR_WIDTH6{1'b0}};
                P_RX_LANE_PD            <= 1'b1;
                P_RX_PMA_RST            <= 1'b1;
                P_PCS_RX_RST            <= 1'b1;
                P_RX_RATE               <= LX_RX_CKDIV;
                o_rxckdiv_done          <= 1'b0;       
                o_rxlane_done           <= 1'b0;
                fifoclr_sig             <= 1'b0;
            end
            RX_LANE_RXPD        :   
            begin
                if(cntr0 == RX_PD_CNTR_VALUE)
                begin
                    cntr0                   <= {CNTR_WIDTH0{1'b0}} ;
                    P_RX_LANE_PD            <= 1'b0 ;            
                end
                else
                begin
                    cntr0                    <= cntr0 + {{CNTR_WIDTH0-1{1'b0}},{1'b1}} ;
                end
            end
            RX_LANE_PMA_RST     :
            begin
                if(cntr1 == RX_PMA_CNTR_VALUE)
                begin
                    cntr1                   <= {CNTR_WIDTH1{1'b0}} ;
                    P_RX_PMA_RST            <= 1'b0 ;
                end
                else
                begin
                    cntr1                    <= cntr1 + {{CNTR_WIDTH1-1{1'b0}},{1'b1}} ;
                    P_RX_PMA_RST            <= 1'b1 ;
                    P_PCS_RX_RST            <= 1'b1 ;
                    o_rxlane_done           <= 1'b0 ;
                    fifoclr_sig             <= 1'b0 ;
                end
            end
            RX_LANE_SIGNAL_WAIT :
            begin
                fifoclr_sig             <= 1'b0 ;
            end
            RX_LANE_CDR_WAIT    :
            begin
                if(!sigdet || cntr2 == RX_CDR_WAIT_CNTR_VALUE || i_rx_rate_chng_posedge || (cdr_align && expll_lock_rx))
                begin
                    cntr2                   <= {CNTR_WIDTH2{1'b0}} ;
                end
                else
                begin
                    cntr2                    <= cntr2 + {{CNTR_WIDTH2-1{1'b0}},{1'b1}} ;
                end
            end
            RX_LANE_PCS_RST     :
            begin
                if(!sigdet || !cdr_align || i_rx_rate_chng_posedge || cntr3 == RX_PCS_CNTR_VALUE)
                begin
                    cntr3                   <= {CNTR_WIDTH3{1'b0}} ;
                end
                else if (cntr3 >= RX_PCS_CNTR_VALUE - 1)
                begin
                    P_PCS_RX_RST            <= 1'b0 ;
                    cntr3                    <= cntr3 + {{CNTR_WIDTH3-1{1'b0}},{1'b1}} ;
                end
                else
                begin
                    cntr3                    <= cntr3 + {{CNTR_WIDTH3-1{1'b0}},{1'b1}} ;
                    P_PCS_RX_RST            <= 1'b1 ;
                    o_rxlane_done           <= 1'b0 ;
                end
            end
            RX_LANE_ALIGN_WAIT  :
            begin
                if(word_align || cntr6 == CH_RXPCS_ALIGN_TIMER)
                begin
                    cntr6                   <= {CNTR_WIDTH6{1'b0}} ;    
                end
                else
                begin
                    cntr6                   <= cntr6  + {{CNTR_WIDTH6-1{1'b0}},{1'b1}} ;
                end
            end
            RX_LANE_BONDING_WAIT  :
            begin
            end
            RX_LANE_DONE        :
            begin
                if(!sigdet || !cdr_align || i_rx_rate_chng_posedge || (fifo_clr_en && rxlane_mult_en) || i_pcs_cb_rst)    begin
                    cntr4                   <= {CNTR_WIDTH4{1'b0}} ;
                end
                else if(cntr4 == RX_RST_DONE_DLY_CNTR_VALUE)    begin
                    o_rxlane_done           <= 1'b1 ;
                end
                else    begin
                    cntr4                    <= cntr4 + {{CNTR_WIDTH4-1{1'b0}},{1'b1}} ;
                    fifoclr_sig             <= 1'b1 ;
                end
            end
            RX_LANE_CB_RST      :
            begin
                o_rxlane_done           <= 1'b0 ;
            end
            RX_CKDIV_ONLY       :
            begin
                if(cntr5 == RX_RATE_CHANGE_PMA_F_CNTR_VALUE)
                begin
                    cntr5                   <= {CNTR_WIDTH5{1'b0}} ;
                    P_RX_PMA_RST            <= 1'b0 ;
                    o_rxckdiv_done          <= 1'b1 ;
                end
                else
                begin
                    o_rxlane_done           <= 1'b0 ;
                    o_rxckdiv_done          <= 1'b0 ;
                    P_PCS_RX_RST            <= 1'b1 ;
                    P_RX_PMA_RST            <= 1'b1 ;
                    cntr5                    <= cntr5 + {{CNTR_WIDTH5-1{1'b0}},{1'b1}} ;
                    if(cntr5 == RX_RATE_CHANGE_PMA_R_CNTR_VALUE)
                        P_RX_RATE           <= rxckdiv ;
                    else ;
                end
            end
            default             :
            begin
                cntr0                   <= {CNTR_WIDTH0{1'b0}} ;
                cntr1                   <= {CNTR_WIDTH1{1'b0}} ;
                cntr2                   <= {CNTR_WIDTH2{1'b0}} ;
                cntr3                   <= {CNTR_WIDTH3{1'b0}} ;
                cntr4                   <= {CNTR_WIDTH4{1'b0}} ;
                cntr5                   <= {CNTR_WIDTH5{1'b0}} ;
                cntr6                   <= {CNTR_WIDTH6{1'b0}} ;
                P_RX_LANE_PD            <= 1'b1;
                P_RX_PMA_RST            <= 1'b1;
                P_PCS_RX_RST            <= 1'b1;
                P_RX_RATE               <= LX_RX_CKDIV;
                o_rxckdiv_done          <= 1'b0;       
                o_rxlane_done           <= 1'b0;
                fifoclr_sig             <= 1'b0;
            end
        endcase
    end
end

assign P_PCS_CB_RST = i_pcs_cb_rst ;

function integer log2 (input integer x);
    integer i;
    begin
        i = 1;
        while (2**i < x)
        begin
            i = i + 1;
        end
        log2 = i;
    end
endfunction

endmodule
