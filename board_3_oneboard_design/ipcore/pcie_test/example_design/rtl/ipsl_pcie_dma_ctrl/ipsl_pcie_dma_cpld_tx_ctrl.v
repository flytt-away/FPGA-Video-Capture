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
// Filename:ipsl_pcie_dma_cpld_tx_ctrl.v
//////////////////////////////////////////////////////////////////////////////
module ipsl_pcie_dma_cpld_tx_ctrl (
    input                               clk                     ,   //gen1:62.5MHz,gen2:125MHz
    input                               rst_n                   ,
    input           [7:0]               i_cfg_pbus_num          ,
    input           [4:0]               i_cfg_pbus_dev_num      ,
    input           [2:0]               i_cfg_max_payload_size  ,
    //**********************************************************************
    //from rx
    input           [2:0]               i_mrd_tc                ,
    input           [2:0]               i_mrd_attr              ,
    input           [9:0]               i_mrd_length            ,
    input           [15:0]              i_mrd_id                ,
    input           [7:0]               i_mrd_tag               ,
    input           [63:0]              i_mrd_addr              ,

    input                               i_cpld_req_vld          ,
    output  wire                        o_cpld_req_rdy          ,
    output  wire                        o_cpld_tx_rdy           ,
    //**********************************************************************
    //ram interface
    output  reg                         o_rd_en                 ,
    output  wire    [9:0]               o_rd_length             ,
    output  wire    [63:0]              o_rd_addr               ,
    output  wire                        o_cpld_tx_hold          ,
    output  wire                        o_cpld_tlp_tx           ,
    input                               i_gen_tlp_start         ,
    input           [127:0]             i_rd_data               ,
    input                               i_last_data             ,
    //axis_slave interface
    input                               i_axis_slave0_trdy      ,
    output  reg                         o_axis_slave0_tvld      ,
    output  reg     [127:0]             o_axis_slave0_tdata     ,
    output  reg                         o_axis_slave0_tlast     ,
    output  reg                         o_axis_slave0_tuser
);
localparam      IDLE        = 2'd0;
localparam      HEADER_TX   = 2'd1;
localparam      DATA_TX     = 2'd2;

localparam      FIFO_DEEP   = 7'd64;    //should be 2^N  real_deep = deep < 16 ? 16 : deep;

reg     [9:0]   cpld_length;
wire    [9:0]   cpld_length_tx;
reg     [7:0]   cpld_tag;
reg     [63:0]  cpld_addr;
reg     [15:0]  cpld_req_id;
reg     [2:0]   cpld_tc;
reg     [2:0]   cpld_attr;

reg             is_first_cpl;
reg     [9:0]   first_cpl_offset;
wire            first_cpl_offset_calcu_done;

wire            rd_en;

reg     [1:0]   state;
reg     [1:0]   next_state;

//tlp_tx
wire    [15:0]  cpld_cpl_id;
wire    [2:0]   fmt;
wire    [4:0]   tlp_type;
wire            th;
wire            td;
wire    [2:0]   tc;
wire    [2:0]   attr;
wire            ep;
wire    [1:0]   at;
wire    [2:0]   compl_status;
wire            bcm;
wire    [11:0]  byte_cnt;
wire    [6:0]   low_addr;
wire    [31:0]  cpld_header_tx;

reg             tx_busy;
wire            tx_done;
wire            data_vlad;

wire    [103:0] data_in;
wire    [103:0] data_out;
wire            fifo_data_in;
wire            fifo_data_out;
wire            data_in_valid;
wire            data_in_ready;
wire            data_out_valid;
reg     [6:0]   fifo_data_cnt;

wire [9:0]      max_payload_size;

