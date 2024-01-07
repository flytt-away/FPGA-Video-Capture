// Created by IP Generator (Version 2022.1 build 99559)


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

module ipsl_pcie_soft_phy_v1_2a #(
    parameter                   HSST_LANE_NUM        = 4    ,
    parameter                   EN_CONTI_SKP_REPLACE = 1'b0
)(
    input                               button_rst_n                ,
    input                               external_rstn               ,
    input                               phy_rst_n                   ,

    output wire [HSST_LANE_NUM-1:0]     P_TXN                       ,
    output wire [HSST_LANE_NUM-1:0]     P_TXP                       ,
    input       [HSST_LANE_NUM-1:0]     P_RXN                       ,
    input       [HSST_LANE_NUM-1:0]     P_RXP                       ,
    input                               P_REFCKN                    , //ref clock
    input                               P_REFCKP                    , //ref clock
    output wire                         P_REFCK2CORE_0              ,
    input                               free_clk                    ,
    output wire                         pclk                        ,
    output wire                         pclk_div2                   ,
    //apb
    input                               i_p_cfg_psel                ,
    input                               i_p_cfg_enable              ,
    input                               i_p_cfg_write               ,
    input       [15:0]                  i_p_cfg_addr                ,
    input       [7:0]                   i_p_cfg_wdata               ,
    output wire [7:0]                   o_p_cfg_rdata               ,
    output wire                         o_p_cfg_int                 ,
    output wire                         o_p_cfg_ready               ,

    output wire                         tx_rst_done                 ,
    input       [1:0]                   mac_phy_powerdown           ,

    output wire [HSST_LANE_NUM-1:0]     phy_mac_rxelecidle          ,
    output  wire    [3:0]       	phy_mac_phystatus           ,
    output wire [HSST_LANE_NUM*32-1:0]  phy_mac_rxdata              ,
    output wire [HSST_LANE_NUM*4-1:0]   phy_mac_rxdatak             ,
    output wire [HSST_LANE_NUM-1:0]     phy_mac_rxvalid             ,
    output wire [HSST_LANE_NUM*3-1:0]   phy_mac_rxstatus            ,
    //output wire [3:0]                 phy_mac_rxstandbystatus     ,

    input       [HSST_LANE_NUM*32-1:0]  mac_phy_txdata              ,
    input       [HSST_LANE_NUM*4-1:0]   mac_phy_txdatak             ,
    input       [HSST_LANE_NUM-1:0]     mac_phy_txdetectrx_loopback ,
    input       [HSST_LANE_NUM-1:0]     mac_phy_txelecidle_h        ,
    input       [HSST_LANE_NUM-1:0]     mac_phy_txelecidle_l        ,
    input       [HSST_LANE_NUM-1:0]     mac_phy_txcompliance        ,
    input       [HSST_LANE_NUM-1:0]     mac_phy_rxpolarity          ,
    input                               mac_phy_rate                ,
    input       [1:0]                   mac_phy_txdeemph            ,
    input       [2:0]                   mac_phy_txmargin            ,
    input                               mac_phy_txswing             ,

    input       [HSST_LANE_NUM-1:0]     pcs_nearend_loop            ,
    input       [HSST_LANE_NUM-1:0]     pma_nearend_ploop           ,
    input       [HSST_LANE_NUM-1:0]     pma_nearend_sloop           ,

    //output wire [3:0]                     phy_mac_rxdatavalid         ,
    output wire                         phy_clk_req_n               ,
    output reg                          phy_rate_chng_halt
);

wire [HSST_LANE_NUM-1:0]    P_LX_ALOS_STA               ;
wire [HSST_LANE_NUM-1:0]    P_PMA_SIGDET_STATUS         ;
wire                        P_PLL_LOCK                  ;
wire                        P_LX_LFO_0                  ;
wire                        P_LX_LFO_1                  ;
wire                        P_LX_LFO_2                  ;
wire                        P_LX_LFO_3                  ;
wire                        P_LX_RXDCT_OUT_0            ;
wire                        P_LX_RXDCT_OUT_1            ;
wire                        P_LX_RXDCT_OUT_2            ;
wire                        P_LX_RXDCT_OUT_3            ;
wire                        P_HSST_RST                  ;
wire                        P_PLL_RST_0                 ;
wire                        P_PLL_RST_1                 ;
wire                        P_PLLPOWERDOWN_0            ;
wire                        P_PLLPOWERDOWN_1            ;
wire                        PLL_READY_0                 ;
wire                        PLL_READY_1                 ;
wire [3:0]                  P_PMA_LANE_PD               ;
wire [3:0]                  P_PMA_LANE_RST              ;
wire [3:0]                  P_PMA_RX_PD                 ;

wire                        P_PMA_RX_RST_0              ;
wire                        P_PMA_RX_RST_1              ;
wire                        P_PMA_RX_RST_2              ;
wire                        P_PMA_RX_RST_3              ;
wire                        P_PCS_RX_RST_0              ;
wire                        P_PCS_RX_RST_1              ;
wire                        P_PCS_RX_RST_2              ;
wire                        P_PCS_RX_RST_3              ;
wire [3:0]                  P_PCS_CB_RST                ;

wire [2:0]                  P_LX_RX_RATE_0              ;
wire [2:0]                  P_LX_RX_RATE_1              ;
wire [2:0]                  P_LX_RX_RATE_2              ;
wire [2:0]                  P_LX_RX_RATE_3              ;

wire [3:0]                  P_PMA_TX_PD                 ;
wire                        P_PCS_TX_RST_0              ;
wire                        P_PCS_TX_RST_1              ;
wire                        P_PCS_TX_RST_2              ;
wire                        P_PCS_TX_RST_3              ;
wire [46:0]                 P_RDATA_0                   ;
wire [46:0]                 P_RDATA_1                   ;
wire [3:0]                  P_PCS_LSM_SYNCED            ;
wire [46:0]                 P_RDATA_2                   ;
wire [46:0]                 P_RDATA_3                   ;
wire [3:0]                  P_CLK2CORE_TX               ;
wire [3:0]                  P_CLK2CORE_RX               ;
wire [3:0]                  P_PCS_RX_MCB_STATUS         ;
wire [1:0]                  P_LX_DEEMP_CTL_1            ;
wire [3:0]                  P_LX_AMP_CTL_0              ;
wire [3:0]                  P_LX_RXDCT_EN               ;
wire [1:0]                  P_LX_DEEMP_CTL_0            ;
wire [3:0]                  P_LX_AMP_CTL_3              ;
wire [1:0]                  P_LX_DEEMP_CTL_3            ;
wire [3:0]                  P_LX_AMP_CTL_1              ;
wire [HSST_LANE_NUM-1:0]    P_RX_POLARITY_INVERT        ;
wire [1:0]                  P_LX_DEEMP_CTL_2            ;
wire [3:0]                  P_LX_AMP_CTL_2              ;
wire [3:0]                  hsst_ch_ready               ;

wire [43:0]                 txdata_l0                   ;
wire [43:0]                 txdata_l1                   ;
wire [43:0]                 txdata_l2                   ;
wire [43:0]                 txdata_l3                   ;
wire [3:0]                  rx_valid_i                  ;
wire [11:0]                 p_rx_st                     ;
wire                        rx_det_done                 ;
wire                        rate_done                   ;
wire [3:0]                  start_rx_det                ;

wire                        P_LANE_SYNC_EN_0            ;
wire                        P_LANE_SYNC_EN_1            ;
wire                        P_LANE_SYNC_EN_2            ;
wire                        P_LANE_SYNC_EN_3            ;

wire                        P_LANE_SYNC_0               ;
wire                        P_LANE_SYNC_1               ;
wire                        P_RATE_CHG_TXPCLK_ON_0      ;
wire                        P_RATE_CHG_TXPCLK_ON_1      ;
wire [2:0]                  P_PMA_TX_RATE_0             ;
wire [2:0]                  P_PMA_TX_RATE_1             ;
wire [2:0]                  P_PMA_TX_RATE_2             ;
wire [2:0]                  P_PMA_TX_RATE_3             ;
wire                        ref_clk                     ;

reg  [1:0]                  down_cfg                    ;
reg                         down_cfg_flag               ;
reg                         p_rst_n                     ;
reg                         p_rst_d1_n                  ;
reg                         rx_detect_en                ;
reg  [3:0]                  lx_amp_ctl_ff               ;
reg  [1:0]                  lx_deemph                   ;
wire                        rate_change_done            ;
reg  [45:0]                 P_TDATA_0                   ;
reg  [45:0]                 P_TDATA_1                   ;
reg  [45:0]                 P_TDATA_2                   ;
reg  [45:0]                 P_TDATA_3                   ;
wire                        P_PMA_TX_RST_0              ;
wire                        P_PMA_TX_RST_1              ;
wire                        P_PMA_TX_RST_2              ;
wire                        P_PMA_TX_RST_3              ;
reg  [3:0]                  start_rx_det_ff             ;
wire                        P_PLL_READY_0               ;
wire [3:0]                  s_PCS_LSM_SYNCED            ;
wire [3:0]                  s_LX_ALOS_STA_deb           ;
wire [3:0]                  s_LX_CDR_ALIGN_deb          ;
wire [3:0]                  tx_fsm                      ;
wire                        s_P_PLL_LOCK_deb            ;
wire                        pll_lock_wtchdg_rst_n       ;
wire [HSST_LANE_NUM-1:0]    p_alos_sta                  ;
wire [HSST_LANE_NUM-1:0]    p_cdr_align                 ;
wire [3:0]                  alos_sta                    ;
wire [3:0]                  cdr_align                   ;
reg  [3:0]                  lx_rxdct_out_d              ;
wire [HSST_LANE_NUM-1:0]    tx_beacon                   ;

wire [HSST_LANE_NUM-1:0]    loopback_en                 ;
wire [HSST_LANE_NUM*32-1:0] phy_mac_rxdata_w            ;
wire [HSST_LANE_NUM*4-1:0]  phy_mac_rxdatak_w           ;
wire [HSST_LANE_NUM*32-1:0] mac_phy_txdata_w            ;
wire [HSST_LANE_NUM*4-1:0]  mac_phy_txdatak_w           ;
wire [HSST_LANE_NUM-1:0]    mac_phy_txcompliance_w      ;
wire [3:0]                  P_TX_LANE_PD                ;
wire [3:0]                  P_TX_PD_PISO                ;
wire [3:0]                  P_TX_PD_DRIVER              ;
wire [HSST_LANE_NUM-1:0]    P_LX_CDR_ALIGN              ;

wire [3:0]                  TCLK2FABRIC                 ;
wire [3:0]                  RCLK2FABRIC                 ;
wire                        rate_done_s                 ;
reg                         rate_done_s_r1              ;

wire [3:0]                  start_rx_det_pos            ;
reg  [3:0]                  det_cnt                     ;

reg                         rate_r                      ;
wire                        mac_phy_rate_i              ;

// Clock & Reset
assign P_REFCK2CORE_0  = free_clk       ;
assign pclk_div2    = TCLK2FABRIC[0]    ;
assign pclk         = RCLK2FABRIC[0]    ;

assign tx_beacon =  (mac_phy_powerdown == 2'b11) ? ~(mac_phy_txelecidle_h | mac_phy_txelecidle_l) : {HSST_LANE_NUM{1'b0}};

assign phy_mac_rxdatak[(HSST_LANE_NUM*4-1):0] = phy_mac_rxdatak_w[(HSST_LANE_NUM*4-1):0];
assign phy_mac_rxdata[(HSST_LANE_NUM*32-1):0] = phy_mac_rxdata_w[(HSST_LANE_NUM*32-1):0];

