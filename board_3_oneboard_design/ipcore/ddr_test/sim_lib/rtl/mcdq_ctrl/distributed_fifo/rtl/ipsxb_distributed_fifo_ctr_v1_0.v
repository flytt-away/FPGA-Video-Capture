//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
//
// Library:
// Filename:ipm_distributed_fifo_ctr_v1_0.v
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

module ipsxb_distributed_fifo_ctr_v1_0 #(

  parameter  DEPTH            = 9             ,           // write adn read address width 4 -- 10
  parameter  FIFO_TYPE        = "ASYNC_FIFO"  ,           // ASYN_FIFO or SYN_FIFO
  parameter  ALMOST_FULL_NUM  = 4             ,
  parameter  ALMOST_EMPTY_NUM = 4
)
(
  input  wire                           wr_clk          ,           //write clock
  input  wire                           w_en            ,           //write enable 1 active
  output wire [DEPTH-1 : 0]             wr_addr         ,           //write address
  input  wire                           wrst            ,           //write reset
  output wire                           wfull           ,           //write full flag 1 active
  output wire                           almost_full     ,           //output write almost full
  output reg  [DEPTH : 0]               wr_water_level  ,           //output write water level

  input  wire                           rd_clk          ,           //read clock
  input  wire                           r_en            ,           //read enable 1 active
  output wire [DEPTH-1 : 0]             rd_addr         ,           //read address
  input  wire                           rrst            ,           //read reset
  output wire                           rempty          ,           //read empty  1 active
  output wire                           almost_empty    ,           //output read almost empty
  output reg  [DEPTH : 0]               rd_water_level              //output read water level
);
//**************************************************************************************************************
//declare inner variables
  //write address operation variables
reg [DEPTH : 0]  wptr               ;          //write pointer
reg [DEPTH : 0]  wrptr1             ;          //1st read-domain to write-domain synchronizer
reg [DEPTH : 0]  wrptr2             ;          //2nd read-domain to write-domain synchronizer
reg [DEPTH : 0]  wbin               ;          //write current binary  pointer
reg [DEPTH : 0]  wbnext             ;          //write next binary  pointer
reg [DEPTH : 0]  wgnext             ;          //write next gray pointer
reg              waddr_msb          ;          //the MSB of waddr
wire             wgnext_2ndmsb      ;          //the second MSB of wgnext
wire             wrptr2_2ndmsb      ;          //the second MSB of wrptr2

//read address operation variables
reg [DEPTH : 0]  rptr               ;          //read pointer
reg [DEPTH : 0]  rwptr1             ;          //1st  write-domain to read-domain synchronizer
reg [DEPTH : 0]  rwptr2             ;          //2nd  write-domain to read-domain synchronizer
reg [DEPTH : 0]  rbin               ;          //read current binary  pointer
reg [DEPTH : 0]  rbnext             ;          //read next binary  pointer
reg [DEPTH : 0]  rgnext             ;          //read next gray pointer
reg              raddr_msb          ;          //the MSB of raddr

