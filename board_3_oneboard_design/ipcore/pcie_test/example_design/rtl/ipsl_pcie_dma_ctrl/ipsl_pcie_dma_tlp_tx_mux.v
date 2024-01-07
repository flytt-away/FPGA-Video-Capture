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
// Filename:ipsl_pcie_dma_tlp_tx_mux.v
//////////////////////////////////////////////////////////////////////////////
module ipsl_pcie_dma_tlp_tx_mux #(
    parameter   integer                 AXIS_SLAVE_NUM = 3
)
(
    input                               clk                         ,   //gen1:62.5MHz,gen2:125MHz
    input                               rst_n                       ,
    //**********************************************************************
    //from dma
    //axis_slave0 interface
    output  wire                        o_dma_axis_slave0_trdy      ,
    input                               i_dma_axis_slave0_tvld      ,
    input           [127:0]             i_dma_axis_slave0_tdata     ,
    input                               i_dma_axis_slave0_tlast     ,
    input                               i_dma_axis_slave0_tuser     ,
    //axis_slave1 interface
    output  wire                        o_dma_axis_slave1_trdy      ,
    input                               i_dma_axis_slave1_tvld      ,
    input           [127:0]             i_dma_axis_slave1_tdata     ,
    input                               i_dma_axis_slave1_tlast     ,
    input                               i_dma_axis_slave1_tuser     ,
    //axis_slave2 interface
    output  wire                        o_dma_axis_slave2_trdy      ,
    input                               i_dma_axis_slave2_tvld      ,
    input           [127:0]             i_dma_axis_slave2_tdata     ,
    input                               i_dma_axis_slave2_tlast     ,
    input                               i_dma_axis_slave2_tuser     ,
    //credit interface
    //from pcie
    input                               i_cfg_ido_req_en            ,
    input                               i_cfg_ido_cpl_en            ,
    input           [7:0]               i_xadm_ph_cdts              ,
    input           [11:0]              i_xadm_pd_cdts              ,
    input           [7:0]               i_xadm_nph_cdts             ,
    input           [11:0]              i_xadm_npd_cdts             ,
    input           [7:0]               i_xadm_cplh_cdts            ,
    input           [11:0]              i_xadm_cpld_cdts            ,
    //pcie_axis_slave0
    input                               i_pcie_axis_slave_trdy     ,
    output  wire                        o_pcie_axis_slave_tvld     ,
    output  wire    [127:0]             o_pcie_axis_slave_tdata    ,
    output  wire                        o_pcie_axis_slave_tlast    ,
    output  wire                        o_pcie_axis_slave_tuser
);

localparam SLAVE0_FIFO_DEEP = 8'd128;    //should be 2^N  real_deep = deep < 16 ? 16 : deep;
localparam SLAVE1_FIFO_DEEP = 8'd128;    //should be 2^N  real_deep = deep < 16 ? 16 : deep;
localparam SLAVE2_FIFO_DEEP = 8'd128;    //should be 2^N  real_deep = deep < 16 ? 16 : deep;

localparam DATA_WIDTH = 8'd131;

localparam IDLE     = 2'd0;
localparam CPLD_TX  = 2'd1;
localparam MWR_TX   = 2'd2;
localparam MRD_TX   = 2'd3;

wire    [130:0] slave0_fifo_data_in;
wire    [130:0] slave1_fifo_data_in;
wire    [130:0] slave2_fifo_data_in;

reg     [1:0]   state;
reg     [1:0]   next_state;

wire             cpld_tx_rdy;
wire             mrd_tx_rdy;
wire             mwr_tx_rdy;

wire            cpld_fifo_out_rdy;
wire            mrd_fifo_out_rdy;
wire            mwr_fifo_out_rdy;

wire    [130:0] cpld_fifo_out;
wire    [130:0] mrd_fifo_out;
wire    [130:0] mwr_fifo_out;

wire            axis_slave0_vld;
wire            axis_slave1_vld;
wire            axis_slave2_vld;

wire            cpld_tx_vld;
reg             mwr_tx_vld;
wire            mrd_tx_vld;

reg             mwr_fifo_out_rdy_ff;
reg             axis_slave2_vld_ff;
reg             mwr_last_ff;
reg     [9:0]   mwr_length;

reg     [130:0] axis_slave;

