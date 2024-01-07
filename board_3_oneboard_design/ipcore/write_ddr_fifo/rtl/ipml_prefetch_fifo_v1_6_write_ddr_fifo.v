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

module ipml_prefetch_fifo_v1_6_write_ddr_fifo
 #(
  parameter  c_SIM_DEVICE        = "LOGOS"       ,
  parameter  c_WR_DEPTH_WIDTH    = 10            ,           // fifo depth width 9 -- 20   legal value:9~20  
  parameter  c_WR_DATA_WIDTH     = 32            ,           // write data width 1 -- 1152 1)c_WR_BYTE_EN =0 legal value:1~1152  2)c_WR_BYTE_EN=1  legal value:2^N or 9*2^N
  parameter  c_RD_DEPTH_WIDTH    = 10            ,           // read address width 9 -- 20 legal value:1~20 
  parameter  c_RD_DATA_WIDTH     = 32            ,           // read data width 1 -- 1152  1)c_WR_BYTE_EN =0 legal value:1~1152  2)c_WR_BYTE_EN=1  legal value:2^N or 9*2^N
  parameter  c_RESET_TYPE        = "ASYNC_RESET" ,           // reset type legal valve "ASYNC_RESET_SYNC_RELEASE" "SYNC_RESET" "ASYNC_RESET"
  parameter  c_POWER_OPT         = 0             ,           // 0 :normal mode  1:low power mode legal value:0 or 1
  parameter  c_FIFO_TYPE         = "SYN"                     // fifo type legal value "SYN" or "ASYN"
)
 (  
  input  wire  [c_WR_DATA_WIDTH-1 : 0]                  wr_data         ,  // input write data
  input  wire                                           wr_en           ,  // input write enable 1 active
  output wire                                           wr_vld          ,
  input  wire                                           wr_clk          ,  // input write clock
  input  wire                                           wr_rst          ,  // input write reset

  output wire  [c_RD_DATA_WIDTH-1 : 0]                  rd_data         ,  // output read data
  input  wire                                           rd_en           ,  // input  read enable
  output wire                                           rd_vld          ,
  input  wire                                           rd_clk          ,  // input  read clock
  input  wire                                           rd_rst             // input read reset

);

//**************************************************************************************************************
//declare inner variables
 wire  [c_WR_DEPTH_WIDTH-1 : 0]  wr_addr;
 wire  [c_RD_DEPTH_WIDTH-1 : 0]  rd_addr;

 wire                            wr_en_mux  ;
 wire                            rd_en_mux  ;

 reg                             rd_en_ff;
 wire                            rd_vld_pre;
 reg   [2:0]                     shift_vld;
 wire                            rd_en_pre;
 reg                             rd_en_pre_ff1;
 wire  [c_RD_DATA_WIDTH-1 : 0]   rd_data_org;
 wire                            pop;

