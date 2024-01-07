`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:Meyesemi 
// Engineer: Will
// 
// Create Date: 2023-01-29 20:31  
// Design Name:  
// Module Name: 
// Project Name: 
// Target Devices: Pango
// Tool Versions: 
// Description: 
//      
// Dependencies: 
// 
// Revision:
// Revision 1.0 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define UD #1
module hdmi_ctrl(
    input       clk,
    input       rst_n,
    
    output      init_over,
    output      iic_tx_scl,
    inout       iic_tx_sda,
    output      iic_scl,
    inout       iic_sda
);
    reg rstn_temp1,rstn_temp2;
    reg rstn;
    always @(posedge clk or negedge rst_n)
    begin
    	if(!rst_n)
    	    rstn_temp1 <= 1'b0;
    	else
    	    rstn_temp1 <= rst_n;
    end
    
    always @(posedge clk)
    begin
    	rstn_temp2 <= rstn_temp1;
    	rstn <= rstn_temp2;
    end
    
    wire         init_over_rx;
    wire   [7:0] device_id_rx;
    wire         iic_trig_rx ;
    wire         w_r_rx      ;
    wire  [15:0] addr_rx     /*synthesis PAP_MARK_DEBUG="true"*/;
    wire  [ 7:0] data_in_rx  ;
    wire         busy_rx     ;
    wire  [ 7:0] data_out_rx ;
    wire         byte_over_rx;
    
    wire   [7:0] device_id_tx;
    wire         iic_trig_tx ;
    wire         w_r_tx      ;
    wire  [15:0] addr_tx     /*synthesis PAP_MARK_DEBUG="true"*/;
    wire  [ 7:0] data_in_tx  ;
    wire         busy_tx     ;
    wire  [ 7:0] data_out_tx ;
    wire         byte_over_tx;
    
//    wire   [7:0] device_id   ;
//    wire         iic_trig    ;
//    wire         w_r         ;
//    wire  [15:0] addr        /*synthesis PAP_MARK_DEBUG="true"*/;
//    wire  [ 7:0] data_in     ;
//    wire         busy        ;
//    wire  [ 7:0] data_out    /*synthesis PAP_MARK_DEBUG="true"*/;
//    wire         byte_over   /*synthesis PAP_MARK_DEBUG="true"*/;

    ms7200_ctrl user_ms7200_ctrl(
        .clk             (  clk           ),//input               
        .rstn            (  rstn          ),//input               
                              
        .init_over       (  init_over_rx  ),//output reg          
        .device_id       (  device_id_rx  ),//output        [7:0] 
        .iic_trig        (  iic_trig_rx   ),//output reg          
        .w_r             (  w_r_rx        ),//output reg          
        .addr            (  addr_rx       ),//output reg   [15:0] 
        .data_in         (  data_in_rx    ),//output reg   [ 7:0] 
        .busy            (  busy_rx       ),//input               
        .data_out        (  data_out_rx   ),//input        [ 7:0] 
        .byte_over       (  byte_over_rx  ) //input               
    );
    
    ms7210_ctrl user_ms7210_ctrl(
        .clk             (  clk           ),//input               
        .rstn            (  init_over_rx  ),//input    rstn),//           
                              
        .init_over       (  init_over     ),//output reg          
        .device_id       (  device_id_tx  ),//output        [7:0] 
        .iic_trig        (  iic_trig_tx   ),//output reg          
        .w_r             (  w_r_tx        ),//output reg          
        .addr            (  addr_tx       ),//output reg   [15:0] 
        .data_in         (  data_in_tx    ),//output reg   [ 7:0] 
        .busy            (  busy_tx       ),//input               
        .data_out        (  data_out_tx   ),//input        [ 7:0] 
        .byte_over       (  byte_over_tx  ) //input               
    );
    
//    assign device_id = (init_over_rx == 1'b1 && init_over == 1'b0) ? device_id_tx : device_id_rx;
//    assign iic_trig = (init_over_rx == 1'b1 && init_over == 1'b0) ? iic_trig_tx : iic_trig_rx;
//    assign w_r = (init_over_rx == 1'b1 && init_over == 1'b0) ? w_r_tx : w_r_rx;
//    assign addr = (init_over_rx == 1'b1 && init_over == 1'b0) ? addr_tx : addr_rx;
//    assign data_in = (init_over_rx == 1'b1 && init_over == 1'b0) ? data_in_tx : data_in_rx;
//    assign busy_tx = (init_over_rx == 1'b1 && init_over == 1'b0) ? busy : 0;
//    assign data_out_tx = (init_over_rx == 1'b1 && init_over == 1'b0) ? data_out : 0;
//    assign byte_over_tx = (init_over_rx == 1'b1 && init_over == 1'b0) ? byte_over : 0;
//    
//    assign busy_rx = (init_over_rx == 1'b0 || init_over == 1'b1) ? busy : 0;
//    assign data_out_rx = (init_over_rx == 1'b0 || init_over == 1'b1) ? data_out : 0;
//    assign byte_over_rx = (init_over_rx == 1'b0 || init_over == 1'b1) ? byte_over : 0;

    wire         sda_in/*synthesis PAP_MARK_DEBUG="true"*/;
    wire         sda_out/*synthesis PAP_MARK_DEBUG="true"*/;
    wire         sda_out_en/*synthesis PAP_MARK_DEBUG="true"*/;  
    iic_rx_driver #(
        .CLK_FRE        (  27'd10_000_000  ),//parameter            CLK_FRE   = 27'd50_000_000,//system clock frequency
        .IIC_FREQ       (  20'd400_000     ),//parameter            IIC_FREQ  = 20'd400_000,   //I2c clock frequency
        .T_WR           (  10'd1           ),//parameter            T_WR      = 10'd5,         //I2c transmit delay ms
        .ADDR_BYTE      (  2'd2            ),//parameter            ADDR_BYTE = 2'd1,          //I2C addr byte number
        .LEN_WIDTH      (  8'd3            ),//parameter            LEN_WIDTH = 8'd3,          //I2C transmit byte width
        .DATA_BYTE      (  2'd1            ) //parameter            DATA_BYTE = 2'd1           //I2C data byte number
    )user_iic_rx_driver(                       
        .clk            (  clk             ),//input                clk,
        .rstn           (  rstn            ),//input                rstn,
        .device_id      (  device_id_rx    ),//input                device_id,
        .pluse          (  iic_trig_rx     ),//input                pluse,                     //I2C transmit trigger
        .w_r            (  w_r_rx          ),//input                w_r,                       //I2C transmit direction 1:send  0:receive
        .byte_len       (  4'd1            ),//input  [LEN_WIDTH:0] byte_len,                  //I2C transmit data byte length of once trigger
                   
        .addr           (  addr_rx         ),//input  [7:0]         addr,                      //I2C transmit addr
        .data_in        (  data_in_rx      ),//input  [7:0]         data_in,                   //I2C send data
                     
        .busy           (  busy_rx         ),//output reg           busy=0,                    //I2C bus status
        
        .byte_over      (  byte_over_rx    ),//output reg           byte_over=0,               //I2C byte transmit over flag               
        .data_out       (  data_out_rx     ),//output reg[7:0]      data_out,                  //I2C receive data
                                           
        .scl            (  iic_scl         ),//output               scl,
        .sda_in         (  sda_in          ),//input                sda_in,
        .sda_out        (  sda_out         ),//output   reg         sda_out=1'b1,
        .sda_out_en     (  sda_out_en      ) //output               sda_out_en
    );
    
    assign iic_sda = sda_out_en ? sda_out : 1'bz;
    assign sda_in = iic_sda;
    
    wire         sda_tx_in/*synthesis PAP_MARK_DEBUG="true"*/;
    wire         sda_tx_out/*synthesis PAP_MARK_DEBUG="true"*/;
    wire         sda_tx_out_en/*synthesis PAP_MARK_DEBUG="true"*/;  
    iic_tx_driver #(
        .CLK_FRE        (  27'd10_000_000  ),//parameter            CLK_FRE   = 27'd50_000_000,//system clock frequency
        .IIC_FREQ       (  20'd400_000     ),//parameter            IIC_FREQ  = 20'd400_000,   //I2c clock frequency
        .T_WR           (  10'd1           ),//parameter            T_WR      = 10'd5,         //I2c transmit delay ms
        .ADDR_BYTE      (  2'd2            ),//parameter            ADDR_BYTE = 2'd1,          //I2C addr byte number
        .LEN_WIDTH      (  8'd3            ),//parameter            LEN_WIDTH = 8'd3,          //I2C transmit byte width
        .DATA_BYTE      (  2'd1            ) //parameter            DATA_BYTE = 2'd1           //I2C data byte number
    )user_iic_tx_driver(                       
        .clk            (  clk             ),//input                clk,
        .rstn           (  rstn            ),//input                rstn,
        .device_id      (  device_id_tx    ),//input                device_id,
        .pluse          (  iic_trig_tx     ),//input                pluse,                     //I2C transmit trigger
        .w_r            (  w_r_tx          ),//input                w_r,                       //I2C transmit direction 1:send  0:receive
        .byte_len       (  4'd1            ),//input  [LEN_WIDTH:0] byte_len,                  //I2C transmit data byte length of once trigger
                   
        .addr           (  addr_tx         ),//input  [7:0]         addr,                      //I2C transmit addr
        .data_in        (  data_in_tx      ),//input  [7:0]         data_in,                   //I2C send data
                     
        .busy           (  busy_tx         ),//output reg           busy=0,                    //I2C bus status
        
        .byte_over      (  byte_over_tx    ),//output reg           byte_over=0,               //I2C byte transmit over flag               
        .data_out       (  data_out_tx     ),//output reg[7:0]      data_out,                  //I2C receive data
                                           
        .scl            (  iic_tx_scl      ),//output               scl,
        .sda_in         (  sda_tx_in       ),//input                sda_in,
        .sda_out        (  sda_tx_out      ),//output   reg         sda_out=1'b1,
        .sda_out_en     (  sda_tx_out_en   ) //output               sda_out_en
    );
    
    assign iic_tx_sda = sda_tx_out_en ? sda_tx_out : 1'bz;
    assign sda_tx_in = iic_tx_sda;
//    GTP_IOBUF #(
//        .IOSTANDARD     (  "DEFAULT"      ),
//        .SLEW_RATE      (  "SLOW"         ),
//        .DRIVE_STRENGTH (  "8"            ),
//        .TERM_DDR       (  "ON"           )
//    ) GTP_IOBUF         (                 
//        .IO             (  iic_sda        ),// INOUT  
//        .O              (  sda_in         ), // OUTPUT  
//        .I              (  sda_out        ), // INPUT  
//        .T              (  sda_out_en     )  // INPUT  
//    );
    
endmodule
