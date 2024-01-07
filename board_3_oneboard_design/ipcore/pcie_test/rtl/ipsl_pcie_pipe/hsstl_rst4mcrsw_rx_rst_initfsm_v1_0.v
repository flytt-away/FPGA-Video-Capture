//******************************************************************
// Copyright (c) 2015 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
`timescale 1ns/1ps
module hsstl_rst4mcrsw_rx_rst_initfsm_v1_0(
    input   wire                       clk,
    input   wire                       rst_n,

    input   wire                       P_RX_LANE_POWERUP,
    input   wire                       main_rst_align,
    input   wire                       main_pll_loss_rst,

    input   wire                       loss_signal,
    input   wire                       cdr_align,
    input   wire                       word_align,
    input   wire                       cur_rate, //added on 20180927, to fix issue (XA-65) about EIOS data receive during link down
    output  reg     [3:0]              rx_init_fsm,

    output  reg                        P_RX_PMA_RSTN,
    output  reg                        P_RX_PLL_RSTN,
    output  reg                        P_PCS_RX_RSTN,
    output  reg                        P_PCS_CB_RSTN,
    output  reg                        init_done
);


localparam CNTR_WIDTH                        = 17;
localparam INIT_ALIGN_WAIT_TIMR_WIDTH        = 8;
localparam RX_PMA_CNTR_VALUE                 = 150;//1.28us
localparam RX_PLL_CNTR_VALUE                 = 1000;//10us@100Mhz
localparam RX_PCS_CNTR_VALUE                 = 64;
localparam WORD_ALIGN_WAITCNTR_VALUE         = 16*2;
localparam CDR_ALIGN_WAITCNTR_VALUE          = 18*2;
localparam ALOS_WAITCNTR_VALUE               = 20*2;
localparam RX_INIT_START      = 4'd0;
localparam RX_INIT_PMA_RST    = 4'd1;
localparam RX_INIT_LOSS_DOWN  = 4'd2;
localparam RX_INIT_PLL_RST    = 4'd3;
localparam RX_INIT_CDR_LOCK   = 4'd4;
localparam RX_INIT_PCS_RST    = 4'd5;
localparam RX_INIT_WORD_ALIGN = 4'd6;
localparam RX_INIT_ALIGN_WAIT = 4'd7;
localparam RX_INIT_DONE       = 4'd8;
localparam RX_REALIGN_PCS_BOND = 4'd9;

reg     [CNTR_WIDTH-1 : 0]                  init_cntr;
reg     [INIT_ALIGN_WAIT_TIMR_WIDTH-1 : 0]  init_align_wait_timr;
reg                                         init_realign;
reg                                         word_align_d;
wire                                        word_align_pos;
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        word_align_d <= 1'b0;
    else
        word_align_d <= word_align;
end

assign word_align_pos = word_align & ~word_align_d;
        // INIT SM
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        init_cntr              <= {CNTR_WIDTH{1'b0}};
        rx_init_fsm            <= RX_INIT_START;

        P_RX_PMA_RSTN          <= 1'b0;
        P_RX_PLL_RSTN          <= 1'b0;
        P_PCS_RX_RSTN          <= 1'b0;
        P_PCS_CB_RSTN          <= 1'b0;
        init_align_wait_timr   <= {INIT_ALIGN_WAIT_TIMR_WIDTH{1'b0}};
        init_realign           <= 1'b0;
        init_done              <= 1'b0;
    end
    else
    begin
        case (rx_init_fsm)
            RX_INIT_START :
            begin
                init_cntr             <= {CNTR_WIDTH{1'b0}};
                P_RX_PMA_RSTN         <= 1'b0;
                P_RX_PLL_RSTN         <= 1'b0;
                P_PCS_RX_RSTN         <= 1'b0;
                P_PCS_CB_RSTN         <= 1'b0;
                init_realign          <= 1'b0;
                init_done             <= 1'b0;

                if (P_RX_LANE_POWERUP)
                    rx_init_fsm       <= RX_INIT_PMA_RST;
                else
                    rx_init_fsm       <= RX_INIT_START;
            end
            RX_INIT_PMA_RST :
            begin
                P_RX_PMA_RSTN         <= 1'b0;
                P_RX_PLL_RSTN         <= 1'b0;
                P_PCS_RX_RSTN         <= 1'b0;
                P_PCS_CB_RSTN         <= 1'b0;
                init_realign          <= 1'b0;
                init_done             <= 1'b0;

                if (init_cntr == RX_PMA_CNTR_VALUE)
                begin
                    rx_init_fsm       <= RX_INIT_LOSS_DOWN;
                    P_RX_PMA_RSTN     <= 1'b1;
                    init_cntr         <= {CNTR_WIDTH{1'b0}};
                end
                else
                begin
                    rx_init_fsm       <= RX_INIT_PMA_RST;
                    P_RX_PMA_RSTN     <= 1'b0;
                    init_cntr         <= init_cntr + {{CNTR_WIDTH-1{1'b0}}, 1'b1};
                end
            end
            RX_INIT_LOSS_DOWN :
            begin
                P_RX_PLL_RSTN         <= 1'b0;
                P_PCS_RX_RSTN         <= 1'b0;
                init_done             <= 1'b0;
                P_PCS_CB_RSTN         <= 1'b0;

                if (~loss_signal)
                    rx_init_fsm       <= RX_INIT_CDR_LOCK;
                else
                    rx_init_fsm       <= RX_INIT_LOSS_DOWN;
            end

            RX_INIT_CDR_LOCK :
            begin
                if (loss_signal)
                    rx_init_fsm       <= RX_INIT_LOSS_DOWN ;
                else if (cdr_align)
                    rx_init_fsm       <= RX_INIT_PCS_RST;
                else
                    rx_init_fsm       <= RX_INIT_CDR_LOCK;
            end
            RX_INIT_PCS_RST :
            begin
               // P_PCS_RX_RSTN         <= 1'b0;
                init_done             <= 1'b0;
                init_align_wait_timr  <= {INIT_ALIGN_WAIT_TIMR_WIDTH{1'b0}};

                if (loss_signal)
                begin
                    rx_init_fsm       <= RX_INIT_LOSS_DOWN;
                    init_cntr         <= {CNTR_WIDTH{1'b0}};
                end
                else if (~cdr_align)
                begin
                    rx_init_fsm       <= RX_INIT_PLL_RST;
                    init_cntr         <= {CNTR_WIDTH{1'b0}};
                end
                else //if (init_cntr == RX_PCS_CNTR_VALUE)
                begin
                    if (init_realign)
                        rx_init_fsm   <= RX_INIT_WORD_ALIGN;
                    else
                        rx_init_fsm   <= RX_INIT_ALIGN_WAIT;

                    P_PCS_RX_RSTN     <= 1'b1;
                    P_PCS_CB_RSTN     <= 1'b1;
                    init_cntr         <= {CNTR_WIDTH{1'b0}};
                end
                //else
                //begin
                //    rx_init_fsm       <= RX_INIT_PCS_RST;
                //    P_PCS_RX_RSTN     <= 1'b0;
                //    init_cntr         <= init_cntr + {{CNTR_WIDTH-1{1'b0}}, 1'b1};
                //end
            end
            RX_INIT_WORD_ALIGN :
            begin
                init_realign          <= 1'b0;

                if (~cdr_align | loss_signal) 
                    init_align_wait_timr         <= {INIT_ALIGN_WAIT_TIMR_WIDTH{1'b0}};
                else if (&init_align_wait_timr)
                    init_align_wait_timr         <= init_align_wait_timr;
                else
                    init_align_wait_timr         <= init_align_wait_timr + {{INIT_ALIGN_WAIT_TIMR_WIDTH-1{1'b0}}, 1'b1};

                if (loss_signal) 
                    rx_init_fsm       <= RX_INIT_LOSS_DOWN;
                else if (~cdr_align)
                    rx_init_fsm       <= RX_INIT_PLL_RST;
                else if (&init_align_wait_timr & (~word_align))
                begin
                    rx_init_fsm       <= RX_INIT_START;
                    init_done         <= 1'b0;
                end
                else if (word_align)
                begin
                    rx_init_fsm       <= RX_INIT_DONE;
                    init_done         <= 1'b1;
                    init_cntr         <= {CNTR_WIDTH{1'b0}};
                end
                else
                    rx_init_fsm       <= RX_INIT_WORD_ALIGN;
            end
            RX_INIT_ALIGN_WAIT :
            begin
                if (~cdr_align | loss_signal) 
                    init_align_wait_timr         <= {INIT_ALIGN_WAIT_TIMR_WIDTH{1'b0}};
                else if (&init_align_wait_timr)
                    init_align_wait_timr         <= init_align_wait_timr;
                else
                    init_align_wait_timr         <= init_align_wait_timr + {{INIT_ALIGN_WAIT_TIMR_WIDTH-1{1'b0}}, 1'b1};

                if (loss_signal) 
                    rx_init_fsm                  <= RX_INIT_LOSS_DOWN;
                else if (~cdr_align)
                    rx_init_fsm                  <= RX_INIT_PLL_RST;
                else if (&init_align_wait_timr & (~word_align))
                begin
                    rx_init_fsm                  <= RX_INIT_PLL_RST;
                    init_realign                 <= 1'b1;
                    init_done                    <= 1'b0;
                    init_align_wait_timr         <= {INIT_ALIGN_WAIT_TIMR_WIDTH{1'b0}};
                end
                else if (word_align)
                begin
                    rx_init_fsm                  <= RX_INIT_DONE;
                    init_done                    <= 1'b1;
                    init_cntr                    <= {CNTR_WIDTH{1'b0}};
                end
                else
                    rx_init_fsm                  <= RX_INIT_ALIGN_WAIT;
            end
            RX_INIT_DONE :
            begin
            //    init_cntr             <= {CNTR_WIDTH{1'b0}};
            if (~word_align)
                    begin
                         rx_init_fsm       <= RX_INIT_PCS_RST;
                         init_cntr         <= {CNTR_WIDTH{1'b0}};
                    end
           //else if (main_pll_loss_rst)
           //     begin
           //         rx_init_fsm       <= RX_INIT_LOSS_DOWN;
           //         P_RX_PLL_RSTN     <= 1'b0;
           //         P_PCS_RX_RSTN     <= 1'b0;
           //         P_PCS_CB_RSTN      <= 1'b0;
           //         init_done         <= 1'b0;
           //     end
           else if (main_rst_align)
                begin
                    rx_init_fsm       <= RX_REALIGN_PCS_BOND;
                   // P_PCS_RX_RSTN     <= 1'b0;
                    P_PCS_CB_RSTN     <= 1'b0;
                    init_done         <= 1'b0;
                end
                else
                    rx_init_fsm       <= RX_INIT_DONE;
            end
            RX_REALIGN_PCS_BOND :
                begin
                    P_PCS_CB_RSTN         <= 1'b1;
                    if(word_align_pos)
                        begin
                            init_done     <= 1'b1;
                            rx_init_fsm   <= RX_INIT_DONE;
                        end
                    else
                        begin
                           init_done      <= 1'b0;
                           rx_init_fsm    <= RX_REALIGN_PCS_BOND;
                        end
                end
            default:
            begin
                init_cntr             <= {CNTR_WIDTH{1'b0}};
                rx_init_fsm           <= RX_INIT_START;

                P_RX_PMA_RSTN         <= 1'b0;
                P_RX_PLL_RSTN         <= 1'b0;
                P_PCS_RX_RSTN         <= 1'b0;
                P_PCS_CB_RSTN         <= 1'b0;
                init_align_wait_timr  <= {INIT_ALIGN_WAIT_TIMR_WIDTH{1'b0}};
                init_realign          <= 1'b0;
                init_done             <= 1'b0;
            end
        endcase
    end
end

endmodule
