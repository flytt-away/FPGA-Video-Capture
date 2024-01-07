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
// Filename:pango_pcie_top_tb.v
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
`define  IPSL_PCIE_SPEEDUP_SIM
`define  IPML_HSST_SPEEDUP_SIM
module pango_pcie_top_tb;
reg                 button_rst_n;
reg                 perst_n;
//clk and rst
reg                 ref_clk_n;
wire                ref_clk_p;
reg                 free_clk;
//rc
wire                rc_smlh_link_up;
wire                rc_rdlh_link_up;

//ep
wire                ep_smlh_link_up;
wire                ep_rdlh_link_up;

//difference signals

    wire    [1:0]       rc_rxn;
    wire    [1:0]       rc_rxp;
    wire    [1:0]       rc_txn;
    wire    [1:0]       rc_txp;
    initial
        $display("x2 tb");

initial
    begin
        // $fsdbDumpfile("ftd_local_test_tb.fsdb");
        $fsdbAutoSwitchDumpfile(500, "pango_pcie_top_tb.fsdb", 20, "pango_pcie_top_tb.log");
        $fsdbDumpvars(0, pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_wrap.u_pcie_top.u_pcie_hard_ctrl.u_pcie_apb2dbi);
        $fsdbDumpvars(0, pango_pcie_top_tb.u_pango_pcie_top_rc.u_ipsl_pcie_wrap.u_pcie_top.u_pcie_hard_ctrl.u_pcie_apb2dbi);
        $fsdbDumpvars(4, pango_pcie_top_tb.u_pango_pcie_top_rc);
        $fsdbDumpvars(4, pango_pcie_top_tb.u_pango_pcie_top_ep);
    end

//***************************************DUT*****************************
pango_pcie_top_sim

#(
    .APP_DEV_NUM        (0                  ),      // set device_number
    .APP_BUS_NUM        (0                  )       // set bus_number
)
u_pango_pcie_top_rc (

    .button_rst_n       (button_rst_n       ),
    .perst_n            (button_rst_n       ),
    .free_clk           (free_clk           ),
    //UART interface
    .txd                (                   ),
    .rxd                (                   ),
    //clk and rst
    .ref_clk_n          (ref_clk_n          ),      
    .ref_clk_p          (ref_clk_p          ),      
    //clock out
    //diff signals
    .rxn                (rc_rxn             ),
    .rxp                (rc_rxp             ),
    .txn                (rc_txn             ),
    .txp                (rc_txp             ),
    //LED signals
    .ref_led            (                   ),
    .pclk_led           (                   ),
    .pclk_div2_led      (                   ),
    .smlh_link_up       (rc_smlh_link_up    ),
    .rdlh_link_up       (rc_rdlh_link_up    )
);



pango_pcie_top

u_pango_pcie_top_ep (

    .button_rst_n       (button_rst_n       ),
    .perst_n            (button_rst_n       ),
    .free_clk           (free_clk           ),
    //UART interface
    .txd                (                   ),
    .rxd                (                   ),
    //clk and rst
    .ref_clk_n          (ref_clk_n          ),      
    .ref_clk_p          (ref_clk_p          ),      
    //clock out
    //diff signals
    .rxn                (rc_txn             ),
    .rxp                (rc_txp             ),
    .txn                (rc_rxn             ),
    .txp                (rc_rxp             ),
    //LED signals
    .ref_led            (                   ),
    .pclk_led           (                   ),
    .pclk_div2_led      (                   ),
    .smlh_link_up       (ep_smlh_link_up    ),
    .rdlh_link_up       (ep_rdlh_link_up    )
);

