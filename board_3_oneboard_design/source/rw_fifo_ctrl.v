module rw_fifo_ctrl(
input wire                         rstn                    ,//ϵͳ��λ
input wire                         ddr_clk                 ,//д���ڴ��ʱ�ӣ��ڴ�axi4�ӿ�ʱ�ӣ�

//дfifo                                                    
input wire                         wfifo_wr_clk            ,//wfifoдʱ��
input wire                         wfifo_wr_en             /* synthesis PAP_MARK_DEBUG="1" */,//wfifo����ʹ��
input wire     [31 : 0]            wfifo_wr_data32_in      /* synthesis PAP_MARK_DEBUG="1" */,//wfifo��������,16bits
input wire                         wfifo_rd_req            /* synthesis PAP_MARK_DEBUG="1" */,//wfifo�����󣬵���������ͻ������ʱ����
//input wire                         wfifo_pre_rd_req        /* synthesis PAP_MARK_DEBUG="1" */,
output wire    [8 : 0]             wfifo_rd_water_level    /* synthesis PAP_MARK_DEBUG="1" */,//wfifo��ˮλ������������ͻ������ʱ��ʼ����
output wire    [255 : 0]           wfifo_rd_data256_out    /* synthesis PAP_MARK_DEBUG="1" */,//wfifo�����ݣ�256bits      
//��fifo
input wire                         rfifo_rd_clk            ,//rfifo��ʱ��
input wire                         rfifo_rd_en             /* synthesis PAP_MARK_DEBUG="1" */,//rfifo����ʹ��
output wire    [31 : 0]            rfifo_rd_data32_out     /* synthesis PAP_MARK_DEBUG="1" */,//rfifo��������,16bits
input wire                         rfifo_wr_req            /* synthesis PAP_MARK_DEBUG="1" */,//rfifoд���󣬵���������ͻ������ʱ����
output wire    [8 : 0]             rfifo_wr_water_level    /* synthesis PAP_MARK_DEBUG="1" */,//rfifoдˮλ��������С��ͻ������ʱ��ʼ����
input wire     [255 : 0]           rfifo_wr_data256_in     /* synthesis PAP_MARK_DEBUG="1" */, //rfifoд���ݣ�256bits
//��λ�ź�
input wire                         vs_in                   ,
input wire                         vs_out                                               
   );


//����********************************************************
//wire********************************************************
//reg********************************************************
//��λ�ź�
reg                              r_vs_in_d0;
reg  [15 : 0]                    r_vs_in_d1; 
reg                              r_vs_out_d0;                            
reg  [15 : 0]                    r_vs_out_d1;     
reg                              r_wr_rst/* synthesis PAP_MARK_DEBUG="1" */;
reg                              r_rd_rst/* synthesis PAP_MARK_DEBUG="1" */;    
//����߼�********************************************************
//дfifo��λ
always @(posedge wfifo_wr_clk ) begin
    if(!rstn ) begin
        r_vs_in_d0 <= 'd0;
    end
    else begin 
        r_vs_in_d0 <= vs_in;
    end
end
//λ�ƼĴ�
always @(posedge wfifo_wr_clk ) begin
    if(!rstn ) begin
        r_vs_in_d1 <= 'd0;
    end
    else begin 
        r_vs_in_d1 <= {r_vs_in_d1[14:0],r_vs_in_d0};
    end
end
//����һ�ζ����ڸ�λ��ƽ������fifo��λʱ��
always @(posedge wfifo_wr_clk ) begin
    if(!rstn)
        r_wr_rst <= 1'b0;
    else if(r_vs_in_d1[0] && !r_vs_in_d1[14])
        r_wr_rst <= 1'b1;
    else
        r_wr_rst <= 1'b0;
end  
//��fifo��λ
always @(posedge rfifo_rd_clk ) begin
    if(!rstn ) begin
        r_vs_out_d0 <= 'd0;
    end
    else begin 
        r_vs_out_d0 <= vs_out;
    end
end
//λ�ƼĴ�
always @(posedge rfifo_rd_clk ) begin
    if(!rstn ) begin
        r_vs_out_d1 <= 'd0;
    end
    else begin 
        r_vs_out_d1 <= {r_vs_out_d1[14:0],r_vs_out_d0};
    end
end
//����һ�ζ����ڸ�λ��ƽ������fifo��λʱ��
always @(posedge rfifo_rd_clk ) begin
    if(!rstn)
        r_rd_rst <= 1'b0;
    else if(r_vs_out_d1[0] && !r_vs_out_d1[14])
        r_rd_rst <= 1'b1;
    else
        r_rd_rst <= 1'b0;
end  
//״̬��********************************************************
//����********************************************************
write_ddr_fifo user_write_ddr_fifo (
  .wr_clk            (wfifo_wr_clk        ),// input         
  .wr_rst            (~rstn | r_wr_rst    ),// input         
  .wr_en             (wfifo_wr_en         ),// input         
  .wr_data           (wfifo_wr_data32_in  ),// input [31:0]  
  .wr_full           (                    ),// output        
  .wr_water_level    (                    ),// output [11:0] 
  .almost_full       (                    ),// output        
  .rd_clk            (ddr_clk             ),// input         
  .rd_rst            (~rstn | r_wr_rst    ),// input         
  .rd_en             (wfifo_rd_req        ),// input         
  .rd_data           (wfifo_rd_data256_out),// output [255:0]
  .rd_empty          (                    ),// output        
  .rd_water_level    (wfifo_rd_water_level),// output [8:0]  
  .almost_empty      (                    ) // output        
);

read_ddr_fifo user_read_ddr_fifo (
  .wr_clk            (ddr_clk             ),// input        
  .wr_rst            (~rstn | r_rd_rst    ),// input        
  .wr_en             (rfifo_wr_req        ),// input        
  .wr_data           (rfifo_wr_data256_in ),// input [255:0]
  .wr_full           (                    ),// output       
  .wr_water_level    (rfifo_wr_water_level),// output [8:0] 
  .almost_full       (                    ),// output       
  .rd_clk            (rfifo_rd_clk        ),// input        
  .rd_rst            (~rstn | r_rd_rst    ),// input        
  .rd_en             (rfifo_rd_en         ),// input        
  .rd_data           (rfifo_rd_data32_out ),// output [31:0]
  .rd_empty          (                    ),// output       
  .rd_water_level    (                    ),// output [11:0]
  .almost_empty      (                    ) // output       
);

endmodule