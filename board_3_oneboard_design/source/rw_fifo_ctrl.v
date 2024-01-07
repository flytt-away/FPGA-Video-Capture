module rw_fifo_ctrl(
input wire                         rstn                    ,//系统复位
input wire                         ddr_clk                 ,//写入内存的时钟（内存axi4接口时钟）

//写fifo                                                    
input wire                         wfifo_wr_clk            ,//wfifo写时钟
input wire                         wfifo_wr_en             /* synthesis PAP_MARK_DEBUG="1" */,//wfifo输入使能
input wire     [31 : 0]            wfifo_wr_data32_in      /* synthesis PAP_MARK_DEBUG="1" */,//wfifo输入数据,16bits
input wire                         wfifo_rd_req            /* synthesis PAP_MARK_DEBUG="1" */,//wfifo读请求，当数量大于突发长度时拉高
//input wire                         wfifo_pre_rd_req        /* synthesis PAP_MARK_DEBUG="1" */,
output wire    [8 : 0]             wfifo_rd_water_level    /* synthesis PAP_MARK_DEBUG="1" */,//wfifo读水位，当数量大于突发长度时开始传输
output wire    [255 : 0]           wfifo_rd_data256_out    /* synthesis PAP_MARK_DEBUG="1" */,//wfifo读数据，256bits      
//读fifo
input wire                         rfifo_rd_clk            ,//rfifo读时钟
input wire                         rfifo_rd_en             /* synthesis PAP_MARK_DEBUG="1" */,//rfifo输入使能
output wire    [31 : 0]            rfifo_rd_data32_out     /* synthesis PAP_MARK_DEBUG="1" */,//rfifo输入数据,16bits
input wire                         rfifo_wr_req            /* synthesis PAP_MARK_DEBUG="1" */,//rfifo写请求，当数量大于突发长度时拉高
output wire    [8 : 0]             rfifo_wr_water_level    /* synthesis PAP_MARK_DEBUG="1" */,//rfifo写水位，当数量小于突发长度时开始传输
input wire     [255 : 0]           rfifo_wr_data256_in     /* synthesis PAP_MARK_DEBUG="1" */, //rfifo写数据，256bits
//复位信号
input wire                         vs_in                   ,
input wire                         vs_out                                               
   );


//参数********************************************************
//wire********************************************************
//reg********************************************************
//复位信号
reg                              r_vs_in_d0;
reg  [15 : 0]                    r_vs_in_d1; 
reg                              r_vs_out_d0;                            
reg  [15 : 0]                    r_vs_out_d1;     
reg                              r_wr_rst/* synthesis PAP_MARK_DEBUG="1" */;
reg                              r_rd_rst/* synthesis PAP_MARK_DEBUG="1" */;    
//组合逻辑********************************************************
//写fifo复位
always @(posedge wfifo_wr_clk ) begin
    if(!rstn ) begin
        r_vs_in_d0 <= 'd0;
    end
    else begin 
        r_vs_in_d0 <= vs_in;
    end
end
//位移寄存
always @(posedge wfifo_wr_clk ) begin
    if(!rstn ) begin
        r_vs_in_d1 <= 'd0;
    end
    else begin 
        r_vs_in_d1 <= {r_vs_in_d1[14:0],r_vs_in_d0};
    end
end
//产生一段多周期复位电平，满足fifo复位时序
always @(posedge wfifo_wr_clk ) begin
    if(!rstn)
        r_wr_rst <= 1'b0;
    else if(r_vs_in_d1[0] && !r_vs_in_d1[14])
        r_wr_rst <= 1'b1;
    else
        r_wr_rst <= 1'b0;
end  
//读fifo复位
always @(posedge rfifo_rd_clk ) begin
    if(!rstn ) begin
        r_vs_out_d0 <= 'd0;
    end
    else begin 
        r_vs_out_d0 <= vs_out;
    end
end
//位移寄存
always @(posedge rfifo_rd_clk ) begin
    if(!rstn ) begin
        r_vs_out_d1 <= 'd0;
    end
    else begin 
        r_vs_out_d1 <= {r_vs_out_d1[14:0],r_vs_out_d0};
    end
end
//产生一段多周期复位电平，满足fifo复位时序
always @(posedge rfifo_rd_clk ) begin
    if(!rstn)
        r_rd_rst <= 1'b0;
    else if(r_vs_out_d1[0] && !r_vs_out_d1[14])
        r_rd_rst <= 1'b1;
    else
        r_rd_rst <= 1'b0;
end  
//状态机********************************************************
//例化********************************************************
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