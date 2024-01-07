module eth_img_rec
#(
parameter integer PIXEL_WIDTH = 32                                   ,
parameter integer VIDEO_LENGTH = 16'd960                             ,
parameter integer VIDEO_HIGTH  = 16'd540                             
)
(
input wire                         eth_rx_clk     ,
input wire                         rstn           ,
input wire [PIXEL_WIDTH - 1 : 0]   udp_date_rcev  /* synthesis PAP_MARK_DEBUG="1" */,
input wire                         udp_date_en    ,
output reg                         img_data_en    /* synthesis PAP_MARK_DEBUG="1" */,
output reg                         img_data_vs    /* synthesis PAP_MARK_DEBUG="1" */,
output reg [15 : 0]   img_data       /* synthesis PAP_MARK_DEBUG="1" */
 );
//~~~~~~~~~~~~~~~~~~~~~~~parameter~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
parameter ETH_RX_WAIT_HEAD_0 = 2'd0 ;//�ȴ�֡��ʼ��־λ
parameter ETH_RX_WAIT_HEAD_1 = 2'd1 ;//�ȴ��ֱ���
parameter ETH_RX_RECV_DATA   = 2'd2 ;//�ȴ����ݴ���
//parameter ETH_RX_END         = 2'b1000 ;
//~~~~~~~~~~~~~~~~~~~~~~~reg~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reg [PIXEL_WIDTH - 1 : 0] udp_date_rcev_d0;
reg [3  :  0]             eth_rx_state/* synthesis PAP_MARK_DEBUG="1" */;
reg [3  :  0]             eth_rx_next_state/* synthesis PAP_MARK_DEBUG="1" */;
reg                       skip_en /* synthesis PAP_MARK_DEBUG="1" */;
reg                       error_en/* synthesis PAP_MARK_DEBUG="1" */;
reg                       img_recv_start/* synthesis PAP_MARK_DEBUG="1" */;
reg [20 :  0]             img_data_recv_cnt/* synthesis PAP_MARK_DEBUG="1" */;
reg                       img_data_en_cnt/* synthesis PAP_MARK_DEBUG="1" */;
//~~~~~~~~~~~~~~~~~~~~~~~wire~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~assign~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~always~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//always @(posedge eth_rx_clk ) begin
//    if(!rstn) begin
//        udp_date_rcev_d0 <= 'd0;
//    end
//    else if(udp_date_rcev) begin
//        udp_date_rcev_d0 <= udp_date_rcev;
//    end
//end

