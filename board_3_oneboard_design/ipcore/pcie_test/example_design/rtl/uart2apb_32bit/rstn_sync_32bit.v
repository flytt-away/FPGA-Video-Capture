module rstn_sync_32bit(
    input          clk,
    input          rst_n,
    output  wire    sync_rst_n
);

reg  rst_n_ff1;
reg  rst_n_ff2;

always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        rst_n_ff1 <= 1'b0;
        rst_n_ff2 <= 1'b0;
    end
    else
    begin
        rst_n_ff1 <= 1;
        rst_n_ff2 <= rst_n_ff1;
    end
end
    
assign sync_rst_n = rst_n_ff2;

endmodule
