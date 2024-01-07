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
module ipsl_pcie_cfg_ctrl(
//from APB
    input                   pclk_div2,
    input                   apb_rst_n,
    input                   p_sel,
    input       [3:0]       p_strb,
    input       [7:0]       p_addr,
    input       [31:0]      p_wdata,
    input                   p_ce,
    input                   p_we,
    output                  p_rdy,
    output      [31:0]      p_rdata,
    output                  pcie_cfg_ctrl_en,
//to PCIE ctrl
    input                   axis_slave_tready,
    output                  axis_slave_tvalid,
    output                  axis_slave_tlast,
    output                  axis_slave_tuser,
    output      [127:0]     axis_slave_tdata,

    output                  axis_master_tready,
    input                   axis_master_tvalid,
    input                   axis_master_tlast,
//    input       [7:0]       axis_master_tuser,
    input       [3:0]       axis_master_tkeep,
    input       [127:0]     axis_master_tdata,
    output      [2:0]       trgt1_radm_pkt_halt
    //input       [5:0]       radm_grant_tlp_type
);

wire                  pcie_cfg_fmt;
wire                  pcie_cfg_type;
wire      [7:0]       pcie_cfg_tag;
wire      [3:0]       pcie_cfg_fbe;
wire      [15:0]      pcie_cfg_req_id;
wire      [15:0]      pcie_cfg_des_id;
wire      [9:0]       pcie_cfg_reg_num;
wire      [31:0]      pcie_cfg_tx_data;
wire                  tx_en;
wire                  pcie_cfg_cpl_rcv;
wire      [2:0]       pcie_cfg_cpl_status;
wire      [31:0]      pcie_cfg_rx_data;

ipsl_pcie_cfg_ctrl_apb u_pcie_cfg_ctrl_apb(
//apb interface
.pclk_div2                  (pclk_div2          ),
.apb_rst_n                  (apb_rst_n          ),
.p_sel                      (p_sel              ),
.p_strb                     (p_strb             ),
.p_addr                     (p_addr             ),
.p_wdata                    (p_wdata            ),
.p_ce                       (p_ce               ),
.p_we                       (p_we               ),
.p_rdy                      (p_rdy              ),
.p_rdata                    (p_rdata            ),
.pcie_cfg_ctrl_en           (pcie_cfg_ctrl_en   ),
//cfg ctrl
.pcie_cfg_fmt               (pcie_cfg_fmt       ),
.pcie_cfg_type              (pcie_cfg_type      ),
.pcie_cfg_tag               (pcie_cfg_tag       ),
.pcie_cfg_fbe               (pcie_cfg_fbe       ),
.pcie_cfg_req_id            (pcie_cfg_req_id    ),
.pcie_cfg_des_id            (pcie_cfg_des_id    ),
.pcie_cfg_reg_num           (pcie_cfg_reg_num   ),
.pcie_cfg_tx_data           (pcie_cfg_tx_data   ),
.tx_en                      (tx_en              ),
.pcie_cfg_cpl_rcv           (pcie_cfg_cpl_rcv   ),
.pcie_cfg_cpl_status        (pcie_cfg_cpl_status),
.pcie_cfg_rx_data           (pcie_cfg_rx_data   )
);

ipsl_pcie_cfg_trans u_pcie_cfg_trans(
.pclk_div2                  (pclk_div2          ),
.apb_rst_n                  (apb_rst_n          ),
//cfg trans
.pcie_cfg_fmt               (pcie_cfg_fmt       ),
.pcie_cfg_type              (pcie_cfg_type      ),
.pcie_cfg_tag               (pcie_cfg_tag       ),
.pcie_cfg_fbe               (pcie_cfg_fbe       ),
//.pcie_cfg_req_id            (pcie_cfg_req_id    ),
.pcie_cfg_des_id            (pcie_cfg_des_id    ),
.pcie_cfg_reg_num           (pcie_cfg_reg_num   ),
.pcie_cfg_tx_data           (pcie_cfg_tx_data   ),
.tx_en                      (tx_en              ),
.pcie_cfg_cpl_rcv           (pcie_cfg_cpl_rcv   ),
.pcie_cfg_cpl_status        (pcie_cfg_cpl_status),
.pcie_cfg_rx_data           (pcie_cfg_rx_data   ),
//pcie core
.axis_slave_tready           (axis_slave_tready  ),
.axis_slave_tvalid           (axis_slave_tvalid  ),
.axis_slave_tlast            (axis_slave_tlast   ),
.axis_slave_tuser            (axis_slave_tuser   ),
.axis_slave_tdata            (axis_slave_tdata   ),
.axis_master_tready          (axis_master_tready ),
.axis_master_tvalid          (axis_master_tvalid ),
.axis_master_tlast           (axis_master_tlast  ),
//.axis_master_tuser           (axis_master_tuser  ),
.axis_master_tkeep           (axis_master_tkeep  ),
.axis_master_tdata           (axis_master_tdata  ),
.trgt1_radm_pkt_halt         (trgt1_radm_pkt_halt)
//.radm_grant_tlp_type         (radm_grant_tlp_type)
);
endmodule
