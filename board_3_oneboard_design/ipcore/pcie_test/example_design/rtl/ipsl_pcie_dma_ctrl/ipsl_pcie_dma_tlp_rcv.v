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
// Filename:ipsl_pcie_dma_tlp_rcv.v
//////////////////////////////////////////////////////////////////////////////
module ipsl_pcie_dma_tlp_rcv#(
    parameter                   DEVICE_TYPE = 3'd0          //3'd0:EP,3'd1:Legacy EP,3'd4:RC
)(
    input                       clk                     ,   //gen1:62.5MHz,gen2:125MHz
    input                       rst_n                   ,

    //**********************************************************************
    //AXIS master interface
    input                       i_axis_master_tvld      ,
    output  wire                o_axis_master_trdy      ,
    input           [127:0]     i_axis_master_tdata     ,
    input           [3:0]       i_axis_master_tkeep     ,
    input                       i_axis_master_tlast     ,
    input           [7:0]       i_axis_master_tuser     ,
    output  reg     [2:0]       o_trgt1_radm_pkt_halt   ,
//    input           [5:0]       i_radm_grant_tlp_type   ,

    //**********************************************************************
    //to mwr write control
    output  reg                 o_mwr_wr_start          ,
    output  wire    [9:0]       o_mwr_length            ,
    output  reg     [7:0]       o_mwr_dwbe              ,
    output  reg     [127:0]     o_mwr_data              ,
    output  reg     [3:0]       o_mwr_dw_vld            ,
    output  reg     [63:0]      o_mwr_addr              ,
    //to cpld write control
    output  reg                 o_cpld_wr_start         ,
    output  wire    [9:0]       o_cpld_length           ,
    output  reg     [6:0]       o_cpld_low_addr         ,
    output  reg     [11:0]      o_cpld_byte_cnt         ,
    output  reg     [127:0]     o_cpld_data             ,
    output  reg     [3:0]       o_cpld_dw_vld           ,
    output  reg     [7:0]       o_cpld_tag              ,
    output  reg                 o_multicpld_flag        ,
    //write bar hit
    output  reg     [1:0]       o_bar_hit               ,
    /////////////////////
    //2'b0:bar0 hit
    //2'b1:bar1 hit
    //2'b2:bar2 hit
    //2'b3:reserved
    /////////////////////

    //**********************************************************************
    //to tx top
    //req rcv
    output  reg     [2:0]       o_mrd_tc                ,
    output  reg     [2:0]       o_mrd_attr              ,
    output  wire    [9:0]       o_mrd_length            ,
    output  reg     [15:0]      o_mrd_id                ,
    output  reg     [7:0]       o_mrd_tag               ,
    output  reg     [63:0]      o_mrd_addr              ,

    output  reg                 o_cpld_req_vld          ,
    input                       i_cpld_req_rdy          ,
    input                       i_cpld_tx_rdy           ,
    //cpld rcv
    output  reg                 o_cpld_rcv              ,
    //output  wire    [7:0]       o_cpld_tag,
    input                       i_tag_full              ,
    //**********************************************************************
    //rst tlp cnt
    output  reg     [63:0]      o_dma_check_result      ,
    input                       i_tx_restart
    //form DMA controller
    //output  wire    [42:0]      o_dbg_bus               ,
    //output  wire    [69:0]      o_dbg_tlp_rcv_cnt
);

localparam IDLE      = 2'd0;
localparam HEAD_RCV  = 2'd1;
localparam DATA_RCV  = 2'd2;

localparam MRD_32    = 8'h0;
localparam MRD_64    = 8'h20;
localparam MRDLK_32  = 8'h01;
localparam MRDLK_64  = 8'h21;
localparam MWR_32    = 8'h40;
localparam MWR_64    = 8'h60;
localparam CPLD      = 8'h4A;
localparam CPLDLK    = 8'h4B;

//fsm
reg  [1:0]      state;
reg  [1:0]      next_state;

//
reg             eop;
wire [2:0]      tlp_fmt;
wire [4:0]      tlp_type;
reg  [9:0]      tlp_length;

wire            mrd32_rcv;
wire            mrd64_rcv;
wire            mrd_rcv;