reg     [7:0]   xadm_nph_cdts;
reg     [11:0]  xadm_pd_cdts;
reg     [7:0]   xadm_ph_cdts;

//axis_slave
generate
    if (AXIS_SLAVE_NUM == 1)
    begin
        assign slave0_fifo_data_in = {i_dma_axis_slave0_tvld,i_dma_axis_slave0_tuser,i_dma_axis_slave0_tlast,i_dma_axis_slave0_tdata};

        pgs_pciex4_prefetch_fifo_v1_2
            #(
                .D              (SLAVE0_FIFO_DEEP       ), //should be 2^N
                .W              (DATA_WIDTH             )
            )
            u_axis_slave0_fifo
            (
            .clk                (clk                    ),
            .rst_n              (rst_n                  ),

            .data_in_valid      (i_dma_axis_slave0_tvld ),
            .data_in            (slave0_fifo_data_in    ),
            .data_in_ready      (o_dma_axis_slave0_trdy ),

            .data_out_ready     (cpld_fifo_out_rdy      ),
            .data_out           (cpld_fifo_out          ),
            .data_out_valid     (axis_slave0_vld        )
            );

        //cpld :infinite credit
        assign cpld_tx_vld = axis_slave0_vld;
        assign cpld_fifo_out_rdy = cpld_tx_rdy & i_pcie_axis_slave_trdy;
    end
    else
    begin
        assign cpld_tx_vld = 1'b0;
        assign cpld_fifo_out = 131'b0;
    end
endgenerate

//axis_slave1 mrd
assign slave1_fifo_data_in = {i_dma_axis_slave1_tvld,i_dma_axis_slave1_tuser,i_dma_axis_slave1_tlast,i_dma_axis_slave1_tdata};

pgs_pciex4_prefetch_fifo_v1_2
    #(
        .D              (SLAVE1_FIFO_DEEP       ), //should be 2^N
        .W              (DATA_WIDTH             )
    )
    u_axis_slave1_fifo
    (
    .clk                (clk                    ),
    .rst_n              (rst_n                  ),

    .data_in_valid      (i_dma_axis_slave1_tvld ),
    .data_in            (slave1_fifo_data_in    ),
    .data_in_ready      (o_dma_axis_slave1_trdy ),

    .data_out_ready     (mrd_fifo_out_rdy       ),
    .data_out           (mrd_fifo_out           ),
    .data_out_valid     (axis_slave1_vld        )
    );

//Calculating mrd credit
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        xadm_nph_cdts <= 8'b0;
    else
        xadm_nph_cdts <= i_xadm_nph_cdts;
end

assign mrd_tx_vld = (|xadm_nph_cdts) ? axis_slave1_vld : 1'b0 ;

assign mrd_fifo_out_rdy = mrd_tx_rdy & i_pcie_axis_slave_trdy;

//axis_slave2 mwr
assign slave2_fifo_data_in = {i_dma_axis_slave2_tvld,i_dma_axis_slave2_tuser,i_dma_axis_slave2_tlast,i_dma_axis_slave2_tdata};

pgs_pciex4_prefetch_fifo_v1_2
    #(
        .D              (SLAVE2_FIFO_DEEP       ), //should be 2^N
        .W              (DATA_WIDTH             )
    )
    u_axis_slave2_fifo
    (
    .clk                (clk                    ),
    .rst_n              (rst_n                  ),

    .data_in_valid      (i_dma_axis_slave2_tvld ),
    .data_in            (slave2_fifo_data_in    ),
    .data_in_ready      (o_dma_axis_slave2_trdy ),

    .data_out_ready     (mwr_fifo_out_rdy       ),
    .data_out           (mwr_fifo_out           ),
    .data_out_valid     (axis_slave2_vld        )
    );

assign mwr_fifo_out_rdy = mwr_tx_rdy & i_pcie_axis_slave_trdy & mwr_tx_vld;

//Calculating mwr credit
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        xadm_pd_cdts <= 12'b0;
    else
        xadm_pd_cdts <= i_xadm_pd_cdts;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        xadm_ph_cdts <= 8'b0;
    else
        xadm_ph_cdts <= i_xadm_ph_cdts;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        axis_slave2_vld_ff <= 1'b0;
    else
        axis_slave2_vld_ff <= axis_slave2_vld;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        mwr_last_ff <= 1'b0;
    else
        mwr_last_ff <= mwr_fifo_out[128];
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        mwr_fifo_out_rdy_ff <= 1'b0;
    else
        mwr_fifo_out_rdy_ff <= mwr_fifo_out_rdy;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        mwr_length <= 10'b0;
    else if((axis_slave2_vld & ~axis_slave2_vld_ff) || (mwr_last_ff & axis_slave2_vld & mwr_fifo_out_rdy_ff))
        mwr_length <= mwr_fifo_out[9:0];
