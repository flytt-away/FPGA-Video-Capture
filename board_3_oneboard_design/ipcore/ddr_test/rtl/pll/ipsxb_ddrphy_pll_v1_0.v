// Created by IP Generator (Version 2020.3-SP2.2 build 65327:65463)



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
// Filename:pll_50_400.v                 
//////////////////////////////////////////////////////////////////////////////

module ipsxb_ddrphy_pll_v1_0 #(
    parameter real    CLKIN_FREQ       = 50.0,
    parameter integer STATIC_RATIOI    = 2,
    parameter integer STATIC_RATIOF    = 32,
    parameter integer STATIC_RATIO0    = 2,
    parameter integer STATIC_RATIO1    = 8,
    parameter integer STATIC_DUTY0     = 2,
    parameter integer STATIC_DUTY1     = 8
) (
    clkin1,
    clkout0_gate,
    pll_rst,
    clkout0,
    clkout1,
    
    pll_lock
    );

    localparam integer STATIC_RATIO2    = 16;
    localparam integer STATIC_RATIO3    = 16;
    localparam integer STATIC_RATIO4    = 4;
    localparam integer STATIC_DUTY2     = 16;
    localparam integer STATIC_DUTY3     = 16;
    localparam integer STATIC_DUTY4     = 4;
    localparam integer STATIC_DUTYF     = 32;
    localparam integer STATIC_PHASE0    = 16;
    localparam integer STATIC_PHASE1    = 16;
    localparam integer STATIC_PHASE2    = 16;
    localparam integer STATIC_PHASE3    = 16;
    localparam integer STATIC_PHASE4    = 16;
    localparam CLK_CAS1_EN              = "FALSE";
    localparam CLK_CAS2_EN              = "FALSE";
    localparam CLK_CAS3_EN              = "FALSE";
    localparam CLK_CAS4_EN              = "FALSE";
    localparam CLKIN_BYPASS_EN          = "FALSE";
    localparam CLKOUT0_GATE_EN          = "TRUE";
    localparam CLKOUT0_EXT_GATE_EN      = "FALSE";
    localparam CLKOUT1_GATE_EN          = "FALSE";
    localparam CLKOUT2_GATE_EN          = "FALSE";
    localparam CLKOUT3_GATE_EN          = "FALSE";
    localparam CLKOUT4_GATE_EN          = "FALSE";
    localparam FBMODE                   = "FALSE";
    localparam integer FBDIV_SEL        = 0;
    localparam BANDWIDTH                = "OPTIMIZED";
    localparam PFDEN_EN                 = "FALSE";
    localparam VCOCLK_DIV2              = 1'b0;
    localparam DYNAMIC_RATIOI_EN        = "FALSE";
    localparam DYNAMIC_RATIO0_EN        = "FALSE";
    localparam DYNAMIC_RATIO1_EN        = "FALSE";
    localparam DYNAMIC_RATIO2_EN        = "FALSE";
    localparam DYNAMIC_RATIO3_EN        = "FALSE";
    localparam DYNAMIC_RATIO4_EN        = "FALSE";
    localparam DYNAMIC_RATIOF_EN        = "FALSE";
    localparam DYNAMIC_DUTY0_EN         = "FALSE";
    localparam DYNAMIC_DUTY1_EN         = "FALSE";
    localparam DYNAMIC_DUTY2_EN         = "FALSE";
    localparam DYNAMIC_DUTY3_EN         = "FALSE";
    localparam DYNAMIC_DUTY4_EN         = "FALSE";
    localparam DYNAMIC_DUTYF_EN         = "FALSE";
    localparam PHASE_ADJUST0_EN         = "TRUE";
    localparam PHASE_ADJUST1_EN         = (CLK_CAS1_EN == "TRUE") ? "FALSE" : "TRUE";
    localparam PHASE_ADJUST2_EN         = (CLK_CAS2_EN == "TRUE") ? "FALSE" : "TRUE";
    localparam PHASE_ADJUST3_EN         = (CLK_CAS3_EN == "TRUE") ? "FALSE" : "TRUE";
    localparam PHASE_ADJUST4_EN         = (CLK_CAS4_EN == "TRUE") ? "FALSE" : "TRUE";
    localparam DYNAMIC_PHASE0_EN        = "FALSE";
    localparam DYNAMIC_PHASE1_EN        = "FALSE";
    localparam DYNAMIC_PHASE2_EN        = "FALSE";
    localparam DYNAMIC_PHASE3_EN        = "FALSE";
    localparam DYNAMIC_PHASE4_EN        = "FALSE";
    localparam DYNAMIC_PHASEF_EN        = "FALSE";
    localparam integer STATIC_PHASEF    = 16;
    localparam CLK_CAS0_EN              = "FALSE";
    localparam integer CLKOUT5_SEL      = 0;
    localparam CLKOUT5_GATE_EN          = "FALSE";
    localparam INTERNAL_FB              = (FBMODE == "FALSE") ? "ENABLE":"DISABLE";
    localparam EXTERNAL_FB              = (FBMODE == "FALSE") ? "DISABLE":
                                          (FBDIV_SEL == 0)  ? "CLKOUT0":
                                          (FBDIV_SEL == 1)  ? "CLKOUT1":
                                          (FBDIV_SEL == 2)  ? "CLKOUT2":
                                          (FBDIV_SEL == 3)  ? "CLKOUT3":
                                          (FBDIV_SEL == 4)  ? "CLKOUT4":"DISABLE";
    localparam RSTODIV_ENABLE           = "FALSE";
    localparam integer STATIC_RATIOM    = 1;
    

    input clkin1;
    input clkout0_gate;
    input pll_rst;
    output clkout0;
    output clkout1;
    
    output pll_lock;

    wire clkout0;
    wire clkout0_2pad;