always @(posedge eth_rx_clk ) begin
    if(!rstn) begin
        skip_en  <= 'd0;
        error_en <= 'd0;
        img_data <= 'd0;
        img_data_vs <= 'd0;
        img_recv_start <= 'd0;
        img_data_recv_cnt <= 'd0;
        eth_rx_state <= ETH_RX_WAIT_HEAD_0;
        img_data_en_cnt <= 'd0;
    end
    else begin
        //skip_en <= 'd0;
        //error_en <= 'd0;
        img_data_en <= 'd0;
        case(eth_rx_state)
            ETH_RX_WAIT_HEAD_0: begin
                img_data_recv_cnt <= 'd0;
                img_data_en_cnt <= 'd0;
                if(udp_date_en && udp_date_rcev == {32'hf0_5a_a5_0f}) begin//���յ�֡ͷ������ȴ�״̬2
                    eth_rx_state <= ETH_RX_WAIT_HEAD_1;
                    img_data_vs <= 'd1;//���յ�֡ͷʱ������vs�ź��Թ�����ģ�鸴λ
                end
                else begin
                    eth_rx_state <= ETH_RX_WAIT_HEAD_0;
                end
            end
            ETH_RX_WAIT_HEAD_1: begin
                if(udp_date_en && udp_date_rcev == {16'd960,16'd540}) begin//���յ��ֱ�����Ϣ�������������״̬
                    eth_rx_state <= ETH_RX_RECV_DATA;
                    img_data_vs <= 'd0;
                end
                else if(udp_date_en && udp_date_rcev != {16'd960,16'd540})begin//����ڶ������ݲ��Ƿֱ���������error�����µȴ�֡ͷ
                    eth_rx_state <= ETH_RX_WAIT_HEAD_0;
                    img_data_vs <= 'd0;
                end
                else begin
                    eth_rx_state <= ETH_RX_WAIT_HEAD_1;
                end
            end
            ETH_RX_RECV_DATA: begin
                if(udp_date_en) begin
                    img_recv_start <= 'd1;
                end
                if(udp_date_en || img_recv_start) begin
                    img_data_recv_cnt <= img_data_recv_cnt + 'd1;
                    if(img_data_en_cnt == 'd0) begin//��һ�½�udp���ݸ�16λת��Ϊ32bits��ʽrgb565
                        //img_data[31 :  27] <= udp_date_rcev[31 : 27];
                        //img_data[21 :  16] <= udp_date_rcev[26 : 21];
                        //img_data[11 :   7] <= udp_date_rcev[20 : 16];
                        img_data[15 : 11] <= udp_date_rcev[31 : 27];
                        img_data[10 :  5] <= udp_date_rcev[26 : 21];
                        img_data[4  :  0] <= udp_date_rcev[20 : 16];
                        img_data_en <= 'd1;
                        img_data_en_cnt <= 'd1;
                    end
                    else if(img_data_en_cnt == 'd1) begin//�ڶ��½�udp���ݵ�16λת��Ϊ32bits��ʽrgb565
                        //img_data[31 :  27] <= udp_date_rcev[15 : 11];
                        //img_data[21 :  16] <= udp_date_rcev[10 :  5];
                        //img_data[11 :   7] <= udp_date_rcev[4  :  0];
                        img_data[15 : 11] <= udp_date_rcev[15 : 11];
                        img_data[10 :  5] <= udp_date_rcev[10 :  5];
                        img_data[4  :  0] <= udp_date_rcev[4  :  0];
                        img_data_en <= 'd1;
                        img_recv_start <= 'd0;
                        img_data_en_cnt <= 'd0;
                    end
                end
                if(img_data_recv_cnt == 960*540) begin//���յ�960*540�����غ����һ֡����
                    eth_rx_state <= ETH_RX_WAIT_HEAD_0;
                end
            end
        endcase
    end
end


//always @(posedge eth_rx_clk) begin
//    if(!rstn) begin
//        eth_rx_cur_state <= ETH_RX_WAIT_HEAD_0;  
//    end
//    else begin
//        eth_rx_cur_state <= eth_rx_next_state;
//    end
//end

//always @(*) begin
//    case(eth_rx_cur_state)
//        ETH_RX_WAIT_HEAD_0: begin
//            if(udp_date_en && udp_date_rcev == {32'hf0_5a_a5_0f}) begin
//                eth_rx_next_state = ETH_RX_WAIT_HEAD_1;
//            end            
//            else begin
//                eth_rx_next_state = ETH_RX_WAIT_HEAD_0;          
//            end        
//        end
//        ETH_RX_WAIT_HEAD_1: begin
//            if(udp_date_en && udp_date_rcev == 32'h03c0_021c) begin
//                eth_rx_next_state = ETH_RX_RECV_DATA;
//            end
//            else if(udp_date_en && udp_date_rcev != {16'd960,16'd540}) begin
//                eth_rx_next_state = ETH_RX_WAIT_HEAD_0; 
//            end   
//            else begin
//                eth_rx_next_state = ETH_RX_WAIT_HEAD_1; 
//            end   
//        end
//        ETH_RX_RECV_DATA: begin
//            if(img_data_recv_cnt == 'd518400) begin
//                eth_rx_next_state = ETH_RX_WAIT_HEAD_0;
//            end  
//            else begin
//                eth_rx_next_state = ETH_RX_RECV_DATA;
//            end
//        end
//        default: begin
//            eth_rx_next_state = ETH_RX_WAIT_HEAD_0;
//        end
//    endcase
//end

endmodule