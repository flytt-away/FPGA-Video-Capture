////////////////////////////////////////////////////////////////
// Copyright (c) 2021 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
////////////////////////////////////////////////////////////////
//Description:
//Author:
//History: v1.0
////////////////////////////////////////////////////////////////
module axi_bist_top_v1_0 #(
    parameter          DATA_MASK_EN     = 0,
    parameter          CTRL_ADDR_WIDTH  = 28,
    parameter          MEM_DQ_WIDTH     = 16,
    parameter          MEM_SPACE_AW     = 18,
    parameter          DATA_PATTERN0    = 8'h55,
    parameter          DATA_PATTERN1    = 8'haa,
    parameter          DATA_PATTERN2    = 8'h7f,
    parameter          DATA_PATTERN3    = 8'h80,
    parameter          DATA_PATTERN4    = 8'h55,
    parameter          DATA_PATTERN5    = 8'haa,
    parameter          DATA_PATTERN6    = 8'h7f,
    parameter          DATA_PATTERN7    = 8'h80
)(
   input               core_clk        ,
   input               core_clk_rst_n  ,
   input [1:0]         wr_mode         ,
   input [1:0]         data_mode       ,  
   input               len_random_en   ,
   input [3:0]         fix_axi_len     ,
   input               bist_stop       ,
   input               ddrc_init_done  ,
   input [3:0]         read_repeat_num ,
   input               data_order      ,
   input [7:0]         dq_inversion    ,
   input               insert_err      ,
   input               manu_clear      ,
   output              bist_run_led    ,
   output   [3:0]      test_main_state ,
   
   output   [CTRL_ADDR_WIDTH-1:0]    axi_awaddr     ,
   output                            axi_awuser_ap  ,    
   output   [3:0]                    axi_awuser_id  ,
   output   [3:0]                    axi_awlen      ,
   input                             axi_awready    ,
   output                            axi_awvalid    ,
         
   output  [MEM_DQ_WIDTH*8-1:0]      axi_wdata      ,
   output  [MEM_DQ_WIDTH*8/8-1:0]    axi_wstrb      ,
   input                             axi_wready     ,
   output   [2:0]                    test_wr_state  ,
   output   [CTRL_ADDR_WIDTH-1:0]    axi_araddr     ,
   output                            axi_aruser_ap  ,    
   output   [3:0]                    axi_aruser_id  ,
   output   [3:0]                    axi_arlen      ,
   input                             axi_arready    ,
   output                            axi_arvalid    ,
   
   input   [MEM_DQ_WIDTH*8-1:0]      axi_rdata      ,
   input                             axi_rvalid     ,
   output   [7:0]                    err_cnt        ,
   output                            err_flag_led   ,
   output   [MEM_DQ_WIDTH*8-1:0]     err_data_out ,    
   output   [MEM_DQ_WIDTH*8-1:0]     err_flag_out ,
   output   [MEM_DQ_WIDTH*8-1:0]     exp_data_out ,    
   output                            next_err_flag,
   output   [15:0]                   result_bit_out,
   output   [2:0]                    test_rd_state,
   output   [MEM_DQ_WIDTH*8-1:0]     next_err_data,
   output   [MEM_DQ_WIDTH*8-1:0]     err_data_pre ,
   output   [MEM_DQ_WIDTH*8-1:0]     err_data_aft  
   
   
);

   wire pattern_en    ;
   wire random_data_en;
   wire read_repeat_en;
   wire stress_test   ; 
   wire write_to_read ;

   wire [CTRL_ADDR_WIDTH-1:0] random_rw_addr;
   wire [3:0] random_axi_id;
   wire [3:0] random_axi_len;
   wire       random_axi_ap;
   
   wire       init_start   ;
   wire       init_done    ;
   wire       write_en     ;
   wire       write_done_p ;
   wire       read_en      ;
   wire       read_done_p  ;
    
   reg        data_order_d0;
   reg        data_order_d1;
   reg [7:0]  dq_inversion_d0;
   reg [7:0]  dq_inversion_d1;
   reg        bist_stop_d0;
   reg        bist_stop_d1;
   
  always @(posedge core_clk or negedge core_clk_rst_n)
  begin
    if (!core_clk_rst_n)begin
    	data_order_d0 <= 0;
    	data_order_d1 <= 0;
    end
    else begin
    	data_order_d0 <= data_order;
    	data_order_d1 <= data_order_d0;
    end
  end
  
  always @(posedge core_clk or negedge core_clk_rst_n)
  begin
    if (!core_clk_rst_n)begin
    	dq_inversion_d0 <= 8'd0;
    	dq_inversion_d1 <= 8'd0;
    end
    else begin
    	dq_inversion_d0 <= dq_inversion;
    	dq_inversion_d1 <= dq_inversion_d0;
    end
  end

  always @(posedge core_clk or negedge core_clk_rst_n)
  begin
    if (!core_clk_rst_n)begin
    	bist_stop_d0 <= 0;
    	bist_stop_d1 <= 0;
    end
    else begin
    	bist_stop_d0 <= bist_stop;
    	bist_stop_d1 <= bist_stop_d0;
    end
  end

