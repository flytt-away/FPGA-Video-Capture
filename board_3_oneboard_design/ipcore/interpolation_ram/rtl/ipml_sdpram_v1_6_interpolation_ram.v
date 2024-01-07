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
// Filename:ipml_sdpram.v                 
//////////////////////////////////////////////////////////////////////////////

module ipml_sdpram_v1_6_interpolation_ram
  #(
    parameter  c_SIM_DEVICE        = "LOGOS"       ,
    parameter  c_WR_ADDR_WIDTH     = 10            ,  //write address width legal value:9~20
    parameter  c_WR_DATA_WIDTH     = 32            ,  //write data width 1)c_WR_BYTE_EN =0 legal value:1~1152  2)c_WR_BYTE_EN=1  legal value:2^N or 9*2^N
    parameter  c_RD_ADDR_WIDTH     = 10            ,  //read address width legal value:9~20
    parameter  c_RD_DATA_WIDTH     = 32            ,  //read data width 1)c_WR_BYTE_EN =0 legal value:1~1152  2)c_WR_BYTE_EN=1  legal value:2^N or 9*2^N
    parameter  c_OUTPUT_REG        = 0             ,  //output register enable legal value:0 or 1
    parameter  c_RD_OCE_EN         = 0             ,  //rd_oce enable
    parameter  c_WR_ADDR_STROBE_EN = 0             ,
    parameter  c_RD_ADDR_STROBE_EN = 0             ,
    parameter  c_WR_CLK_EN         = 0             ,
    parameter  c_RD_CLK_EN         = 0             ,
    parameter  c_RD_CLK_OR_POL_INV = 0             ,  //clk polarity invert for output register legal value 1 or 0
    parameter  c_RESET_TYPE        = "ASYNC_RESET" ,  //reset type legal valve "ASYNC_RESET_SYNC_RELEASE" "SYNC_RESET" "ASYNC_RESET"
    parameter  c_POWER_OPT         = 0             ,  //0 :normal mode  1:low power mode        legal value:0 or 1
    parameter  c_INIT_FILE         = "NONE"        ,  //legal value:"NONE" or "initial file name"
    parameter  c_INIT_FORMAT       = "BIN"         ,  //initial data format legal valve: "bin" or "hex"
    parameter  c_WR_BYTE_EN        = 0             ,  //byte write enable legal value: 0 or 1
    parameter  c_BE_WIDTH          = 4               //byte width legal value: 1~128
   )
   (

    input  wire  [c_WR_DATA_WIDTH-1:0]  wr_data        , //input write data    [c_WR_DATA_WIDTH-1:0]
    input  wire  [c_WR_ADDR_WIDTH-1:0]  wr_addr        , //input write address [c_WR_ADDR_WIDTH-1:0]
    input  wire                         wr_en          , //input write enable
    input  wire                         wr_clk         , //input write clock
    input  wire                         wr_clk_en      , //input write clock enable
    input  wire                         wr_rst         , //input write reset
    input  wire  [c_BE_WIDTH-1:0]       wr_byte_en     ,
    input  wire                         wr_addr_strobe ,
                 
    output wire  [c_RD_DATA_WIDTH-1:0]  rd_data        , //output read data    [C_RD_DATA_WIDTH-1:0]
    input  wire  [c_RD_ADDR_WIDTH-1:0]  rd_addr        , //output read address [c_RD_ADDR_WIDTH-1:0]
    input  wire                         rd_clk         , //output read clock 
    input  wire                         rd_clk_en      , //output read clock enable
    input  wire                         rd_rst         , //output read reset
    input  wire                         rd_oce         , //output read output register enable
    input  wire                         rd_addr_strobe
   );

//*************************************************************************************************************************************

localparam INIT_EN = 0 ; // @IPC bool

localparam MODE_9K = 0 ; // @IPC bool

localparam MODE_18K = 1 ; // @IPC bool

//

//********************************************************************************************************************************************************************   
//declare localparam
//********************************************************************************************************************************************************************   
localparam  c_WR_BYTE_WIDTH = c_WR_BYTE_EN ? (c_WR_DATA_WIDTH/(c_BE_WIDTH==0 ? 1 : c_BE_WIDTH)) : ( (c_WR_DATA_WIDTH%9 ==0) ? 9 : (c_WR_DATA_WIDTH%8 ==0) ? 8 : 9 );
localparam  ADDR_STROBE_EN  = (c_WR_ADDR_STROBE_EN == 1) || (c_RD_ADDR_STROBE_EN == 1);
//c_WR_DATA_WIDTH == 2^N
//WIDTH_RATIO = 1  
//L_DATA_WIDTH is the parameter value of DATA_WIDTH_A and DATA_WIDTH_B in a instance DRM ,define witch type DRM to instance in noraml mode
localparam  DATA_WIDTH_WIDE  =  c_WR_DATA_WIDTH >= c_RD_DATA_WIDTH ? c_WR_DATA_WIDTH :c_RD_DATA_WIDTH ; //wider DATA_WIDTH between c_WR_DATA_WIDTH and c_RD_DATA_WIDTH 
localparam  ADDR_WIDTH_WIDE  =  c_WR_DATA_WIDTH >= c_RD_DATA_WIDTH ? c_WR_ADDR_WIDTH :c_RD_ADDR_WIDTH ; //ADDR WIDTH correspond to DATA_WIDTH_WIDE

localparam  DATA_WIDTH_NARROW = c_WR_DATA_WIDTH >= c_RD_DATA_WIDTH ? c_RD_DATA_WIDTH :c_WR_DATA_WIDTH ;
localparam  ADDR_WIDTH_NARROW = c_WR_DATA_WIDTH >= c_RD_DATA_WIDTH ? c_RD_ADDR_WIDTH :c_WR_ADDR_WIDTH ;

localparam  DATA_WIDTH_W2N    = c_WR_DATA_WIDTH >= c_RD_DATA_WIDTH ? 1 : 0 ;

localparam  N_DATA_1_WIDTH   =  ADDR_WIDTH_WIDE <= 9  ? ( (DATA_WIDTH_WIDE%9 == 0) ? ( (ADDR_STROBE_EN == 1) ? 18 : 36 ) :
                                                          (DATA_WIDTH_WIDE%8 == 0) ? ( (ADDR_STROBE_EN == 1) ? 16 : 32 ) : 
                                                                                     ( (ADDR_STROBE_EN == 1) ? 18 : 36 ) ) :     //cascade with 512*36 type DRM 
                                ADDR_WIDTH_WIDE == 10 ? (DATA_WIDTH_WIDE%9 == 0) ? 18 : 
                                                       ((DATA_WIDTH_WIDE%8 == 0) ? 16 : 
                                                                                   18 ) :     //cascade with 1k*18  type DRM
                                ADDR_WIDTH_WIDE == 11 ? (DATA_WIDTH_WIDE%9 == 0)  ? 9 : 
                                                       ((DATA_WIDTH_WIDE%8 == 0)  ? 8 : 
                                                                                    9 ) :     //cascade with 2k*9   type DRM
                                ADDR_WIDTH_WIDE == 12 ? 4:                                    //cascade with 4k*4   type DRM
                                ADDR_WIDTH_WIDE == 13 ? 2:                                    //cascade with 8k*2   type DRM
                                                        1;                                    //cascade with 16k*1  type DRM
                                                                 
localparam  L_DATA_1_WIDTH   =  DATA_WIDTH_WIDE == 1  ? 1:                                    //cascade with 16k*1  type DRM
                                DATA_WIDTH_WIDE == 2  ? 2:                                    //cascade with 8k*2   type DRM
                                DATA_WIDTH_WIDE <= 4  ? 4:                                    //cascade with 2k*8   type DRM
                                DATA_WIDTH_WIDE <= 8  ? 8:                                    //cascade with 2k*9   type DRM
                                DATA_WIDTH_WIDE == 9  ? 9:                                    //cascade with 4k*4   type DRM
                                DATA_WIDTH_WIDE <= 16 ? 16:  
                                DATA_WIDTH_WIDE <= 18 ? 18:                                   //cascade with 1k*18  type DRM
                            ( (DATA_WIDTH_WIDE%9 == 0) ? ( (ADDR_STROBE_EN == 1) ? 18 : 36 ) :  
                              (DATA_WIDTH_WIDE%8 == 0) ? ( (ADDR_STROBE_EN == 1) ? 16 : 32 ) :
                                                         ( (ADDR_STROBE_EN == 1) ? 18 : 36 ) ) ;//cascade with 512*36 type DRM
//WIDTH_RATIO = 2
localparam  N_DATA_WIDTH_2_WIDE   =   DATA_WIDTH_WIDE%9 == 0 ? (ADDR_WIDTH_WIDE <= 9  ? (ADDR_STROBE_EN == 1) ? 18 : 36 : 
                                                                                                                18 ) :
                                      (ADDR_WIDTH_WIDE <= 9  ? (ADDR_STROBE_EN == 1) ? 16 : 32 :
                                      ADDR_WIDTH_WIDE == 10 ? 16  :
                                      ADDR_WIDTH_WIDE == 11 ? 8   :
                                      ADDR_WIDTH_WIDE == 12 ? 4   :
                                                              2 ) ;
                                     
localparam  L_DATA_WIDTH_2_WIDE   =   DATA_WIDTH_WIDE%9 == 0 ? ( (DATA_WIDTH_WIDE == 18)  ? 18 : 
                                                                                            ( (ADDR_STROBE_EN == 1) ?  18 : 36 ) ) :
                                      (DATA_WIDTH_WIDE == 2  ? 2  :
                                      DATA_WIDTH_WIDE == 4  ? 4   :
                                      DATA_WIDTH_WIDE == 8  ? 8   :
                                      DATA_WIDTH_WIDE == 16 ? 16  :
                                                              ( (ADDR_STROBE_EN == 1) ? 16 : 32 ) );
//WIDTH_RATIO == 4
localparam  N_DATA_WIDTH_4_WIDE   =   DATA_WIDTH_WIDE%9 == 0 ? ( (ADDR_STROBE_EN == 1) ? 18 : 36 ) :
                                      (ADDR_WIDTH_WIDE <= 9  ? ( (ADDR_STROBE_EN == 1) ? 16 : 32 ) :
                                      ADDR_WIDTH_WIDE == 10 ? 16  :
                                      ADDR_WIDTH_WIDE == 11 ? 8   :
                                                              4 ) ;

localparam  L_DATA_WIDTH_4_WIDE   =  DATA_WIDTH_WIDE%9 == 0 ? ( (ADDR_STROBE_EN == 1) ? 18 : 36 ) :
                                     DATA_WIDTH_WIDE == 4  ? 4  :
                                     DATA_WIDTH_WIDE == 8  ? 8  :
                                     DATA_WIDTH_WIDE == 16 ? 16 :
                                     DATA_WIDTH_WIDE == 18 ? 18 :
                                                             ( (ADDR_STROBE_EN == 1) ? 16 : 32 ) ;

//WIDTH_RATIO == 8
localparam  N_DATA_WIDTH_8_WIDE   =  ADDR_WIDTH_WIDE <= 9  ? ( (ADDR_STROBE_EN == 1) ? 16 : 32 ) :
                                     ADDR_WIDTH_WIDE == 10 ? 16:
                                                             8 ;