//**************************************************************************************************************
//instance ipml_flex_sdpram
ipml_sdpram_v1_6_write_ddr_fifo
  #(
  .c_SIM_DEVICE     (c_SIM_DEVICE),
  .c_WR_ADDR_WIDTH  (c_WR_DEPTH_WIDTH),          //write address width
  .c_WR_DATA_WIDTH  (c_WR_DATA_WIDTH),           //write data width
  .c_RD_ADDR_WIDTH  (c_RD_DEPTH_WIDTH),          //read address width 
  .c_RD_DATA_WIDTH  (c_RD_DATA_WIDTH),           //read data width
  .c_OUTPUT_REG     (0),                         //output register
  .c_RD_OCE_EN      (0),

  .c_WR_ADDR_STROBE_EN (0),
  .c_RD_ADDR_STROBE_EN (0),

  .c_WR_CLK_EN      (1),
  .c_RD_CLK_EN      (1),
  .c_RESET_TYPE     (c_RESET_TYPE),              //ASYNC_RESET_SYNC_RELEASE SYNC_RESET  
  .c_POWER_OPT      (c_POWER_OPT),               //0 :normal mode  1:low power mode
  .c_RD_CLK_OR_POL_INV(0),                       //clk polarity invert for output register
  .c_INIT_FILE      ("NONE"),                    //false  NONE or initial file name
  .c_INIT_FORMAT    ("BIN"),                     //bin or hex
  .c_WR_BYTE_EN     (0),                         //false
  .c_BE_WIDTH       (8)
)
U_ipml_sdpram
 (

  .wr_data          (wr_data),      //input write data    [c_WR_DATA_WIDTH-1:0]
  .wr_addr          (wr_addr),      //input write address [c_WR_DEPTH_WIDTH-1:0]
  .wr_en            (wr_en_mux),    //input write enable
  .wr_clk           (wr_clk),       //input write clock
  .wr_clk_en        (1'b1),         //input write clock enable
  .wr_rst           (wr_rst),       //input write reset
  .wr_byte_en       (-1),           //"false"
  .wr_addr_strobe   (1'b0),

  .rd_data          (rd_data_org),  //output read data    [C_RD_DATA_WIDTH-1:0]
  .rd_addr          (rd_addr),      //output read address [c_RD_DEPTH_WIDTH-1:0]
  .rd_clk           (rd_clk),       //output read clock 
  .rd_clk_en        (rd_en_mux),    //output read clock enable
  .rd_rst           (rd_rst),       //output read reset
  .rd_oce           (1'b0),         //output read output register enable
  .rd_addr_strobe   (1'b0)
 );

ipml_fifo_ctrl_v1_3 
 #(
  .c_WR_DEPTH_WIDTH    (c_WR_DEPTH_WIDTH),  // write address width 8-- 20
  .c_RD_DEPTH_WIDTH    (c_RD_DEPTH_WIDTH),  // read address width 8 -- 20
  .c_FIFO_TYPE         (c_FIFO_TYPE)
) U_ipml_fifo_ctrl( 
  .wclk          (wr_clk),            //write clock
  .w_en          (wr_en_mux),         //write enable 1 active
  .waddr         (wr_addr),           //write address
  .wrst          (wr_rst),            //write reset
  .wfull         (wr_full),           //write full flag 1 active
  .almost_full   (almost_full),
  .wr_water_level(wr_water_level),
    
  .rclk          (rd_clk),           //read clock
  .r_en          (rd_en_mux),        //read enable 1 active
  .raddr         (rd_addr),          //read address
  .rrst          (rd_rst),           //read reset
  .rempty        (rd_empty),         //read empty  1 active
  .almost_empty  (almost_empty),
  .rd_water_level(rd_water_level)
  
);    

assign wr_vld    = ~wr_full;
assign rd_vld    = rd_vld_pre;
assign wr_en_mux = wr_en & wr_vld;
assign rd_en_mux = rd_en_pre;

always@(posedge rd_clk or posedge rd_rst)
begin
    if (rd_rst)
        rd_en_ff <= 1'b0;
    else
        rd_en_ff <= ~rd_empty & rd_en;
end

assign rd_en_pre = (~shift_vld[2] | rd_en) & ~rd_empty;
always@(posedge rd_clk or posedge rd_rst)
begin
    if (rd_rst)
        rd_en_pre_ff1 <= 1'b0;
    else
        rd_en_pre_ff1 <= rd_en_pre;
end

assign pop = rd_vld & rd_en;
always@(posedge rd_clk or posedge rd_rst)
begin
    if (rd_rst)
        shift_vld <= 3'b001;
    else
    begin
        case ({rd_en_pre, pop})
            2'b10  : shift_vld <= {shift_vld[1:0], shift_vld[2]};
            2'b01  : shift_vld <= {shift_vld[0], shift_vld[2:1]};
            default: shift_vld <= 3'b000;
        endcase 
    end
end

// Depth = 2
ipml_reg_fifo_v1_0
    #(
    .W ( c_RD_DATA_WIDTH )
    )
    ipml_reg_fifo
    (
    .clk            ( rd_clk         ),
    .rst_n          ( ~rd_rst        ),
    .data_in_valid  ( rd_en_pre_ff1  ),
    .data_in        ( rd_data_org    ),
    .data_in_ready  (                ),
    .data_out_ready ( rd_en          ),
    .data_out       ( rd_data        ),
    .data_out_valid ( rd_vld_pre     )
);

endmodule
