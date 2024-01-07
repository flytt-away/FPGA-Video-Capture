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
// Filename:ipsl_pcie_dma_rx_cpld_wr_ctrl.v
//////////////////////////////////////////////////////////////////////////////
module ipsl_pcie_dma_rx_cpld_wr_ctrl #(
    parameter                           ADDR_WIDTH = 4'd9
)(
    input                               clk                     ,   //gen1:62.5MHz,gen2:125MHz
    input                               rst_n                   ,
    input           [2:0]               i_cfg_max_rd_req_size   ,
    //**********************************************************************
    input                               i_cpld_wr_start         ,
    input           [9:0]               i_cpld_length           ,
    input           [6:0]               i_cpld_low_addr         ,
    input           [11:0]              i_cpld_byte_cnt         ,
    input           [127:0]             i_cpld_data             ,
    input           [3:0]               i_cpld_dw_vld           ,
    input           [7:0]               i_cpld_tag              ,
    input           [1:0]               i_bar_hit               ,
    input                               i_multicpld_flag        ,
    //**********************************************************************
    //ram write control
    output  wire                        o_cpld_wr_en            ,
    output  wire    [ADDR_WIDTH-1:0]    o_cpld_wr_addr          ,
    output  wire    [127:0]             o_cpld_wr_data          ,
    output  wire    [15:0]              o_cpld_wr_be            ,
    output  wire    [1:0]               o_cpld_wr_bar_hit
);

reg                 wr_start_ff;
wire                rx_start;

wire                last_dw;

wire    [1:0]       last_dw_byte_num;
reg     [3:0]       first_dw_be;
reg     [3:0]       last_dw_be;
wire    [7:0]       cpld_dwbe;

wire    [63:0]      cpld_addr; //128byte
reg     [9:0]       tag_addr;
reg     [9:0]       tag_addr_next;
//
wire    [5:0]       cpld_tag_use;
reg     [5:0]       cpld_tag_use_ff;

reg                 addr_ram_wr_en;

wire    [9:0]       multicpld_addr;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        wr_start_ff <= 1'b0;
    else
        wr_start_ff <=  i_cpld_wr_start;
end

assign rx_start = i_cpld_wr_start & ~wr_start_ff;
assign last_dw  = ~i_cpld_wr_start & wr_start_ff;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        addr_ram_wr_en <= 1'b0;
    else
        addr_ram_wr_en <= rx_start;
end

//calculating dwbe from byte count and lower address
always@(*)
begin
    case(i_cpld_low_addr[1:0])
        2'd0: first_dw_be = 4'b1111;
        2'd1: first_dw_be = 4'b1110;
        2'd2: first_dw_be = 4'b1100;
        2'd3: first_dw_be = 4'b1000;
        default: first_dw_be = 4'hf;
    endcase
end

assign last_dw_byte_num = i_cpld_byte_cnt[1:0] + i_cpld_low_addr[1:0];

always@(*)
begin
    case(last_dw_byte_num)
        2'd0: last_dw_be = 4'b1111;
        2'd1: last_dw_be = 4'b0001;
        2'd2: last_dw_be = 4'b0011;
        2'd3: last_dw_be = 4'b0111;
        default: last_dw_be = 4'hf;
    endcase
end

assign cpld_dwbe = {last_dw_be,first_dw_be};

//************************************gen write address*************************************
assign cpld_tag_use  = i_cpld_tag[5:0]; //64 tag use

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cpld_tag_use_ff <= 6'b0;
    else
        cpld_tag_use_ff <= cpld_tag_use; //128byte
end

//save multicpld address pointer
ipm_distributed_sdpram_v1_2
    #(
    .ADDR_WIDTH (6                  ),  //address width   range:4-10
    .DATA_WIDTH (10                 ),  //data width      range:1-256
    .RST_TYPE   ("ASYNC"            ),  //reset type   "ASYNC" "SYNC"
    .OUT_REG    (1                  ),  //output options :non_register(0)  register(1)
    .INIT_FILE  ("NONE"             ),  //legal value:"NONE" or "initial file name"
    .FILE_FORMAT("BIN"              )   //initial data format : "BIN" or "HEX"
     )
    u_ipm_distributed_sdpram_v1_2
     (
    .wr_data    (  tag_addr_next    ),
    .wr_addr    (  cpld_tag_use_ff  ),
    .rd_addr    (  cpld_tag_use     ),
    .wr_clk     (  clk              ),
    .rd_clk     (  clk              ),
    .wr_en      (  addr_ram_wr_en   ),
    .rst        (  ~rst_n           ),
    .rd_data    (  multicpld_addr   )
     );

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tag_addr <= 10'b0;
    else if(last_dw)
        tag_addr <= multicpld_addr; //128byte
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tag_addr_next <= 10'b0;
    else if(rx_start)
        tag_addr_next <= i_multicpld_flag ? tag_addr + {i_cpld_length[7:0],2'b0} : 10'b0; //128byte
end

assign cpld_addr = (i_cfg_max_rd_req_size == 3'd0) ? {51'b0,{cpld_tag_use_ff,tag_addr[6:0]}} :  //128byte
                   (i_cfg_max_rd_req_size == 3'd1) ? {50'b0,{cpld_tag_use_ff,tag_addr[7:0]}} :  //256byte
                   (i_cfg_max_rd_req_size == 3'd2) ? {49'b0,{cpld_tag_use_ff,tag_addr[8:0]}} :  //512byte
                   (i_cfg_max_rd_req_size == 3'd3) ? {48'b0,{cpld_tag_use_ff,tag_addr[9:0]}} :  //1024byte
                                                     {51'b0,{cpld_tag_use_ff,tag_addr[6:0]}} ;

//******************************************************************************************
ipsl_pcie_dma_wr_ctrl #(
    .ADDR_WIDTH         (ADDR_WIDTH         )
)
ipsl_pcie_dma_cpld_wr_ctrl
(
    .clk                (clk                ),  //gen1:62.5MHz,gen2:125MHz
    .rst_n              (rst_n              ),

    //**********************************************************************
    .i_wr_start         (i_cpld_wr_start    ),
    .i_length           (i_cpld_length      ),
    .i_dwbe             (cpld_dwbe          ),
    .i_data             (i_cpld_data        ),
    .i_dw_vld           (i_cpld_dw_vld      ),
    .i_addr             (cpld_addr          ),
    .i_bar_hit          (i_bar_hit          ),

    //**********************************************************************
    //ram write control
    .o_wr_en            (o_cpld_wr_en       ),
    .o_wr_addr          (o_cpld_wr_addr     ),
    .o_wr_data          (o_cpld_wr_data     ),
    .o_wr_be            (o_cpld_wr_be       ),
    .o_wr_bar_hit       (o_cpld_wr_bar_hit  )
);

endmodule