localparam  L_DATA_WIDTH_8_WIDE   =  DATA_WIDTH_WIDE == 8  ? 8 :
                                     DATA_WIDTH_WIDE == 16 ? 16:
                                                             ( (ADDR_STROBE_EN == 1) ? 16 : 32 ) ;
//WIDTH_RATIO == 16   
localparam  N_DATA_WIDTH_16_WIDE  =  ADDR_WIDTH_WIDE <= 9 ?  ( (ADDR_STROBE_EN == 1) ? 16 : 32 ) :
                                                            16;

localparam  L_DATA_WIDTH_16_WIDE  =  DATA_WIDTH_WIDE == 16 ? 16 :
                                                             ( (ADDR_STROBE_EN == 1) ? 16 : 32 );

//WIDTH_RATIO == 32   
localparam  N_DATA_WIDTH_32_WIDE  =  ( (ADDR_STROBE_EN == 1) ? 16 : 32 ) ;

localparam  L_DATA_WIDTH_32_WIDE  =  ( (ADDR_STROBE_EN == 1) ? 16 : 32 ) ;

//********************************************************************************************************************************************************************   
//BYTE ENABLE parameter 
//byte_enable && WIDTH_RATIO = 1
localparam  N_BYTE_DATA_1_WIDTH = (ADDR_WIDTH_WIDE <= 9) ? (c_WR_BYTE_WIDTH == 8 ? ( (ADDR_STROBE_EN == 1) ? 16 : 32 ) : 
                                                                                   ( (ADDR_STROBE_EN == 1) ? 18 : 36 ) ) :
                                                           (c_WR_BYTE_WIDTH == 8 ? 16 : 18);

localparam  L_BYTE_DATA_1_WIDTH = (c_WR_BYTE_WIDTH == 8) ? (DATA_WIDTH_WIDE <= 16 ? 16 : 
                                                                                     ( (ADDR_STROBE_EN == 1) ? 16 : 32 ) ): 
                                                           (DATA_WIDTH_WIDE <= 18 ? 18 : 
                                                                                     ( (ADDR_STROBE_EN == 1) ? 18 : 36 ) );
//byte_enable && WIDTH_RATIO = 2
localparam  N_BYTE_DATA_WIDTH_2_WIDE = (ADDR_WIDTH_WIDE <= 9) ? ( (DATA_WIDTH_WIDE%9 == 0) ? ( (ADDR_STROBE_EN == 1) ? 18 : 36 ) :
                                                                                             ( (ADDR_STROBE_EN == 1) ? 16 : 32 ) ) :
                                                                ( (DATA_WIDTH_WIDE%9 == 0) ? 18 : 16 );

localparam  L_BYTE_DATA_WIDTH_2_WIDE = (DATA_WIDTH_WIDE%9 == 0) ? (DATA_WIDTH_WIDE <= 18 ? 18 :
                                                                                           ( (ADDR_STROBE_EN == 1) ? 18 : 36 ) ): 
                                                                  (DATA_WIDTH_WIDE <= 16 ? 16 : 
                                                                                           ( (ADDR_STROBE_EN == 1) ? 16 : 32 ) );
//byte_enable && WIDTH_RATIO = 4
localparam  N_BYTE_DATA_WIDTH_4_WIDE = ( DATA_WIDTH_WIDE%9 == 0 ) ? ( (ADDR_STROBE_EN == 1) ? 18 : 36 ) :
                                                                    ( (ADDR_STROBE_EN == 1) ? 16 : 32 ) ;

localparam  L_BYTE_DATA_WIDTH_4_WIDE = N_BYTE_DATA_WIDTH_4_WIDE; 

//******************************************************************************************************************************************************************** 
localparam  WIDTH_RATIO  =  (c_WR_DATA_WIDTH > c_RD_DATA_WIDTH) ? (c_WR_DATA_WIDTH/c_RD_DATA_WIDTH) : (c_RD_DATA_WIDTH/c_WR_DATA_WIDTH);

localparam  N_DRM_DATA_WIDTH_A  = WIDTH_RATIO == 1  ? N_DATA_1_WIDTH :
                                  WIDTH_RATIO == 2  ? (c_WR_DATA_WIDTH > c_RD_DATA_WIDTH ? N_DATA_WIDTH_2_WIDE  : (N_DATA_WIDTH_2_WIDE/2)   ):
                                  WIDTH_RATIO == 4  ? (c_WR_DATA_WIDTH > c_RD_DATA_WIDTH ? N_DATA_WIDTH_4_WIDE  : (N_DATA_WIDTH_4_WIDE/4)   ):
                                  WIDTH_RATIO == 8  ? (c_WR_DATA_WIDTH > c_RD_DATA_WIDTH ? N_DATA_WIDTH_8_WIDE  : (N_DATA_WIDTH_8_WIDE/8)   ):
                                  WIDTH_RATIO == 16 ? (c_WR_DATA_WIDTH > c_RD_DATA_WIDTH ? N_DATA_WIDTH_16_WIDE : (N_DATA_WIDTH_16_WIDE/16) ):
                                                      (c_WR_DATA_WIDTH > c_RD_DATA_WIDTH ? N_DATA_WIDTH_32_WIDE : (N_DATA_WIDTH_32_WIDE/32) );
                                  
localparam  L_DRM_DATA_WIDTH_A  = WIDTH_RATIO == 1  ? L_DATA_1_WIDTH :
                                  WIDTH_RATIO == 2  ? (c_WR_DATA_WIDTH > c_RD_DATA_WIDTH ? L_DATA_WIDTH_2_WIDE  : (L_DATA_WIDTH_2_WIDE/2)   ):
                                  WIDTH_RATIO == 4  ? (c_WR_DATA_WIDTH > c_RD_DATA_WIDTH ? L_DATA_WIDTH_4_WIDE  : (L_DATA_WIDTH_4_WIDE/4)   ):
                                  WIDTH_RATIO == 8  ? (c_WR_DATA_WIDTH > c_RD_DATA_WIDTH ? L_DATA_WIDTH_8_WIDE  : (L_DATA_WIDTH_8_WIDE/8)   ):
                                  WIDTH_RATIO == 16 ? (c_WR_DATA_WIDTH > c_RD_DATA_WIDTH ? L_DATA_WIDTH_16_WIDE : (L_DATA_WIDTH_16_WIDE/16) ):
                                                      (c_WR_DATA_WIDTH > c_RD_DATA_WIDTH ? L_DATA_WIDTH_32_WIDE : (L_DATA_WIDTH_32_WIDE/32) );
                                  
localparam  N_DRM_DATA_WIDTH_B  = WIDTH_RATIO == 1  ? N_DATA_1_WIDTH :
                                  WIDTH_RATIO == 2  ? (c_RD_DATA_WIDTH > c_WR_DATA_WIDTH ? N_DATA_WIDTH_2_WIDE  : (N_DATA_WIDTH_2_WIDE/2)   ):
                                  WIDTH_RATIO == 4  ? (c_RD_DATA_WIDTH > c_WR_DATA_WIDTH ? N_DATA_WIDTH_4_WIDE  : (N_DATA_WIDTH_4_WIDE/4)   ):
                                  WIDTH_RATIO == 8  ? (c_RD_DATA_WIDTH > c_WR_DATA_WIDTH ? N_DATA_WIDTH_8_WIDE  : (N_DATA_WIDTH_8_WIDE/8)   ):
                                  WIDTH_RATIO == 16 ? (c_RD_DATA_WIDTH > c_WR_DATA_WIDTH ? N_DATA_WIDTH_16_WIDE : (N_DATA_WIDTH_16_WIDE/16) ):
                                                      (c_RD_DATA_WIDTH > c_WR_DATA_WIDTH ? N_DATA_WIDTH_32_WIDE : (N_DATA_WIDTH_32_WIDE/32) );
                                  
localparam  L_DRM_DATA_WIDTH_B  = WIDTH_RATIO == 1  ? L_DATA_1_WIDTH :
                                  WIDTH_RATIO == 2  ? (c_RD_DATA_WIDTH > c_WR_DATA_WIDTH ? L_DATA_WIDTH_2_WIDE  : (L_DATA_WIDTH_2_WIDE/2)   ):
                                  WIDTH_RATIO == 4  ? (c_RD_DATA_WIDTH > c_WR_DATA_WIDTH ? L_DATA_WIDTH_4_WIDE  : (L_DATA_WIDTH_4_WIDE/4)   ):
                                  WIDTH_RATIO == 8  ? (c_RD_DATA_WIDTH > c_WR_DATA_WIDTH ? L_DATA_WIDTH_8_WIDE  : (L_DATA_WIDTH_8_WIDE/8)   ):
                                  WIDTH_RATIO == 16 ? (c_RD_DATA_WIDTH > c_WR_DATA_WIDTH ? L_DATA_WIDTH_16_WIDE : (L_DATA_WIDTH_16_WIDE/16) ):
                                                      (c_RD_DATA_WIDTH > c_WR_DATA_WIDTH ? L_DATA_WIDTH_32_WIDE : (L_DATA_WIDTH_32_WIDE/32) );

//byte_enable  DRM DATA WIDTH 
localparam  N_BYTE_DATA_WIDTH_A = WIDTH_RATIO == 1  ? N_BYTE_DATA_1_WIDTH :
                                  WIDTH_RATIO == 2  ? (c_WR_DATA_WIDTH > c_RD_DATA_WIDTH ? N_BYTE_DATA_WIDTH_2_WIDE  : (N_BYTE_DATA_WIDTH_2_WIDE/2) ):
                                                      (c_WR_DATA_WIDTH > c_RD_DATA_WIDTH ? N_BYTE_DATA_WIDTH_4_WIDE  : (N_BYTE_DATA_WIDTH_4_WIDE/4) );

localparam  L_BYTE_DATA_WIDTH_A = WIDTH_RATIO == 1  ? L_BYTE_DATA_1_WIDTH :
                                  WIDTH_RATIO == 2  ? (c_WR_DATA_WIDTH > c_RD_DATA_WIDTH ? L_BYTE_DATA_WIDTH_2_WIDE  : (L_BYTE_DATA_WIDTH_2_WIDE/2) ):
                                                      (c_WR_DATA_WIDTH > c_RD_DATA_WIDTH ? L_BYTE_DATA_WIDTH_4_WIDE  : (L_BYTE_DATA_WIDTH_4_WIDE/4) );

localparam  N_BYTE_DATA_WIDTH_B = WIDTH_RATIO == 1  ? N_BYTE_DATA_1_WIDTH :
                                  WIDTH_RATIO == 2  ? (c_RD_DATA_WIDTH > c_WR_DATA_WIDTH ? N_BYTE_DATA_WIDTH_2_WIDE  : (N_BYTE_DATA_WIDTH_2_WIDE/2) ):
                                                      (c_RD_DATA_WIDTH > c_WR_DATA_WIDTH ? N_BYTE_DATA_WIDTH_4_WIDE  : (N_BYTE_DATA_WIDTH_4_WIDE/4) );

localparam  L_BYTE_DATA_WIDTH_B = WIDTH_RATIO == 1  ? L_BYTE_DATA_1_WIDTH :
                                  WIDTH_RATIO == 2  ? (c_RD_DATA_WIDTH > c_WR_DATA_WIDTH ? L_BYTE_DATA_WIDTH_2_WIDE  : (L_BYTE_DATA_WIDTH_2_WIDE/2) ):
                                                      (c_RD_DATA_WIDTH > c_WR_DATA_WIDTH ? L_BYTE_DATA_WIDTH_4_WIDE  : (L_BYTE_DATA_WIDTH_4_WIDE/4) );

