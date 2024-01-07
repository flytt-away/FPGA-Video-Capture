//******************************************************************
// Copyright (c) 2015 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************

`timescale 1ns/1ps

module pgs_pciex4_fifo_v1_2 #(
  parameter  ADDR_WIDTH               = 10            ,  // fifo depth width 4 -- 10
  parameter  DATA_WIDTH               = 32            ,  // write data width 1 -- 256
  parameter  OUT_REG                  = 0
)
(
   input                               clk             ,  // input write clock
   input                               rst_n           ,  // input write reset

   input     [DATA_WIDTH-1 : 0]        wr_data         ,  // input write data
   input                               wr_en           ,  // input write enable 1 active
   output                              full            ,  // output write full  flag 1 active


   output    [DATA_WIDTH-1 : 0]        rd_data         ,  // output read data
   input                               rd_en           ,  // input  read enable
   output                              empty             // output read empty
);

 wire  [ADDR_WIDTH-1 : 0]  wr_addr         ;
 wire  [ADDR_WIDTH-1 : 0]  rd_addr         ;
 wire                      wr_en_tmp       ;
 wire                      rd_en_tmp       ;

assign   wr_en_tmp =  wr_en & (~full);
assign   rd_en_tmp =  rd_en & (~empty);

//instance sdpram
ipm_distributed_sdpram_v1_2_distributed_fifo
#(
 .ADDR_WIDTH(ADDR_WIDTH )  ,    //address width   range:4-10
 .DATA_WIDTH(DATA_WIDTH )  ,    //data width      range:4-256
 .RST_TYPE  ("ASYNC"   )  ,    //reset type   "ASYNC_RESET" "SYNC_RESET"
 .OUT_REG   (OUT_REG    )
 ) ipm_distributed_sdpram_distributed_fifo
 (
  .wr_data  (wr_data    )  ,
  .wr_addr  (wr_addr    )  ,
  .rd_addr  (rd_addr    )  ,
  .wr_clk   (clk        )  ,
  .rd_clk   (clk        )  ,
  .wr_en    (wr_en_tmp  )  ,
  .rst      (~rst_n     )  ,
  .rd_data  (rd_data    )
 );

pgs_pciex4_fifo_ctrl
 #(
  .ADDR_WIDTH       (ADDR_WIDTH      )
  ) pgs_pciex4_fifo_ctrl
  (
  .clk              (clk             ),            //write clock
  .w_en             (wr_en_tmp       ),             //write enable 1 active
  .wr_addr          (wr_addr         ),           //write address          //write reset
  .wfull            (full            ),           //write full flag 1 active
  .r_en             (rd_en_tmp       ),            //read enable 1 active
  .rd_addr          (rd_addr         ),          //read address
  .rst_n            (rst_n           ),         //read reset
  .rempty           (empty           )         //read empty  1 active
);

endmodule //pgs_pciex4_fifo
