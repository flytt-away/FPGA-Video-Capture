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
// Filename:ipsl_pcie_dma_rd_ctrl.v
//////////////////////////////////////////////////////////////////////////////
module ipsl_pcie_dma_rd_ctrl #(
    parameter                            ADDR_WIDTH  = 4'd9
)(
    input                                clk             ,   //gen1:62.5MHz,gen2:125MHz
    input                                rst_n           ,
    //**********************************************************************
    //ram interface
    input                               i_rd_en         ,
    input           [9:0]               i_rd_length     ,
    input           [63:0]              i_rd_addr       ,
    input                               i_tx_hold       ,
    input                               i_tlp_tx        ,

    output  wire                        o_rd_ram_hold   ,
    output  wire                        o_gen_tlp_start ,
    output  wire    [127:0]             o_rd_data       ,
    output  wire                        o_last_data     ,
    //ram_rd
    output  reg                         o_bar_rd_clk_en ,
    output  wire    [ADDR_WIDTH-1:0]    o_bar_rd_addr   ,
    input           [127:0]             i_bar_rd_data
);

localparam FIFO_DEEP = 8'd128;    //should be 2^N  real_deep = deep < 16 ? 16 : deep;

reg                         rd_en_ff;
wire                        rd_start;

reg     [ADDR_WIDTH-1:0]    rd_addr;

reg     [10:0]              data_read_cnt;

reg     [1:0]               data_position;
reg     [127:0]             rd_data_ff;
wire    [255:0]             data_shift;
reg     [127:0]             data_shift_out;

reg     [9:0]               shift_data_cnt;
reg     [9:0]               shift_data_cnt_ff;

reg                         shift_data_out_valid;
reg                         ram_data_out_vld;
wire                        ram_last_data_rd  ;
reg                         data_in_valid;
wire                        data_in_ready;
wire                        fifo_data_in;
wire                        fifo_data_out;
reg     [7:0]               fifo_data_cnt;
reg                         rd_ram_hold_ff;
wire                        data_out_ready;
wire                        data_out_valid;
reg     [9:0]               tx_data_cnt;

wire    [127:0]             data_out;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rd_en_ff <= 1'b0;
    else
        rd_en_ff <= i_rd_en;
end
//rd ctrl start
assign rd_start = ~rd_en_ff && i_rd_en;

