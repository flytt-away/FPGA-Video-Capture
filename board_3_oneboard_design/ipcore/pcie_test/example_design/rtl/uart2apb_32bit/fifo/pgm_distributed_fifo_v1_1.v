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
// Filename:pgm_distributed_fifo_v1_1.v
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

module pgm_distributed_fifo_v1_1 
 #(
  parameter  ADDR_WIDTH               = 10            ,  // fifo depth width 4 -- 10   
  parameter  DATA_WIDTH               = 32            ,  // write data width 1 -- 256 
  parameter  RST_TYPE                 = "ASYNC"       ,  //reset type   "ASYNC" "SYNC"
  parameter  OUT_REG                  = 0             ,  // output register   legal value:0 or 1
  parameter  FIFO_TYPE                = "ASYNC_FIFO"  ,  // fifo type legal value "SYNC_FIFO" or "ASYNC_FIFO"
  parameter  ALMOST_FULL_NUM          = 4             ,  // almost full number 
  parameter  ALMOST_EMPTY_NUM         = 4                // almost full number      
 )
 (  
  input     [DATA_WIDTH-1 : 0]        wr_data         ,  // input write data
  input                               wr_en           ,  // input write enable 1 active
  input                               wr_clk          ,  // input write clock
  output                              full            ,  // output write full  flag 1 active
  input                               wr_rst          ,  // input write reset
  output                              almost_full     ,  // output write almost full
  output    [ADDR_WIDTH : 0]          wr_water_level  ,  // output write water level  

  output    [DATA_WIDTH-1 : 0]        rd_data         ,  // output read data
  input                               rd_en           ,  // input  read enable
  input                               rd_clk          ,  // input  read clock   
  output                              empty           ,  // output read empty 
  input                               rd_rst          ,  // input read reset
  output                              almost_empty    ,
  output    [ADDR_WIDTH : 0]          rd_water_level                                                                                   
);


//declare inner variables
 wire  [ADDR_WIDTH-1 : 0]  wr_addr         ;
 wire  [ADDR_WIDTH-1 : 0]  rd_addr         ;
 wire                      wr_en_tmp       ; 

assign   wr_en_tmp =  wr_en & (~full);                               
//instance sdpram
pgm_distributed_sdpram_v1_1 
#(
 .ADDR_WIDTH(ADDR_WIDTH )  ,    //address width   range:4-10
 .DATA_WIDTH(DATA_WIDTH )  ,    //data width      range:4-256     
 .RST_TYPE  (RST_TYPE   )  ,    //reset type   "ASYNC_RESET" "SYNC_RESET"
 .OUT_REG   (OUT_REG    )                    
 ) pgm_distributed_sdpram
 (
  .wr_data  (wr_data    )  ,
  .wr_addr  (wr_addr    )  ,
  .rd_addr  (rd_addr    )  ,  
  .wr_clk   (wr_clk     )  ,
  .rd_clk   (rd_clk     )  ,
  .wr_en    (wr_en_tmp  )  ,
  .rst      (rd_rst     )  ,
  .rd_data  (rd_data    )
 );


pgm_distributed_fifo_ctr_v1_0 
 #(
  .DEPTH            (ADDR_WIDTH      ),           // write and read address width 4-- 10
  .FIFO_TYPE        (FIFO_TYPE       ),
  .ALMOST_FULL_NUM  (ALMOST_FULL_NUM ),
  .ALMOST_EMPTY_NUM (ALMOST_EMPTY_NUM)
   
)u_pgm_distributed_fifo_ctr_v1_0
( 
  .wr_clk           (wr_clk          ),            //write clock 
  .w_en             (wr_en           ),             //write enable 1 active 
  .wr_addr          (wr_addr         ),           //write address 
  .wrst             (wr_rst          ),          //write reset 
  .wfull            (full            ),           //write full flag 1 active
  .almost_full      (almost_full     ),
  .wr_water_level   (wr_water_level  ),
    
  .rd_clk           (rd_clk          ),           //read clock
  .r_en             (rd_en           ),            //read enable 1 active 
  .rd_addr          (rd_addr         ),          //read address
  .rrst             (rd_rst          ),         //read reset
  .rempty           (empty           ),         //read empty  1 active      
  .almost_empty     (almost_empty    ),
  .rd_water_level   (rd_water_level  )
  
);    
 
 
 

endmodule