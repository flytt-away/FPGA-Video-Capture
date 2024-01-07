//******************************************************************
// Copyright (c) 2015 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
`timescale 1ns/1ps
module hsstl_rst4mcrsw_rx_rst_fsm_v1_0 #(
    parameter FORCE_LANE_REV = 0  //1 = Lane Reversal

)(
    input   wire                       clk,
    input   wire                       rst_n,
    input   wire    [3:0]              loss_of_signal,
    input   wire                       tx_rst_done,

    input   wire                       ltssm_in_recovery,
    input   wire                       rate,
    input   wire    [3:0]              init_done,

    output  reg     [3:0]              rx_main_fsm,
    output  reg                        main_rst_align,
    output  reg                        main_pll_loss_rst,

    output  reg                        P_RX_LANE_POWERUP,
    output  reg                        P_LX_RX_CKDIV_DYNSEL,
    output  reg     [1:0]              P_LX_RX_CKDIV,

    output  reg                        rate_done,
    output  reg     [3:0]              main_done
);

localparam PMA_RX_PD_CNT_VALUE               = 4095;
localparam CNTR_WIDTH                        = 16;
localparam MAIN_ALIGN_WAIT_TIMR_WIDTH        = 10;
`ifdef IPSL_PCIE_SPEEDUP_SIM
localparam RX_CKDIV_DYNSEL_SW_CNTR_NEG_VALUE = 4*512;
`else
localparam RX_CKDIV_DYNSEL_SW_CNTR_NEG_VALUE = 64*512;
`endif