//    wire clkout1;
    wire clkout2;
    wire clkout3;
    wire clkout4;
    wire clkout5;
    wire clkswitch_flag;
    wire pll_lock;
    wire clkin1;
    wire clkin2;
    wire clkfb;
    wire clkin_sel;
    wire clkin_sel_en;
    wire pfden;
    wire clkout0_gate;
    wire clkout0_2pad_gate;
    wire clkout1_gate;
    wire clkout2_gate;
    wire clkout3_gate;
    wire clkout4_gate;
    wire clkout5_gate;
    wire [9:0] dyn_idiv;
    wire [9:0] dyn_odiv0;
    wire [9:0] dyn_odiv1;
    wire [9:0] dyn_odiv2;
    wire [9:0] dyn_odiv3;
    wire [9:0] dyn_odiv4;
    wire [9:0] dyn_fdiv;
    wire [9:0] dyn_duty0;
    wire [9:0] dyn_duty1;
    wire [9:0] dyn_duty2;
    wire [9:0] dyn_duty3;
    wire [9:0] dyn_duty4;
    wire [12:0] dyn_phase0;
    wire [12:0] dyn_phase1;
    wire [12:0] dyn_phase2;
    wire [12:0] dyn_phase3;
    wire [12:0] dyn_phase4;
    wire pll_pwd;
    wire pll_rst;
    wire rstodiv;
    wire       icp_base;
    wire [3:0] icp_sel;
    wire [2:0] lpfres_sel;
    wire       cripple_sel;
    wire [2:0] phase_sel;
    wire       phase_dir;
    wire       phase_step_n;
    wire       load_phase;
    wire [6:0] dyn_mdiv;    
    
    assign clkin2       = 1'b0;
    assign clkin_sel    = 1'b0;
    assign clkin_sel_en = 1'b0;
    
    assign pll_pwd      = 1'b0;
    
    assign rstodiv      = 1'b0;

