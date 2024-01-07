module vesa_debug#(
parameter PIX_WIGHT = 16
)
(
input wire    pix_clk,
input wire    rstn,
input wire    vs,
input wire    de,
output reg [15 : 0]   vesa_data
);
reg de_d0;
reg de_d1;
wire de_pos;
wire de_neg;
assign de_pos_d0 = de && !de_d0;
assign de_neg = !de_d0 && de_d1;
always @(posedge pix_clk)begin
    if(!rstn||vs) begin
        vesa_data <= 16'hA500;
    end
    else if(de) begin
        vesa_data <= vesa_data + 'd1;
    end
    else if(de_neg) begin
        vesa_data <= 16'hA500;
    end
end
always @(posedge pix_clk)begin
    if(!rstn||vs) begin
        de_d0 <= 'd0;
    end
    else begin
        de_d0 <= de;
        de_d1 <= de_d0;
    end
end
endmodule