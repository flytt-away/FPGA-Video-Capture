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
module ipsl_pcie_seio_intf_v1_0(
    input               pclk_div2   ,
    input               user_rst_n  ,

    input               sedo_in     ,
    input               sedo_en_in  ,
    output  wire        sedi        ,
    output  reg         sedi_ack
);

    reg     [1:0]   seio_state      ;
    reg     [1:0]   seio_nxt_state  ;
    reg             sedo_in_r       ;
    reg             sedo_in_2r      ;
    reg             sedo_en_r       ;
    reg             sedo_en_2r      ;

    localparam      SEIO_IDLE   = 2'b00;
    localparam      SEIO_BUSY   = 2'b01;
    localparam      SEIO_NACK   = 2'b10;

assign sedi = 1'b0;

//----------------PHASE1
always @(posedge pclk_div2  or negedge user_rst_n)
    if(!user_rst_n)
        seio_state  <= SEIO_IDLE;
    else
        seio_state  <= seio_nxt_state;

//----------------PHASE2
always@(*)
    case(seio_state)
        SEIO_IDLE:begin
            if(sedo_en_2r & sedo_in_r & ~sedo_in_2r)         //WR OP
                seio_nxt_state = SEIO_BUSY;
            else if(sedo_en_2r & ~sedo_in_r & sedo_in_2r)    //RD OP
                seio_nxt_state = SEIO_BUSY;
            else
                seio_nxt_state = SEIO_IDLE;
        end
        SEIO_BUSY:begin
            if(sedo_en_2r & ~sedo_en_r)         //falling edge of sedo_en
                seio_nxt_state = SEIO_NACK;
            else
                seio_nxt_state = SEIO_BUSY;
        end
        SEIO_NACK:begin
            if(sedi_ack)
                seio_nxt_state = SEIO_IDLE;
            else
                seio_nxt_state = SEIO_NACK;
        end
        default:seio_nxt_state = SEIO_IDLE;
    endcase

//------------------------------SEIO Logic
always @(posedge pclk_div2  or negedge user_rst_n)
    if(!user_rst_n)begin
        sedo_in_r   <= 1'b0;
        sedo_in_2r  <= 1'b0;
        sedo_en_r   <= 1'b0;
        sedo_en_2r  <= 1'b0;
    end
    else begin
        sedo_in_r   <= sedo_in;
        sedo_in_2r  <= sedo_in_r;
        sedo_en_r   <= sedo_en_in;
        sedo_en_2r  <= sedo_en_r;
    end

always @(posedge pclk_div2  or negedge user_rst_n)
    if(!user_rst_n)
        sedi_ack    <= 1'b0;
    else if(seio_state == SEIO_NACK)
        sedi_ack    <= ~sedi_ack;           //1 cycle pulse
    else
        sedi_ack    <= 1'b0;

endmodule