//*****************************************************************************************************************************************
//DRM_DATA_WIDTH_A is the  port A parameter  of DRM
localparam  DRM_DATA_WIDTH_A = (c_POWER_OPT == 1) ? (c_WR_BYTE_EN ==1 ? L_BYTE_DATA_WIDTH_A : L_DRM_DATA_WIDTH_A): 
                                                     (c_WR_BYTE_EN ==1 ? N_BYTE_DATA_WIDTH_A : N_DRM_DATA_WIDTH_A);
//DRM_DATA_WIDTH_A is the  port B parameter  of DRM
localparam  DRM_DATA_WIDTH_B = (c_POWER_OPT == 1) ? (c_WR_BYTE_EN ==1 ? L_BYTE_DATA_WIDTH_B : L_DRM_DATA_WIDTH_B): 
                                                     (c_WR_BYTE_EN ==1 ? N_BYTE_DATA_WIDTH_B : N_DRM_DATA_WIDTH_B);

//DATA_LOOP_NUM difine how many loop to cascade the c_WR_DATA_WIDTH
localparam  DATA_LOOP_NUM = (c_WR_DATA_WIDTH%DRM_DATA_WIDTH_A == 0) ? (c_WR_DATA_WIDTH/DRM_DATA_WIDTH_A):(c_WR_DATA_WIDTH/DRM_DATA_WIDTH_A + 1);

localparam  Q_DRM_DATA_WIDTH_B  = (DRM_DATA_WIDTH_B == 36) ? 18 : ((DRM_DATA_WIDTH_B == 32) ? 16 : DRM_DATA_WIDTH_B);
localparam  Q_DRM_DATA_WIDTH_A  = (DRM_DATA_WIDTH_B==32 || DRM_DATA_WIDTH_B ==36) ? Q_DRM_DATA_WIDTH_B :
                                  ((DRM_DATA_WIDTH_A == 36) ? 18 : ((DRM_DATA_WIDTH_A == 32) ? 16 : DRM_DATA_WIDTH_A));

localparam  D_DRM_DATA_WIDTH_A  = (DRM_DATA_WIDTH_A == 36) ? 18 : ((DRM_DATA_WIDTH_A == 32) ? 16 : DRM_DATA_WIDTH_A);
localparam  D_DRM_DATA_WIDTH_B  = (DRM_DATA_WIDTH_A == 32 || DRM_DATA_WIDTH_A==36) ? D_DRM_DATA_WIDTH_A :
                                  ((DRM_DATA_WIDTH_B == 36) ? 18 : ((DRM_DATA_WIDTH_B == 32) ? 16 : DRM_DATA_WIDTH_B));

//DRM_ADDR_WIDTH is the ADDR_WIDTH of INSTANCE DRM primitives
localparam  DRM_ADDR_WIDTH_A = DRM_DATA_WIDTH_A == 1  ? 14:
                               DRM_DATA_WIDTH_A == 2  ? 13:
                               DRM_DATA_WIDTH_A == 4  ? 12:
                               DRM_DATA_WIDTH_A == 8  ? 11:
                               DRM_DATA_WIDTH_A == 9  ? 11:
                               DRM_DATA_WIDTH_A == 16 ? 10:
                               DRM_DATA_WIDTH_A == 18 ? 10:
                               DRM_DATA_WIDTH_A == 32 ?  9:
                                                         9;
                                                         
localparam  DRM_ADDR_WIDTH_B = DRM_DATA_WIDTH_B == 1  ? 14: 
                               DRM_DATA_WIDTH_B == 2  ? 13:
                               DRM_DATA_WIDTH_B == 4  ? 12:
                               DRM_DATA_WIDTH_B == 8  ? 11:
                               DRM_DATA_WIDTH_B == 9  ? 11:
                               DRM_DATA_WIDTH_B == 16 ? 10:
                               DRM_DATA_WIDTH_B == 18 ? 10:
                               DRM_DATA_WIDTH_B == 32 ?  9:
                                                         9;

localparam  ADDR_WIDTH_A  = c_WR_ADDR_WIDTH > DRM_ADDR_WIDTH_A ? c_WR_ADDR_WIDTH : DRM_ADDR_WIDTH_A;
//CS_ADDR_WIDTH_A is the CS address width to choose the DRM18K CS_ADDR_WIDTH_A=  [ extra-addres + cs[2]+csp[1]+cs[0] ]
localparam  CS_ADDR_WIDTH_A  = ADDR_WIDTH_A - DRM_ADDR_WIDTH_A;

localparam  ADDR_WIDTH_B  = c_RD_ADDR_WIDTH > DRM_ADDR_WIDTH_B ? c_RD_ADDR_WIDTH : DRM_ADDR_WIDTH_B;
localparam  CS_ADDR_WIDTH_B  = ADDR_WIDTH_B - DRM_ADDR_WIDTH_B;
//ADDR_LOOP_NUM_A difine how many loops to cascade the c_WR_ADDR_WIDTH
localparam  ADDR_LOOP_NUM_A  = 2**CS_ADDR_WIDTH_A;
localparam  ADDR_LOOP_NUM_B  = 2**CS_ADDR_WIDTH_B;

//CAS_DATA_WIDTH_A is the cascaded  data width 
localparam  CAS_DATA_WIDTH_A   =  DRM_DATA_WIDTH_A*DATA_LOOP_NUM   ;
localparam  CAS_DATA_WIDTH_B   =  DRM_DATA_WIDTH_B*DATA_LOOP_NUM   ;

localparam  Q_CAS_DATA_WIDTH_A =  Q_DRM_DATA_WIDTH_A*DATA_LOOP_NUM ;
localparam  Q_CAS_DATA_WIDTH_B =  Q_DRM_DATA_WIDTH_B*DATA_LOOP_NUM ;

localparam  D_CAS_DATA_WIDTH_A =  D_DRM_DATA_WIDTH_A*DATA_LOOP_NUM ;
localparam  D_CAS_DATA_WIDTH_B =  D_DRM_DATA_WIDTH_B*DATA_LOOP_NUM ;

localparam  WR_BYTE_WIDTH_A = c_WR_BYTE_EN == 1 ? c_WR_BYTE_WIDTH :
                            ( (DRM_DATA_WIDTH_A >=8 || DRM_DATA_WIDTH_A >=9 ) ? ((c_WR_DATA_WIDTH%9 == 0) ? 9 : 8 ) : 1 );
                            
localparam  WR_BYTE_WIDTH_B = c_WR_BYTE_EN == 1 ? c_WR_BYTE_WIDTH :
                            ( (DRM_DATA_WIDTH_B >=8 || DRM_DATA_WIDTH_B >=9 ) ? ((c_RD_DATA_WIDTH%9 == 0) ? 9 : 8 ) : 1 );

//MASK_NUM the mask base value          
localparam  MASK_NUM_A  = (( DRM_DATA_WIDTH_A == 36 || DRM_DATA_WIDTH_A == 32 ) || ( DRM_DATA_WIDTH_B == 36 || DRM_DATA_WIDTH_B == 32 )) ? (ADDR_LOOP_NUM_A > 4 ? 2 : 4 ):
                          ( ADDR_LOOP_NUM_A >8 ) ? (( DRM_DATA_WIDTH_A == 36 || DRM_DATA_WIDTH_A == 32 ) ? 2 : 4) : 8;
                          
localparam  MASK_NUM_B  = ( DRM_DATA_WIDTH_B == 36 || DRM_DATA_WIDTH_B == 32 ) ? (ADDR_LOOP_NUM_B > 4 ? 2 : 4 ):
                          ( ADDR_LOOP_NUM_B > 8 ) ? (( DRM_DATA_WIDTH_B == 36 || DRM_DATA_WIDTH_B == 32 ) ? 2 : 4) : 8;

localparam c_RST_TYPE = (c_RESET_TYPE == "SYNC_RESET") ? "SYNC" : ((c_RESET_TYPE == "ASYNC_RESET") ?  "ASYNC" : "ASYNC_SYNC_RELEASE");      