wire            mwr32_rcv;
wire            mwr64_rcv;
wire            mwr_rcv;
reg             mwr_data_valid;

wire            cpld_rcv;
reg             cpld_data_valid;

reg             with_data;

wire [127:0]    axis_rx_data;

reg  [11:0]     dma_check_cnt;
reg  [5:0]      data_cnt;

reg             axis_master_tvld;
reg             axis_master_tvld_ff;
reg  [127:0]    axis_master_tdata;
reg  [127:0]    axis_master_tdata_ff;
reg  [3:0]      axis_master_tkeep;
reg  [3:0]      axis_master_tkeep_ff;
reg             axis_master_tlast;
reg             axis_master_tlast_ff;
reg  [7:0]      axis_master_tuser;
reg  [7:0]      axis_master_tuser_ff;
//reg  [5:0]      radm_grant_tlp_type;
//reg  [5:0]      radm_grant_tlp_type_ff;

//axis reg_in
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        axis_master_tvld    <= 1'b0;
        axis_master_tdata   <= 128'b0;
        axis_master_tkeep   <= 4'b0;
        axis_master_tlast   <= 1'b0;
        axis_master_tuser   <= 8'b0;
        //radm_grant_tlp_type <= 6'b0;
    end
    else
    begin
        axis_master_tvld    <= i_axis_master_tvld;
        axis_master_tdata   <= i_axis_master_tdata;
        axis_master_tkeep   <= i_axis_master_tkeep;
        axis_master_tlast   <= i_axis_master_tlast;
        axis_master_tuser   <= i_axis_master_tuser;
        //radm_grant_tlp_type <= i_radm_grant_tlp_type;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        axis_master_tvld_ff    <= 1'b0;
        axis_master_tdata_ff   <= 128'b0;
        axis_master_tkeep_ff   <= 4'b0;
        axis_master_tlast_ff   <= 1'b0;
        axis_master_tuser_ff   <= 8'b0;
        //radm_grant_tlp_type_ff <= 6'b0;
    end
    else
    begin
        axis_master_tvld_ff    <= axis_master_tvld;
        axis_master_tdata_ff   <= axis_master_tdata;
        axis_master_tkeep_ff   <= axis_master_tkeep;
        axis_master_tlast_ff   <= axis_master_tlast;
        axis_master_tuser_ff   <= axis_master_tuser;
        //radm_grant_tlp_type_ff <= radm_grant_tlp_type;
    end
end

assign o_axis_master_trdy = 1'b1;
//fmt,type
assign tlp_fmt    = axis_master_tdata_ff[31:29];
assign tlp_type   = axis_master_tdata_ff[28:24];

//recive mrd
assign mrd32_rcv = ({tlp_fmt,tlp_type} == MRD_32 || {tlp_fmt,tlp_type} == MRDLK_32) && state == HEAD_RCV;
assign mrd64_rcv = ({tlp_fmt,tlp_type} == MRD_64 || {tlp_fmt,tlp_type} == MRDLK_64) && state == HEAD_RCV;
assign mrd_rcv   = mrd32_rcv || mrd64_rcv;
//recive mwr
assign mwr32_rcv = ({tlp_fmt,tlp_type} == MWR_32) && state == HEAD_RCV;
assign mwr64_rcv = ({tlp_fmt,tlp_type} == MWR_64) && state == HEAD_RCV;
assign mwr_rcv   = mwr32_rcv || mwr64_rcv;
//recive cpld
assign cpld_rcv = ({tlp_fmt,tlp_type} == CPLD || {tlp_fmt,tlp_type} == CPLDLK) && state == HEAD_RCV;

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        mwr_data_valid <= 1'b0;
    else if(axis_master_tlast_ff)
        mwr_data_valid <= 1'b0;
    else if(axis_master_tvld_ff && o_axis_master_trdy && state == HEAD_RCV)
        mwr_data_valid <= mwr_rcv;
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        cpld_data_valid <= 1'b0;
    else if(axis_master_tlast_ff)
        cpld_data_valid <= 1'b0;
    else if(axis_master_tvld_ff && o_axis_master_trdy && state == HEAD_RCV)
        cpld_data_valid <= cpld_rcv;
