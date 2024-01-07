//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
module ipsl_pcie_cfg_ctrl_apb(
    //from APB
    input                   pclk_div2,
    input                   apb_rst_n,
    input                   p_sel,
    input       [3:0]       p_strb,
    input       [7:0]       p_addr,
    input       [31:0]      p_wdata,
    input                   p_ce,
    input                   p_we,
    output reg              p_rdy,
    output reg  [31:0]      p_rdata,
    output                  pcie_cfg_ctrl_en,
    //to cfg_trans
    output                  pcie_cfg_fmt,
    output                  pcie_cfg_type,
    output      [7:0]       pcie_cfg_tag,
    output      [3:0]       pcie_cfg_fbe,
    output      [15:0]      pcie_cfg_req_id,
    output      [15:0]      pcie_cfg_des_id,
    output      [9:0]       pcie_cfg_reg_num,
    output      [31:0]      pcie_cfg_tx_data,
    output                  tx_en,
    input                   pcie_cfg_cpl_rcv,
    input       [2:0]       pcie_cfg_cpl_status,
    input       [31:0]      pcie_cfg_rx_data
);

localparam IDLE  = 1'b0;
localparam SETUP = 1'b1;

reg                 state;
reg                 nextstate;
reg     [31:0]      reg0;
reg     [31:0]      reg1;
reg     [31:0]      reg2;
reg     [31:0]      reg3;
reg     [31:0]      reg4;

wire                reg0_wr;
wire                reg1_wr;
wire                reg2_wr;
wire                reg3_wr;


assign pcie_cfg_fmt     = reg0[0];
assign pcie_cfg_type    = reg0[1];
assign pcie_cfg_fbe     = reg0[5:2];
assign pcie_cfg_tag     = reg0[15:8];
assign tx_en            = reg0[24];
assign pcie_cfg_req_id  = reg1[15:0];
assign pcie_cfg_des_id  = reg1[31:16];
assign pcie_cfg_reg_num = reg2[9:0];
assign pcie_cfg_ctrl_en = reg2[24];
assign pcie_cfg_tx_data = reg3[31:0];


//-------------------------------APB FSM------------------------------------
//---------------PHASE 1-----------
always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        state <= IDLE;
    else
        state <= nextstate;

//---------------PHASE 2-----------
always@(*)
    case (state)
        IDLE:begin
            if(p_sel && !p_ce)
                nextstate = SETUP;
            else
                nextstate = IDLE;
            end
        SETUP:  nextstate = IDLE;
        default: nextstate =IDLE;
    endcase

//---------------PHASE 3-----------
// p_rdy
always@(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        p_rdy <= 1'b0;
    else if(state== IDLE && p_sel && !p_ce)
        p_rdy <= 1'b1;
    else
        p_rdy <= 1'b0;

//***************APB write*********************
assign reg0_wr = p_addr ==8'h0 && p_we && p_ce && p_rdy;
assign reg1_wr = p_addr ==8'h4 && p_we && p_ce && p_rdy;
assign reg2_wr = p_addr ==8'h8 && p_we && p_ce && p_rdy;
assign reg3_wr = p_addr ==8'hc && p_we && p_ce && p_rdy;

//***************reg0 write
always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg0[7:0] <= 8'h0;
    else if (reg0_wr & p_strb[0])
        reg0[5:0] <= p_wdata[5:0];

always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg0[15:8] <= 8'h0;
    else if (reg0_wr & p_strb[1])
        reg0[15:8] <= p_wdata[15:8];

//reg0[19:16] are W1C
always@(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg0[23:16] <= 8'h0;
    else if (reg0_wr & p_strb[2])
        reg0[19:16] <= reg0[19:16] & (~p_wdata[19:16]);
    else if (pcie_cfg_cpl_rcv)
        reg0[19:16] <= {pcie_cfg_cpl_status,1'b1};

always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg0[31:24] <= 8'h0;
    else if (reg0_wr & p_strb[3])
        reg0[24]    <= p_wdata[24];

//***************reg1 write
always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg1[7:0]  <= 8'h0;
    else if (reg1_wr & p_strb[0])
        reg1[7:0]  <= p_wdata[7:0];

always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg1[15:8] <= 8'h0;
    else if (reg1_wr & p_strb[1])
        reg1[15:8] <= p_wdata[15:8];

always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg1[23:16] <= 8'h0;
    else if (reg1_wr & p_strb[2])
        reg1[23:16] <= p_wdata[23:16];

always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg1[31:24] <= 8'h0;
    else if (reg1_wr & p_strb[3])
        reg1[31:24] <= p_wdata[31:24];

//***************reg2 write
always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg2[7:0]  <= 8'h0;
    else if (reg2_wr & p_strb[0])
        reg2[7:0]  <= p_wdata[7:0];

always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg2[15:8]  <= 8'h0;
    else if (reg2_wr & p_strb[1])
        reg2[9:8]   <= p_wdata[9:8];

always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg2[23:16] <= 8'h0;

always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg2[31:24] <= 8'h0;
    else if (reg2_wr & p_strb[3])
        reg2[24]    <= p_wdata[24];

//***************reg3 write
always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg3[7:0]  <= 8'h0;
    else if (reg3_wr & p_strb[0])
        reg3[7:0]  <= p_wdata[7:0];

always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg3[15:8] <= 8'h0;
    else if (reg3_wr & p_strb[1])
        reg3[15:8] <= p_wdata[15:8];

always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg3[23:16] <= 8'h0;
    else if (reg3_wr & p_strb[2])
        reg3[23:16] <= p_wdata[23:16];

always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg3[31:24] <= 8'h0;
    else if (reg3_wr & p_strb[3])
        reg3[31:24] <= p_wdata[31:24];

//***************reg4 write
always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg4[7:0]  <= 8'h0;
    else if (pcie_cfg_cpl_rcv)
        reg4[7:0] <= pcie_cfg_rx_data[7:0];

always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg4[15:8] <= 8'h0;
    else if (pcie_cfg_cpl_rcv)
        reg4[15:8] <= pcie_cfg_rx_data[15:8];

always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg4[23:16] <= 8'h0;
    else if (pcie_cfg_cpl_rcv)
        reg4[23:16] <= pcie_cfg_rx_data[23:16];

always @(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        reg4[31:24] <= 8'h0;
    else if (pcie_cfg_cpl_rcv)
        reg4[31:24] <= pcie_cfg_rx_data[31:24];


//***************APB read***************************************
always@(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        p_rdata <= 32'h0;
    else if (state == IDLE && p_sel && !p_ce && !p_we) begin
        case(p_addr)
            8'h0:       p_rdata <= reg0;
            8'h4:       p_rdata <= reg1;
            8'h8:       p_rdata <= reg2;
            8'hc:       p_rdata <= reg3;
            8'h10:      p_rdata <= reg4;
            default:    p_rdata <= 32'h0;
        endcase
    end
    else
        p_rdata <= 32'h0;

endmodule