test_main_ctrl_v1_0 #(
    .CTRL_ADDR_WIDTH            (CTRL_ADDR_WIDTH              ),
    .MEM_DQ_WIDTH               (MEM_DQ_WIDTH                 ),
    .MEM_SPACE_AW               (MEM_SPACE_AW                 )
) u_test_main_ctrl (
    .clk                        (core_clk                     ),
    .rst_n                      (core_clk_rst_n               ),
    .wr_mode                    (wr_mode                      ),
    .data_mode                  (data_mode                    ),
    .len_random_en              (len_random_en                ),
    .fix_axi_len                (fix_axi_len                  ),
    .bist_stop                  (bist_stop_d1                 ),
    .random_rw_addr             (random_rw_addr               ),
    .random_axi_id              (random_axi_id                ),
    .random_axi_len             (random_axi_len               ),  
    .random_axi_ap              (random_axi_ap                ),
    .pattern_en                 (pattern_en                   ),
    .random_data_en             (random_data_en               ),
    .read_repeat_en             (read_repeat_en               ),
    .stress_test                (stress_test                  ),
    .write_to_read              (write_to_read                ),
    .ddrc_init_done             (ddrc_init_done               ),
    .init_start                 (init_start                   ),
    .init_done                  (init_done                    ),
    .write_en                   (write_en                     ),
    .write_done_p               (write_done_p                 ),
    .read_en                    (read_en                      ),
    .read_done_p                (read_done_p                  ),
    .bist_run_led               (bist_run_led                 ),
    .test_main_state            (test_main_state              )
);

test_wr_ctrl_v1_0 #(
    .DATA_PATTERN0              (DATA_PATTERN0                ),
    .DATA_PATTERN1              (DATA_PATTERN1                ),
    .DATA_PATTERN2              (DATA_PATTERN2                ),
    .DATA_PATTERN3              (DATA_PATTERN3                ),
    .DATA_PATTERN4              (DATA_PATTERN4                ),
    .DATA_PATTERN5              (DATA_PATTERN5                ),
    .DATA_PATTERN6              (DATA_PATTERN6                ),
    .DATA_PATTERN7              (DATA_PATTERN7                ),
    .DATA_MASK_EN               (DATA_MASK_EN                 ),
    .CTRL_ADDR_WIDTH            (CTRL_ADDR_WIDTH              ),
    .MEM_DQ_WIDTH               (MEM_DQ_WIDTH                 ),
    .MEM_SPACE_AW               (MEM_SPACE_AW                 )
) u_test_wr_ctrl (
    .clk                        (core_clk                     ),
    .rst_n                      (core_clk_rst_n               ),
    .init_start                 (init_start                   ),
    .write_en                   (write_en                     ),
    .write_done_p               (write_done_p                 ),
    .init_done                  (init_done                    ),
    .insert_err                 (insert_err                   ),
    .pattern_en                 (pattern_en                   ),
    .random_data_en             (random_data_en               ),
    .read_repeat_en             (read_repeat_en               ),
    .stress_test                (stress_test                  ),
    .write_to_read              (write_to_read                ),
    .data_order                 (data_order_d1                ),
    .dq_inversion               (dq_inversion_d1              ),
    .random_rw_addr             (random_rw_addr               ),     
    .random_axi_id              (random_axi_id                ),
    .random_axi_len             (random_axi_len               ),
    .random_axi_ap              (random_axi_ap                ),
        
    .axi_awaddr                 (axi_awaddr                   ),
    .axi_awuser_ap              (axi_awuser_ap                ),
    .axi_awuser_id              (axi_awuser_id                ),
    .axi_awlen                  (axi_awlen                    ),
    .axi_awready                (axi_awready                  ),
    .axi_awvalid                (axi_awvalid                  ),
    .axi_wdata                  (axi_wdata                    ),
    .axi_wstrb                  (axi_wstrb                    ),
    .axi_wready                 (axi_wready                   ),
    .test_wr_state              (test_wr_state                )
);

