module udp_rx(
    input                clk         ,    //时钟信号
    input                rst_n       ,    //复位信号，低电平有效
    
    input                gmii_rx_dv  ,    //GMII输入数据有效信号
    input        [7:0]   gmii_rxd    /* synthesis PAP_MARK_DEBUG="1" */,    //GMII输入数据
    output  reg          rec_pkt_done,    //以太网单包数据接收完成信号
    output  reg          rec_en      /* synthesis PAP_MARK_DEBUG="1" */,    //以太网接收的数据使能信号
    output  reg  [31:0]  rec_data    /* synthesis PAP_MARK_DEBUG="1" */,    //以太网接收的数据
    output  reg  [15:0]  rec_byte_num     //以太网接收的有效字数 单位:byte     
    );

//parameter define
//开发板MAC地址 00-11-22-33-44-55
parameter BOARD_MAC = 48'h00_11_22_33_44_55; 
//开发板IP地址 192.168.1.10 
parameter BOARD_IP = {8'd192,8'd168,8'd1,8'd10};

localparam  st_idle     = 7'b000_0001; //初始状态，等待接收前导码
localparam  st_preamble = 7'b000_0010; //接收前导码状态 
localparam  st_eth_head = 7'b000_0100; //接收以太网帧头
localparam  st_ip_head  = 7'b000_1000; //接收IP首部
localparam  st_udp_head = 7'b001_0000; //接收UDP首部
localparam  st_rx_data  = 7'b010_0000; //接收有效数据
localparam  st_rx_end   = 7'b100_0000; //接收结束

localparam  ETH_TYPE    = 16'h0800   ; //以太网协议类型 IP协议

//reg define
reg  [6:0]   cur_state       ;
reg  [6:0]   next_state      /* synthesis PAP_MARK_DEBUG="1" */;
                             
reg          skip_en         ; //控制状态跳转使能信号
reg          error_en        /* synthesis PAP_MARK_DEBUG="1" */; //解析错误使能信号
reg  [4:0]   cnt             ; //解析数据计数器
reg  [47:0]  des_mac         ; //目的MAC地址
reg  [15:0]  eth_type        ; //以太网类型
reg  [31:0]  des_ip          ; //目的IP地址
reg  [5:0]   ip_head_byte_num; //IP首部长度
reg  [15:0]  udp_byte_num    ; //UDP长度
reg  [15:0]  data_byte_num   ; //数据长度
reg  [15:0]  data_cnt        ; //有效数据计数    
reg  [1:0]   rec_en_cnt      ; //8bit转32bit计数器

//*****************************************************
//**                    main code
//*****************************************************

//(三段式状态机)同步时序描述状态转移
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cur_state <= st_idle;  
    else
        cur_state <= next_state;
end

//组合逻辑判断状态转移条件
always @(*) begin
    next_state = st_idle;
    case(cur_state)
        st_idle : begin                                     //等待接收前导码
            if(skip_en) 
                next_state = st_preamble;
            else
                next_state = st_idle;    
        end
        st_preamble : begin                                 //接收前导码
            if(skip_en) 
                next_state = st_eth_head;
            else if(error_en) 
                next_state = st_rx_end;    
            else
                next_state = st_preamble;    
        end
        st_eth_head : begin                                 //接收以太网帧头
            if(skip_en) 
                next_state = st_ip_head;
            else if(error_en) 
                next_state = st_rx_end;
            else
                next_state = st_eth_head;           
        end  
        st_ip_head : begin                                  //接收IP首部
            if(skip_en)
                next_state = st_udp_head;
            else if(error_en)
                next_state = st_rx_end;
            else
                next_state = st_ip_head;       
        end 
        st_udp_head : begin                                 //接收UDP首部
            if(skip_en)
                next_state = st_rx_data;
            else
                next_state = st_udp_head;    
        end                
        st_rx_data : begin                                  //接收有效数据
            if(skip_en)
                next_state = st_rx_end;
            else
                next_state = st_rx_data;    
        end                           
        st_rx_end : begin                                   //接收结束
            if(skip_en)
                next_state = st_idle;
            else
                next_state = st_rx_end;          
        end
        default : next_state = st_idle;
    endcase                                          
end    

