//****************************************Copyright (c)***********************************//
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com 
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡFPGA & STM32���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           crc32_d8
// Last modified Date:  2019/8/21 8:37:49
// Last Version:        V1.0
// Descriptions:        CRC32У��ģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2018/3/12 8:37:49
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module crc32_d8(
    input                 clk     ,  //ʱ���ź�
    input                 rst_n   ,  //��λ�źţ��͵�ƽ��Ч
    input         [7:0]   data    ,  //�����У��8λ����
    input                 crc_en  ,  //crcʹ�ܣ���ʼУ���־
    input                 crc_clr ,  //crc���ݸ�λ�ź�            
    output   reg  [31:0]  crc_data,  //CRCУ������
    output        [31:0]  crc_next   //CRC�´�У���������
    );

//*****************************************************
//**                    main code
//*****************************************************

//�����У��8λ����,��Ҫ�Ƚ��ߵ�λ����
wire    [7:0]  data_t;

assign data_t = {data[0],data[1],data[2],data[3],data[4],data[5],data[6],data[7]};

//CRC32�����ɶ���ʽΪ��G(x)= x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 
//+ x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x^1 + 1

assign crc_next[0] = crc_data[24] ^ crc_data[30] ^ data_t[0] ^ data_t[6];
assign crc_next[1] = crc_data[24] ^ crc_data[25] ^ crc_data[30] ^ crc_data[31] 
                     ^ data_t[0] ^ data_t[1] ^ data_t[6] ^ data_t[7];
assign crc_next[2] = crc_data[24] ^ crc_data[25] ^ crc_data[26] ^ crc_data[30] 
                     ^ crc_data[31] ^ data_t[0] ^ data_t[1] ^ data_t[2] ^ data_t[6] 
                     ^ data_t[7];
assign crc_next[3] = crc_data[25] ^ crc_data[26] ^ crc_data[27] ^ crc_data[31] 
                     ^ data_t[1] ^ data_t[2] ^ data_t[3] ^ data_t[7];
assign crc_next[4] = crc_data[24] ^ crc_data[26] ^ crc_data[27] ^ crc_data[28] 
                     ^ crc_data[30] ^ data_t[0] ^ data_t[2] ^ data_t[3] ^ data_t[4] 
                     ^ data_t[6];
assign crc_next[5] = crc_data[24] ^ crc_data[25] ^ crc_data[27] ^ crc_data[28] 
                     ^ crc_data[29] ^ crc_data[30] ^ crc_data[31] ^ data_t[0] 
                     ^ data_t[1] ^ data_t[3] ^ data_t[4] ^ data_t[5] ^ data_t[6] 
                     ^ data_t[7];
assign crc_next[6] = crc_data[25] ^ crc_data[26] ^ crc_data[28] ^ crc_data[29] 
                     ^ crc_data[30] ^ crc_data[31] ^ data_t[1] ^ data_t[2] ^ data_t[4] 
                     ^ data_t[5] ^ data_t[6] ^ data_t[7];
assign crc_next[7] = crc_data[24] ^ crc_data[26] ^ crc_data[27] ^ crc_data[29] 
                     ^ crc_data[31] ^ data_t[0] ^ data_t[2] ^ data_t[3] ^ data_t[5] 
                     ^ data_t[7];
assign crc_next[8] = crc_data[0] ^ crc_data[24] ^ crc_data[25] ^ crc_data[27] 
                     ^ crc_data[28] ^ data_t[0] ^ data_t[1] ^ data_t[3] ^ data_t[4];
assign crc_next[9] = crc_data[1] ^ crc_data[25] ^ crc_data[26] ^ crc_data[28] 
                     ^ crc_data[29] ^ data_t[1] ^ data_t[2] ^ data_t[4] ^ data_t[5];
assign crc_next[10] = crc_data[2] ^ crc_data[24] ^ crc_data[26] ^ crc_data[27] 
                     ^ crc_data[29] ^ data_t[0] ^ data_t[2] ^ data_t[3] ^ data_t[5];
assign crc_next[11] = crc_data[3] ^ crc_data[24] ^ crc_data[25] ^ crc_data[27] 
                     ^ crc_data[28] ^ data_t[0] ^ data_t[1] ^ data_t[3] ^ data_t[4];
