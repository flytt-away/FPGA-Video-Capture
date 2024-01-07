//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2020 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
module ipsl_pcie_cfg_init_v1_3 #(
    parameter DEVICE_TYPE                       = 3'b000        , // EP-> 3'b000; RC->3'b100;

    parameter MAX_LINK_WIDTH                    = 6'b00_0100    ,  // x4
    parameter MAX_LINK_SPEED                    = 4'b0010       ,  // gen2
    parameter LINK_CAPABLE                      = 6'b00_0111    ,  // 4-lanes
    parameter SCRAMBLE_DISABLE                  = 1'b0          ,
    parameter AUTO_LANE_FLIP_CTRL_EN            = 1'b1          ,
    parameter NUM_OF_LANES                      = 5'b0_0001     ,
    parameter MAX_PAYLOAD_SIZE                  = 3'b011        ,  // 1024-bytes
    parameter INT_DISABLE                       = 1'b0          ,
    parameter PVM_SUPPORT                       = 1'b1          ,
    parameter MSI_64_BIT_ADDR_CAP               = 1'b1          ,
    parameter MSI_MULTIPLE_MSG_CAP              = 3'b101        ,
    parameter MSI_ENABLE                        = 1'b0          ,
    parameter MSI_CAP_NEXT_OFFSET               = 8'h70         ,
    parameter CAP_POINTER                       = 8'h50         ,
    parameter PCIE_CAP_NEXT_PTR                 = 8'hB0         ,
    parameter VENDOR_ID                         = 16'h0755      ,
    parameter DEVICE_ID                         = 16'h0755      ,
    parameter BASE_CLASS_CODE                   = 8'h05         ,
    parameter SUBCLASS_CODE                     = 8'h80         ,
    parameter PROGRAM_INTERFACE                 = 8'h00         ,
    parameter REVISION_ID                       = 8'h00         ,
    parameter SUBSYS_DEV_ID                     = 16'h0000      ,
    parameter SUBSYS_VENDOR_ID                  = 16'h0000      ,
    parameter BAR0_PREFETCH                     = 1'b0          ,
    parameter BAR0_TYPE                         = 2'b0          ,
    parameter BAR0_MEM_IO                       = 1'b0          ,
    parameter BAR0_ENABLED                      = 1'b1          ,
    parameter BAR0_MASK                         = 31'h0000_0fff ,
    parameter BAR1_PREFETCH                     = 1'b0          ,
    parameter BAR1_TYPE                         = 2'b0          ,
    parameter BAR1_MEM_IO                       = 1'b0          ,
    parameter BAR1_ENABLED                      = 1'b1          ,
    parameter BAR1_MASK                         = 31'h0000_07ff ,
    parameter BAR2_PREFETCH                     = 1'b0          ,
    parameter BAR2_TYPE                         = 2'b10         ,
    parameter BAR2_MEM_IO                       = 1'b0          ,
    parameter BAR2_ENABLED                      = 1'b1          ,
    parameter BAR2_MASK                         = 31'h0000_0fff ,
    parameter BAR3_PREFETCH                     = 1'b0          ,
    parameter BAR3_TYPE                         = 2'b0          ,
    parameter BAR3_MEM_IO                       = 1'b0          ,
    parameter BAR3_ENABLED                      = 1'b0          ,
    parameter BAR3_MASK                         = 31'd0         ,
    parameter BAR4_PREFETCH                     = 1'b0          ,
    parameter BAR4_TYPE                         = 2'b0          ,
    parameter BAR4_MEM_IO                       = 1'b0          ,
    parameter BAR4_ENABLED                      = 1'b0          ,
    parameter BAR4_MASK                         = 31'd0         ,
    parameter BAR5_PREFETCH                     = 1'b0          ,
    parameter BAR5_TYPE                         = 2'b0          ,
    parameter BAR5_MEM_IO                       = 1'b0          ,
    parameter BAR5_ENABLED                      = 1'b0          ,
    parameter BAR5_MASK                         = 31'd0         ,
    parameter ROM_BAR_ENABLE                    = 1'b0          ,
    parameter ROM_BAR_ENABLED                   = 1'd0          ,
    parameter ROM_MASK                          = 31'd0         ,
    parameter DO_DESKEW_FOR_SRIS                = 1'b1          ,
    parameter PCIE_CAP_HW_AUTO_SPEED_DISABLE    = 1'b0          ,
    parameter TARGET_LINK_SPEED                 = 4'h1          ,

    parameter ECRC_CHECK_EN                     = 1'b1          ,
    parameter ECRC_GEN_EN                       = 1'b1          ,
    parameter EXT_TAG_EN                        = 1'b1          ,
    parameter EXT_TAG_SUPP                      = 1'b1          ,
    parameter PCIE_CAP_RCB                      = 1'b1          ,
    parameter PCIE_CAP_CRS                      = 1'b0          ,
    parameter PCIE_CAP_ATOMIC_EN                = 1'b0          ,

    //msix
    parameter PCI_MSIX_ENABLE                   = 1'b0          ,
    parameter PCI_FUNCTION_MASK                 = 1'b0          ,
    parameter PCI_MSIX_TABLE_SIZE               = 11'h0         ,
    parameter PCI_MSIX_CPA_NEXT_OFFSET          = 8'h0          ,
    parameter PCI_MSIX_TABLE_OFFSET             = 29'h0         ,
    parameter PCI_MSIX_BIR                      = 3'h0          ,
    parameter PCI_MSIX_PBA_OFFSET               = 29'h0         ,
    parameter PCI_MSIX_PBA_BIR                  = 3'h0          ,
    parameter AER_CAP_NEXT_OFFSET               = 12'h0         ,

    //TPH
    parameter TPH_REQ_NEXT_PTR                  = 12'h0         ,

    //Resizable BAR
    parameter RESBAR_BAR0_MAX_SUPP_SIZE         = 20'hf_ffff    ,
    parameter RESBAR_BAR0_INIT_SIZE             = 5'h13         ,
    parameter RESBAR_BAR1_MAX_SUPP_SIZE         = 20'hf_ffff    ,
    parameter RESBAR_BAR1_INIT_SIZE             = 5'h13         ,
    parameter RESBAR_BAR2_MAX_SUPP_SIZE         = 20'hf_ffff    ,
    parameter RESBAR_BAR2_INIT_SIZE             = 5'hb          ,

    //MULTI_LANE_CONTROL_OFF
    parameter UPCONFIGURE_SUPPORT               = 1'b1
)(
    input                       clk                 ,
    input                       rst_n               ,
    input                       start               ,
    input                       dbi_ack             ,
    output reg                  dbi_cs              ,
    output reg                  dbi_cs2             ,
    output reg  [31:0]          dbi_addr            ,
    output reg  [31:0]          dbi_din             ,
    output reg  [3:0]           dbi_wr              ,
    output reg                  dbi_ro_wr_disable   ,
    output reg                  init_finish
);