end

//tlp with payload
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        with_data <= 1'b0;
    else if(axis_master_tdata[30] && axis_master_tvld && o_axis_master_trdy)
        with_data <= 1'b1;
    else
        with_data <= 1'b0;
end

//eop
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        eop <= 1'b0;
    else if(axis_master_tlast && axis_master_tvld && o_axis_master_trdy)
        eop <= 1'b1;
    else
        eop <= 1'b0;
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        state <= IDLE;
    else
        state <= next_state;
end

always @(*)
begin
    case(state)
        IDLE:
        begin
            if(axis_master_tvld && o_axis_master_trdy) //start transfer
                next_state = HEAD_RCV;
            else
                next_state = IDLE;
        end
        HEAD_RCV:
        begin
            if(with_data)
                next_state = DATA_RCV;
            else if(~with_data && ~(o_axis_master_trdy && axis_master_tvld)) //without data
                next_state = IDLE;
            else
                next_state = state;
        end
        DATA_RCV:
        begin
            if(eop && o_axis_master_trdy && axis_master_tvld)//back to back transmit
                next_state = HEAD_RCV;
            else if(eop && ~(o_axis_master_trdy && axis_master_tvld))//transmit end
                next_state = IDLE;
            else
                next_state = state;
        end
        default:
        begin
            next_state = IDLE;
        end
    endcase
end