test_rd_ctrl_v1_0 #(
    .DATA_PATTERN0              (DATA_PATTERN0                ),
    .DATA_PATTERN1              (DATA_PATTERN1                ),
    .DATA_PATTERN2              (DATA_PATTERN2                ),
    .DATA_PATTERN3              (DATA_PATTERN3                ),
    .DATA_PATTERN4              (DATA_PATTERN4                ),
    .DATA_PATTERN5              (DATA_PATTERN5                ),
    .DATA_PATTERN6              (DATA_PATTERN6                ),
    .DATA_PATTERN7              (DATA_PATTERN7                ),
    .DATA_MASK_EN               (DATA_MASK_EN                 ),
    .CTRL_ADDR_WIDTH            (CTRL_ADDR_WIDTH              ),
    .MEM_DQ_WIDTH               (MEM_DQ_WIDTH                 ),
    .MEM_SPACE_AW               (MEM_SPACE_AW                 )
)u_test_rd_ctrl(
    .clk                        (core_clk                     ),
    .rst_n                      (core_clk_rst_n               ),
    .pattern_en                 (pattern_en                   ),
    .random_data_en             (random_data_en               ),
    .read_repeat_en             (read_repeat_en               ),
    .read_repeat_num            (read_repeat_num              ),
    .stress_test                (stress_test                  ),
    .write_to_read              (write_to_read                ),
    .data_order                 (data_order_d1                ),
    .dq_inversion               (dq_inversion_d1              ),
    .random_rw_addr             (random_rw_addr               ),
    .random_axi_id              (random_axi_id                ),
    .random_axi_len             (random_axi_len               ),
    .random_axi_ap              (random_axi_ap                ),    
    .read_en                    (read_en                      ),
    .read_done_p                (read_done_p                  ),    
    .axi_araddr                 (axi_araddr                   ),
    .axi_aruser_ap              (axi_aruser_ap                ),
    .axi_aruser_id              (axi_aruser_id                ),
    .axi_arlen                  (axi_arlen                    ),
    .axi_arready                (axi_arready                  ),
    .axi_arvalid                (axi_arvalid                  ),

    .axi_rdata                  (axi_rdata                    ),
    .axi_rvalid                 (axi_rvalid                   ),
    .err_cnt                    (err_cnt                      ),
    .err_flag_led               (err_flag_led                 ),
    .err_data_out               (err_data_out                 ),
    .err_flag_out               (err_flag_out                 ),
    .exp_data_out               (exp_data_out                 ),
    .manu_clear                 (manu_clear                   ),
    .next_err_flag              (next_err_flag                ),
    .result_bit_out             (result_bit_out               ),
    .test_rd_state              (test_rd_state                ),
    .next_err_data              (next_err_data                ),
    .err_data_pre               (err_data_pre                 ),
    .err_data_aft               (err_data_aft                 )
);

endmodule
