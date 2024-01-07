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
//
// Library:
// Filename:pango_pcie_top_sim.v
//////////////////////////////////////////////////////////////////////////////
module pango_pcie_top_sim

#(
    parameter    integer    APP_DEV_NUM     = 0 ,       // set device_number,RC only

    parameter    integer    APP_BUS_NUM     = 0         // set bus_number,RC only
)

(
    input                       button_rst_n    ,
    input                       perst_n         ,
    input                       free_clk        ,
    //UART interface
    output  wire                txd             ,
    input                       rxd             ,
    //clk and rst
    input                       ref_clk_n       ,      
    input                       ref_clk_p       ,      
    //diff signals

    input           [1:0]       rxn             ,
    input           [1:0]       rxp             ,
    output  wire    [1:0]       txn             ,
    output  wire    [1:0]       txp             ,

    //LED signals
    output  reg                 ref_led         ,
    output  reg                 pclk_led        ,
    output  reg                 pclk_div2_led   ,
    output  wire                smlh_link_up    ,
    output  wire                rdlh_link_up
);

localparam  DEVICE_TYPE = 3'b100;

localparam AXIS_SLAVE_NUM = 3      ;  //@IPC enum 1 2 3


//TEST UNIT MODE SIGNALS
wire            pcie_cfg_ctrl_en        ;
wire            axis_master_tready_cfg  ;

wire            cfg_axis_slave0_tvalid  ;
wire    [127:0] cfg_axis_slave0_tdata   ;
wire            cfg_axis_slave0_tlast   ;
wire            cfg_axis_slave0_tuser   ;

//for mux
wire            axis_master_tready_mem  ;
wire            axis_master_tvalid_mem  ;
wire    [127:0] axis_master_tdata_mem   ;
wire    [3:0]   axis_master_tkeep_mem   ;
wire            axis_master_tlast_mem   ;
wire    [7:0]   axis_master_tuser_mem   ;

wire            cross_4kb_boundary      ;

wire            dma_axis_slave0_tvalid  ;
wire    [127:0] dma_axis_slave0_tdata   ;
wire            dma_axis_slave0_tlast   ;
wire            dma_axis_slave0_tuser   ;

//RESET DEBOUNCE and SYNC
wire            sync_button_rst_n       ;
wire            s_pclk_rstn             ;
wire            s_pclk_div2_rstn        ;

//********************** internal signal
//clk and rst
wire            pclk_div2               ;
wire            pclk                    ;
wire            ref_clk                 ;
wire            core_rst_n              ;
//AXIS master interface
wire            axis_master_tvalid      ;
wire            axis_master_tready      ;
wire    [127:0] axis_master_tdata       ;
wire    [3:0]   axis_master_tkeep       ;
wire            axis_master_tlast       ;
wire    [7:0]   axis_master_tuser       ;

//axis slave 0 interface
wire            axis_slave0_tready      ;
wire            axis_slave0_tvalid      ;
wire    [127:0] axis_slave0_tdata       ;
wire            axis_slave0_tlast       ;
wire            axis_slave0_tuser       ;

//axis slave 1 interface
wire            axis_slave1_tready      ;
wire            axis_slave1_tvalid      ;
wire    [127:0] axis_slave1_tdata       ;
wire            axis_slave1_tlast       ;
wire            axis_slave1_tuser       ;

//axis slave 2 interface
wire            axis_slave2_tready      ;
wire            axis_slave2_tvalid      ;
wire    [127:0] axis_slave2_tdata       ;
wire            axis_slave2_tlast       ;
wire            axis_slave2_tuser       ;

wire    [7:0]   cfg_pbus_num            ;
wire    [4:0]   cfg_pbus_dev_num        ;
wire    [2:0]   cfg_max_rd_req_size     ;
wire    [2:0]   cfg_max_payload_size    ;
wire            cfg_rcb                 ;

