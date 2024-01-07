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
//
// Library:
// Filename:ipsl_pcie_dma_controller.v
//////////////////////////////////////////////////////////////////////////////
module ipsl_pcie_dma_controller #(
    parameter                           DEVICE_TYPE = 3'd0      ,   //3'd0:EP,3'd1:Legacy EP,3'd4:RC
    parameter                           ADDR_WIDTH  = 4'd9
)(
    input                               clk                     ,   //gen1:62.5MHz,gen2:125MHz
    input                               rst_n                   ,
    //**********************************************************************
    //bar1 wr interface
    input                               i_bar1_wr_en            ,
    input           [ADDR_WIDTH-1:0]    i_bar1_wr_addr          ,
    input           [127:0]             i_bar1_wr_data          ,
    input           [15:0]              i_bar1_wr_byte_en       ,
    //**********************************************************************
    //apb interface
    input                               i_apb_psel              ,
    input           [8:0]               i_apb_paddr             ,
    input           [31:0]              i_apb_pwdata            ,
    input           [3:0]               i_apb_pstrb             ,
    input                               i_apb_pwrite            ,
    input                               i_apb_penable           ,
    output  reg                         o_apb_prdy              ,
    output  reg     [31:0]              o_apb_prdata            ,
    //**********************************************************************
    output  reg                         o_user_define_data_flag ,

    //**********************************************************************
    //to tx
    output  reg                         o_mwr32_req             ,
    input                               i_mwr32_req_ack         ,
    output  reg                         o_mwr64_req             ,
    input                               i_mwr64_req_ack         ,

    output  reg                         o_mrd32_req             ,
    input                               i_mrd32_req_ack         ,
    output  reg                         o_mrd64_req             ,
    input                               i_mrd64_req_ack         ,
    output  reg     [9:0]               o_req_length            ,
    output  reg     [63:0]              o_req_addr              ,
    output  reg     [31:0]              o_req_data              ,

    input           [63:0]              i_dma_check_result      ,
    output  wire                        o_tx_restart            ,
    output  reg                         o_cross_4kb_boundary

);
//apb register for rc
reg     [31:0]      apb_cmd_reg;
reg     [31:0]      apb_cmd_length;
reg     [31:0]      apb_cmd_l_addr;
reg     [31:0]      apb_cmd_h_addr;
reg     [31:0]      apb_cmd_data;

reg     [31:0]      apb_pwdata;

reg                 apb_cmd_reg_vld;
reg                 apb_cmd_length_vld;
reg                 apb_cmd_l_addr_vld;
reg                 apb_cmd_h_addr_vld;
reg                 apb_cmd_data_vld;

reg                 apb_ctrl_cfg_done;
reg                 apb_length_cfg_done;
reg                 apb_l_addr_cfg_done;
reg                 apb_h_addr_cfg_done;
reg                 apb_data_cfg_done;

//mwr register for ep
reg     [31:0]      dma_cmd_reg;
reg     [31:0]      dma_cmd_l_addr;
reg     [31:0]      dma_cmd_h_addr;

reg     [31:0]      dma_wr_data;

reg                 dma_cmd_reg_vld;
reg                 dma_cmd_l_addr_vld;
reg                 dma_cmd_h_addr_vld;

reg                 dma_ctrl_cfg_done;
reg                 dma_l_addr_cfg_done;
reg                 dma_h_addr_cfg_done;

wire                user_define_data_flag;
wire                dma_32_64_addr_cmd_flag;
wire                dma_wr_rd_cmd_flag;

wire                ack_rcv;

wire                device_rc;
wire                device_ep;

wire                apb_write;
wire                apb_read;

wire                cmd_reg_cfg_done;
wire                l_addr_cfg_done;
wire                h_addr_cfg_done;

wire                mwr32_req_vld;
wire                mwr64_req_vld;
wire                mrd32_req_vld;
wire                mrd64_req_vld;

//4KB boundary
wire    [12:0]      req_l_addr;
wire    [12:0]      total_data;
wire    [12:0]      target_addr;
wire                cross_4kb_boundary;
//dma check
wire                dma_check_success;

