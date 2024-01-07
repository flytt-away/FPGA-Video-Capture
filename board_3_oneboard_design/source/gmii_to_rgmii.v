`timescale 1ns / 1ps
`define UD #1
module gmii_to_rgmii(
    input        rst,
    output       rgmii_clk,
    //mac输入的数据由gmii转化为rgmii，时钟为rgmii_clk
    input        mac_tx_data_valid,
    input [7:0]  mac_tx_data,
    //eth输入的数据由rgmii转化为gmii，时钟为rgmii_clk
    output reg       mac_rx_error,
    output reg       mac_rx_data_valid,
    output reg [7:0] mac_rx_data,
    //eth接收
    input        rgmii_rxc,
    input        rgmii_rx_ctl,
    input [3:0]  rgmii_rxd,
    //eth发送        
    output       rgmii_txc,
    output       rgmii_tx_ctl,
    output [3:0] rgmii_txd 
);

    //=============================================================
    //  RGMII TX 
    //=============================================================
    wire       rgmii_txc_obuf;
    wire       rgmii_txc_tbuf;
    wire       rgmii_tx_ctl_obuf;
    wire       rgmii_tx_ctl_tbuf;
    wire [3:0] rgmii_txd_obuf;
    wire [3:0] rgmii_txd_tbuf;

    generate 
        genvar i;
        for (i=0; i<4; i=i+1) 
        begin : rgmii_tx_data            
            GTP_OSERDES #(
                .OSERDES_MODE("ODDR"),  //"ODDR","OMDDR","OGSER4","OMSER4","OGSER7","OGSER8",OMSER8"
                .WL_EXTEND   ("FALSE"),     //"TRUE"; "FALSE"
                .GRS_EN      ("TRUE"),         //"TRUE"; "FALSE"
                .LRS_EN      ("TRUE"),          //"TRUE"; "FALSE"
                .TSDDR_INIT  (1'b0)         //1'b0;1'b1
            ) tx_data_oddr(
                .DO    (rgmii_txd_obuf[i]),                        //数据输出  output
                .TQ    (rgmii_txd_tbuf[i]),                        //选通输出  output
                .DI    ({6'd0,mac_tx_data[i+4],mac_tx_data[i]}),   //数据输入  input
                .TI    (4'd0),                                     //选通输入  input
                .RCLK  (rgmii_clk),                                //输出时钟  input
                .SERCLK(rgmii_clk),                                //串行时钟  input
                .OCLK  (1'd0),                                     //输出时钟  input
                .RST   (1'b0)                                      //复位     input
            );                                         
            
            GTP_OUTBUFT  gtp_outbuft1(
                .I(rgmii_txd_obuf[i]),     
                .T(rgmii_txd_tbuf[i])  ,
                .O(rgmii_txd[i])        
            );
        end
    endgenerate

    GTP_OSERDES #(
        .OSERDES_MODE("ODDR"),  //"ODDR","OMDDR","OGSER4","OMSER4","OGSER7","OGSER8",OMSER8"
        .WL_EXTEND   ("FALSE"),     //"TRUE"; "FALSE"
        .GRS_EN      ("TRUE"),         //"TRUE"; "FALSE"
        .LRS_EN      ("TRUE"),          //"TRUE"; "FALSE"
        .TSDDR_INIT  (1'b0)         //1'b0;1'b1
    ) tx_ctl_oddr(
        .DO    (rgmii_tx_ctl_obuf),
        .TQ    (rgmii_tx_ctl_tbuf),
        .DI    ({6'd0,mac_tx_data_valid ^ 1'b0,mac_tx_data_valid}),
        .TI    (4'd0),
        .RCLK  (rgmii_clk),
        .SERCLK(rgmii_clk),
        .OCLK  (1'd0),
        .RST   (tx_reset_sync)
    );                                         
    
    GTP_OUTBUFT  gtp_outbuft1(
        .I(rgmii_tx_ctl_obuf),     
        .T(rgmii_tx_ctl_tbuf)  ,
        .O(rgmii_tx_ctl)        
    );

    //DDR数据输出转换模块
    GTP_OSERDES #(
     .OSERDES_MODE("ODDR"),  //"ODDR","OMDDR","OGSER4","OMSER4","OGSER7","OGSER8",OMSER8"
     .WL_EXTEND   ("FALSE"),     //"TRUE"; "FALSE"
     .GRS_EN      ("TRUE"),         //"TRUE"; "FALSE"
     .LRS_EN      ("TRUE"),          //"TRUE"; "FALSE"
     .TSDDR_INIT  (1'b0)         //1'b0;1'b1
    ) tx_clk_oddr(
       .DO    (rgmii_txc_obuf),
       .TQ    (rgmii_txc_tbuf),
       .DI    ({7'd0,1'b1}),
       .TI    (4'd0),
       .RCLK  (rgmii_clk),
       .SERCLK(rgmii_clk),
       .OCLK  (1'd0),
       .RST   (tx_reset_sync)
    ); 
    GTP_OUTBUFT  gtp_outbuft6
    (
        
        .I(rgmii_txc_obuf),     
        .T(rgmii_txc_tbuf)  ,
        .O(rgmii_txc)        
    );                                                                                                            
    

    
    //=============================================================
    //  RGMII RX 
    //=============================================================
    wire        rgmii_rxc_ibuf;
    wire        rgmii_rxc_bufio;
    wire        rgmii_rx_ctl_ibuf;
    wire [3:0]  rgmii_rxd_ibuf;

    wire [7:0] delay_step_b ;
    wire [7:0] delay_step_gray ;
    
    assign delay_step_b = 8'hA0;   // 0~247 , 10ps/step

    wire lock;
    GTP_DLL #(
        .GRS_EN("TRUE"),
        .FAST_LOCK("TRUE"),
        .DELAY_STEP_OFFSET(0) 
    ) clk_dll (
        .DELAY_STEP(delay_step_gray),// OUTPUT[7:0]  
        .LOCK      (lock),      // OUTPUT  
        .CLKIN     (rgmii_rxc),     // INPUT  
        .PWD       (1'b0),       // INPUT  
        .RST       (1'b0),       // INPUT  
        .UPDATE_N  (1'b1)   // INPUT  
    );
    GTP_IOCLKDELAY #(
        .DELAY_STEP_VALUE   (  'd127           ),
        .DELAY_STEP_SEL     (  "PARAMETER"     ),
        .SIM_DEVICE         (  "LOGOS"         ) 
    ) rgmii_clk_delay (
        .DELAY_STEP         (  delay_step_gray ),// INPUT[7:0]     
        .CLKOUT             (  rgmii_rxc_ibuf  ),// OUTPUT         
        .DELAY_OB           (                  ),// OUTPUT         
        .CLKIN              (  rgmii_rxc       ),// INPUT          
        .DIRECTION          (  1'b0            ),// INPUT          
        .LOAD               (  1'b0            ),// INPUT          
        .MOVE               (  1'b0            ) // INPUT          
    );

    GTP_CLKBUFG GTP_CLKBUFG_RXSHFT(
        .CLKIN     (rgmii_rxc_ibuf),
        .CLKOUT    (rgmii_clk)
    );


    GTP_INBUF #(
        .IOSTANDARD("DEFAULT"),
        .TERM_DDR("ON")
    ) u_rgmii_rx_ctl_ibuf (
        .O(rgmii_rx_ctl_ibuf),// OUTPUT  
        .I(rgmii_rx_ctl) // INPUT  
    );
    
    wire  rgmii_rx_ctl_delay;
    parameter DELAY_STEP = 8'h0F;

    wire [5:0] rx_ctl_nc;
    wire       gmii_ctl;
    wire       rgmii_rx_valid_xor_error;
    GTP_ISERDES #(
        .ISERDES_MODE("IDDR"),
        .GRS_EN("TRUE"),
        .LRS_EN("TRUE") 
    ) gmii_ctl_in (
        .DO   ({rgmii_rx_valid_xor_error,gmii_ctl,rx_ctl_nc[5: 0]}),    // OUTPUT[7:0]  
        .RADDR(3'd0), // INPUT[2:0]  
        .WADDR(3'd0), // INPUT[2:0]  
        .DESCLK(rgmii_clk),// INPUT  
        .DI(rgmii_rx_ctl_ibuf),    // INPUT  
        .ICLK(1'b0),  // INPUT  
        .RCLK(rgmii_clk),  // INPUT  
        .RST(1'b0)    // INPUT  
    );

    wire [3:0] rgmii_rxd_delay;
    wire [23:0] rxd_nc;
    wire [7:0]  gmii_rxd;
    always @(posedge rgmii_clk)
    begin
        mac_rx_data <= gmii_rxd;
        mac_rx_data_valid <= gmii_ctl;
        mac_rx_error <= gmii_ctl ^ rgmii_rx_valid_xor_error;
    end

    generate 
        genvar j;
        for (j=0; j<4; j=j+1)
        begin : rgmii_rx_data

            GTP_INBUF #(
                .IOSTANDARD("DEFAULT"),
                .TERM_DDR("ON")
            ) u_rgmii_rxd_ibuf (
                .O(rgmii_rxd_ibuf[j]),// OUTPUT  
                .I(rgmii_rxd[j]) // INPUT  
            );
            
            GTP_ISERDES #(
                .ISERDES_MODE("IDDR"),
                .GRS_EN("TRUE"),
                .LRS_EN("TRUE") 
            ) gmii_rxd_in (
                .DO   ({gmii_rxd[j+4],gmii_rxd[j],rxd_nc[j*6 +: 6]}),    // OUTPUT[7:0]  
                .RADDR(3'd0), // INPUT[2:0]  
                .WADDR(3'd0), // INPUT[2:0]  
                .DESCLK(rgmii_clk),// INPUT  
                .DI(rgmii_rxd_ibuf[j]),    // INPUT  
                .ICLK(1'b0),  // INPUT  
                .RCLK(rgmii_clk),  // INPUT  
                .RST(1'b0)    // INPUT  
            );

        end
    endgenerate
    

endmodule