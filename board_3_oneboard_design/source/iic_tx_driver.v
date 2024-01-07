`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Myminieye
// Engineer: Nill
// 
// Create Date: 2020-03-09 17:54  
// Design Name:  
// Module Name:  iic_dri
// Project Name: 
// Target Devices: Gowin
// Tool Versions: 
// Description: 
//      
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
// Revision 0.02 - Modify by Nill
// Additional Comments:  修改IIC状态机，第二段为组合逻辑，赋值应使用“=”，将“=”替换“<= `UD”
//                       修改busy区间，由于iic_dri不能缓冲命令，应在接收一次触发后就进入busy状态，
//                                修改语句：if(start_en)       busy <= `UD 1'b1;   
//////////////////////////////////////////////////////////////////////////////////

`define UD #1

module iic_tx_driver #(
    parameter            CLK_FRE = 27'd50_000_000,  //system clock frequency
    parameter            IIC_FREQ = 20'd400_000,    //I2c clock frequency
    parameter            T_WR = 10'd5,              //I2c transmit delay ms
    parameter            ADDR_BYTE = 2'd1,          //I2C addr byte number
    parameter            LEN_WIDTH = 8'd3,          //I2C transmit byte width
    parameter            DATA_BYTE = 2'd1           //I2C data byte number
)(                       
    input                clk,
    input                rstn,
    input                pluse,                     //I2C transmit trigger
    input  [7:0]         device_id,                 //I2C divice id
    input                w_r,                       //I2C transmit direction 1:send  0:receive
    input  [LEN_WIDTH:0] byte_len,                  //I2C transmit data byte length of once trigger
                    
    input  [ADDR_BYTE*8 - 1:0]         addr,                      //I2C transmit addr
    input  [7:0]         data_in,                   //I2C send data
                         
    output reg           busy=0,                    //I2C bus status
    output reg           byte_over=0,               //I2C byte transmit over flag
                         
    output reg[7:0]      data_out,                  //I2C receive data
                         
    output               scl,
    input                sda_in,
    output   reg         sda_out=1'b1,
    output               sda_out_en
);

    localparam CLK_DIV = CLK_FRE/IIC_FREQ;  //计数器计数最大值，产生时钟用
    localparam ID_ADDR_BYTE = ADDR_BYTE + 1'b1;//地址加deviceID字节数
    localparam DATA_SET = CLK_DIV>>2;//输出data变化位置
    localparam T_WR_DELAY = T_WR*CLK_FRE/1000_000;

    //  iic clock time counter
    reg [20:0] fre_cnt;//=21'd0;
    always @(posedge clk)
    begin
        if(!rstn)
            fre_cnt <= `UD 21'd0;
        else if(fre_cnt == CLK_DIV - 1'b1)
            fre_cnt <= `UD 21'd0;
        else
            fre_cnt <= `UD fre_cnt + 1'b1;
    end
    
    wire  full_cycle;
    wire  half_cycle;
    assign full_cycle = (fre_cnt == CLK_DIV - 1'b1) ? 1'b1 : 1'b0;  //SCL上升沿：1个SCL周期位置
    assign half_cycle = (fre_cnt == (CLK_DIV>>1'b1) - 1'b1) ? 1'b1 : 1'b0;//SCL下降沿：1/2个SCL周期位置
    
    wire start_h;
    wire dsu;
    assign start_h = (fre_cnt == DATA_SET - 1'b1) ? 1'b1 : 1'b0; //开始停止标志SDA翻转位置 ：1/4个SCL周期位置
    assign dsu = (fre_cnt == (CLK_DIV>>1'b1) + DATA_SET - 1'b1) ? 1'b1 : 1'b0; //数据传输过程SDA变化位置：3/4个SCL周期位置
    
    //============================================================================
    //pluse trige the iic bus transmit start
    wire   start;
    reg    start_en;
    reg    pluse_1d,pluse_2d,pluse_3d;
    always @(posedge clk)
    begin
        if(!rstn)
        begin
            pluse_1d <= `UD 1'b0;
            pluse_2d <= `UD 1'b0;
            pluse_3d <= `UD 1'b0;
        end
        else
        begin
            pluse_1d <= `UD pluse   ;
            pluse_2d <= `UD pluse_1d;//同步
            pluse_3d <= `UD pluse_2d;//取边沿用
        end
    end
    
    always @ (posedge clk)
    begin
        if(start || (!rstn))//开始后开始使能信号拉低
            start_en <= `UD 1'b0;
        else if(~pluse_3d & pluse_2d)//上升沿
            start_en <= `UD 1'b1;
        else
            start_en <= `UD start_en;
    end
    
    assign start = (start_en & full_cycle) ? 1'b1 : 1'b0;
    
    reg w_r_1d=1'b0,w_r_2d=1'b0;
    always @(posedge clk)
    begin
        if(!rstn)
        begin
            w_r_1d <= `UD 1'b0;
            w_r_2d <= `UD 1'b0;
        end
        else
        begin
            w_r_1d <= `UD w_r;
            w_r_2d <= `UD w_r_1d;
        end
    end

    //==========================================================================
    //     IIC FSM STATE
    //==========================================================================
    localparam IDLE   = 3'd0;
    localparam S_START= 3'd1;
    localparam SEND   = 3'd2;
    localparam S_ACK  = 3'd3;
    localparam RECEIV = 3'd4;
    localparam R_ACK  = 3'd5;
    localparam STOP   = 3'd6;
    reg [2:0] state;
    reg [2:0] state_n;
    reg [2:0] trans_bit = 3'd0;
    
    reg [LEN_WIDTH :0] trans_byte = 5'd0;
    reg [LEN_WIDTH :0] trans_byte_max = 5'd0;
    reg       restart = 1'b0;
    reg [7:0] send_data=8'd0;
    reg [7:0] receiv_data=8'd0;
    reg       trans_en=0;
    reg       trans_over=0;
    reg       scl_out= 1'b1/*synthesis PAP_MARK_DEBUG="true"*/;
    
//    assign sda = sda_out_en ? sda_out : 1'bz;
//    assign sda_in = sda;
    assign scl = scl_out;
    
    //============================================================================
    //transmit status
    always @ (posedge clk)
    begin
        if(start)//传输操作开始标志
            trans_en <= `UD 1'b1;
        else if(state == STOP && start_h)//传输STOP标志输出完成
            trans_en <= `UD 1'b0;
        else
            trans_en <= `UD trans_en;
    end
    
//    always @(posedge clk)//冗余
//    begin
//        if(start)
//            trans_over <= `UD 1'b0;
//        else if(state == STOP && start_h)
//            trans_over <= `UD 1'b1;
//        else 
//            trans_over <= `UD trans_over;
//    end
    
    //===========================================================================
    // IIC Bus status
    reg           twr_en=0;
    reg  [26:0]   twr_cnt=0;
    always @(posedge clk)
    begin
        if(state == STOP && dsu)//STOP状态后开始延时
            twr_en <= `UD 1'b1;
        else if(twr_cnt == T_WR_DELAY)//延时满5ms
            twr_en <= `UD 1'b0;
        else
            twr_en <= `UD twr_en;    
    end
    
    always @(posedge clk)
    begin
        if(twr_en)
        begin
            if(twr_cnt == T_WR_DELAY)//延时满5ms
                twr_cnt <= `UD 1'b0;
            else
                twr_cnt <= `UD twr_cnt + 1'b1; 
        end
        else
            twr_cnt <= `UD twr_cnt;
    end
    
    always @(posedge clk)
    begin
        if(start_en)  //接收开始指令进入busy
            busy <= `UD 1'b1;
        else if(twr_cnt == T_WR_DELAY)//busy延时完成
            busy <= `UD 1'b0;
        else
            busy <= `UD busy;
    end
    
    //============================================================================
    //iic bus controller
    always @(posedge clk)
    begin
        if(trans_en)
        begin
            if(half_cycle || full_cycle)
                scl_out <= ~scl_out;
            else
                scl_out <= scl_out;
        end
        else
            scl_out <= 1'b1;
    end
    
    assign sda_out_en = ((state == S_ACK) || (state == RECEIV)) ? 1'b0 : 1'b1;
    
    //tx data control
    always @(posedge clk)
    begin
        if(start)//开始传输时提前准备第一个设备ID+写标志
            send_data <= `UD {device_id[7:1],1'b0};//{设备ID，读写标志}   传输高位在前
        else if(state == S_ACK && full_cycle) //在SACK状态中取一个点提前准备数据
        begin
        	if(ADDR_BYTE == 2'd1)
        	begin
                case(trans_byte)//传输内容变化
                    5'd0 : send_data <= `UD {device_id[7:1],1'b0};
                    5'd1 : send_data <= `UD addr[7:0];
                    5'd2 : send_data <= `UD (w_r_2d) ? data_in : {device_id[7:1],1'b1};
                    default: send_data <= `UD data_in;
                endcase
            end
            else
            begin
            	case(trans_byte)//传输内容变化
                    5'd0 : send_data <= `UD {device_id[7:1],1'b0};
                    5'd1 : send_data <= `UD addr[ 7:0];
                    5'd2 : send_data <= `UD addr[15:8];
                    5'd3 : send_data <= `UD (w_r_2d) ? data_in : {device_id[7:1],1'b1};
                    default: send_data <= `UD data_in;
                endcase
            end
        end
        else
            send_data <= `UD send_data;
    end
    
    //transmit byte number,contain device ID，ADDR，DATA
    always @(posedge clk)
    begin
        if(start)
        begin
            if(w_r_2d)
                trans_byte_max <= `UD ADDR_BYTE + byte_len + 2'd1;
            else
                trans_byte_max <= `UD ADDR_BYTE + byte_len + 2'd2;
        end
        else
            trans_byte_max <= `UD trans_byte_max;
    end
    
    //sda out control
    always @(posedge clk)
    begin
        case(state)
            IDLE  ://空闲状态
            begin
                sda_out <= `UD 1'b1;
            end
            S_START ://开始状态
            begin
                if(start_h)//开始标志产生
                    sda_out <= `UD 1'b0;
                else if(dsu)//数据在SCL上升沿前发出
                    sda_out <= `UD send_data[7-trans_bit];//高位先发
                else
                    sda_out <= `UD sda_out;
            end
            SEND  :
            begin
                sda_out <= `UD send_data[7-trans_bit];//变化数据，高位先发
            end
            S_ACK :
            begin
                if(trans_byte == ID_ADDR_BYTE && dsu && !w_r_2d)//读状态下地址传输完成，准备进入第二次S_START
                    sda_out <= `UD 1'b1;
                else
                    sda_out <= `UD 1'h0;
            end
            R_ACK :
            begin
                if(trans_byte < trans_byte_max)//继续读取回复ACK
                    sda_out <= `UD 1'b0;
                else
                begin
                    if(dsu)//反馈ACK结束，进入STOP状态，提前将SDA拉低
                        sda_out <= `UD 1'b0;
                    else//反馈不再继续读，提示切换传输方向；
                        sda_out <= `UD 1'b1;
                end
            end
            STOP  :
            begin
                if(start_h)//停止标志，
                    sda_out <= `UD 1'b1;
                else
                    sda_out <= `UD sda_out;
            end
            default: sda_out <= `UD 1'b1;
        endcase
    end
    
    // iic read data
    always @(posedge clk)
    begin
        if(state == RECEIV)
        begin
            if(full_cycle)//上升沿位置接收输入数据
                receiv_data <= `UD {receiv_data[6:0],sda_in};
            else
                receiv_data <= `UD receiv_data;
        end
        else
            receiv_data <= `UD 8'd0;
    end
    
    always @(posedge clk)
    begin
        if(state == RECEIV && trans_bit == 3'd7 && half_cycle)//接收1byte数据后，将数据传出
            data_out <= `UD receiv_data;
        else
            data_out <= `UD data_out;
    end
    
    //one byte data transmit over flag
    always @(posedge clk)
    begin
        if(w_r_2d)
        begin
            if(trans_byte > ID_ADDR_BYTE - 1'b1 && dsu && trans_bit == 3'd7)//写地址完成后再传输字节进行标识
                byte_over <= `UD 1'b1;
            else
                byte_over <= `UD 1'b0;
        end
        else
        begin
            if(trans_byte > ID_ADDR_BYTE && dsu && trans_bit == 3'd7)//写完第二次ID后，再传输字节进行标识
                byte_over <= `UD 1'b1;
            else
                byte_over <= `UD 1'b0;
        end
    end
    
    always @(posedge clk)
    begin
        if(state == SEND || state == RECEIV)
        begin
            if(dsu)
                trans_bit <= `UD trans_bit + 1'b1;
            else
                trans_bit <= `UD trans_bit;
        end
        else
            trans_bit <= `UD 3'd0;
    end
    
    always @(posedge clk)
    begin
        if(start)//每次开始传输时清零byte计数
            trans_byte <= `UD 5'd0;
        else if(state == SEND || state == RECEIV)//读写状态需要计数
        begin
            if(dsu && trans_bit == 3'd7)//传输满1byte时计数加1
                trans_byte <= `UD trans_byte + 1'b1;
            else//其他时候保持状态
                trans_byte <= `UD trans_byte;
        end
        else//其他时候保持状态
            trans_byte <= `UD trans_byte;
    end
    
    //==========================================================================
    //     IIC FSM STATE CHANGE
    //==========================================================================
    always @(posedge clk)
    begin
        if(!rstn)
            state <= `UD IDLE;
        else
            state <= `UD state_n;
    end
    
    // next state set
    always @(*)
    begin
        state_n = state;
        case(state)
            IDLE  :
            begin
                if(start)
                    state_n = S_START;
                else
                    state_n = state;
            end
            S_START :
            begin
//                if(full_cycle && trans_byte == 3'd0) //读写操作第一次
//                    state_n = SEND;
//                else if(!w_r_2d && trans_byte == ID_ADDR_BYTE && dsu)//读操作第二次
//                    state_n = SEND;
                if(dsu) 
                    state_n = SEND;
                else
                    state_n = state;
            end
            SEND  :
            begin
                if(trans_bit == 3'd7 & dsu)
                    state_n = S_ACK;
                else
                    state_n = state;
            end
            S_ACK :
            begin
                if(dsu)// & sda_in)
                begin
                    if(w_r_2d)
                    begin
                        if(trans_byte < ID_ADDR_BYTE)//写入ID+ADDR
                            state_n = SEND;
                        else if(trans_byte < trans_byte_max)//写入数据
                            state_n = SEND;
                        else//写入数据完成
                            state_n = STOP;
                    end
                    else
                    begin
                        if(trans_byte < ID_ADDR_BYTE)//写入ID+ADDR
                            state_n = SEND;
                        else if(trans_byte == ID_ADDR_BYTE)//重新开始，写入ID和读标志位
                            state_n = S_START;
                        else//进入读状态
                            state_n = RECEIV;
                    end
                end
                else
                    state_n = state;
            end
            RECEIV:
            begin
                if(trans_bit == 3'd7 & dsu)
                    state_n = R_ACK;
                else
                    state_n = state;
            end
            R_ACK :
            begin
                if(dsu)
                begin
                    if(trans_byte < trans_byte_max)
                        state_n = RECEIV;
                    else
                        state_n = STOP;
                end
                else
                    state_n = state;
            end
            STOP  :
            begin
                if(dsu)
                    state_n = IDLE;
                else
                    state_n = state;
            end
            default: state_n = IDLE;
        endcase
    end
    
    //===========================================================================

endmodule
 