//parameter  check
initial begin
   if( (2**c_WR_ADDR_WIDTH*c_WR_DATA_WIDTH) != (2**c_RD_ADDR_WIDTH*c_RD_DATA_WIDTH) ) begin
      $display("IPSpecCheck: 01030100 ipml_flex_sdpram parameter setting error !!!: 2**c_WR_ADDR_WIDTH*c_WR_DATA_WIDTH must be equal to  2**c_RD_ADDR_WIDTH*c_RD_DATA_WIDTH or 2**c_WR_ADDR_WIDTH*9 must be equal to  2**c_RD_ADDR_WIDTH*9")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if( c_WR_ADDR_WIDTH>20 || c_WR_ADDR_WIDTH<8 ) begin
      $display("IPSpecCheck: 01030102 ipml_flex_sdpram parameter setting error !!!: c_WR_ADDR_WIDTH must between 8-20")/* PANGO PAP_CRITICAL_WARNING */;
      //$finish;
   end
   else if( c_WR_DATA_WIDTH>1152 || c_WR_DATA_WIDTH<1 ) begin
      $display("IPSpecCheck: 01030103 ipml_flex_sdpram parameter setting error !!!: c_WR_DATA_WIDTH must between 1-1152")/* PANGO PAP_CRITICAL_WARNING */;
      //$finish;
   end
   else if( c_RD_ADDR_WIDTH>20 || c_RD_ADDR_WIDTH<8 ) begin
      $display("IPSpecCheck: 01030104 ipml_flex_sdpram parameter setting error !!!: c_RD_ADDR_WIDTH must between 8-20")/* PANGO PAP_CRITICAL_WARNING */;
      //$finish;
   end
   else if( c_RD_DATA_WIDTH>1152 || c_RD_DATA_WIDTH<1 ) begin
      $display("IPSpecCheck: 01030105 ipml_flex_sdpram parameter setting error !!!: c_RD_DATA_WIDTH must between 1-1152")/* PANGO PAP_CRITICAL_WARNING */;
      //$finish;
   end
   else if( c_OUTPUT_REG!=1 && c_OUTPUT_REG!=0 ) begin
      $display("IPSpecCheck: 01030107 ipml_flex_sdpram parameter setting error !!!: c_OUTPUT_REG must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if( c_RD_CLK_OR_POL_INV!=1 && c_RD_CLK_OR_POL_INV!=0 ) begin
      $display("IPSpecCheck: 01030108 ipml_flex_sdpram parameter setting error !!!: c_RD_CLK_OR_POL_INV must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( c_RD_OCE_EN!=0 && c_RD_OCE_EN!=1) begin
      $display("IPSpecCheck: 01030109 ipml_flex_sdpram parameter setting error !!!: c_RD_OCE_EN must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( c_RD_OCE_EN==1 && c_OUTPUT_REG==0 ) begin
      $display("IPSpecCheck: 01030110 ipml_flex_sdpram parameter setting error !!!: c_OUTPUT_REG must be 1 when c_RD_OCE_EN is 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( c_RD_CLK_OR_POL_INV==1 && c_OUTPUT_REG==0 ) begin
      $display("IPSpecCheck: 01030111 ipml_flex_sdpram parameter setting error !!!: c_OUTPUT_REG must be 1 when c_RD_CLK_OR_POL_INV is 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( (c_WR_CLK_EN!=0 && c_WR_CLK_EN!=1) || (c_RD_CLK_EN!=0 && c_RD_CLK_EN!=1) )begin
      $display("IPSpecCheck: 01030112 ipml_flex_sdpram parameter setting error !!!: c_WR_CLK_EN or c_RD_CLK_EN must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( (c_WR_ADDR_STROBE_EN!=0 && c_WR_ADDR_STROBE_EN!=1) || (c_RD_ADDR_STROBE_EN!=0 && c_RD_ADDR_STROBE_EN!=1) ) begin
      $display("IPSpecCheck: 01030113 ipml_flex_sdpram parameter setting error !!!: c_WR_ADDR_STROBE_EN or c_RD_ADDR_STROBE_EN must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( (c_SIM_DEVICE == "PGL22G") && (c_WR_CLK_EN==1 || c_RD_CLK_EN==1) && (c_WR_ADDR_STROBE_EN==1 || c_RD_ADDR_STROBE_EN==1) ) begin
      $display("IPSpecCheck: 01030114 ipml_flex_sdpram parameter setting error !!!: Clock Enable and Address Strobe only works individually when using PGL22G")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if( c_RST_TYPE!="ASYNC" && c_RST_TYPE!="SYNC" && c_RST_TYPE!="ASYNC_SYNC_RELEASE" ) begin
      $display("IPSpecCheck: 01030015 ipml_flex_sdpram parameter setting error !!!: c_RESET_TYPE must be ASYNC or SYNC or ASYNC_SYNC_RELEASE")/* PANGO PAP_ERROR */;
      $finish;
   end 
   else if( c_POWER_OPT!=1 && c_POWER_OPT!=0 ) begin
      $display("IPSpecCheck: 01030116 ipml_flex_sdpram parameter setting error !!!: c_POWER_OPT must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if( c_WR_BYTE_EN!=0 && c_WR_BYTE_EN!=1 ) begin
      $display("IPSpecCheck: 01030117 ipml_flex_sdpram parameter setting error !!!: c_WR_BYTE_EN must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if( c_WR_BYTE_EN ==1 ) begin
      if( c_WR_BYTE_WIDTH !=8 && c_WR_BYTE_WIDTH!=9 ) begin
         $display("IPSpecCheck: 01030118 ipml_flex_sdpram parameter setting error !!!: c_WR_BYTE_WIDTH must be 8 or 9")/* PANGO PAP_ERROR */;
         $finish;
      end
      if( (c_WR_DATA_WIDTH%8)!=0 && (c_WR_DATA_WIDTH%9)!=0 ) begin
         $display("IPSpecCheck: 01030119 ipml_flex_sdpram parameter setting error !!!: c_WR_DATA_WIDTH must be 8*N or 9*N")/* PANGO PAP_ERROR */;
         $finish;
      end
   end
   else if( c_INIT_FORMAT!="BIN" && c_INIT_FORMAT!="HEX" ) begin
      $display("IPSpecCheck: 01030120 ipml_flex_sdpram parameter setting error !!!: c_INIT_FORMAT must be bin or hex ")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( (c_WR_BYTE_EN == 1) && (c_WR_ADDR_STROBE_EN==1 || c_RD_ADDR_STROBE_EN==1) ) begin
      $display("IPSpecCheck: 01030124 ipml_flex_sdpram parameter setting error !!!: When Byte Write, disable Address Strobe")/* PANGO PAP_ERROR */;
      $finish;
   end   
   else if( WIDTH_RATIO > 32 && c_WR_BYTE_EN == 0 ) begin
      $display("IPSpecCheck: 01030121 ipml_flex_sdpram parameter setting error !!!: Data Width Ratio is 1~32 when disable Byte Write ")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if( WIDTH_RATIO > 4 && c_WR_BYTE_EN == 1 ) begin
      $display("IPSpecCheck: 01030122 ipml_flex_sdpram parameter setting error !!!: Data Width Ratio is 1~4 when enable Byte Write ")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( WIDTH_RATIO>1 && (c_WR_ADDR_STROBE_EN==1 || c_RD_ADDR_STROBE_EN==1) ) begin
      $display("IPSpecCheck: 01030123 ipml_flex_sdpram parameter setting error !!!: Address Strobe could not work when Mixed Data Width")/* PANGO PAP_ERROR */;
      $finish;
   end     
   else if( c_WR_DATA_WIDTH != c_RD_DATA_WIDTH ) begin
      if( c_WR_DATA_WIDTH%9 == 0 || c_RD_DATA_WIDTH%9 == 0 ) begin
         if( ((c_WR_DATA_WIDTH/9)&(c_WR_DATA_WIDTH/9-1))!=0 || ((c_RD_DATA_WIDTH/9)&(c_RD_DATA_WIDTH/9-1))!=0 ) begin
            $display("IPSpecCheck: 01030101 ipml_flex_sdpram parameter setting error !!!: c_WR_DATA_WIDTH and c_RD_DATA_WIDTH must be 2^N or 9*2^N ")/* PANGO PAP_ERROR */;
            $finish;
         end
         else if( ((WIDTH_RATIO > 4) && (c_WR_BYTE_EN == 0)) ) begin
            $display("IPSpecCheck: 01030125 ipml_flex_dpram parameter setting error !!!: Data Width Ratio is 1~4 when c_WR_DATA_WIDTH and c_RD_DATA_WIDTH is 9*2^N")/* PANGO PAP_ERROR */;
            $finish;
         end
      end
      else begin
         if ( (c_WR_DATA_WIDTH&(c_WR_DATA_WIDTH-1))!=0 || (c_RD_DATA_WIDTH&(c_RD_DATA_WIDTH-1))!=0 ) begin
            $display("IPSpecCheck: 01030101 ipml_flex_sdpram parameter setting error !!!: c_WR_DATA_WIDTH and c_RD_DATA_WIDTH must be 2^N or 9*2^N ")/* PANGO PAP_ERROR */;
            $finish;
         end
      end
   end
end


//main code 
//***********************************************************************************************************************************************
//inner variables
//port A operation
wire  [CAS_DATA_WIDTH_A-1:0]                    wr_data_bus       ;
reg   [CAS_DATA_WIDTH_A-1:0]                    wr_data_mix_bus   ;
reg   [D_CAS_DATA_WIDTH_A-1:0]                  da_data_bus       ; //the data bus of data_cascaded instance DRM
wire  [Q_CAS_DATA_WIDTH_A*ADDR_LOOP_NUM_A-1:0]  qa_data_bus       ; //the total data width of instance DRM
wire  [ADDR_WIDTH_A-1:0]                        wr_addr_bus       ;
reg   [DATA_LOOP_NUM*14-1:0]                    drm_wr_addr_bus   ; //write address to all instance DRM
reg                                             wr_cs_bit0        ; //write cs[0]  to all instance DRM
reg   [ADDR_LOOP_NUM_A-1:0]                     wr_cs_bit1_bus    ; //write cs[1]  to all instance DRM
reg   [ADDR_LOOP_NUM_A-1:0]                     wr_cs_bit2_bus    ; //write cs[2] bus  to every data_cascaded DRM-block
reg                                             wr_cs_bit0_ff     ;
reg   [ADDR_LOOP_NUM_A-1:0]                     wr_cs_bit1_bus_ff ;
reg   [ADDR_LOOP_NUM_A-1:0]                     wr_cs_bit2_bus_ff ;
wire                                            wr_cs_bit0_m      ;
wire  [ADDR_LOOP_NUM_A-1:0]                     wr_cs_bit1_bus_m  ;
wire  [ADDR_LOOP_NUM_A-1:0]                     wr_cs_bit2_bus_m  ;
wire  [ADDR_LOOP_NUM_A-1:0]                     wr_cs2_ctrl       ;

reg   [DATA_LOOP_NUM-1 :0]                      wr_en_bus         ;
//port B operation                                              
wire  [CAS_DATA_WIDTH_B*ADDR_LOOP_NUM_B-1:0]    rd_data_bus       ;
reg   [D_CAS_DATA_WIDTH_B-1:0]                  db_data_bus       ; //the data bus of data_cascaded instance DRM
wire  [Q_CAS_DATA_WIDTH_B*ADDR_LOOP_NUM_B-1:0]  qb_data_bus       ; //the total data width of instance DRM
wire  [ADDR_WIDTH_B-1:0]                        rd_addr_bus       ;  
wire  [3:0]                                     rd_addr_bsel_bus  ;
reg   [13:0]                                    drm_rd_addr       ; //read address to all instance DRM
reg                                             rd_cs_bit0        ; //read cs[0]  to all instance DRM
reg   [ADDR_LOOP_NUM_B-1:0]                     rd_cs_bit1_bus    ; //read cs[1]  to all instance DRM
reg   [ADDR_LOOP_NUM_B-1:0]                     rd_cs_bit2_bus    ; //raad cs[2]  bus  to every data_cascaded DRM-block
reg                                             rd_cs_bit0_ff     ;
reg   [ADDR_LOOP_NUM_B-1:0]                     rd_cs_bit1_bus_ff ;
reg   [ADDR_LOOP_NUM_B-1:0]                     rd_cs_bit2_bus_ff ;
wire                                            rd_cs_bit0_m      ;
wire  [ADDR_LOOP_NUM_B-1:0]                     rd_cs_bit1_bus_m  ;
wire  [ADDR_LOOP_NUM_B-1:0]                     rd_cs_bit2_bus_m  ;

reg   [CAS_DATA_WIDTH_B-1:0]                    rd_mix_data       ; //mix data form rd_data_bus
reg   [CAS_DATA_WIDTH_B-1:0]                    rd_full_data      ; //
                                                                  
//byte enable                                                   
wire  [CAS_DATA_WIDTH_A/WR_BYTE_WIDTH_A-1 : 0]    wr_byte_en_bus    ;
reg   [CAS_DATA_WIDTH_A/WR_BYTE_WIDTH_A-1 : 0]    wr_byte_en_mix_bus;
//*************************************************************************************************************************************
//write data mux 
assign  wr_data_bus[CAS_DATA_WIDTH_A-1:0] = {{(CAS_DATA_WIDTH_A - c_WR_DATA_WIDTH){1'b0}},wr_data[c_WR_DATA_WIDTH-1:0]};

assign  wr_addr_bus[ADDR_WIDTH_A-1:0] = {{(ADDR_WIDTH_A - c_WR_ADDR_WIDTH){1'b0}},wr_addr[c_WR_ADDR_WIDTH-1:0]};
//wr_byte_en_bus 
assign  wr_byte_en_bus = (c_WR_BYTE_EN == 0) ? -1 : {{(CAS_DATA_WIDTH_A/WR_BYTE_WIDTH_A - c_WR_DATA_WIDTH/WR_BYTE_WIDTH_A){1'b0}},wr_byte_en[c_BE_WIDTH-1 : 0]}; 

//*************************************************************************************************************************************
////generate drm_wr_addr_bus connect to the instance DRM directly ,based on DRM_DATA_WIDTH_A
integer gen_wa;
always @(*) begin
   for( gen_wa=0;gen_wa < DATA_LOOP_NUM;gen_wa = gen_wa + 1 ) begin
      case (DRM_DATA_WIDTH_A)
         1      : drm_wr_addr_bus[gen_wa*14 +: 14] = wr_addr_bus[(ADDR_WIDTH_A-CS_ADDR_WIDTH_A-1):0];
         2      : drm_wr_addr_bus[gen_wa*14 +: 14] = wr_addr_bus[(ADDR_WIDTH_A-CS_ADDR_WIDTH_A-1):0] <<1;
         4      : drm_wr_addr_bus[gen_wa*14 +: 14] = wr_addr_bus[(ADDR_WIDTH_A-CS_ADDR_WIDTH_A-1):0] <<2;
         8,9    : drm_wr_addr_bus[gen_wa*14 +: 14] = wr_addr_bus[(ADDR_WIDTH_A-CS_ADDR_WIDTH_A-1):0] <<3;
         16,18  : drm_wr_addr_bus[gen_wa*14 +: 14] = {wr_addr_bus[(ADDR_WIDTH_A-CS_ADDR_WIDTH_A-1):0],2'b00,wr_byte_en_mix_bus[gen_wa*2 +: 2]};
         32,36  : drm_wr_addr_bus[gen_wa*14 +: 14] = {wr_addr_bus[(ADDR_WIDTH_A-CS_ADDR_WIDTH_A-1):0],1'b0,wr_byte_en_mix_bus[gen_wa*4 +: 4]};
         default: drm_wr_addr_bus[gen_wa*14 +: 14] = 14'b0;
      endcase
   end
end
//*****************************************************************************************************************************************************
//generate CSA bus
localparam CS_ADDR_A_3_LSB = (CS_ADDR_WIDTH_A >= 3) ? (ADDR_WIDTH_A-CS_ADDR_WIDTH_A+1) : (ADDR_WIDTH_A-2);  //avoid reveral index of wr_addr_bus

localparam CS_ADDR_A_4_LSB = (CS_ADDR_WIDTH_A >= 4) ? ((ADDR_WIDTH_A-CS_ADDR_WIDTH_A+2)) : (ADDR_WIDTH_A-2); //avoid reveral index of wr_addr_bus

integer  gen_csa;

always@(*) begin
   for(gen_csa=0;gen_csa<ADDR_LOOP_NUM_A;gen_csa=gen_csa+1) begin
      if((DRM_DATA_WIDTH_A == 36 || DRM_DATA_WIDTH_A == 32) || (DRM_DATA_WIDTH_B == 36 || DRM_DATA_WIDTH_B == 32)) begin
         if(CS_ADDR_WIDTH_A == 0) begin
            wr_cs_bit0 = 0;
            wr_cs_bit1_bus[gen_csa] = 0;
            wr_cs_bit2_bus[gen_csa] = 1'b0;
         end
         else if(CS_ADDR_WIDTH_A == 1) begin
            wr_cs_bit0 = wr_addr_bus[ADDR_WIDTH_A-CS_ADDR_WIDTH_A];
            wr_cs_bit1_bus[gen_csa] = 0;
            wr_cs_bit2_bus[gen_csa] = 1'b0;
         end
         else if(CS_ADDR_WIDTH_A == 2) begin
            wr_cs_bit0 = wr_addr_bus[ADDR_WIDTH_A-2];
            wr_cs_bit1_bus[gen_csa] = wr_addr_bus[ADDR_WIDTH_A-1];
            wr_cs_bit2_bus[gen_csa] = 1'b0;
         end
         else if(CS_ADDR_WIDTH_A >= 3 ) begin
            wr_cs_bit0 = wr_addr_bus[ADDR_WIDTH_A-CS_ADDR_WIDTH_A];
            wr_cs_bit1_bus[gen_csa] = (wr_addr_bus[(ADDR_WIDTH_A-1):CS_ADDR_A_3_LSB] == (gen_csa/2) ) ? 0 : 1;
            wr_cs_bit2_bus[gen_csa] = 1'b0;
         end
      end
      else begin
          if(CS_ADDR_WIDTH_A == 0) begin
             wr_cs_bit0 = 0;
             wr_cs_bit1_bus[gen_csa] = 0;
             wr_cs_bit2_bus[gen_csa] = 0;
          end
          else if(CS_ADDR_WIDTH_A == 1) begin
             wr_cs_bit0 = wr_addr_bus[ADDR_WIDTH_A-CS_ADDR_WIDTH_A];
             wr_cs_bit1_bus[gen_csa] = 0;
             wr_cs_bit2_bus[gen_csa] = 0;
          end
          else if(CS_ADDR_WIDTH_A == 2) begin
             wr_cs_bit0 = wr_addr_bus[ADDR_WIDTH_A-2];
             wr_cs_bit1_bus[gen_csa] = wr_addr_bus[ADDR_WIDTH_A-1];
             wr_cs_bit2_bus[gen_csa] = 0;
          end
          else if(CS_ADDR_WIDTH_A == 3) begin
             wr_cs_bit0 = wr_addr_bus[ADDR_WIDTH_A-CS_ADDR_WIDTH_A];
             wr_cs_bit1_bus[gen_csa] = wr_addr_bus[ADDR_WIDTH_A-2];
             wr_cs_bit2_bus[gen_csa] = wr_addr_bus[ADDR_WIDTH_A-1];
          end
          else if(CS_ADDR_WIDTH_A >= 4) begin
             wr_cs_bit0 = wr_addr_bus[ADDR_WIDTH_A-CS_ADDR_WIDTH_A];
             wr_cs_bit1_bus[gen_csa] = wr_addr_bus[ADDR_WIDTH_A-CS_ADDR_WIDTH_A+1];
             wr_cs_bit2_bus[gen_csa] = ( wr_addr_bus[(ADDR_WIDTH_A-1):CS_ADDR_A_4_LSB] == (gen_csa/4) ) ? 0 : 1;
          end
      end
   end
end

always @(posedge wr_clk or posedge wr_rst)
begin
    if (wr_rst) begin
        wr_cs_bit0_ff     <= 0;
        wr_cs_bit1_bus_ff <= 0;
        wr_cs_bit2_bus_ff <= 0;
    end
    else if(~wr_addr_strobe) begin
        wr_cs_bit0_ff     <= wr_cs_bit0;
        wr_cs_bit1_bus_ff <= wr_cs_bit1_bus;
        wr_cs_bit2_bus_ff <= wr_cs_bit2_bus;
    end
end

assign wr_cs_bit0_m     = (c_SIM_DEVICE == "PGL22G") ? (wr_addr_strobe ? wr_cs_bit0_ff     : wr_cs_bit0    ) : wr_cs_bit0;
assign wr_cs_bit1_bus_m = (c_SIM_DEVICE == "PGL22G") ? (wr_addr_strobe ? wr_cs_bit1_bus_ff : wr_cs_bit1_bus) : wr_cs_bit1_bus;
assign wr_cs_bit2_bus_m = (c_SIM_DEVICE == "PGL22G") ? (wr_addr_strobe ? wr_cs_bit2_bus_ff : wr_cs_bit2_bus) : wr_cs_bit2_bus;
//****************************************************************************************************************************************************
//generate wr_data_mix_bus  and wr_byte_en_mix_bus
integer  gen_i_wd,gen_j_wd;
always@(*)
begin
   if( c_WR_DATA_WIDTH > c_RD_DATA_WIDTH && DATA_LOOP_NUM > 1 ) begin
      for (gen_i_wd=0;gen_i_wd < DATA_LOOP_NUM;gen_i_wd =gen_i_wd+1)
         for(gen_j_wd=0;gen_j_wd<WIDTH_RATIO;gen_j_wd=gen_j_wd+1 )
            wr_data_mix_bus[gen_i_wd*DRM_DATA_WIDTH_A+gen_j_wd*DRM_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = wr_data_bus[(gen_i_wd + gen_j_wd*DATA_LOOP_NUM)*DRM_DATA_WIDTH_B +:DRM_DATA_WIDTH_B];
   end
   else begin
      wr_data_mix_bus = wr_data_bus;
   end
   
   if( c_WR_DATA_WIDTH > c_RD_DATA_WIDTH && DATA_LOOP_NUM > 1 && c_WR_BYTE_EN == 1) begin
      for (gen_i_wd=0;gen_i_wd < DATA_LOOP_NUM;gen_i_wd =gen_i_wd+1)
         for(gen_j_wd=0;gen_j_wd<WIDTH_RATIO;gen_j_wd=gen_j_wd+1 )
            wr_byte_en_mix_bus[gen_i_wd*(DRM_DATA_WIDTH_A/WR_BYTE_WIDTH_A)+gen_j_wd*(DRM_DATA_WIDTH_B/WR_BYTE_WIDTH_B) +:(DRM_DATA_WIDTH_B/WR_BYTE_WIDTH_B)] = wr_byte_en_bus[(gen_i_wd + gen_j_wd*DATA_LOOP_NUM)*(DRM_DATA_WIDTH_B/WR_BYTE_WIDTH_B) +:(DRM_DATA_WIDTH_B/WR_BYTE_WIDTH_B)];           
   end
   else begin
      wr_byte_en_mix_bus = wr_byte_en_bus;
   end
   //generate wr_en_bus
   if( c_WR_BYTE_EN == 1 &&(DRM_DATA_WIDTH_A == 8 || DRM_DATA_WIDTH_A == 9) ) begin
      wr_en_bus = wr_byte_en_mix_bus & {CAS_DATA_WIDTH_A/WR_BYTE_WIDTH_A{wr_en}};
   end
   else begin
      for (gen_i_wd=0;gen_i_wd<DATA_LOOP_NUM;gen_i_wd=gen_i_wd+1)
         wr_en_bus[gen_i_wd] = wr_en;
   end
end
//***********************************************************************************************************************************************************
localparam  MODE_RATIO = (DATA_WIDTH_WIDE < DRM_DATA_WIDTH_A) ? (DRM_DATA_WIDTH_A/DATA_WIDTH_WIDE) : (DATA_WIDTH_WIDE/DRM_DATA_WIDTH_A);
//drm_rd_addr connect to the instance DRM directly,based on DRM_DATA_WIDTH_A
//assign  rd_addr_bus[ADDR_WIDTH_B-1:0] = {{(ADDR_WIDTH_B-c_RD_ADDR_WIDTH){1'b0}},rd_addr[c_RD_ADDR_WIDTH-1:0]};
assign  rd_addr_bus[ADDR_WIDTH_B-1:0] = ((WIDTH_RATIO == 16) && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B)
                                                                                      && (MODE_RATIO       == 2               )) ? {{(ADDR_WIDTH_B-c_RD_ADDR_WIDTH){1'b0}},rd_addr[c_RD_ADDR_WIDTH-1:4],1'b0,rd_addr[3:1]}
                                      : ((WIDTH_RATIO == 16) && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B)) ? {{(ADDR_WIDTH_B-c_RD_ADDR_WIDTH){1'b0}},rd_addr[c_RD_ADDR_WIDTH-1:4],4'b0000}
                                      : ((WIDTH_RATIO == 8)  && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B)
                                                                                      && (MODE_RATIO       == 4               )) ? {{(ADDR_WIDTH_B-c_RD_ADDR_WIDTH){1'b0}},rd_addr[c_RD_ADDR_WIDTH-1:3],2'b00,rd_addr[2]}
                                      : ((WIDTH_RATIO == 8)  && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B)
                                                                                      && (MODE_RATIO       == 2               )) ? {{(ADDR_WIDTH_B-c_RD_ADDR_WIDTH){1'b0}},rd_addr[c_RD_ADDR_WIDTH-1:3],1'b0,rd_addr[2:1]}
                                      : ((WIDTH_RATIO == 8)  && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B)) ? {{(ADDR_WIDTH_B-c_RD_ADDR_WIDTH){1'b0}},rd_addr[c_RD_ADDR_WIDTH-1:3],3'b000}
                                      : ((WIDTH_RATIO == 4)  && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B)
                                                                                      && (MODE_RATIO       == 2               )) ? {{(ADDR_WIDTH_B-c_RD_ADDR_WIDTH){1'b0}},rd_addr[c_RD_ADDR_WIDTH-1:2],1'b0,rd_addr[1]}
                                      : ((WIDTH_RATIO == 4)  && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B)) ? {{(ADDR_WIDTH_B-c_RD_ADDR_WIDTH){1'b0}},rd_addr[c_RD_ADDR_WIDTH-1:2],2'b00}
                                      : ((WIDTH_RATIO == 2)  && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B)) ? {{(ADDR_WIDTH_B-c_RD_ADDR_WIDTH){1'b0}},rd_addr[c_RD_ADDR_WIDTH-1:1],1'b0}
                                                                                                                                 : {{(ADDR_WIDTH_B-c_RD_ADDR_WIDTH){1'b0}},rd_addr[c_RD_ADDR_WIDTH-1:0]};

reg   [3:0] rd_addr_bsel_rd_ce   ;
reg   [3:0] rd_addr_bsel_rd_oce  ;
reg   [3:0] rd_addr_bsel_rd_invt ;

//CE
always @(posedge rd_clk or posedge rd_rst)
begin
    if (rd_rst)
        rd_addr_bsel_rd_ce <= 0;
    else if ((c_RD_ADDR_STROBE_EN == 1) && (c_RD_CLK_EN == 1)) begin
        if (~rd_addr_strobe & rd_clk_en)
            rd_addr_bsel_rd_ce <= rd_addr[3:0];
    end
    else if (c_RD_ADDR_STROBE_EN == 1) begin
        if (~rd_addr_strobe)
            rd_addr_bsel_rd_ce <= rd_addr[3:0];
    end
    else if (c_RD_CLK_EN == 1) begin
        if (rd_clk_en)
            rd_addr_bsel_rd_ce <= rd_addr[3:0];
    end
    else
        rd_addr_bsel_rd_ce <= rd_addr[3:0];
end

//OCE
always @(posedge rd_clk or posedge rd_rst)
begin
    if (rd_rst)
        rd_addr_bsel_rd_oce <= 0;
    else if (c_RD_OCE_EN == 1) begin
        if (rd_oce)
            rd_addr_bsel_rd_oce <= rd_addr_bsel_rd_ce;
    end
    else if (c_OUTPUT_REG == 1) begin
        rd_addr_bsel_rd_oce <= rd_addr_bsel_rd_ce;
    end  
end

//INVT
always @(negedge rd_clk or posedge rd_rst)
begin
    if (rd_rst)
        rd_addr_bsel_rd_invt <= 0;
    else if ((c_RD_OCE_EN == 1) && (c_RD_CLK_OR_POL_INV == 1)) begin
        if (rd_oce)
            rd_addr_bsel_rd_invt <= rd_addr_bsel_rd_ce;
    end
    else if (c_RD_CLK_OR_POL_INV == 1)
        rd_addr_bsel_rd_invt <= rd_addr_bsel_rd_ce;
end

assign rd_addr_bsel_bus = (c_RD_CLK_OR_POL_INV == 1) ? rd_addr_bsel_rd_invt : (c_OUTPUT_REG == 1)
                                                     ? rd_addr_bsel_rd_oce  : rd_addr_bsel_rd_ce;

always@(*) begin
    drm_rd_addr = 14'b0;
    case(DRM_DATA_WIDTH_B)  //synthesis parallel_case 
        1      : drm_rd_addr = rd_addr_bus[(ADDR_WIDTH_B-CS_ADDR_WIDTH_B-1):0];
        2      : drm_rd_addr = {rd_addr_bus[(ADDR_WIDTH_B-CS_ADDR_WIDTH_B-1):0],1'b0};
        4      : drm_rd_addr = {rd_addr_bus[(ADDR_WIDTH_B-CS_ADDR_WIDTH_B-1):0],2'b00};
        8,9    : drm_rd_addr = {rd_addr_bus[(ADDR_WIDTH_B-CS_ADDR_WIDTH_B-1):0],3'b000};
        16,18  : drm_rd_addr = {rd_addr_bus[(ADDR_WIDTH_B-CS_ADDR_WIDTH_B-1):0],2'b00,2'b11};
        32,36  : drm_rd_addr = {rd_addr_bus[(ADDR_WIDTH_B-CS_ADDR_WIDTH_B-1):0],1'b0,4'b1111};
        default: drm_rd_addr = 14'b0;
    endcase
end

//*************************************************************************************************************************************************************
//generate CSB bus
localparam  CS_ADDR_B_3_LSB = (CS_ADDR_WIDTH_B >= 3) ? (ADDR_WIDTH_B-CS_ADDR_WIDTH_B+1) : (ADDR_WIDTH_B-2);  //avoid reveral index of wr_addr_bus

localparam  CS_ADDR_B_4_LSB = (CS_ADDR_WIDTH_B >= 4) ? ((ADDR_WIDTH_B-CS_ADDR_WIDTH_B+2)) : (ADDR_WIDTH_B-2); //avoid reveral index of wr_addr_bus

integer gen_csb;
always@(*) begin
   for(gen_csb=0;gen_csb<ADDR_LOOP_NUM_B;gen_csb=gen_csb+1) begin
      if(DRM_DATA_WIDTH_B == 36 || DRM_DATA_WIDTH_B ==32) begin
         if (CS_ADDR_WIDTH_B == 0) begin
            rd_cs_bit0 = 0;
            rd_cs_bit1_bus[gen_csb] = 0;
            rd_cs_bit2_bus[gen_csb] = 0;
         end
         else if(CS_ADDR_WIDTH_B == 1) begin
            rd_cs_bit0 = rd_addr_bus[ADDR_WIDTH_B-CS_ADDR_WIDTH_B];
            rd_cs_bit1_bus[gen_csb] = 0;
            rd_cs_bit2_bus[gen_csb] = 0; 
         end
         else if(CS_ADDR_WIDTH_B == 2) begin
            rd_cs_bit0 = rd_addr_bus[ADDR_WIDTH_B-CS_ADDR_WIDTH_B];
            rd_cs_bit1_bus[gen_csb] = rd_addr_bus[ADDR_WIDTH_B-1];
            rd_cs_bit2_bus[gen_csb] = 0; 
         end
         else if(CS_ADDR_WIDTH_B >= 3) begin
            rd_cs_bit0 = rd_addr_bus[ADDR_WIDTH_B-CS_ADDR_WIDTH_B];
            rd_cs_bit1_bus[gen_csb] = (rd_addr_bus[(ADDR_WIDTH_B-1):CS_ADDR_B_3_LSB] == (gen_csb/2) ) ? 0: 1;
            rd_cs_bit2_bus[gen_csb] = 0;
         end
      end
      else begin
         if(CS_ADDR_WIDTH_B == 0) begin
            rd_cs_bit0 = 0;
            rd_cs_bit1_bus[gen_csb] = 0;
            rd_cs_bit2_bus[gen_csb] = 0;
         end
         else if(CS_ADDR_WIDTH_B ==1 ) begin
            rd_cs_bit0 = rd_addr_bus[ADDR_WIDTH_B-CS_ADDR_WIDTH_B];
            rd_cs_bit1_bus[gen_csb] = 0; 
            rd_cs_bit2_bus[gen_csb] = 0;
         end
         else if(CS_ADDR_WIDTH_B == 2) begin
            rd_cs_bit0 = rd_addr_bus[ADDR_WIDTH_B-2];
            rd_cs_bit1_bus[gen_csb] = rd_addr_bus[ADDR_WIDTH_B-1];
            rd_cs_bit2_bus[gen_csb] = 0; 
         end
         else if(CS_ADDR_WIDTH_B == 3) begin
            rd_cs_bit0 = rd_addr_bus[ADDR_WIDTH_B-3];
            rd_cs_bit1_bus[gen_csb] = rd_addr_bus[ADDR_WIDTH_B-2];
            rd_cs_bit2_bus[gen_csb] = rd_addr_bus[ADDR_WIDTH_B-1];
         end
         else if(CS_ADDR_WIDTH_B >= 4) begin
            rd_cs_bit0 = rd_addr_bus[ADDR_WIDTH_B-CS_ADDR_WIDTH_B];
            rd_cs_bit1_bus[gen_csb] = rd_addr_bus[ADDR_WIDTH_B - CS_ADDR_WIDTH_B + 1];
            rd_cs_bit2_bus[gen_csb] = (rd_addr_bus[(ADDR_WIDTH_B - 1):CS_ADDR_B_4_LSB] == (gen_csb/4) ) ? 0 : 1;
         end
      end
   end
end

always @(posedge rd_clk or posedge rd_rst)
begin
    if (rd_rst) begin
        rd_cs_bit0_ff     <= 0;
        rd_cs_bit1_bus_ff <= 0;
        rd_cs_bit2_bus_ff <= 0;
    end
    else if(~rd_addr_strobe) begin
        rd_cs_bit0_ff     <= rd_cs_bit0;
        rd_cs_bit1_bus_ff <= rd_cs_bit1_bus;
        rd_cs_bit2_bus_ff <= rd_cs_bit2_bus;
    end
end

assign rd_cs_bit0_m     = (c_SIM_DEVICE == "PGL22G") ? (rd_addr_strobe ? rd_cs_bit0_ff     : rd_cs_bit0    ) : rd_cs_bit0;
assign rd_cs_bit1_bus_m = (c_SIM_DEVICE == "PGL22G") ? (rd_addr_strobe ? rd_cs_bit1_bus_ff : rd_cs_bit1_bus) : rd_cs_bit1_bus;
assign rd_cs_bit2_bus_m = (c_SIM_DEVICE == "PGL22G") ? (rd_addr_strobe ? rd_cs_bit2_bus_ff : rd_cs_bit2_bus) : rd_cs_bit2_bus;

wire [18*DATA_LOOP_NUM*ADDR_LOOP_NUM_A-1:0]  QA_bus;
wire [18*DATA_LOOP_NUM*ADDR_LOOP_NUM_B-1:0]  QB_bus;
wire [18*DATA_LOOP_NUM-1:0]                  DA_bus;
wire [18*DATA_LOOP_NUM-1:0]                  DB_bus;

integer  drm_d_i;
always@(*) begin
    for (drm_d_i = 0; drm_d_i <DATA_LOOP_NUM; drm_d_i = drm_d_i+1) begin
       db_data_bus[drm_d_i*D_DRM_DATA_WIDTH_B +:D_DRM_DATA_WIDTH_B] = 'b0;
       da_data_bus[drm_d_i*D_DRM_DATA_WIDTH_A +:D_DRM_DATA_WIDTH_A] = 'b0;
       if(DRM_DATA_WIDTH_A == 36 || DRM_DATA_WIDTH_A == 32)          //DRM data_in = {DB,DA}
          {db_data_bus[drm_d_i*D_DRM_DATA_WIDTH_B +:D_DRM_DATA_WIDTH_B] ,da_data_bus[drm_d_i*D_DRM_DATA_WIDTH_A +:D_DRM_DATA_WIDTH_A]} = wr_data_mix_bus[drm_d_i*DRM_DATA_WIDTH_A +:DRM_DATA_WIDTH_A];
       else begin                                                    //DRM data_in = DA 
          da_data_bus[drm_d_i*D_DRM_DATA_WIDTH_A +:D_DRM_DATA_WIDTH_A] = wr_data_mix_bus[drm_d_i*DRM_DATA_WIDTH_A +:DRM_DATA_WIDTH_A];
          db_data_bus[drm_d_i*D_DRM_DATA_WIDTH_B +:D_DRM_DATA_WIDTH_B] = 'b0;
       end
    end
end

//***********************************************************************************************************************************************************
//INSTANCE DRM
//generate DRMs: ADDR_LOOP to cascade request address  and  DATA LOOP to cascade request data
genvar gen_i,gen_j;
generate  
  for(gen_j=0;gen_j<ADDR_LOOP_NUM_A;gen_j=gen_j+1) begin:ADDR_LOOP
     for(gen_i=0;gen_i<DATA_LOOP_NUM;gen_i=gen_i+1) begin:DATA_LOOP
        localparam [2:0] csa_mask = ((DRM_DATA_WIDTH_A == 36 || DRM_DATA_WIDTH_A == 32) || (DRM_DATA_WIDTH_B == 36 || DRM_DATA_WIDTH_B == 32)) ? 3'b011 & gen_j%MASK_NUM_A : gen_j%MASK_NUM_A;
        localparam [2:0] csb_mask = gen_j%MASK_NUM_B;
        assign wr_cs2_ctrl[gen_j] = (c_SIM_DEVICE == "PGL22G") ? ((c_WR_DATA_WIDTH != c_RD_DATA_WIDTH) && (DRM_DATA_WIDTH_B == 36 || DRM_DATA_WIDTH_B == 32)) ? wr_cs_bit2_bus_m[gen_j] | (~wr_en) : wr_cs_bit2_bus_m[gen_j]
                                                               : wr_cs_bit2_bus_m[gen_j];
     //write data  bus             
        if( Q_DRM_DATA_WIDTH_A == 16 ) begin:QA
           assign  qa_data_bus[gen_i*Q_DRM_DATA_WIDTH_A+gen_j*Q_CAS_DATA_WIDTH_A +:Q_DRM_DATA_WIDTH_A] = {QA_bus[(gen_i*18+gen_j*18*DATA_LOOP_NUM+9) +:8],QA_bus[(gen_i*18+gen_j*18*DATA_LOOP_NUM) +:8]};
        end
        else begin:QA
           assign  qa_data_bus[gen_i*Q_DRM_DATA_WIDTH_A+gen_j*Q_CAS_DATA_WIDTH_A +:Q_DRM_DATA_WIDTH_A] = QA_bus[(gen_i*18+gen_j*18*DATA_LOOP_NUM) +:Q_DRM_DATA_WIDTH_A];
        end
        
        if( D_DRM_DATA_WIDTH_A == 16 ) begin:DA
           assign  {DA_bus[(gen_i*18+9) +:8],DA_bus[gen_i*18 +:8]} = da_data_bus[gen_i*16 +:16];
        end
        else begin:DA
           assign  DA_bus[gen_i*18 +:D_DRM_DATA_WIDTH_A] = da_data_bus[gen_i*D_DRM_DATA_WIDTH_A +:D_DRM_DATA_WIDTH_A];
        end          
        
        if( Q_DRM_DATA_WIDTH_B == 16 ) begin:QB
           assign  qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:Q_DRM_DATA_WIDTH_B] = {QB_bus[(gen_i*18+gen_j*18*DATA_LOOP_NUM+9) +:8],QB_bus[(gen_i*18+gen_j*18*DATA_LOOP_NUM) +:8]};
        end
        else begin:QB
           assign  qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:Q_DRM_DATA_WIDTH_B] = QB_bus[(gen_i*18+gen_j*18*DATA_LOOP_NUM) +:Q_DRM_DATA_WIDTH_B];
        end            

        if( D_DRM_DATA_WIDTH_B == 16 ) begin:DB
           assign  {DB_bus[(gen_i*18+9) +:8],DB_bus[gen_i*18 +:8]} = db_data_bus[gen_i*16 +:16];
        end
        else begin:DB
           assign  DB_bus[gen_i*18 +:D_DRM_DATA_WIDTH_B] = db_data_bus[gen_i*D_DRM_DATA_WIDTH_B +:D_DRM_DATA_WIDTH_B];
        end

        GTP_DRM18K # (

                 .GRS_EN                   ( "FALSE"                  ),
                 .SIM_DEVICE               ( c_SIM_DEVICE             ),
                 .CSA_MASK                 ( csa_mask                 ),
                 .CSB_MASK                 ( csb_mask                 ),  
                 .DATA_WIDTH_A             ( DRM_DATA_WIDTH_A         ),    // 1 2 4 8 16 9 18 
                 .DATA_WIDTH_B             ( DRM_DATA_WIDTH_B         ),    // 1 2 4 8 16 9 18                     
                 .WRITE_MODE_A             ( "NORMAL_WRITE"           ),
                 .WRITE_MODE_B             ( "NORMAL_WRITE"           ),   
                 .DOA_REG                  ( c_OUTPUT_REG             ),
                 .DOB_REG                  ( c_OUTPUT_REG             ),
                 .DOA_REG_CLKINV           ( c_RD_CLK_OR_POL_INV      ),
                 .DOB_REG_CLKINV           ( c_RD_CLK_OR_POL_INV      ),
                 .RST_TYPE                 ( c_RST_TYPE               ),    // ASYNC_RESET_SYNC_RELEASE SYNC_RESET
                 .RAM_MODE                 ( "SIMPLE_DUAL_PORT"       ),    // TRUE_DUAL_PORT                   
                 .INIT_FILE                ( c_INIT_FILE              ),                 
                 .BLOCK_X                  ( gen_i                    ),
                 .BLOCK_Y                  ( gen_j                    ),
                 .RAM_ADDR_WIDTH           ( ADDR_WIDTH_A             ),
                 .RAM_DATA_WIDTH           ( CAS_DATA_WIDTH_A         ),
                 .INIT_FORMAT              ( c_INIT_FORMAT            )    //binary or hex       
        ) U_GTP_DRM18K (
                .DOA(QA_bus[(gen_i*18+gen_j*18*DATA_LOOP_NUM) +:18]),
                .ADDRA(drm_wr_addr_bus[gen_i*14 +:14]),            //wr_addr[13:0]
                .ADDRA_HOLD(wr_addr_strobe),
                .DIA(DA_bus[gen_i*18 +:18]),
                .CSA({wr_cs2_ctrl[gen_j],wr_cs_bit1_bus_m[gen_j],wr_cs_bit0_m}),
                .WEA(wr_en_bus[gen_i]),
                .CLKA(wr_clk),
                .CEA(wr_clk_en),
                .ORCEA(rd_oce),
                .RSTA(wr_rst),

                .DOB(QB_bus[(gen_i*18+gen_j*18*DATA_LOOP_NUM) +:18]),
                .ADDRB(drm_rd_addr[13:0]),             //rd_addr[13:0]
                .ADDRB_HOLD(rd_addr_strobe),
                .DIB(DB_bus[gen_i*18 +:18]),
                .CSB({rd_cs_bit2_bus_m[gen_j],rd_cs_bit1_bus_m[gen_j],rd_cs_bit0_m}),
                .WEB(1'b0),
                .CLKB(rd_clk),
                .CEB(rd_clk_en),
                .ORCEB(rd_oce),
                .RSTB(rd_rst)
       );
       
       //drive rd_data_bus 
        if(DRM_DATA_WIDTH_B == 36 || DRM_DATA_WIDTH_B == 32) begin     //DRM  data_out = {QB,QA}
           if ((WIDTH_RATIO == 2) && (DATA_WIDTH_W2N == 0) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_A))
               assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = {qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW],
                                                                                                       qa_data_bus[gen_i*Q_DRM_DATA_WIDTH_A+gen_j*Q_CAS_DATA_WIDTH_A +:DATA_WIDTH_NARROW]};
           else if ((WIDTH_RATIO == 4) && (DATA_WIDTH_W2N == 0) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_A))
               assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = {qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW],
                                                                                                       qa_data_bus[(gen_i*Q_DRM_DATA_WIDTH_A+gen_j*Q_CAS_DATA_WIDTH_A+DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qa_data_bus[gen_i*Q_DRM_DATA_WIDTH_A+gen_j*Q_CAS_DATA_WIDTH_A +:DATA_WIDTH_NARROW]};
           else if ((WIDTH_RATIO == 8) && (DATA_WIDTH_W2N == 0) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_A))
               assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = {qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+3*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+2*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW],
                                                                                                       qa_data_bus[(gen_i*Q_DRM_DATA_WIDTH_A+gen_j*Q_CAS_DATA_WIDTH_A+3*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qa_data_bus[(gen_i*Q_DRM_DATA_WIDTH_A+gen_j*Q_CAS_DATA_WIDTH_A+2*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qa_data_bus[(gen_i*Q_DRM_DATA_WIDTH_A+gen_j*Q_CAS_DATA_WIDTH_A+DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qa_data_bus[gen_i*Q_DRM_DATA_WIDTH_A+gen_j*Q_CAS_DATA_WIDTH_A +:DATA_WIDTH_NARROW]};
           else if ((WIDTH_RATIO == 16) && (DATA_WIDTH_W2N == 0) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_A))
               assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = {qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+7*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+6*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+5*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+4*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+3*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+2*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW],
                                                                                                       qa_data_bus[(gen_i*Q_DRM_DATA_WIDTH_A+gen_j*Q_CAS_DATA_WIDTH_A+7*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qa_data_bus[(gen_i*Q_DRM_DATA_WIDTH_A+gen_j*Q_CAS_DATA_WIDTH_A+6*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qa_data_bus[(gen_i*Q_DRM_DATA_WIDTH_A+gen_j*Q_CAS_DATA_WIDTH_A+5*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qa_data_bus[(gen_i*Q_DRM_DATA_WIDTH_A+gen_j*Q_CAS_DATA_WIDTH_A+4*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qa_data_bus[(gen_i*Q_DRM_DATA_WIDTH_A+gen_j*Q_CAS_DATA_WIDTH_A+3*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qa_data_bus[(gen_i*Q_DRM_DATA_WIDTH_A+gen_j*Q_CAS_DATA_WIDTH_A+2*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qa_data_bus[(gen_i*Q_DRM_DATA_WIDTH_A+gen_j*Q_CAS_DATA_WIDTH_A+DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                       qa_data_bus[gen_i*Q_DRM_DATA_WIDTH_A+gen_j*Q_CAS_DATA_WIDTH_A +:DATA_WIDTH_NARROW]};
           else if ((WIDTH_RATIO == 2) && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B))
              assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = rd_addr_bsel_bus[0] ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                                         : qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW];
           else if ((WIDTH_RATIO == 4)  && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B) && (MODE_RATIO == 2))
              assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = rd_addr_bsel_bus[0] ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                                         : qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW];
           else if ((WIDTH_RATIO == 4) && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B))
              assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = (rd_addr_bsel_bus[1:0] == 2'b00) ? qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW]
                                                                                                   : (rd_addr_bsel_bus[1:0] == 2'b01) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DATA_WIDTH_NARROW)   +:DATA_WIDTH_NARROW]
                                                                                                   : (rd_addr_bsel_bus[1:0] == 2'b10) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+2*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                                                      : qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+3*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW];
           else if ((WIDTH_RATIO == 8)  && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B) && (MODE_RATIO == 4))
              assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = (rd_addr_bsel_bus[1:0] == 2'b00) ? qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW]
                                                                                                   : (rd_addr_bsel_bus[1:0] == 2'b01) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DATA_WIDTH_NARROW)   +:DATA_WIDTH_NARROW]
                                                                                                   : (rd_addr_bsel_bus[1:0] == 2'b10) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+2*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                                                      : qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+3*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW];
           else if ((WIDTH_RATIO == 8)  && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B) && (MODE_RATIO == 2))
              assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = rd_addr_bsel_bus[0] ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                                         : qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW];
           else if ((WIDTH_RATIO == 8) && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B))
               assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = (rd_addr_bsel_bus[2:0] == 3'b000) ? qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[2:0] == 3'b001) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DATA_WIDTH_NARROW)   +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[2:0] == 3'b010) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+2*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[2:0] == 3'b011) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+3*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[2:0] == 3'b100) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+4*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[2:0] == 3'b101) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+5*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[2:0] == 3'b110) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+6*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                                                        : qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+7*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW];
           else if ((WIDTH_RATIO == 16) && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B) && (MODE_RATIO == 2))
               assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = rd_addr_bsel_bus[0] ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                                          : qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW];
           else if ((WIDTH_RATIO == 16) && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B))
               assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = (rd_addr_bsel_bus[3:0] == 4'b0000) ? qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[3:0] == 4'b0001) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DATA_WIDTH_NARROW)    +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[3:0] == 4'b0010) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+2*DATA_WIDTH_NARROW)  +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[3:0] == 4'b0011) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+3*DATA_WIDTH_NARROW)  +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[3:0] == 4'b0100) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+4*DATA_WIDTH_NARROW)  +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[3:0] == 4'b0101) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+5*DATA_WIDTH_NARROW)  +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[3:0] == 4'b0110) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+6*DATA_WIDTH_NARROW)  +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[3:0] == 4'b0111) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+7*DATA_WIDTH_NARROW)  +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[3:0] == 4'b1000) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+8*DATA_WIDTH_NARROW)  +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[3:0] == 4'b1001) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+9*DATA_WIDTH_NARROW)  +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[3:0] == 4'b1010) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+10*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[3:0] == 4'b1011) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+11*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[3:0] == 4'b1100) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+12*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[3:0] == 4'b1101) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+13*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                    : (rd_addr_bsel_bus[3:0] == 4'b1110) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+14*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                                                         : qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+15*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW];
           else
               assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = {qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:Q_DRM_DATA_WIDTH_B],
                                                                                                       qa_data_bus[gen_i*Q_DRM_DATA_WIDTH_A+gen_j*Q_CAS_DATA_WIDTH_A +:Q_DRM_DATA_WIDTH_A]};
        end
        else if ((WIDTH_RATIO == 2) && (DATA_WIDTH_W2N == 0) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_A))
           assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = {qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW]};
        else if ((WIDTH_RATIO == 4) && (DATA_WIDTH_W2N == 0) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_A))
           assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = {qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+3*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+2*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW]};
        else if ((WIDTH_RATIO == 8) && (DATA_WIDTH_W2N == 0) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_A))
           assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = {qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+7*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+6*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+5*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+4*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+3*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+2*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW]};
        else if ((WIDTH_RATIO == 16) && (DATA_WIDTH_W2N == 0) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_A))
           assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = {qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+15*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+14*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+13*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+12*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+11*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+10*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+9*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+8*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+7*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+6*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+5*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+4*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+3*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+2*DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DRM_DATA_WIDTH_A) +:DATA_WIDTH_NARROW],
                                                                                                   qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW]};
        else if ((WIDTH_RATIO == 2) && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B))
           assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = rd_addr_bsel_bus[0] ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                                      : qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW];
        else if ((WIDTH_RATIO == 4)  && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B) && (MODE_RATIO == 2))
           assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = rd_addr_bsel_bus[0] ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                                      : qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW];
        else if ((WIDTH_RATIO == 4) && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B))
            assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = (rd_addr_bsel_bus[1:0] == 2'b00) ? qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[1:0] == 2'b01) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DATA_WIDTH_NARROW)   +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[1:0] == 2'b10) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+2*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                                                    : qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+3*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW];
        else if ((WIDTH_RATIO == 8)  && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B) && (MODE_RATIO == 4))
           assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = (rd_addr_bsel_bus[1:0] == 2'b00) ? qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW]
                                                                                                : (rd_addr_bsel_bus[1:0] == 2'b01) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DATA_WIDTH_NARROW)   +:DATA_WIDTH_NARROW]
                                                                                                : (rd_addr_bsel_bus[1:0] == 2'b10) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+2*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                                                   : qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+3*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW];
        else if ((WIDTH_RATIO == 8)  && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B) && (MODE_RATIO == 2))
           assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = rd_addr_bsel_bus[0] ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                                      : qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW];
        else if ((WIDTH_RATIO == 8) && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B))
            assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = (rd_addr_bsel_bus[2:0] == 3'b000) ? qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[2:0] == 3'b001) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DATA_WIDTH_NARROW)   +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[2:0] == 3'b010) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+2*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[2:0] == 3'b011) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+3*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[2:0] == 3'b100) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+4*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[2:0] == 3'b101) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+5*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[2:0] == 3'b110) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+6*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                                                     : qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+7*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW];
        else if ((WIDTH_RATIO == 16) && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B) && (MODE_RATIO == 2))
            assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = rd_addr_bsel_bus[0] ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                                       : qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW];
        else if ((WIDTH_RATIO == 16) && (DATA_WIDTH_W2N == 1) && (DATA_WIDTH_NARROW < DRM_DATA_WIDTH_B))
            assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] = (rd_addr_bsel_bus[3:0] == 4'b0000) ? qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[3:0] == 4'b0001) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+DATA_WIDTH_NARROW)    +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[3:0] == 4'b0010) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+2*DATA_WIDTH_NARROW)  +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[3:0] == 4'b0011) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+3*DATA_WIDTH_NARROW)  +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[3:0] == 4'b0100) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+4*DATA_WIDTH_NARROW)  +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[3:0] == 4'b0101) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+5*DATA_WIDTH_NARROW)  +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[3:0] == 4'b0110) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+6*DATA_WIDTH_NARROW)  +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[3:0] == 4'b0111) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+7*DATA_WIDTH_NARROW)  +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[3:0] == 4'b1000) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+8*DATA_WIDTH_NARROW)  +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[3:0] == 4'b1001) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+9*DATA_WIDTH_NARROW)  +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[3:0] == 4'b1010) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+10*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[3:0] == 4'b1011) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+11*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[3:0] == 4'b1100) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+12*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[3:0] == 4'b1101) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+13*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                 : (rd_addr_bsel_bus[3:0] == 4'b1110) ? qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+14*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW]
                                                                                                                                      : qb_data_bus[(gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B+15*DATA_WIDTH_NARROW) +:DATA_WIDTH_NARROW];
        else                                                      //DRM  data_out = QB
           assign rd_data_bus[gen_i*DRM_DATA_WIDTH_B+gen_j*CAS_DATA_WIDTH_B +:DRM_DATA_WIDTH_B] =  qb_data_bus[gen_i*Q_DRM_DATA_WIDTH_B+gen_j*Q_CAS_DATA_WIDTH_B +:Q_DRM_DATA_WIDTH_B];     
     end
  end
endgenerate


localparam   RD_ADDR_SEL_LSB = (CS_ADDR_WIDTH_B > 0) ? (ADDR_WIDTH_B - CS_ADDR_WIDTH_B) : (ADDR_WIDTH_B - 1); 

//cs read addr register  to match read data 
wire [CS_ADDR_WIDTH_B-1:0]   addr_bus_rd_sel;
reg  [CS_ADDR_WIDTH_B-1:0]   addr_bus_rd_ce;
reg  [CS_ADDR_WIDTH_B-1:0]   addr_bus_rd_oce;
reg  [CS_ADDR_WIDTH_B-1:0]   addr_bus_rd_invt;

//CE
always @(posedge rd_clk or posedge rd_rst)
begin
    if (rd_rst)
        addr_bus_rd_ce   <= 0;
    else if (~rd_addr_strobe & rd_clk_en)
        addr_bus_rd_ce <= rd_addr_bus[ADDR_WIDTH_B-1:RD_ADDR_SEL_LSB];
end

//OCE
always @(posedge rd_clk or posedge rd_rst)
begin
    if (rd_rst)
        addr_bus_rd_oce <= 0;
    else if (rd_oce)
        addr_bus_rd_oce <= addr_bus_rd_ce;
end

//INVT
always @(negedge rd_clk or posedge rd_rst)
begin
    if (rd_rst)
        addr_bus_rd_invt <= 0;
    else if (rd_oce)
        addr_bus_rd_invt <= addr_bus_rd_ce;
end

assign  addr_bus_rd_sel = (c_RD_CLK_OR_POL_INV == 1) ? addr_bus_rd_invt : (c_OUTPUT_REG == 1) ? addr_bus_rd_oce : addr_bus_rd_ce;

//select read data
integer cs_rd;
always@(*) begin
   rd_mix_data = 'b0;
   if(ADDR_LOOP_NUM_B >1 ) begin
      for(cs_rd=0;cs_rd<ADDR_LOOP_NUM_B;cs_rd=cs_rd+1) begin
         if(addr_bus_rd_sel== cs_rd)
            rd_mix_data = rd_data_bus[cs_rd*CAS_DATA_WIDTH_B +:CAS_DATA_WIDTH_B];
      end
   end
   else begin
      rd_mix_data = rd_data_bus;
   end
end

integer  gen_i_rd,gen_j_rd;
always@(*) begin
   if( c_RD_DATA_WIDTH > c_WR_DATA_WIDTH && DATA_LOOP_NUM > 1 ) begin   //read mix data
      for (gen_i_rd=0;gen_i_rd < WIDTH_RATIO;gen_i_rd = gen_i_rd + 1)
         for(gen_j_rd=0;gen_j_rd < DATA_LOOP_NUM ;gen_j_rd = gen_j_rd+1)
             rd_full_data[gen_i_rd*(CAS_DATA_WIDTH_B/WIDTH_RATIO)+gen_j_rd*DRM_DATA_WIDTH_A +:DRM_DATA_WIDTH_A] = rd_mix_data[(gen_i_rd + gen_j_rd*WIDTH_RATIO)*DRM_DATA_WIDTH_A +:DRM_DATA_WIDTH_A];
   end
   else begin    //read nomix data
      rd_full_data = rd_mix_data;
   end
end

assign  rd_data = rd_full_data[c_RD_DATA_WIDTH-1:0];



endmodule