// ROM Define
localparam ROM_CNT = 10'd46;

wire [47:0] init_rom [ROM_CNT-1:0] /* synthesis syn_romstyle = "select_rom" */;
wire dbi_standby;

reg [9:0] rom_raddr;
//================================================
//  init parameter
//================================================
//------------------------------------------------
//  rom width = 48-bits
//  |--> [47:44] = 4-bits = dbi_wr
//  |--> [43:32] = 12-bits = dbi_addr
//  |--> [31:0] = 32-bits = dbi_data
//------------------------------------------------
//
//----------------------
// B=0x70, offset=B+0xc, = 0x7c
//----------------------
// max_link_width @[9:4]
// max_link_speed @[3:0]
localparam [47:0] INI_0 = {4'b0011, 12'h07c, 16'd0, 4'hf, 2'b10, MAX_LINK_WIDTH, MAX_LINK_SPEED};
//----------------------
// offset=0x710
//----------------------
// link_capable     @[21:16]
// scramble_disable @[1]
localparam [47:0] INI_1 = {4'b0101, 12'h710, 10'h00, LINK_CAPABLE, 8'h0, 6'b0010_00, SCRAMBLE_DISABLE, 1'b0};
//----------------------
// offset=0x80c
//----------------------
// auto_lane_flip_ctrl_en @[16]
// num_of_lanes  @[12:8]
localparam [47:0] INI_2 = {4'b0110, 12'h80c, 15'h01, AUTO_LANE_FLIP_CTRL_EN, 3'h0, NUM_OF_LANES, 8'h00};
//----------------------
// B=0x70, offset=B+0x24, = 0x94
//----------------------
// cpl_timeout_disable_support @[4]
// cpl_timeout_range @[3:0]
localparam [47:0] INI_3 = 48'd0;//{4'b0001, 12'h094, 24'd0, 3'b100, CPL_TIMEOUT_DISABLE_SUPPORT, CPL_TIMEOUT_RANGE};
//----------------------
// B=0x70, offset=B+0x4, = 0x74
//----------------------
// EXT_TAG_SUPP @[5]
// max_payload_size[2:0]
localparam [47:0] INI_4 = {4'b0001, 12'h074, 26'b0, EXT_TAG_SUPP, 2'b0, MAX_PAYLOAD_SIZE};
//----------------------
// B=0x00, offset=B+0x4, = 0x4
//----------------------
// INT_DISABLE[10]
localparam [47:0] INI_5 = {4'b0010, 12'h004, 16'd0, 5'd0, INT_DISABLE, 10'd0};
//----------------------
// B=0x50, offset=B+0x0, = 0x50
//----------------------
// pvm_support @[24]
// msi_64_bit_addr_cap @[23]
// msi_multiple_msg_cap @[19:17]
// msi_enable @[16]
// msi_cap_next_offset @[15:8]
localparam [47:0] INI_6 = {4'b1110, 12'h050, 7'd0, PVM_SUPPORT, MSI_64_BIT_ADDR_CAP, 3'd0, MSI_MULTIPLE_MSG_CAP, MSI_ENABLE, MSI_CAP_NEXT_OFFSET, 8'd0};
//----------------------
// B=0x00, offset=B+0x34, = 0x34
//----------------------
// cap_pointer @[7:0]
localparam [47:0] INI_7 = {4'b0001, 12'h034, 24'd0, CAP_POINTER};
//----------------------
// B=0x70, offset=B+0x0, = 0x70
//----------------------
// pcie_cap_next_ptr @[15:8]
localparam [47:0] INI_8 = {4'b0010, 12'h070, 16'd0, PCIE_CAP_NEXT_PTR, 8'd0};
//----------------------
// B=0x00, offset=B+0x0, = 0x00
//----------------------
// vendor_id [15:0]
// device_id [31:16]
localparam [47:0] INI_9 = {4'b1111, 12'h000, DEVICE_ID, VENDOR_ID};
//----------------------
// B=0x00, offset=B+0x8, = 0x8
//----------------------
// base_class_code  @[31:24]
// subclass_code    @[23:16]
// program_interface@[15:8]
// revision_id      @[7:0]
localparam [47:0] INI_10 = {4'b1111, 12'h008, BASE_CLASS_CODE, SUBCLASS_CODE, PROGRAM_INTERFACE, REVISION_ID};
//----------------------
// B=0x00, offset=B+0x2c, = 0x2c
//----------------------
// subsys_dev_id    @[31:16]
// subsys_vendor_id @[15:0]
localparam [47:0] INI_11 = (DEVICE_TYPE==3'b100) ? 48'd0 : {4'b1111, 12'h02c, SUBSYS_DEV_ID, SUBSYS_VENDOR_ID};
//----------------------
// B=0x00, offset=B+0x11, = 0x11
//----------------------
// bar0_enabled @[0]
// bar0_mask    @[31:1]
localparam [47:0] INI_12 = {4'b1111, 12'h011, BAR0_MASK, BAR0_ENABLED};
//----------------------
// B=0x00, offset=B+0x10, = 0x10
//----------------------
// bar0_prefetch @[3]
// bar0_type     @[2:1]
// bar0_mem_io   @[0]
localparam [47:0] INI_13 = {4'b0001, 12'h010, 28'd0, BAR0_PREFETCH, BAR0_TYPE, BAR0_MEM_IO};
//----------------------
// B=0x00, offset=B+0x11, = 0x11
//----------------------
// bar1_enabled @[0]
// bar1_mask    @[31:1]
localparam [47:0] INI_14 = {4'b1111, 12'h015, BAR1_MASK, BAR1_ENABLED};
//----------------------
// B=0x00, offset=B+0x10, = 0x10
//----------------------
// bar1_prefetch @[3]
// bar1_type     @[2:1]
// bar1_mem_io   @[0]
localparam [47:0] INI_15 = {4'b0001, 12'h014, 28'd0, BAR1_PREFETCH, BAR1_TYPE, BAR1_MEM_IO};

//----------------------
// B=0x00, offset=B+0x11, = 0x11
//----------------------
// BAR2_enabled @[0]
// BAR2_mask    @[31:1]
localparam [47:0] INI_16 = (DEVICE_TYPE==3'b100) ? 48'd0 : {4'b1111, 12'h019, BAR2_MASK, BAR2_ENABLED};
//----------------------
// B=0x00, offset=B+0x10, = 0x10
//----------------------
// BAR2_prefetch @[3]
// BAR2_type     @[2:1]
// BAR2_mem_io   @[0]
localparam [47:0] INI_17 = (DEVICE_TYPE==3'b100) ? 48'd0 : {4'b0001, 12'h018, 28'd0, BAR2_PREFETCH, BAR2_TYPE, BAR2_MEM_IO};
//----------------------
// B=0x00, offset=B+0x11, = 0x11
//----------------------
// BAR3_enabled @[0]
// BAR3_mask    @[31:1]
localparam [47:0] INI_18 = (DEVICE_TYPE==3'b100) ? 48'd0 : {4'b1111, 12'h01d, BAR3_MASK, BAR3_ENABLED};
//----------------------
// B=0x00, offset=B+0x10, = 0x10
//----------------------
// BAR3_prefetch @[3]
// BAR3_type     @[2:1]
// BAR3_mem_io   @[0]
localparam [47:0] INI_19 = (DEVICE_TYPE==3'b100) ? 48'd0 : {4'b0001, 12'h01c, 28'd0, BAR3_PREFETCH, BAR3_TYPE, BAR3_MEM_IO};
//----------------------
// B=0x00, offset=B+0x11, = 0x11
//----------------------
// BAR4_enabled @[0]
// BAR4_mask    @[31:1]
localparam [47:0] INI_20 = (DEVICE_TYPE==3'b100) ? 48'd0 : {4'b1111, 12'h021, BAR4_MASK, BAR4_ENABLED};
//----------------------
// B=0x00, offset=B+0x10, = 0x10
//----------------------
// BAR4_prefetch @[3]
// BAR4_type     @[2:1]
// BAR4_mem_io   @[0]
localparam [47:0] INI_21 = (DEVICE_TYPE==3'b100) ? 48'd0 : {4'b0001, 12'h020, 28'd0, BAR4_PREFETCH, BAR4_TYPE, BAR4_MEM_IO};
//----------------------
// B=0x00, offset=B+0x11, = 0x11
//----------------------
// BAR5_enabled @[0]
// BAR5_mask    @[31:1]
localparam [47:0] INI_22 = (DEVICE_TYPE==3'b100) ? 48'd0 : {4'b1111, 12'h025, BAR5_MASK, BAR5_ENABLED};
//----------------------
// B=0x00, offset=B+0x10, = 0x10
//----------------------
// BAR5_prefetch @[3]
// BAR5_type     @[2:1]
// BAR5_mem_io   @[0]
localparam [47:0] INI_23 = (DEVICE_TYPE==3'b100) ? 48'd0 : {4'b0001, 12'h024, 28'd0, BAR5_PREFETCH, BAR5_TYPE, BAR5_MEM_IO};
//----------------------
// B=0x00,
// ep-> offset=B+0x30, = 0x30
// rc-> offset=B+0x38, = 0x38
//----------------------
// rom_bar_enable @[0]
localparam [47:0] INI_24 = (DEVICE_TYPE==3'b100) ? {4'b0001, 12'h038, 31'd0, ROM_BAR_ENABLE} : {4'b0001, 12'h030, 31'd0, ROM_BAR_ENABLE};
//----------------------
// B=0x00,
// ep-> offset=B+0x31, = 0x31
// rc-> offset=B+0x39, = 0x39
//----------------------
// rom_bar_enabled  @[0]
// rom_mask         @[31:1]
localparam [47:0] INI_25 = (DEVICE_TYPE==3'b100) ? {4'b1111, 12'h039, ROM_MASK, ROM_BAR_ENABLED} : {4'b1111, 12'h031, ROM_MASK, ROM_BAR_ENABLED};

//----------------------
// offset 0x708
//----------------------
// DO_DESKEW_FOR_SRIS @[23]
localparam [47:0] INI_26 = {4'b0100, 12'h708, 8'd0, DO_DESKEW_FOR_SRIS, 23'd0};

//----------------------
// offset 0xa0
//----------------------
//PCIE_CAP_HW_AUTO_SPEED_DISABLE @[5]
// TARGET_LINK_SPEED @[3:0]
localparam [47:0] INI_27 = {4'b0001, 12'h0a0, 26'd0, PCIE_CAP_HW_AUTO_SPEED_DISABLE, 1'b0, TARGET_LINK_SPEED};

//----------------------
// offset 0xB+0x18
//----------------------
// ECRC_CHECK_EN    @[8]
// ECRC_GEN_EN      @[6]
localparam [47:0] INI_28 = {4'b0011, 12'h118, 16'd0, 7'd0, ECRC_CHECK_EN, 1'd1, ECRC_GEN_EN, 1'd1, 5'd0};

//----------------------
// offset 0xB(70)+0x8
//----------------------
// EXT_TAG_EN @[8]
localparam [47:0] INI_29 = {4'b0010, 12'h078, 8'h0, 4'h1, 4'h0, 4'h2, 3'h0, EXT_TAG_EN, 4'h1, 4'h0};

//----------------------
// offset 0xB(70)+0x10
//----------------------
localparam [47:0] INI_30 = (DEVICE_TYPE==3'b100) ? {4'b0001, 12'h080, 28'h0, PCIE_CAP_RCB , 3'h0} : {4'b0001, 12'h080, 28'h0, 1'b1 , 3'h0};

//----------------------
// offset 0xB(70)+0x1c
//----------------------
//rc
localparam [47:0] INI_31 = (DEVICE_TYPE==3'b100) ? {4'b0001, 12'h08c, 28'h0, PCIE_CAP_CRS, 3'h0} : {32'd0};

//----------------------
// offset 0xB(70)+0x28
//----------------------
// PCIE_CAP_ATOMIC_EN[6]
localparam [47:0] INI_32 = {4'b0001, 12'h098, 24'h0, 1'b0, PCIE_CAP_ATOMIC_EN, 2'b0 , 4'h0};

//----------------------
// offset 0xB(b0)+0x00
//----------------------
//PCI_MSIX_ENABLE           [31]
//PCI_FUNCTION_MASK         [30]
//PCI_MSIX_TABLE_SIZE       [26:16]
//PCI_MSIX_CPA_NEXT_OFFSET  [15:8]
localparam [47:0] INI_33 = {4'b1110, 12'h0b0, PCI_MSIX_ENABLE, PCI_FUNCTION_MASK, 3'h0, PCI_MSIX_TABLE_SIZE, PCI_MSIX_CPA_NEXT_OFFSET, 8'h0};

//----------------------
// offset 0xB(b0)+0x04
//----------------------
//PCI_MSIX_TABLE_OFFSET     [31:3]
//PCI_MSIX_BIR              [2:0]
localparam [47:0] INI_34 = {4'b1111, 12'h0b4, PCI_MSIX_TABLE_OFFSET, PCI_MSIX_BIR};

//----------------------
// offset 0xB(b0)+0x08
//----------------------
// PCI_MSIX_PBA_OFFSET      [31:3]
// PCI_MSIX_PBA_BIR         [2:0]
localparam [47:0] INI_35 = {4'b1111, 12'h0b8, PCI_MSIX_PBA_OFFSET, PCI_MSIX_PBA_BIR};

//----------------------
// offset 0x(100)+0x00
//----------------------
// AER_CAP_NEXT_OFFSET [31:20]
localparam [47:0] INI_36 = {4'b1100, 12'h100, AER_CAP_NEXT_OFFSET, 4'h2, 16'h0};

//----------------------
// offset 0x(158)+0x00
//----------------------
// TPH_REQ_NEXT_PTR [31:20]
localparam [47:0] INI_37 = {4'b1100, 12'h158, TPH_REQ_NEXT_PTR, 4'h1, 16'h0};

//----------------------
// offset 0x8c0
//----------------------
// UPCONFIGURE_SUPPORT [7]
localparam [47:0] INI_38 = {4'b0001, 12'h8c0, 24'h0, UPCONFIGURE_SUPPORT, 7'h0};

//----------------------
// offset 0x(2E4)+0x04
//----------------------
// RESBAR_BAR0_MAX_SUPP_SIZE [23:4]
localparam [47:0] INI_39 = {4'b0111, 12'h2E8, 8'h0,RESBAR_BAR0_MAX_SUPP_SIZE, 4'h0};

//----------------------
// offset 0x(2E4)+0x08
//----------------------
// RESBAR_BAR0_INIT_SIZE [12:8]
localparam [47:0] INI_40 = {4'b0010, 12'h2EC, 19'h0,RESBAR_BAR0_INIT_SIZE, 8'h0};

//----------------------
// offset 0x(2E4)+0x0C
//----------------------
// RESBAR_BAR1_MAX_SUPP_SIZE [23:4]
localparam [47:0] INI_41 = {4'b0111, 12'h2F0, 8'h0,RESBAR_BAR1_MAX_SUPP_SIZE, 4'h0};

//----------------------
// offset 0x(2E4)+0x10
//----------------------
// RESBAR_BAR1_INIT_SIZE [12:8]
localparam [47:0] INI_42 = {4'b0010, 12'h2F4, 19'h0,RESBAR_BAR1_INIT_SIZE, 8'h0};

//----------------------
// offset 0x(2E4)+0x14
//----------------------
// RESBAR_BAR2_MAX_SUPP_SIZE [23:4]
localparam [47:0] INI_43 = {4'b0111, 12'h2F8, 8'h0,RESBAR_BAR2_MAX_SUPP_SIZE, 4'h0};

//----------------------
// offset 0x(2E4)+0x18
//----------------------
// RESBAR_BAR2_INIT_SIZE [12:8]
localparam [47:0] INI_44 = {4'b0010, 12'h2FC, 19'h0,RESBAR_BAR2_INIT_SIZE, 8'h0};

// ROM Initial
assign init_rom[0]  = INI_0;
assign init_rom[1]  = INI_1;
assign init_rom[2]  = INI_2;
assign init_rom[3]  = INI_3;
assign init_rom[4]  = INI_4;
assign init_rom[5]  = INI_5;
assign init_rom[6]  = INI_6;
assign init_rom[7]  = INI_7;
assign init_rom[8]  = INI_8;
assign init_rom[9]  = INI_9;
assign init_rom[10] = INI_10;
assign init_rom[11] = INI_11;
assign init_rom[12] = INI_12;
assign init_rom[13] = INI_13;
assign init_rom[14] = INI_14;
assign init_rom[15] = INI_15;
assign init_rom[16] = INI_16;
assign init_rom[17] = INI_17;
assign init_rom[18] = INI_18;
assign init_rom[19] = INI_19;
assign init_rom[20] = INI_20;
assign init_rom[21] = INI_21;
assign init_rom[22] = INI_22;
assign init_rom[23] = INI_23;
assign init_rom[24] = INI_24;
assign init_rom[25] = INI_25;
assign init_rom[26] = INI_26;
assign init_rom[27] = INI_27;
assign init_rom[28] = INI_28;
assign init_rom[29] = INI_29;
assign init_rom[30] = INI_30;
assign init_rom[31] = INI_31;
assign init_rom[32] = INI_32;
assign init_rom[33] = INI_33;
assign init_rom[34] = INI_34;
assign init_rom[35] = INI_35;
assign init_rom[36] = INI_36;
assign init_rom[37] = INI_37;
assign init_rom[38] = INI_38;
assign init_rom[39] = INI_39;
assign init_rom[40] = INI_40;
assign init_rom[41] = INI_41;
assign init_rom[42] = INI_42;
assign init_rom[43] = INI_43;
assign init_rom[44] = INI_44;
assign init_rom[45] = 48'b0;

assign dbi_standby = !(dbi_cs || dbi_ack);

reg cnt_done;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cnt_done <= 1'd0;
    else if (rom_raddr==(ROM_CNT-1) && dbi_ack && !dbi_cs)
    //else if (rom_raddr==(ROM_CNT) && dbi_ack && !dbi_cs)
        cnt_done <= 1'd1;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        init_finish <= 1'b0;
    else
        init_finish <= cnt_done;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        dbi_ro_wr_disable <= 1'b1;
    else if (cnt_done)
        dbi_ro_wr_disable <= 1'b1;
    else if (start && dbi_standby && !cnt_done)
        dbi_ro_wr_disable <= 1'b0;
end

// Read Rom Adderess
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        rom_raddr <= 10'd0;
    else if (rom_raddr == ROM_CNT-10'd1)
        rom_raddr <= rom_raddr;
    else if (dbi_ack && dbi_cs)
        rom_raddr <= rom_raddr + 10'd1;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dbi_cs <= 1'b0;
        dbi_din  <= 32'd0;
        dbi_addr <= 32'd0;
        dbi_wr <= 4'd0;
        dbi_cs2 <= 1'd0;
    end
    else if (dbi_ack) begin
        dbi_cs <= 1'b0;
        dbi_cs2 <= 1'd0;
        dbi_wr <= 4'd0;
    end
    else if (start && dbi_standby && !cnt_done) begin
        dbi_cs <= 1'b1;
        dbi_din  <= init_rom[rom_raddr][31:0];
        dbi_addr <= {20'd0, init_rom[rom_raddr][43:32]};
        dbi_wr <= init_rom[rom_raddr][47:44];

        if (init_rom[rom_raddr][32]==1'b1)
            dbi_cs2 <= 1'b1;
        else
            dbi_cs2 <= 1'b0;
    end
end

// debug logic

`ifdef IPSL_PCIE_SPEEDUP_SIM
reg [47:44] test_wr   ;
reg [43:32] test_addr ;
reg [31:0]  test_data ;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        test_wr   <= 'd0;
        test_addr <= 'd0;
        test_data <= 'd0;
    end
    else begin
        test_wr   <= init_rom[rom_raddr][47:44];
        test_addr <= init_rom[rom_raddr][43:32];
        test_data <= init_rom[rom_raddr][31:0];
    end
end
`else
`endif

endmodule