generate
genvar k;
for(k=0;k<HSST_LANE_NUM;k=k+1) begin
    assign loopback_en[k] = ( mac_phy_powerdown==2'b0 & mac_phy_txelecidle_h[k] == 1'b0 & mac_phy_txelecidle_l[k] == 1'b0) ? mac_phy_txdetectrx_loopback[k] : 1'b0 ;
    assign mac_phy_txdata_w[k*32+:32]   = loopback_en[k] ? phy_mac_rxdata_w[k*32+:32] : mac_phy_txdata[k*32+:32];
    assign mac_phy_txdatak_w[k*4+:4]    = loopback_en[k] ? phy_mac_rxdatak_w[k*4+:4]  : mac_phy_txdatak[k*4+:4];
end
endgenerate

assign mac_phy_txcompliance_w = (|loopback_en) ? {HSST_LANE_NUM{1'b0}} : mac_phy_txcompliance;

// Tx datapath
generate
    if (HSST_LANE_NUM == 1)
    begin:P_TDATA_X1
        always@(posedge pclk_div2 or negedge phy_rst_n)
        begin
            if(!phy_rst_n)
            begin
                P_TDATA_0 <= {2'b11,44'b0};
                //P_TDATA_1 <= {2'b11,44'b0};
                //P_TDATA_2 <= {2'b11,44'b0};
                //P_TDATA_3 <= {2'b11,44'b0};
            end
            else
            begin
                P_TDATA_0 <= {mac_phy_txelecidle_h[0],mac_phy_txelecidle_l[0],txdata_l0};
                //P_TDATA_1 <= {mac_phy_txelecidle_h[1],mac_phy_txelecidle_l[1],txdata_l1};
                //P_TDATA_2 <= {mac_phy_txelecidle_h[2],mac_phy_txelecidle_l[2],txdata_l2};
                //P_TDATA_3 <= {mac_phy_txelecidle_h[3],mac_phy_txelecidle_l[3],txdata_l3};
            end
        end
    end
    else if(HSST_LANE_NUM == 2)
    begin:P_TDATA_X2
        always@(posedge pclk_div2 or negedge phy_rst_n)
        begin
            if(!phy_rst_n)
            begin
                P_TDATA_0 <= {2'b11,44'b0};
                P_TDATA_1 <= {2'b11,44'b0};
                //P_TDATA_2 <= {2'b11,44'b0};
                //P_TDATA_3 <= {2'b11,44'b0};
            end
            else
            begin
                P_TDATA_0 <= {mac_phy_txelecidle_h[0],mac_phy_txelecidle_l[0],txdata_l0};
                P_TDATA_1 <= {mac_phy_txelecidle_h[1],mac_phy_txelecidle_l[1],txdata_l1};
                //P_TDATA_2 <= {mac_phy_txelecidle_h[2],mac_phy_txelecidle_l[2],txdata_l2};
                //P_TDATA_3 <= {mac_phy_txelecidle_h[3],mac_phy_txelecidle_l[3],txdata_l3};
            end
        end
    end
    else
    begin:P_TDATA_X4
        always@(posedge pclk_div2 or negedge phy_rst_n)
        begin
            if(!phy_rst_n)
            begin
                P_TDATA_0 <= {2'b11,44'b0};
                P_TDATA_1 <= {2'b11,44'b0};
                P_TDATA_2 <= {2'b11,44'b0};
                P_TDATA_3 <= {2'b11,44'b0};
            end
            else
            begin
                P_TDATA_0 <= {mac_phy_txelecidle_h[0],mac_phy_txelecidle_l[0],txdata_l0};
                P_TDATA_1 <= {mac_phy_txelecidle_h[1],mac_phy_txelecidle_l[1],txdata_l1};
                P_TDATA_2 <= {mac_phy_txelecidle_h[2],mac_phy_txelecidle_l[2],txdata_l2};
                P_TDATA_3 <= {mac_phy_txelecidle_h[3],mac_phy_txelecidle_l[3],txdata_l3};
            end
        end
    end
endgenerate


assign txdata_l0[43:22] = ((mac_phy_powerdown == 2'b0) & ~mac_phy_txelecidle_h[0]) ?
                         {mac_phy_txdatak_w[3 ], 2'd0, mac_phy_txdata_w[31 :24 ],
                          mac_phy_txdatak_w[2 ], 2'd0, mac_phy_txdata_w[23 :16 ]}
                          :22'b0;

assign txdata_l0[21:0]  = ((mac_phy_powerdown == 2'b0) & ~mac_phy_txelecidle_l[0]) ?
                         {mac_phy_txdatak_w[1 ], 2'd0, mac_phy_txdata_w[15 :8  ],
                          mac_phy_txdatak_w[0 ], mac_phy_txcompliance_w[0], 1'b0, mac_phy_txdata_w[7  :0 ]}
                         : 22'b0;

generate
    if (HSST_LANE_NUM == 2)
    begin:tx_data_X2
        assign txdata_l1[43:22] = ((mac_phy_powerdown == 2'b0) & ~mac_phy_txelecidle_h[1]) ?
                                {mac_phy_txdatak_w[7 ], 2'd0, mac_phy_txdata_w[63 :56 ],
                                mac_phy_txdatak_w[6 ], 2'd0, mac_phy_txdata_w[55 :48 ]}
                                : 22'b0;

        assign txdata_l1[21:0]  = ((mac_phy_powerdown == 2'b0) & ~mac_phy_txelecidle_l[1]) ?
                                { mac_phy_txdatak_w[5 ], 2'd0, mac_phy_txdata_w[47 :40 ],
                                mac_phy_txdatak_w[4 ], mac_phy_txcompliance_w[1], 1'b0, mac_phy_txdata_w[39 :32]}
                                : 22'b0;
    end
    else if(HSST_LANE_NUM == 4)
    begin:tx_data_X4
        assign txdata_l1[43:22] = ((mac_phy_powerdown == 2'b0) & ~mac_phy_txelecidle_h[1]) ?
                                {mac_phy_txdatak_w[7 ], 2'd0, mac_phy_txdata_w[63 :56 ],
                                mac_phy_txdatak_w[6 ], 2'd0, mac_phy_txdata_w[55 :48 ]}
                                : 22'b0;

        assign txdata_l1[21:0]  = ((mac_phy_powerdown == 2'b0) & ~mac_phy_txelecidle_l[1]) ?
                                { mac_phy_txdatak_w[5 ], 2'd0, mac_phy_txdata_w[47 :40 ],
                                mac_phy_txdatak_w[4 ], mac_phy_txcompliance_w[1], 1'b0, mac_phy_txdata_w[39 :32]}
                                : 22'b0;

        assign txdata_l2[43:22] = ((mac_phy_powerdown == 2'b0) & ~mac_phy_txelecidle_h[2]) ?
                                {mac_phy_txdatak_w[11], 2'd0, mac_phy_txdata_w[95 :88 ],
                                mac_phy_txdatak_w[10], 2'd0, mac_phy_txdata_w[87 :80 ]}
                                : 22'b0;

        assign txdata_l2[21:0] = ((mac_phy_powerdown == 2'b0) & ~mac_phy_txelecidle_l[2]) ?
                                {mac_phy_txdatak_w[9 ], 2'd0, mac_phy_txdata_w[79 :72 ],
                                mac_phy_txdatak_w[8 ], mac_phy_txcompliance_w[2], 1'b0, mac_phy_txdata_w[71 :64]}
                                : 22'b0;
        assign txdata_l3[43:22] = ((mac_phy_powerdown == 2'b0) & ~mac_phy_txelecidle_h[3]) ?
                                {mac_phy_txdatak_w[15], 2'd0, mac_phy_txdata_w[127:120],
                                mac_phy_txdatak_w[14], 2'd0, mac_phy_txdata_w[119:112]}
                                : 22'b0;

        assign txdata_l3[21:0] = ((mac_phy_powerdown == 2'b0) & ~mac_phy_txelecidle_l[3]) ?
                                {mac_phy_txdatak_w[13], 2'd0, mac_phy_txdata_w[111:104],
                                mac_phy_txdatak_w[12], mac_phy_txcompliance_w[3], 1'b0, mac_phy_txdata_w[103:96]}
                                : 22'b0;
    end
endgenerate

hsstl_phy_mac_rdata_proc #(
    .EN_CONTI_SKP_REPLACE (EN_CONTI_SKP_REPLACE)
)rdata_proc_0(
    .pclk                (pclk_div2                 ),
    .rst_n               (phy_rst_n                 ),
    .P_RDATA             (P_RDATA_0                 ),
    .rx_det_done         (rx_det_done               ),
    .lx_rxdct_out_d      (lx_rxdct_out_d[0]         ),

    .phy_mac_rxdata      (phy_mac_rxdata_w[31 :0 ]  ),
    .phy_mac_rxdatak     (phy_mac_rxdatak_w[3 :0 ]  ),
    .phy_mac_rxstatus    (phy_mac_rxstatus[2:0] )
);

generate
    if (HSST_LANE_NUM == 2)
    begin
        hsstl_phy_mac_rdata_proc #(
            .EN_CONTI_SKP_REPLACE (EN_CONTI_SKP_REPLACE)
        )rdata_proc_1(
            .pclk                (pclk_div2                     ),
            .rst_n               (phy_rst_n                     ),
            .P_RDATA             (P_RDATA_1                     ),
            .rx_det_done         (rx_det_done                   ),
            .lx_rxdct_out_d      (lx_rxdct_out_d[1]             ),

            .phy_mac_rxdata      (phy_mac_rxdata_w[32+31 :32+0] ),
            .phy_mac_rxdatak     (phy_mac_rxdatak_w[4+3 :4+0]   ),
            .phy_mac_rxstatus    (phy_mac_rxstatus[3+2:3+0]     )
        );
    end
    else if (HSST_LANE_NUM == 4)
    begin
        hsstl_phy_mac_rdata_proc #(
            .EN_CONTI_SKP_REPLACE (EN_CONTI_SKP_REPLACE)
        )rdata_proc_1(
            .pclk                (pclk_div2                     ),
            .rst_n               (phy_rst_n                     ),
            .P_RDATA             (P_RDATA_1                     ),
            .rx_det_done         (rx_det_done                   ),
            .lx_rxdct_out_d      (lx_rxdct_out_d[1]             ),

            .phy_mac_rxdata      (phy_mac_rxdata_w[32+31 :32+0] ),
            .phy_mac_rxdatak     (phy_mac_rxdatak_w[4+3 :4+0]   ),
            .phy_mac_rxstatus    (phy_mac_rxstatus[3+2:3+0]     )
        );
        hsstl_phy_mac_rdata_proc #(
            .EN_CONTI_SKP_REPLACE (EN_CONTI_SKP_REPLACE)
        )rdata_proc_2(
            .pclk                (pclk_div2                         ),
            .rst_n               (phy_rst_n                         ),
            .P_RDATA             (P_RDATA_2                         ),
            .rx_det_done         (rx_det_done                       ),
            .lx_rxdct_out_d      (lx_rxdct_out_d[2]                 ),

            .phy_mac_rxdata      (phy_mac_rxdata_w[32*2+31 :32*2+0] ),
            .phy_mac_rxdatak     (phy_mac_rxdatak_w[4*2+3 :4*2+0]   ),
            .phy_mac_rxstatus    (phy_mac_rxstatus[3*2+2:3*2+0]     )
        );

        hsstl_phy_mac_rdata_proc #(
            .EN_CONTI_SKP_REPLACE (EN_CONTI_SKP_REPLACE)
        )rdata_proc_3(
            .pclk                (pclk_div2                         ),
            .rst_n               (phy_rst_n                         ),
            .P_RDATA             (P_RDATA_3                         ),
            .rx_det_done         (rx_det_done                       ),
            .lx_rxdct_out_d      (lx_rxdct_out_d[3]                 ),

            .phy_mac_rxdata      (phy_mac_rxdata_w[32*3+31 :32*3+0] ),
            .phy_mac_rxdatak     (phy_mac_rxdatak_w[4*3+3 :4*3+0]   ),
            .phy_mac_rxstatus    (phy_mac_rxstatus[3*3+2:3*3+0]     )
        );
    end
endgenerate

//assign phy_mac_rxdatavalid      = 4'hf;
//assign phy_mac_rxstandbystatus  = 4'hf;

generate
genvar i;
for(i=0;i<HSST_LANE_NUM;i=i+1)begin
    ipsl_pcie_sync_v1_0 hsst_ch_ready_sync (
        .clk        ( pclk_div2         ),
        .rst_n      ( phy_rst_n         ),
        .sig_async  ( hsst_ch_ready[i]  ),
        .sig_synced ( rx_valid_i[i]     )
    );
end
endgenerate

assign phy_mac_rxvalid[0+:HSST_LANE_NUM] = |rx_valid_i[0+:HSST_LANE_NUM] ? P_PCS_LSM_SYNCED[0+:HSST_LANE_NUM] : {HSST_LANE_NUM{1'b0}};

// Rx Elecidle
assign phy_mac_rxelecidle[0+:HSST_LANE_NUM] = P_LX_ALOS_STA[0+:HSST_LANE_NUM];



//=== Rx detect ===
assign start_rx_det[0] = (mac_phy_powerdown == 2'b10) & mac_phy_txdetectrx_loopback[0];
assign start_rx_det[1] = (HSST_LANE_NUM == 1) ? 1'b0 : (mac_phy_powerdown == 2'b10) & mac_phy_txdetectrx_loopback[1];
assign start_rx_det[2] = ((HSST_LANE_NUM == 2) || (HSST_LANE_NUM == 1)) ? 1'b0 : (mac_phy_powerdown == 2'b10) & mac_phy_txdetectrx_loopback[2];
assign start_rx_det[3] = ((HSST_LANE_NUM == 2) || (HSST_LANE_NUM == 1)) ? 1'b0 : (mac_phy_powerdown == 2'b10) & mac_phy_txdetectrx_loopback[3];

always@(posedge pclk_div2 or negedge phy_rst_n)
begin
    if (!phy_rst_n)
        start_rx_det_ff <= 4'b0;
    else
        start_rx_det_ff <= start_rx_det;
end

//detect force

//assign P_LX_RXDCT_OUT_0 = 1'b1;
//assign P_LX_RXDCT_OUT_1 = 1'b1;
//assign P_LX_RXDCT_OUT_2 = 1'b1;
//assign P_LX_RXDCT_OUT_3 = 1'b1;

assign start_rx_det_pos = ~start_rx_det_ff & start_rx_det;

always@(posedge pclk_div2 or negedge phy_rst_n)
begin
    if (!phy_rst_n) begin
        rx_detect_en   <= 1'b0;
        det_cnt        <= 4'd0;
        lx_rxdct_out_d <= 4'd0;
    end
    else begin
        if (rx_detect_en) begin
           if (&det_cnt) begin
              det_cnt   <= 4'd0;
              rx_detect_en <= 1'b0;
           end
           else
              det_cnt   <= det_cnt + 1;
        end
        else if (|start_rx_det_pos) begin
           rx_detect_en <= 1'b1;
           det_cnt      <= 4'd0;
        end

        if (rx_detect_en && (det_cnt == 9))
           lx_rxdct_out_d <= (HSST_LANE_NUM == 1) ? {1'b0, 1'b0, 1'b0, P_LX_RXDCT_OUT_0} :
                             (HSST_LANE_NUM == 2) ? {1'b0, 1'b0, P_LX_RXDCT_OUT_1, P_LX_RXDCT_OUT_0} :
                             {P_LX_RXDCT_OUT_3, P_LX_RXDCT_OUT_2, P_LX_RXDCT_OUT_1, P_LX_RXDCT_OUT_0};

    end
end

assign P_LX_RXDCT_EN    = {4{rx_detect_en}} & start_rx_det;
assign rx_det_done      = rx_detect_en && (det_cnt == 10);

//used to communicate completion of several phy functions includes:
//stable pclk after reset#
//power managements transitions
//rate change
// receiver detection
localparam      P2_ENTRY_CNT_INIT   = 16;
localparam      P2_EXIT_CNT_INIT    = 16;
localparam      L0_TO_L0S_CNT_INIT  = 16;
localparam      L0S_TO_L0_CNT_INIT  = 16;
localparam      L1_TO_L0_CNT_INIT   = 16;
localparam      L0_TO_L1_CNT_INIT   = 16;
localparam      DEFAULT_CNT_INIT    = 16;
reg         [1:0]       tx_rst_done_d;
reg         [3:0]       phy_mac_phystatus_reset;
reg         [3:0]       phy_mac_phystatus_misc;
reg         [3:0]       phy_mac_phystatus_pm;
reg         [1:0]       mac_phy_powerdown_d;
reg         [7:0]       cnt;

reg     tx_rst_done_ref;
wire    s_tx_rst_done_pclk_div2;

wire    ref_rst_n;
wire    hsst_apb_rst_n;

ipsl_pcie_sync_v1_0  phy_rstn_sync (.clk(P_REFCK2CORE_0), .rst_n(phy_rst_n), .sig_async(1'b1),  .sig_synced(ref_rst_n));

ipsl_pcie_sync_v1_0  button_rstn_sync (.clk(P_REFCK2CORE_0), .rst_n(button_rst_n), .sig_async(1'b1),  .sig_synced(hsst_apb_rst_n));

always@(posedge P_REFCK2CORE_0 or negedge ref_rst_n)
begin
    if (!ref_rst_n)
        tx_rst_done_ref <= 1'b0;
    else if(~(&P_PMA_RX_PD))
        tx_rst_done_ref <= tx_rst_done;
end

reg tx_rst_done_ref_ff;
reg tx_rst_done_ref_ff2;

always@(posedge pclk_div2)
begin
    tx_rst_done_ref_ff  <= tx_rst_done_ref;
    tx_rst_done_ref_ff2 <= tx_rst_done_ref_ff;
end

assign s_tx_rst_done_pclk_div2 = tx_rst_done_ref_ff2;

always@(posedge pclk_div2 or negedge phy_rst_n)
begin
    if (!phy_rst_n) begin
        tx_rst_done_d <= 2'h0;
        phy_mac_phystatus_reset <= 4'hf;
    end
    else begin
        //tx_rst_done_d <= {tx_rst_done_d[0],tx_rst_done};
        tx_rst_done_d <= (HSST_LANE_NUM == 1) ? {tx_rst_done_d[0],s_tx_rst_done_pclk_div2 & ~(P_PMA_RX_PD[0])}
                                              : {tx_rst_done_d[0],s_tx_rst_done_pclk_div2};

        if (tx_rst_done_d[0] & (~tx_rst_done_d[1]))
           phy_mac_phystatus_reset <= 4'h0;
    end
end

always@(posedge pclk_div2 or negedge phy_rst_n)
begin
    if (!phy_rst_n) begin
        phy_mac_phystatus_misc <= 4'b0;
    end
    else begin
        if (rx_det_done | rate_done)
            phy_mac_phystatus_misc <= (HSST_LANE_NUM == 1) ? 4'h1 :
                                      (HSST_LANE_NUM == 2) ? 4'h3 : 4'hF;
        else
           phy_mac_phystatus_misc <= 4'h0;
    end
end

always@(posedge pclk_div2 or negedge phy_rst_n)
begin
    if (!phy_rst_n) begin
        mac_phy_powerdown_d  <= 2'd2;
        cnt                  <= 8'd0;
        phy_mac_phystatus_pm <= 4'b0;
    end
    else begin
        mac_phy_powerdown_d  <= mac_phy_powerdown;
        if ((mac_phy_powerdown == 2'd3) & (mac_phy_powerdown_d == 2'd0)) //P0 to P2; P2 entry, to be update; also used for L0 to L1
            cnt <= P2_ENTRY_CNT_INIT;
        else if ((mac_phy_powerdown == 2'd0) & (mac_phy_powerdown_d == 2'd3)) //P2 to P0; P2 exit, to be update
            cnt <= P2_EXIT_CNT_INIT;
        else if ((mac_phy_powerdown == 2'd1) & (mac_phy_powerdown_d == 2'd0)) //L0 to L0s
            cnt <= L0_TO_L0S_CNT_INIT;
        else if ((mac_phy_powerdown == 2'd0) & (mac_phy_powerdown_d == 2'd1)) //L0s to L0
            cnt <= L0S_TO_L0_CNT_INIT;
        else if ((mac_phy_powerdown == 2'd0) & (mac_phy_powerdown_d == 2'd2)) //L1 to L0
            cnt <= L1_TO_L0_CNT_INIT;
        else if ((mac_phy_powerdown == 2'd2) & (mac_phy_powerdown_d == 2'd0)) //L0 to L1
            cnt <= L0_TO_L1_CNT_INIT;
        else if (mac_phy_powerdown != mac_phy_powerdown_d )//default
                 cnt <= DEFAULT_CNT_INIT;
        else if (cnt != 0)
            cnt <= cnt - 1;

        if (cnt == 1)
            phy_mac_phystatus_pm <= (HSST_LANE_NUM == 1) ? 4'h1 :
                                    (HSST_LANE_NUM == 2) ? 4'h3 : 4'hf;

        else
            phy_mac_phystatus_pm <= 4'h0;
    end
end

assign phy_mac_phystatus = phy_mac_phystatus_pm | phy_mac_phystatus_misc | phy_mac_phystatus_reset;

//=== TxSwing ===
//-- Voltage --
// Amplitude setting
// Driver output swing control, programming range is from 125mV to 1000mV.
// 0000 :  125mV       1000 :   562mV
// 0001 :  167mV       1001 :   625mV
// 0010 :  208mV       1010 :   687mV
// 0011 :  250mV       1011 :   750mV
// 0100 :  312mV       1100 :   812mV
// 0101 :  375mV       1101 :   875mV
// 0110 :  437mV       1110 :   937mV
// 0111 :  500mV       1111 :   1000mV

//=== De-emph ===
assign P_LX_DEEMP_CTL_0 = lx_deemph;
assign P_LX_DEEMP_CTL_1 = lx_deemph;
assign P_LX_DEEMP_CTL_2 = lx_deemph;
assign P_LX_DEEMP_CTL_3 = lx_deemph;

always@(posedge pclk_div2 or negedge phy_rst_n)
begin
    if (!phy_rst_n)
        lx_deemph <= 2'b00;
    else if (mac_phy_txdeemph==2'b00)
        lx_deemph <= 2'b01;
    else
        lx_deemph <= 2'b00;
end

//=== Rx Polarity ===
assign P_RX_POLARITY_INVERT = mac_phy_rxpolarity;
//supply0 REP0;
//supply1 REP1;
assign P_PLL_LOCK = P_PLL_READY_0;

// HSST_ALIGN
assign P_LX_ALOS_STA[0+:HSST_LANE_NUM] = ~P_PMA_SIGDET_STATUS[0+:HSST_LANE_NUM];

generate
genvar j;
for(j=0;j<HSST_LANE_NUM;j=j+1) begin
    assign p_alos_sta[j] = P_LX_ALOS_STA[j] & (~pcs_nearend_loop[j] & ~pma_nearend_ploop[j] & ~pma_nearend_sloop[j]);
    assign p_cdr_align[j]= P_LX_CDR_ALIGN[j] | (pcs_nearend_loop[j] | pma_nearend_ploop[j]);
end
endgenerate

assign alos_sta  = {{4-HSST_LANE_NUM{1'b1}},p_alos_sta[0+:HSST_LANE_NUM]};
assign cdr_align = {{4-HSST_LANE_NUM{1'b0}},p_cdr_align[0+:HSST_LANE_NUM]};

// rate change
assign rate_change = (mac_phy_rate == rate_r) ? 1'b0 : 1'b1;
always @ (posedge pclk_div2 or negedge phy_rst_n )
begin
    if(~phy_rst_n)
        rate_r <= 1'b0;
    else
        rate_r <= mac_phy_rate;
end

ipsl_pcie_sync_v1_0 rate_done_sync (.clk    ( pclk_div2 ),  .rst_n  ( phy_rst_n ),  .sig_async  ( rate_change_done ),   .sig_synced ( rate_done_s ));

always @ (posedge pclk_div2 or negedge phy_rst_n)
begin
    if(~phy_rst_n)
        rate_done_s_r1 <= 1'b0;
    else
        rate_done_s_r1 <= rate_done_s;
end

assign rate_done = rate_done_s & ~rate_done_s_r1;

always @ (posedge pclk_div2 or negedge phy_rst_n )
begin
    if(~phy_rst_n)
        phy_rate_chng_halt <= 1'b0;
    else if(rate_change)
        phy_rate_chng_halt <= 1'b1;
    else if(rate_done)
        phy_rate_chng_halt <= 1'b0;
end

assign mac_phy_rate_i = mac_phy_rate;


hsstl_rst4mcrsw_v1_0 #(
    .LINK_X1_WIDTH           ( 1                        ),
    .FORCE_LANE_REV          ( 0                        )
) hsst_pciex4_rst (
    .clk                     ( P_REFCK2CORE_0           ),
    .ext_rst_n               ( external_rstn            ),
    .txpll_soft_rst_n        ( 1'b1                     ),
    .rxlane_soft_rst_n       ( 4'hf                     ),
    .wtchdg_clr              ( 1'b0                     ),
    .ltssm_in_recovery       ( 1'b1                     ),
    .rate                    ( mac_phy_rate_i           ),
    .link_num                ( 2'b0                     ),
    .link_num_flag           ( 1'b0                     ),
    .P_PLL_LOCK              ( P_PLL_LOCK               ),
    .P_LX_ALOS_STA_0         ( alos_sta[0]              ),
    .P_LX_ALOS_STA_1         ( alos_sta[1]              ),
    .P_LX_ALOS_STA_2         ( alos_sta[2]              ),
    .P_LX_ALOS_STA_3         ( alos_sta[3]              ),
    .P_LX_CDR_ALIGN_0        ( cdr_align[0]             ),
    .P_LX_CDR_ALIGN_1        ( cdr_align[1]             ),
    .P_LX_CDR_ALIGN_2        ( cdr_align[2]             ),
    .P_LX_CDR_ALIGN_3        ( cdr_align[3]             ),
    .P_PCS_LSM_SYNCED        ({{(4-HSST_LANE_NUM){1'b0}},P_PCS_LSM_SYNCED[0+:HSST_LANE_NUM]} ),
    .tx_fsm                  ( tx_fsm                   ),
    .s_P_PLL_LOCK_deb        ( s_P_PLL_LOCK_deb         ),
    .pll_lock_wtchdg_rst_n   ( pll_lock_wtchdg_rst_n    ),

    .P_PMA_LANE_PD           ( P_PMA_LANE_PD            ),
    .P_PMA_LANE_RST          ( P_PMA_LANE_RST           ),
    .P_HSST_RST              ( P_HSST_RST               ),
    .P_PLLPOWERDOWN_0        ( P_PLLPOWERDOWN_0         ),
    .P_PLLPOWERDOWN_1        ( P_PLLPOWERDOWN_1         ),
    .P_PLL_RST_0             ( P_PLL_RST_0              ),
    .P_PLL_RST_1             ( P_PLL_RST_1              ),
    .P_PMA_TX_PD             ( P_PMA_TX_PD              ),
    .P_RATE_CHG_TXPCLK_ON_0  ( P_RATE_CHG_TXPCLK_ON_0   ),
    .P_RATE_CHG_TXPCLK_ON_1  ( P_RATE_CHG_TXPCLK_ON_1   ),
    .P_LANE_SYNC_0           ( P_LANE_SYNC_0            ),
    .P_LANE_SYNC_EN_0        ( P_LANE_SYNC_EN_0         ),
    .P_LANE_SYNC_1           ( P_LANE_SYNC_1            ),
    .P_PMA_TX_RATE_0         ( P_PMA_TX_RATE_0          ),
    .P_PMA_TX_RATE_1         ( P_PMA_TX_RATE_1          ),
    .P_PMA_TX_RATE_2         ( P_PMA_TX_RATE_2          ),
    .P_PMA_TX_RATE_3         ( P_PMA_TX_RATE_3          ),
    .P_PMA_TX_RST_0          ( P_PMA_TX_RST_0           ),
    .P_PMA_TX_RST_1          ( P_PMA_TX_RST_1           ),
    .P_PMA_TX_RST_2          ( P_PMA_TX_RST_2           ),
    .P_PMA_TX_RST_3          ( P_PMA_TX_RST_3           ),
    .P_PCS_TX_RST_0          ( P_PCS_TX_RST_0           ),
    .P_PCS_TX_RST_1          ( P_PCS_TX_RST_1           ),
    .P_PCS_TX_RST_2          ( P_PCS_TX_RST_2           ),
    .P_PCS_TX_RST_3          ( P_PCS_TX_RST_3           ),
    .tx_rst_done             ( tx_rst_done              ),
    //rx
    .rx_main_fsm             (),
    .rx_init_fsm0            (),
    .rx_init_fsm1            (),
    .rx_init_fsm2            (),
    .rx_init_fsm3            (),
    .s_PCS_LSM_SYNCED        ( s_PCS_LSM_SYNCED         ),
    .s_LX_ALOS_STA_deb       ( s_LX_ALOS_STA_deb        ),
    .s_LX_CDR_ALIGN_deb      ( s_LX_CDR_ALIGN_deb       ),
    .P_PMA_RX_PD             ( P_PMA_RX_PD              ),
    .P_PMA_RX_RST_0          ( P_PMA_RX_RST_0           ),
    .P_PMA_RX_RST_1          ( P_PMA_RX_RST_1           ),
    .P_PMA_RX_RST_2          ( P_PMA_RX_RST_2           ),
    .P_PMA_RX_RST_3          ( P_PMA_RX_RST_3           ),
    .P_PCS_RX_RST_0          ( P_PCS_RX_RST_0           ),
    .P_PCS_RX_RST_1          ( P_PCS_RX_RST_1           ),
    .P_PCS_RX_RST_2          ( P_PCS_RX_RST_2           ),
    .P_PCS_RX_RST_3          ( P_PCS_RX_RST_3           ),
    .P_LX_RX_RATE_0          ( P_LX_RX_RATE_0           ),
    .P_LX_RX_RATE_1          ( P_LX_RX_RATE_1           ),
    .P_LX_RX_RATE_2          ( P_LX_RX_RATE_2           ),
    .P_LX_RX_RATE_3          ( P_LX_RX_RATE_3           ),
    .rate_done               ( rate_change_done         ),
    .hsst_ch_ready           ( hsst_ch_ready            ),
    .init_done               (),
    .P_TX_PD_CLKPATH         (),
    .P_TX_PD_PISO            (),
    .P_TX_PD_DRIVER          (),
    .P_PCS_CB_RST            (P_PCS_CB_RST              ),
    .mac_clk_req_n           (1'b0                      ),
    .phy_clk_req_n           (phy_clk_req_n             )


);


generate
    if(HSST_LANE_NUM == 1)
    begin:x1
        wire [31:0] i_txd_0;
        //wire [31:0] i_txd_1;
        //wire [31:0] i_txd_2;
        //wire [31:0] i_txd_3;

        assign i_txd_0 = {P_TDATA_0[40:33],P_TDATA_0[29:22],P_TDATA_0[18:11],P_TDATA_0[7:0]};
        //assign i_txd_1 = {P_TDATA_1[40:33],P_TDATA_1[29:22],P_TDATA_1[18:11],P_TDATA_1[7:0]};
        //assign i_txd_2 = {P_TDATA_2[40:33],P_TDATA_2[29:22],P_TDATA_2[18:11],P_TDATA_2[7:0]};
        //assign i_txd_3 = {P_TDATA_3[40:33],P_TDATA_3[29:22],P_TDATA_3[18:11],P_TDATA_3[7:0]};

        wire  [1:0]   i_p_lx_elecidle_en_0;
        //wire  [1:0]   i_p_lx_elecidle_en_1;
        //wire  [1:0]   i_p_lx_elecidle_en_2;
        //wire  [1:0]   i_p_lx_elecidle_en_3;

        assign i_p_lx_elecidle_en_0 = P_TDATA_0[45:44];
        //assign i_p_lx_elecidle_en_1 = P_TDATA_1[45:44];
        //assign i_p_lx_elecidle_en_2 = P_TDATA_2[45:44];
        //assign i_p_lx_elecidle_en_3 = P_TDATA_3[45:44];

        wire    [3:0]   i_txk_0;
        //wire    [3:0]   i_txk_1;
        //wire    [3:0]   i_txk_2;
        //wire    [3:0]   i_txk_3;

        assign i_txk_0 = {P_TDATA_0[43],P_TDATA_0[32],P_TDATA_0[21],P_TDATA_0[10]};
        //assign i_txk_1 = {P_TDATA_1[43],P_TDATA_1[32],P_TDATA_1[21],P_TDATA_1[10]};
        //assign i_txk_2 = {P_TDATA_2[43],P_TDATA_2[32],P_TDATA_2[21],P_TDATA_2[10]};
        //assign i_txk_3 = {P_TDATA_3[43],P_TDATA_3[32],P_TDATA_3[21],P_TDATA_3[10]};

        wire    [3:0]   i_tdispsel_0;
        //wire    [3:0]   i_tdispsel_1;
        //wire    [3:0]   i_tdispsel_2;
        //wire    [3:0]   i_tdispsel_3;
        wire    [3:0]   i_tdispctrl_0;
        //wire    [3:0]   i_tdispctrl_1;
        //wire    [3:0]   i_tdispctrl_2;
        //wire    [3:0]   i_tdispctrl_3;

        assign i_tdispsel_0 = {P_TDATA_0[41],P_TDATA_0[30],P_TDATA_0[19],P_TDATA_0[8]};
        //assign i_tdispsel_1 = {P_TDATA_1[41],P_TDATA_1[30],P_TDATA_1[19],P_TDATA_1[8]};
        //assign i_tdispsel_2 = {P_TDATA_2[41],P_TDATA_2[30],P_TDATA_2[19],P_TDATA_2[8]};
        //assign i_tdispsel_3 = {P_TDATA_3[41],P_TDATA_3[30],P_TDATA_3[19],P_TDATA_3[8]};

        assign i_tdispctrl_0 = {P_TDATA_0[42],P_TDATA_0[31],P_TDATA_0[20],P_TDATA_0[9]};
        //assign i_tdispctrl_1 = {P_TDATA_1[42],P_TDATA_1[31],P_TDATA_1[20],P_TDATA_1[9]};
        //assign i_tdispctrl_2 = {P_TDATA_2[42],P_TDATA_2[31],P_TDATA_2[20],P_TDATA_2[9]};
        //assign i_tdispctrl_3 = {P_TDATA_3[42],P_TDATA_3[31],P_TDATA_3[20],P_TDATA_3[9]};


        wire [ 2:0] o_rxstatus_0;
        wire [31:0] o_rxd_0;
        wire [ 3:0] o_rdisper_0;
        wire [ 3:0] o_rdecer_0;
        wire [ 3:0] o_rxk_0;

        //wire [ 2:0] o_rxstatus_1;
        //wire [31:0] o_rxd_1;
        //wire [ 3:0] o_rdisper_1;
        //wire [ 3:0] o_rdecer_1;
        //wire [ 3:0] o_rxk_1;
        //
        //wire [ 2:0] o_rxstatus_2;
        //wire [31:0] o_rxd_2;
        //wire [ 3:0] o_rdisper_2;
        //wire [ 3:0] o_rdecer_2;
        //wire [ 3:0] o_rxk_2;
        //
        //wire [ 2:0] o_rxstatus_3;
        //wire [31:0] o_rxd_3;
        //wire [ 3:0] o_rdisper_3;
        //wire [ 3:0] o_rdecer_3;
        //wire [ 3:0] o_rxk_3;

        // 8b10b-32bits
        assign P_RDATA_0 = {o_rxstatus_0, o_rxk_0[3], o_rdecer_0[3], o_rdisper_0[3], o_rxd_0[31:24], o_rxk_0[2], o_rdecer_0[2], o_rdisper_0[2], o_rxd_0[23:16], o_rxk_0[1], o_rdecer_0[1], o_rdisper_0[1], o_rxd_0[15:8], o_rxk_0[0], o_rdecer_0[0], o_rdisper_0[0], o_rxd_0[7:0]};
        //assign P_RDATA_1 = {o_rxstatus_1, o_rxk_1[3], o_rdecer_1[3], o_rdisper_1[3], o_rxd_1[31:24], o_rxk_1[2], o_rdecer_1[2], o_rdisper_1[2], o_rxd_1[23:16], o_rxk_1[1], o_rdecer_1[1], o_rdisper_1[1], o_rxd_1[15:8], o_rxk_1[0], o_rdecer_1[0], o_rdisper_1[0], o_rxd_1[7:0]};
        //assign P_RDATA_2 = {o_rxstatus_2, o_rxk_2[3], o_rdecer_2[3], o_rdisper_2[3], o_rxd_2[31:24], o_rxk_2[2], o_rdecer_2[2], o_rdisper_2[2], o_rxd_2[23:16], o_rxk_2[1], o_rdecer_2[1], o_rdisper_2[1], o_rxd_2[15:8], o_rxk_2[0], o_rdecer_2[0], o_rdisper_2[0], o_rxd_2[7:0]};
        //assign P_RDATA_3 = {o_rxstatus_3, o_rxk_3[3], o_rdecer_3[3], o_rdisper_3[3], o_rxd_3[31:24], o_rxk_3[2], o_rdecer_3[2], o_rdisper_3[2], o_rxd_3[23:16], o_rxk_3[1], o_rdecer_3[1], o_rdisper_3[1], o_rxd_3[15:8], o_rxk_3[0], o_rdecer_3[0], o_rdisper_3[0], o_rxd_3[7:0]};

        `ifdef IPSL_PCIE_SPEEDUP_SIM
            initial
            $display("hsst_x1 MODE!");
        `endif


        ipml_pcie_hsst_x1_top u_pcie_hsst (
        //    .free_clk                      (free_clk                ),

            .i_p_refckn_1                  (P_REFCKN                ),  // input
            .i_p_refckp_1                  (P_REFCKP                ),  // input

            .i_p_tx_lane_pd_0              (P_PMA_TX_PD[0]          ),  // input
        //    .i_p_tx_lane_pd_1              (P_PMA_TX_PD[1]          ),  // input
        //    .i_p_tx_lane_pd_2              (P_PMA_TX_PD[2]          ),  // input
        //    .i_p_tx_lane_pd_3              (P_PMA_TX_PD[3]          ),  // input
            .i_p_lane_pd_0                 (P_PMA_LANE_PD[0]        ),  // input
        //    .i_p_lane_pd_1                 (P_PMA_LANE_PD[1]        ),  // input
        //    .i_p_lane_pd_2                 (P_PMA_LANE_PD[2]        ),  // input
        //    .i_p_lane_pd_3                 (P_PMA_LANE_PD[3]        ),  // input
            .i_p_lane_rst_0                (P_PMA_LANE_RST[0]       ),  // input
        //    .i_p_lane_rst_1                (P_PMA_LANE_RST[1]       ),  // input
        //    .i_p_lane_rst_2                (P_PMA_LANE_RST[2]       ),  // input
        //    .i_p_lane_rst_3                (P_PMA_LANE_RST[3]       ),  // input
            .i_p_rx_lane_pd_0              (P_PMA_RX_PD[0]          ),  // input
        //    .i_p_rx_lane_pd_1              (P_PMA_RX_PD[1]          ),  // input
        //    .i_p_rx_lane_pd_2              (P_PMA_RX_PD[2]          ),  // input
        //    .i_p_rx_lane_pd_3              (P_PMA_RX_PD[3]          ),  // input
            .o_p_clk2core_tx_0             (TCLK2FABRIC[0]          ),  // output
            .i_p_tx0_clk_fr_core           (pclk_div2               ),  // input
        //    .i_p_tx1_clk_fr_core           (pclk_div2               ),  // input
        //    .i_p_tx2_clk_fr_core           (pclk_div2               ),  // input
        //    .i_p_tx3_clk_fr_core           (pclk_div2               ),  // input
            .i_p_tx0_clk2_fr_core          (pclk                    ),  // input
        //    .i_p_tx1_clk2_fr_core          (pclk                    ),  // input
        //    .i_p_tx2_clk2_fr_core          (pclk                    ),  // input
        //    .i_p_tx3_clk2_fr_core          (pclk                    ),  // input
        //    .i_pll_lock_tx_0               (1'b1                    ),
        //    .i_pll_lock_tx_1               (1'b1                    ),
        //    .i_pll_lock_tx_2               (1'b1                    ),
        //    .i_pll_lock_tx_3               (1'b1                    ),
            .o_p_clk2core_rx_0             (RCLK2FABRIC[0]          ),
            .i_p_rx0_clk_fr_core           (pclk_div2               ),  // input
        //    .i_p_rx1_clk_fr_core           (pclk_div2               ),  // input
        //    .i_p_rx2_clk_fr_core           (pclk_div2               ),  // input
        //    .i_p_rx3_clk_fr_core           (pclk_div2               ),  // input
            .i_p_rx0_clk2_fr_core          (pclk                    ),  // input
        //    .i_p_rx1_clk2_fr_core          (pclk                    ),  // input
        //    .i_p_rx2_clk2_fr_core          (pclk                    ),  // input
        //    .i_p_rx3_clk2_fr_core          (pclk                    ),  // input
        //    .o_p_refck2core_0              (P_REFCK2CORE_0          ),  // output
            .i_p_pll_rst_0                 (P_PLL_RST_0             ),  // input
            .i_p_tx_pma_rst_0              (P_PMA_TX_RST_0          ),  // input
        //    .i_p_tx_pma_rst_1              (P_PMA_TX_RST_1          ),  // input
        //    .i_p_tx_pma_rst_2              (P_PMA_TX_RST_2          ),  // input
        //    .i_p_tx_pma_rst_3              (P_PMA_TX_RST_3          ),  // input
            .i_p_pcs_tx_rst_0              (P_PCS_TX_RST_0          ),  // input
        //    .i_p_pcs_tx_rst_1              (P_PCS_TX_RST_1          ),  // input
        //    .i_p_pcs_tx_rst_2              (P_PCS_TX_RST_2          ),  // input
        //    .i_p_pcs_tx_rst_3              (P_PCS_TX_RST_3          ),  // input
            .i_p_rx_pma_rst_0              (P_PMA_RX_RST_0          ),  // input
        //    .i_p_rx_pma_rst_1              (P_PMA_RX_RST_1          ),  // input
        //    .i_p_rx_pma_rst_2              (P_PMA_RX_RST_2          ),  // input
        //    .i_p_rx_pma_rst_3              (P_PMA_RX_RST_3          ),  // input
            .i_p_pcs_rx_rst_0              (P_PCS_RX_RST_0          ),  // input
        //    .i_p_pcs_rx_rst_1              (P_PCS_RX_RST_1          ),  // input
        //    .i_p_pcs_rx_rst_2              (P_PCS_RX_RST_2          ),  // input
        //    .i_p_pcs_rx_rst_3              (P_PCS_RX_RST_3          ),  // input
            .i_p_pcs_cb_rst_0              (P_PCS_CB_RST[0]         ),  // input
        //    .i_p_pcs_cb_rst_1              (P_PCS_CB_RST[1]         ),  // input
        //    .i_p_pcs_cb_rst_2              (P_PCS_CB_RST[2]         ),  // input
        //    .i_p_pcs_cb_rst_3              (P_PCS_CB_RST[3]         ),  // input
            .i_p_lx_margin_ctl_0           (mac_phy_txmargin        ),  // input  [2:0]
        //    .i_p_lx_margin_ctl_1           (mac_phy_txmargin        ),  // input  [2:0]
        //    .i_p_lx_margin_ctl_2           (mac_phy_txmargin        ),  // input  [2:0]
        //    .i_p_lx_margin_ctl_3           (mac_phy_txmargin        ),  // input  [2:0]
            .i_p_lx_swing_ctl_0            (mac_phy_txswing         ),  // input
        //    .i_p_lx_swing_ctl_1            (mac_phy_txswing         ),  // input
        //    .i_p_lx_swing_ctl_2            (mac_phy_txswing         ),  // input
        //    .i_p_lx_swing_ctl_3            (mac_phy_txswing         ),  // input

            // Lane de-emphasis default 3.5dB
            // 2'b00 -> 3.5dB
            // 2'b01 -> 6dB
            .i_p_lx_deemp_ctl_0            (P_LX_DEEMP_CTL_0        ), // input [1:0]
        //    .i_p_lx_deemp_ctl_1            (P_LX_DEEMP_CTL_1        ), // input [1:0]
        //    .i_p_lx_deemp_ctl_2            (P_LX_DEEMP_CTL_2        ), // input [1:0]
        //    .i_p_lx_deemp_ctl_3            (P_LX_DEEMP_CTL_3        ), // input [1:0]

            .i_p_lane_sync_0               (P_LANE_SYNC_0           ),  // input
            .i_p_lane_sync_en_0            (P_LANE_SYNC_EN_0        ),
            .i_p_rate_change_tclk_on_0     (P_RATE_CHG_TXPCLK_ON_0  ),  // input
            .i_p_tx_ckdiv_0                (P_PMA_TX_RATE_0[1:0]    ),  // input  [1:0]
        //    .i_p_tx_ckdiv_1                (P_PMA_TX_RATE_1[1:0]    ),  // input  [1:0]
        //    .i_p_tx_ckdiv_2                (P_PMA_TX_RATE_2[1:0]    ),  // input  [1:0]
        //    .i_p_tx_ckdiv_3                (P_PMA_TX_RATE_3[1:0]    ),  // input  [1:0]
            .i_p_lx_rx_ckdiv_0             (P_PMA_TX_RATE_0[1:0]    ),
        //    .i_p_lx_rx_ckdiv_1             (P_PMA_TX_RATE_1[1:0]    ),
        //    .i_p_lx_rx_ckdiv_2             (P_PMA_TX_RATE_2[1:0]    ),
        //    .i_p_lx_rx_ckdiv_3             (P_PMA_TX_RATE_3[1:0]    ),
            .i_p_lx_elecidle_en_0          (i_p_lx_elecidle_en_0    ),  // input  [1:0]
        //    .i_p_lx_elecidle_en_1          (i_p_lx_elecidle_en_1    ),  // input  [1:0]
        //    .i_p_lx_elecidle_en_2          (i_p_lx_elecidle_en_2    ),  // input  [1:0]
        //    .i_p_lx_elecidle_en_3          (i_p_lx_elecidle_en_3    ),  // input  [1:0]
            .o_p_pll_lock_0                (P_PLL_READY_0           ),  // output
            .o_p_rx_sigdet_sta_0           (P_PMA_SIGDET_STATUS[0]  ),  // output
        //    .o_p_rx_sigdet_sta_1           (P_PMA_SIGDET_STATUS_1   ),  // output
        //    .o_p_rx_sigdet_sta_2           (P_PMA_SIGDET_STATUS_2   ),  // output
        //    .o_p_rx_sigdet_sta_3           (P_PMA_SIGDET_STATUS_3   ),  // output
            .o_p_lx_cdr_align_0            (P_LX_CDR_ALIGN[0]       ),  // output
        //    .o_p_lx_cdr_align_1            (P_LX_CDR_ALIGN_1        ),  // output
        //    .o_p_lx_cdr_align_2            (P_LX_CDR_ALIGN_2        ),  // output
        //    .o_p_lx_cdr_align_3            (P_LX_CDR_ALIGN_3        ),  // output
            .i_p_lx_rxdct_en_0             (P_LX_RXDCT_EN[0]        ),  // input
        //    .i_p_lx_rxdct_en_1             (P_LX_RXDCT_EN[1]        ),  // input
        //    .i_p_lx_rxdct_en_2             (P_LX_RXDCT_EN[2]        ),  // input
        //    .i_p_lx_rxdct_en_3             (P_LX_RXDCT_EN[3]        ),  // input

            .o_p_lx_rxdct_out_0            (P_LX_RXDCT_OUT_0        ),  // output
        //    .o_p_lx_rxdct_out_1            (P_LX_RXDCT_OUT_1        ),  // output
        //    .o_p_lx_rxdct_out_2            (P_LX_RXDCT_OUT_2        ),  // output
        //    .o_p_lx_rxdct_out_3            (P_LX_RXDCT_OUT_3        ),  // output

            .o_p_pcs_lsm_synced_0          (P_PCS_LSM_SYNCED[0]     ),  // output
        //    .o_p_pcs_lsm_synced_1          (P_PCS_LSM_SYNCED[1]     ),  // output
        //    .o_p_pcs_lsm_synced_2          (P_PCS_LSM_SYNCED[2]     ),  // output
        //    .o_p_pcs_lsm_synced_3          (P_PCS_LSM_SYNCED[3]     ),  // output
            .i_p_pcs_nearend_loop_0        (pcs_nearend_loop[0]     ),  // input
            .i_p_pcs_farend_loop_0         (1'd0                    ),  // input
            .i_p_pma_nearend_ploop_0       (pma_nearend_ploop[0]    ),  // input
            .i_p_pma_nearend_sloop_0       (pma_nearend_sloop[0]    ),  // input
            .i_p_pma_farend_ploop_0        (1'd0                    ),  // input
        //    .i_p_pcs_nearend_loop_1        (pcs_nearend_loop[1]     ),  // input
        //    .i_p_pcs_farend_loop_1         (1'd0                    ),  // input
        //    .i_p_pma_nearend_ploop_1       (pma_nearend_ploop[1]    ),  // input
        //    .i_p_pma_nearend_sloop_1       (pma_nearend_sloop[1]    ),  // input
        //    .i_p_pma_farend_ploop_1        (1'd0                    ),  // input
        //    .i_p_pcs_nearend_loop_2        (pcs_nearend_loop[2]     ),  // input
        //    .i_p_pcs_farend_loop_2         (1'd0                    ),  // input
        //    .i_p_pma_nearend_ploop_2       (pma_nearend_ploop[2]    ),  // input
        //    .i_p_pma_nearend_sloop_2       (pma_nearend_sloop[2]    ),  // input
        //    .i_p_pma_farend_ploop_2        (1'd0                    ),  // input
        //    .i_p_pcs_nearend_loop_3        (pcs_nearend_loop[3]     ),  // input
        //    .i_p_pcs_farend_loop_3         (1'd0                    ),  // input
        //    .i_p_pma_nearend_ploop_3       (pma_nearend_ploop[3]    ),  // input
        //    .i_p_pma_nearend_sloop_3       (pma_nearend_sloop[3]    ),  // input
        //    .i_p_pma_farend_ploop_3        (1'd0                    ),  // input
            .i_p_rx_polarity_invert_0      (P_RX_POLARITY_INVERT[0] ),  // input
        //    .i_p_rx_polarity_invert_1      (P_RX_POLARITY_INVERT[1] ),  // input
        //    .i_p_rx_polarity_invert_2      (P_RX_POLARITY_INVERT[2] ),  // input
        //    .i_p_rx_polarity_invert_3      (P_RX_POLARITY_INVERT[3] ),  // input
            .i_p_tx_beacon_en_0            (tx_beacon[0]            ),  // input
        //    .i_p_tx_beacon_en_1            (tx_beacon[1]            ),  // input
        //    .i_p_tx_beacon_en_2            (tx_beacon[2]            ),  // input
        //    .i_p_tx_beacon_en_3            (tx_beacon[3]            ),  // input
            .i_p_cfg_clk                   (P_REFCK2CORE_0          ),  // input
            .i_p_cfg_rst                   (~hsst_apb_rst_n         ),  // input
            .i_p_cfg_psel                  (i_p_cfg_psel            ),  // input
            .i_p_cfg_enable                (i_p_cfg_enable          ),  // input
            .i_p_cfg_write                 (i_p_cfg_write           ),  // input
            .i_p_cfg_addr                  (i_p_cfg_addr            ),  // input  [15:0]
            .i_p_cfg_wdata                 (i_p_cfg_wdata           ),  // input  [7:0]
            .o_p_cfg_rdata                 (o_p_cfg_rdata           ),  // output [7:0]
            .o_p_cfg_int                   (o_p_cfg_int             ),  // output
            .o_p_cfg_ready                 (o_p_cfg_ready           ),  // output
            .i_p_l0rxn                     (P_RXN[0]                ),  // input
            .i_p_l0rxp                     (P_RXP[0]                ),  // input
        //    .i_p_l1rxn                     (P_L1RXN                 ),  // input
        //    .i_p_l1rxp                     (P_L1RXP                 ),  // input
        //    .i_p_l2rxn                     (P_L2RXN                 ),  // input
        //    .i_p_l2rxp                     (P_L2RXP                 ),  // input
        //    .i_p_l3rxn                     (P_L3RXN                 ),  // input
        //    .i_p_l3rxp                     (P_L3RXP                 ),  // input
            .o_p_l0txn                     (P_TXN[0]                 ),  // output
            .o_p_l0txp                     (P_TXP[0]                 ),  // output
        //    .o_p_l1txn                     (P_L1TXN                 ),  // output
        //    .o_p_l1txp                     (P_L1TXP                 ),  // output
        //    .o_p_l2txn                     (P_L2TXN                 ),  // output
        //    .o_p_l2txp                     (P_L2TXP                 ),  // output
        //    .o_p_l3txn                     (P_L3TXN                 ),  // output
        //    .o_p_l3txp                     (P_L3TXP                 ),  // output
            .i_txd_0                       (i_txd_0                 ),  // input  [31:0]
            .i_tdispsel_0                  (i_tdispsel_0            ),  // input  [3:0]
            .i_tdispctrl_0                 (i_tdispctrl_0           ),  // input  [3:0]
            .i_txk_0                       (i_txk_0                 ),  // input  [3:0]
        //    .i_txd_1                       (i_txd_1                 ),  // input  [31:0]
        //    .i_tdispsel_1                  (i_tdispsel_1            ),  // input  [3:0]
        //    .i_tdispctrl_1                 (i_tdispctrl_1           ),  // input  [3:0]
        //    .i_txk_1                       (i_txk_1                 ),  // input  [3:0]
        //    .i_txd_2                       (i_txd_2                 ),  // input  [31:0]
        //    .i_tdispsel_2                  (i_tdispsel_2            ),  // input  [3:0]
        //    .i_tdispctrl_2                 (i_tdispctrl_2           ),  // input  [3:0]
        //    .i_txk_2                       (i_txk_2                 ),  // input  [3:0]
        //    .i_txd_3                       (i_txd_3                 ),  // input  [31:0]
        //    .i_tdispsel_3                  (i_tdispsel_3            ),  // input  [3:0]
        //    .i_tdispctrl_3                 (i_tdispctrl_3           ),  // input  [3:0]
        //    .i_txk_3                       (i_txk_3                 ),  // input  [3:0]
            .o_rxstatus_0                  (o_rxstatus_0            ),  // output [2:0]
            .o_rxd_0                       (o_rxd_0                 ),  // output [31:0]
            .o_rdisper_0                   (o_rdisper_0             ),  // output [3:0]
            .o_rdecer_0                    (o_rdecer_0              ),  // output [3:0]
            .o_rxk_0                       (o_rxk_0                 ),  // output [3:0]
        //    .o_rxstatus_1                  (o_rxstatus_1            ),  // output [2:0]
        //    .o_rxd_1                       (o_rxd_1                 ),  // output [31:0]
        //    .o_rdisper_1                   (o_rdisper_1             ),  // output [3:0]
        //    .o_rdecer_1                    (o_rdecer_1              ),  // output [3:0]
        //    .o_rxk_1                       (o_rxk_1                 ),  // output [3:0]
        //    .o_rxstatus_2                  (o_rxstatus_2            ),  // output [2:0]
        //    .o_rxd_2                       (o_rxd_2                 ),  // output [31:0]
        //    .o_rdisper_2                   (o_rdisper_2             ),  // output [3:0]
        //    .o_rdecer_2                    (o_rdecer_2              ),  // output [3:0]
        //    .o_rxk_2                       (o_rxk_2                 ),  // output [3:0]
        //    .o_rxstatus_3                  (o_rxstatus_3            ),  // output [2:0]
        //    .o_rxd_3                       (o_rxd_3                 ),  // output [31:0]
        //    .o_rdisper_3                   (o_rdisper_3             ),  // output [3:0]
        //    .o_rdecer_3                    (o_rdecer_3              ),  // output [3:0]
        //    .o_rxk_3                       (o_rxk_3                 ),  // output [3:0]
            .i_p_pllpowerdown_0            (P_PLLPOWERDOWN_0        )   // input
        );
    end
    else if (HSST_LANE_NUM == 2)
    begin:x2
        wire [31:0] i_txd_0;
        wire [31:0] i_txd_1;
        //wire [31:0] i_txd_2;
        //wire [31:0] i_txd_3;

        assign i_txd_0 = {P_TDATA_0[40:33],P_TDATA_0[29:22],P_TDATA_0[18:11],P_TDATA_0[7:0]};
        assign i_txd_1 = {P_TDATA_1[40:33],P_TDATA_1[29:22],P_TDATA_1[18:11],P_TDATA_1[7:0]};
        //assign i_txd_2 = {P_TDATA_2[40:33],P_TDATA_2[29:22],P_TDATA_2[18:11],P_TDATA_2[7:0]};
        //assign i_txd_3 = {P_TDATA_3[40:33],P_TDATA_3[29:22],P_TDATA_3[18:11],P_TDATA_3[7:0]};

        wire  [1:0]   i_p_lx_elecidle_en_0;
        wire  [1:0]   i_p_lx_elecidle_en_1;
        //wire  [1:0]   i_p_lx_elecidle_en_2;
        //wire  [1:0]   i_p_lx_elecidle_en_3;

        assign i_p_lx_elecidle_en_0 = P_TDATA_0[45:44];
        assign i_p_lx_elecidle_en_1 = P_TDATA_1[45:44];
        //assign i_p_lx_elecidle_en_2 = P_TDATA_2[45:44];
        //assign i_p_lx_elecidle_en_3 = P_TDATA_3[45:44];

        wire    [3:0]   i_txk_0;
        wire    [3:0]   i_txk_1;
        //wire    [3:0]   i_txk_2;
        //wire    [3:0]   i_txk_3;

        assign i_txk_0 = {P_TDATA_0[43],P_TDATA_0[32],P_TDATA_0[21],P_TDATA_0[10]};
        assign i_txk_1 = {P_TDATA_1[43],P_TDATA_1[32],P_TDATA_1[21],P_TDATA_1[10]};
        //assign i_txk_2 = {P_TDATA_2[43],P_TDATA_2[32],P_TDATA_2[21],P_TDATA_2[10]};
        //assign i_txk_3 = {P_TDATA_3[43],P_TDATA_3[32],P_TDATA_3[21],P_TDATA_3[10]};

        wire    [3:0]   i_tdispsel_0;
        wire    [3:0]   i_tdispsel_1;
        //wire    [3:0]   i_tdispsel_2;
        //wire    [3:0]   i_tdispsel_3;
        wire    [3:0]   i_tdispctrl_0;
        wire    [3:0]   i_tdispctrl_1;
        //wire    [3:0]   i_tdispctrl_2;
        //wire    [3:0]   i_tdispctrl_3;

        assign i_tdispsel_0 = {P_TDATA_0[41],P_TDATA_0[30],P_TDATA_0[19],P_TDATA_0[8]};
        assign i_tdispsel_1 = {P_TDATA_1[41],P_TDATA_1[30],P_TDATA_1[19],P_TDATA_1[8]};
        //assign i_tdispsel_2 = {P_TDATA_2[41],P_TDATA_2[30],P_TDATA_2[19],P_TDATA_2[8]};
        //assign i_tdispsel_3 = {P_TDATA_3[41],P_TDATA_3[30],P_TDATA_3[19],P_TDATA_3[8]};

        assign i_tdispctrl_0 = {P_TDATA_0[42],P_TDATA_0[31],P_TDATA_0[20],P_TDATA_0[9]};
        assign i_tdispctrl_1 = {P_TDATA_1[42],P_TDATA_1[31],P_TDATA_1[20],P_TDATA_1[9]};
        //assign i_tdispctrl_2 = {P_TDATA_2[42],P_TDATA_2[31],P_TDATA_2[20],P_TDATA_2[9]};
        //assign i_tdispctrl_3 = {P_TDATA_3[42],P_TDATA_3[31],P_TDATA_3[20],P_TDATA_3[9]};


        wire [ 2:0] o_rxstatus_0;
        wire [31:0] o_rxd_0;
        wire [ 3:0] o_rdisper_0;
        wire [ 3:0] o_rdecer_0;
        wire [ 3:0] o_rxk_0;

        wire [ 2:0] o_rxstatus_1;
        wire [31:0] o_rxd_1;
        wire [ 3:0] o_rdisper_1;
        wire [ 3:0] o_rdecer_1;
        wire [ 3:0] o_rxk_1;

        //wire [ 2:0] o_rxstatus_2;
        //wire [31:0] o_rxd_2;
        //wire [ 3:0] o_rdisper_2;
        //wire [ 3:0] o_rdecer_2;
        //wire [ 3:0] o_rxk_2;
        //
        //wire [ 2:0] o_rxstatus_3;
        //wire [31:0] o_rxd_3;
        //wire [ 3:0] o_rdisper_3;
        //wire [ 3:0] o_rdecer_3;
        //wire [ 3:0] o_rxk_3;

        // 8b10b-32bits
        assign P_RDATA_0 = {o_rxstatus_0, o_rxk_0[3], o_rdecer_0[3], o_rdisper_0[3], o_rxd_0[31:24], o_rxk_0[2], o_rdecer_0[2], o_rdisper_0[2], o_rxd_0[23:16], o_rxk_0[1], o_rdecer_0[1], o_rdisper_0[1], o_rxd_0[15:8], o_rxk_0[0], o_rdecer_0[0], o_rdisper_0[0], o_rxd_0[7:0]};
        assign P_RDATA_1 = {o_rxstatus_1, o_rxk_1[3], o_rdecer_1[3], o_rdisper_1[3], o_rxd_1[31:24], o_rxk_1[2], o_rdecer_1[2], o_rdisper_1[2], o_rxd_1[23:16], o_rxk_1[1], o_rdecer_1[1], o_rdisper_1[1], o_rxd_1[15:8], o_rxk_1[0], o_rdecer_1[0], o_rdisper_1[0], o_rxd_1[7:0]};
        //assign P_RDATA_2 = {o_rxstatus_2, o_rxk_2[3], o_rdecer_2[3], o_rdisper_2[3], o_rxd_2[31:24], o_rxk_2[2], o_rdecer_2[2], o_rdisper_2[2], o_rxd_2[23:16], o_rxk_2[1], o_rdecer_2[1], o_rdisper_2[1], o_rxd_2[15:8], o_rxk_2[0], o_rdecer_2[0], o_rdisper_2[0], o_rxd_2[7:0]};
        //assign P_RDATA_3 = {o_rxstatus_3, o_rxk_3[3], o_rdecer_3[3], o_rdisper_3[3], o_rxd_3[31:24], o_rxk_3[2], o_rdecer_3[2], o_rdisper_3[2], o_rxd_3[23:16], o_rxk_3[1], o_rdecer_3[1], o_rdisper_3[1], o_rxd_3[15:8], o_rxk_3[0], o_rdecer_3[0], o_rdisper_3[0], o_rxd_3[7:0]};

        `ifdef IPSL_PCIE_SPEEDUP_SIM
            initial
            $display("hsst_x2 MODE!");
        `endif

        ipml_pcie_hsst_x2_top u_pcie_hsst (
        //    .free_clk                      (free_clk                ),

            .i_p_refckn_1                  (P_REFCKN                ),  // input
            .i_p_refckp_1                  (P_REFCKP                ),  // input

            .i_p_tx_lane_pd_0              (P_PMA_TX_PD[0]          ),  // input
            .i_p_tx_lane_pd_1              (P_PMA_TX_PD[1]          ),  // input
        //    .i_p_tx_lane_pd_2              (P_PMA_TX_PD[2]          ),  // input
        //    .i_p_tx_lane_pd_3              (P_PMA_TX_PD[3]          ),  // input
            .i_p_lane_pd_0                 (P_PMA_LANE_PD[0]        ),  // input
            .i_p_lane_pd_1                 (P_PMA_LANE_PD[1]        ),  // input
        //    .i_p_lane_pd_2                 (P_PMA_LANE_PD[2]        ),  // input
        //    .i_p_lane_pd_3                 (P_PMA_LANE_PD[3]        ),  // input
            .i_p_lane_rst_0                (P_PMA_LANE_RST[0]       ),  // input
            .i_p_lane_rst_1                (P_PMA_LANE_RST[1]       ),  // input
        //    .i_p_lane_rst_2                (P_PMA_LANE_RST[2]       ),  // input
        //    .i_p_lane_rst_3                (P_PMA_LANE_RST[3]       ),  // input
            .i_p_rx_lane_pd_0              (P_PMA_RX_PD[0]          ),  // input
            .i_p_rx_lane_pd_1              (P_PMA_RX_PD[1]          ),  // input
        //    .i_p_rx_lane_pd_2              (P_PMA_RX_PD[2]          ),  // input
        //    .i_p_rx_lane_pd_3              (P_PMA_RX_PD[3]          ),  // input
            .o_p_clk2core_tx_0             (TCLK2FABRIC[0]          ),  // output
            .i_p_tx0_clk_fr_core           (pclk_div2               ),  // input
            .i_p_tx1_clk_fr_core           (pclk_div2               ),  // input
        //    .i_p_tx2_clk_fr_core           (pclk_div2               ),  // input
        //    .i_p_tx3_clk_fr_core           (pclk_div2               ),  // input
            .i_p_tx0_clk2_fr_core          (pclk                    ),  // input
            .i_p_tx1_clk2_fr_core          (pclk                    ),  // input
        //    .i_p_tx2_clk2_fr_core          (pclk                    ),  // input
        //    .i_p_tx3_clk2_fr_core          (pclk                    ),  // input
        //    .i_pll_lock_tx_0               (1'b1                    ),
        //    .i_pll_lock_tx_1               (1'b1                    ),
        //    .i_pll_lock_tx_2               (1'b1                    ),
        //    .i_pll_lock_tx_3               (1'b1                    ),
            .o_p_clk2core_rx_0             (RCLK2FABRIC[0]          ),
            .i_p_rx0_clk_fr_core           (pclk_div2               ),  // input
            .i_p_rx1_clk_fr_core           (pclk_div2               ),  // input
        //    .i_p_rx2_clk_fr_core           (pclk_div2               ),  // input
        //    .i_p_rx3_clk_fr_core           (pclk_div2               ),  // input
            .i_p_rx0_clk2_fr_core          (pclk                    ),  // input
            .i_p_rx1_clk2_fr_core          (pclk                    ),  // input
        //    .i_p_rx2_clk2_fr_core          (pclk                    ),  // input
        //    .i_p_rx3_clk2_fr_core          (pclk                    ),  // input
        //    .o_p_refck2core_0              (P_REFCK2CORE_0          ),  // output
            .i_p_pll_rst_0                 (P_PLL_RST_0             ),  // input
            .i_p_tx_pma_rst_0              (P_PMA_TX_RST_0          ),  // input
            .i_p_tx_pma_rst_1              (P_PMA_TX_RST_1          ),  // input
        //    .i_p_tx_pma_rst_2              (P_PMA_TX_RST_2          ),  // input
        //    .i_p_tx_pma_rst_3              (P_PMA_TX_RST_3          ),  // input
            .i_p_pcs_tx_rst_0              (P_PCS_TX_RST_0          ),  // input
            .i_p_pcs_tx_rst_1              (P_PCS_TX_RST_1          ),  // input
        //    .i_p_pcs_tx_rst_2              (P_PCS_TX_RST_2          ),  // input
        //    .i_p_pcs_tx_rst_3              (P_PCS_TX_RST_3          ),  // input
            .i_p_rx_pma_rst_0              (P_PMA_RX_RST_0          ),  // input
            .i_p_rx_pma_rst_1              (P_PMA_RX_RST_1          ),  // input
        //    .i_p_rx_pma_rst_2              (P_PMA_RX_RST_2          ),  // input
        //    .i_p_rx_pma_rst_3              (P_PMA_RX_RST_3          ),  // input
            .i_p_pcs_rx_rst_0              (P_PCS_RX_RST_0          ),  // input
            .i_p_pcs_rx_rst_1              (P_PCS_RX_RST_1          ),  // input
        //    .i_p_pcs_rx_rst_2              (P_PCS_RX_RST_2          ),  // input
        //    .i_p_pcs_rx_rst_3              (P_PCS_RX_RST_3          ),  // input
            .i_p_pcs_cb_rst_0              (P_PCS_CB_RST[0]         ),  // input
            .i_p_pcs_cb_rst_1              (P_PCS_CB_RST[1]         ),  // input
        //    .i_p_pcs_cb_rst_2              (P_PCS_CB_RST[2]         ),  // input
        //    .i_p_pcs_cb_rst_3              (P_PCS_CB_RST[3]         ),  // input
            .i_p_lx_margin_ctl_0           (mac_phy_txmargin        ),  // input  [2:0]
            .i_p_lx_margin_ctl_1           (mac_phy_txmargin        ),  // input  [2:0]
        //    .i_p_lx_margin_ctl_2           (mac_phy_txmargin        ),  // input  [2:0]
        //    .i_p_lx_margin_ctl_3           (mac_phy_txmargin        ),  // input  [2:0]
            .i_p_lx_swing_ctl_0            (mac_phy_txswing         ),  // input
            .i_p_lx_swing_ctl_1            (mac_phy_txswing         ),  // input
        //    .i_p_lx_swing_ctl_2            (mac_phy_txswing         ),  // input
        //    .i_p_lx_swing_ctl_3            (mac_phy_txswing         ),  // input

            // Lane de-emphasis default 3.5dB
            // 2'b00 -> 3.5dB
            // 2'b01 -> 6dB
            .i_p_lx_deemp_ctl_0            (P_LX_DEEMP_CTL_0        ), // input [1:0]
            .i_p_lx_deemp_ctl_1            (P_LX_DEEMP_CTL_1        ), // input [1:0]
        //    .i_p_lx_deemp_ctl_2            (P_LX_DEEMP_CTL_2        ), // input [1:0]
        //    .i_p_lx_deemp_ctl_3            (P_LX_DEEMP_CTL_3        ), // input [1:0]

            .i_p_lane_sync_0               (P_LANE_SYNC_0           ),  // input
            .i_p_lane_sync_en_0            (P_LANE_SYNC_EN_0        ),
            .i_p_rate_change_tclk_on_0     (P_RATE_CHG_TXPCLK_ON_0  ),  // input
            .i_p_tx_ckdiv_0                (P_PMA_TX_RATE_0[1:0]    ),  // input  [1:0]
            .i_p_tx_ckdiv_1                (P_PMA_TX_RATE_1[1:0]    ),  // input  [1:0]
        //    .i_p_tx_ckdiv_2                (P_PMA_TX_RATE_2[1:0]    ),  // input  [1:0]
        //    .i_p_tx_ckdiv_3                (P_PMA_TX_RATE_3[1:0]    ),  // input  [1:0]
            .i_p_lx_rx_ckdiv_0             (P_PMA_TX_RATE_0[1:0]    ),
            .i_p_lx_rx_ckdiv_1             (P_PMA_TX_RATE_1[1:0]    ),
        //    .i_p_lx_rx_ckdiv_2             (P_PMA_TX_RATE_2[1:0]    ),
        //    .i_p_lx_rx_ckdiv_3             (P_PMA_TX_RATE_3[1:0]    ),
            .i_p_lx_elecidle_en_0          (i_p_lx_elecidle_en_0    ),  // input  [1:0]
            .i_p_lx_elecidle_en_1          (i_p_lx_elecidle_en_1    ),  // input  [1:0]
        //    .i_p_lx_elecidle_en_2          (i_p_lx_elecidle_en_2    ),  // input  [1:0]
        //    .i_p_lx_elecidle_en_3          (i_p_lx_elecidle_en_3    ),  // input  [1:0]
            .o_p_pll_lock_0                (P_PLL_READY_0           ),  // output
            .o_p_rx_sigdet_sta_0           (P_PMA_SIGDET_STATUS[0]  ),  // output
            .o_p_rx_sigdet_sta_1           (P_PMA_SIGDET_STATUS[1]  ),  // output
        //    .o_p_rx_sigdet_sta_2           (P_PMA_SIGDET_STATUS_2   ),  // output
        //    .o_p_rx_sigdet_sta_3           (P_PMA_SIGDET_STATUS_3   ),  // output
            .o_p_lx_cdr_align_0            (P_LX_CDR_ALIGN[0]       ),  // output
            .o_p_lx_cdr_align_1            (P_LX_CDR_ALIGN[1]       ),  // output
        //    .o_p_lx_cdr_align_2            (P_LX_CDR_ALIGN_2        ),  // output
        //    .o_p_lx_cdr_align_3            (P_LX_CDR_ALIGN_3        ),  // output
            .i_p_lx_rxdct_en_0             (P_LX_RXDCT_EN[0]        ),  // input
            .i_p_lx_rxdct_en_1             (P_LX_RXDCT_EN[1]        ),  // input
        //    .i_p_lx_rxdct_en_2             (P_LX_RXDCT_EN[2]        ),  // input
        //    .i_p_lx_rxdct_en_3             (P_LX_RXDCT_EN[3]        ),  // input

            .o_p_lx_rxdct_out_0            (P_LX_RXDCT_OUT_0        ),  // output
            .o_p_lx_rxdct_out_1            (P_LX_RXDCT_OUT_1        ),  // output
        //    .o_p_lx_rxdct_out_2            (P_LX_RXDCT_OUT_2        ),  // output
        //    .o_p_lx_rxdct_out_3            (P_LX_RXDCT_OUT_3        ),  // output

            .o_p_pcs_lsm_synced_0          (P_PCS_LSM_SYNCED[0]     ),  // output
            .o_p_pcs_lsm_synced_1          (P_PCS_LSM_SYNCED[1]     ),  // output
        //    .o_p_pcs_lsm_synced_2          (P_PCS_LSM_SYNCED[2]     ),  // output
        //    .o_p_pcs_lsm_synced_3          (P_PCS_LSM_SYNCED[3]     ),  // output
            .i_p_pcs_nearend_loop_0        (pcs_nearend_loop[0]     ),  // input
            .i_p_pcs_farend_loop_0         (1'd0                    ),  // input
            .i_p_pma_nearend_ploop_0       (pma_nearend_ploop[0]    ),  // input
            .i_p_pma_nearend_sloop_0       (pma_nearend_sloop[0]    ),  // input
            .i_p_pma_farend_ploop_0        (1'd0                    ),  // input
            .i_p_pcs_nearend_loop_1        (pcs_nearend_loop[1]     ),  // input
            .i_p_pcs_farend_loop_1         (1'd0                    ),  // input
            .i_p_pma_nearend_ploop_1       (pma_nearend_ploop[1]    ),  // input
            .i_p_pma_nearend_sloop_1       (pma_nearend_sloop[1]    ),  // input
            .i_p_pma_farend_ploop_1        (1'd0                    ),  // input
        //    .i_p_pcs_nearend_loop_2        (pcs_nearend_loop[2]     ),  // input
        //    .i_p_pcs_farend_loop_2         (1'd0                    ),  // input
        //    .i_p_pma_nearend_ploop_2       (pma_nearend_ploop[2]    ),  // input
        //    .i_p_pma_nearend_sloop_2       (pma_nearend_sloop[2]    ),  // input
        //    .i_p_pma_farend_ploop_2        (1'd0                    ),  // input
        //    .i_p_pcs_nearend_loop_3        (pcs_nearend_loop[3]     ),  // input
        //    .i_p_pcs_farend_loop_3         (1'd0                    ),  // input
        //    .i_p_pma_nearend_ploop_3       (pma_nearend_ploop[3]    ),  // input
        //    .i_p_pma_nearend_sloop_3       (pma_nearend_sloop[3]    ),  // input
        //    .i_p_pma_farend_ploop_3        (1'd0                    ),  // input
            .i_p_rx_polarity_invert_0      (P_RX_POLARITY_INVERT[0] ),  // input
            .i_p_rx_polarity_invert_1      (P_RX_POLARITY_INVERT[1] ),  // input
        //    .i_p_rx_polarity_invert_2      (P_RX_POLARITY_INVERT[2] ),  // input
        //    .i_p_rx_polarity_invert_3      (P_RX_POLARITY_INVERT[3] ),  // input
            .i_p_tx_beacon_en_0            (tx_beacon[0]            ),  // input
            .i_p_tx_beacon_en_1            (tx_beacon[1]            ),  // input
        //    .i_p_tx_beacon_en_2            (tx_beacon[2]            ),  // input
        //    .i_p_tx_beacon_en_3            (tx_beacon[3]            ),  // input
            .i_p_cfg_clk                   (P_REFCK2CORE_0          ),  // input
            .i_p_cfg_rst                   (~hsst_apb_rst_n         ),  // input
            .i_p_cfg_psel                  (i_p_cfg_psel            ),  // input
            .i_p_cfg_enable                (i_p_cfg_enable          ),  // input
            .i_p_cfg_write                 (i_p_cfg_write           ),  // input
            .i_p_cfg_addr                  (i_p_cfg_addr            ),  // input  [15:0]
            .i_p_cfg_wdata                 (i_p_cfg_wdata           ),  // input  [7:0]
            .o_p_cfg_rdata                 (o_p_cfg_rdata           ),  // output [7:0]
            .o_p_cfg_int                   (o_p_cfg_int             ),  // output
            .o_p_cfg_ready                 (o_p_cfg_ready           ),  // output
            .i_p_l0rxn                     (P_RXN[0]                ),  // input
            .i_p_l0rxp                     (P_RXP[0]                ),  // input
            .i_p_l1rxn                     (P_RXN[1]                ),  // input
            .i_p_l1rxp                     (P_RXP[1]                ),  // input
        //    .i_p_l2rxn                     (P_L2RXN                 ),  // input
        //    .i_p_l2rxp                     (P_L2RXP                 ),  // input
        //    .i_p_l3rxn                     (P_L3RXN                 ),  // input
        //    .i_p_l3rxp                     (P_L3RXP                 ),  // input
            .o_p_l0txn                     (P_TXN[0]                ),  // output
            .o_p_l0txp                     (P_TXP[0]                ),  // output
            .o_p_l1txn                     (P_TXN[1]                ),  // output
            .o_p_l1txp                     (P_TXP[1]                ),  // output
        //    .o_p_l2txn                     (P_L2TXN                 ),  // output
        //    .o_p_l2txp                     (P_L2TXP                 ),  // output
        //    .o_p_l3txn                     (P_L3TXN                 ),  // output
        //    .o_p_l3txp                     (P_L3TXP                 ),  // output
            .i_txd_0                       (i_txd_0                 ),  // input  [31:0]
            .i_tdispsel_0                  (i_tdispsel_0            ),  // input  [3:0]
            .i_tdispctrl_0                 (i_tdispctrl_0           ),  // input  [3:0]
            .i_txk_0                       (i_txk_0                 ),  // input  [3:0]
            .i_txd_1                       (i_txd_1                 ),  // input  [31:0]
            .i_tdispsel_1                  (i_tdispsel_1            ),  // input  [3:0]
            .i_tdispctrl_1                 (i_tdispctrl_1           ),  // input  [3:0]
            .i_txk_1                       (i_txk_1                 ),  // input  [3:0]
        //    .i_txd_2                       (i_txd_2                 ),  // input  [31:0]
        //    .i_tdispsel_2                  (i_tdispsel_2            ),  // input  [3:0]
        //    .i_tdispctrl_2                 (i_tdispctrl_2           ),  // input  [3:0]
        //    .i_txk_2                       (i_txk_2                 ),  // input  [3:0]
        //    .i_txd_3                       (i_txd_3                 ),  // input  [31:0]
        //    .i_tdispsel_3                  (i_tdispsel_3            ),  // input  [3:0]
        //    .i_tdispctrl_3                 (i_tdispctrl_3           ),  // input  [3:0]
        //    .i_txk_3                       (i_txk_3                 ),  // input  [3:0]
            .o_rxstatus_0                  (o_rxstatus_0            ),  // output [2:0]
            .o_rxd_0                       (o_rxd_0                 ),  // output [31:0]
            .o_rdisper_0                   (o_rdisper_0             ),  // output [3:0]
            .o_rdecer_0                    (o_rdecer_0              ),  // output [3:0]
            .o_rxk_0                       (o_rxk_0                 ),  // output [3:0]
            .o_rxstatus_1                  (o_rxstatus_1            ),  // output [2:0]
            .o_rxd_1                       (o_rxd_1                 ),  // output [31:0]
            .o_rdisper_1                   (o_rdisper_1             ),  // output [3:0]
            .o_rdecer_1                    (o_rdecer_1              ),  // output [3:0]
            .o_rxk_1                       (o_rxk_1                 ),  // output [3:0]
        //    .o_rxstatus_2                  (o_rxstatus_2            ),  // output [2:0]
        //    .o_rxd_2                       (o_rxd_2                 ),  // output [31:0]
        //    .o_rdisper_2                   (o_rdisper_2             ),  // output [3:0]
        //    .o_rdecer_2                    (o_rdecer_2              ),  // output [3:0]
        //    .o_rxk_2                       (o_rxk_2                 ),  // output [3:0]
        //    .o_rxstatus_3                  (o_rxstatus_3            ),  // output [2:0]
        //    .o_rxd_3                       (o_rxd_3                 ),  // output [31:0]
        //    .o_rdisper_3                   (o_rdisper_3             ),  // output [3:0]
        //    .o_rdecer_3                    (o_rdecer_3              ),  // output [3:0]
        //    .o_rxk_3                       (o_rxk_3                 ),  // output [3:0]
            .i_p_pllpowerdown_0            (P_PLLPOWERDOWN_0        )   // input
        );
    end
    else
    begin:x4
        wire [31:0] i_txd_0;
        wire [31:0] i_txd_1;
        wire [31:0] i_txd_2;
        wire [31:0] i_txd_3;

        assign i_txd_0 = {P_TDATA_0[40:33],P_TDATA_0[29:22],P_TDATA_0[18:11],P_TDATA_0[7:0]};
        assign i_txd_1 = {P_TDATA_1[40:33],P_TDATA_1[29:22],P_TDATA_1[18:11],P_TDATA_1[7:0]};
        assign i_txd_2 = {P_TDATA_2[40:33],P_TDATA_2[29:22],P_TDATA_2[18:11],P_TDATA_2[7:0]};
        assign i_txd_3 = {P_TDATA_3[40:33],P_TDATA_3[29:22],P_TDATA_3[18:11],P_TDATA_3[7:0]};

        wire  [1:0]   i_p_lx_elecidle_en_0;
        wire  [1:0]   i_p_lx_elecidle_en_1;
        wire  [1:0]   i_p_lx_elecidle_en_2;
        wire  [1:0]   i_p_lx_elecidle_en_3;

        assign i_p_lx_elecidle_en_0 = P_TDATA_0[45:44];
        assign i_p_lx_elecidle_en_1 = P_TDATA_1[45:44];
        assign i_p_lx_elecidle_en_2 = P_TDATA_2[45:44];
        assign i_p_lx_elecidle_en_3 = P_TDATA_3[45:44];

        wire    [3:0]   i_txk_0;
        wire    [3:0]   i_txk_1;
        wire    [3:0]   i_txk_2;
        wire    [3:0]   i_txk_3;

        assign i_txk_0 = {P_TDATA_0[43],P_TDATA_0[32],P_TDATA_0[21],P_TDATA_0[10]};
        assign i_txk_1 = {P_TDATA_1[43],P_TDATA_1[32],P_TDATA_1[21],P_TDATA_1[10]};
        assign i_txk_2 = {P_TDATA_2[43],P_TDATA_2[32],P_TDATA_2[21],P_TDATA_2[10]};
        assign i_txk_3 = {P_TDATA_3[43],P_TDATA_3[32],P_TDATA_3[21],P_TDATA_3[10]};

        wire    [3:0]   i_tdispsel_0;
        wire    [3:0]   i_tdispsel_1;
        wire    [3:0]   i_tdispsel_2;
        wire    [3:0]   i_tdispsel_3;
        wire    [3:0]   i_tdispctrl_0;
        wire    [3:0]   i_tdispctrl_1;
        wire    [3:0]   i_tdispctrl_2;
        wire    [3:0]   i_tdispctrl_3;

        assign i_tdispsel_0 = {P_TDATA_0[41],P_TDATA_0[30],P_TDATA_0[19],P_TDATA_0[8]};
        assign i_tdispsel_1 = {P_TDATA_1[41],P_TDATA_1[30],P_TDATA_1[19],P_TDATA_1[8]};
        assign i_tdispsel_2 = {P_TDATA_2[41],P_TDATA_2[30],P_TDATA_2[19],P_TDATA_2[8]};
        assign i_tdispsel_3 = {P_TDATA_3[41],P_TDATA_3[30],P_TDATA_3[19],P_TDATA_3[8]};

        assign i_tdispctrl_0 = {P_TDATA_0[42],P_TDATA_0[31],P_TDATA_0[20],P_TDATA_0[9]};
        assign i_tdispctrl_1 = {P_TDATA_1[42],P_TDATA_1[31],P_TDATA_1[20],P_TDATA_1[9]};
        assign i_tdispctrl_2 = {P_TDATA_2[42],P_TDATA_2[31],P_TDATA_2[20],P_TDATA_2[9]};
        assign i_tdispctrl_3 = {P_TDATA_3[42],P_TDATA_3[31],P_TDATA_3[20],P_TDATA_3[9]};


        wire [ 2:0] o_rxstatus_0;
        wire [31:0] o_rxd_0;
        wire [ 3:0] o_rdisper_0;
        wire [ 3:0] o_rdecer_0;
        wire [ 3:0] o_rxk_0;

        wire [ 2:0] o_rxstatus_1;
        wire [31:0] o_rxd_1;
        wire [ 3:0] o_rdisper_1;
        wire [ 3:0] o_rdecer_1;
        wire [ 3:0] o_rxk_1;

        wire [ 2:0] o_rxstatus_2;
        wire [31:0] o_rxd_2;
        wire [ 3:0] o_rdisper_2;
        wire [ 3:0] o_rdecer_2;
        wire [ 3:0] o_rxk_2;

        wire [ 2:0] o_rxstatus_3;
        wire [31:0] o_rxd_3;
        wire [ 3:0] o_rdisper_3;
        wire [ 3:0] o_rdecer_3;
        wire [ 3:0] o_rxk_3;

        // 8b10b-32bits
        assign P_RDATA_0 = {o_rxstatus_0, o_rxk_0[3], o_rdecer_0[3], o_rdisper_0[3], o_rxd_0[31:24], o_rxk_0[2], o_rdecer_0[2], o_rdisper_0[2], o_rxd_0[23:16], o_rxk_0[1], o_rdecer_0[1], o_rdisper_0[1], o_rxd_0[15:8], o_rxk_0[0], o_rdecer_0[0], o_rdisper_0[0], o_rxd_0[7:0]};
        assign P_RDATA_1 = {o_rxstatus_1, o_rxk_1[3], o_rdecer_1[3], o_rdisper_1[3], o_rxd_1[31:24], o_rxk_1[2], o_rdecer_1[2], o_rdisper_1[2], o_rxd_1[23:16], o_rxk_1[1], o_rdecer_1[1], o_rdisper_1[1], o_rxd_1[15:8], o_rxk_1[0], o_rdecer_1[0], o_rdisper_1[0], o_rxd_1[7:0]};
        assign P_RDATA_2 = {o_rxstatus_2, o_rxk_2[3], o_rdecer_2[3], o_rdisper_2[3], o_rxd_2[31:24], o_rxk_2[2], o_rdecer_2[2], o_rdisper_2[2], o_rxd_2[23:16], o_rxk_2[1], o_rdecer_2[1], o_rdisper_2[1], o_rxd_2[15:8], o_rxk_2[0], o_rdecer_2[0], o_rdisper_2[0], o_rxd_2[7:0]};
        assign P_RDATA_3 = {o_rxstatus_3, o_rxk_3[3], o_rdecer_3[3], o_rdisper_3[3], o_rxd_3[31:24], o_rxk_3[2], o_rdecer_3[2], o_rdisper_3[2], o_rxd_3[23:16], o_rxk_3[1], o_rdecer_3[1], o_rdisper_3[1], o_rxd_3[15:8], o_rxk_3[0], o_rdecer_3[0], o_rdisper_3[0], o_rxd_3[7:0]};

        `ifdef IPSL_PCIE_SPEEDUP_SIM
            initial
            $display("hsst_x4 MODE!");
        `endif

        ipml_pcie_hsst_x4_top u_pcie_hsst (
        //    .free_clk                      (free_clk                ),

            .i_p_refckn_1                  (P_REFCKN                ),  // input
            .i_p_refckp_1                  (P_REFCKP                ),  // input

            .i_p_tx_lane_pd_0              (P_PMA_TX_PD[0]          ),  // input
            .i_p_tx_lane_pd_1              (P_PMA_TX_PD[1]          ),  // input
            .i_p_tx_lane_pd_2              (P_PMA_TX_PD[2]          ),  // input
            .i_p_tx_lane_pd_3              (P_PMA_TX_PD[3]          ),  // input
            .i_p_lane_pd_0                 (P_PMA_LANE_PD[0]        ),  // input
            .i_p_lane_pd_1                 (P_PMA_LANE_PD[1]        ),  // input
            .i_p_lane_pd_2                 (P_PMA_LANE_PD[2]        ),  // input
            .i_p_lane_pd_3                 (P_PMA_LANE_PD[3]        ),  // input
            .i_p_lane_rst_0                (P_PMA_LANE_RST[0]       ),  // input
            .i_p_lane_rst_1                (P_PMA_LANE_RST[1]       ),  // input
            .i_p_lane_rst_2                (P_PMA_LANE_RST[2]       ),  // input
            .i_p_lane_rst_3                (P_PMA_LANE_RST[3]       ),  // input
            .i_p_rx_lane_pd_0              (P_PMA_RX_PD[0]          ),  // input
            .i_p_rx_lane_pd_1              (P_PMA_RX_PD[1]          ),  // input
            .i_p_rx_lane_pd_2              (P_PMA_RX_PD[2]          ),  // input
            .i_p_rx_lane_pd_3              (P_PMA_RX_PD[3]          ),  // input
            .o_p_clk2core_tx_0             (TCLK2FABRIC[0]          ),  // output
            .i_p_tx0_clk_fr_core           (pclk_div2               ),  // input
            .i_p_tx1_clk_fr_core           (pclk_div2               ),  // input
            .i_p_tx2_clk_fr_core           (pclk_div2               ),  // input
            .i_p_tx3_clk_fr_core           (pclk_div2               ),  // input
            .i_p_tx0_clk2_fr_core          (pclk                    ),  // input
            .i_p_tx1_clk2_fr_core          (pclk                    ),  // input
            .i_p_tx2_clk2_fr_core          (pclk                    ),  // input
            .i_p_tx3_clk2_fr_core          (pclk                    ),  // input
        //    .i_pll_lock_tx_0               (1'b1                    ),
        //    .i_pll_lock_tx_1               (1'b1                    ),
        //    .i_pll_lock_tx_2               (1'b1                    ),
        //    .i_pll_lock_tx_3               (1'b1                    ),
            .o_p_clk2core_rx_0             (RCLK2FABRIC[0]          ),
            .i_p_rx0_clk_fr_core           (pclk_div2               ),  // input
            .i_p_rx1_clk_fr_core           (pclk_div2               ),  // input
            .i_p_rx2_clk_fr_core           (pclk_div2               ),  // input
            .i_p_rx3_clk_fr_core           (pclk_div2               ),  // input
            .i_p_rx0_clk2_fr_core          (pclk                    ),  // input
            .i_p_rx1_clk2_fr_core          (pclk                    ),  // input
            .i_p_rx2_clk2_fr_core          (pclk                    ),  // input
            .i_p_rx3_clk2_fr_core          (pclk                    ),  // input
        //    .o_p_refck2core_0              (P_REFCK2CORE_0          ),  // output
            .i_p_pll_rst_0                 (P_PLL_RST_0             ),  // input
            .i_p_tx_pma_rst_0              (P_PMA_TX_RST_0          ),  // input
            .i_p_tx_pma_rst_1              (P_PMA_TX_RST_1          ),  // input
            .i_p_tx_pma_rst_2              (P_PMA_TX_RST_2          ),  // input
            .i_p_tx_pma_rst_3              (P_PMA_TX_RST_3          ),  // input
            .i_p_pcs_tx_rst_0              (P_PCS_TX_RST_0          ),  // input
            .i_p_pcs_tx_rst_1              (P_PCS_TX_RST_1          ),  // input
            .i_p_pcs_tx_rst_2              (P_PCS_TX_RST_2          ),  // input
            .i_p_pcs_tx_rst_3              (P_PCS_TX_RST_3          ),  // input
            .i_p_rx_pma_rst_0              (P_PMA_RX_RST_0          ),  // input
            .i_p_rx_pma_rst_1              (P_PMA_RX_RST_1          ),  // input
            .i_p_rx_pma_rst_2              (P_PMA_RX_RST_2          ),  // input
            .i_p_rx_pma_rst_3              (P_PMA_RX_RST_3          ),  // input
            .i_p_pcs_rx_rst_0              (P_PCS_RX_RST_0          ),  // input
            .i_p_pcs_rx_rst_1              (P_PCS_RX_RST_1          ),  // input
            .i_p_pcs_rx_rst_2              (P_PCS_RX_RST_2          ),  // input
            .i_p_pcs_rx_rst_3              (P_PCS_RX_RST_3          ),  // input
            .i_p_pcs_cb_rst_0              (P_PCS_CB_RST[0]         ),  // input
            .i_p_pcs_cb_rst_1              (P_PCS_CB_RST[1]         ),  // input
            .i_p_pcs_cb_rst_2              (P_PCS_CB_RST[2]         ),  // input
            .i_p_pcs_cb_rst_3              (P_PCS_CB_RST[3]         ),  // input
            .i_p_lx_margin_ctl_0           (mac_phy_txmargin        ),  // input  [2:0]
            .i_p_lx_margin_ctl_1           (mac_phy_txmargin        ),  // input  [2:0]
            .i_p_lx_margin_ctl_2           (mac_phy_txmargin        ),  // input  [2:0]
            .i_p_lx_margin_ctl_3           (mac_phy_txmargin        ),  // input  [2:0]
            .i_p_lx_swing_ctl_0            (mac_phy_txswing         ),  // input
            .i_p_lx_swing_ctl_1            (mac_phy_txswing         ),  // input
            .i_p_lx_swing_ctl_2            (mac_phy_txswing         ),  // input
            .i_p_lx_swing_ctl_3            (mac_phy_txswing         ),  // input

            // Lane de-emphasis default 3.5dB
            // 2'b00 -> 3.5dB
            // 2'b01 -> 6dB
            .i_p_lx_deemp_ctl_0            (P_LX_DEEMP_CTL_0        ), // input [1:0]
            .i_p_lx_deemp_ctl_1            (P_LX_DEEMP_CTL_1        ), // input [1:0]
            .i_p_lx_deemp_ctl_2            (P_LX_DEEMP_CTL_2        ), // input [1:0]
            .i_p_lx_deemp_ctl_3            (P_LX_DEEMP_CTL_3        ), // input [1:0]

            .i_p_lane_sync_0               (P_LANE_SYNC_0           ),  // input
            .i_p_lane_sync_en_0            (P_LANE_SYNC_EN_0        ),
            .i_p_rate_change_tclk_on_0     (P_RATE_CHG_TXPCLK_ON_0  ),  // input
            .i_p_tx_ckdiv_0                (P_PMA_TX_RATE_0[1:0]    ),  // input  [1:0]
            .i_p_tx_ckdiv_1                (P_PMA_TX_RATE_1[1:0]    ),  // input  [1:0]
            .i_p_tx_ckdiv_2                (P_PMA_TX_RATE_2[1:0]    ),  // input  [1:0]
            .i_p_tx_ckdiv_3                (P_PMA_TX_RATE_3[1:0]    ),  // input  [1:0]
            .i_p_lx_rx_ckdiv_0             (P_PMA_TX_RATE_0[1:0]    ),
            .i_p_lx_rx_ckdiv_1             (P_PMA_TX_RATE_1[1:0]    ),
            .i_p_lx_rx_ckdiv_2             (P_PMA_TX_RATE_2[1:0]    ),
            .i_p_lx_rx_ckdiv_3             (P_PMA_TX_RATE_3[1:0]    ),
            .i_p_lx_elecidle_en_0          (i_p_lx_elecidle_en_0    ),  // input  [1:0]
            .i_p_lx_elecidle_en_1          (i_p_lx_elecidle_en_1    ),  // input  [1:0]
            .i_p_lx_elecidle_en_2          (i_p_lx_elecidle_en_2    ),  // input  [1:0]
            .i_p_lx_elecidle_en_3          (i_p_lx_elecidle_en_3    ),  // input  [1:0]
            .o_p_pll_lock_0                (P_PLL_READY_0           ),  // output
            .o_p_rx_sigdet_sta_0           (P_PMA_SIGDET_STATUS[0]  ),  // output
            .o_p_rx_sigdet_sta_1           (P_PMA_SIGDET_STATUS[1]  ),  // output
            .o_p_rx_sigdet_sta_2           (P_PMA_SIGDET_STATUS[2]  ),  // output
            .o_p_rx_sigdet_sta_3           (P_PMA_SIGDET_STATUS[3]  ),  // output
            .o_p_lx_cdr_align_0            (P_LX_CDR_ALIGN[0]       ),  // output
            .o_p_lx_cdr_align_1            (P_LX_CDR_ALIGN[1]       ),  // output
            .o_p_lx_cdr_align_2            (P_LX_CDR_ALIGN[2]       ),  // output
            .o_p_lx_cdr_align_3            (P_LX_CDR_ALIGN[3]       ),  // output
            .i_p_lx_rxdct_en_0             (P_LX_RXDCT_EN[0]        ),  // input
            .i_p_lx_rxdct_en_1             (P_LX_RXDCT_EN[1]        ),  // input
            .i_p_lx_rxdct_en_2             (P_LX_RXDCT_EN[2]        ),  // input
            .i_p_lx_rxdct_en_3             (P_LX_RXDCT_EN[3]        ),  // input

            .o_p_lx_rxdct_out_0            (P_LX_RXDCT_OUT_0        ),  // output
            .o_p_lx_rxdct_out_1            (P_LX_RXDCT_OUT_1        ),  // output
            .o_p_lx_rxdct_out_2            (P_LX_RXDCT_OUT_2        ),  // output
            .o_p_lx_rxdct_out_3            (P_LX_RXDCT_OUT_3        ),  // output

            .o_p_pcs_lsm_synced_0          (P_PCS_LSM_SYNCED[0]     ),  // output
            .o_p_pcs_lsm_synced_1          (P_PCS_LSM_SYNCED[1]     ),  // output
            .o_p_pcs_lsm_synced_2          (P_PCS_LSM_SYNCED[2]     ),  // output
            .o_p_pcs_lsm_synced_3          (P_PCS_LSM_SYNCED[3]     ),  // output
            .i_p_pcs_nearend_loop_0        (pcs_nearend_loop[0]     ),  // input
            .i_p_pcs_farend_loop_0         (1'd0                    ),  // input
            .i_p_pma_nearend_ploop_0       (pma_nearend_ploop[0]    ),  // input
            .i_p_pma_nearend_sloop_0       (pma_nearend_sloop[0]    ),  // input
            .i_p_pma_farend_ploop_0        (1'd0                    ),  // input
            .i_p_pcs_nearend_loop_1        (pcs_nearend_loop[1]     ),  // input
            .i_p_pcs_farend_loop_1         (1'd0                    ),  // input
            .i_p_pma_nearend_ploop_1       (pma_nearend_ploop[1]    ),  // input
            .i_p_pma_nearend_sloop_1       (pma_nearend_sloop[1]    ),  // input
            .i_p_pma_farend_ploop_1        (1'd0                    ),  // input
            .i_p_pcs_nearend_loop_2        (pcs_nearend_loop[2]     ),  // input
            .i_p_pcs_farend_loop_2         (1'd0                    ),  // input
            .i_p_pma_nearend_ploop_2       (pma_nearend_ploop[2]    ),  // input
            .i_p_pma_nearend_sloop_2       (pma_nearend_sloop[2]    ),  // input
            .i_p_pma_farend_ploop_2        (1'd0                    ),  // input
            .i_p_pcs_nearend_loop_3        (pcs_nearend_loop[3]     ),  // input
            .i_p_pcs_farend_loop_3         (1'd0                    ),  // input
            .i_p_pma_nearend_ploop_3       (pma_nearend_ploop[3]    ),  // input
            .i_p_pma_nearend_sloop_3       (pma_nearend_sloop[3]    ),  // input
            .i_p_pma_farend_ploop_3        (1'd0                    ),  // input
            .i_p_rx_polarity_invert_0      (P_RX_POLARITY_INVERT[0] ),  // input
            .i_p_rx_polarity_invert_1      (P_RX_POLARITY_INVERT[1] ),  // input
            .i_p_rx_polarity_invert_2      (P_RX_POLARITY_INVERT[2] ),  // input
            .i_p_rx_polarity_invert_3      (P_RX_POLARITY_INVERT[3] ),  // input
            .i_p_tx_beacon_en_0            (tx_beacon[0]            ),  // input
            .i_p_tx_beacon_en_1            (tx_beacon[1]            ),  // input
            .i_p_tx_beacon_en_2            (tx_beacon[2]            ),  // input
            .i_p_tx_beacon_en_3            (tx_beacon[3]            ),  // input
            .i_p_cfg_clk                   (P_REFCK2CORE_0          ),  // input
            .i_p_cfg_rst                   (~hsst_apb_rst_n         ),  // input
            .i_p_cfg_psel                  (i_p_cfg_psel            ),  // input
            .i_p_cfg_enable                (i_p_cfg_enable          ),  // input
            .i_p_cfg_write                 (i_p_cfg_write           ),  // input
            .i_p_cfg_addr                  (i_p_cfg_addr            ),  // input  [15:0]
            .i_p_cfg_wdata                 (i_p_cfg_wdata           ),  // input  [7:0]
            .o_p_cfg_rdata                 (o_p_cfg_rdata           ),  // output [7:0]
            .o_p_cfg_int                   (o_p_cfg_int             ),  // output
            .o_p_cfg_ready                 (o_p_cfg_ready           ),  // output
            .i_p_l0rxn                     (P_RXN[0]                ),  // input
            .i_p_l0rxp                     (P_RXP[0]                ),  // input
            .i_p_l1rxn                     (P_RXN[1]                ),  // input
            .i_p_l1rxp                     (P_RXP[1]                ),  // input
            .i_p_l2rxn                     (P_RXN[2]                ),  // input
            .i_p_l2rxp                     (P_RXP[2]                ),  // input
            .i_p_l3rxn                     (P_RXN[3]                ),  // input
            .i_p_l3rxp                     (P_RXP[3]                ),  // input
            .o_p_l0txn                     (P_TXN[0]                ),  // output
            .o_p_l0txp                     (P_TXP[0]                ),  // output
            .o_p_l1txn                     (P_TXN[1]                ),  // output
            .o_p_l1txp                     (P_TXP[1]                ),  // output
            .o_p_l2txn                     (P_TXN[2]                ),  // output
            .o_p_l2txp                     (P_TXP[2]                ),  // output
            .o_p_l3txn                     (P_TXN[3]                ),  // output
            .o_p_l3txp                     (P_TXP[3]                ),  // output
            .i_txd_0                       (i_txd_0                 ),  // input  [31:0]
            .i_tdispsel_0                  (i_tdispsel_0            ),  // input  [3:0]
            .i_tdispctrl_0                 (i_tdispctrl_0           ),  // input  [3:0]
            .i_txk_0                       (i_txk_0                 ),  // input  [3:0]
            .i_txd_1                       (i_txd_1                 ),  // input  [31:0]
            .i_tdispsel_1                  (i_tdispsel_1            ),  // input  [3:0]
            .i_tdispctrl_1                 (i_tdispctrl_1           ),  // input  [3:0]
            .i_txk_1                       (i_txk_1                 ),  // input  [3:0]
            .i_txd_2                       (i_txd_2                 ),  // input  [31:0]
            .i_tdispsel_2                  (i_tdispsel_2            ),  // input  [3:0]
            .i_tdispctrl_2                 (i_tdispctrl_2           ),  // input  [3:0]
            .i_txk_2                       (i_txk_2                 ),  // input  [3:0]
            .i_txd_3                       (i_txd_3                 ),  // input  [31:0]
            .i_tdispsel_3                  (i_tdispsel_3            ),  // input  [3:0]
            .i_tdispctrl_3                 (i_tdispctrl_3           ),  // input  [3:0]
            .i_txk_3                       (i_txk_3                 ),  // input  [3:0]
            .o_rxstatus_0                  (o_rxstatus_0            ),  // output [2:0]
            .o_rxd_0                       (o_rxd_0                 ),  // output [31:0]
            .o_rdisper_0                   (o_rdisper_0             ),  // output [3:0]
            .o_rdecer_0                    (o_rdecer_0              ),  // output [3:0]
            .o_rxk_0                       (o_rxk_0                 ),  // output [3:0]
            .o_rxstatus_1                  (o_rxstatus_1            ),  // output [2:0]
            .o_rxd_1                       (o_rxd_1                 ),  // output [31:0]
            .o_rdisper_1                   (o_rdisper_1             ),  // output [3:0]
            .o_rdecer_1                    (o_rdecer_1              ),  // output [3:0]
            .o_rxk_1                       (o_rxk_1                 ),  // output [3:0]
            .o_rxstatus_2                  (o_rxstatus_2            ),  // output [2:0]
            .o_rxd_2                       (o_rxd_2                 ),  // output [31:0]
            .o_rdisper_2                   (o_rdisper_2             ),  // output [3:0]
            .o_rdecer_2                    (o_rdecer_2              ),  // output [3:0]
            .o_rxk_2                       (o_rxk_2                 ),  // output [3:0]
            .o_rxstatus_3                  (o_rxstatus_3            ),  // output [2:0]
            .o_rxd_3                       (o_rxd_3                 ),  // output [31:0]
            .o_rdisper_3                   (o_rdisper_3             ),  // output [3:0]
            .o_rdecer_3                    (o_rdecer_3              ),  // output [3:0]
            .o_rxk_3                       (o_rxk_3                 ),  // output [3:0]
            .i_p_pllpowerdown_0            (P_PLLPOWERDOWN_0        )   // input
        );
    end
endgenerate

endmodule
