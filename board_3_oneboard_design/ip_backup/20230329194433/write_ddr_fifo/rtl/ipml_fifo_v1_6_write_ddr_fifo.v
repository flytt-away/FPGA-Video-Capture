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
// Filename:ipml_fifo.v
//
// Functional description: parameterized FIFO : cascade DRMS to flex FIFO   
// Submodule list: 1) DRM18K
// Revision: v0
//                 
//////////////////////////////////////////////////////////////////////////////

module ipml_fifo_v1_6_write_ddr_fifo
 #(
  parameter  c_SIM_DEVICE        = "LOGOS"       ,
  parameter  c_WR_DEPTH_WIDTH    = 10            ,           // fifo depth width 9 -- 20   legal value:9~20  
  parameter  c_WR_DATA_WIDTH     = 32            ,           // write data width 1 -- 1152 1)c_WR_BYTE_EN =0 legal value:1~1152  2)c_WR_BYTE_EN=1  legal value:2^N or 9*2^N
  parameter  c_RD_DEPTH_WIDTH    = 10            ,           // read address width 9 -- 20 legal value:1~20 
  parameter  c_RD_DATA_WIDTH     = 32            ,           // read data width 1 -- 1152  1)c_WR_BYTE_EN =0 legal value:1~1152  2)c_WR_BYTE_EN=1  legal value:2^N or 9*2^N
  parameter  c_OUTPUT_REG        = 0             ,           // output register            legal value:0 or 1
  parameter  c_RD_OCE_EN         = 0             ,
  parameter  c_RESET_TYPE        = "ASYNC_RESET" ,           // reset type legal valve "ASYNC_RESET_SYNC_RELEASE" "SYNC_RESET" "ASYNC_RESET"
  parameter  c_POWER_OPT         = 0             ,           // 0 :normal mode  1:low power mode legal value:0 or 1
  parameter  c_RD_CLK_OR_POL_INV = 0             ,           // clk polarity invert for output register  legal value: 0 or 1
  parameter  c_WR_BYTE_EN        = 0             ,               // byte write enable                       legal value: 0 or 1
  parameter  c_BE_WIDTH          = 8             ,           // byte width legal value: 1~128
  parameter  c_FIFO_TYPE         = "SYN"         ,           // fifo type legal value "SYN" or "ASYN"
  parameter  c_ALMOST_FULL_NUM   = 508           ,           // almost full number
  parameter  c_ALMOST_EMPTY_NUM  = 4                         // almost full number
)
 (
  input  wire  [c_WR_DATA_WIDTH-1 : 0]                  wr_data         ,  // input write data
  input  wire                                           wr_en           ,  // input write enable 1 active
  input  wire                                           wr_clk          ,  // input write clock
  output wire                                           wr_full         ,  // input write full  flag 1 active
  input  wire                                           wr_rst          ,  // input write reset
  input  wire  [c_BE_WIDTH-1 : 0]                       wr_byte_en      ,  // input write byte enable
  output wire                                           almost_full     ,  // output write almost full
  output wire  [c_WR_DEPTH_WIDTH : 0]                   wr_water_level  ,  // output write water level

  output wire  [c_RD_DATA_WIDTH-1 : 0]                  rd_data         ,  // output read data
  input  wire                                           rd_en           ,  // input  read enable
  input  wire                                           rd_clk          ,  // input  read clock
  output wire                                           rd_empty        ,  // output read empty
  input  wire                                           rd_rst          ,  // input read reset
  input  wire                                           rd_oce          ,  // output read output register enable
  output wire                                           almost_empty    ,  // output read water level
  output wire  [c_RD_DEPTH_WIDTH : 0]                   rd_water_level

);

//**************************************************************************************************************
//declare inner variables
 wire  [c_WR_DEPTH_WIDTH-1 : 0]  wr_addr;
 wire  [c_RD_DEPTH_WIDTH-1 : 0]  rd_addr;