reg [DEPTH : 0]  wrptr2_b           ;          //wrptr2 into binary
reg [DEPTH : 0]  rwptr2_b           ;          //rwptr2 into binary
//**************************************************************************************************************
reg              asyn_wfull         ;
reg              asyn_almost_full   ;
reg              asyn_rempty        ;
reg              asyn_almost_empty  ;
reg              syn_wfull          ;
reg              syn_almost_full    ;
reg              syn_rempty         ;
reg              syn_almost_empty   ;
//main code
//**************************************************************************************************************
generate
if(FIFO_TYPE == "ASYNC_FIFO")
begin:ASYN_CTRL
//write gray pointer generate
    integer  i;
    always@(*)
    begin
        for(i = 0;i <= DEPTH;i = i+1 )  //gray to binary converter
            wbin[i] = ^(wptr >> i);
    end
    always@(*)
    begin
        if(!wfull)
            wbnext = wbin + w_en;
        else
            wbnext = wbin;
    end
    always@(*)
    begin
        wgnext = (wbnext >> 1) ^ wbnext;          //binary to gray converter
    end
    always@( posedge wr_clk or posedge wrst )
    begin
        if(wrst)
        begin
            wptr <=0;
            waddr_msb <=0;
        end
        else
        begin
           wptr <= wgnext;
           waddr_msb <= wgnext[DEPTH] ^ wgnext[DEPTH-1];
        end
    end
    //read domain to write domain synchronizer
    always@( posedge wr_clk or posedge wrst )
    begin
        if(wrst)
            {wrptr2,wrptr1} <= 0;
        else
            {wrptr2,wrptr1} <= {wrptr1,rptr};
    end

    always@(*)
    begin
        for(i = 0;i <= DEPTH;i = i+1 )  //gray to binary converter
            wrptr2_b[i] = ^(wrptr2 >> i);
    end

    //generate fifo write full flag
    assign  wgnext_2ndmsb = wgnext[DEPTH] ^ wgnext[DEPTH-1];
    assign  wrptr2_2ndmsb = wrptr2[DEPTH] ^ wrptr2[DEPTH-1];
    //**************************************************************************************************************
    //read gray pointer generate
    integer  j;
    always@(*)
    begin
        for(j = 0;j <= DEPTH;j = j+1 )  //gray to binary converter
            rbin[j] = ^(rptr >> j);
    end

    always@(*)
    begin
        if(!rempty)
            rbnext = rbin + r_en;
        else
            rbnext = rbin;
        rgnext = (rbnext >> 1) ^ rbnext;          //binary to gray converter
    end

    always@( posedge rd_clk or posedge rrst )
    begin
        if(rrst)
        begin
            rptr <=0;
            raddr_msb <=0;
        end
        else
        begin
            rptr <= rgnext;
            raddr_msb <= rgnext[DEPTH] ^ rgnext[DEPTH-1];
        end
    end
    //read domain to write domain synchronizer
    always@(posedge rd_clk or posedge rrst)
    begin
        if(rrst)
            {rwptr2,rwptr1} <= 0;
        else
            {rwptr2,rwptr1} <= {rwptr1,wptr};
    end
    always@(*)
    begin
        for(i = 0;i <= DEPTH;i = i+1 )  //gray to binary converter
            rwptr2_b[i] = ^(rwptr2 >> i);
    end
    //generate asyn_fifo write full flag
    always@(posedge wr_clk or posedge wrst)
    begin
        if(wrst)
            asyn_wfull <= 1'b0;
        else
            asyn_wfull <= ( (wgnext[DEPTH] != wrptr2[DEPTH]) &&
	                      (wgnext_2ndmsb == wrptr2_2ndmsb) &&
	                      (wgnext[DEPTH-2:0] == wrptr2[DEPTH-2:0]) );
    end
	//generate asyn_fifo write almost full flag
	always@(posedge wr_clk or posedge wrst)
	begin
	    if(wrst)
	        asyn_almost_full <= 1'b0;
	    else if (wbnext[DEPTH:0] < wrptr2_b[DEPTH:0])
	        asyn_almost_full <= ({1'b1,wbnext[DEPTH:0]} - {1'b0,wrptr2_b[DEPTH:0]} >= ALMOST_FULL_NUM );
	    else
	        asyn_almost_full <= ((wbnext[DEPTH:0] - wrptr2_b[DEPTH:0]) >= ALMOST_FULL_NUM );
	end
	//asyn_fifo read empty flag generate
	always@(posedge rd_clk or posedge rrst)
	begin
	    if(rrst)
	        asyn_rempty <= 1'b1;
	    else
	        asyn_rempty <= (rgnext == rwptr2);
	end
	//generate asyn_fifo read almost empty flag
	always@(posedge rd_clk or posedge rrst)
	begin
	    if(rrst)
	        asyn_almost_empty <= 1'b1;
	    else if(rwptr2_b[DEPTH:0] < rbnext[DEPTH:0])
	        asyn_almost_empty <= ({1'b1,rwptr2_b[DEPTH:0]} - {1'b0,rbnext[DEPTH:0]} <= ALMOST_EMPTY_NUM );
	    else
	        asyn_almost_empty <= ((rwptr2_b[DEPTH:0] - rbnext[DEPTH:0]) <= ALMOST_EMPTY_NUM );
	end