GTP_PLL_E3 #(
        .CLKIN_FREQ(CLKIN_FREQ),
        .PFDEN_EN(PFDEN_EN),
        .VCOCLK_DIV2(VCOCLK_DIV2),
        .DYNAMIC_RATIOI_EN(DYNAMIC_RATIOI_EN),
        .DYNAMIC_RATIOM_EN("FALSE"),
        .DYNAMIC_RATIO0_EN(DYNAMIC_RATIO0_EN),
        .DYNAMIC_RATIO1_EN(DYNAMIC_RATIO1_EN),
        .DYNAMIC_RATIO2_EN(DYNAMIC_RATIO2_EN),
        .DYNAMIC_RATIO3_EN(DYNAMIC_RATIO3_EN),
        .DYNAMIC_RATIO4_EN(DYNAMIC_RATIO4_EN),
        .DYNAMIC_RATIOF_EN(DYNAMIC_RATIOF_EN),
        .STATIC_RATIOI(STATIC_RATIOI),
        .STATIC_RATIOM(STATIC_RATIOM),
        .STATIC_RATIO0(STATIC_RATIO0),
        .STATIC_RATIO1(STATIC_RATIO1),
        .STATIC_RATIO2(STATIC_RATIO2),
        .STATIC_RATIO3(STATIC_RATIO3),
        .STATIC_RATIO4(STATIC_RATIO4),
        .STATIC_RATIOF(STATIC_RATIOF),
        .DYNAMIC_DUTY0_EN(DYNAMIC_DUTY0_EN),
        .DYNAMIC_DUTY1_EN(DYNAMIC_DUTY1_EN),
        .DYNAMIC_DUTY2_EN(DYNAMIC_DUTY2_EN),
        .DYNAMIC_DUTY3_EN(DYNAMIC_DUTY3_EN),
        .DYNAMIC_DUTY4_EN(DYNAMIC_DUTY4_EN),
        
        .STATIC_DUTY0(STATIC_DUTY0),
        .STATIC_DUTY1(STATIC_DUTY1),
        .STATIC_DUTY2(STATIC_DUTY2),
        .STATIC_DUTY3(STATIC_DUTY3),
        .STATIC_DUTY4(STATIC_DUTY4),
        
        .STATIC_PHASE0(STATIC_PHASE0[2:0]),
        .STATIC_PHASE1(STATIC_PHASE1[2:0]),
        .STATIC_PHASE2(STATIC_PHASE2[2:0]),
        .STATIC_PHASE3(STATIC_PHASE3[2:0]),
        .STATIC_PHASE4(STATIC_PHASE4[2:0]),
        .STATIC_PHASEF(STATIC_PHASEF[2:0]),
        .STATIC_CPHASE0(STATIC_PHASE0[12:3]-2),
        .STATIC_CPHASE1(STATIC_PHASE1[12:3]-2),
        .STATIC_CPHASE2(STATIC_PHASE2[12:3]-2),
        .STATIC_CPHASE3(STATIC_PHASE3[12:3]-2),
        .STATIC_CPHASE4(STATIC_PHASE4[12:3]-2),
        .STATIC_CPHASEF(STATIC_PHASEF[12:3]-2),
        .CLK_CAS1_EN(CLK_CAS1_EN),
        .CLK_CAS2_EN(CLK_CAS2_EN),
        .CLK_CAS3_EN(CLK_CAS3_EN),
        .CLK_CAS4_EN(CLK_CAS4_EN),
        .CLKOUT5_SEL(CLKOUT5_SEL),
        .CLKIN_BYPASS_EN(CLKIN_BYPASS_EN),
        .CLKOUT0_SYN_EN(CLKOUT0_GATE_EN),
        .CLKOUT0_EXT_SYN_EN(CLKOUT0_EXT_GATE_EN),
        .CLKOUT1_SYN_EN(CLKOUT1_GATE_EN),
        .CLKOUT2_SYN_EN(CLKOUT2_GATE_EN),
        .CLKOUT3_SYN_EN(CLKOUT3_GATE_EN),
        .CLKOUT4_SYN_EN(CLKOUT4_GATE_EN),
        .CLKOUT5_SYN_EN(CLKOUT5_GATE_EN),
        .INTERNAL_FB(INTERNAL_FB),
        .EXTERNAL_FB(EXTERNAL_FB),
        .DYNAMIC_LOOP_EN("FALSE"),
        .LOOP_MAPPING_EN("FALSE"),
        .BANDWIDTH(BANDWIDTH)
        ) u_pll_e3 (
        .CLKOUT0(clkout0),
        .CLKOUT0_EXT(clkout0_2pad),
        .CLKOUT1(clkout1),
        .CLKOUT2(clkout2),
        .CLKOUT3(clkout3),
        .CLKOUT4(clkout4),
        .CLKOUT5(clkout5),
        .CLKSWITCH_FLAG(clkswitch_flag),
        .LOCK(pll_lock),
        .CLKIN1(clkin1),
        .CLKIN2(clkin2),
        .CLKFB(clkfb),
        .CLKIN_SEL(clkin_sel),
        .CLKIN_SEL_EN(clkin_sel_en),
        .PFDEN(pfden),
        .ICP_BASE(1'b0),
        .ICP_SEL(4'b0),
        .LPFRES_SEL(3'b0),
        .CRIPPLE_SEL(1'b0),
        .PHASE_SEL(3'b0),
        .PHASE_DIR(1'b0),
        .PHASE_STEP_N(1'b0),
        .LOAD_PHASE(1'b0),
        .RATIOM(7'b0),
        .RATIOI(dyn_idiv),
        .RATIO0(dyn_odiv0),
        .RATIO1(dyn_odiv1),
        .RATIO2(dyn_odiv2),
        .RATIO3(dyn_odiv3),
        .RATIO4(dyn_odiv4),
        .RATIOF(dyn_fdiv),
        .DUTY0(dyn_duty0),
        .DUTY1(dyn_duty1),
        .DUTY2(dyn_duty2),
        .DUTY3(dyn_duty3),
        .DUTY4(dyn_duty4),
        
        .CLKOUT0_SYN(clkout0_gate),
        .CLKOUT0_EXT_SYN(clkout0_2pad_gate),
        .CLKOUT1_SYN(clkout1_gate),
        .CLKOUT2_SYN(clkout2_gate),
        .CLKOUT3_SYN(clkout3_gate),
        .CLKOUT4_SYN(clkout4_gate),
        .CLKOUT5_SYN(clkout5_gate),
        .PLL_PWD(pll_pwd),
        .RST(pll_rst),
        .RSTODIV(rstodiv)
    );
    
endmodule