//时序电路描述状态输出,解析以太网数据
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        skip_en <= 1'b0;
        error_en <= 1'b0;
        cnt <= 5'd0;
        des_mac <= 48'd0;
        eth_type <= 16'd0;
        des_ip <= 32'd0;
        ip_head_byte_num <= 6'd0;
        udp_byte_num <= 16'd0;
        data_byte_num <= 16'd0;
        data_cnt <= 16'd0;
        rec_en_cnt <= 2'd0;
        rec_en <= 1'b0;
        rec_data <= 32'd0;
        rec_pkt_done <= 1'b0;
        rec_byte_num <= 16'd0;
    end
    else begin
        skip_en <= 1'b0;
        error_en <= 1'b0;  
        rec_en <= 1'b0;
        rec_pkt_done <= 1'b0;
        case(next_state)
            st_idle : begin
                if((gmii_rx_dv == 1'b1) && (gmii_rxd == 8'h55)) 
                    skip_en <= 1'b1;
            end
            st_preamble : begin
                if(gmii_rx_dv) begin                         //解析前导码
                    cnt <= cnt + 5'd1;
                    if((cnt < 5'd6) && (gmii_rxd != 8'h55))  //7个8'h55  
                        error_en <= 1'b1;
                    else if(cnt==5'd6) begin
                        cnt <= 5'd0;
                        if(gmii_rxd==8'hd5)                  //1个8'hd5
                            skip_en <= 1'b1;
                        else
                            error_en <= 1'b1;    
                    end  
                end  
            end
            st_eth_head : begin
                if(gmii_rx_dv) begin
                    cnt <= cnt + 5'b1;
                    if(cnt < 5'd6) 
                        des_mac <= {des_mac[39:0],gmii_rxd}; //目的MAC地址
                    else if(cnt == 5'd12) 
                        eth_type[15:8] <= gmii_rxd;          //以太网协议类型
                    else if(cnt == 5'd13) begin
                        eth_type[7:0] <= gmii_rxd;
                        cnt <= 5'd0;
                        //判断MAC地址是否为开发板MAC地址或者公共地址 判断类型是否为IP协议（0800）
                        if(((des_mac == BOARD_MAC) ||(des_mac == 48'hff_ff_ff_ff_ff_ff))
                       && eth_type[15:8] == ETH_TYPE[15:8] && gmii_rxd == ETH_TYPE[7:0])            
                            skip_en <= 1'b1;
                        else
                            error_en <= 1'b1;
                    end        
                end  
            end
            st_ip_head : begin
                if(gmii_rx_dv) begin
                    cnt <= cnt + 5'd1;
                    if(cnt == 5'd0)
                        ip_head_byte_num <= {gmii_rxd[3:0],2'd0}; //IP寄存首部长度，左移两位=x4，即dwX4变成字节数
                    //比较视频代码，少了对UDP协议的解析
                    else if((cnt >= 5'd16) && (cnt <= 5'd18))
                        des_ip <= {des_ip[23:0],gmii_rxd};   //目的IP地址 
                    else if(cnt == 5'd19) begin
                        des_ip <= {des_ip[23:0],gmii_rxd}; 
                        //判断IP地址是否为开发板IP地址
                        if((des_ip[23:0] == BOARD_IP[31:8])
                            && (gmii_rxd == BOARD_IP[7:0])) begin  
                            if(cnt == ip_head_byte_num - 1'b1) begin//计数是否等于首部字节数？如果还包含可选字段会继续自增等待跳转
                                skip_en <=1'b1;                     
                                cnt <= 5'd0;
                            end                             
                        end    
                        else begin            
                        //IP错误，停止解析数据                        
                            error_en <= 1'b1;               
                            cnt <= 5'd0;
                        end                                                  
                    end                          
                    else if(cnt == ip_head_byte_num - 1'b1) begin 
                        skip_en <=1'b1;                      //IP首部解析完成
                        cnt <= 5'd0;                    
                    end    
                end                                
            end 
            st_udp_head : begin
                if(gmii_rx_dv) begin
                    cnt <= cnt + 5'd1;
                    if(cnt == 5'd4)
                        udp_byte_num[15:8] <= gmii_rxd;      //解析UDP字节长度 （首部+数据）
                    else if(cnt == 5'd5)
                        udp_byte_num[7:0] <= gmii_rxd;
                    else if(cnt == 5'd7) begin
                        //有效数据字节长度，（UDP首部8个字节，所以减去8）
                        data_byte_num <= udp_byte_num - 16'd8;    
                        skip_en <= 1'b1;
                        cnt <= 5'd0;
                    end  
                end                 
            end          
            st_rx_data : begin         
                //接收数据，转换成32bit 积累四次时钟周期然后转           
                if(gmii_rx_dv) begin
                    data_cnt <= data_cnt + 16'd1;
                    rec_en_cnt <= rec_en_cnt + 2'd1;
                    if(data_cnt == data_byte_num - 16'd1) begin
                        skip_en <= 1'b1;                    //有效数据接收完成
                        data_cnt <= 16'd0;
                        rec_en_cnt <= 2'd0;
                        rec_pkt_done <= 1'b1;               
                        rec_en <= 1'b1;                     
                        rec_byte_num <= data_byte_num;
                    end    
                    //先收到的数据放在了rec_data的高位,所以当数据不是4的倍数时,
                    //低位数据为无效数据，可根据有效字节数来判断(rec_byte_num)
                    if(rec_en_cnt == 2'd0)
                        rec_data[31:24] <= gmii_rxd;
                    else if(rec_en_cnt == 2'd1)
                        rec_data[23:16] <= gmii_rxd;
                    else if(rec_en_cnt == 2'd2) 
                        rec_data[15:8] <= gmii_rxd;        
                    else if(rec_en_cnt==2'd3) begin
                        rec_en <= 1'b1;
                        rec_data[7:0] <= gmii_rxd;
                    end    
                end  
            end    
            st_rx_end : begin                               //单包数据接收完成   
                if(gmii_rx_dv == 1'b0 && skip_en == 1'b0)
                    skip_en <= 1'b1; 
            end    
            default : ;
        endcase                                                        
    end
end

endmodule