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
// Filename:ipsl_pcie_dma_mrd_tx_ctrl.v
//////////////////////////////////////////////////////////////////////////////
module ipsl_pcie_dma_mrd_tx_ctrl (
    input                               clk                     ,   //gen1:62.5MHz,gen2:125MHz
    input                               rst_n                   ,
    input           [7:0]               i_cfg_pbus_num          ,
    input           [4:0]               i_cfg_pbus_dev_num      ,
    input           [2:0]               i_cfg_max_rd_req_size   ,
    //**********************************************************************
    //from dma controller
    input                               i_mrd32_req             ,
    output  reg                         o_mrd32_req_ack         ,
    input                               i_mrd64_req             ,
    output  reg                         o_mrd64_req_ack         ,
    input           [9:0]               i_req_length            ,
    input           [63:0]              i_req_addr              ,
    //**********************************************************************
    input                               i_cpld_rcv              ,
    input           [7:0]               i_cpld_tag              ,
    output  wire                        o_tag_full              ,
    //axis_slave interface
    input                               i_axis_slave1_trdy      ,
    output  reg                         o_axis_slave1_tvld      ,
    output  reg     [127:0]             o_axis_slave1_tdata     ,
    output  reg                         o_axis_slave1_tlast     ,
    output  reg                         o_axis_slave1_tuser     ,
    //debug
    input                               i_tx_restart
    //output  wire    [13:0]              o_dbg_bus

);
localparam      IDLE        = 2'd0;
localparam      HEADER_TX   = 2'd1;

reg     [63:0]  mrd_addr;
reg     [9:0]   mrd_length;
reg     [9:0]   mrd_length_ff;
wire    [9:0]   mrd_length_tx;

wire            mrd_req_start;

reg             mrd32_req_tx;
reg             mrd64_req_tx;

reg     [1:0]   state;
reg     [1:0]   next_state;

wire            mrd_req_rcv;

reg     [63:0]  cpld_tag;

//tlp_tx
wire    [15:0]  requester_id;
wire    [2:0]   fmt;
wire    [4:0]   tlp_type;
wire    [2:0]   tc;
wire    [2:0]   attr;
wire            th;
wire            td;
reg     [5:0]   mrd_tag;
wire            ep;
wire    [1:0]   at;
wire    [31:0]  mrd_header_tx;

wire    [3:0]   first_dwbe;
wire    [3:0]   last_dwbe;
wire    [7:0]   dwbe;

reg             tx_busy;
reg             tx_mrd;
reg             tx_mrd_ff;

wire            mrd_req_ack;
wire            mrd_tx_hold;

wire            tx_done;

wire [63:0]     mask_mrd_vec;

wire            mrd_tx_halt;

reg             tx_tag_vld;

wire [9:0]      max_rd_req_size;

assign mrd_req_rcv = i_mrd32_req || i_mrd64_req;

assign mrd_req_ack = o_mrd32_req_ack || o_mrd64_req_ack;

assign mrd_req_start = mrd_req_rcv && mrd_req_ack;

assign tx_done  =  i_axis_slave1_trdy && o_axis_slave1_tvld && o_axis_slave1_tlast;

