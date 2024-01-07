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
module ipsl_pcie_apb2dbi_v1_0 (
    input                       pclk_div2               ,
    input                       apb_rst_n               ,
    input                       p_sel                   ,
    input           [ 3:0]      p_strb                  ,
    input           [15:0]      p_addr                  , // dbi use [11:2]
    input           [31:0]      p_wdata                 ,
    input                       p_ce                    ,
    input                       p_we                    ,
    output  reg                 p_rdy                   ,
    output  reg     [31:0]      p_rdata                 ,
    output  reg     [31:0]      dbi_addr                ,
    output  reg     [31:0]      dbi_din                 ,
    output  reg                 dbi_cs                  ,
    output  reg                 dbi_cs2                 ,
    output  reg     [ 3:0]      dbi_wr                  ,
    output  reg                 app_dbi_ro_wr_disable   ,
    input                       lbc_dbi_ack             ,
    input           [31:0]      lbc_dbi_dout            ,
    input                       dbi_halt
);

wire        apb_access  ;
wire        dbi_standby ;

assign dbi_standby = !(dbi_cs || lbc_dbi_ack);
assign apb_access = (p_sel && p_ce && !p_rdy);

always @(posedge pclk_div2 or negedge apb_rst_n) begin
    if (!apb_rst_n)
    begin
        app_dbi_ro_wr_disable <= 1'd0;
        dbi_cs2  <= 1'b0;
        dbi_cs   <= 1'b0;
        dbi_addr <= 32'd0;
        dbi_din  <= 32'd0;
    end
    else if (apb_access && dbi_standby)
    begin
        if (p_addr[1])
            app_dbi_ro_wr_disable <= 1'b1;

        if (p_addr[0])
            dbi_cs2 <= 1'b1;
        else
            dbi_cs2 <= 1'b0;

        dbi_cs   <= 1'b1;
        dbi_addr <= {20'd0,p_addr[11:2],2'd0};
        dbi_din  <= p_wdata;

    end
    else if (lbc_dbi_ack)
    begin
        dbi_cs  <= 1'b0;
        dbi_cs2 <= 1'b0;
    end
    else
        app_dbi_ro_wr_disable <= 1'b0;
end

always @(posedge pclk_div2 or negedge apb_rst_n) begin
    if (!apb_rst_n)
        dbi_wr <= 4'd0;
    else if (dbi_standby && apb_access && p_we)
        dbi_wr <= p_strb;
    else
        dbi_wr <= 4'd0;
end

always @(posedge pclk_div2 or negedge apb_rst_n) begin
    if (!apb_rst_n)
    begin
        p_rdy <= 1'b0;
        p_rdata <= 32'd0;
    end
    else if (!dbi_cs && lbc_dbi_ack && p_sel && p_ce)
    begin
        if (!dbi_halt)
            p_rdy <= 1'b1;
        else
            p_rdy <= 1'b0;

        if (!p_we)
            p_rdata <= lbc_dbi_dout;
    end
    else
        p_rdy <= 1'b0;
end

endmodule