end


//assign mwr_tx_vld = ({i_xadm_pd_cdts,2'b0} >= {4'b0,mwr_length}) ? (|i_xadm_ph_cdts & axis_slave1_vld): 1'b0 ;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        mwr_tx_vld <= 1'b0;
    else if(mwr_fifo_out[128] & mwr_fifo_out_rdy)
        mwr_tx_vld <= 1'b0;
    else
        mwr_tx_vld <= ({i_xadm_pd_cdts,2'b0} >= {4'b0,mwr_length}) && (|i_xadm_ph_cdts & axis_slave2_vld);
end

//tx fsm
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
            if(cpld_tx_vld)
                next_state = CPLD_TX;
            else if(mwr_tx_vld)
                next_state = MWR_TX;
            else if(mrd_tx_vld)
                next_state = MRD_TX;
            else
                next_state = IDLE;
        end
        CPLD_TX:
        begin
            if(cpld_tx_vld)
                next_state = state;
            else if(mwr_tx_vld)
                next_state = MWR_TX;
            else if(mrd_tx_vld)
                next_state = MRD_TX;
            else
                next_state = IDLE;
        end
        MWR_TX:
        begin
            if(mwr_tx_vld)
                next_state = state;
            else if(cpld_tx_vld)
                next_state = CPLD_TX;
            else if(mrd_tx_vld)
                next_state = MRD_TX;
            else
                next_state = IDLE;
        end
        MRD_TX:
        begin
            if(mrd_tx_vld)
                next_state = state;
            else if(cpld_tx_vld)
                next_state = CPLD_TX;
            else if(mwr_tx_vld)
                next_state = MWR_TX;
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
        //cpld_tx_rdy <= 1'b0;
        //mwr_tx_rdy  <= 1'b0;
        //mrd_tx_rdy  <= 1'b0;
        axis_slave  <= 131'b0;
    end
    else if(i_pcie_axis_slave_trdy)
    begin
        case(state)
        IDLE:
        begin
            //cpld_tx_rdy <= 1'b0;
            //mwr_tx_rdy  <= 1'b0;
            //mrd_tx_rdy  <= 1'b0;
            axis_slave  <= 131'b0;
        end
        CPLD_TX:
        begin
            //cpld_tx_rdy <= 1'b1;
            //mwr_tx_rdy  <= 1'b0;
            //mrd_tx_rdy  <= 1'b0;
            axis_slave  <= (cpld_fifo_out_rdy & axis_slave0_vld) ? cpld_fifo_out : 131'b0;
        end
        MWR_TX:
        begin
            //cpld_tx_rdy <= 1'b0;
            //mwr_tx_rdy  <= 1'b1;
            //mrd_tx_rdy  <= 1'b0;
            axis_slave  <= (mwr_fifo_out_rdy & axis_slave2_vld) ? mwr_fifo_out : 131'b0;
        end
        MRD_TX:
        begin
            //cpld_tx_rdy <= 1'b0;
            //mwr_tx_rdy  <= 1'b0;
            //mrd_tx_rdy  <= 1'b1;
            axis_slave  <= (mrd_fifo_out_rdy & axis_slave1_vld) ? mrd_fifo_out : 131'b0;
        end
        default:
        begin
            //cpld_tx_rdy <= 1'b0;
            //mwr_tx_rdy  <= 1'b0;
            //mrd_tx_rdy  <= 1'b0;
            axis_slave  <= 131'b0;
        end
        endcase
    end
end

assign cpld_tx_rdy = state == CPLD_TX ;
assign mwr_tx_rdy  = state == MWR_TX ;
assign mrd_tx_rdy  = state == MRD_TX ;


assign o_pcie_axis_slave_tdata = axis_slave[127:0];
assign o_pcie_axis_slave_tlast = axis_slave[128];
assign o_pcie_axis_slave_tuser = axis_slave[129];
assign o_pcie_axis_slave_tvld  = axis_slave[130];

endmodule