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
module ipsl_pcie_cfg_trans(
    //from pcie_cfg_core_apb
    input                   pclk_div2,
    input                   apb_rst_n,
    input                   pcie_cfg_fmt,
    input                   pcie_cfg_type,
    input       [7:0]       pcie_cfg_tag,
    input       [3:0]       pcie_cfg_fbe,
//    input       [15:0]      pcie_cfg_req_id,
    input       [15:0]      pcie_cfg_des_id,
    input       [9:0]       pcie_cfg_reg_num,
    input       [31:0]      pcie_cfg_tx_data,
    input                   tx_en,
    output  reg             pcie_cfg_cpl_rcv,
    output  reg [2:0]       pcie_cfg_cpl_status,
    output  reg [31:0]      pcie_cfg_rx_data,
    //to pcie_core
    input                   axis_slave_tready,
    output  reg             axis_slave_tvalid,
    output  reg             axis_slave_tlast,
    output                  axis_slave_tuser,
    output  reg    [127:0]  axis_slave_tdata,

    output                  axis_master_tready,
    input                   axis_master_tvalid,
    input                   axis_master_tlast,
//    input       [7:0]       axis_master_tuser,
    input       [3:0]       axis_master_tkeep,
    input       [127:0]     axis_master_tdata,
    output      [2:0]       trgt1_radm_pkt_halt
//    input       [5:0]       radm_grant_tlp_type
);

wire    [4:0]       type_code;               //
reg                 tx_en_r;
reg                 tx_en_2r;
wire                tx_start;

reg                 tx_data_en;
reg                 tx_wait_en;
reg                 rx_data_en;
//-----------------------------------------------------CFG TLP TX --------------------------------------------
//tx_start indicator
always@(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n) begin
        tx_en_r  <= 1'b0;
        tx_en_2r <= 1'b0;
    end
    else begin
        tx_en_r  <= tx_en;
        tx_en_2r <= tx_en_r;
    end
assign tx_start = tx_en_r && !tx_en_2r;

//--------------------------------------------axis_slave-

assign axis_slave_tuser = 1'b0;   // not used in bringup test
assign type_code        = pcie_cfg_type ? 5'b00101 : 5'b00100; //type1:00101 type0:00100
always@(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n)
        axis_slave_tvalid <= 1'b0;
    else if (tx_start)
        axis_slave_tvalid <= 1'b1;
    else if (axis_slave_tlast)
        axis_slave_tvalid <= 1'b0;

