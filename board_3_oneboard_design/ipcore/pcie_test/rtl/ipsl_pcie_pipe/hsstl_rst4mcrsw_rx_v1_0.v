//******************************************************************
// Copyright (c) 2015 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
`timescale 1ns/1ps
module hsstl_rst4mcrsw_rx_v1_0 #(
    parameter LINK_X1_WIDTH  = 0, // 1 = x4
    parameter FORCE_LANE_REV = 0  //1 = Lane Reversal
)(
    input   wire                         clk,
    input   wire                         rst_n,
    input   wire    [3:0]                rxlane_soft_rst_n,

    input   wire                         tx_rst_done,
    input   wire    [1:0]                link_num,
    input   wire                         link_num_flag,

    input   wire                         P_LX_ALOS_STA_0,
    input   wire                         P_LX_ALOS_STA_1,
    input   wire                         P_LX_ALOS_STA_2,
    input   wire                         P_LX_ALOS_STA_3,
    input   wire                         P_LX_CDR_ALIGN_0,
    input   wire                         P_LX_CDR_ALIGN_1,
    input   wire                         P_LX_CDR_ALIGN_2,
    input   wire                         P_LX_CDR_ALIGN_3,
    input   wire    [3:0]                P_PCS_LSM_SYNCED,

    input   wire                         ltssm_in_recovery,
    input   wire                         rate,             // 0 = 2.5GT/s;   1 = 5.0GT/s

    output  wire    [3:0]                rx_main_fsm,
    output  wire    [3:0]                rx_init_fsm0,
    output  wire    [3:0]                rx_init_fsm1,
    output  wire    [3:0]                rx_init_fsm2,
    output  wire    [3:0]                rx_init_fsm3,
    output  wire    [3:0]                s_PCS_LSM_SYNCED,
    output  wire    [3:0]                s_LX_ALOS_STA_deb,
    output  wire    [3:0]                s_LX_CDR_ALIGN_deb,
    output  wire    [3:0]                init_done,

    output  wire    [3:0]                P_PMA_RX_PD,
    output  wire                         P_PMA_RX_RST_0,
    output  wire                         P_PMA_RX_RST_1,
    output  wire                         P_PMA_RX_RST_2,
    output  wire                         P_PMA_RX_RST_3,
    output  wire                         P_PCS_RX_RST_0,
    output  wire                         P_PCS_RX_RST_1,
    output  wire                         P_PCS_RX_RST_2,
    output  wire                         P_PCS_RX_RST_3,
    output  wire    [2:0]                P_LX_RX_RATE_0,
    output  wire    [2:0]                P_LX_RX_RATE_1,
    output  wire    [2:0]                P_LX_RX_RATE_2,
    output  wire    [2:0]                P_LX_RX_RATE_3,
    output  wire    [3:0]                P_PCS_CB_RST,
    output  wire                         rate_done,
    output  wire    [3:0]                hsst_ch_ready
);

localparam LOSS_DEB_RISE_CNTR_WIDTH       = 12;
localparam LOSS_DEB_RISE_CNTR_VALUE       = 4;
localparam CDR_ALIGN_DEB_RISE_CNTR_WIDTH  = 12;
localparam CDR_ALIGN_DEB_RISE_CNTR_VALUE  = 2048;
localparam WORD_ALIGN_DEB_RISE_CNTR_WIDTH = 11;
localparam WORD_ALIGN_DEB_RISE_CNTR_VALUE = 1024;

wire             [3:0]     P_LX_ALOS_STA          ;
wire             [3:0]     P_LX_CDR_ALIGN         ;
wire             [3:0]     s_LX_ALOS_STA          ;
wire             [3:0]     s_LX_CDR_ALIGN         ;

wire                       main_rst_align         ;
wire                       rx_rate_change_rst     ;
wire             [3:0]     rx_init_fsm_buf [3:0]  ;

wire                       P_PMA_RX_PD_m          ;
wire             [3:0]     P_PMA_RX_RST           ;
wire             [3:0]     P_PCS_RX_RST           ;
wire             [2:0]     P_LX_RX_RATE           ;

reg              [1:0]     link_num_synced        ;
reg              link_num_flag_synced_d;
wire             [3:0]     main_done              ;
wire             main_pll_loss_rst;
wire P_RX_LANE_POWERUP;
wire [3:0] P_RX_PMA_RSTN    ;
wire [3:0] P_PCS_RX_RSTN    ;
wire [3:0] P_PCS_CB_RSTN    ;
wire [1:0] P_LX_RX_CKDIV;
wire [3:0] P_PCS_CB_RST_I;
wire P_LX_RX_CKDIV_DYNSEL;
wire cur_rate;
// Link Number sync
ipsl_pcie_sync_v1_0 link_num_sync  (.clk(clk), .rst_n(rst_n), .sig_async(link_num_flag), .sig_synced(link_num_flag_synced));

always @(posedge clk or negedge rst_n)
   if (!rst_n) begin
      link_num_flag_synced_d <= 1'b0;
      link_num_synced        <= 2'd0;
   end
   else begin
      link_num_flag_synced_d <= link_num_flag_synced;
      if (link_num_flag_synced_d ^ link_num_flag_synced)
          link_num_synced  <= link_num;      
   end

// Lane Reversal
assign P_LX_ALOS_STA      = {P_LX_ALOS_STA_3,  P_LX_ALOS_STA_2,  P_LX_ALOS_STA_1,  P_LX_ALOS_STA_0};
assign P_LX_CDR_ALIGN     = {P_LX_CDR_ALIGN_3, P_LX_CDR_ALIGN_2, P_LX_CDR_ALIGN_1, P_LX_CDR_ALIGN_0};

// Initial part
assign rx_init_fsm0 = rx_init_fsm_buf[0];
assign rx_init_fsm1 = rx_init_fsm_buf[1];
assign rx_init_fsm2 = rx_init_fsm_buf[2];
assign rx_init_fsm3 = rx_init_fsm_buf[3];

generate
genvar i;
for(i=0;i<4;i=i+1)begin
    hsstl_rst4mcrsw_rx_init_v1_0 hsst_rst4mcrsw_rx_init(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .rxlane_soft_rst_n      (rxlane_soft_rst_n[i]   ),

    .ltssm_in_recovery      (ltssm_in_recovery      ),

    .P_LX_ALOS_STA          (P_LX_ALOS_STA[i]       ),
    .P_LX_CDR_ALIGN         (P_LX_CDR_ALIGN[i]      ),
    .P_PCS_LSM_SYNCED       (P_PCS_LSM_SYNCED[i]    ),

    .main_rst_align         (main_rst_align         ),
    .main_pll_loss_rst      (main_pll_loss_rst      ),
    .cur_rate               (cur_rate),
    .rx_init_fsm            (rx_init_fsm_buf[i]     ),
    .s_LX_ALOS_STA          (s_LX_ALOS_STA[i]       ),
    .s_LX_CDR_ALIGN         (s_LX_CDR_ALIGN[i]      ),
    .s_PCS_LSM_SYNCED       (s_PCS_LSM_SYNCED[i]    ),
    .s_LX_ALOS_STA_deb      (s_LX_ALOS_STA_deb[i]   ),
    .s_LX_CDR_ALIGN_deb     (s_LX_CDR_ALIGN_deb[i]  ),

//    .P_PMA_RX_PD            (P_PMA_RX_PD_m          ),
//    .P_PMA_RX_RST           (P_PMA_RX_RST[i]        ),
    .P_RX_PLL_RSTN          (), //NC
//    .P_PCS_RX_RST           (P_PCS_RX_RST[i]        ),

    .P_RX_LANE_POWERUP      (P_RX_LANE_POWERUP      ),
    .P_RX_PMA_RSTN          (P_RX_PMA_RSTN[i]       ),
    .P_PCS_RX_RSTN          (P_PCS_RX_RSTN[i]       ),
    .P_PCS_CB_RSTN          (P_PCS_CB_RSTN[i]       ),
    .init_done              (init_done[i]           )
    );
end

endgenerate

assign P_PMA_RX_PD_m = ~P_RX_LANE_POWERUP;
assign P_PMA_RX_RST  = ~P_RX_PMA_RSTN | {4{P_LX_RX_CKDIV_DYNSEL}};
assign P_PCS_RX_RST  = ~P_PCS_RX_RSTN;
assign P_PCS_CB_RST_I  = ~P_PCS_CB_RSTN;
// Main part
hsstl_rst4mcrsw_rx_rst_fsm_v1_0 #(
    .FORCE_LANE_REV         (FORCE_LANE_REV         )
)rx_rst_fsm_multi_sw_lane(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .tx_rst_done            (tx_rst_done            ),
//    .link_num               (link_num_synced        ),
    .ltssm_in_recovery      (ltssm_in_recovery      ),
    .rate                   (rate                   ),
    .init_done              (init_done              ),
    .rx_main_fsm            (rx_main_fsm            ),
    .main_rst_align         (main_rst_align         ),
    .main_pll_loss_rst      (main_pll_loss_rst      ),
    .loss_of_signal         (s_LX_ALOS_STA),
//    .P_PMA_RX_PD            (P_PMA_RX_PD_m          ),
//    .P_LX_RX_RATE           (P_LX_RX_RATE           ),
    .P_RX_LANE_POWERUP      (P_RX_LANE_POWERUP      ),
    .P_LX_RX_CKDIV          (P_LX_RX_CKDIV          ),
    .P_LX_RX_CKDIV_DYNSEL   (P_LX_RX_CKDIV_DYNSEL), //NC
    .rate_done              (rate_done              ),
    .main_done              (main_done              )
); 

assign P_LX_RX_RATE = (P_LX_RX_CKDIV == 2'd0) ? 3'd3 : 3'd2;

assign cur_rate = (P_LX_RX_CKDIV == 2'd0);

wire [3:0] mask_bits = (link_num_synced == 1) ? 4'b1110 : ((link_num_synced == 2) ? 4'b1100 : 4'b0000);

assign P_PMA_RX_PD     = {4{P_PMA_RX_PD_m}} | mask_bits;

assign P_PMA_RX_RST_0  =  P_PMA_RX_RST[0];
assign P_PMA_RX_RST_1  =  P_PMA_RX_RST[1];
assign P_PMA_RX_RST_2  =  P_PMA_RX_RST[2] ;
assign P_PMA_RX_RST_3  =  P_PMA_RX_RST[3]; 

assign P_PCS_RX_RST_0  = ((|main_done) | (|s_LX_CDR_ALIGN[3:1] & s_LX_ALOS_STA[0]))   ? &P_PCS_RX_RST :P_PCS_RX_RST[0];
assign P_PCS_RX_RST_1  = ((|main_done) | (|s_LX_CDR_ALIGN[3:2] & s_LX_ALOS_STA[1]))  ? &P_PCS_RX_RST[3:1] : P_PCS_RX_RST[1];
assign P_PCS_RX_RST_2  = ((|main_done) | (|s_LX_CDR_ALIGN[3] & s_LX_ALOS_STA[2]))? &P_PCS_RX_RST[3:2] : P_PCS_RX_RST[2] ;
assign P_PCS_RX_RST_3  = P_PCS_RX_RST[3];

assign  P_PCS_CB_RST[0]  = ((|main_done) | (|s_LX_CDR_ALIGN[3:1] & s_LX_ALOS_STA[0]))   ? &P_PCS_CB_RST_I :P_PCS_CB_RST_I[0];
assign  P_PCS_CB_RST[1] = ((|main_done) | (|s_LX_CDR_ALIGN[3:2] & s_LX_ALOS_STA[1]))  ? &P_PCS_CB_RST_I[3:1] : P_PCS_CB_RST_I[1];
assign  P_PCS_CB_RST[2] = ((|main_done) | (|s_LX_CDR_ALIGN[3] & s_LX_ALOS_STA[2]))? &P_PCS_CB_RST_I[3:2] : P_PCS_CB_RST_I[2] ;
assign  P_PCS_CB_RST[3] = P_PCS_CB_RST_I[3];

assign P_LX_RX_RATE_0   = P_LX_RX_RATE;
assign P_LX_RX_RATE_1   = P_LX_RX_RATE;
assign P_LX_RX_RATE_2   = P_LX_RX_RATE;
assign P_LX_RX_RATE_3   = P_LX_RX_RATE;

assign hsst_ch_ready =  main_done ;
endmodule