end
else
begin:SYN_CTRL
    //write operation
    always@(*)
    begin
        if(!wfull)
            wbnext = wptr + w_en;
        else
            wbnext = wptr;
    end
    always@(*)
    begin
        wgnext =  wbnext;    // syn fifo
    end
    always@( posedge wr_clk or posedge wrst )
    begin
        if(wrst)
        begin
            wptr <=0;
            waddr_msb <=0;
        end
        else
        begin
            wptr <= wgnext;
            waddr_msb <= wgnext[DEPTH-1];
        end
    end
    always@(*)
    begin
        wrptr2 = rptr;    // syn fifo
    end
    always@(*)
    begin
        wrptr2_b = rptr;    // syn fifo
    end
    //generate fifo write full flag
    assign  wgnext_2ndmsb = wgnext[DEPTH-1];
    assign  wrptr2_2ndmsb = wrptr2[DEPTH-1];
    //**************************************************************************************************************
    //read operation
    always@(*)
    begin
        if(!rempty)
            rbnext = rptr + r_en;
        else
            rbnext = rptr;
    end
    always@(*)
    begin
        rgnext = rbnext;
    end
    always@( posedge rd_clk or posedge rrst )
    begin
        if(rrst)
        begin
            rptr <=0;
            raddr_msb <=0;
        end
        else
        begin
            rptr <= rgnext;
            raddr_msb <= rgnext[DEPTH-1];
        end
    end
    always@(*)
    begin
        rwptr2   =  wptr;    //syn fifo
    end
    always@(*)
    begin
        rwptr2_b =  wptr;    //syn fifo
    end
    //generate syn_fifo write full flag
    always@(posedge wr_clk or posedge wrst)
    begin
        if(wrst)
            syn_wfull <= 1'b0;
        else
            syn_wfull <= ((wgnext[DEPTH] != rgnext[DEPTH]) &&
	                     (wgnext[DEPTH-1:0] == rgnext[DEPTH-1:0]) );
    end
	//generate syn_fifo write almost full flag
	always@(posedge wr_clk or posedge wrst)
	begin
	    if(wrst)
	        syn_almost_full <= 1'b0;
	    else if (wbnext[DEPTH:0] < rbnext[DEPTH:0])
	        syn_almost_full <= ({1'b1,wbnext[DEPTH:0]} - {1'b0,rbnext[DEPTH:0]} >= ALMOST_FULL_NUM );
	    else
	        syn_almost_full <= ((wbnext[DEPTH:0] - rbnext[DEPTH:0]) >= ALMOST_FULL_NUM );
	end
	//syn_fifo read empty flag generate
	always@(posedge rd_clk or posedge rrst)
	begin
	    if(rrst)
	        syn_rempty <= 1'b1;
	    else
	        syn_rempty <= (rgnext == wgnext);
	end
	//generate syn_fifo read almost empty flag
	always@(posedge rd_clk or posedge rrst)
	begin
	    if(rrst)
	        syn_almost_empty <= 1'b1;
	    else if (wbnext[DEPTH:0] < rbnext[DEPTH:0])
	        syn_almost_empty <= ({1'b1,wbnext[DEPTH:0]} - {1'b0,rbnext[DEPTH:0]} <= ALMOST_EMPTY_NUM );
	    else
	        syn_almost_empty <= ((wbnext[DEPTH:0] - rbnext[DEPTH:0]) <= ALMOST_EMPTY_NUM );
	end
end

endgenerate

//write  flex memory address generate
assign  wr_addr = {waddr_msb,wptr[DEPTH-2:0]};

//generate fifo write full flag
assign wfull = (FIFO_TYPE == "ASYNC_FIFO") ? asyn_wfull : syn_wfull;

//generate fifo write almost full flag
assign almost_full  = (FIFO_TYPE == "ASYNC_FIFO") ? asyn_almost_full : syn_almost_full;

//generate write water level flag
always@(posedge wr_clk or posedge wrst)
begin
    if(wrst)
        wr_water_level <= 'b0;
    else if (wbnext[DEPTH:0] < wrptr2_b[DEPTH:0])
        wr_water_level <= ({1'b1,wbnext[DEPTH:0]} - {1'b0,wrptr2_b[DEPTH:0]});
    else
        wr_water_level <= ( wbnext[DEPTH:0] - wrptr2_b[DEPTH:0] );
end

//read flex memory address generate
assign  rd_addr = {raddr_msb,rptr[DEPTH-2:0]};

//fifo read empty flag generate
assign rempty  = (FIFO_TYPE == "ASYNC_FIFO") ? asyn_rempty : syn_rempty;

//generate fifo read almost empty flag
assign almost_empty  = (FIFO_TYPE == "ASYNC_FIFO") ? asyn_almost_empty : syn_almost_empty;

//generate read water level flag
always@(posedge rd_clk or posedge rrst)
begin
    if(rrst)
        rd_water_level <= 'b0;
    else if (rwptr2_b[DEPTH:0] < rbnext[DEPTH:0])
        rd_water_level <= ({1'b1,rwptr2_b[DEPTH:0]} - {1'b0,rbnext[DEPTH:0]});
    else
        rd_water_level <= ( rwptr2_b[DEPTH:0] - rbnext[DEPTH:0] );
end




endmodule