//******************************************************************
// Copyright (c) 2015 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
`timescale 1ns/1ps
module hsst_rst_wtchdg_v1_0 #(
    parameter ACTIVE_HIGH        = 0,  // 0 : active@low, 1 : active@high
    parameter WTCHDG_CNTR1_WIDTH = 10, //(2**(WTCHDG_CNTR1_WIDTH-1)) = 512
    parameter WTCHDG_CNTR2_WIDTH = 10  //watchdog time = (2**(WTCHDG_CNTR2_WIDTH-1))*(2**(WTCHDG_CNTR1_WIDTH-1)) = 256k;
                                       //watchdog reset length = (2**(WTCHDG_CNTR1_WIDTH-1))
)(
    input   wire                             clk,
    input   wire                             rst_n,
    input   wire                             wtchdg_clr,
    input   wire                             wtchdg_in,
    output  reg                              wtchdg_rst_n
);

wire                              wtchdg_in_mux;
reg     [WTCHDG_CNTR1_WIDTH-1:0]  cnt_1;
reg     [WTCHDG_CNTR2_WIDTH-1:0]  cnt_2;

assign wtchdg_in_mux = (ACTIVE_HIGH == 1'b1) ? ~wtchdg_in : wtchdg_in;

always@(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        cnt_1 <= {WTCHDG_CNTR1_WIDTH{1'b0}};
    end
    else if(cnt_1[WTCHDG_CNTR1_WIDTH-1] | wtchdg_in_mux | wtchdg_clr)
    begin
        cnt_1 <= {WTCHDG_CNTR1_WIDTH{1'b0}};
    end
    else
    begin
        cnt_1 <= cnt_1 + { {(WTCHDG_CNTR1_WIDTH-1){1'b0}}, 1'b1};
    end
end

always@(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        cnt_2 <= {WTCHDG_CNTR2_WIDTH{1'b0}};
    end
    else if(wtchdg_clr | wtchdg_in_mux | (cnt_2[WTCHDG_CNTR2_WIDTH-1] & cnt_2[0]) )
    begin
        cnt_2 <= {WTCHDG_CNTR2_WIDTH{1'b0}};
    end
    else if(cnt_1[WTCHDG_CNTR1_WIDTH-1])
    begin
        cnt_2 <= cnt_2 + { {(WTCHDG_CNTR2_WIDTH-1){1'b0}}, 1'b1};
    end
end

always@(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        wtchdg_rst_n <= 1'b1;
    end
    else if(cnt_2[WTCHDG_CNTR2_WIDTH-1])
    begin
        wtchdg_rst_n <= 1'b0;
    end
    else
    begin
        wtchdg_rst_n <= 1'b1;
    end
end

endmodule