assign crc_next[12] = crc_data[4] ^ crc_data[24] ^ crc_data[25] ^ crc_data[26] 
                     ^ crc_data[28] ^ crc_data[29] ^ crc_data[30] ^ data_t[0] 
                     ^ data_t[1] ^ data_t[2] ^ data_t[4] ^ data_t[5] ^ data_t[6];
assign crc_next[13] = crc_data[5] ^ crc_data[25] ^ crc_data[26] ^ crc_data[27] 
                     ^ crc_data[29] ^ crc_data[30] ^ crc_data[31] ^ data_t[1] 
                     ^ data_t[2] ^ data_t[3] ^ data_t[5] ^ data_t[6] ^ data_t[7];
assign crc_next[14] = crc_data[6] ^ crc_data[26] ^ crc_data[27] ^ crc_data[28] 
                     ^ crc_data[30] ^ crc_data[31] ^ data_t[2] ^ data_t[3] ^ data_t[4]
                     ^ data_t[6] ^ data_t[7];
assign crc_next[15] =  crc_data[7] ^ crc_data[27] ^ crc_data[28] ^ crc_data[29]
                     ^ crc_data[31] ^ data_t[3] ^ data_t[4] ^ data_t[5] ^ data_t[7];
assign crc_next[16] = crc_data[8] ^ crc_data[24] ^ crc_data[28] ^ crc_data[29] 
                     ^ data_t[0] ^ data_t[4] ^ data_t[5];
assign crc_next[17] = crc_data[9] ^ crc_data[25] ^ crc_data[29] ^ crc_data[30] 
                     ^ data_t[1] ^ data_t[5] ^ data_t[6];
assign crc_next[18] = crc_data[10] ^ crc_data[26] ^ crc_data[30] ^ crc_data[31] 
                     ^ data_t[2] ^ data_t[6] ^ data_t[7];
assign crc_next[19] = crc_data[11] ^ crc_data[27] ^ crc_data[31] ^ data_t[3] ^ data_t[7];
assign crc_next[20] = crc_data[12] ^ crc_data[28] ^ data_t[4];
assign crc_next[21] = crc_data[13] ^ crc_data[29] ^ data_t[5];
assign crc_next[22] = crc_data[14] ^ crc_data[24] ^ data_t[0];
assign crc_next[23] = crc_data[15] ^ crc_data[24] ^ crc_data[25] ^ crc_data[30] 
                      ^ data_t[0] ^ data_t[1] ^ data_t[6];
assign crc_next[24] = crc_data[16] ^ crc_data[25] ^ crc_data[26] ^ crc_data[31] 
                      ^ data_t[1] ^ data_t[2] ^ data_t[7];
assign crc_next[25] = crc_data[17] ^ crc_data[26] ^ crc_data[27] ^ data_t[2] ^ data_t[3];
assign crc_next[26] = crc_data[18] ^ crc_data[24] ^ crc_data[27] ^ crc_data[28] 
                      ^ crc_data[30] ^ data_t[0] ^ data_t[3] ^ data_t[4] ^ data_t[6];
assign crc_next[27] = crc_data[19] ^ crc_data[25] ^ crc_data[28] ^ crc_data[29] 
                      ^ crc_data[31] ^ data_t[1] ^ data_t[4] ^ data_t[5] ^ data_t[7];
assign crc_next[28] = crc_data[20] ^ crc_data[26] ^ crc_data[29] ^ crc_data[30] 
                      ^ data_t[2] ^ data_t[5] ^ data_t[6];
assign crc_next[29] = crc_data[21] ^ crc_data[27] ^ crc_data[30] ^ crc_data[31] 
                      ^ data_t[3] ^ data_t[6] ^ data_t[7];
assign crc_next[30] = crc_data[22] ^ crc_data[28] ^ crc_data[31] ^ data_t[4] ^ data_t[7];
assign crc_next[31] = crc_data[23] ^ crc_data[29] ^ data_t[5];

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        crc_data <= 32'hff_ff_ff_ff;
    else if(crc_clr)                             //CRCУ��ֵ��λ
        crc_data <= 32'hff_ff_ff_ff;
    else if(crc_en)
        crc_data <= crc_next;
end

endmodule