always@(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n) begin
        axis_slave_tlast <= 1'b0;
        axis_slave_tdata <= 128'h0;
        tx_wait_en       <= 1'b0;
        tx_data_en       <= 1'b0;
    end
    else if (tx_start|tx_wait_en) begin
        if(axis_slave_tready) begin
            case(pcie_cfg_fmt)
                1'b0:begin                          //cfg rd fmt=000
                        axis_slave_tlast <= 1'b1;
                        axis_slave_tdata <= {32'h0,
                                             pcie_cfg_des_id,4'h0,pcie_cfg_reg_num,2'h0,    //Des ID,RSVD,REG_NUM,RSVD
                                             16'h0,pcie_cfg_tag,4'h0,pcie_cfg_fbe,          //REQ ID determined bt CTRL,TAG,LBE,FBE
                                             3'h0,type_code,8'h0,8'h0,8'h1};                     //FMT,TYPE,TC,ATTR,TH,TD,EP,AT,LENGTH
                        tx_wait_en       <=  1'b0;
                end
                1'b1:begin                          //cfg_wr fmt=010
                        axis_slave_tlast <= 1'b0;
                        axis_slave_tdata <= {32'h0,
                                             pcie_cfg_des_id,4'h0,pcie_cfg_reg_num,2'h0,    //Des ID,RSVD,REG_NUM,RSVD
                                             16'h0,pcie_cfg_tag,4'h0,pcie_cfg_fbe,          //REQ ID determined bt CTRL,TAG,LBE,FBE
                                             3'h2,type_code,8'h0,8'h0,8'h1};                     //FMT,TYPE,TC,ATTR,TH,TD,EP,AT,LENGTH
                        tx_wait_en      <=  1'b0;
                        tx_data_en      <=  1'b1;
                end
            endcase
        end
        else begin
            tx_wait_en  <= 1'b1;
        end
    end
    else if(tx_data_en) begin
        axis_slave_tlast <= 1'b1;
        axis_slave_tdata <= endian_convert({96'h0,pcie_cfg_tx_data});
        tx_data_en       <= 1'b0;
    end
    else begin
        axis_slave_tlast<= 1'b0;
    end
//--------------------------------------------------------CFG CPL ------
wire    [127:0]     pcie_rx_data;
assign  pcie_rx_data = endian_convert(axis_master_tdata);


assign trgt1_radm_pkt_halt  = 3'b000;        //APP not halt the RX channel
assign axis_master_tready   = 1'b1;
always@(posedge pclk_div2 or negedge apb_rst_n)
    if(!apb_rst_n) begin
        pcie_cfg_cpl_rcv    <= 1'b0;
        pcie_cfg_cpl_status <= 3'b0;
        pcie_cfg_rx_data    <= 32'h0;
        rx_data_en          <= 1'b0;
    end
    else if(axis_master_tvalid && axis_master_tready
            && axis_master_tdata[28:24]== 5'b01010                   //cpl type
            && axis_master_tdata[79:72]== pcie_cfg_tag
            && !rx_data_en)begin         //tag is for cfg req tag
        case(axis_master_tdata[31:29])
            3'b000:begin                                            //CPL without DATA
                pcie_cfg_cpl_rcv    <= 1'b1;
                pcie_cfg_cpl_status <= axis_master_tdata[47:45];     //cpl status field
                pcie_cfg_rx_data    <= 32'h0;
            end
            3'b010:begin                                            //CPL with DATA
                pcie_cfg_cpl_rcv    <= 1'b0;
                pcie_cfg_cpl_status <= axis_master_tdata[47:45];     //CPL status field
                rx_data_en          <= 1'b1;
            end
            default:begin
                pcie_cfg_cpl_rcv    <= 1'b0;
                pcie_cfg_cpl_status <= 3'b0;
                rx_data_en          <= 1'b0;
            end
        endcase
    end
    else if(rx_data_en && axis_master_tlast && axis_master_tvalid && axis_master_tready) begin
        pcie_cfg_cpl_rcv         <= 1'b1;
        pcie_cfg_rx_data         <= {32{axis_master_tkeep[0]}} & axis_master_tdata[31:0];
        rx_data_en               <= 1'b0;
    end
    else begin
        pcie_cfg_cpl_rcv <= 1'b0;
    end
//convert from little endian into big endian
function [127:0] endian_convert;
   input [127:0] data_in;
   begin
   endian_convert[32*0+31:32*0+0] = {data_in[32*0+7:32*0+0], data_in[32*0+15:32*0+8], data_in[32*0+23:32*0+16], data_in[32*0+31:32*0+24]};
   endian_convert[32*1+31:32*1+0] = {data_in[32*1+7:32*1+0], data_in[32*1+15:32*1+8], data_in[32*1+23:32*1+16], data_in[32*1+31:32*1+24]};
   endian_convert[32*2+31:32*2+0] = {data_in[32*2+7:32*2+0], data_in[32*2+15:32*2+8], data_in[32*2+23:32*2+16], data_in[32*2+31:32*2+24]};
   endian_convert[32*3+31:32*3+0] = {data_in[32*3+7:32*3+0], data_in[32*3+15:32*3+8], data_in[32*3+23:32*3+16], data_in[32*3+31:32*3+24]};
   end
endfunction

endmodule




