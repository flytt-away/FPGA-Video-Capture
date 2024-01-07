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
// Filename:write_ddr_fifo.v
//////////////////////////////////////////////////////////////////////////////

module write_ddr_fifo
   (
    
    wr_clk          ,  // input write clock
    wr_rst          ,  // input write reset
    
    wr_en           ,  // input write enable 1 active
    wr_data         ,  // input write data
    wr_full         ,  // output write full  flag 1 active
    
    wr_water_level  ,  // output write water level
    
    rd_clk          ,  // input read clock
    rd_rst          ,  // input read reset
    
    rd_en           ,  // input read enable
    rd_data         ,  // output read data
    
    almost_full     ,  // output write almost full
    rd_empty        ,  // output read empty
    
    rd_water_level  ,  // output read water level
    
    almost_empty       // output write almost empty 
   );


localparam WR_DEPTH_WIDTH = 11 ; // @IPC int 9,20

localparam WR_DATA_WIDTH = 32 ; // @IPC int 1,1152

localparam RD_DEPTH_WIDTH = 8 ; // @IPC int 9,20

localparam RD_DATA_WIDTH = 256 ; // @IPC int 1,1152

localparam OUTPUT_REG = 0 ; // @IPC bool

localparam RD_OCE_EN = 0 ; // @IPC bool

localparam RD_CLK_OR_POL_INV = 0 ; // @IPC bool

localparam RESET_TYPE = "ASYNC" ; // @IPC enum Sync_Internally,SYNC,ASYNC

localparam POWER_OPT = 0 ; // @IPC bool

localparam WR_BYTE_EN = 0 ; // @IPC bool

localparam BE_WIDTH = 1 ; // @IPC int 2,128

localparam FIFO_TYPE = "ASYN_FIFO" ; // @IPC enum SYN_FIFO,ASYN_FIFO

localparam ASYN_FIFO_EN = "1" ; // @IPC bool

localparam ALMOST_FULL_NUM = 2044 ; // @IPC int

localparam ALMOST_EMPTY_NUM = 4 ; // @IPC int

localparam FULL_WL_EN = 1 ; // @IPC bool

localparam EMPTY_WL_EN = 1 ; // @IPC bool

localparam BYTE_SIZE = 8 ; // @IPC enum 8,9

localparam  RESET_TYPE_SEL     = (RESET_TYPE == "ASYNC") ? "ASYNC_RESET" :
                                 (RESET_TYPE == "SYNC") ? "SYNC_RESET": "ASYNC_RESET_SYNC_RELEASE";
localparam  FIFO_TYPE_SEL      = (FIFO_TYPE=="SYN_FIFO") ? "SYN" : "ASYN" ; // @IPC enum SYN,ASYN
localparam  DEVICE_NAME        = "PGL50H";

localparam  WR_DATA_WIDTH_WRAP = ((DEVICE_NAME == "PGT30G") && (WR_DATA_WIDTH <= 9)) ? 10 : WR_DATA_WIDTH;
localparam  RD_DATA_WIDTH_WRAP = ((DEVICE_NAME == "PGT30G") && (RD_DATA_WIDTH <= 9)) ? 10 : RD_DATA_WIDTH;
localparam  SIM_DEVICE         = ((DEVICE_NAME == "PGL22G") || (DEVICE_NAME == "PGL22GS")) ? "PGL22G" : "LOGOS";

input [WR_DATA_WIDTH-1 : 0]    wr_data         ;    // input write data
input                          wr_en           ;    // input write enable 1 active

input                          wr_clk          ;    // input write clock
input                          wr_rst          ;    // input write reset

output                         wr_full         ;    // output write full  flag 1 active

output                         almost_full     ;    // output write almost full

output [WR_DEPTH_WIDTH : 0]    wr_water_level  ;    // output write water level

output [RD_DATA_WIDTH-1 : 0]   rd_data         ;    // output read data
input                          rd_en           ;    // input  read enable

input                          rd_clk          ;    // input  read clock
input                          rd_rst          ;    // input read reset

output                         rd_empty        ;    // output read empty

output                         almost_empty    ;    // output read water level

output [RD_DEPTH_WIDTH : 0]    rd_water_level  ;


wire  [WR_DATA_WIDTH-1 : 0]                   wr_data         ;    // input write data
wire                                          wr_en           ;    // input write enable 1 active
wire                                          wr_clk          ;    // input write clock
wire                                          wr_full         ;    // input write full  flag 1 active
wire                                          wr_rst          ;    // input write reset
wire  [BE_WIDTH-1 : 0]                        wr_byte_en      ;    // input write byte enable
wire                                          almost_full     ;    // output write almost full
wire  [WR_DEPTH_WIDTH : 0]                    wr_water_level  ;    // output write water level
wire  [RD_DATA_WIDTH-1 : 0]                   rd_data         ;    // output read data
wire                                          rd_en           ;    // input  read enable
wire                                          rd_clk          ;    // input  read clock
wire                                          rd_empty        ;    // output read empty
wire                                          rd_rst          ;    // input read reset
wire                                          rd_oce          ;    // output read output register enable
wire                                          almost_empty    ;    // output read water level
wire  [RD_DEPTH_WIDTH : 0]                    rd_water_level  ;

