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
// Library:
// Filename:TB interpolation_ram_tb.v 
//////////////////////////////////////////////////////////////////////////////
`timescale   1ns / 1ps

module  interpolation_ram_tb;
localparam  T_CLK_PERIOD       = 10 ;       //clock a half perid
localparam  T_RST_TIME         = 200 ;       //reset time 

localparam WR_ADDR_WIDTH = 11 ; // @IPC int 9,20

localparam WR_DATA_WIDTH = 32 ; // @IPC int 1,1152

localparam RD_ADDR_WIDTH = 11 ; // @IPC int 9,20

localparam RD_DATA_WIDTH = 32 ; // @IPC int 1,1152

localparam OUTPUT_REG = 0 ; // @IPC bool

localparam RD_OCE_EN = 0 ; // @IPC bool

localparam RD_CLK_OR_POL_INV = 0 ; // @IPC bool

localparam RESET_TYPE = "ASYNC" ; // @IPC enum Sync_Internally,SYNC,ASYNC

localparam POWER_OPT = 0 ; // @IPC bool

localparam INIT_FILE = "NONE" ; // @IPC string

localparam INIT_FORMAT = "BIN" ; // @IPC enum BIN,HEX

localparam WR_BYTE_EN = 0 ; // @IPC bool

localparam BE_WIDTH = 1 ; // @IPC int 2,128

localparam RD_BE_WIDTH = 1 ; // @IPC int 2,128

localparam BYTE_SIZE = 8 ; // @IPC enum 8,9

localparam INIT_EN = 0 ; // @IPC bool

localparam SAMEWIDTH_EN = 1 ; // @IPC bool

localparam WR_CLK_EN = 0 ; // @IPC bool

localparam RD_CLK_EN = 0 ; // @IPC bool

localparam WR_ADDR_STROBE_EN = 0 ; // @IPC bool

localparam RD_ADDR_STROBE_EN = 0 ; // @IPC bool

localparam  RESET_TYPE_CTRL    = (RESET_TYPE == "ASYNC") ? "ASYNC_RESET" :
                                 (RESET_TYPE == "SYNC")  ? "SYNC_RESET"  : "ASYNC_RESET_SYNC_RELEASE";
localparam  DEVICE_NAME        = "PGL50H";

localparam  WR_DATA_WIDTH_WRAP = ((DEVICE_NAME == "PGT30G") && (WR_DATA_WIDTH <= 9)) ? 10 : WR_DATA_WIDTH;
localparam  RD_DATA_WIDTH_WRAP = ((DEVICE_NAME == "PGT30G") && (RD_DATA_WIDTH <= 9)) ? 10 : RD_DATA_WIDTH;

// variable declaration 
reg                           wr_clk            ;
reg                           rd_clk            ;
reg                           tb_wr_rst         ;
wire                          tb_wr_clk         ;
reg                           tb_wr_clk_en      ;
reg                           tb_wr_en          ;
reg   [WR_ADDR_WIDTH  :0]     tb_wr_addr        ;
reg                           tb_wr_addr_strobe ;
reg   [BE_WIDTH-1:0]          tb_wr_byte_en     ;
reg   [WR_DATA_WIDTH-1:0]     tb_wrdata_cnt     ;
reg                           tb_rd_rst         ;
wire                          tb_rd_clk         ;
reg                           tb_rd_clk_en      ;
reg   [RD_ADDR_WIDTH  :0]     tb_rd_addr        ;
reg                           tb_rd_addr_strobe ;
reg                           tb_rd_oce         ;
wire  [RD_DATA_WIDTH-1:0]     tb_rddata         ;

reg                           tb_rd_en          ;
reg                           tb_rd_en_dly      ;
reg                           tb_rd_en_2dly     ;
reg   [RD_DATA_WIDTH-1:0]     tb_rddata_cnt     ;
reg   [RD_DATA_WIDTH-1:0]     tb_rddata_cnt_dly ;
reg   [RD_DATA_WIDTH-1:0]     tb_expected_data  ;
reg                           check_err         ;
reg   [2:0]                   results_cnt       ;

//************************************************************ CGU ****************************************************************************
initial
begin
    wr_clk            = 1'b0 ;
    tb_wr_en          = 1'b0 ;
    tb_wr_addr        = {WR_ADDR_WIDTH+1{1'b0}} ;
    tb_wrdata_cnt     = {WR_DATA_WIDTH{1'b0}} ;

    rd_clk            = 1'b0 ;
    tb_rd_addr        = {RD_ADDR_WIDTH+1{1'b0}} ;

    tb_rd_en          = 1'b0 ;
    tb_rddata_cnt     = {RD_DATA_WIDTH{1'b0}} ;
    tb_rddata_cnt_dly = {RD_DATA_WIDTH{1'b0}} ;

    if (WR_CLK_EN == 1)
        tb_wr_clk_en      = 1'b1 ;
    else
        tb_wr_clk_en      = 1'b0 ;

    if (WR_BYTE_EN == 1)
        tb_wr_byte_en     = {BE_WIDTH{1'b1}} ;
    else
        tb_wr_byte_en     = {BE_WIDTH{1'b0}} ;

    if (WR_ADDR_STROBE_EN == 1)
        tb_wr_addr_strobe = 1'b0 ;
    else
        tb_wr_addr_strobe = 1'b0 ;

    if (RD_CLK_EN == 1)
        tb_rd_clk_en      = 1'b1 ;
    else
        tb_rd_clk_en      = 1'b0 ;

    if (RD_OCE_EN == 1)
        tb_rd_oce         = 1'b1 ;
    else
        tb_rd_oce         = 1'b0 ;

    if (RD_ADDR_STROBE_EN == 1)
        tb_rd_addr_strobe = 1'b0 ;
    else
        tb_rd_addr_strobe = 1'b0 ;
end

initial
begin
    forever #(T_CLK_PERIOD/2)  wr_clk = ~wr_clk ;
end

initial
begin
    forever #(T_CLK_PERIOD/2)  rd_clk = ~rd_clk ;
end

assign tb_wr_clk = wr_clk;
assign tb_rd_clk = (RD_CLK_OR_POL_INV == 1) ? ~rd_clk : rd_clk;

task write_sdpram ;
    input write_sdpram ;

    begin
        while ( tb_wr_addr < 2**WR_ADDR_WIDTH )
        begin
            @(posedge wr_clk) ;
            tb_wr_en   = 1'b1 ;
            tb_wr_addr = tb_wr_addr + {{WR_ADDR_WIDTH{1'b0}},1'b1} ;
        end
        tb_wr_en = 1'b0 ;
    end 
endtask

task read_sdpram ;
    input read_sdpram ;

    begin
        while (tb_rd_addr < 2**RD_ADDR_WIDTH )
        begin
            @(posedge rd_clk) ;
            tb_rd_en   = 1'b1 ;
            tb_rd_addr = tb_rd_addr + {{RD_ADDR_WIDTH{1'b0}},1'b1} ;
        end
        tb_rd_en =1'b0 ;
    end
endtask

initial begin
    tb_wr_rst           = 1'b1 ;
    tb_rd_rst           = 1'b1 ;
    #T_RST_TIME ;
    tb_wr_rst           = 1'b0 ;
    tb_rd_rst           = 1'b0 ;
    #10 ;
    if(INIT_FILE == "NONE") begin
        $display("Writing SDPRAM") ;
        write_sdpram(1) ;
        #10 ;
        $display("Reading SDPRAM") ;
        read_sdpram(1) ;
        #10 ;
        $display("SDPRAM Simulation is Done.") ;
    end
    else begin
        $display("Reading Initial SDPRAM") ;
        read_sdpram(1) ;
    end

    if (|results_cnt)
        $display("Simulation Failed due to Error Found.") ;
    else
        $display("Simulation Success.") ;

    #500 ;
    $finish ;
end

always@(posedge wr_clk or posedge tb_wr_rst)
begin
    if(tb_wr_rst)
        tb_wrdata_cnt <= {WR_DATA_WIDTH{1'b1}} ;
    else if (tb_wr_en)
        tb_wrdata_cnt <= tb_wrdata_cnt - {{WR_DATA_WIDTH-1{1'b0}},1'b1} ;
end

always@(posedge rd_clk or posedge tb_rd_rst)
begin
    if(tb_rd_rst)
        tb_rddata_cnt <= {RD_DATA_WIDTH{1'b1}} ;
    else if (!tb_rd_en)
        tb_rddata_cnt <= {RD_DATA_WIDTH{1'b1}} ;
    else if (((RD_OCE_EN == 1'b1) && (tb_rd_oce))
           || (RD_OCE_EN == 1'b0))
        tb_rddata_cnt <= tb_rddata_cnt - {{RD_DATA_WIDTH-1{1'b0}},1'b1} ;
end

always@(posedge tb_rd_clk or posedge tb_rd_rst)
begin
    if (tb_rd_rst)
        tb_rddata_cnt_dly <= {RD_DATA_WIDTH{1'b0}} ;
    else
        tb_rddata_cnt_dly <= tb_rddata_cnt ;
end

always@(posedge tb_rd_clk or posedge tb_rd_rst)
begin
    if (tb_rd_rst)
    begin
        tb_rd_en_dly  <= 1'b0;
        tb_rd_en_2dly <= 1'b0;
    end
    else
    begin
        tb_rd_en_dly  <= tb_rd_en;
        tb_rd_en_2dly <= tb_rd_en_dly;
    end
end

always@(posedge tb_rd_clk or posedge tb_rd_rst)
begin
    if (tb_rd_rst)
        tb_expected_data <= {RD_DATA_WIDTH{1'b0}} ;
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

always@(posedge tb_rd_clk or posedge tb_rd_rst)
begin
    if(tb_rd_rst)
        check_err <= 1'b0;
    else if(INIT_FILE == "NONE")
    begin
        if (((RD_OCE_EN == 1'b1) && (tb_rd_en_2dly) && (tb_rd_oce))
         || ((OUTPUT_REG == 1'b0) && (tb_rd_en_dly))
         || ((OUTPUT_REG == 1'b1) && (tb_rd_en_2dly)))
            check_err <= (tb_expected_data != tb_rddata) ;
        else
            check_err <= 1'b0;
    end 
    else
        check_err <= 1'b0;
end

always@(posedge tb_rd_clk or posedge tb_rd_rst)
begin
    if (tb_rd_rst)
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

interpolation_ram U_interpolation_ram (
    .wr_data        ( tb_wrdata_cnt                 ),
    .wr_addr        ( tb_wr_addr[WR_ADDR_WIDTH-1:0] ),
    .wr_en          ( tb_wr_en                      ),
    .wr_clk         ( wr_clk                        ),

    .wr_rst         ( tb_wr_rst                     ),

    .rd_data        ( tb_rddata                     ),
    .rd_addr        ( tb_rd_addr[RD_ADDR_WIDTH-1:0] ),
    .rd_clk         ( rd_clk                        ),

    .rd_rst         ( tb_rd_rst                     )
    ) ;

endmodule
