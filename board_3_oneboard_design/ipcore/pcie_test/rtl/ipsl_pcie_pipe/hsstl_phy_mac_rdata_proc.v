//******************************************************************
// Copyright (c) 2015 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//******************************************************************
module hsstl_phy_mac_rdata_proc #(
parameter EN_CONTI_SKP_REPLACE = 1'b0
)(
input pclk,
input rst_n,
input [46:0] P_RDATA,
input  rx_det_done,
input  lx_rxdct_out_d,

output reg [31:0] phy_mac_rxdata,
output reg [3:0] phy_mac_rxdatak,
output reg [2:0] phy_mac_rxstatus
); 
wire ctc_underflow;
localparam K30_7 = 8'hFE;
localparam K28_0 = 8'h1C;
localparam K28_5 = 8'hBC;
always @(posedge pclk or negedge rst_n)
begin
    if (!rst_n)
        phy_mac_rxstatus <= 3'b0;
    else if (rx_det_done)
        phy_mac_rxstatus <= {1'b0, {2{lx_rxdct_out_d}}};
    else begin
//*******************************************************************************************
        if (P_RDATA[9] | P_RDATA[20] | P_RDATA[31] | P_RDATA[42])
           phy_mac_rxstatus[2:0] <= 3'b100; //decode error
     //   else if (P_RDATA[8] | P_RDATA[19] | P_RDATA[30] | P_RDATA[41])
     //      phy_mac_rxstatus[2:0] <= 3'b111; //disparity error
      //  else if (P_RDATA[46:44] == 3'b011) //continuous skip del
      //     phy_mac_rxstatus[2:0] <= 3'b010;
        else if ((P_RDATA[46:44] == 3'b100) | (P_RDATA[46:44] == 3'b101)) //bridge / CTC over flow
           phy_mac_rxstatus[2:0] <= 3'b101;  //CTC buffer overflow
        else if  ((P_RDATA[46:44] == 3'b110) | (P_RDATA[46:44] == 3'b111))  //bridge under flow
           phy_mac_rxstatus[2:0] <= 3'b110;  //CTC buffer underflow
       else if (P_RDATA[8] | P_RDATA[19] | P_RDATA[30] | P_RDATA[41])
           phy_mac_rxstatus[2:0] <= 3'b111; //disparity error
        else
           phy_mac_rxstatus[2:0] <= P_RDATA[46:44];
     end
end
assign ctc_underflow = (P_RDATA[46:44] == 3'b111) | (P_RDATA[46:44] == 3'b110);
assign cond1_for_conti_skp_del = ~ (P_RDATA[9] | P_RDATA[20] | P_RDATA[31] | P_RDATA[42] | P_RDATA[8] | P_RDATA[19] | P_RDATA[30] | P_RDATA[41]); //no decoder/disparity errs
assign cond2_for_conti_skp_del = (P_RDATA[46:44] == 3'b011) & (EN_CONTI_SKP_REPLACE == 1'b1);
assign cond3_for_conti_skp_del =  ({P_RDATA[10], P_RDATA[7:0]  } ==  {1'b1, K28_5}) &
                                  ({P_RDATA[21], P_RDATA[18:11]} ==  {1'b1, K28_0}) &
                                  ({P_RDATA[32], P_RDATA[29:22]} ==  {1'b1, K28_0}) &
                                  ({P_RDATA[43], P_RDATA[40:33]} ==  {1'b1, K28_5});

assign all_match_conti_skp_del = cond1_for_conti_skp_del & cond2_for_conti_skp_del & cond3_for_conti_skp_del;

always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
    begin
        phy_mac_rxdatak[3 :0 ] <= 4'b0;
        phy_mac_rxdata[31 :0 ] <= 32'b0;
    end
    else
    begin     
        {phy_mac_rxdatak[3], phy_mac_rxdata[31:24]}          <= ( ctc_underflow | P_RDATA[42]) ? {1'b1, K30_7} : (all_match_conti_skp_del ? {1'b1, K28_0} : {P_RDATA[43], P_RDATA[40:33]});
        {phy_mac_rxdatak[2], phy_mac_rxdata[23:16]}          <= ( ctc_underflow | P_RDATA[31]) ? {1'b1, K30_7} : (all_match_conti_skp_del ? {1'b1, K28_5} : {P_RDATA[32], P_RDATA[29:22]});
        {phy_mac_rxdatak[1], phy_mac_rxdata[15:8] }          <= ( ctc_underflow | P_RDATA[20]) ? {1'b1, K30_7} : {P_RDATA[21], P_RDATA[18:11]};
        {phy_mac_rxdatak[0], phy_mac_rxdata[7:0]  }          <= ( ctc_underflow | P_RDATA[9] ) ? {1'b1, K30_7} : {P_RDATA[10], P_RDATA[7:0]  };
    end
end
endmodule
