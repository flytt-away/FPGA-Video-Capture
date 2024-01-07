// Created by IP Generator (Version 2022.1 build 99559)


//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
//
// Library:
// Filename:TB hdmi_pcie_fifo_tb.v
//////////////////////////////////////////////////////////////////////////////
`timescale   1ns / 1ps

module  hdmi_pcie_fifo_tb;
localparam T_CLK_PERIOD       = 10 ;       //clock a half perid
localparam T_RST_TIME         = 200 ;       //reset time 

localparam WR_DEPTH_WIDTH = 15 ; // @IPC int 9,20

localparam WR_DATA_WIDTH = 16 ; // @IPC int 1,1152

localparam RD_DEPTH_WIDTH = 12 ; // @IPC int 9,20

localparam RD_DATA_WIDTH = 128 ; // @IPC int 1,1152

localparam OUTPUT_REG = 0 ; // @IPC bool

localparam RD_OCE_EN = 0 ; // @IPC bool

localparam RD_CLK_OR_POL_INV = 0 ; // @IPC bool

localparam RESET_TYPE = "ASYNC" ; // @IPC enum Sync_Internally,SYNC,ASYNC

localparam POWER_OPT = 0 ; // @IPC bool

localparam WR_BYTE_EN = 0 ; // @IPC bool

localparam BE_WIDTH = 1 ; // @IPC int 2,128

localparam FIFO_TYPE = "ASYN_FIFO" ; // @IPC enum SYN_FIFO,ASYN_FIFO

localparam ASYN_FIFO_EN = "1" ; // @IPC bool

localparam ALMOST_FULL_NUM = 1020 ; // @IPC int

localparam ALMOST_EMPTY_NUM = 4 ; // @IPC int

localparam FULL_WL_EN = 1 ; // @IPC bool

localparam EMPTY_WL_EN = 1 ; // @IPC bool

localparam BYTE_SIZE = 8 ; // @IPC enum 8,9

localparam  RESET_TYPE_SEL     = (RESET_TYPE == "ASYNC"   ) ? "ASYNC_RESET" :
                                 (RESET_TYPE == "SYNC"    ) ? "SYNC_RESET"  : "ASYNC_RESET_SYNC_RELEASE" ;
localparam  FIFO_TYPE_SEL      = (FIFO_TYPE  == "SYN_FIFO") ? "SYNC"        : "ASYNC" ;
localparam  DEVICE_NAME        = "PGL50H";

localparam  WR_DATA_WIDTH_WRAP = ((DEVICE_NAME == "PGT30G") && (WR_DATA_WIDTH <= 9)) ? 10 : WR_DATA_WIDTH;
localparam  RD_DATA_WIDTH_WRAP = ((DEVICE_NAME == "PGT30G") && (RD_DATA_WIDTH <= 9)) ? 10 : RD_DATA_WIDTH;

// variable declaration
reg                             clk                ;
wire                            tb_clk             ;
reg                             tb_rst             ;
wire  [WR_DATA_WIDTH-1 : 0]     tb_wrdata          ;
reg                             tb_wr_en           ;
wire                            tb_wr_full         ;
reg   [BE_WIDTH-1      : 0]     tb_wr_byte_en      ;
wire  [WR_DEPTH_WIDTH  : 0]     tb_wr_water_level  ;
wire                            tb_almost_full     ;
wire  [RD_DATA_WIDTH-1 : 0]     tb_rddata          ;
reg   [RD_DATA_WIDTH-1 : 0]     tb_rddata_dly      ;
reg                             tb_rd_en           ;
reg                             tb_rd_en_dly       ;
reg                             tb_rd_en_2dly      ;
wire                            tb_rd_empty        ;
reg                             tb_rd_oce          ;
wire  [RD_DEPTH_WIDTH  : 0]     tb_rd_water_level  ;
wire                            tb_almost_empty    ;

reg   [RD_DEPTH_WIDTH  : 0]     tb_rd_addr         ;
reg   [WR_DEPTH_WIDTH  : 0]     tb_wr_addr         ;
reg   [WR_DATA_WIDTH-1 : 0]     tb_wrdata_cnt      ;
reg   [RD_DATA_WIDTH-1 : 0]     tb_rddata_cnt      ;
reg   [RD_DATA_WIDTH-1 : 0]     tb_rddata_cnt_dly  ;
reg   [RD_DATA_WIDTH-1 : 0]     tb_expected_data   ;
reg                             check_err          ;
reg   [2:0]                     results_cnt        ;

//********************************************************* CGU ********************************************************************************
initial
begin
    tb_wr_en      = 1'b0 ;
    tb_wr_addr    = {WR_DEPTH_WIDTH+1{1'b0}} ;
    tb_wrdata_cnt = {WR_DATA_WIDTH{1'b0}} ;
    tb_rd_en      = 1'b0;
    tb_rd_addr    = {RD_DEPTH_WIDTH+1{1'b0}} ;
    tb_rddata_cnt = {RD_DATA_WIDTH{1'b0}} ;
    tb_rst        = 1'b1 ;
    #T_RST_TIME;
    tb_rst        = 1'b0 ;
    clk           = 1'b0;
    if(RD_OCE_EN == 1)
        tb_rd_oce = 1'b1 ;
    else
        tb_rd_oce = 1'b0 ;
    if(WR_BYTE_EN == 1)
        tb_wr_byte_en = {BE_WIDTH{1'b1}} ;
    else
        tb_wr_byte_en = {BE_WIDTH{1'b0}} ;
end

initial
begin
    forever #(T_CLK_PERIOD/2) clk = ~clk ;
end

assign tb_clk = (RD_CLK_OR_POL_INV == 1) ? ~clk : clk;

task write_fifo ;
    input wr_fifo ;
    begin
        tb_wr_addr = {WR_DEPTH_WIDTH+1{1'b0}} ;
        while (tb_wr_addr <= (2**WR_DEPTH_WIDTH))
        begin
            @(posedge clk) ;
            tb_wr_en   = 1'b1 ;
            tb_wr_addr = tb_wr_addr + {{WR_DEPTH_WIDTH{1'b0}},1'b1} ;
        end
        tb_wr_en = 1'b0 ;
    end
endtask

task read_fifo ;
    input rd_fifo ;
    begin
        tb_rd_addr = {RD_DEPTH_WIDTH+1{1'b0}} ;
        while (tb_rd_addr <= (2**RD_DEPTH_WIDTH))
        begin
            @(posedge clk) ;
            tb_rd_en   = 1'b1 ;
            tb_rd_addr = tb_rd_addr + {{RD_DEPTH_WIDTH{1'b0}},1'b1} ;
        end
        tb_rd_en =1'b0 ;
    end
endtask

initial
begin
    $display("Writing FIFO") ;
    write_fifo(1) ;
    #10;
    $display("Reading FIFO") ;
    read_fifo(1) ;
    $display("FIFO simulation is done.") ;
    if (|results_cnt)
        $display("Simulation Failed due to Error Found.") ;
    else
        $display("Simulation Success.") ;
    #500 ;
    $finish ;
end

always@(posedge clk or posedge tb_rst)
begin
    if(tb_rst)
        tb_wrdata_cnt <= {WR_DATA_WIDTH{1'b1}} ;
    else if (tb_wr_en)
        tb_wrdata_cnt <= tb_wrdata_cnt - {{WR_DATA_WIDTH-1{1'b0}},1'b1} ;
end

assign tb_wrdata = tb_wrdata_cnt ;

always@(posedge clk or posedge tb_rst)
begin
    if(tb_rst)
        tb_rddata_cnt <= {RD_DATA_WIDTH{1'b1}} ;
    else if (!tb_rd_en)
        tb_rddata_cnt <= {RD_DATA_WIDTH{1'b1}} ;
    else
        tb_rddata_cnt <= tb_rddata_cnt - {{RD_DATA_WIDTH-1{1'b0}},1'b1} ;
end

always@(posedge tb_clk or posedge tb_rst)
begin
    if (tb_rst)
        tb_rddata_cnt_dly <= {RD_DATA_WIDTH{1'b0}} ;
    else
        tb_rddata_cnt_dly <= tb_rddata_cnt ;
end

always@(posedge tb_clk or posedge tb_rst)
begin
    if (tb_rst)
    begin
        tb_rd_en_dly  <= 1'b0;
        tb_rd_en_2dly <= 1'b0;
        tb_rddata_dly <= 0;
    end
    else
    begin
        tb_rd_en_dly  <= tb_rd_en;
        tb_rd_en_2dly <= tb_rd_en_dly;
        tb_rddata_dly <= tb_rddata;
    end
end


always@(posedge tb_clk or posedge tb_rst)
begin
    if (tb_rst)
        tb_expected_data <= {RD_DATA_WIDTH{1'b1}} ;
    else if (RD_OCE_EN == 1'b1)
    begin
        if (tb_rd_oce)
            tb_expected_data <= tb_rddata_cnt_dly ;
    end
    else if (OUTPUT_REG == 1'b1)
        tb_expected_data <= tb_rddata_cnt_dly ;
    else
        tb_expected_data <= tb_rddata_cnt ;
end

always@(posedge tb_clk or posedge tb_rst)
begin
    if(tb_rst)
        check_err <= 1'b0;
    else if (((RD_OCE_EN == 1'b1) && (tb_rd_en_2dly) && (tb_rd_oce))
         || ((OUTPUT_REG == 1'b0) && (tb_rd_en_dly))
         || ((OUTPUT_REG == 1'b1) && (tb_rd_en_2dly)))
        check_err <= (tb_expected_data != tb_rddata) ;
    else
        check_err <= 1'b0;
end

always @(posedge tb_clk or posedge tb_rst)
begin
    if (tb_rst)
        results_cnt <= 3'b000 ;
    else if (&results_cnt)
        results_cnt <= 3'b100 ;
    else if (check_err)
        results_cnt <= results_cnt + 3'd1 ;
end

//***************************************************************** DUT  INST **************************************************************************************

GTP_GRS GRS_INST(
    .GRS_N(1'b1)
    ) ;
hdmi_pcie_fifo U_hdmi_pcie_fifo (

    .wr_data        ( tb_wrdata         ) ,
    .wr_en          ( tb_wr_en          ) ,

    .wr_clk         ( clk               ) ,
    .wr_rst         ( tb_rst            ) ,

    .wr_full        ( tb_wr_full        ) ,

    .wr_water_level ( tb_wr_water_level ) ,

    .almost_full    ( tb_almost_full    ) ,
    .rd_data        ( tb_rddata         ) ,
    .rd_en          ( tb_rd_en          ) ,

    .rd_clk         ( clk               ) ,
    .rd_rst         ( tb_rst            ) ,

    .rd_empty       ( tb_rd_empty       ) ,

    .rd_water_level ( tb_rd_water_level ) ,

    .almost_empty   ( tb_almost_empty   )
    ) ;

endmodule