`ifdef IPSL_PCIE_SPEEDUP_SIM
localparam RX_CKDIV_DYNSEL_SPEED_DONE = 3*512;
`else
localparam RX_CKDIV_DYNSEL_SPEED_DONE = 16*512;
`endif
localparam RX_CKDIV_SW_CNTR_VALUE     = 4*260;

localparam RX_MAIN_IDLE            = 4'd0 ;
localparam RX_MAIN_INIT            = 4'd1 ;
localparam RX_MAIN_INIT_WAIT       = 4'd2 ;
localparam RX_MAIN_ALIGN_RST       = 4'd3 ;
localparam RX_MAIN_ALIGN_WAIT      = 4'd4 ;
localparam RX_MAIN_ALIGN_WAIT2     = 4'd5 ;
localparam RX_MAIN_RST_DONE        = 4'd6 ;
localparam RX_MAIN_RECOVERY        = 4'd7 ;
localparam RX_MAIN_CKDIV           = 4'd8 ;

reg                        rate_chng;
reg     [1:0]              rate_ff;
wire                                            all_lane_rst_done;
wire                                            mstr_init_done;
reg     [CNTR_WIDTH-1 : 0]                      main_cntr;
reg     [MAIN_ALIGN_WAIT_TIMR_WIDTH-1 : 0]      main_align_wait_timr;
reg     rate_done_r;
reg     rate_done_r_d;
wire    [2:0]      active_lane_num ;
assign mstr_init_done = (FORCE_LANE_REV ==1) ? init_done[3] : init_done[0];
assign all_lane_rst_done = &(loss_of_signal | init_done) & ~(&loss_of_signal);
assign active_lane_num =init_done[3] + init_done[2] + init_done[1] + init_done[0];
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        rate_ff          <= 2'd0;
        rate_chng        <= 1'b0;
    end
    else
    begin
        rate_ff[0]         <= rate;
        rate_ff[1]         <= rate_ff[0];
        rate_chng          <= (rate_ff[1] == P_LX_RX_CKDIV[0]) ;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
       rate_done_r_d <= 1'b0;
       rate_done     <= 1'b0;
    end
    else begin
       rate_done_r_d <= rate_done_r;
       rate_done     <= rate_done_r_d | rate_done_r;
    end
end

// MAIN SM
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        main_cntr                 <= {CNTR_WIDTH{1'b0}};
        rx_main_fsm               <= RX_MAIN_IDLE;

        P_RX_LANE_POWERUP         <= 1'b0;
        P_LX_RX_CKDIV_DYNSEL      <= 1'b0;
        P_LX_RX_CKDIV             <= 2'b01;
        rate_done_r               <= 1'b0;
        main_done                 <= 4'd0;
        main_rst_align            <= 1'b0;
        main_pll_loss_rst         <= 1'b0;
        main_align_wait_timr      <= {MAIN_ALIGN_WAIT_TIMR_WIDTH{1'b0}};
    end
    else
    begin
        case (rx_main_fsm)
            RX_MAIN_IDLE :
            begin
                if (tx_rst_done)
                    if(main_cntr == PMA_RX_PD_CNT_VALUE)
                    begin
                        rx_main_fsm               <= RX_MAIN_INIT;
                        main_cntr                 <= {CNTR_WIDTH{1'b0}};
                    end
                    else
                    begin
                        rx_main_fsm               <= RX_MAIN_IDLE;
                        main_cntr                 <= main_cntr + {{CNTR_WIDTH-1{1'b0}}, 1'b1};
                    end
                else
                    rx_main_fsm               <= RX_MAIN_IDLE;

               // main_cntr                     <= {CNTR_WIDTH{1'b0}};
                P_RX_LANE_POWERUP             <= 1'b0;
                P_LX_RX_CKDIV_DYNSEL          <= 1'b0;
                P_LX_RX_CKDIV                 <= rate ? 2'b00: 2'b01 ;
                rate_done_r                   <= 1'b0;
                main_done                     <= 4'd0;
                main_rst_align                <= 1'b0;
                main_pll_loss_rst             <= 1'b0;
                main_align_wait_timr          <= {MAIN_ALIGN_WAIT_TIMR_WIDTH{1'b0}};
            end
            RX_MAIN_INIT :
            begin
                P_RX_LANE_POWERUP             <= 1'b1;
                main_pll_loss_rst             <= 1'b0;
                main_align_wait_timr          <= {MAIN_ALIGN_WAIT_TIMR_WIDTH{1'b0}};
                main_done                     <= 4'd0;
                if(rate_chng )
                    rx_main_fsm                <= RX_MAIN_CKDIV;
                else if (~main_pll_loss_rst & |init_done)
                    rx_main_fsm               <= RX_MAIN_INIT_WAIT;
                else
                    rx_main_fsm               <= RX_MAIN_INIT;
            end
            RX_MAIN_INIT_WAIT :
            begin
                main_done                     <= 4'd0;
                if(rate_chng )
                    rx_main_fsm                <= RX_MAIN_CKDIV;
                else
                begin 
                    if (&main_align_wait_timr)
                        main_align_wait_timr      <= main_align_wait_timr;
                    else
                        main_align_wait_timr      <= main_align_wait_timr + {{MAIN_ALIGN_WAIT_TIMR_WIDTH-1{1'b0}}, 1'b1};
                    
                    if (&main_align_wait_timr | all_lane_rst_done )
                    begin
                        if (active_lane_num[1] | active_lane_num[2] )
                            rx_main_fsm           <= RX_MAIN_ALIGN_RST;
						
                        else if (active_lane_num[0])
                        begin
                            rx_main_fsm           <= RX_MAIN_RST_DONE;
                            main_done             <= (FORCE_LANE_REV == 1) ? 4'h8 : 4'h1;
                        end
                        else
                        begin
                            rx_main_fsm           <= RX_MAIN_INIT;
                            main_done             <= 4'd0;
                        end
                    end
                    else
                        rx_main_fsm               <= RX_MAIN_INIT_WAIT;
                end
            end
            RX_MAIN_ALIGN_RST :
            begin
               if(rate_chng )
                    rx_main_fsm                <= RX_MAIN_CKDIV;
               else
                begin
                    main_rst_align                <= 1'b1;
                    main_align_wait_timr          <= {MAIN_ALIGN_WAIT_TIMR_WIDTH{1'b0}};
                    rx_main_fsm                   <= RX_MAIN_ALIGN_WAIT2;
                end
            end
            RX_MAIN_ALIGN_WAIT2 :
            begin
                main_rst_align                <= 1'b0;
               if(rate_chng )
                    rx_main_fsm                <= RX_MAIN_CKDIV;
               else  if (~main_rst_align & |init_done)
                    rx_main_fsm               <= RX_MAIN_ALIGN_WAIT;
                else
                    rx_main_fsm               <= RX_MAIN_ALIGN_WAIT2;
            end
            RX_MAIN_ALIGN_WAIT :
            begin
                 if(rate_chng )
                    rx_main_fsm                <= RX_MAIN_CKDIV;
                else
                begin
                    if (&main_align_wait_timr[6:0])
                        main_align_wait_timr      <= main_align_wait_timr;
                    else
                        main_align_wait_timr      <= main_align_wait_timr + {{MAIN_ALIGN_WAIT_TIMR_WIDTH-1{1'b0}}, 1'b1};
                    
                    if (&main_align_wait_timr[6:0] | all_lane_rst_done)
                    begin
                        if (active_lane_num[2])
                        begin
                            rx_main_fsm           <= RX_MAIN_RST_DONE;
                            main_done             <= 4'hf;
                        end
                        else if (active_lane_num[1])
                        begin
                            rx_main_fsm           <= RX_MAIN_RST_DONE;
                            main_done             <= 4'h3;
                        end
                        else if (active_lane_num[0])
                        begin
                            rx_main_fsm           <= RX_MAIN_RST_DONE;
                            main_done             <=  4'h1;
                        end
                        else
                        begin
                            rx_main_fsm           <= RX_MAIN_INIT;
                            main_done             <= 4'd0;
                        end
                    end
                    else
                        rx_main_fsm               <= RX_MAIN_ALIGN_WAIT;
               end
            end
            RX_MAIN_RST_DONE :
            begin
                if (ltssm_in_recovery)
                    rx_main_fsm               <= RX_MAIN_RECOVERY;
                else if(rate_chng)
                    rx_main_fsm               <= RX_MAIN_CKDIV;
                else if(&main_done & (active_lane_num[1])) // down cfg linkwidth: x4 -> x2 if lane 3 inactive
                    main_done                 <= 4'h3;
                else if(&main_done[1:0] &  active_lane_num[0] & ~active_lane_num[1] & ~active_lane_num[2]) // down cfg linkwidth: x4 -> x1 or x2 -> x1 if lane 1 inactive
                    main_done                 <= 4'h1;
                else if(((main_done == 4'h1) & (active_lane_num[2] | active_lane_num[1]) ) | ((main_done == 4'h3) & (active_lane_num[2]) )| (init_done == 4'h0)) //up cfg linkwidth : rst pcs
                    rx_main_fsm               <= RX_MAIN_INIT;
                else
                    rx_main_fsm               <= RX_MAIN_RST_DONE;
            end
            RX_MAIN_RECOVERY :
            begin
                if (rate_chng)
                begin
                    rx_main_fsm               <= RX_MAIN_CKDIV;
                    main_cntr                 <= {CNTR_WIDTH{1'b0}};
                end
                else if (~ltssm_in_recovery)
                    rx_main_fsm               <= RX_MAIN_RST_DONE;
               else if(&main_done & (active_lane_num[1])) // down cfg linkwidth: x4 -> x2 if lane 3 inactive
                    main_done                 <= 4'h3;
               else if(&main_done[1:0] &  active_lane_num[0] & ~active_lane_num[1] & ~active_lane_num[2]) // down cfg linkwidth: x4 -> x1 or x2 -> x1 if lane 1 inactive
                    main_done                 <= 4'h1;
               else if(((main_done == 4'h1) & (active_lane_num[2] | active_lane_num[1]) ) | ((main_done == 4'h3) & (active_lane_num[2]) )| (init_done == 4'h0)) //up cfg linkwidth : rst pcs

                      rx_main_fsm               <= RX_MAIN_INIT;
                else
                    rx_main_fsm               <= RX_MAIN_RECOVERY;
            end
            RX_MAIN_CKDIV :
            begin
                main_done                     <= 4'd0;

                if (main_cntr == RX_CKDIV_DYNSEL_SW_CNTR_NEG_VALUE)
                begin
                    main_pll_loss_rst         <= 1'b1;
                    rx_main_fsm               <= RX_MAIN_INIT;
                    main_cntr                 <= {CNTR_WIDTH{1'b0}};
                    P_LX_RX_CKDIV_DYNSEL      <= 1'b0;
                end
                else if (main_cntr == RX_CKDIV_DYNSEL_SPEED_DONE)
                begin
                    rate_done_r               <= 1'b1;
                    rx_main_fsm               <= RX_MAIN_CKDIV;
                    main_cntr                 <= main_cntr + {{CNTR_WIDTH-1{1'b0}}, 1'b1};
                end
                else if (main_cntr == RX_CKDIV_SW_CNTR_VALUE)
                begin
                    rx_main_fsm               <= RX_MAIN_CKDIV;
                    main_cntr                 <= main_cntr + {{CNTR_WIDTH-1{1'b0}}, 1'b1};
                    if (rate)
                        P_LX_RX_CKDIV         <= 2'd0;
                    else
                        P_LX_RX_CKDIV         <= 2'd1;
                end
                else
                begin
                    rate_done_r               <= 1'b0;
                    rx_main_fsm               <= RX_MAIN_CKDIV;
                    main_cntr                 <= main_cntr + {{CNTR_WIDTH-1{1'b0}}, 1'b1};
                    P_LX_RX_CKDIV_DYNSEL      <= 1'b1;
                end
            end
            default :
            begin
                main_cntr                     <= {CNTR_WIDTH{1'b0}};
                rx_main_fsm                   <= RX_MAIN_IDLE;

                P_RX_LANE_POWERUP             <= 1'b0;
                P_LX_RX_CKDIV_DYNSEL          <= 1'b0;
                P_LX_RX_CKDIV                 <= 2'b01;
                main_rst_align                <= 1'b0;
                main_pll_loss_rst             <= 1'b0;
                main_align_wait_timr          <= {MAIN_ALIGN_WAIT_TIMR_WIDTH{1'b0}};
            end
        endcase
    end
end

endmodule
