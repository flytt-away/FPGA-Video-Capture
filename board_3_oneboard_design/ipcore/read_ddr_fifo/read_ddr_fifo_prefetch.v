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
// Filename:read_ddr_fifo.v
//////////////////////////////////////////////////////////////////////////////

module read_ddr_fifo_prefetch
   (
    
    wr_clk          ,  // input write clock
    wr_rst          ,  // input write reset
    rd_clk          ,  // input read clock
    rd_rst          ,  // input read reset
    
    wr_en           ,  // input write enable 1 active
    wr_vld          ,
    wr_data         ,  // input write data
    rd_en           ,  // input read enable
    rd_vld          ,
    rd_data            // output read data
   );


localparam WR_DEPTH_WIDTH = 8 ; // @IPC int 9,20

localparam WR_DATA_WIDTH = 256 ; // @IPC int 1,1152

localparam RD_DEPTH_WIDTH = 11 ; // @IPC int 9,20

localparam RD_DATA_WIDTH = 32 ; // @IPC int 1,1152

localparam RESET_TYPE = "ASYNC" ; // @IPC enum Sync_Internally,SYNC,ASYNC

localparam POWER_OPT = 0 ; // @IPC bool

localparam FIFO_TYPE = "ASYN_FIFO" ; // @IPC enum SYN_FIFO,ASYN_FIFO

localparam ASYN_FIFO_EN = "1" ; // @IPC bool

localparam  RESET_TYPE_SEL     = (RESET_TYPE == "ASYNC") ? "ASYNC_RESET" :
                                 (RESET_TYPE == "SYNC") ? "SYNC_RESET": "ASYNC_RESET_SYNC_RELEASE";
localparam  FIFO_TYPE_SEL      = (FIFO_TYPE=="SYN_FIFO") ? "SYN" : "ASYN" ; // @IPC enum SYN,ASYN
localparam  DEVICE_NAME        = "PGL50H";

localparam  WR_DATA_WIDTH_WRAP = ((DEVICE_NAME == "PGT30G") && (WR_DATA_WIDTH <= 9)) ? 10 : WR_DATA_WIDTH;
localparam  RD_DATA_WIDTH_WRAP = ((DEVICE_NAME == "PGT30G") && (RD_DATA_WIDTH <= 9)) ? 10 : RD_DATA_WIDTH;

input                          wr_clk          ;    // input write clock
input                          wr_rst          ;    // input write reset
input                          rd_clk          ;    // input  read clock
input                          rd_rst          ;    // input read reset

input [WR_DATA_WIDTH-1 : 0]    wr_data         ;    // input write data
input                          wr_en           ;    // input write enable 1 active
output                         wr_vld          ;
output [RD_DATA_WIDTH-1 : 0]   rd_data         ;    // output read data
input                          rd_en           ;    // input  read enable
output                         rd_vld          ;

wire  [WR_DATA_WIDTH-1 : 0]                   wr_data         ;    // input write data
wire                                          wr_en           ;    // input write enable 1 active
wire                                          wr_clk          ;    // input write clock
wire                                          wr_rst          ;    // input write reset
wire  [RD_DATA_WIDTH-1 : 0]                   rd_data         ;    // output read data
wire                                          rd_en           ;    // input  read enable
wire                                          rd_clk          ;    // input  read clock
wire                                          rd_rst          ;    // input read reset
wire                                          wr_vld;
wire                                          rd_vld;

wire [WR_DATA_WIDTH_WRAP-1 : 0]               wr_data_wrap;
wire [RD_DATA_WIDTH_WRAP-1 : 0]               rd_data_wrap;


assign wr_data_wrap   = ((DEVICE_NAME == "PGT30G") && (WR_DATA_WIDTH <= 9)) ? {{(WR_DATA_WIDTH_WRAP - WR_DATA_WIDTH){1'b0}},wr_data} : wr_data;
assign rd_data        = ((DEVICE_NAME == "PGT30G") && (RD_DATA_WIDTH <= 9)) ? rd_data_wrap[RD_DATA_WIDTH-1 : 0] : rd_data_wrap;


//ipml_prefetch_fifo IP instance
ipml_prefetch_fifo_v1_6_read_ddr_fifo 
    #(
    .c_WR_DEPTH_WIDTH    (WR_DEPTH_WIDTH        ),    // fifo depth width 9 -- 20   legal value:9~20
    .c_WR_DATA_WIDTH     (WR_DATA_WIDTH_WRAP    ),    // write data width 1 -- 1152 1)WR_BYTE_EN =0 legal value:1~1152  2)WR_BYTE_EN=1  legal value:2^N or 9*2^N
    .c_RD_DEPTH_WIDTH    (RD_DEPTH_WIDTH        ),    // read address width 9 -- 20 legal value:1~20
    .c_RD_DATA_WIDTH     (RD_DATA_WIDTH_WRAP    ),    // read data width 1 -- 1152  1)WR_BYTE_EN =0 legal value:1~1152  2)WR_BYTE_EN=1  legal value:2^N or 9*2^N
    .c_RESET_TYPE        (RESET_TYPE_SEL        ),    // reset type legal valve "ASYNC_RESET_SYNC_RELEASE" "SYNC_RESET" "ASYNC_RESET"
    .c_POWER_OPT         (POWER_OPT             ),    // 0 :normal mode  1:low power mode legal value:0 or 1
    .c_FIFO_TYPE         (FIFO_TYPE_SEL         )    // fifo type legal value "SYN" or "ASYN"
    ) U_ipml_fifo_read_ddr_fifo
    (
    
    .wr_clk         ( wr_clk         ) ,    // input write clock
    .wr_rst         ( wr_rst         ) ,    // input write reset
    .rd_clk         ( rd_clk         ) ,    // input  read clock
    .rd_rst         ( rd_rst         ) ,    // input read reset
    
    .wr_en          ( wr_en          ) ,    // input write enable 1 active
    .wr_vld         ( wr_vld         ) ,
    .wr_data        ( wr_data_wrap   ) ,    // input write data
    .rd_en          ( rd_en          ) ,    // input  read enable
    .rd_vld         ( rd_vld         ) ,
    .rd_data        ( rd_data_wrap   )      // output read data
    );

endmodule
