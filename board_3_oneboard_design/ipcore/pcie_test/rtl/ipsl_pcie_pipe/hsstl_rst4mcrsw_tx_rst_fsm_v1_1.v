//******************************************************************
// Copyright (c) 2015 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
`timescale 1ns/1ps
module hsstl_rst4mcrsw_tx_rst_fsm_v1_1(
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire                        pll_rst_n,

    input   wire                        pll_ready,

    input   wire                        clk_remove,
    input   wire                        rate,

    output  reg     [3:0]               hsst_fsm,

    output  reg                         P_PMA_LANE_PD,   //for each lane
    output  reg                         P_PMA_LANE_RST,  //for each lane  
    output  reg                         P_HSST_RST,
    output  reg                         P_PLLPOWERDOWN,
    output  reg                         P_PLL_RST,

    output  reg                         P_PMA_TX_PD,
    output  reg                         P_PMA_TX_RST,   
           
    output  reg                         P_RATE_CHG_TXPCLK_ON,
    output  reg                         P_LANE_SYNC_EN,    
    output  reg                         P_LANE_SYNC,
    output  reg     [2:0]               P_PMA_TX_RATE,
    output  reg                         P_PCS_TX_RST,
    output  reg                         P_TX_PD_CLKPATH,
    output  reg                         P_TX_PD_PISO,
    output  reg                         P_TX_PD_DRIVER, 
    output  reg                         tx_rst_done
);

localparam CNTR_WIDTH                    = 12 ;

localparam PLL_PWRDONE_CNTR_VALUE        = 4*1023;
localparam PLL_RST_CNTR_VALUE            = 4*256;
localparam PMA_TX_RST_CNTR_VALUE          = 64;
localparam BONDING_RST_RELEASE_VALUE     = 128;
localparam BONDING_SYNC_EN_POS_VALUE     = BONDING_RST_RELEASE_VALUE + 64;
localparam BONDING_SYNC_POS_VALUE        = BONDING_SYNC_EN_POS_VALUE + 64;
localparam BONDING_SYNC_NEG_VALUE        = BONDING_SYNC_POS_VALUE + 16;
localparam BONDING_SYNC_EN_NEG_VALUE     = BONDING_SYNC_NEG_VALUE + 64;

localparam TX_PCS_RST_CNTR_VALUE         = 16;

localparam RATE_SYNC_EN_POS_VALUE        = 0;
localparam RATE_RCHANGE_NEG_VALUE        = RATE_SYNC_EN_POS_VALUE + 56;
localparam RATE_RST_POS_VALUE            = RATE_RCHANGE_NEG_VALUE + 30;
localparam RATE_UPPDATE_RATE_CNT_VALUE   = RATE_RST_POS_VALUE + 8;
localparam RATE_SYNC_NEG_VALUE           = RATE_UPPDATE_RATE_CNT_VALUE + 8;
localparam RATE_RST_NEG_VALUE            = RATE_SYNC_NEG_VALUE + 8;
localparam RATE_RCHANGE_POS_VALUE        = RATE_RST_NEG_VALUE + 30;
localparam RATE_SYNC_EN_NEG_VALUE        = RATE_RCHANGE_POS_VALUE + 48;





localparam HSST_IDLE         = 4'd0;
localparam PMA_PD_UP         = 4'd1;
localparam PMA_PLL_RST       = 4'd2;
localparam PMA_PLL_LOCK      = 4'd3;
localparam PMA_TX_RST        = 4'd4;
localparam PMA_BONDING       = 4'd5;
localparam TX_PCS_RST        = 4'd6;
localparam TX_RST_DONE       = 4'd7;
localparam TX_RATE_ONLY      = 4'd8;

reg     [CNTR_WIDTH-1 : 0] cntr;
reg     [1:0]              rate_ff;
reg                        rate_chng;

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        rate_ff       <= 2'd0;
        rate_chng     <= 1'b0;
    end
    else
    begin
        rate_ff[0]     <= rate;
        rate_ff[1]     <= rate_ff[0];
        rate_chng      <= ^rate_ff;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        hsst_fsm                        <= HSST_IDLE;
        cntr                            <= {CNTR_WIDTH{1'b0}};
        P_PMA_LANE_PD                   <= 1'b1;  //powerdown
        P_PMA_LANE_RST                  <= 1'b1;  //in reset  
        P_HSST_RST                      <= 1'b1;  //in reset
        P_PLLPOWERDOWN                  <= 1'b1;
        P_PLL_RST                       <= 1'b1;
        P_PMA_TX_PD                     <= 1'b1;
        P_PMA_TX_RST                    <= 1'b1;
        P_RATE_CHG_TXPCLK_ON            <= 1'b1;
        P_TX_PD_CLKPATH                 <= 1'b1;
        P_TX_PD_DRIVER                  <= 1'b1;
        P_LANE_SYNC                     <= 1'b0;
        P_LANE_SYNC_EN                  <= 1'b0;
        P_PMA_TX_RATE                   <= 3'd2;  //010, half rate
        P_PCS_TX_RST                    <= 1'b1;
        P_TX_PD_PISO                    <= 1'b1;
        tx_rst_done                     <= 1'b0;
    end
    else
    begin
        case (hsst_fsm)
            HSST_IDLE :
            begin
                P_PMA_LANE_PD           <= 1'b1; 
                P_PMA_LANE_RST          <= 1'b1; 
                P_HSST_RST              <= 1'b1;  //reset
                P_PLLPOWERDOWN          <= 1'b1;  //power down
                P_PLL_RST               <= 1'b1;  //reset
                P_PMA_TX_PD             <= 1'b1;
                P_PMA_TX_RST            <= 1'b1; 
                P_RATE_CHG_TXPCLK_ON    <= 1'b1;
                P_LANE_SYNC             <= 1'b0;
                P_LANE_SYNC_EN          <= 1'b0;
                P_PMA_TX_RATE           <= 3'd2;  //010, half rate
                P_PCS_TX_RST            <= 1'b1;  //reset
                tx_rst_done             <= 1'b0;
                if (cntr == PLL_PWRDONE_CNTR_VALUE) begin  //>40us
                   hsst_fsm             <= PMA_PD_UP;
                   cntr                 <= {CNTR_WIDTH{1'b0}};
                end
                else
                   cntr                 <= cntr + {{CNTR_WIDTH-1{1'b0}},1'b1};
            end
            PMA_PD_UP :
            begin
                 P_PLLPOWERDOWN          <= 1'b0;  //power power up
                 if (cntr == PLL_RST_CNTR_VALUE)   //>1us
                    begin
                        hsst_fsm             <= PMA_PLL_RST;
                        cntr                 <= {CNTR_WIDTH{1'b0}};
                    end
                 else
                        cntr                 <= cntr + {{CNTR_WIDTH-1{1'b0}},1'b1};
             end

            PMA_PLL_RST :
            begin
                P_HSST_RST              <= 1'b0;  //release reset
                //----------------------------------------------------
                //default setting for signals
                P_PMA_LANE_PD           <= 1'b1;  
                P_PMA_LANE_RST          <= 1'b1;   
                P_PLL_RST               <= 1'b1;  //reset
                P_PMA_TX_PD             <= 1'b1;
                P_PMA_TX_RST            <= 1'b1; 
                P_RATE_CHG_TXPCLK_ON    <= 1'b1;
                P_LANE_SYNC             <= 1'b0;
                P_LANE_SYNC_EN          <= 1'b0;
                P_PMA_TX_RATE           <= rate ? 3'd3 : 3'd2;
                P_PCS_TX_RST            <= 1'b1;  //reset
                tx_rst_done             <= 1'b0;               
                hsst_fsm                <= PMA_PLL_LOCK;
                        
            end
            PMA_PLL_LOCK :
            begin
                P_PLL_RST               <= 1'b0; //release pll reset
                if (pll_ready)
                    begin 
                        if(cntr == PMA_TX_RST_CNTR_VALUE)
                         begin    
                            hsst_fsm            <= PMA_TX_RST;
                            cntr                <= {CNTR_WIDTH{1'b0}};
                        end
                        else 
                            cntr                 <= cntr + {{CNTR_WIDTH-1{1'b0}},1'b1};                       
                    end
                else
                     hsst_fsm            <= PMA_PLL_LOCK;
         
            end
            PMA_TX_RST:
            begin
                P_TX_PD_CLKPATH <= 1'b0;
                if(cntr == PMA_TX_RST_CNTR_VALUE)
                    begin
                        P_PMA_TX_RST <= 1'b0;
                        cntr         <= cntr + {{CNTR_WIDTH-1{1'b0}},1'b1}; 
                    end
                else if(cntr == PMA_TX_RST_CNTR_VALUE*2)
                    begin
                        P_TX_PD_PISO <= 1'b0;
                        cntr       <= cntr + {{CNTR_WIDTH-1{1'b0}},1'b1}; 
                     end
                else if(cntr == PMA_TX_RST_CNTR_VALUE*3)
                    begin
                        P_TX_PD_DRIVER <= 1'b0;
                        cntr         <= {CNTR_WIDTH{1'b0}};
                        hsst_fsm     <= PMA_BONDING;
                     end
                else
                    begin
                        cntr         <= cntr + {{CNTR_WIDTH-1{1'b0}},1'b1}; 
                        hsst_fsm    <= PMA_TX_RST; 
                    end
            end 
                   
            PMA_BONDING :
            begin
                // releae power down
                P_PMA_LANE_PD           <= 1'b0;
                P_PMA_TX_PD             <= 1'b0;
                if ((~pll_ready) | (~pll_rst_n))
                begin
                    hsst_fsm            <= PMA_PLL_RST;
                    cntr                <= {CNTR_WIDTH{1'b0}};
                end
                else if (cntr == BONDING_SYNC_EN_NEG_VALUE)
                begin
                    hsst_fsm            <= TX_PCS_RST;
                    cntr                <= {CNTR_WIDTH{1'b0}};
                end
                else
                begin
                    cntr                <= cntr + {{CNTR_WIDTH-1{1'b0}},1'b1};
                end

                if (cntr == BONDING_RST_RELEASE_VALUE) begin //>1us
                    P_PMA_LANE_RST <= 1'b0;
                //    P_PMA_TX_RST   <= 1'b0;
                end
                else if (cntr == BONDING_SYNC_EN_POS_VALUE) //>500us
                    P_LANE_SYNC_EN <= 1'b1;
                else if (cntr == BONDING_SYNC_POS_VALUE) //>500us
                    P_LANE_SYNC    <= 1'b1;
                else if (cntr == BONDING_SYNC_NEG_VALUE)
                    P_LANE_SYNC    <= 1'b0;
                else if (cntr == BONDING_SYNC_EN_NEG_VALUE) begin
                    P_LANE_SYNC_EN <= 1'b0;
                end
            end
            TX_PCS_RST :
            begin
                if ((~pll_ready) | (~pll_rst_n))
                begin
                    hsst_fsm            <= PMA_PLL_RST;
                    cntr                <= {CNTR_WIDTH{1'b0}};
                end
                else if (cntr == TX_PCS_RST_CNTR_VALUE)
                begin
                    hsst_fsm            <= TX_RST_DONE;
                    cntr                <= {CNTR_WIDTH{1'b0}};
                end
                else
                    cntr                <= cntr + {{CNTR_WIDTH-1{1'b0}},1'b1};
            end
            TX_RST_DONE :
            begin
                P_PCS_TX_RST    <= 1'b0;
                tx_rst_done     <= 1'b1;
                if (clk_remove)
                    hsst_fsm            <= HSST_IDLE;                
                else if ((~pll_ready) | (~pll_rst_n))
                begin
                    hsst_fsm            <= PMA_PLL_RST;
                    cntr                <= {CNTR_WIDTH{1'b0}};
                end
                else if (rate_chng)
                    hsst_fsm            <= TX_RATE_ONLY;
                else
                    hsst_fsm            <= TX_RST_DONE;
            end
            TX_RATE_ONLY :
            begin
                if ((~pll_ready) | (~pll_rst_n)) begin
                    hsst_fsm            <= PMA_PLL_RST;
                    cntr                <= {CNTR_WIDTH{1'b0}};
                end
                else if (cntr == RATE_SYNC_EN_NEG_VALUE)
                begin
                    hsst_fsm            <= TX_RST_DONE;
                    cntr                <= {CNTR_WIDTH{1'b0}};
                end
                else
                begin
                    cntr                <= cntr + {{CNTR_WIDTH-1{1'b0}},1'b1};
                end
                 
                if (cntr == RATE_SYNC_EN_POS_VALUE) 
                   P_LANE_SYNC_EN <= 1'b1;
                else if (cntr == RATE_RCHANGE_NEG_VALUE) 
                   P_RATE_CHG_TXPCLK_ON <= 1'b0;
                else if (cntr == RATE_RST_POS_VALUE) begin
                   P_PMA_TX_RST <= 1'b1;
                   P_LANE_SYNC  <= 1'b1;
                end
                else if (cntr == RATE_UPPDATE_RATE_CNT_VALUE)
                   P_PMA_TX_RATE <= rate ? 3'd3 : 3'd2;
                else if (cntr == RATE_SYNC_NEG_VALUE)
                   P_LANE_SYNC  <= 1'b0;
                else if (cntr == RATE_RST_NEG_VALUE)
                   P_PMA_TX_RST <= 1'b0;
                else if (cntr == RATE_RCHANGE_POS_VALUE) begin
                    P_PCS_TX_RST    <= 1'b1;                
                    P_RATE_CHG_TXPCLK_ON <= 1'b1;
                end
                else if (cntr == RATE_SYNC_EN_NEG_VALUE)
                   P_LANE_SYNC_EN <= 1'b0;
            end
            default :
            begin
                hsst_fsm                <= HSST_IDLE;
            end
        endcase
    end
end

endmodule
