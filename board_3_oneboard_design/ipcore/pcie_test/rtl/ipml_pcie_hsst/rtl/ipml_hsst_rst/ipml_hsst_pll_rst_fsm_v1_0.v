///////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
////////////////////////////////////////////////////////////////////////////////
//
// Library:
// Filename:
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module  ipml_hsst_pll_rst_fsm_v1_0#(
    parameter FREE_CLOCK_FREQ   = 100  //unit is MHz, free clock  freq from GUI
)(
    // Reset and Clock
    input  wire                   clk           ,
    input  wire                   rst_n         ,
    // HSST Reset Control Signal
    input  wire                   pll_lock    ,
    output reg                    P_PLLPOWERDOWN,
    output reg                    P_PLL_RST    ,
    output reg                    o_pll_done   
);

localparam         CNTR_WIDTH                = 14;
`ifdef IPML_HSST_SPEEDUP_SIM
localparam integer PLL_PD_CNTR_VALUE         = 2*(1*FREE_CLOCK_FREQ);//add 50 percent margin
localparam integer PLL_RST_F_CNTR_VALUE      = 2*(2*FREE_CLOCK_FREQ);//add 50 percent margin
`else
localparam integer PLL_PD_CNTR_VALUE         = 2*(40*FREE_CLOCK_FREQ);//add 50 percent margin
localparam integer PLL_RST_F_CNTR_VALUE      = 2*(41*FREE_CLOCK_FREQ);//add 50 percent margin
`endif


localparam PLL_IDLE = 2'd0;
localparam PLL_RST  = 2'd1;
localparam PLL_DONE = 2'd2;

//****************************************************************************//
//                      Internal Signal                                       //
//****************************************************************************//
reg     [CNTR_WIDTH-1 : 0] cntr       ;
reg     [1            : 0] pll_fsm    ;
reg     [1            : 0] next_state ;
//****************************************************************************//
//                      Sequential and Logic                                  //
//****************************************************************************//
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pll_fsm     <=   PLL_IDLE   ;
    end
    else begin
        pll_fsm     <=   next_state ;
    end
end

always @ (*) begin
    case(pll_fsm)
        PLL_IDLE    :    begin
            next_state  =  PLL_RST  ;
        end
        PLL_RST     :    begin
            if((cntr ==  PLL_RST_F_CNTR_VALUE) && pll_lock )   begin
                next_state  =  PLL_DONE  ;
            end
            else begin
                next_state  =  PLL_RST   ;
            end
        end
        PLL_DONE    :    begin
            next_state    =    PLL_DONE  ;
        end
        default    :    begin
            next_state    =    PLL_IDLE  ;
        end
    endcase
end
 
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cntr              <=   {CNTR_WIDTH{1'b0}} ;
        P_PLLPOWERDOWN    <=   1'b1               ;
        P_PLL_RST         <=   1'b1               ;
        o_pll_done        <=   1'b0               ;
    end
    else  begin
        case(pll_fsm)
            PLL_IDLE    :    begin
                P_PLLPOWERDOWN    <=   1'b1               ;
                P_PLL_RST         <=   1'b1               ;
                o_pll_done        <=   1'b0               ;
            end
            PLL_RST     :    begin
                if(cntr == PLL_RST_F_CNTR_VALUE) begin
                    P_PLL_RST             <=   1'b0                  ;
                    if(pll_lock)    begin
                        cntr              <=   {CNTR_WIDTH{1'b0}}    ;
                    end
                end
                else    begin
                    cntr              <=   cntr + {{CNTR_WIDTH-1{1'b0}},{1'b1}} ;
                    if(cntr == PLL_PD_CNTR_VALUE)  begin
                        P_PLLPOWERDOWN    <=   1'b0               ;
                    end
                end
            end
            PLL_DONE    :    begin
                o_pll_done        <=   1'b1                  ;
            end
            default    :    begin
                cntr              <=   {CNTR_WIDTH{1'b0}} ;
                P_PLLPOWERDOWN    <=   1'b1               ;
                P_PLL_RST         <=   1'b1               ;
                o_pll_done        <=   1'b0               ;
            end
        endcase
    end
end

endmodule