wire            cfg_ido_req_en          ;
wire            cfg_ido_cpl_en          ;
wire    [7:0]   xadm_ph_cdts            ;
wire    [11:0]  xadm_pd_cdts            ;
wire    [7:0]   xadm_nph_cdts           ;
wire    [11:0]  xadm_npd_cdts           ;
wire    [7:0]   xadm_cplh_cdts          ;
wire    [11:0]  xadm_cpld_cdts          ;

//system signal
wire    [4:0]   smlh_ltssm_state        ;

// led lights up
reg     [23:0]  ref_led_cnt             ;
reg     [26:0]  pclk_led_cnt            ;
reg     [26:0]  pclk_div2_led_cnt       ;

//uart2apb 32bits
wire            uart_p_sel              ;
wire    [3:0]   uart_p_strb             ;
wire    [15:0]  uart_p_addr             ;
wire    [31:0]  uart_p_wdata            ;
wire            uart_p_ce               ;
wire            uart_p_we               ;
wire            uart_p_rdy              ;
wire    [31:0]  uart_p_rdata            ;

//APB
wire    [3:0]   p_strb                  ;
wire    [15:0]  p_addr                  ;
wire    [31:0]  p_wdata                 ;
wire            p_ce                    ;
wire            p_we                    ;

//apb mux
wire            p_sel_pcie              ;       //0~1,8~f:hsst 2,5,6:Reserved 7:pcie
wire            p_sel_cfg               ;       //4: cfg
wire            p_sel_dma               ;       //3: dma

wire    [31:0]  p_rdata_pcie            ;       //0~1,8~f:hsst 2,5,6:Reserved 7:pcie
wire    [31:0]  p_rdata_cfg             ;       //4: cfg
wire    [31:0]  p_rdata_dma             ;       //3: dma

wire            p_rdy_pcie              ;       //0~1,8~f:hsst 2,5,6:Reserved 7:pcie
wire            p_rdy_cfg               ;       //4: cfg
wire            p_rdy_dma               ;       //3: dma


assign cfg_ido_req_en   =   1'b0;
assign cfg_ido_cpl_en   =   1'b0;
assign xadm_ph_cdts     =   8'b0;
assign xadm_pd_cdts     =   12'b0;
assign xadm_nph_cdts    =   8'b0;
assign xadm_npd_cdts    =   12'b0;
assign xadm_cplh_cdts   =   8'b0;
assign xadm_cpld_cdts   =   12'b0;