assign max_rd_req_size = (i_cfg_max_rd_req_size == 3'd0) ? 10'h20 :
                         (i_cfg_max_rd_req_size == 3'd1) ? 10'h40 :
                         (i_cfg_max_rd_req_size == 3'd2) ? 10'h80 :
                         (i_cfg_max_rd_req_size == 3'd3) ? 10'h100 : 10'd20;

//get tlp information
//length > max_rd_req_size,
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        mrd_length <= 10'd0;
    else if(mrd_req_start && !tx_busy)
        mrd_length <= i_req_length;
    else if((mrd_length >  max_rd_req_size) && tx_mrd && i_axis_slave1_trdy)
        mrd_length <= mrd_length - max_rd_req_size;
    else if((mrd_length <= max_rd_req_size) && tx_mrd && i_axis_slave1_trdy)
        mrd_length <= 10'b0;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        mrd_length_ff <= 10'd0;
    else if(~mrd_tx_halt)
        mrd_length_ff <= mrd_length;
end

//the true length to be transmitted
assign mrd_length_tx = (mrd_length_ff > max_rd_req_size) ? max_rd_req_size : mrd_length_ff ;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        mrd_addr <= 64'd0;
    else if(mrd_req_start && !tx_busy)
        mrd_addr <= i_req_addr;
    else if(|mrd_length && tx_done)
        mrd_addr <= mrd_addr + {52'b0,max_rd_req_size,2'b0};
end

//start tx mrd
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tx_mrd <= 1'b0;
    else if(i_axis_slave1_trdy && tx_mrd)
        tx_mrd <= 1'b0;
    else if(mrd_req_start && !tx_busy && ~mrd_tx_halt)  //new req rcv
        tx_mrd <= 1'b1;
    else if(|mrd_length && tx_done && ~mrd_tx_halt)  //for length > max_rd_req_size
        tx_mrd <= 1'b1;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tx_mrd_ff <= 1'b0;
    else
        tx_mrd_ff <= tx_mrd;
end

//tag ctrl,for 64 valid tag
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        mrd_tag <= 6'b0;
    else if(tx_done)
        mrd_tag <= mrd_tag + 6'b1;
    else if(cpld_tag == 64'b0)
        mrd_tag <= 6'b0;
end

genvar i;
generate
    for ( i = 0; i < 64; i = i + 1 )
    begin:tag_ctrl
        assign mask_mrd_vec[i] = tx_tag_vld && (mrd_tag == i) && cpld_tag[i];

        always@(posedge clk or negedge rst_n)
        begin
            if(!rst_n)
                cpld_tag[i] <= 1'b0;
            else if(o_axis_slave1_tvld && i_axis_slave1_trdy && (mrd_tag == i))
                cpld_tag[i] <= 1'b1;
            else if(i_cpld_rcv && (i_cpld_tag == i))
                cpld_tag[i] <= 1'b0;
        end
    end
endgenerate

//
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tx_tag_vld <= 1'b0;
    else if(tx_mrd && ~tx_mrd_ff)
        tx_tag_vld <= 1'b1;
    else if(o_axis_slave1_tvld && i_axis_slave1_trdy)
        tx_tag_vld <= 1'b0;
end

//when the sent tag is not released,will halt mrd tx logic
assign mrd_tx_halt = |mask_mrd_vec;

assign o_tag_full = &cpld_tag;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        mrd32_req_tx <= 1'b0;
    else if(tx_done && ~(|mrd_length))
        mrd32_req_tx <= 1'b0;
    else if(mrd_req_start)
        mrd32_req_tx <= i_mrd32_req;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        mrd64_req_tx <= 1'b0;
    else if(tx_done && ~(|mrd_length))
        mrd64_req_tx <= 1'b0;
    else if(mrd_req_start)
        mrd64_req_tx <= i_mrd64_req;
end

//tlp header
assign requester_id     = {i_cfg_pbus_num,i_cfg_pbus_dev_num,3'b0};
assign {fmt,tlp_type}   = mrd32_req_tx ? 8'h0
                        : mrd64_req_tx ? 8'h20 : 8'h00;
assign tc               = 3'b0;
assign attr             = 3'b0;
assign {th,td,ep,at}    = 5'b0;
assign mrd_header_tx    = {fmt,tlp_type,1'b0,tc,1'b0,attr[2],1'b0,th,td,ep,attr[1:0],at,mrd_length_tx};
assign first_dwbe       = 4'hf;
assign last_dwbe        = mrd_length_tx == 10'h1 ? 4'h0 : 4'hf;
assign dwbe             = {last_dwbe,first_dwbe};
//mrd_tx
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
            if(tx_mrd && i_axis_slave1_trdy && ~mrd_tx_halt) //start transmit
                next_state = HEADER_TX;
            else
                next_state = IDLE;
        end
        HEADER_TX:
        begin
            if(mrd_tx_hold || mrd_tx_halt)
                next_state = state;
            else
                next_state = IDLE;
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
        o_axis_slave1_tdata <= 128'd0;
        o_axis_slave1_tvld  <= 1'b0;
        o_axis_slave1_tuser <= 1'b0;
        o_axis_slave1_tlast <= 1'b0;
    end
    else if(~mrd_tx_hold)
    begin
        case(state)
            IDLE:
            begin
                o_axis_slave1_tdata <= 128'd0;
                o_axis_slave1_tvld  <= 1'b0;
                o_axis_slave1_tuser <= 1'b0;
                o_axis_slave1_tlast <= 1'b0;
            end
            HEADER_TX:
            begin
                o_axis_slave1_tvld  <= ~mrd_tx_halt;
                o_axis_slave1_tlast <= ~mrd_tx_halt;
                if(mrd32_req_tx)
                    o_axis_slave1_tdata <= {{mrd_addr[31:2],2'b0},requester_id,{2'b0,mrd_tag},dwbe,mrd_header_tx};
                else if(mrd64_req_tx)
                    o_axis_slave1_tdata <= {{mrd_addr[31:2],2'b0},mrd_addr[63:32],requester_id,{2'b0,mrd_tag},dwbe,mrd_header_tx};
            end
            default:
            begin
                o_axis_slave1_tdata <= 128'd0;
                o_axis_slave1_tvld  <= 1'b0;
                o_axis_slave1_tuser <= 1'b0;
                o_axis_slave1_tlast <= 1'b0;
            end
        endcase
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tx_busy <= 1'b0;
    else if(~(|mrd_length) && tx_done)
        tx_busy <= 1'b0;
    else if(mrd_req_start)
        tx_busy <= 1'b1;
end

//ack
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_mrd32_req_ack <= 1'b0;
    else if(!i_mrd32_req)
        o_mrd32_req_ack <= 1'b0;
    else if(i_mrd32_req && !tx_busy)
        o_mrd32_req_ack <= 1'b1;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_mrd64_req_ack <= 1'b0;
    else if(!i_mrd64_req)
        o_mrd64_req_ack <= 1'b0;
    else if(i_mrd64_req && !tx_busy)
        o_mrd64_req_ack <= 1'b1;
end

//when i_axis_slave1_trdy down,hold all tx logic
assign mrd_tx_hold = ~i_axis_slave1_trdy && o_axis_slave1_tvld;
//******************************************************************debug ************************************************************************
reg     [13:0]  tlp_tx_sum;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tlp_tx_sum <= 14'b0;
    else if(i_tx_restart)
        tlp_tx_sum <= 14'b0;
    else if(tx_done)
        tlp_tx_sum <= tlp_tx_sum + 14'b1;
end

//debug_bus
//assign o_dbg_bus = {
//                    tlp_tx_sum //13:0
//                    };

endmodule