assign device_rc = (DEVICE_TYPE == 3'b100 ) ? 1'b1 : 1'b0;
assign device_ep = (DEVICE_TYPE == 3'b000 || DEVICE_TYPE == 3'b001) ? 1'b1 : 1'b0;

//req_ack
assign ack_rcv = i_mwr32_req_ack | i_mwr64_req_ack | i_mrd32_req_ack | i_mrd64_req_ack;

//********************************************************************dma controller register*********************************************************************
//dma_wr_data
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dma_wr_data <= 32'b0;
    else
        dma_wr_data <= i_bar1_wr_data[31:0];
end

//dma_cmd_reg_vld
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dma_cmd_reg_vld <= 1'b0;
    else if(dma_cmd_reg_vld)
        dma_cmd_reg_vld <= 1'b0;
    else
        dma_cmd_reg_vld <= &i_bar1_wr_byte_en && i_bar1_wr_en && (i_bar1_wr_addr[8:0] == 9'h100);
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dma_cmd_reg <= 32'd0;
    else if(dma_cmd_reg_vld)
        dma_cmd_reg <= dma_wr_data;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dma_ctrl_cfg_done <= 1'b0;
    else if (ack_rcv || cross_4kb_boundary)
        dma_ctrl_cfg_done <= 1'b0;
    else if(dma_cmd_reg_vld)
        dma_ctrl_cfg_done <= 1'b1;
end

//dma_cmd_l_addr
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dma_cmd_l_addr_vld <= 1'b0;
    else if(dma_cmd_l_addr_vld)
        dma_cmd_l_addr_vld <= 1'b0;
    else
        dma_cmd_l_addr_vld <= &i_bar1_wr_byte_en && i_bar1_wr_en && (i_bar1_wr_addr[8:0] == 9'h110);
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dma_cmd_l_addr <= 32'd0;
    else if(dma_cmd_l_addr_vld)
        dma_cmd_l_addr <= dma_wr_data;
end

//l_addr_cfg_done
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dma_l_addr_cfg_done <= 1'b0;
    else if (ack_rcv || cross_4kb_boundary)
        dma_l_addr_cfg_done <= 1'b0;
    else if(dma_cmd_l_addr_vld)
        dma_l_addr_cfg_done <= 1'b1;
end

//dma_cmd_h_addr
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dma_cmd_h_addr_vld <= 1'b0;
    else if(dma_cmd_l_addr_vld)
        dma_cmd_h_addr_vld <= 1'b0;
    else
        dma_cmd_h_addr_vld <= &i_bar1_wr_byte_en && i_bar1_wr_en && (i_bar1_wr_addr[8:0] == 9'h120);
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dma_cmd_h_addr <= 32'd0;
    else if(dma_cmd_h_addr_vld)
        dma_cmd_h_addr <= dma_wr_data;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dma_h_addr_cfg_done <= 1'b0;
    else if (ack_rcv || cross_4kb_boundary)
        dma_h_addr_cfg_done <= 1'b0;
    else if(dma_cmd_h_addr_vld)
        dma_h_addr_cfg_done <= 1'b1;
end

//********************************************************************apb controller register*********************************************************************
assign apb_write = i_apb_psel && i_apb_penable && i_apb_pwrite;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        apb_pwdata <= 32'b0;
    else
        apb_pwdata <= i_apb_pwdata;
end
//apb_cmd_reg for rc
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        apb_cmd_reg_vld <= 1'b0;
    else if(apb_cmd_reg_vld)
        apb_cmd_reg_vld <= 1'b0;
    else
        apb_cmd_reg_vld <= &i_apb_pstrb && apb_write && (i_apb_paddr == 9'h140);
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        apb_cmd_reg <= 32'd0;
    else if(apb_cmd_reg_vld)
        apb_cmd_reg <= apb_pwdata;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        apb_ctrl_cfg_done <= 1'b0;
    else if (ack_rcv || cross_4kb_boundary)
        apb_ctrl_cfg_done <= 1'b0;
    else if(apb_cmd_reg_vld)
        apb_ctrl_cfg_done <= 1'b1;
end

//apb_cmd_length
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        apb_cmd_length_vld <= 1'b0;
    else if(apb_cmd_length_vld)
        apb_cmd_length_vld <= 1'b0;
    else
        apb_cmd_length_vld <= &i_apb_pstrb && apb_write && (i_apb_paddr == 9'h150);
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        apb_cmd_length <= 32'd0;
    else if(apb_cmd_length_vld)
        apb_cmd_length <= apb_pwdata;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        apb_length_cfg_done <= 1'b0;
    else if (ack_rcv || cross_4kb_boundary)
        apb_length_cfg_done <= 1'b0;
    else if(apb_cmd_length_vld)
        apb_length_cfg_done <= 1'b1;
end

//apb_cmd_l_addr
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        apb_cmd_l_addr_vld <= 1'b0;
    else if(apb_cmd_l_addr_vld)
        apb_cmd_l_addr_vld <= 1'b0;
    else
        apb_cmd_l_addr_vld <= &i_apb_pstrb && apb_write && (i_apb_paddr == 9'h160);
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        apb_cmd_l_addr <= 32'd0;
    else if(apb_cmd_l_addr_vld)
        apb_cmd_l_addr <= apb_pwdata;
end

//apb_l_addr_cfg_done
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        apb_l_addr_cfg_done <= 1'b0;
    else if (ack_rcv || cross_4kb_boundary)
        apb_l_addr_cfg_done <= 1'b0;
    else if(apb_cmd_l_addr_vld)
        apb_l_addr_cfg_done <= 1'b1;
end

//apb_cmd_h_addr
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        apb_cmd_h_addr_vld <= 1'b0;
    else if(apb_cmd_h_addr_vld)
        apb_cmd_h_addr_vld <= 1'b0;
    else
        apb_cmd_h_addr_vld <= &i_apb_pstrb && apb_write && (i_apb_paddr == 9'h170);
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        apb_cmd_h_addr <= 32'd0;
    else if(apb_cmd_h_addr_vld)
        apb_cmd_h_addr <= apb_pwdata;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        apb_h_addr_cfg_done <= 1'b0;
    else if (ack_rcv || cross_4kb_boundary)
        apb_h_addr_cfg_done <= 1'b0;
    else if(apb_cmd_h_addr_vld)
        apb_h_addr_cfg_done <= 1'b1;
end

//apb_cmd_data
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        apb_cmd_data_vld <= 1'b0;
    else if(apb_cmd_data_vld)
        apb_cmd_data_vld <= 1'b0;
    else
        apb_cmd_data_vld <= &i_apb_pstrb && apb_write && (i_apb_paddr == 9'h180);
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        apb_cmd_data <= 32'd0;
    else if(apb_cmd_data_vld)
        apb_cmd_data <= apb_pwdata;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        apb_data_cfg_done <= 1'b0;
    else if (ack_rcv || cross_4kb_boundary)
        apb_data_cfg_done <= 1'b0;
    else if(apb_cmd_data_vld)
        apb_data_cfg_done <= 1'b1;
end

assign cmd_reg_cfg_done = (device_ep && dma_ctrl_cfg_done)   || (device_rc && apb_ctrl_cfg_done);

assign l_addr_cfg_done  = (device_ep && dma_l_addr_cfg_done) || (device_rc && apb_l_addr_cfg_done);

assign h_addr_cfg_done  = (device_ep && dma_h_addr_cfg_done) || (device_rc && apb_h_addr_cfg_done);
//********************************************************************req information*********************************************************************
//o_req_length
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_req_length <= 10'd0;
    else if(cmd_reg_cfg_done)
    begin
        if(device_ep)
            o_req_length <= dma_cmd_reg[9:0] + 10'h1;
        else if(device_rc && apb_length_cfg_done)
            o_req_length <= apb_cmd_length[9:0] + 10'h1;
    end
end

//o_req_addr
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_req_addr[31:0] <= 32'd0;
    else if(l_addr_cfg_done)
        if(device_ep)
            o_req_addr[31:0] <= dma_cmd_l_addr;
        else if(device_rc)
            o_req_addr[31:0] <= apb_cmd_l_addr;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_req_addr[63:32] <= 32'd0;
    else if(h_addr_cfg_done)
        if(device_ep)
            o_req_addr[63:32] <= dma_cmd_h_addr;
        else if(device_rc)
            o_req_addr[63:32] <= apb_cmd_h_addr;
end

//o_req_data
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_req_data <= 32'd0;
    else if(apb_data_cfg_done)
        o_req_data[31:0]  <= apb_cmd_data;
end

//******************************************************************tx request*************************************************************************
assign user_define_data_flag     = device_rc ? apb_cmd_reg[8]  : 1'b0;  //0:use ram data; 1:use user define data
assign dma_32_64_addr_cmd_flag   = device_rc ? apb_cmd_reg[16] : (device_ep ? dma_cmd_reg[16] : 1'b0);  //0:32; 1:64;
assign dma_wr_rd_cmd_flag        = device_rc ? apb_cmd_reg[24] : (device_ep ? dma_cmd_reg[24] : 1'b0);  //0:read; 1:write;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_user_define_data_flag <= 1'd0;
    else
        o_user_define_data_flag <= user_define_data_flag;
end

//gen req valid
assign mwr32_req_vld = !dma_32_64_addr_cmd_flag &&  dma_wr_rd_cmd_flag && cmd_reg_cfg_done && l_addr_cfg_done && !cross_4kb_boundary;
assign mwr64_req_vld =  dma_32_64_addr_cmd_flag &&  dma_wr_rd_cmd_flag && cmd_reg_cfg_done && l_addr_cfg_done && h_addr_cfg_done && !cross_4kb_boundary;
assign mrd32_req_vld = !dma_32_64_addr_cmd_flag && !dma_wr_rd_cmd_flag && cmd_reg_cfg_done && l_addr_cfg_done && !cross_4kb_boundary;
assign mrd64_req_vld =  dma_32_64_addr_cmd_flag && !dma_wr_rd_cmd_flag && cmd_reg_cfg_done && l_addr_cfg_done && h_addr_cfg_done && !cross_4kb_boundary;

//mwr_32_req
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_mwr32_req <= 1'b0;
    else if(i_mwr32_req_ack)
        o_mwr32_req <= 1'b0;
    else if(mwr32_req_vld)
    begin
        if(!user_define_data_flag)
            o_mwr32_req  <= 1'b1;
        else if(apb_data_cfg_done)
            o_mwr32_req  <= 1'b1;
        else
            o_mwr32_req  <= 1'b0;
    end
end

//mwr_64_req
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_mwr64_req <= 1'b0;
    else if(i_mwr64_req_ack)
        o_mwr64_req <= 1'b0;
    else if(mwr64_req_vld)
    begin
        if(!user_define_data_flag)
            o_mwr64_req  <= 1'b1;
        else if(apb_data_cfg_done)
            o_mwr64_req  <= 1'b1;
        else
            o_mwr64_req  <= 1'b0;
    end
end
//mrd_32_req
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_mrd32_req <= 1'b0;
    else if(i_mrd32_req_ack)
        o_mrd32_req <= 1'b0;
    else if(mrd32_req_vld)
        o_mrd32_req  <= 1'b1;
end

//mrd_64_req
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_mrd64_req <= 1'b0;
    else if(i_mrd64_req_ack)
        o_mrd64_req <= 1'b0;
    else if(mrd64_req_vld)
        o_mrd64_req  <= 1'b1;
end

//**********************************************************************apb_read***************************************************************************
assign apb_read  = i_apb_psel && i_apb_penable && ~i_apb_pwrite ;

assign dma_check_success = ~(|i_dma_check_result);

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_apb_prdata <= 32'd0;
    else if(apb_read)
        case(i_apb_paddr)
            9'h100: o_apb_prdata <= dma_cmd_reg;
            9'h110: o_apb_prdata <= dma_cmd_l_addr;
            9'h120: o_apb_prdata <= dma_cmd_h_addr;
            9'h140: o_apb_prdata <= apb_cmd_reg;
            9'h150: o_apb_prdata <= {22'b0,apb_cmd_length};
            9'h160: o_apb_prdata <= apb_cmd_l_addr;
            9'h170: o_apb_prdata <= apb_cmd_h_addr;
            9'h180: o_apb_prdata <= apb_cmd_data;
            9'h190: o_apb_prdata <= i_dma_check_result[31:0];
            9'h1A0: o_apb_prdata <= i_dma_check_result[63:32];
            9'h1B0: o_apb_prdata <= {31'b0,dma_check_success};
            default: o_apb_prdata <= 32'd0;
        endcase
end
//apb_rdy
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_apb_prdy <= 1'b0;
    else if(i_apb_psel && i_apb_penable && !o_apb_prdy)
        o_apb_prdy <= 1'b1;
    else
        o_apb_prdy <= 1'b0;
end

assign o_tx_restart = i_bar1_wr_en && (i_bar1_wr_addr[8:0] == 9'h110);

//detect 4-KB boundary
assign req_l_addr = device_rc ? apb_cmd_l_addr[12:0] : dma_cmd_l_addr[12:0];

assign total_data   = ~((device_rc && apb_length_cfg_done) || (device_ep && dma_ctrl_cfg_done)) ? 13'd0 :
                        (o_req_length[9:0] == 10'b0) ? 13'h1000 : {1'b0,o_req_length[9:0],2'b0}; //total byte data

assign target_addr  = ~l_addr_cfg_done ? 13'd0 : (req_l_addr[12:0] + total_data);

assign cross_4kb_boundary = ~l_addr_cfg_done ? 1'b0 :
                            (target_addr[12] == req_l_addr[12]) ? 1'b0 : |target_addr[11:0];

//4-KB boundary flag
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_cross_4kb_boundary <= 1'b0;
    else if(cross_4kb_boundary)
        o_cross_4kb_boundary <= 1'b1;
    else if(cmd_reg_cfg_done)
        o_cross_4kb_boundary <= 1'b0;
end

endmodule
