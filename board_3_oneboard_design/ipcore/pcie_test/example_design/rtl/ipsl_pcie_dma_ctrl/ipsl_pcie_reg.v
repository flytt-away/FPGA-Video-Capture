//******************************************************************
// Copyright (c) 2020 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
module ipsl_pcie_reg #(
    parameter    SIG_WIDTH = 8
)(
    input                  clk,

    input       [SIG_WIDTH-1:0] sig,
    output reg  [SIG_WIDTH-1:0] sig_reg
);

always@(posedge clk)
begin
    sig_reg <= sig;
end
endmodule