//total dw data need read
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        data_read_cnt <= 11'b0;
    else if(rd_start)
        data_read_cnt <= {1'b0,i_rd_length} + {9'b0,i_rd_addr[3:2]};
    else if(!o_rd_ram_hold)
    begin
        if(data_read_cnt > 11'h4)
            data_read_cnt <= data_read_cnt - 11'h4;
        else if(data_read_cnt <= 11'h4)
            data_read_cnt <= 11'b0;
    end
end

//bar rd enable
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        o_bar_rd_clk_en <= 1'b0;
    else if(rd_start)
        o_bar_rd_clk_en <= 1'b1;
    else if(data_read_cnt <= 11'd4)
        o_bar_rd_clk_en <= 1'b0;
end

//bar rd addr
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rd_addr <= {ADDR_WIDTH{1'b0}};
    else if(rd_start)
        rd_addr <= i_rd_addr[15:4];
    else if(o_bar_rd_clk_en && !o_rd_ram_hold)
        rd_addr <= rd_addr + {{(ADDR_WIDTH-1){1'b0}},1'b1};
end

assign o_bar_rd_addr = rd_addr;

//data_shift
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        data_position <= 2'b0;
    else if(rd_start)
        data_position <= i_rd_addr[3:2];
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rd_data_ff <= 128'b0;
    else if(!rd_ram_hold_ff)
        rd_data_ff <= i_bar_rd_data;
end

assign data_shift = {i_bar_rd_data,rd_data_ff};

always@(*)
begin
    case(data_position)
        2'd0: data_shift_out = data_shift[32*0+127:32*0];
        2'd1: data_shift_out = data_shift[32*1+127:32*1];
        2'd2: data_shift_out = data_shift[32*2+127:32*2];
        2'd3: data_shift_out = data_shift[32*3+127:32*3];
        default : data_shift_out = 128'b0;
    endcase
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        shift_data_cnt <= 10'b0;
    else if(rd_start)
        shift_data_cnt <= i_rd_length;
    else if(!o_rd_ram_hold)
    begin
        if(shift_data_cnt >= 10'd4)
            shift_data_cnt <= shift_data_cnt - 10'd4;
        else if(shift_data_cnt < 10'd4)
            shift_data_cnt <= 10'b0;
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        shift_data_cnt_ff  <= 10'b0;
    else
        shift_data_cnt_ff  <= shift_data_cnt;
end

//bar read data valid
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        ram_data_out_vld <= 1'b0;
    else if(o_rd_ram_hold)
        ram_data_out_vld <= 1'b0;
    else
        ram_data_out_vld <= o_bar_rd_clk_en;
end

//shift out data valid
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        shift_data_out_valid <= 1'b0;
    else if(!o_rd_ram_hold)
    begin
        if(shift_data_cnt_ff > 10'b0)
            shift_data_out_valid <= 1'b1;
        else if(~(|shift_data_cnt_ff) && fifo_data_in)
            shift_data_out_valid <= 1'b0;
    end
end

//read ram last data flag
assign ram_last_data_rd = ~(|shift_data_cnt_ff) && shift_data_out_valid;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        data_in_valid <= 1'b0;
    else if(o_rd_ram_hold || ram_last_data_rd && data_in_valid)
        data_in_valid <= 1'b0;
    else if(((fifo_data_cnt == FIFO_DEEP - 8'd3) && shift_data_out_valid)  || ram_data_out_vld)
        data_in_valid <= 1'b1;
end

    pgs_pciex4_prefetch_fifo_v1_2
    #(
        .D              (FIFO_DEEP      ), //should be 2^N
        .W              (128            )
     )
    u_mwr_data_rd_fifo
    (
    .clk                (clk            ),
    .rst_n              (rst_n          ),

    .data_in_valid      (data_in_valid  ),
    .data_in            (data_shift_out ),
    .data_in_ready      (data_in_ready  ),

    .data_out_ready     (data_out_ready ),
    .data_out           (data_out       ),
    .data_out_valid     (data_out_valid )
    );

assign fifo_data_in  = data_in_valid  && data_in_ready ;
assign fifo_data_out = data_out_ready && data_out_valid;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        fifo_data_cnt <= 8'b0;
    else if(fifo_data_in && fifo_data_out)
        fifo_data_cnt <= fifo_data_cnt;
    else if(fifo_data_in)
        fifo_data_cnt <= fifo_data_cnt + 8'h1;
    else if(fifo_data_out)
        fifo_data_cnt <= fifo_data_cnt - 8'h1;
end

assign o_rd_ram_hold = (fifo_data_cnt >= FIFO_DEEP - 8'd2) ? 1'b1 : 1'b0;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rd_ram_hold_ff <= 1'b0;
    else
        rd_ram_hold_ff <= o_rd_ram_hold;
end

assign data_out_ready  = i_tlp_tx && !i_tx_hold;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tx_data_cnt <= 10'b0;
    else if(rd_start)
        tx_data_cnt <= (i_rd_length >= 10'd4) ? i_rd_length - 10'd4 :  10'd0;
    else if(fifo_data_out && |tx_data_cnt)
        tx_data_cnt <= (tx_data_cnt >= 10'd4) ? tx_data_cnt - 10'd4 :  10'd0;
end

//read fifo last data flag
assign o_last_data = ~(|tx_data_cnt) && fifo_data_out;

assign o_gen_tlp_start = data_out_valid;
assign o_rd_data       = data_out;

endmodule