wire  [BE_WIDTH-1:0]                          wr_byte_en_mux  ;
wire                                          rd_oce_mux      ;

wire [WR_DATA_WIDTH_WRAP-1 : 0]               wr_data_wrap;
wire [RD_DATA_WIDTH_WRAP-1 : 0]               rd_data_wrap;

assign wr_byte_en_mux = (WR_BYTE_EN == 1) ? wr_byte_en : -1   ;
assign rd_oce_mux     = (RD_OCE_EN  == 1) ? rd_oce     :
                        (OUTPUT_REG == 1) ? 1'b1       : 1'b0 ;

assign wr_data_wrap   = ((DEVICE_NAME == "PGT30G") && (WR_DATA_WIDTH <= 9)) ? {{(WR_DATA_WIDTH_WRAP - WR_DATA_WIDTH){1'b0}},wr_data} : wr_data;
assign rd_data        = ((DEVICE_NAME == "PGT30G") && (RD_DATA_WIDTH <= 9)) ? rd_data_wrap[RD_DATA_WIDTH-1 : 0] : rd_data_wrap;


//ipml_sdpram IP instance
ipml_fifo_v1_6_write_ddr_fifo 
    #(
    .c_SIM_DEVICE        (SIM_DEVICE            ),
    .c_WR_DEPTH_WIDTH    (WR_DEPTH_WIDTH        ),    // fifo depth width 9 -- 20   legal value:9~20
    .c_WR_DATA_WIDTH     (WR_DATA_WIDTH_WRAP    ),    // write data width 1 -- 1152 1)WR_BYTE_EN =0 legal value:1~1152  2)WR_BYTE_EN=1  legal value:2^N or 9*2^N
    .c_RD_DEPTH_WIDTH    (RD_DEPTH_WIDTH        ),    // read address width 9 -- 20 legal value:1~20
    .c_RD_DATA_WIDTH     (RD_DATA_WIDTH_WRAP    ),    // read data width 1 -- 1152  1)WR_BYTE_EN =0 legal value:1~1152  2)WR_BYTE_EN=1  legal value:2^N or 9*2^N
    .c_OUTPUT_REG        (OUTPUT_REG            ),    // output register            legal value:0 or 1
    .c_RD_OCE_EN         (RD_OCE_EN             ),
    .c_RESET_TYPE        (RESET_TYPE_SEL        ),    // reset type legal valve "ASYNC_RESET_SYNC_RELEASE" "SYNC_RESET" "ASYNC_RESET"
    .c_POWER_OPT         (POWER_OPT             ),    // 0 :normal mode  1:low power mode legal value:0 or 1
    .c_RD_CLK_OR_POL_INV (RD_CLK_OR_POL_INV     ),    // clk polarity invert for output register  legal value: 0 or 1
    .c_WR_BYTE_EN        (WR_BYTE_EN            ),    // byte write enable                       legal value: 0 or 1
    .c_BE_WIDTH          (BE_WIDTH              ),    // byte width legal value: 1~128
    .c_FIFO_TYPE         (FIFO_TYPE_SEL         ),    // fifo type legal value "SYN" or "ASYN"
    .c_ALMOST_FULL_NUM   (ALMOST_FULL_NUM       ),    // almost full number
    .c_ALMOST_EMPTY_NUM  (ALMOST_EMPTY_NUM      )     // almost full number
    ) U_ipml_fifo_write_ddr_fifo
    (
    
    .wr_clk         ( wr_clk         ) ,    // input write clock
    .wr_rst         ( wr_rst         ) ,    // input write reset
    
    .wr_en          ( wr_en          ) ,    // input write enable 1 active
    .wr_data        ( wr_data_wrap   ) ,    // input write data
    .wr_full        ( wr_full        ) ,    // input write full  flag 1 active
    .wr_byte_en     ( wr_byte_en_mux ) ,    // input write byte enable
    .almost_full    ( almost_full    ) ,    // output write almost full
    .wr_water_level ( wr_water_level ) ,    // output write water level
    
    .rd_clk         ( rd_clk         ) ,    // input  read clock
    .rd_rst         ( rd_rst         ) ,    // input read reset
    
    .rd_en          ( rd_en          ) ,    // input  read enable
    .rd_data        ( rd_data_wrap   ) ,    // output read data
    .rd_oce         ( rd_oce_mux     ) ,    // output read output register enable
    .rd_empty       ( rd_empty       ) ,    // output read empty
    .almost_empty   ( almost_empty   ) ,    // output read water level
    .rd_water_level ( rd_water_level )
    );

endmodule