//----------------------------------------------------------rst debounce ----------------------------------------------------------
//ASYNC RST  define IPSL_PCIE_SPEEDUP_SIM when simulation
hsst_rst_cross_sync_v1_0 #(
    `ifdef IPSL_PCIE_SPEEDUP_SIM
    .RST_CNTR_VALUE     (16'h10             )
    `else
    .RST_CNTR_VALUE     (16'hC000           )
    `endif
)
u_refclk_buttonrstn_debounce(
    .clk                (ref_clk            ),
    .rstn_in            (button_rst_n       ),
    .rstn_out           (sync_button_rst_n  )
);

hsst_rst_cross_sync_v1_0 #(
    `ifdef IPSL_PCIE_SPEEDUP_SIM
    .RST_CNTR_VALUE     (16'h10             )
    `else
    .RST_CNTR_VALUE     (16'hC000           )
    `endif
)
u_refclk_perstn_debounce(
    .clk                (ref_clk            ),
    .rstn_in            (perst_n            ),
    .rstn_out           (sync_perst_n       )
);

ipsl_pcie_sync_v1_0  u_ref_core_rstn_sync    (
    .clk                (ref_clk            ),
    .rst_n              (core_rst_n         ),
    .sig_async          (1'b1               ),
    .sig_synced         (ref_core_rst_n     )
);

ipsl_pcie_sync_v1_0  u_pclk_core_rstn_sync   (
    .clk                (pclk               ),
    .rst_n              (core_rst_n         ),
    .sig_async          (1'b1               ),
    .sig_synced         (s_pclk_rstn        )
);

ipsl_pcie_sync_v1_0  u_pclk_div2_core_rstn_sync   (
    .clk                (pclk_div2          ),
    .rst_n              (core_rst_n         ),
    .sig_async          (1'b1               ),
    .sig_synced         (s_pclk_div2_rstn   )
);

//----------------------------------------------------------clk led ----------------------------------------------------------
always @(posedge ref_clk or negedge sync_perst_n)
begin
    if (!sync_perst_n)
        ref_led_cnt    <= 24'd0;
    else
        ref_led_cnt    <= ref_led_cnt + 24'd1;
end

always @(posedge ref_clk or negedge sync_perst_n)
begin
    if (!sync_perst_n)
        ref_led        <= 1'b1;
    else if(&ref_led_cnt)
        ref_led        <= ~ref_led;
end

always @(posedge pclk or negedge s_pclk_rstn)
begin
    if (!s_pclk_rstn)
        pclk_led_cnt    <= 27'd0;
    else
        pclk_led_cnt    <= pclk_led_cnt + 27'd1;
end

always @(posedge pclk or negedge s_pclk_rstn)
begin
    if (!s_pclk_rstn)
        pclk_led        <= 1'b1;
    else if(&pclk_led_cnt)
        pclk_led        <= ~pclk_led;
end

always @(posedge pclk_div2 or negedge s_pclk_div2_rstn)
begin
    if (!s_pclk_div2_rstn)
        pclk_div2_led_cnt    <= 27'd0;
    else
        pclk_div2_led_cnt    <= pclk_div2_led_cnt + 27'd1;
end

always @(posedge pclk_div2 or negedge s_pclk_div2_rstn)
begin
    if (!s_pclk_div2_rstn)
        pclk_div2_led        <= 1'b1;
    else if(&pclk_div2_led_cnt)
        pclk_div2_led        <= ~pclk_div2_led;
end

//----------------------------------------------------------uart2apb ----------------------------------------------------------
pgr_uart2apb_top_32bit u_uart2apb_top
(
    .i_clk        (ref_clk            ), // input
    .i_rst_n      (ref_core_rst_n     ), // input
    //apb enable
    .o_p_sel      (uart_p_sel         ), // output
    .o_p_strb     (uart_p_strb        ), // output  [SW-1:0]
    .o_p_addr     (uart_p_addr        ), // output  [AW-1:0]
    .o_p_wdata    (uart_p_wdata       ), // output  [DW-1:0]
    .o_p_enable   (uart_p_ce          ), // output
    .o_p_we       (uart_p_we          ), // output
    .i_p_ready    (uart_p_rdy         ), // input
    .i_p_rdata    (uart_p_rdata       ), // input   [DW-1:0]
    .i_apb_en     (1'b1               ), // input
    .i_strb_en    (1'b1               ), // input
    //uart
    .o_uart_txd   (txd                ), // output
    .i_uart_rxd   (rxd                ), // input
    //just for debug
    .rx_overrun   (                   ), // output
    .rx_chk_err   (                   ), // output
    //apb bypass
    .o_uart_txvld (                   ), // output
    .i_uart_txreq (1'd0               ), // input
    .i_uart_txdata(8'd0               ), // input   [7:0]
    .i_uart_rxreq (1'd0               ), // input
    .o_uart_rxdata(                   ), // output  [7:0]
    .o_uart_rxvld (                   )  // output
);

//----------------------------------------------------------apb mux----------------------------------------------------------
ipsl_expd_apb_mux u_ipsl_pcie_expd_apb_mux(
    //from ref_clk domain
    .i_uart_clk             (ref_clk        ),
    .i_uart_rst_n           (ref_core_rst_n ),
    .i_uart_p_sel           (uart_p_sel     ),
    .i_uart_p_strb          (uart_p_strb    ),
    .i_uart_p_addr          (uart_p_addr    ),
    .i_uart_p_wdata         (uart_p_wdata   ),
    .i_uart_p_ce            (uart_p_ce      ),
    .i_uart_p_we            (uart_p_we      ),
    .o_uart_p_rdy           (uart_p_rdy     ),
    .o_uart_p_rdata         (uart_p_rdata   ),
    //to pclk_div2 domain
    .i_pclk_div2_clk        (pclk_div2      ),
    .i_pclk_div2_rst_n      (core_rst_n     ),

    .o_pclk_div2_p_strb     (p_strb         ),
    .o_pclk_div2_p_addr     (p_addr         ),
    .o_pclk_div2_p_wdata    (p_wdata        ),
    .o_pclk_div2_p_ce       (p_ce           ),
    .o_pclk_div2_p_we       (p_we           ),
    //to pcie
    .o_pcie_p_sel           (p_sel_pcie     ),
    .i_pcie_p_rdy           (p_rdy_pcie     ),
    .i_pcie_p_rdata         (p_rdata_pcie   ),
    //to dma
    .o_dma_p_sel            (p_sel_dma      ),
    .i_dma_p_rdy            (p_rdy_dma      ),
    .i_dma_p_rdata          (p_rdata_dma    ),
    //to cfg
    .o_cfg_p_sel            (p_sel_cfg      ),
    .i_cfg_p_rdy            (p_rdy_cfg      ),
    .i_cfg_p_rdata          (p_rdata_cfg    )
);
//----------------------------------------------------------   dma  ----------------------------------------------------------
// DMA CTRL      BASE ADDR = 0x8000
ipsl_pcie_dma #(
    .DEVICE_TYPE            (DEVICE_TYPE            ),
    .AXIS_SLAVE_NUM         (AXIS_SLAVE_NUM         )
)
u_ipsl_pcie_dma
(
    .clk                    (pclk_div2              ),  //gen1:62.5MHz,gen2:125MHz
    .rst_n                  (core_rst_n             ),
    //num
    .i_cfg_pbus_num         (cfg_pbus_num           ),  //input [7:0]
    .i_cfg_pbus_dev_num     (cfg_pbus_dev_num       ),  //input [4:0]
    .i_cfg_max_rd_req_size  (cfg_max_rd_req_size    ),  //input [2:0]
    .i_cfg_max_payload_size (cfg_max_payload_size   ),  //input [2:0]
    //**********************************************************************
    //axis master interface
    .i_axis_master_tvld     (axis_master_tvalid_mem ),
    .o_axis_master_trdy     (axis_master_tready_mem ),
    .i_axis_master_tdata    (axis_master_tdata_mem  ),
    .i_axis_master_tkeep    (axis_master_tkeep_mem  ),
    .i_axis_master_tlast    (axis_master_tlast_mem  ),
    .i_axis_master_tuser    (axis_master_tuser_mem  ),

    //**********************************************************************
    //axis_slave0 interface
    .i_axis_slave0_trdy     (axis_slave0_tready     ),
    .o_axis_slave0_tvld     (dma_axis_slave0_tvalid ),
    .o_axis_slave0_tdata    (dma_axis_slave0_tdata  ),
    .o_axis_slave0_tlast    (dma_axis_slave0_tlast  ),
    .o_axis_slave0_tuser    (dma_axis_slave0_tuser  ),
    //axis_slave1 interface
    .i_axis_slave1_trdy     (axis_slave1_tready     ),
    .o_axis_slave1_tvld     (axis_slave1_tvalid     ),
    .o_axis_slave1_tdata    (axis_slave1_tdata      ),
    .o_axis_slave1_tlast    (axis_slave1_tlast      ),
    .o_axis_slave1_tuser    (axis_slave1_tuser      ),
    //axis_slave2 interface
    .i_axis_slave2_trdy     (axis_slave2_tready     ),
    .o_axis_slave2_tvld     (axis_slave2_tvalid     ),
    .o_axis_slave2_tdata    (axis_slave2_tdata      ),
    .o_axis_slave2_tlast    (axis_slave2_tlast      ),
    .o_axis_slave2_tuser    (axis_slave2_tuser      ),
    //from pcie
    .i_cfg_ido_req_en       (cfg_ido_req_en         ),
    .i_cfg_ido_cpl_en       (cfg_ido_cpl_en         ),
    .i_xadm_ph_cdts         (xadm_ph_cdts           ),
    .i_xadm_pd_cdts         (xadm_pd_cdts           ),
    .i_xadm_nph_cdts        (xadm_nph_cdts          ),
    .i_xadm_npd_cdts        (xadm_npd_cdts          ),
    .i_xadm_cplh_cdts       (xadm_cplh_cdts         ),
    .i_xadm_cpld_cdts       (xadm_cpld_cdts         ),
    //**********************************************************************
    //apb interface
    .i_apb_psel             (p_sel_dma              ),
    .i_apb_paddr            (p_addr[8:0]            ),
    .i_apb_pwdata           (p_wdata                ),
    .i_apb_pstrb            (p_strb                 ),
    .i_apb_pwrite           (p_we                   ),
    .i_apb_penable          (p_ce                   ),
    .o_apb_prdy             (p_rdy_dma              ),
    .o_apb_prdata           (p_rdata_dma            ),
    .o_cross_4kb_boundary   (cross_4kb_boundary     )
);

generate
    if (DEVICE_TYPE == 3'd4)
    begin:rc
    //----------------------------------------------------------   cfg ctrl  ----------------------------------------------------------
    //CFG TLP TX RX     BASE ADDR = 0x9000
        ipsl_pcie_cfg_ctrl   u_pcie_cfg_ctrl(
            //from APB
            .pclk_div2              (pclk_div2              ),
            .apb_rst_n              (core_rst_n             ),
            .p_sel                  (p_sel_cfg              ),
            .p_strb                 (p_strb                 ),
            .p_addr                 (p_addr[7:0]            ),
            .p_wdata                (p_wdata                ),
            .p_ce                   (p_ce                   ),
            .p_we                   (p_we                   ),
            .p_rdy                  (p_rdy_cfg              ),
            .p_rdata                (p_rdata_cfg            ),
            .pcie_cfg_ctrl_en       (pcie_cfg_ctrl_en       ),
            //to PCIE ctrl
            .axis_slave_tready      (axis_slave0_tready     ),
            .axis_slave_tvalid      (cfg_axis_slave0_tvalid ),
            .axis_slave_tlast       (cfg_axis_slave0_tlast  ),
            .axis_slave_tuser       (cfg_axis_slave0_tuser  ),
            .axis_slave_tdata       (cfg_axis_slave0_tdata  ),
            
            .axis_master_tready     (axis_master_tready_cfg ),
            .axis_master_tvalid     (axis_master_tvalid     ),
            .axis_master_tlast      (axis_master_tlast      ),
        //    .axis_master_tuser      (axis_master_tuser      ),
            .axis_master_tkeep      (axis_master_tkeep      ),
            .axis_master_tdata      (axis_master_tdata      )
        );

        //----------------------------------------------------------   logic mux  ----------------------------------------------------------
        assign axis_slave0_tvalid      = pcie_cfg_ctrl_en ? cfg_axis_slave0_tvalid  : dma_axis_slave0_tvalid;
        assign axis_slave0_tlast       = pcie_cfg_ctrl_en ? cfg_axis_slave0_tlast   : dma_axis_slave0_tlast;
        assign axis_slave0_tuser       = pcie_cfg_ctrl_en ? cfg_axis_slave0_tuser   : dma_axis_slave0_tuser;
        assign axis_slave0_tdata       = pcie_cfg_ctrl_en ? cfg_axis_slave0_tdata   : dma_axis_slave0_tdata;

        assign axis_master_tvalid_mem  = pcie_cfg_ctrl_en ? 1'b0                    : axis_master_tvalid;
        assign axis_master_tdata_mem   = pcie_cfg_ctrl_en ? 128'b0                  : axis_master_tdata;
        assign axis_master_tkeep_mem   = pcie_cfg_ctrl_en ? 4'b0                    : axis_master_tkeep;
        assign axis_master_tlast_mem   = pcie_cfg_ctrl_en ? 1'b0                    : axis_master_tlast;
        assign axis_master_tuser_mem   = pcie_cfg_ctrl_en ? 8'b0                    : axis_master_tuser;
        
        assign axis_master_tready      = pcie_cfg_ctrl_en ? axis_master_tready_cfg  : axis_master_tready_mem;
    end
    else
    begin:ep
        assign p_rdy_cfg               = 1'b0;
        assign p_rdata_cfg             = 32'b0;

        assign axis_slave0_tvalid      = dma_axis_slave0_tvalid;
        assign axis_slave0_tlast       = dma_axis_slave0_tlast;
        assign axis_slave0_tuser       = dma_axis_slave0_tuser;
        assign axis_slave0_tdata       = dma_axis_slave0_tdata;

        assign axis_master_tvalid_mem  = axis_master_tvalid;
        assign axis_master_tdata_mem   = axis_master_tdata;
        assign axis_master_tkeep_mem   = axis_master_tkeep;
        assign axis_master_tlast_mem   = axis_master_tlast;
        assign axis_master_tuser_mem   = axis_master_tuser;
        
        assign axis_master_tready      = axis_master_tready_mem;
    end
endgenerate

//----------------------------------------------------------   pcie wrap  ----------------------------------------------------------
//pcie wrap : HSSTLP : 0x0000~6000 PCIe BASE ADDR : 0x7000
ipsl_pcie_wrap_v1_3_sim

#(
    .APP_DEV_NUM                (APP_DEV_NUM            ),      // set device_number
    .APP_BUS_NUM                (APP_BUS_NUM            )       // set bus_number
)

u_ipsl_pcie_wrap
(
    .button_rst_n               (sync_button_rst_n      ),
    .power_up_rst_n             (sync_perst_n           ),
    .perst_n                    (sync_perst_n           ),
    //clk and rst
    .free_clk                   (free_clk               ),
    .pclk                       (pclk                   ),      //output
    .pclk_div2                  (pclk_div2              ),      //output
    .ref_clk                    (ref_clk                ),      //output
    .ref_clk_n                  (ref_clk_n              ),      //input
    .ref_clk_p                  (ref_clk_p              ),      //input
    .core_rst_n                 (core_rst_n             ),      //output
    
    //APB interface to  DBI cfg
//    .p_clk                      (ref_clk                ),      //input
    .p_sel                      (p_sel_pcie             ),      //input
    .p_strb                     (uart_p_strb            ),      //input  [ 3:0]
    .p_addr                     (uart_p_addr            ),      //input  [15:0]
    .p_wdata                    (uart_p_wdata           ),      //input  [31:0]
    .p_ce                       (uart_p_ce              ),      //input
    .p_we                       (uart_p_we              ),      //input
    .p_rdy                      (p_rdy_pcie             ),      //output
    .p_rdata                    (p_rdata_pcie           ),      //output [31:0]
    
    //PHY diff signals
    .rxn                        (rxn                    ),      //input   max[3:0]
    .rxp                        (rxp                    ),      //input   max[3:0]
    .txn                        (txn                    ),      //output  max[3:0]
    .txp                        (txp                    ),      //output  max[3:0]
    
    .pcs_nearend_loop           ({2{1'b0}}              ),      //input
    .pma_nearend_ploop          ({2{1'b0}}              ),      //input
    .pma_nearend_sloop          ({2{1'b0}}              ),      //input
    
    //AXIS master interface
    .axis_master_tvalid         (axis_master_tvalid     ),      //output
    .axis_master_tready         (axis_master_tready     ),      //input
    .axis_master_tdata          (axis_master_tdata      ),      //output [127:0]
    .axis_master_tkeep          (axis_master_tkeep      ),      //output [3:0]
    .axis_master_tlast          (axis_master_tlast      ),      //output
    .axis_master_tuser          (axis_master_tuser      ),      //output [7:0]
    
    //axis slave 0 interface
    .axis_slave0_tready         (axis_slave0_tready     ),      //output
    .axis_slave0_tvalid         (axis_slave0_tvalid     ),      //input
    .axis_slave0_tdata          (axis_slave0_tdata      ),      //input  [127:0]
    .axis_slave0_tlast          (axis_slave0_tlast      ),      //input
    .axis_slave0_tuser          (axis_slave0_tuser      ),      //input
    
    //axis slave 1 interface
    .axis_slave1_tready         (axis_slave1_tready     ),      //output
    .axis_slave1_tvalid         (axis_slave1_tvalid     ),      //input
    .axis_slave1_tdata          (axis_slave1_tdata      ),      //input  [127:0]
    .axis_slave1_tlast          (axis_slave1_tlast      ),      //input
    .axis_slave1_tuser          (axis_slave1_tuser      ),      //input
    //axis slave 2 interface
    .axis_slave2_tready         (axis_slave2_tready     ),      //output
    .axis_slave2_tvalid         (axis_slave2_tvalid     ),      //input
    .axis_slave2_tdata          (axis_slave2_tdata      ),      //input  [127:0]
    .axis_slave2_tlast          (axis_slave2_tlast      ),      //input
    .axis_slave2_tuser          (axis_slave2_tuser      ),      //input
     
    .pm_xtlh_block_tlp          (                       ),      //output
    
    .cfg_send_cor_err_mux       (                       ),      //output
    .cfg_send_nf_err_mux        (                       ),      //output
    .cfg_send_f_err_mux         (                       ),      //output
    .cfg_sys_err_rc             (                       ),      //output
    .cfg_aer_rc_err_mux         (                       ),      //output
    //radm timeout
    .radm_cpl_timeout           (                       ),      //output
    
    //configuration signals
    .cfg_max_rd_req_size        (cfg_max_rd_req_size    ),      //output [2:0]
    .cfg_bus_master_en          (                       ),      //output
    .cfg_max_payload_size       (cfg_max_payload_size   ),      //output [2:0]
    .cfg_ext_tag_en             (                       ),      //output
    .cfg_rcb                    (cfg_rcb                ),      //output
    .cfg_mem_space_en           (                       ),      //output
    .cfg_pm_no_soft_rst         (                       ),      //output
    .cfg_crs_sw_vis_en          (                       ),      //output
    .cfg_no_snoop_en            (                       ),      //output
    .cfg_relax_order_en         (                       ),      //output
    .cfg_tph_req_en             (                       ),      //output [2-1:0]
    .cfg_pf_tph_st_mode         (                       ),      //output [3-1:0]
    .rbar_ctrl_update           (                       ),      //output
    .cfg_atomic_req_en          (                       ),      //output
    
    .cfg_pbus_num               (cfg_pbus_num           ),      //output [7:0]
    .cfg_pbus_dev_num           (cfg_pbus_dev_num       ),      //output [4:0]
    
    //debug signals
    .radm_idle                  (                       ),      //output
    .radm_q_not_empty           (                       ),      //output
    .radm_qoverflow             (                       ),      //output
    .diag_ctrl_bus              (2'b0                   ),      //input   [1:0]
    .cfg_link_auto_bw_mux       (                       ),      //output              merge cfg_link_auto_bw_msi and cfg_link_auto_bw_int
    .cfg_bw_mgt_mux             (                       ),      //output              merge cfg_bw_mgt_int and cfg_bw_mgt_msi
    .cfg_pme_mux                (                       ),      //output              merge cfg_pme_int and cfg_pme_msi
    .app_ras_des_sd_hold_ltssm  (1'b0                   ),      //input
    .app_ras_des_tba_ctrl       (2'b0                   ),      //input   [1:0]
    
    .dyn_debug_info_sel         (4'b0                   ),      //input   [3:0]
    .debug_info_mux             (                       ),      //output  [132:0]
    
    //system signal
    .smlh_link_up               (smlh_link_up           ),      //output
    .rdlh_link_up               (rdlh_link_up           ),      //output
    .smlh_ltssm_state           (smlh_ltssm_state       )       //output  [4:0]
);

endmodule