always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        //comon header
        tlp_length          <=  10'b0;
        //mrd
        o_mrd_tc            <=  3'b0;
        o_mrd_attr          <=  3'b0;
        o_mrd_id            <=  16'b0;
        o_mrd_tag           <=  8'b0;
        o_mrd_addr          <=  64'b0;
        //mwr
        o_mwr_wr_start      <=  1'b0;
        o_mwr_dwbe          <=  8'b0;
        o_mwr_data          <=  128'b0;
        o_mwr_dw_vld        <=  4'b0;
        o_mwr_addr          <=  64'b0;
        //cpld
        o_cpld_wr_start     <=  1'b0;
        o_cpld_low_addr     <=  7'b0;
        o_cpld_byte_cnt     <=  12'b0;
        o_cpld_data         <=  128'b0;
        o_cpld_dw_vld       <=  4'b0;
        o_cpld_tag          <=  8'b0;
        o_bar_hit           <=  2'b0;
        o_multicpld_flag    <=  1'b0;
    end
    else
    begin
        case(state)
            IDLE:
            begin
                tlp_length          <=  10'b0;
                //mrd
                o_mrd_tc            <=  3'b0;
                o_mrd_attr          <=  3'b0;
                o_mrd_id            <=  16'b0;
                o_mrd_tag           <=  8'b0;
                o_mrd_addr          <=  64'b0;
                //mwr
                o_mwr_wr_start      <=  1'b0;
                o_mwr_dwbe          <=  8'b0;
                o_mwr_data          <=  128'b0;
                o_mwr_dw_vld        <=  4'b0;
                o_mwr_addr          <=  64'b0;
                //cpld
                o_cpld_wr_start     <=  1'b0;
                o_cpld_low_addr     <=  7'b0;
                o_cpld_byte_cnt     <=  12'b0;
                o_cpld_data         <=  128'b0;
                o_cpld_dw_vld       <=  4'b0;
                o_cpld_tag          <=  8'b0;
                o_bar_hit           <=  2'b0;
                o_multicpld_flag    <=  1'b0;
            end
            HEAD_RCV:
            begin
                //length
                tlp_length          <=  axis_master_tdata_ff[9:0];

                if(mrd_rcv)
                begin
                    o_mrd_tc        <=  axis_master_tdata_ff[22:20];
                    o_mrd_attr      <=  {axis_master_tdata_ff[18],axis_master_tdata_ff[13:12]};
                    o_mrd_id        <=  axis_master_tdata_ff[63:48];
                    o_mrd_tag       <=  axis_master_tdata_ff[47:40];
                    //address
                    if (mrd32_rcv)
                        o_mrd_addr      <=  {32'b0,axis_master_tdata_ff[95:66],2'b0};
                    else if(mrd64_rcv)
                        o_mrd_addr      <=  {axis_master_tdata_ff[95:64],axis_master_tdata_ff[127:98],2'b0};

                end
                else if (mwr_rcv)
                begin
                    o_mwr_wr_start      <=  1'b0;
                    o_mwr_dwbe          <=  axis_master_tdata_ff[39:32];
                    //address
                    if (mwr32_rcv)
                        o_mwr_addr      <=  {32'b0,axis_master_tdata_ff[95:66],2'b0};
                    else if(mwr64_rcv)
                        o_mwr_addr      <=  {axis_master_tdata_ff[95:64],axis_master_tdata_ff[127:98],2'b0};
                end
                else if (cpld_rcv)
                begin
                    o_cpld_wr_start     <=  1'b0;
                    o_cpld_byte_cnt     <=  axis_master_tdata_ff[41:32];
                    o_cpld_low_addr     <=  axis_master_tdata_ff[70:64];
                    o_cpld_tag          <=  axis_master_tdata_ff[79:72];
                    o_multicpld_flag    <=  ~axis_master_tuser_ff[3];
                end
            end
            DATA_RCV:
            begin
                o_bar_hit           <=  axis_master_tuser_ff[5:4];
                if(mwr_data_valid)
                begin
                    o_mwr_wr_start  <=  1'b1;
                    o_mwr_data      <=  axis_rx_data;
                    o_mwr_dw_vld    <=  axis_master_tkeep_ff;
                end
                else if(cpld_data_valid)
                begin
                    o_cpld_wr_start <=  1'b1;
                    o_cpld_data     <=  axis_rx_data;
                    o_cpld_dw_vld   <=  axis_master_tkeep_ff;
                end
            end
            default:
            begin
                tlp_length          <=  10'b0;
                //mrd
                o_mrd_tc            <=  3'b0;
                o_mrd_attr          <=  3'b0;
                o_mrd_id            <=  16'b0;
                o_mrd_tag           <=  8'b0;
                o_mrd_addr          <=  64'b0;
                //mwr
                o_mwr_wr_start      <=  1'b0;
                o_mwr_dwbe          <=  8'b0;
                o_mwr_data          <=  128'b0;
                o_mwr_dw_vld        <=  4'b0;
                o_mwr_addr          <=  64'b0;
                //cpld
                o_cpld_wr_start     <=  1'b0;
                o_cpld_low_addr     <=  7'b0;
                o_cpld_byte_cnt     <=  12'b0;
                o_cpld_data         <=  128'b0;
                o_cpld_dw_vld       <=  4'b0;
                o_cpld_tag          <=  8'b0;
                o_bar_hit           <=  2'b0;
                o_multicpld_flag    <=  1'b0;
            end
        endcase
    end
end

assign o_mwr_length  = tlp_length;
assign o_mrd_length  = tlp_length;
assign o_cpld_length = tlp_length;

//rcv mrd:cpld req
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_cpld_req_vld <= 1'b0;
    else if((state == HEAD_RCV) && mrd_rcv)
        o_cpld_req_vld <= 1'b1;
    else if(i_cpld_req_rdy)
        o_cpld_req_vld <= 1'b0;
end

//rcv cpld:release cpld tag
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_cpld_rcv <= 1'b0;
    else if((state == HEAD_RCV) && cpld_rcv && axis_master_tuser_ff[3]) //for multicpld,i_axis_master_tuser[3]:Indicates the last completion TLP
        o_cpld_rcv <= 1'b1;
    else
        o_cpld_rcv <= 1'b0;
end

//o_trgt1_radm_pkt_halt[0]:Halt posted TLPs for VC0,MWR
//o_trgt1_radm_pkt_halt[1]:Halt non-posted TLPs for VC0,MRD
//o_trgt1_radm_pkt_halt[2]:Halt CPL TLPs for VC0,CPLD
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_trgt1_radm_pkt_halt <= 3'b0;
    else
        o_trgt1_radm_pkt_halt <= {1'b0,~i_cpld_tx_rdy,i_tag_full};
end

//******************************************************************debug logic*************************************************************************
//check for 128byte only
reg     [2:0]   tlp_data_cnt;
reg     [13:0]  tlp_rx_check_pass_cnt;
reg     [13:0]  tlp_rx_check_error_cnt;
reg     [13:0]  tlp_rx_sum;
reg     [13:0]  multcpld_cnt;
wire            tlp_rx_vld;
reg             check_error_flag;
//rcv tlp cnt
reg     [13:0]  mwr_rcv_cnt;
reg     [13:0]  mrd_rcv_cnt;
reg     [13:0]  cpld_rcv_cnt;
//wire    [41:0]  o_dbg_tlp_rcv_cnt;

assign tlp_rx_vld = axis_master_tvld_ff && o_axis_master_trdy;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tlp_data_cnt <= 3'b0;
    else if(axis_master_tlast_ff)
        tlp_data_cnt <= 3'b0;
    else if(cpld_data_valid && tlp_rx_vld)
        tlp_data_cnt <= tlp_data_cnt + 3'b1;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tlp_rx_sum <= 14'b0;
    else if(i_tx_restart)
        tlp_rx_sum <= 14'b0;
    else if(axis_master_tlast_ff  && tlp_rx_vld)
        tlp_rx_sum <= tlp_rx_sum + 14'b1;
end

//rcv tlp cnt

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        mwr_rcv_cnt <= 14'b0;
    else if(i_tx_restart)
        mwr_rcv_cnt <= 14'b0;
    else if(mwr_rcv)
        mwr_rcv_cnt <= mwr_rcv_cnt + 14'b1;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        mrd_rcv_cnt <= 14'b0;
    else if(i_tx_restart)
        mrd_rcv_cnt <= 14'b0;
    else if(mrd_rcv)
        mrd_rcv_cnt <= mrd_rcv_cnt + 14'b1;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cpld_rcv_cnt <= 14'b0;
    else if(i_tx_restart)
        cpld_rcv_cnt <= 14'b0;
    else if(cpld_rcv)
        cpld_rcv_cnt <= cpld_rcv_cnt + 14'b1;
end

//assign o_dbg_tlp_rcv_cnt = {
//                            mwr_rcv_cnt,            //41:28
//                            mrd_rcv_cnt,            //27:14
//                            cpld_rcv_cnt            //13:0
//                            };

//check multicpld,i_axis_master_tuser[3]

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        multcpld_cnt <= 14'b0;
    else if(i_tx_restart)
        multcpld_cnt <= 14'b0;
    else if(cpld_data_valid && axis_master_tlast_ff && ~axis_master_tuser_ff[3])
        multcpld_cnt <= multcpld_cnt + 14'b1;
end

//******************************************************************check logic*************************************************************************
//DMA check
//note:
//1.mrd addr must equal to mwr addr
//2.addr must 4dw aligned
//3.only for DMA test
//otherwise the check logic will not work properly
generate
    if (DEVICE_TYPE == 3'd4)
    begin
        always@(posedge clk or negedge rst_n)
        begin
            if(!rst_n)
                dma_check_cnt <= 12'b0;
            else if(mwr_rcv)
                dma_check_cnt <=  {axis_master_tdata_ff[79:68]};
            else if(mwr_data_valid)
                dma_check_cnt <= dma_check_cnt + 12'b1;
        end

        always@(posedge clk or negedge rst_n)
        begin
            if(!rst_n)
                data_cnt <= 6'b0;
            else if(mrd_rcv)
                data_cnt <=  6'd0;
            else if(mwr_data_valid)
                data_cnt <= data_cnt + 6'b1;
        end

        always@(posedge clk or negedge rst_n)
        begin
            if(!rst_n)
                o_dma_check_result <= 64'b0;
            else if(mrd_rcv)
                o_dma_check_result <= 64'b0;
            else if(mwr_data_valid)
                o_dma_check_result[data_cnt] <= ~(dma_check_cnt == axis_rx_data[11:0]);
        end
    end
    else
    begin
        always@(*)
        begin
            o_dma_check_result = 64'b0;
        end
    end
endgenerate
assign axis_rx_data = endian_convert(axis_master_tdata_ff);
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