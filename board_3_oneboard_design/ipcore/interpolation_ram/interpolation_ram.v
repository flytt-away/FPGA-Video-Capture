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
// Filename:interpolation_ram.v
//////////////////////////////////////////////////////////////////////////////

module interpolation_ram
    (
    wr_data        , //input write data
    wr_addr        , //input write address
    wr_en          , //input write enable
    wr_clk         , //input write clock
    
    wr_rst         , //input write reset
    
    rd_data        , //output read data
    rd_addr        , //input read address
    rd_clk         , //input read clock
    
    rd_rst           //input read reset
    );


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
localparam  SIM_DEVICE         = ((DEVICE_NAME == "PGL22G") || (DEVICE_NAME == "PGL22GS")) ? "PGL22G" : "LOGOS";


input  [WR_DATA_WIDTH-1:0]    wr_data        ; //input write data    [WR_DATA_WIDTH-1:0]
input  [WR_ADDR_WIDTH-1:0]    wr_addr        ; //input write address [WR_ADDR_WIDTH-1:0]
input                         wr_en          ; //input write enable
input                         wr_clk         ; //input write clock

input                         wr_rst         ; //input write reset

output [RD_DATA_WIDTH-1:0]    rd_data        ; //output read data    [C_RD_DATA_WIDTH-1:0]
input  [RD_ADDR_WIDTH-1:0]    rd_addr        ; //input read address [RD_ADDR_WIDTH-1:0]
input                         rd_clk         ; //input read clock 

input                         rd_rst         ; //input read reset


wire  [WR_DATA_WIDTH-1:0]     wr_data        ; //input write data    [WR_DATA_WIDTH-1:0]
wire  [WR_ADDR_WIDTH-1:0]     wr_addr        ; //input write address [WR_ADDR_WIDTH-1:0]
wire                          wr_en          ; //input write enable
wire                          wr_clk         ; //input write clock
wire                          wr_clk_en      ; //input write clock enable
wire                          wr_rst         ; //input write reset
wire  [BE_WIDTH-1:0]          wr_byte_en     ; //input write reset
wire                          wr_addr_strobe ; //input write address string
wire  [RD_DATA_WIDTH-1:0]     rd_data        ; //output read data    [C_RD_DATA_WIDTH-1:0]
wire  [RD_ADDR_WIDTH-1:0]     rd_addr        ; //input read address [RD_ADDR_WIDTH-1:0]
wire                          rd_clk         ; //input read clock 
wire                          rd_clk_en      ; //input read clock enable
wire                          rd_rst         ; //input read reset
wire                          rd_oce         ; //input read output register enable
wire                          rd_addr_strobe ; //input read address string

wire  [BE_WIDTH-1:0]          wr_byte_en_mux     ;
wire                          rd_oce_mux         ;
wire                          wr_clk_en_mux      ;
wire                          rd_clk_en_mux      ;
wire                          wr_addr_strobe_mux ;
wire                          rd_addr_strobe_mux ;

wire [WR_DATA_WIDTH_WRAP-1 : 0] wr_data_wrap;
wire [RD_DATA_WIDTH_WRAP-1 : 0] rd_data_wrap;

assign wr_byte_en_mux      = (WR_BYTE_EN == 1) ? wr_byte_en : -1  ;
assign rd_oce_mux          = (RD_OCE_EN  == 1) ? rd_oce     :
                             (OUTPUT_REG == 1) ? 1'b1 : 1'b0 ;
assign wr_clk_en_mux       = (WR_CLK_EN  == 1) ? wr_clk_en  : 1'b1 ;
assign rd_clk_en_mux       = (RD_CLK_EN  == 1) ? rd_clk_en  : 1'b1 ;
assign wr_addr_strobe_mux  = (WR_ADDR_STROBE_EN ==1) ? wr_addr_strobe : 1'b0 ;
assign rd_addr_strobe_mux  = (RD_ADDR_STROBE_EN ==1) ? rd_addr_strobe : 1'b0 ;

assign wr_data_wrap    = ((DEVICE_NAME == "PGT30G") && (WR_DATA_WIDTH <= 9)) ? {{(WR_DATA_WIDTH_WRAP - WR_DATA_WIDTH){1'b0}},wr_data} : wr_data;
assign rd_data         = ((DEVICE_NAME == "PGT30G") && (RD_DATA_WIDTH <= 9)) ? rd_data_wrap[RD_DATA_WIDTH-1 : 0] : rd_data_wrap;


//ipml_sdpram IP instance
ipml_sdpram_v1_6_interpolation_ram
    #(
    .c_SIM_DEVICE           (SIM_DEVICE             ),
    .c_WR_ADDR_WIDTH        (WR_ADDR_WIDTH          ),
    .c_WR_DATA_WIDTH        (WR_DATA_WIDTH_WRAP     ),
    .c_RD_ADDR_WIDTH        (RD_ADDR_WIDTH          ),
    .c_RD_DATA_WIDTH        (RD_DATA_WIDTH_WRAP     ),
    .c_OUTPUT_REG           (OUTPUT_REG             ),
    .c_RD_OCE_EN            (RD_OCE_EN              ),
    .c_WR_ADDR_STROBE_EN    (WR_ADDR_STROBE_EN      ),
    .c_RD_ADDR_STROBE_EN    (RD_ADDR_STROBE_EN      ),
    .c_WR_CLK_EN            (WR_CLK_EN              ),
    .c_RD_CLK_EN            (RD_CLK_EN              ),
    .c_RD_CLK_OR_POL_INV    (RD_CLK_OR_POL_INV      ),
    .c_RESET_TYPE           (RESET_TYPE_CTRL        ),
    .c_POWER_OPT            (POWER_OPT              ),
    .c_INIT_FILE            ("NONE"                 ),
    .c_INIT_FORMAT          (INIT_FORMAT            ),
    .c_WR_BYTE_EN           (WR_BYTE_EN             ),
    .c_BE_WIDTH             (BE_WIDTH               )
    ) U_ipml_sdpram_interpolation_ram
    (
    .wr_data                (wr_data_wrap           ),//input write data
    .wr_addr                (wr_addr                ),//input write address
    .wr_en                  (wr_en                  ),//input write enable
    .wr_clk                 (wr_clk                 ),//input write clock
    .wr_clk_en              (wr_clk_en_mux          ),//input write clock enable
    .wr_rst                 (wr_rst                 ),//input write reset
    .wr_byte_en             (wr_byte_en_mux         ),//input write byte enable
    .wr_addr_strobe         (wr_addr_strobe_mux     ),//input write address strobe

    .rd_data                (rd_data_wrap           ),//output read data
    .rd_addr                (rd_addr                ),//input read address
    .rd_clk                 (rd_clk                 ),//input read clock 
    .rd_clk_en              (rd_clk_en_mux          ),//input read clock enable
    .rd_rst                 (rd_rst                 ),//input read reset
    .rd_oce                 (rd_oce_mux             ),//input read output register enable
    .rd_addr_strobe         (rd_addr_strobe_mux     ) //input read address strobe
    );

endmodule