//**************************************************************************************************************
//instance ipml_flex_sdpram
ipml_sdpram_v1_6_write_ddr_fifo
  #(
  .c_SIM_DEVICE     (c_SIM_DEVICE),
  .c_WR_ADDR_WIDTH  (c_WR_DEPTH_WIDTH),          //write address width
  .c_WR_DATA_WIDTH  (c_WR_DATA_WIDTH),           //write data width
  .c_RD_ADDR_WIDTH  (c_RD_DEPTH_WIDTH),          //read address width 
  .c_RD_DATA_WIDTH  (c_RD_DATA_WIDTH),           //read data width
  .c_OUTPUT_REG     (c_OUTPUT_REG),              //output register
  .c_RD_OCE_EN      (c_RD_OCE_EN),

  .c_WR_ADDR_STROBE_EN (0),
  .c_RD_ADDR_STROBE_EN (0),

  .c_WR_CLK_EN      (1),
  .c_RD_CLK_EN      (1),
  .c_RESET_TYPE     (c_RESET_TYPE),              //ASYNC_RESET_SYNC_RELEASE SYNC_RESET  
  .c_POWER_OPT      (c_POWER_OPT),               //0 :normal mode  1:low power mode
  .c_RD_CLK_OR_POL_INV(c_RD_CLK_OR_POL_INV),     //clk polarity invert for output register
  .c_INIT_FILE      ("NONE"),                    //false  NONE or initial file name
  .c_INIT_FORMAT    ("BIN"),                     //bin or hex 
  .c_WR_BYTE_EN     (c_WR_BYTE_EN),              //false
  .c_BE_WIDTH       (c_BE_WIDTH)
) U_ipml_sdpram (

  .wr_data       (wr_data),   //input write data    [c_WR_DATA_WIDTH-1:0]
  .wr_addr       (wr_addr),   //input write address [c_WR_DEPTH_WIDTH-1:0]
  .wr_en         (wr_en),     //input write enable
  .wr_clk        (wr_clk),    //input write clock
  .wr_clk_en     (1'b1),      //input write clock enable
  .wr_rst        (wr_rst),    //input write reset
  .wr_byte_en    (wr_byte_en),//"false"
  .wr_addr_strobe (1'b0),

  .rd_data      (rd_data),   //output read data    [C_RD_DATA_WIDTH-1:0]
  .rd_addr      (rd_addr),   //output read address [c_RD_DEPTH_WIDTH-1:0]
  .rd_clk       (rd_clk),    //output read clock 
  .rd_clk_en    (rd_en),     //output read clock enable
  .rd_rst       (rd_rst),    //output read reset
  .rd_oce       (rd_oce),    //output read output register enable
  .rd_addr_strobe (1'b0)
 );

ipml_fifo_ctrl_v1_3 
 #(
  .c_WR_DEPTH_WIDTH    (c_WR_DEPTH_WIDTH),// write address width 8-- 20
  .c_RD_DEPTH_WIDTH    (c_RD_DEPTH_WIDTH),// read address width 8 -- 20   
  .c_FIFO_TYPE         (c_FIFO_TYPE),
  .c_ALMOST_FULL_NUM   (c_ALMOST_FULL_NUM),
  .c_ALMOST_EMPTY_NUM  (c_ALMOST_EMPTY_NUM)
)
U_ipml_fifo_ctrl
( 
  .wclk          (wr_clk),            //write clock 
  .w_en          (wr_en),             //write enable 1 active 
  .waddr         (wr_addr),           //write address 
  .wrst          (wr_rst),            //write reset 
  .wfull         (wr_full),           //write full flag 1 active
  .almost_full   (almost_full),
  .wr_water_level(wr_water_level),

  .rclk          (rd_clk),           //read clock
  .r_en          (rd_en),            //read enable 1 active
  .raddr         (rd_addr),          //read address
  .rrst          (rd_rst),           //read reset
  .rempty        (rd_empty),         //read empty  1 active
  .almost_empty  (almost_empty),
  .rd_water_level(rd_water_level)
);

endmodule
