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
module ipsl_pcie_apb_cross_v1_0 (
    //from src domain
    input               i_src_clk       ,
    input               i_src_rst_n     ,
    input               i_src_p_sel     ,
    input       [3:0]   i_src_p_strb    ,
    input       [15:0]  i_src_p_addr    ,
    input       [31:0]  i_src_p_wdata   ,
    input               i_src_p_ce      ,
    input               i_src_p_we      ,
    output  reg         o_src_p_rdy     ,
    output  reg [31:0]  o_src_p_rdata   ,
    //to target domain
    input               i_des_clk       ,
    input               i_des_rst_n     ,
    output  reg         o_des_p_sel     ,
    output  reg [3:0]   o_des_p_strb    ,
    output  reg [15:0]  o_des_p_addr    ,
    output  reg [31:0]  o_des_p_wdata   ,
    output  reg         o_des_p_ce      ,
    output  reg         o_des_p_we      ,
    input               i_des_p_rdy     ,
    input       [31:0]  i_des_p_rdata
);

reg             src_p_sel;
reg     [3:0]   src_p_strb;
reg     [15:0]  src_p_addr;
reg     [31:0]  src_p_wdata;
reg             src_p_ce;
reg             src_p_we;

reg     [2:0]   src_dly;
reg     [1:0]   des_dly;
reg     [1:0]   sync_src_p_sel;
reg     [1:0]   sync_src_dly;
wire            des_apb_start;
wire            des_apb_end;
reg             des_p_rdy_hold;
reg     [31:0]  des_p_rdata_hold;
//---------------------------------------------src domain-----------------------------------------------
always@(posedge i_src_clk or negedge i_src_rst_n)
begin
    if(!i_src_rst_n)
        src_p_sel <= 1'b0;
    else
        src_p_sel <= i_src_p_sel;
end

always@(posedge i_src_clk or negedge i_src_rst_n)
begin
    if(!i_src_rst_n)
        src_p_strb <= 4'b0;
    else
        src_p_strb <= i_src_p_strb;
end

always@(posedge i_src_clk or negedge i_src_rst_n)
begin
    if(!i_src_rst_n)
        src_p_addr <= 16'b0;
    else
        src_p_addr <= i_src_p_addr;
end

always@(posedge i_src_clk or negedge i_src_rst_n)
begin
    if(!i_src_rst_n)
        src_p_wdata <= 32'b0;
    else
        src_p_wdata <= i_src_p_wdata;
end

always@(posedge i_src_clk or negedge i_src_rst_n)
begin
    if(!i_src_rst_n)
        src_p_ce <= 1'b0;
    else
        src_p_ce <= i_src_p_ce;
end

always@(posedge i_src_clk or negedge i_src_rst_n)
begin
    if(!i_src_rst_n)
        src_p_we <= 1'b0;
    else
        src_p_we <= i_src_p_we;
end

always@(posedge i_src_clk or negedge i_src_rst_n)
begin
    if(!i_src_rst_n)
        src_dly <= 3'b0;
    else
        src_dly <= {src_dly[1:0],des_p_rdy_hold};
end

always@(posedge i_src_clk or negedge i_src_rst_n)
begin
    if(!i_src_rst_n)
        o_src_p_rdy <= 1'b0;
    else if(o_src_p_rdy)
        o_src_p_rdy <= 1'b0;
    else if(src_p_sel & src_p_ce & ~o_src_p_rdy)
        o_src_p_rdy <= ~src_dly[2] & src_dly[1];
end

always@(posedge i_src_clk or negedge i_src_rst_n)
begin
    if(!i_src_rst_n)
        o_src_p_rdata <= 32'b0;
    else if(o_src_p_rdy)
        o_src_p_rdata <= 32'b0;
    else if(src_p_sel & src_p_ce & ~src_dly[2] & src_dly[1] & ~src_p_we)
        o_src_p_rdata <= des_p_rdata_hold;
end


//---------------------------------------------des domain-----------------------------------------------
always@(posedge i_des_clk or negedge i_des_rst_n)
begin
    if(!i_des_rst_n)
        sync_src_p_sel <= 2'b0;
    else
        sync_src_p_sel <= {sync_src_p_sel[0],src_p_sel};
end

always@(posedge i_des_clk or negedge i_des_rst_n)
begin
    if(!i_des_rst_n)
        sync_src_dly <= 2'b0;
    else
        sync_src_dly <= {sync_src_dly[0],src_dly[2]};
end

always@(posedge i_des_clk or negedge i_des_rst_n)
begin
    if(!i_des_rst_n)
        des_dly <= 2'b0;
    else if(sync_src_dly[1])
        des_dly <= {des_dly[0],1'b0};
    else
        des_dly <= {des_dly[0],sync_src_p_sel[1]};
end

assign des_apb_start = ~des_dly[1] &  des_dly[0];
assign des_apb_end   =  des_dly[1] & ~des_dly[0];

//get apb information
always@(posedge i_des_clk or negedge i_des_rst_n)
begin
    if(!i_des_rst_n)
        o_des_p_addr <= 16'b0;
    else if(des_apb_start)
        o_des_p_addr <= src_p_addr;
end

always@(posedge i_des_clk or negedge i_des_rst_n)
begin
    if(!i_des_rst_n)
        o_des_p_strb <= 4'b0;
    else if(des_apb_start)
        o_des_p_strb <= src_p_strb;
end

always@(posedge i_des_clk or negedge i_des_rst_n)
begin
    if(!i_des_rst_n)
        o_des_p_wdata <= 32'b0;
    else if(des_apb_start)
        o_des_p_wdata <= src_p_wdata;
end

always@(posedge i_des_clk or negedge i_des_rst_n)
begin
    if(!i_des_rst_n)
        o_des_p_we <= 1'b0;
    else if(des_apb_start)
        o_des_p_we <= src_p_we;
end

always@(posedge i_des_clk or negedge i_des_rst_n)
begin
    if(!i_des_rst_n)
        o_des_p_sel <= 1'b0;
    else if(i_des_p_rdy)
        o_des_p_sel <= 1'b0;
    else if(des_apb_start)
        o_des_p_sel <= 1'b1;
end

always@(posedge i_des_clk or negedge i_des_rst_n)
begin
    if(!i_des_rst_n)
        o_des_p_ce <= 1'b0;
    else if(i_des_p_rdy)
        o_des_p_ce <= 1'b0;
    else if(o_des_p_sel)
        o_des_p_ce <= 1'b1;
end

always@(posedge i_des_clk or negedge i_des_rst_n)
begin
    if(!i_des_rst_n)
        des_p_rdy_hold <= 1'b0;
    else if(des_apb_end)
        des_p_rdy_hold <= 1'b0;
    else if(o_des_p_sel & o_des_p_ce & i_des_p_rdy )
        des_p_rdy_hold <= 1'b1;
end

always@(posedge i_des_clk or negedge i_des_rst_n)
begin
    if(!i_des_rst_n)
        des_p_rdata_hold <= 32'b0;
    else if(des_apb_end)
        des_p_rdata_hold <= 32'b0;
    else if(o_des_p_sel & o_des_p_ce & i_des_p_rdy & ~o_des_p_we)
        des_p_rdata_hold <= i_des_p_rdata;
end

endmodule
