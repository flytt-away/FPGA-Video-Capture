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
// Filename:ipsl_pcie_dma_tx_mwr_rd_ctrl.v
//////////////////////////////////////////////////////////////////////////////
module ipsl_pcie_dma_tx_mwr_rd_ctrl #(
    parameter                           ADDR_WIDTH  = 4'd9
)(
    input                               clk             ,            //gen1:62.5MHz,gen2:125MHz
    input                               rst_n           ,
    //**********************************************************************
    //ram interface
    input                               i_rd_en         ,
    input           [9:0]               i_rd_length     ,
    input                               i_mwr_tx_busy   ,
    input                               i_mwr_tx_hold   ,
    input                               i_mwr_tlp_tx    ,

    output  wire                        o_gen_tlp_start ,
    output  wire    [127:0]             o_rd_data       ,
    output  wire                        o_last_data     ,
    //ram_rd
    output  wire                        o_bar_rd_clk_en ,
    output  wire    [ADDR_WIDTH-1:0]    o_bar_rd_addr   ,
    input           [127:0]             i_bar_rd_data
);

reg                 rd_en_ff;
wire                rd_start;

reg     [10:0]      rd_addr;
reg     [9:0]       data_remain_cnt;
reg     [9:0]       data_remain_cnt_ff;

wire                rd_ram_hold;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rd_en_ff <= 1'b0;
    else
        rd_en_ff <= i_rd_en;
end

assign rd_start = ~rd_en_ff && i_rd_en;

//calculating rd addr from rd length
//data need to read
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        data_remain_cnt <= 10'b0;
    else if(rd_start)
        data_remain_cnt <= i_rd_length;
    else if(!rd_ram_hold)
    begin
        if(data_remain_cnt >= 10'd4)
            data_remain_cnt <= data_remain_cnt - 10'd4;
        else if(data_remain_cnt < 10'd4)
            data_remain_cnt <= 10'b0;
    end
end

//data_shift
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        data_remain_cnt_ff <= 10'b0;
    else if(!rd_ram_hold)
        data_remain_cnt_ff <= data_remain_cnt;
end

//rd_dw_addr
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rd_addr <= 11'b0;
    else if(!i_mwr_tx_busy)
        rd_addr <= 11'b0;
    else if(o_bar_rd_clk_en && !rd_ram_hold)
    begin
        if(data_remain_cnt_ff >= 10'd4 )
            rd_addr <= rd_addr +11'd4;
        else
            rd_addr <= rd_addr + {9'b0+data_remain_cnt_ff[1:0]};
    end
end

ipsl_pcie_dma_rd_ctrl #(
    .ADDR_WIDTH             (ADDR_WIDTH             )
)
u_ipsl_pcie_dma_mwr_rd_ctrl
(
    .clk                    (clk                    ),  //gen1:62.5MHz,gen2:125MHz
    .rst_n                  (rst_n                  ),
    //**********************************************************************
    //ram interface
    .i_rd_en                (rd_en_ff               ),
    .i_rd_length            (i_rd_length            ),
    .i_rd_addr              ({51'b0,rd_addr,2'b0}   ),
    .i_tx_hold              (i_mwr_tx_hold          ),
    .i_tlp_tx               (i_mwr_tlp_tx           ),
    .o_rd_ram_hold          (rd_ram_hold            ),
    .o_gen_tlp_start        (o_gen_tlp_start        ),
    .o_rd_data              (o_rd_data              ),
    .o_last_data            (o_last_data            ),
    //ram_rd
    .o_bar_rd_clk_en        (o_bar_rd_clk_en        ),
    .o_bar_rd_addr          (o_bar_rd_addr          ),
    .i_bar_rd_data          (i_bar_rd_data          )
);

endmodule