GTP_GRS GRS_INST    (.GRS_N(1'b1)) ;


always #5 ref_clk_n = ~ref_clk_n;

assign    ref_clk_p = ~ref_clk_n;

always #10 free_clk = ~free_clk;

initial
begin
    button_rst_n    = 1'b0;
    ref_clk_n       = 1'b0;
    free_clk        = 1'b0;
    //APB interface
    #100
    button_rst_n    = 1'b1;

    force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_addr       = 16'h0;
    force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_sel        = 1'b0;
    force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_strb       = 4'h0;
    force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_ce         = 1'b0;
    force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_we         = 1'b0;
    force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_wdata      = 32'h0;
    force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_addr       = 16'h0;
    force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_sel        = 1'b0;
    force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_strb       = 4'h0;
    force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_ce         = 1'b0;
    force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_we         = 1'b0;
    force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_wdata      = 32'h0;
//PCIE_CTRL
    #100
        wait(|pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_wrap.u_pcie_top.u_pcie_soft_phy.hsst_ch_ready[3:0])
        $display ("hsst rst done!");
        wait(pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_wrap.u_pcie_top.u_pcie_hard_ctrl.app_ltssm_enable)
            $display ("ltssm enable!");
        wait(rc_rdlh_link_up)
            $display ("PCIe link up!");
        #1000
        wait(pango_pcie_top_tb.u_pango_pcie_top_rc.smlh_ltssm_state[4:0] == 5'h11)
        if (pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_wrap.u_pcie_top.mac_phy_rate == 1'b1)
            $display ("link rate is 5.0GT/S");
        else
            $display ("link rate is 2.5GT/S");
            $display ("cfg start!");
        #1000
        //rc cfg ep bar
//--------------------CFG read-------------------------------
        //cfg_ctrl_en enable
                rc_apb_write(16'h4008,32'h0100_0000,4'b1000);
        #5000   //cfg wr type 0
                rc_apb_write(16'h4000,32'h0000_003c,4'b0001);
        // BAR0
        #1000   //reg num 4 BAR0
                rc_apb_write(16'h4008,32'h0000_0004,4'b0001);
                //tag 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR1
        #1000   //reg num 5 BAR1
                rc_apb_write(16'h4008,32'h0000_0005,4'b0001);
                //tag 1
                rc_apb_write(16'h4000,32'h0000_0100,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR2
        #1000   //reg num 6 BAR2
                rc_apb_write(16'h4008,32'h0000_0006,4'b0001);
                //tag 2
                rc_apb_write(16'h4000,32'h0000_0200,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR3
        #1000   //reg num 7 BAR3
                rc_apb_write(16'h4008,32'h0000_0007,4'b0001);
                //tag 3
                rc_apb_write(16'h4000,32'h0000_0300,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR4
        #1000   //reg num 8 BAR4
                rc_apb_write(16'h4008,32'h0000_0008,4'b0001);
                //tag 4
                rc_apb_write(16'h4000,32'h0000_0400,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR5
        #1000   //reg num 8 BAR5
                rc_apb_write(16'h4008,32'h0000_0009,4'b0001);
                //tag 5
                rc_apb_write(16'h4000,32'h0000_0500,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        $display ("CFG Read Done!");
//--------------------CFG write all 1------------------------
        //cfgwr all 1
        #5000
                rc_apb_write(16'h4008,32'h0100_0000,4'b1000);
                //cfg wr type 0
                rc_apb_write(16'h4000,32'h0000_003d,4'b0001);
                //des id bus 1 dev0 fun 0
                rc_apb_write(16'h4004,32'h0100_0000,4'b1000);
                //wr data all 1
                rc_apb_write(16'h400c,32'hffff_ffff,4'b1111);
        // BAR0
        #1000   //reg num 4 BAR0
                rc_apb_write(16'h4008,32'h0000_0004,4'b0001);
                //tag 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR1
        #1000   //reg num 5 BAR1
                rc_apb_write(16'h4008,32'h0000_0005,4'b0001);
                //tag 1
                rc_apb_write(16'h4000,32'h0000_0100,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR2
        #1000   //reg num 6 BAR2
                rc_apb_write(16'h4008,32'h0000_0006,4'b0001);
                //tag 2
                rc_apb_write(16'h4000,32'h0000_0200,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR3
        #1000   //reg num 7 BAR3
                rc_apb_write(16'h4008,32'h0000_0007,4'b0001);
                //tag 3
                rc_apb_write(16'h4000,32'h0000_0300,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR4
        #1000   //reg num 8 BAR4
                rc_apb_write(16'h4008,32'h0000_0008,4'b0001);
                //tag 4
                rc_apb_write(16'h4000,32'h0000_0400,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR5
        #1000   //reg num 8 BAR5
                rc_apb_write(16'h4008,32'h0000_0009,4'b0001);
                //tag 5
                rc_apb_write(16'h4000,32'h0000_0500,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        $display ("CFG Write Done!");
//--------------------CFG read-------------------------------
        #5000   //cfg wr type 0
                rc_apb_write(16'h4000,32'h0000_003c,4'b0001);
        // BAR0
        #1000   //reg num 4 BAR0
                rc_apb_write(16'h4008,32'h0000_0004,4'b0001);
                //tag 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR1
        #1000   //reg num 5 BAR1
                rc_apb_write(16'h4008,32'h0000_0005,4'b0001);
                //tag 1
                rc_apb_write(16'h4000,32'h0000_0100,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR2
        #1000   //reg num 6 BAR2
                rc_apb_write(16'h4008,32'h0000_0006,4'b0001);
                //tag 2
                rc_apb_write(16'h4000,32'h0000_0200,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR3
        #1000   //reg num 7 BAR3
                rc_apb_write(16'h4008,32'h0000_0007,4'b0001);
                //tag 3
                rc_apb_write(16'h4000,32'h0000_0300,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR4
        #1000   //reg num 8 BAR4
                rc_apb_write(16'h4008,32'h0000_0008,4'b0001);
                //tag 4
                rc_apb_write(16'h4000,32'h0000_0400,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR5
        #1000   //reg num 8 BAR5
                rc_apb_write(16'h4008,32'h0000_0009,4'b0001);
                //tag 5
                rc_apb_write(16'h4000,32'h0000_0500,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        $display ("CFG Read Done!");
//--------------------CFG write base addr reg---------------
        //cfg_ctrl_en enable
        #5000
                //rc_apb_write(16'h4008,32'h0100_0000,4'b1000);
                //cfg wr type 0
                rc_apb_write(16'h4000,32'h0000_003d,4'b0001);
                //des id bus 1 dev0 fun 0
                rc_apb_write(16'h4004,32'h0100_0000,4'b1000);
        // BAR0
        #1000   //reg num 4 BAR0
                rc_apb_write(16'h4008,32'h0000_0004,4'b0001);
                //tag 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b0010);
                //wr data all 1
                rc_apb_write(16'h400c,32'h0000_2000,4'b1111);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR1
        #1000   //reg num 5 BAR1
                rc_apb_write(16'h4008,32'h0000_0005,4'b0001);
                //tag 1
                rc_apb_write(16'h4000,32'h0000_0100,4'b0010);
                //wr data all 1
                rc_apb_write(16'h400c,32'hf7e1_2000,4'b1111);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR2
        #1000   //reg num 6 BAR2
                rc_apb_write(16'h4008,32'h0000_0006,4'b0001);
                //tag 2
                rc_apb_write(16'h4000,32'h0000_0200,4'b0010);
                //wr data all 1
                rc_apb_write(16'h400c,32'hf7e1_0000,4'b1111);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR3
        #1000   //reg num 7 BAR3
                rc_apb_write(16'h4008,32'h0000_0007,4'b0001);
                //tag 3
                rc_apb_write(16'h4000,32'h0000_0300,4'b0010);
                //wr data all 1
                rc_apb_write(16'h400c,32'h0000_000f,4'b1111);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR4
        #1000   //reg num 8 BAR4
                rc_apb_write(16'h4008,32'h0000_0008,4'b0001);
                //tag 4
                rc_apb_write(16'h4000,32'h0000_0400,4'b0010);
                //wr data all 1
                rc_apb_write(16'h400c,32'h0000_0000,4'b1111);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR5
        #1000   //reg num 8 BAR5
                rc_apb_write(16'h4008,32'h0000_0009,4'b0001);
                //tag 5
                rc_apb_write(16'h4000,32'h0000_0500,4'b0010);
                //wr data all 1
                rc_apb_write(16'h400c,32'h0000_0000,4'b1111);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
//--------------------CFG read-------------------------------
        //      cfg_wr type
        #1000
                rc_apb_write(16'h4000,32'h0000_003d,4'b0001);
        //      cfg_wr  regnum =1
                //tag 6
                rc_apb_write(16'h4000,32'h0000_0600,4'b0010);

                rc_apb_write(16'h4008,32'h0000_0001,4'b0001);
        //      cfg_wr MSE IOE MEMEN

                rc_apb_write(16'h400c,32'h0000_0007,4'b0001);
        //      cfg_wr  tx en

                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //      cfg_ctrl_en release

                //rc_apb_write(16'h4008,32'h0000_0000,4'b1000);

        #1000
                $display ("CFG cfg Done!");
        //      rc DBI MSE IOE MEMEN
                rc_apb_write(16'h7004,32'h0000_0007,4'b0001);

        #5000   //cfg wr type 0
                rc_apb_write(16'h4000,32'h0000_003c,4'b0001);
        // BAR0
        #1000   //reg num 4 BAR0
                rc_apb_write(16'h4008,32'h0000_0004,4'b0001);
                //tag 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR1
        #1000   //reg num 5 BAR1
                rc_apb_write(16'h4008,32'h0000_0005,4'b0001);
                //tag 1
                rc_apb_write(16'h4000,32'h0000_0100,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR2
        #1000   //reg num 6 BAR2
                rc_apb_write(16'h4008,32'h0000_0006,4'b0001);
                //tag 2
                rc_apb_write(16'h4000,32'h0000_0200,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR3
        #1000   //reg num 7 BAR3
                rc_apb_write(16'h4008,32'h0000_0007,4'b0001);
                //tag 3
                rc_apb_write(16'h4000,32'h0000_0300,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR4
        #1000   //reg num 8 BAR4
                rc_apb_write(16'h4008,32'h0000_0008,4'b0001);
                //tag 4
                rc_apb_write(16'h4000,32'h0000_0400,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        //BAR5
        #1000   //reg num 8 BAR5
                rc_apb_write(16'h4008,32'h0000_0009,4'b0001);
                //tag 5
                rc_apb_write(16'h4000,32'h0000_0500,4'b0010);
                //tx_en 1
                rc_apb_write(16'h4000,32'h0100_0000,4'b1000);
                //tx_en 0
                rc_apb_write(16'h4000,32'h0000_0000,4'b1000);
        $display ("CFG Read Done!");

        //      cfg_ctrl_en release
        #5000
                rc_apb_write(16'h4008,32'h0000_0000,4'b1000);

                //for check ep bar reg
                // bar0_reg
                ep_apb_read(16'h7010);
                // bar1_reg
                ep_apb_read(16'h7014);
                // bar2_reg
                ep_apb_read(16'h7018); //64bit bar
                // bar3_reg
                ep_apb_read(16'h701c);
                // bar4_reg
                ep_apb_read(16'h7020);
                // bar5_reg
                ep_apb_read(16'h7024);

//----------------------PIO and DMA test--------------------------------------
                $display ("start DMA test!");
      //DMA 1 DW
                //cfg_ep_tx_mrd
                rc_cfg_ep_tx(32'h0000_0000,32'h0000_0000);
                wait(pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("ep_rcv cpld!");
                //cfg_ep_tx_mwr
                rc_cfg_ep_tx(32'h0100_0000,32'h0000_0000);
                $display ("1dw DMA test done!");

                dma_check;

        //DMA 2 DW
                //cfg_ep_tx_mrd
                rc_cfg_ep_tx(32'h0000_0001,32'h0000_0040);
                wait(pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("ep_rcv cpld!");
                //cfg_ep_tx_mwr
                rc_cfg_ep_tx(32'h0100_0001,32'h0000_0040);
                $display ("2dw DMA test done!");

                dma_check;
        //DMA 3 DW
                //cfg_ep_tx_mrd
                rc_cfg_ep_tx(32'h0000_0002,32'h0000_0080);
                wait(pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("ep_rcv cpld!");
                //cfg_ep_tx_mwr
                rc_cfg_ep_tx(32'h0100_0002,32'h0000_0080);
                $display ("3dw DMA test done!");

                dma_check;

        //DMA 4 DW
                //cfg_ep_tx_mrd
                rc_cfg_ep_tx(32'h0000_0003,32'h0000_00c0);
                wait(pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("ep_rcv cpld!");
                //cfg_ep_tx_mwr
                rc_cfg_ep_tx(32'h0100_0003,32'h0000_00c0);
                $display ("4dw DMA test done!");

                dma_check;
        //DMA 5 DW
                //cfg_ep_tx_mrd
                rc_cfg_ep_tx(32'h0000_0004,32'h0000_0100);
                wait(pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("ep_rcv cpld!");
                //cfg_ep_tx_mwr
                rc_cfg_ep_tx(32'h0100_0004,32'h0000_0100);
                $display ("5dw DMA test done!");

                dma_check;
        //DMA 6 DW
                //cfg_ep_tx_mrd
                rc_cfg_ep_tx(32'h0000_0005,32'h0000_0140);
                wait(pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("ep_rcv cpld!");
                //cfg_ep_tx_mwr
                rc_cfg_ep_tx(32'h0100_0005,32'h0000_0140);
                $display ("6dw DMA test done!");

                dma_check;
        //DMA 8 DW
                //cfg_ep_tx_mrd
                rc_cfg_ep_tx(32'h0000_0007,32'h0000_0180);
                wait(pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("ep_rcv cpld!");
                //cfg_ep_tx_mwr
                rc_cfg_ep_tx(32'h0100_0007,32'h0000_0180);
                $display ("8dw DMA test done!");

                dma_check;
        //DMA 16 DW
                //cfg_ep_tx_mrd
                rc_cfg_ep_tx(32'h0000_000f,32'h0000_01c0);
                wait(pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("ep_rcv cpld!");
                //cfg_ep_tx_mwr
                rc_cfg_ep_tx(32'h0100_000f,32'h0000_01c0);
                $display ("16dw DMA test done!");

                dma_check;
        //DMA 32 DW
                //cfg_ep_tx_mrd
                rc_cfg_ep_tx(32'h0000_001f,32'h0000_0200);
                wait(pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("ep_rcv cpld!");
                //cfg_ep_tx_mwr
                rc_cfg_ep_tx(32'h0100_001f,32'h0000_0200);
                $display ("32dw DMA test done!");

                dma_check;
        //DMA 64 DW
                //cfg_ep_tx_mrd
                rc_cfg_ep_tx(32'h0000_003f,32'h0000_0240);
                wait(pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("ep_rcv cpld!");
                //cfg_ep_tx_mwr
                rc_cfg_ep_tx(32'h0100_003f,32'h0000_0240);
                $display ("64dw DMA test done!");

                dma_check;
        //DMA 128 DW
                //cfg_ep_tx_mrd
                rc_cfg_ep_tx(32'h0000_007f,32'h0000_0280);
                wait(pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("ep_rcv cpld!");
                //cfg_ep_tx_mwr
                rc_cfg_ep_tx(32'h0100_007f,32'h0000_0280);
                $display ("128dw DMA test done!");

                dma_check;
        //DMA 256 DW
                //cfg_ep_tx_mrd
                rc_cfg_ep_tx(32'h0000_00ff,32'h0000_02c0);
                wait(pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("ep_rcv cpld!");
                //cfg_ep_tx_mwr
                rc_cfg_ep_tx(32'h0100_00ff,32'h0000_02c0);
                $display ("256dw DMA test done!");

                dma_check;
        #10000
        //PIO 1 DW
                //rc_tx_mwr
                rc_mwr_tx(8'h00,32'h0000_2000);
                //rc_tx_mrd
                rc_mrd_tx(8'h00,32'h0000_2000);
                wait(pango_pcie_top_tb.u_pango_pcie_top_rc.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("rc_rcv cpld! PIO 1 DW test done");
        //PIO 4 DW
                rc_mwr_tx(8'h03,32'h0000_2000);
                //rc_tx_mwr
                rc_mrd_tx(8'h03,32'h0000_2000);
                wait(pango_pcie_top_tb.u_pango_pcie_top_rc.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("rc_rcv cpld! PIO 4 DW test done");
        //PIO 5 DW
                //rc_tx_mwr
                rc_mwr_tx(8'h04,32'h0000_2000);
                //rc_tx_mrd
                rc_mrd_tx(8'h04,32'h0000_2000);
                wait(pango_pcie_top_tb.u_pango_pcie_top_rc.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("rc_rcv cpld! PIO 5 DW test done");

        //PIO 8 DW
                rc_mwr_tx(8'h07,32'h0000_2000);
                //rc_tx_mwr
                rc_mrd_tx(8'h07,32'h0000_2000);
                wait(pango_pcie_top_tb.u_pango_pcie_top_rc.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("rc_rcv cpld! PIO 8 DW test done");

        //PIO 16 DW
                rc_mwr_tx(8'h0f,32'h0000_2000);
                //rc_tx_mwr
                rc_mrd_tx(8'h0f,32'h0000_2000);
                wait(pango_pcie_top_tb.u_pango_pcie_top_rc.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("rc_rcv cpld! PIO 16 DW test done");
        //PIO 32 DW
                rc_mwr_tx(8'h1f,32'h0000_2000);
                //rc_tx_mwr
                rc_mrd_tx(8'h1f,32'h0000_2000);
                wait(pango_pcie_top_tb.u_pango_pcie_top_rc.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("rc_rcv cpld! PIO 32 DW test done");

        //PIO 64 DW
                rc_mwr_tx(8'h3f,32'h0000_2000);
                //rc_tx_mwr
                #1000
                rc_mrd_tx(8'h3f,32'h0000_2000);
                wait(pango_pcie_top_tb.u_pango_pcie_top_rc.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("rc_rcv cpld! PIO 64 DW test done");
        //PIO 128 DW
                rc_mwr_tx(8'hff,32'h0000_2000);
                //rc_tx_mwr
                #1000
                rc_mrd_tx(8'hff,32'h0000_2000);
                wait(pango_pcie_top_tb.u_pango_pcie_top_rc.u_ipsl_pcie_dma.i_axis_master_tdata[31:24]==8'h4a)
                $display ("rc_rcv cpld! PIO 128 DW test done");
    #20000 $finish;
end

initial
begin
    $monitor ($time, ,"mwr tx %d,mrd tx %d,tlp rcv %d",pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_dma.u_ipsl_pcie_dma_tx_top.u_ipsl_pcie_dma_mwr_tx_ctrl.tlp_tx_sum,
                                                       pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_dma.u_ipsl_pcie_dma_tx_top.u_ipsl_pcie_dma_mrd_tx_ctrl.tlp_tx_sum,
                                                       pango_pcie_top_tb.u_pango_pcie_top_ep.u_ipsl_pcie_dma.u_ipsl_pcie_dma_rx_top.u_ipsl_pcie_dma_tlp_rcv.tlp_rx_sum);
end

task    rc_apb_write;
        input [15:0]    addr;
        input [31:0]    wdata;
        input [3:0]     strb;
        begin
            @(posedge pango_pcie_top_tb.u_pango_pcie_top_rc.ref_clk)
            #1
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_addr       = addr;
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_sel        = 1'b1;
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_strb       = strb;
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_ce         = 1'b0;
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_we         = 1'b1;
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_wdata      = wdata;
            @(posedge pango_pcie_top_tb.u_pango_pcie_top_rc.ref_clk)
            #1
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_ce         = 1'b1;
            //wait(pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_rdy)
            //@(posedge pango_pcie_top_tb.u_pango_pcie_top_rc.ref_clk)
            @(negedge pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_rdy)
            #1
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_addr       = 16'h0;
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_sel        = 1'b0;
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_strb       = 4'h0;
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_ce         = 1'b0;
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_we         = 1'b0;
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_wdata      = 32'h0;
        end
endtask

task    rc_apb_read;
        input   [15:0]  addr;
        begin
            @(posedge pango_pcie_top_tb.u_pango_pcie_top_rc.ref_clk)
            #1
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_sel        =  1'b1;
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_addr       =  addr;
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_ce         =  1'b0;
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_we         =  1'b0;
            @(posedge pango_pcie_top_tb.u_pango_pcie_top_rc.ref_clk)
            #1
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_ce         = 1'b1;
            //wait(pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_rdy)
            //@(posedge pango_pcie_top_tb.u_pango_pcie_top_rc.ref_clk)
            @(negedge pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_rdy)
            #1
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_sel        = 1'b0;
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_addr       = 16'h0;
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_ce         = 1'b0;
                force pango_pcie_top_tb.u_pango_pcie_top_rc.uart_p_we         = 1'b0;
        end
endtask

task    ep_apb_write;
        input [15:0]    addr;
        input [31:0]    wdata;
        input [3:0]     strb;
        begin
            @(posedge pango_pcie_top_tb.u_pango_pcie_top_ep.ref_clk)
            #1
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_addr       = addr;
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_sel        = 1'b1;
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_strb       = strb;
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_ce         = 1'b0;
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_we         = 1'b1;
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_wdata      = wdata;
            @(posedge pango_pcie_top_tb.u_pango_pcie_top_ep.ref_clk)
            #1
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_ce         = 1'b1;
            //wait(pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_rdy)
            //@(posedge pango_pcie_top_tb.u_pango_pcie_top_ep.ref_clk)
            @(negedge pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_rdy)
            #1
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_addr       = 16'h0;
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_sel        = 1'b0;
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_strb       = 4'h0;
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_ce         = 1'b0;
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_we         = 1'b0;
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_wdata      = 32'h0;
        end
endtask

task    ep_apb_read;
        input   [15:0]  addr;
        begin
            @(posedge pango_pcie_top_tb.u_pango_pcie_top_ep.ref_clk)
            #1
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_sel        =  1'b1;
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_addr       =  addr;
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_ce         =  1'b0;
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_we         =  1'b0;
            @(posedge pango_pcie_top_tb.u_pango_pcie_top_ep.ref_clk)
            #1
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_ce         = 1'b1;
            //wait(pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_rdy)
            //@(posedge pango_pcie_top_tb.u_pango_pcie_top_ep.ref_clk)
            @(negedge pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_rdy)
            #1
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_sel        = 1'b0;
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_addr       = 16'h0;
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_ce         = 1'b0;
                force pango_pcie_top_tb.u_pango_pcie_top_ep.uart_p_we         = 1'b0;
        end
endtask

task    rc_mwr_tx;
        input   [7:0]   length;
        input   [31:0]  addr;
        begin
        #1000
            //type:mwr 32bit
            rc_apb_write(16'h3140,32'h0100_0000,4'b1111);
            //length:32 dw
            rc_apb_write(16'h3150,{24'b0,length},4'b1111);
            //addr_l:0x0000_0000
            rc_apb_write(16'h3160,addr,4'b1111);
        end
endtask

task    rc_mrd_tx;
        input   [7:0]   length;
        input   [31:0]  addr;
        begin
        #1000
            //type:mrd 32bit
            rc_apb_write(16'h3140,32'h0000_0000,4'b1111);
            //length:32 dw
            rc_apb_write(16'h3150,{24'b0,length},4'b1111);
            //addr_l:0x0000_0000
            rc_apb_write(16'h3160,addr,4'b1111);
        end
endtask

task    rc_mwr_tx_with_data;
        input   [31:0]  addr;
        input   [31:0]  data;
        begin
        #1000
            //cfg cmd_reg;
            //type:mwr 32bit with data
            rc_apb_write(16'h3140,32'h0100_0100,4'b1111);
            //length:1 dw
            rc_apb_write(16'h3150,32'h0000_0000,4'b1111);
            //addr_l:0xf7e1_2100
            rc_apb_write(16'h3160,addr,4'b1111);
            //wr_data: cfg ep tx 32mwr 32dw
            rc_apb_write(16'h3180,data,4'b1111);
        end
endtask

task    rc_cfg_ep_tx;
        input   [31:0]  cmd_reg;
        input   [31:0]  addr_l_reg;
        begin
        #5000
            //ep_cmd_reg
            rc_mwr_tx_with_data(32'hf7e1_2100,cmd_reg);
            //ep_addr_l
            rc_mwr_tx_with_data(32'hf7e1_2110,addr_l_reg);
        end
endtask

task    dma_check;
        if (pango_pcie_top_tb.u_pango_pcie_top_rc.u_ipsl_pcie_dma.u_ipsl_pcie_dma_controller.dma_check_success == 1'b1)
            $display ("DMA test pass!");
        else
            $display ("DMA test fail!");
endtask

endmodule