assign max_payload_size = (i_cfg_max_payload_size == 3'd0) ? 10'h20 :           //dw
                          (i_cfg_max_payload_size == 3'd1) ? 10'h40 :
                          (i_cfg_max_payload_size == 3'd2) ? 10'h80 :
                          (i_cfg_max_payload_size == 3'd3) ? 10'h100 : 10'd20;

//reg             cpld_req_ff;

assign data_in = {i_mrd_tc,     //103:101
                  i_mrd_attr,   //100:98
                  i_mrd_length, //97:88
                  i_mrd_id,     //87:72
                  i_mrd_tag,    //71:64
                  i_mrd_addr};  //63:0

assign data_in_valid = i_cpld_req_vld;

assign o_cpld_req_rdy = data_in_ready;

//cpld_req buff
    pgs_pciex4_prefetch_fifo_v1_2
    #(
        .D              (FIFO_DEEP      ),  //should be 2^N
        .W              (104            )
     )
    u_cpld_req_fifo
    (
    .clk                (clk            ),
    .rst_n              (rst_n          ),

    .data_in_valid      (data_in_valid  ),
    .data_in            (data_in        ),
    .data_in_ready      (data_in_ready  ),

    .data_out_ready     (~tx_busy       ),
    .data_out           (data_out       ),
    .data_out_valid     (data_out_valid )
    );

assign fifo_data_in  = data_in_valid  && data_in_ready ;
assign fifo_data_out = ~tx_busy && data_out_valid;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        fifo_data_cnt <= 7'b0;
    else if(fifo_data_in && fifo_data_out)
        fifo_data_cnt <= fifo_data_cnt;
    else if(fifo_data_in)
        fifo_data_cnt <= fifo_data_cnt + 7'h1;
    else if(fifo_data_out)
        fifo_data_cnt <= fifo_data_cnt - 7'h1;
end

//for o_trgt1_radm_pkt_halt[1] :Halt non-posted TLPs for VC0,MRD
assign o_cpld_tx_rdy = (fifo_data_cnt >= FIFO_DEEP- 7'd10 ) ? 1'b0 : 1'b1 ;

//******************************************************************get mrd information************************************************************************
// current mult-completion address equals to:
// 1. for the first completion, address equals to MRD address
// 2. for the other comoletion(if have), address from last mult-completion's address added last mult-completion's length
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cpld_addr <= 64'd0;
    else if(fifo_data_out)
        cpld_addr <= data_out[63:0];
    else if(|cpld_length && state == HEADER_TX && !o_cpld_tx_hold)
        cpld_addr <= cpld_addr + {52'b0,cpld_length_tx,2'b0};
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cpld_tag <= 8'd0;
    else if(fifo_data_out)
        cpld_tag <= data_out[71:64];
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cpld_req_id <= 16'd0;
    else if(fifo_data_out)
        cpld_req_id <= data_out[87:72];
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cpld_length <= 10'd0;
    else if(fifo_data_out)
        cpld_length <= data_out[97:88];
    else if(state == HEADER_TX  && !o_cpld_tx_hold)
        cpld_length <= cpld_length - cpld_length_tx;
end

//multicpld: first completion
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        is_first_cpl <= 1'b0;
    else if(tx_done)
        is_first_cpl <= 1'b0;
    else if(fifo_data_out)
        is_first_cpl <= 1'b1;
end

//multicpld: for rcb first_completion_length = max_payload_size - first_cpl_offset
//first_cpl_offset need <= max_payload_size
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        first_cpl_offset <= 10'b0;
    else if(fifo_data_out)
        first_cpl_offset <= data_out[11:2];
    else if (first_cpl_offset >= max_payload_size)
        first_cpl_offset <= first_cpl_offset - max_payload_size;
end

assign first_cpl_offset_calcu_done = first_cpl_offset < max_payload_size;

//the true length to be transmitted
assign cpld_length_tx = (cpld_length <= max_payload_size) ? cpld_length :
                        (is_first_cpl && first_cpl_offset_calcu_done) ? (max_payload_size - first_cpl_offset) : max_payload_size ;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cpld_attr <= 3'd0;
    else if(fifo_data_out)
        cpld_attr <= data_out[100:98];
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cpld_tc <= 3'd0;
    else if(fifo_data_out)
        cpld_tc <= data_out[103:101];
end

//gen tx busy
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tx_busy <= 1'b0;
    else if(tx_done && ~(|cpld_length))
        tx_busy <= 1'b0;
    else if(fifo_data_out)
        tx_busy <= 1'b1;
end

//gen rd_en
assign rd_en = is_first_cpl ? ((cpld_length <= max_payload_size) ? |cpld_length : first_cpl_offset_calcu_done ) :  |cpld_length;

//rd ram ctrl
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_rd_en <= 1'b0;
    else if(tx_done)
        o_rd_en <= 1'b0;
    else if(rd_en)
        o_rd_en <= 1'b1;
end

assign data_vlad = i_gen_tlp_start;

assign o_rd_length = cpld_length_tx;
assign o_rd_addr   = cpld_addr;

//tlp header
//first DW
assign {fmt,tlp_type}   = 8'h4a;
assign {th,td,ep,at}    = 5'b0;
assign tc               = cpld_tc;
assign attr             = cpld_attr;
//second DW
assign cpld_cpl_id      = {i_cfg_pbus_num,i_cfg_pbus_dev_num,3'b0};
assign compl_status     = 3'b0;
assign bcm              = 1'b0;
assign byte_cnt         = {cpld_length,2'b0};
//third DW
assign low_addr         = is_first_cpl ? {cpld_addr[6:2],2'b0} : 7'b0;
assign cpld_header_tx   = {fmt,tlp_type,1'b0,tc,1'b0,attr[2],1'b0,th,td,ep,attr[1:0],at,cpld_length_tx};

//mwr_tx
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        state <= IDLE;
    else
        state <= next_state;
end

always @(*)
begin
    case(state)
        IDLE:
        begin
            if(i_gen_tlp_start && i_axis_slave0_trdy) //start transmit
                next_state = HEADER_TX;
            else
                next_state = IDLE;
        end
        HEADER_TX:
        begin
            if(i_axis_slave0_trdy)
                next_state = DATA_TX;
            else
                next_state = state;
        end
        DATA_TX:
        begin
            if(i_last_data && !o_cpld_tx_hold)//transmit end
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

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        o_axis_slave0_tdata <= 128'b0;
        o_axis_slave0_tvld  <= 1'b0;
        o_axis_slave0_tuser <= 1'b0;
        o_axis_slave0_tlast <= 1'b0;
    end
    else if(!o_cpld_tx_hold)
    begin
        case(state)
            IDLE:
            begin
                o_axis_slave0_tdata <= 128'b0;
                o_axis_slave0_tvld  <= 1'b0;
                o_axis_slave0_tuser <= 1'b0;
                o_axis_slave0_tlast <= 1'b0;
            end
            HEADER_TX:
            begin
                o_axis_slave0_tvld  <= 1'b1;
                o_axis_slave0_tdata <= {32'd0,cpld_req_id,cpld_tag,1'b0,low_addr,cpld_cpl_id,compl_status,bcm,byte_cnt,cpld_header_tx};
            end
            DATA_TX:
            begin
                o_axis_slave0_tvld  <= data_vlad;
                o_axis_slave0_tdata <= endian_convert(i_rd_data);
                if(i_last_data)
                    o_axis_slave0_tlast <= 1'b1;
            end
            default:
            begin
                o_axis_slave0_tdata <= 128'b0;
                o_axis_slave0_tvld  <= 1'b0;
                o_axis_slave0_tuser <= 1'b0;
                o_axis_slave0_tlast <= 1'b0;
            end
        endcase
    end
end

assign tx_done = i_axis_slave0_trdy && o_axis_slave0_tvld && o_axis_slave0_tlast;

//when i_axis_slave0_trdy down,hold all tx logic
assign o_cpld_tx_hold = ~i_axis_slave0_trdy && o_axis_slave0_tvld;

assign o_cpld_tlp_tx = state == DATA_TX;

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