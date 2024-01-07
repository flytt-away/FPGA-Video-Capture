// Created by IP Generator (Version 2022.1 build 99559)



`timescale 1ns/1ps 

`define DDR3

module ipsxb_ddrphy_slice_top_v1_4 #(
  parameter   MEM_ADDR_WIDTH      = 15,
  parameter   MEM_BANKADDR_WIDTH  = 3,
  parameter   MEM_DQ_WIDTH        = 16,
  parameter   MEM_DQS_WIDTH       = 2,
  parameter   MEM_DM_WIDTH        = 2,
  parameter   DM_GROUP_EN         = 0,
  parameter   WL_EXTEND           = "FALSE"
)(                          
  input  [4:0]                      mc_rl                    ,
  input  [1:0]                      init_read_clk_ctrl       ,                                                       
  input  [3:0]                      init_slip_step           ,                                                 
  input  [7:0]                      init_samp_position       ,                
                                                                                                         
  input                             ddrphy_clkin             ,                      
  input                             ddrphy_rst_n             ,
  input  [8:0]                      ddrphy_ioclk             , 
  input                             ddrphy_dqs_rst           ,
  input                             ddrphy_dqs_training_rstn ,
  input  [2:0]                      ddrphy_iodly_ctrl        ,
  input  [2:0]                      ddrphy_wl_ctrl           ,
  
  output [2*MEM_DQS_WIDTH-1:0]      dqs_drift                ,

//wrlvl                                                                               
  input                             wrlvl_dqs_req            ,                        
  output                            wrlvl_dqs_resp           ,                        
  output                            wrlvl_error              ,                                 
  input                             man_wrlvl_dqs            ,  
  output reg                        wrlvl_ck_dly_start_rst   ,
  input                             logic_rstn               ,
  input                             force_ck_dly_en          ,
  input  [7:0]                      force_ck_dly_set_bin     ,
                                    
//dqs                                                                                 
  input                             force_read_clk_ctrl      ,
  input                             gatecal_start            ,
  output                            gate_check_pass          ,
  output                            gate_adj_done            ,
  output                            gate_cal_error           ,
  input                             gate_move_en             ,
  input                             dqs_gate_update1         ,
  input                             dqs_gate_update2         ,
  output                            gate_update1_done        ,
  output                            gate_update2_done        ,
  output                            dqs_gate_check_falling   ,
                                                              
  input                             rddata_cal               ,
  output                            rddata_check_pass        ,
                                       
  input  [3:0]                      read_cmd                 ,                 

  output                            gate_check_error         ,
                                    
///rdel                                                                               
  input                             force_samp_position      ,                       
  input  [7:0]                      dll_step                 ,
 
  input                             init_adj_rdel            ,                        
  input                             reinit_adj_rdel          ,
  output                            adj_rdel_done            ,                        
  input                             rdel_calibration         ,                        
  output                            rdel_calib_done          ,                        
  output                            rdel_calib_error         ,                        
  input                             rdel_move_en             ,                        
  output                            rdel_move_done           ,                                                
//rdata                                                                                                 
  output     	                    read_valid               ,                        
  output reg [8*MEM_DQ_WIDTH-1:0]   o_read_data              ,      
  output [MEM_DQS_WIDTH-1:0]        ddrphy_read_valid        ,                
//wdata                                                               
  input  [3:0]                      phy_wrdata_en            ,               
  input  [8*MEM_DM_WIDTH-1:0]       phy_wrdata_mask          ,               
  input  [8*MEM_DQ_WIDTH-1:0]       phy_wrdata               ,                                                                   
  input  [3:0]                      phy_cke                  ,                                              
  input  [3:0]                      phy_cs_n                 ,                                              
  input  [3:0]                      phy_ras_n                ,                                              
  input  [3:0]                      phy_cas_n                ,                                              
  input  [3:0]                      phy_we_n                 ,                                              
  input  [4*MEM_ADDR_WIDTH-1:0]     phy_addr                 ,                                              
  input  [4*MEM_BANKADDR_WIDTH-1:0] phy_ba                   ,                                              
  input  [3:0]                      phy_odt                  ,
  input  [3:0]                      phy_ck                   ,
  input                             phy_rst                  ,

  output                            mem_cs_n                 ,

  output                            mem_rst_n                ,
  output                            mem_ck                   ,
  output                            mem_ck_n                 ,
  output                            mem_cke                  ,
  output                            mem_ras_n                ,
  output                            mem_cas_n                ,
  output                            mem_we_n                 , 
  output                            mem_odt                  ,
  output [MEM_ADDR_WIDTH-1:0]       mem_a                    ,
  output [MEM_BANKADDR_WIDTH-1:0]   mem_ba                   ,
  inout  [MEM_DQS_WIDTH-1:0]        mem_dqs                  ,
  inout  [MEM_DQS_WIDTH-1:0]        mem_dqs_n                ,
  inout  [MEM_DQ_WIDTH-1:0]         mem_dq                   ,
  output [MEM_DM_WIDTH-1:0]         mem_dm                   ,
  output [34*MEM_DQS_WIDTH -1:0]    debug_data               ,
  output [13*MEM_DQS_WIDTH -1:0]    debug_slice_state        ,
  output reg [7:0]                  ck_dly_set_bin      
  );                                            


localparam  MEM_CA_GROUP = 4;

localparam CKE_GROUP_NUM = 0;

localparam CK_GROUP_NUM = 0;

localparam CS_GROUP_NUM = 1;

localparam RAS_GROUP_NUM = 1;

localparam CAS_GROUP_NUM = 1;

localparam WE_GROUP_NUM = 1;

localparam ODT_GROUP_NUM = 1;

localparam BA0_GROUP_NUM = 1;

localparam BA1_GROUP_NUM = 0;

localparam BA2_GROUP_NUM = 2;

localparam A0_GROUP_NUM = 2;

localparam A1_GROUP_NUM = 2;

localparam A2_GROUP_NUM = 2;

localparam A3_GROUP_NUM = 3;

localparam A4_GROUP_NUM = 0;

localparam A5_GROUP_NUM = 3;

localparam A6_GROUP_NUM = 0;

localparam A7_GROUP_NUM = 3;

localparam A8_GROUP_NUM = 2;

localparam A9_GROUP_NUM = 0;

localparam A10_GROUP_NUM = 0;

localparam A11_GROUP_NUM = 2;

localparam A12_GROUP_NUM = 2;

localparam A13_GROUP_NUM = 0;
  
localparam A14_GROUP_NUM = 2;
  
localparam GROUP_DQG_0_NUM = 5;

localparam GROUP_DQG_1_NUM = 4;

localparam GROUP_DQG_2_NUM = 3;

localparam GROUP_DQG_3_NUM = 2;

localparam CA_GROUP0_REG   =  2;

localparam CA_GROUP1_REG   =  0;

localparam CA_GROUP2_REG   =  2;

localparam CA_GROUP3_REG   =  0;

localparam CA_GROUP4_REG   =  0;



  integer i,j;

  wire                            logic_ck_rstn          ;
  wire [MEM_DQS_WIDTH-1:0]        dqs_read_valid         ;
  wire [8*MEM_DQ_WIDTH-1:0]       dqs_read_data          ;
  wire                            dqs_align_valid        ;
  wire [8*MEM_DQ_WIDTH-1:0]       dqs_align_data         ;
  
  reg [8*MEM_DQ_WIDTH-1:0]        phy_wrdata_reorder     ; 
  reg [8*MEM_DM_WIDTH-1:0]        phy_wrdata_mask_reorder; 
  reg [4*MEM_BANKADDR_WIDTH-1:0]  phy_ba_reorder         ;
  reg [4*MEM_ADDR_WIDTH-1:0]      phy_addr_reorder       ;
  
  wire [MEM_DQS_WIDTH-1:0]        wrlvl_error_tmp        ;
  wire [MEM_DQS_WIDTH-1:0]        wrlvl_dqs_resp_tmp     ;
  wire [MEM_DQS_WIDTH-1:0]        adj_rdel_done_tmp      ;
  wire [MEM_DQS_WIDTH-1:0]        rdel_calib_done_tmp    ;
  wire [MEM_DQS_WIDTH-1:0]        rdel_calib_error_tmp   ;
  wire [MEM_DQS_WIDTH-1:0]        rdel_move_done_tmp     ;
  wire [MEM_DQS_WIDTH-1:0]        gate_check_pass_tmp    ;
  wire [MEM_DQS_WIDTH-1:0]        gate_adj_done_tmp      ;
  wire [MEM_DQS_WIDTH-1:0]        gate_cal_error_tmp     ;
  wire [MEM_DQS_WIDTH-1:0]        rddata_check_pass_tmp  ;
  wire [MEM_DQS_WIDTH-1:0]        gate_check_error_tmp   ;  
  wire [MEM_DQS_WIDTH-1:0]        gate_update1_done_tmp  ;
  wire [MEM_DQS_WIDTH-1:0]        gate_update2_done_tmp  ;
  wire [MEM_DQS_WIDTH-1:0]        dqs_gate_check_falling_tmp ;
  wire [MEM_DQS_WIDTH-1:0]        wrlvl_ck_dly_flag_tmp  ;
  wire [MEM_DQS_WIDTH-1:0]        ck_check_done_tmp      ;
  wire [8*MEM_DQS_WIDTH-1:0]      ck_dly_set_bin_tmp     ;
  wire                            align_error            ;
  wire                            wrlvl_ck_dly_start     ;
  wire                            wrlvl_ck_dly_done      ;
  wire [7:0]                      ck_dly_set_bin_sto     ;
  reg  [2:0]                      ck_dly_cnt             ;
  
 

  wire [7:0]                      adj_cs_n               ;
  wire [7:0]                      adj_cke                ;
  wire [7:0]                      adj_ras_n              ;
  wire [7:0]                      adj_cas_n              ;
  wire [7:0]                      adj_we_n               ;
  wire [8*MEM_ADDR_WIDTH-1:0]     adj_addr               ;
  wire [8*MEM_BANKADDR_WIDTH-1:0] adj_ba                 ;
  wire [7:0]                      adj_odt                ;
  wire [7:0]                      adj_ck                 ;

  wire [4:0]                      ddrphy_ioclk_ca        ;

  wire                            cs_ioclk               ;

  wire                            cke_ioclk              ;
  wire                            ck_ioclk               ;
  wire                            ras_ioclk              ;
  wire                            cas_ioclk              ;
  wire                            we_ioclk               ;
  wire                            odt_ioclk              ;
  wire                            ba0_ioclk              ;
  wire                            ba1_ioclk              ;
  wire                            ba2_ioclk              ;
  wire                            a0_ioclk               ;
  wire                            a1_ioclk               ;
  wire                            a2_ioclk               ;
  wire                            a3_ioclk               ;
  wire                            a4_ioclk               ;
  wire                            a5_ioclk               ;
  wire                            a6_ioclk               ;
  wire                            a7_ioclk               ;
  wire                            a8_ioclk               ;
  wire                            a9_ioclk               ;
  wire                            a10_ioclk              ;
  wire                            a11_ioclk              ;
  wire                            a12_ioclk              ;

  wire                            a13_ioclk              ;

  wire                            a14_ioclk              ;

  wire                            cs_wclk_ca             ;

  wire                            cke_wclk_ca            ;
  wire                            ck_wclk_ca             ;
  wire                            ras_wclk_ca            ;
  wire                            cas_wclk_ca            ;
  wire                            we_wclk_ca             ;
  wire                            odt_wclk_ca            ;
  wire                            ba0_wclk_ca            ;
  wire                            ba1_wclk_ca            ;
  wire                            ba2_wclk_ca            ;
  wire                            a0_wclk_ca             ;
  wire                            a1_wclk_ca             ;
  wire                            a2_wclk_ca             ;
  wire                            a3_wclk_ca             ;
  wire                            a4_wclk_ca             ;
  wire                            a5_wclk_ca             ;
  wire                            a6_wclk_ca             ;
  wire                            a7_wclk_ca             ;
  wire                            a8_wclk_ca             ;
  wire                            a9_wclk_ca             ;
  wire                            a10_wclk_ca            ;
  wire                            a11_wclk_ca            ;
  wire                            a12_wclk_ca            ;
 
  wire                            a13_wclk_ca            ;
 
  wire                            a14_wclk_ca            ;
 

  wire [MEM_CA_GROUP-1:0]         wclk_ca      /* pragma PAP_TIM_MASK_CLOCK_ATTR = 1 */  ;
  wire [MEM_CA_GROUP-1:0]         ioclk_ca     /* pragma PAP_TIM_MASK_CLOCK_ATTR = 1 */  ; 

  wire                            pado_mem_cs_n          ;
  wire                            padt_mem_cs_n          ;

  wire                            pado_mem_ck            ;
  wire                            padt_mem_ck            ;
  wire                            pado_mem_odt           ;
  wire                            padt_mem_odt           ;
  wire                            pado_mem_ras_n         ;
  wire                            padt_mem_ras_n         ;
  wire                            pado_mem_cas_n         ;
  wire                            padt_mem_cas_n         ;
  wire                            pado_mem_we_n          ;
  wire                            padt_mem_we_n          ;
  wire                            pado_mem_cke           ;
  wire                            padt_mem_cke           ;
  wire [MEM_BANKADDR_WIDTH-1:0]   pado_mem_ba            ;
  wire [MEM_BANKADDR_WIDTH-1:0]   padt_mem_ba            ;
  wire [MEM_ADDR_WIDTH-1:0]       pado_mem_a             ;
  wire [MEM_ADDR_WIDTH-1:0]       padt_mem_a             ;


  wire [MEM_DQS_WIDTH-1:0]        ddrphy_ioclk_dq        ;
  wire [MEM_DQS_WIDTH-1:0]        ioclk_dm             /* pragma PAP_TIM_MASK_CLOCK_ATTR = 1 */  ;
  wire [MEM_DQS_WIDTH-1:0]        ioclk_dq             /* pragma PAP_TIM_MASK_CLOCK_ATTR = 1 */  ;
  wire [MEM_DQS_WIDTH-1:0]        wclk_del_dq          /* pragma PAP_TIM_MASK_CLOCK_ATTR = 1 */  ;
  wire [MEM_DQS_WIDTH-1:0]        wclk_del_dm          /* pragma PAP_TIM_MASK_CLOCK_ATTR = 1 */  ;
  wire [8*MEM_DM_WIDTH-1:0]       adj_wrdata_mask        ;
  
  //************************************************// 

 assign ddrphy_ioclk_ca[0]   = ddrphy_ioclk[CA_GROUP0_REG*3];
 assign ddrphy_ioclk_ca[1]   = ddrphy_ioclk[CA_GROUP1_REG*3];
 assign ddrphy_ioclk_ca[2]   = ddrphy_ioclk[CA_GROUP2_REG*3];
 assign ddrphy_ioclk_ca[3]   = ddrphy_ioclk[CA_GROUP3_REG*3];
 assign ddrphy_ioclk_ca[4]   = ddrphy_ioclk[CA_GROUP4_REG*3];


 assign cs_ioclk             = ioclk_ca[CS_GROUP_NUM]; 

 assign cke_ioclk            = ioclk_ca[CKE_GROUP_NUM]; 
 assign ck_ioclk             = ioclk_ca[CK_GROUP_NUM]; 
 assign ras_ioclk            = ioclk_ca[RAS_GROUP_NUM]; 
 assign cas_ioclk            = ioclk_ca[CAS_GROUP_NUM]; 
 assign we_ioclk             = ioclk_ca[WE_GROUP_NUM]; 
 assign odt_ioclk            = ioclk_ca[ODT_GROUP_NUM]; 
 assign ba0_ioclk            = ioclk_ca[BA0_GROUP_NUM]; 
 assign ba1_ioclk            = ioclk_ca[BA1_GROUP_NUM]; 
 assign ba2_ioclk            = ioclk_ca[BA2_GROUP_NUM]; 

 assign a0_ioclk             = ioclk_ca[A0_GROUP_NUM]; 
 assign a1_ioclk             = ioclk_ca[A1_GROUP_NUM]; 
 assign a2_ioclk             = ioclk_ca[A2_GROUP_NUM]; 
 assign a3_ioclk             = ioclk_ca[A3_GROUP_NUM]; 
 assign a4_ioclk             = ioclk_ca[A4_GROUP_NUM]; 
 assign a5_ioclk             = ioclk_ca[A5_GROUP_NUM]; 
 assign a6_ioclk             = ioclk_ca[A6_GROUP_NUM]; 
 assign a7_ioclk             = ioclk_ca[A7_GROUP_NUM]; 
 assign a8_ioclk             = ioclk_ca[A8_GROUP_NUM]; 
 assign a9_ioclk             = ioclk_ca[A9_GROUP_NUM]; 
 assign a10_ioclk            = ioclk_ca[A10_GROUP_NUM]; 
 assign a11_ioclk            = ioclk_ca[A11_GROUP_NUM]; 
 assign a12_ioclk            = ioclk_ca[A12_GROUP_NUM];

 assign a13_ioclk            = ioclk_ca[A13_GROUP_NUM];

 assign a14_ioclk            = ioclk_ca[A14_GROUP_NUM];

 assign cs_wclk_ca           = wclk_ca[CS_GROUP_NUM]; 

 assign cke_wclk_ca          = wclk_ca[CKE_GROUP_NUM]; 
 assign ck_wclk_ca           = wclk_ca[CK_GROUP_NUM]; 
 assign ras_wclk_ca          = wclk_ca[RAS_GROUP_NUM]; 
 assign cas_wclk_ca          = wclk_ca[CAS_GROUP_NUM]; 
 assign we_wclk_ca           = wclk_ca[WE_GROUP_NUM]; 
 assign odt_wclk_ca          = wclk_ca[ODT_GROUP_NUM]; 
 assign ba0_wclk_ca          = wclk_ca[BA0_GROUP_NUM]; 
 assign ba1_wclk_ca          = wclk_ca[BA1_GROUP_NUM]; 
 assign ba2_wclk_ca          = wclk_ca[BA2_GROUP_NUM]; 

 assign a0_wclk_ca           = wclk_ca[A0_GROUP_NUM]; 
 assign a1_wclk_ca           = wclk_ca[A1_GROUP_NUM]; 
 assign a2_wclk_ca           = wclk_ca[A2_GROUP_NUM]; 
 assign a3_wclk_ca           = wclk_ca[A3_GROUP_NUM]; 
 assign a4_wclk_ca           = wclk_ca[A4_GROUP_NUM]; 
 assign a5_wclk_ca           = wclk_ca[A5_GROUP_NUM]; 
 assign a6_wclk_ca           = wclk_ca[A6_GROUP_NUM]; 
 assign a7_wclk_ca           = wclk_ca[A7_GROUP_NUM]; 
 assign a8_wclk_ca           = wclk_ca[A8_GROUP_NUM]; 
 assign a9_wclk_ca           = wclk_ca[A9_GROUP_NUM]; 
 assign a10_wclk_ca          = wclk_ca[A10_GROUP_NUM]; 
 assign a11_wclk_ca          = wclk_ca[A11_GROUP_NUM]; 
 assign a12_wclk_ca          = wclk_ca[A12_GROUP_NUM];

 assign a13_wclk_ca          = wclk_ca[A13_GROUP_NUM];

 assign a14_wclk_ca          = wclk_ca[A14_GROUP_NUM];

assign ddrphy_ioclk_dq[0] = ddrphy_ioclk[GROUP_DQG_0_NUM];

assign ddrphy_ioclk_dq[1] = ddrphy_ioclk[GROUP_DQG_1_NUM];

assign ddrphy_ioclk_dq[2] = ddrphy_ioclk[GROUP_DQG_2_NUM];

assign ddrphy_ioclk_dq[3] = ddrphy_ioclk[GROUP_DQG_3_NUM];



if (DM_GROUP_EN == 1'b0) begin
    assign ioclk_dm = ioclk_dq; 
    assign wclk_del_dm = wclk_del_dq;
end
else begin
    
    assign ioclk_dm = {ioclk_dq[3],ioclk_dq[2],ioclk_dq[0],ioclk_dq[0]};
    assign wclk_del_dm = {wclk_del_dq[3],wclk_del_dq[2],wclk_del_dq[0],wclk_del_dq[0]};

end


//wl 
 assign   wrlvl_error            = |wrlvl_error_tmp            ; 
 assign   wrlvl_dqs_resp         = &wrlvl_dqs_resp_tmp         ;   
 assign   wrlvl_ck_dly_start     = |wrlvl_ck_dly_flag_tmp      ;
 assign   wrlvl_ck_dly_done      = &ck_check_done_tmp          ;
 assign   ck_dly_set_bin_sto     = ck_dly_set_bin_tmp[7:0]     ;
// xuhao                                                       
 assign   adj_rdel_done          = &adj_rdel_done_tmp          ;
 assign   rdel_calib_done        = &rdel_calib_done_tmp        ;
 assign   rdel_calib_error       = |rdel_calib_error_tmp       ;
 assign   rdel_move_done         = &rdel_move_done_tmp         ;
 assign   gate_check_pass        = &gate_check_pass_tmp        ;  
 assign   gate_adj_done          = &gate_adj_done_tmp          ; 
 assign   gate_cal_error         = |gate_cal_error_tmp         ;
 assign   rddata_check_pass      = &rddata_check_pass_tmp      ;   
 assign   gate_check_error       = |gate_check_error_tmp       ; 
 assign   gate_update1_done      = &gate_update1_done_tmp      ;
 assign   gate_update2_done      = &gate_update2_done_tmp      ;
 assign   dqs_gate_check_falling = &dqs_gate_check_falling_tmp ;

//ck_delay

always @(posedge ddrphy_clkin or negedge ddrphy_rst_n)
begin
    if(!ddrphy_rst_n)
      ck_dly_cnt  <= 3'h0;
    else if(wrlvl_ck_dly_done) begin
      if (ck_dly_cnt == 3'h6)
        ck_dly_cnt  <= ck_dly_cnt;
      else
        ck_dly_cnt  <= ck_dly_cnt + 3'h1;
    end
end

always @(posedge ddrphy_clkin or negedge ddrphy_rst_n)
begin
    if(!ddrphy_rst_n)
      wrlvl_ck_dly_start_rst  <= 1'b0;
    else if(wrlvl_ck_dly_done & (ck_dly_cnt == 3'h6))
      wrlvl_ck_dly_start_rst  <= 1'b1;
end

ipsxb_rst_sync_v1_1 #(
  .DATA_WIDTH     (1                     ),
  .DFT_VALUE      (1'b0                  )
) u_logic_rstn_sync(
  .clk            (ddrphy_clkin          ),
  .rst_n          (logic_rstn            ),
  .sig_async      (1'b1                  ),
  .sig_synced     (logic_ck_rstn         )
);

always @(posedge ddrphy_clkin or negedge logic_ck_rstn)
begin
    if(!logic_ck_rstn)
      ck_dly_set_bin         <= 8'h0;
    else if(force_ck_dly_en)
      ck_dly_set_bin         <= force_ck_dly_set_bin;
    else if(wrlvl_ck_dly_done) begin
      if (ck_dly_cnt < 3'h6)
          ck_dly_set_bin         <= ck_dly_set_bin + 8'd1;
      else
          ck_dly_set_bin         <= ck_dly_set_bin;
    end
    else if(wrlvl_ck_dly_start)
      ck_dly_set_bin         <= ck_dly_set_bin_sto;
end

////wrdata  reorder                                                                                                                   
always @(*) 
begin
    for (i=0; i<8; i=i+1) begin
        for (j=0; j<MEM_DQ_WIDTH; j=j+1)            
            phy_wrdata_reorder[j*8 + i] = phy_wrdata[i*MEM_DQ_WIDTH+j];
    end
end

// write_data_mask_reorder                                                                
always @(*) 
begin
    for (i=0; i<8; i=i+1) begin
        for (j=0; j<MEM_DM_WIDTH; j=j+1)          
            phy_wrdata_mask_reorder[j*8 + i] = phy_wrdata_mask[i*MEM_DM_WIDTH+j];
    end
end
 
//rddata reorder
always @(*)
begin                                                        
    for (i=0; i<8; i=i+1) begin                                           
        for (j=0; j<MEM_DQ_WIDTH; j=j+1)                                 
          o_read_data[i*MEM_DQ_WIDTH + j] = dqs_align_data[j*8 + i];
    end
end                                                                      

assign read_valid = dqs_align_valid ;

//bank reoder
always @(*) 
begin
    for (i=0; i<4; i=i+1) begin
        for (j=0;j<MEM_BANKADDR_WIDTH ; j=j+1)
            phy_ba_reorder[j*4+i] = phy_ba[i*MEM_BANKADDR_WIDTH + j] ;
    end
end
 
//addr reoder
always @(*)
begin
    for (i=0; i<4; i=i+1) begin
        for (j=0;j<MEM_ADDR_WIDTH;j=j+1)
            phy_addr_reorder[j*4+i] = phy_addr[i*MEM_ADDR_WIDTH+j];
    end
end                                                            

genvar gen_d;
generate
  for(gen_d=0; gen_d<MEM_DQS_WIDTH; gen_d=gen_d+1) begin   : i_dqs_group
    ipsxb_ddrphy_data_slice_v1_4 #(
      .WL_EN            (1      ),       
      .INIT_WRLVL_STEP  (8'h0   ),
      .WL_MAX_STEP      (8'hff  ),
      .WL_MAX_CHECK     (5'h1f  ),
      .WL_SETTING       (0      ), 
      .RDEL_ADJ_MAX_RANG( 8'h1f ),
      .MIN_DQSI_WIN     ( 10    ),
      .WL_EXTEND        (WL_EXTEND)
    ) u_ddrphy_data_slice( 
      .mc_rl                     (mc_rl                                       ),         
      .init_read_clk_ctrl        (init_read_clk_ctrl                          ),
      .init_slip_step            (init_slip_step                              ),
      .init_samp_position        (init_samp_position                          ),
      
      .ddrphy_clkin              (ddrphy_clkin                                ),            
      .ddrphy_rst_n              (ddrphy_rst_n                                ),
      .ddrphy_ioclk              (ddrphy_ioclk_dq[gen_d]                      ),
      .ddrphy_dqs_rst            (ddrphy_dqs_rst                              ),
      .ddrphy_dqs_training_rstn  (ddrphy_dqs_training_rstn                    ),
      .ddrphy_iodly_ctrl         (ddrphy_iodly_ctrl                           ),
      
      .ddrphy_wl_ctrl            (ddrphy_wl_ctrl                              ),                                         
      .wrlvl_dqs_req             (wrlvl_dqs_req                               ),            
      .wrlvl_dqs_resp            (wrlvl_dqs_resp_tmp[gen_d]                   ),            
      .wrlvl_error               (wrlvl_error_tmp[gen_d]                      ),          
      .man_wrlvl_dqs             (man_wrlvl_dqs                               ),
      
      .gatecal_start             (gatecal_start                               ),
      .gate_check_pass           (gate_check_pass_tmp[gen_d]                  ),
      .gate_adj_done             (gate_adj_done_tmp[gen_d]                    ),
      .gate_cal_error            (gate_cal_error_tmp[gen_d]                   ),
      .gate_move_en              (gate_move_en                                ), 
      .gate_check_error          (gate_check_error_tmp[gen_d]                 ),
      .rddata_cal                (rddata_cal                                  ), 
      .rddata_check_pass         (rddata_check_pass_tmp[gen_d]                ),
      .dqs_gate_update1          (dqs_gate_update1                            ),
      .dqs_gate_update2          (dqs_gate_update2                            ),
      .gate_update1_done         (gate_update1_done_tmp[gen_d]                ),
      .gate_update2_done         (gate_update2_done_tmp[gen_d]                ),
      .dqs_gate_check_falling    (dqs_gate_check_falling_tmp[gen_d]           ),
      .wrlvl_ck_dly_flag         (wrlvl_ck_dly_flag_tmp[gen_d]                ),
      .wrlvl_ck_dly_done         (wrlvl_ck_dly_done                           ),
      .wrlvl_ck_dly_start        (wrlvl_ck_dly_start                          ),
      .ck_check_done             (ck_check_done_tmp[gen_d]                    ),
      .ck_dly_set_bin_tra        (ck_dly_set_bin_tmp[8*gen_d+7:8*gen_d]       ),
      .force_ck_dly_en           (force_ck_dly_en                             ),
      
      .force_read_clk_ctrl       (force_read_clk_ctrl                         ),
      .read_cmd                  (read_cmd                                    ),  
      .ddrphy_read_valid         (ddrphy_read_valid[gen_d]                    ),

      .dqs_drift                 (dqs_drift[2*gen_d+1:2*gen_d]                ),
      
      .force_samp_position       (force_samp_position                         ),
      .dll_step                  (dll_step                                    ),
      
      .init_adj_rdel             (init_adj_rdel                               ),
      .reinit_adj_rdel           (reinit_adj_rdel                             ),
      .adj_rdel_done             (adj_rdel_done_tmp[gen_d]                    ),  
      .rdel_calibration          (rdel_calibration                            ),
      .rdel_calib_done           (rdel_calib_done_tmp[gen_d]                  ),
      .rdel_calib_error          (rdel_calib_error_tmp[gen_d]                 ),
      .rdel_move_en              (rdel_move_en                                ),
      .rdel_move_done            (rdel_move_done_tmp[gen_d]                   ),
      
      .read_valid                (dqs_read_valid[gen_d]                       ),
      .read_data                 (dqs_read_data[64*gen_d+63:64*gen_d]         ),

      .adj_wrdata_mask           (adj_wrdata_mask[8*gen_d+7:8*gen_d]          ),
      .ioclk_dq                  (ioclk_dq[gen_d]                             ),
      .ioclk_dm                  (ioclk_dm[gen_d]                             ),
      .wclk_del                  (wclk_del_dq[gen_d]                          ),
      .wclk_del_dm               (wclk_del_dm[gen_d]                          ),
     
      .phy_wrdata_en             (phy_wrdata_en                               ), 
      .phy_wrdata_mask           (phy_wrdata_mask_reorder[8*gen_d+7 : 8*gen_d]), 
      .phy_wrdata                (phy_wrdata_reorder[64*gen_d+63:64*gen_d]    ),
      .dqs                       (mem_dqs[gen_d]                              ),
      .dqs_n                     (mem_dqs_n[gen_d]                            ),
      .dq                        (mem_dq[8*gen_d+7 : 8*gen_d]                 ),
      .dm                        (mem_dm[gen_d]                               ),
      .debug_data                (debug_data[34*gen_d+33:34*gen_d]            ),
      .debug_slice_state         (debug_slice_state[13*gen_d+12:13*gen_d]     )
    ); 
  end    
endgenerate


ipsxb_ddrphy_slice_rddata_align_v1_0 #(
 .MEM_DQ_WIDTH      (MEM_DQ_WIDTH    ),
 .MEM_DQS_WIDTH     (MEM_DQS_WIDTH   )
) u_slice_rddata_align(
 .ddrphy_clkin      (ddrphy_clkin    ),   
 .ddrphy_rst_n      (ddrphy_rst_n    ),  

 .dqs_read_valid    (dqs_read_valid  ),       
 .dqs_read_data     (dqs_read_data   ),

 .dqs_align_valid   (dqs_align_valid ),
 .dqs_align_data    (dqs_align_data  ),                                                                                                                                          
 .align_error       (align_error     )
);                                                            
  
ipsxb_ddrphy_control_path_adj_v1_0 #(
  .MEM_ADDR_WIDTH      (MEM_ADDR_WIDTH    ),
  .MEM_BANKADDR_WIDTH  (MEM_BANKADDR_WIDTH),
  .SLIP_BIT_NUM        (1                 )     
) u_control_path_adj(
  .ddrphy_clkin        (ddrphy_clkin      ),
  .ddrphy_rst_n        (ddrphy_rst_n      ),

  .phy_cke             (phy_cke           ),
  .phy_cs_n            (phy_cs_n          ),
  .phy_ras_n           (phy_ras_n         ),
  .phy_cas_n           (phy_cas_n         ),
  .phy_we_n            (phy_we_n          ),
  .phy_addr            (phy_addr_reorder  ),
  .phy_ba              (phy_ba_reorder    ),
  .phy_odt             (phy_odt           ),
  .phy_ck              (phy_ck            ),
  .adj_cke             (adj_cke           ),
  .adj_cs_n            (adj_cs_n          ),
  .adj_ras_n           (adj_ras_n         ),
  .adj_cas_n           (adj_cas_n         ),
  .adj_we_n            (adj_we_n          ),
  .adj_addr            (adj_addr          ),
  .adj_ba              (adj_ba            ),
  .adj_odt             (adj_odt           ),
  .adj_ck              (adj_ck            )
); 


genvar gen_ca;
generate
   for(gen_ca=0; gen_ca<MEM_CA_GROUP; gen_ca=gen_ca+1) begin   : i_ca_group
  GTP_DDC_E1    #(
    .GRS_EN             ("FALSE"    ),    //"true"; "false"
    .DDC_MODE           ("QUAD_RATE"),    //"full_rate"; "half_rate"; "quad_rate"
    .IFIFO_GENERIC      ("FALSE"    ),    //"true"; "false"
    .WCLK_DELAY_OFFSET  (0          ),    //0~255
    .DQSI_DELAY_OFFSET  (0          ),    //0~255
    .CLKA_GATE_EN       ("FALSE"    ),    
    .R_DELAY_STEP_EN    ("TRUE"     ),    //"true"; "false"
    .R_MOVE_EN          ("TRUE"     ),    //"true"; "false"
    .W_MOVE_EN          ("FALSE"    ),    //"true"; "false"
    .R_EXTEND           ("TRUE"     ),    //"true"; "false" --2015.12029.ln
    .GATE_SEL           ("TRUE"     ),
    .WCLK_DELAY_SEL     ("FALSE"     ),    //wclk --> wclk_del 90 deg
    .RADDR_INIT         (3'd0       )   
   ) u_ddc_ca(
   //output
   .WDELAY_OB                            ( ),
   .WCLK                                 (wclk_ca[gen_ca] ),
   .WCLK_DELAY                           (),
   .RCLK                                 (ioclk_ca[gen_ca]),
   .RDELAY_OB                            (),
   .DQSI_DELAY                           (),
   .DGTS                                 (),
   .READ_VALID                           (),
   .GATE_OUT                             (),
   .IFIFO_WADDR                          (),
   .IFIFO_RADDR                          (),
   .DQS_DRIFT                            (),
   .DRIFT_DETECT_ERR                     (),
   .DQS_DRIFT_STATUS                     (),
    //input                              (),
   .RST                                  (ddrphy_dqs_rst),//dqs_rst
   .CLKB                                 (ddrphy_clkin),//glck
   .CLKA                                 (ddrphy_ioclk_ca[gen_ca]),
   .CLKA_GATE                            (1'b1),
   .DELAY_STEP1                          (dll_step),
   .DELAY_STEP0                          (ck_dly_set_bin),
   .W_DIRECTION                          (1'b0),
   .W_MOVE                               (1'b0),
   .W_LOAD_N                             (1'b0),
   .DQS_GATE_CTRL                        (4'd0),
   .READ_CLK_CTRL                        (3'd0),
   .DQSI                                 (),
   .GATE_IN                              (),
   .R_DIRECTION                          (1'b0),
   .R_MOVE                               (1'b0),
   .R_LOAD_N                             (1'b0),
   .RST_TRAINING_N                       (ddrphy_dqs_training_rstn)
);

  end     
endgenerate

// cs_n
  GTP_OSERDES #(
     .OSERDES_MODE ("OMSER8"),
     .WL_EXTEND    (WL_EXTEND)
  )  u_oserdes_csn (
  .DI        (adj_cs_n),
  .TI        (4'b0000),
  .SERCLK    (cs_ioclk),
  .RCLK      (ddrphy_clkin),
  .OCLK      (cs_wclk_ca),
  .RST       (ddrphy_dqs_rst),
  .DO        (pado_mem_cs_n),
  .TQ        (padt_mem_cs_n)
  );
  
  GTP_OUTBUFT  u_outbuft_csn
  (
      .O     (mem_cs_n),
      .I     (pado_mem_cs_n),
      .T     (padt_mem_cs_n)
  );


//odt
GTP_OSERDES #(
   .OSERDES_MODE ("OMSER8"),
   .WL_EXTEND    (WL_EXTEND)
)  u_oserdes_odt (
.DI        (adj_odt),
.TI        (4'b0000),
.SERCLK    (odt_ioclk),
.RCLK      (ddrphy_clkin),
.OCLK      (odt_wclk_ca),
.RST       (ddrphy_dqs_rst),
.DO        (pado_mem_odt),
.TQ        (padt_mem_odt)
);

GTP_OUTBUFT  u_outbuft_odt
(
    .O     (mem_odt),
    .I     (pado_mem_odt),
    .T     (padt_mem_odt)
);

// cke
 GTP_OSERDES #(
    .OSERDES_MODE ("OMSER8"),
    .WL_EXTEND    (WL_EXTEND)
 )  u_oserdes_cke (
 .DI        (adj_cke),
 .TI        (4'b0000),
 .SERCLK    (cke_ioclk),
 .RCLK      (ddrphy_clkin),
 .OCLK      (cke_wclk_ca),
 .RST       (ddrphy_dqs_rst),
 .DO        (pado_mem_cke),
 .TQ        (padt_mem_cke)
 );
 
 GTP_OUTBUFT  u_outbuft_cke
 (
     .O     (mem_cke),
     .I     (pado_mem_cke),
     .T     (padt_mem_cke)
 );

GTP_OSERDES #(
  .OSERDES_MODE ("OMSER8"),
  .WL_EXTEND    (WL_EXTEND)
)  u_oserdes_ba0 (
      .DI        (adj_ba[0*8+7:0*8]),
      .TI        (4'b0000),
      .SERCLK    (ba0_ioclk ),
      .RCLK      (ddrphy_clkin),
      .OCLK      (ba0_wclk_ca),
      .RST       (ddrphy_dqs_rst),
      .DO        (pado_mem_ba[0]),
      .TQ        (padt_mem_ba[0])
      );

  GTP_OUTBUFT  u_outbuft_ba0
  (
      .O     (mem_ba[0]),
      .I     (pado_mem_ba[0]),
      .T     (padt_mem_ba[0])
  );

  GTP_OSERDES #(
    .OSERDES_MODE ("OMSER8"),
    .WL_EXTEND    (WL_EXTEND)
  ) u_oserdes_addr_0 (
      .DI        (adj_addr[0*8+7:0*8]),
      .TI        (4'b0000),
      .SERCLK    (a0_ioclk),
      .RCLK      (ddrphy_clkin),
      .OCLK      (a0_wclk_ca),
      .RST       (ddrphy_dqs_rst),
      .DO        (pado_mem_a[0]),
      .TQ        (padt_mem_a[0])
      );

  GTP_OUTBUFT  u_outbuft_addr_0
  (
      .O     (mem_a[0]),
      .I     (pado_mem_a[0]),
      .T     (padt_mem_a[0])
  );

   GTP_OSERDES #(
   .OSERDES_MODE ("OMSER8"),
   .WL_EXTEND    (WL_EXTEND)
 ) u_oserdes_addr_5 (
     .DI        (adj_addr[5*8+7:5*8]),
     .TI        (4'b0000),
     .SERCLK    (a5_ioclk),
     .RCLK      (ddrphy_clkin),
     .OCLK      (a5_wclk_ca),
     .RST       (ddrphy_dqs_rst),
     .DO        (pado_mem_a[5]),
     .TQ        (padt_mem_a[5])
     );

 GTP_OUTBUFT  u_outbuft_addr_5
 (
     .O     (mem_a[5]),
     .I     (pado_mem_a[5]),
     .T     (padt_mem_a[5])
 );

    GTP_OSERDES #(
   .OSERDES_MODE ("OMSER8"),
   .WL_EXTEND    (WL_EXTEND)
 ) u_oserdes_addr_12 (
     .DI        (adj_addr[12*8+7:12*8]),
     .TI        (4'b0000),
     .SERCLK    (a12_ioclk),
     .RCLK      (ddrphy_clkin),
     .OCLK      (a12_wclk_ca),
     .RST       (ddrphy_dqs_rst),
     .DO        (pado_mem_a[12]),
     .TQ        (padt_mem_a[12])
     );

 GTP_OUTBUFT  u_outbuft_addr_12
 (
     .O     (mem_a[12]),
     .I     (pado_mem_a[12]),
     .T     (padt_mem_a[12])
 );

  GTP_OSERDES #(
    .OSERDES_MODE ("OMSER8"),
    .WL_EXTEND    (WL_EXTEND)
  ) u_oserdes_addr_3 (
      .DI        (adj_addr[3*8+7:3*8]),
      .TI        (4'b0000),
      .SERCLK    (a3_ioclk),
      .RCLK      (ddrphy_clkin),
      .OCLK      (a3_wclk_ca),
      .RST       (ddrphy_dqs_rst),
      .DO        (pado_mem_a[3]),
      .TQ        (padt_mem_a[3])
      );

  GTP_OUTBUFT  u_outbuft_addr_3
  (
      .O     (mem_a[3]),
      .I     (pado_mem_a[3]),
      .T     (padt_mem_a[3])
  );


// ck
GTP_OSERDES #(
   .OSERDES_MODE ("OMSER8"),
   .WL_EXTEND    (WL_EXTEND)
)  u_oserdes_ck (
.DI        (adj_ck),
.TI        (4'b0000),
.SERCLK    (ck_ioclk),
.RCLK      (ddrphy_clkin),
.OCLK      (ck_wclk_ca),
.RST       (ddrphy_dqs_rst),
.DO        (pado_mem_ck),
.TQ        (padt_mem_ck)
);

 GTP_OUTBUFTCO u_outbuftco_ck
 (
 .O    (mem_ck),
 .OB   (mem_ck_n),
 .I    (pado_mem_ck),
 .T    (padt_mem_ck)
 );

GTP_OSERDES #(
  .OSERDES_MODE ("OMSER8"),
  .WL_EXTEND    (WL_EXTEND)
)  u_oserdes_ba2 (
      .DI        (adj_ba[2*8+7:2*8]),
      .TI        (4'b0000),
      .SERCLK    (ba2_ioclk ),
      .RCLK      (ddrphy_clkin),
      .OCLK      (ba2_wclk_ca),
      .RST       (ddrphy_dqs_rst),
      .DO        (pado_mem_ba[2]),
      .TQ        (padt_mem_ba[2])
      );

  GTP_OUTBUFT  u_outbuft_ba2
  (
      .O     (mem_ba[2]),
      .I     (pado_mem_ba[2]),
      .T     (padt_mem_ba[2])
  ); 

   // we_n
   GTP_OSERDES #(
      .OSERDES_MODE ("OMSER8"),
      .WL_EXTEND    (WL_EXTEND)
   )  u_oserdes_wen (
   .DI        (adj_we_n),
   .TI        (4'b0000),
   .SERCLK    (we_ioclk),
   .RCLK      (ddrphy_clkin),
   .OCLK      (we_wclk_ca),
   .RST       (ddrphy_dqs_rst),
   .DO        (pado_mem_we_n),
   .TQ        (padt_mem_we_n)
   );
   
   GTP_OUTBUFT  u_outbuft_wen
   (
       .O     (mem_we_n),
       .I     (pado_mem_we_n),
       .T     (padt_mem_we_n)
   );


// ras_n
GTP_OSERDES #(
   .OSERDES_MODE ("OMSER8"),
   .WL_EXTEND    (WL_EXTEND)
)  u_oserdes_rasn (
.DI        (adj_ras_n),
.TI        (4'b0000),
.SERCLK    (ras_ioclk),
.RCLK      (ddrphy_clkin),
.OCLK      (ras_wclk_ca),
.RST       (ddrphy_dqs_rst),
.DO        (pado_mem_ras_n),
.TQ        (padt_mem_ras_n)
);

GTP_OUTBUFT  u_outbuft_rasn
(
    .O     (mem_ras_n),
    .I     (pado_mem_ras_n),
    .T     (padt_mem_ras_n)
);

    GTP_OSERDES #(
   .OSERDES_MODE ("OMSER8"),
   .WL_EXTEND    (WL_EXTEND)
 ) u_oserdes_addr_2 (
     .DI        (adj_addr[2*8+7:2*8]),
     .TI        (4'b0000),
     .SERCLK    (a2_ioclk),
     .RCLK      (ddrphy_clkin),
     .OCLK      (a2_wclk_ca),
     .RST       (ddrphy_dqs_rst),
     .DO        (pado_mem_a[2]),
     .TQ        (padt_mem_a[2])
     );

 GTP_OUTBUFT  u_outbuft_addr_2
 (
     .O     (mem_a[2]),
     .I     (pado_mem_a[2]),
     .T     (padt_mem_a[2])
 );

 GTP_OSERDES #(
   .OSERDES_MODE ("OMSER8"),
   .WL_EXTEND    (WL_EXTEND)
 ) u_oserdes_addr_6 (
     .DI        (adj_addr[6*8+7:6*8]),
     .TI        (4'b0000),
     .SERCLK    (a6_ioclk),
     .RCLK      (ddrphy_clkin),
     .OCLK      (a6_wclk_ca),
     .RST       (ddrphy_dqs_rst),
     .DO        (pado_mem_a[6]),
     .TQ        (padt_mem_a[6])
     );

 GTP_OUTBUFT  u_outbuft_addr_6
 (
     .O     (mem_a[6]),
     .I     (pado_mem_a[6]),
     .T     (padt_mem_a[6])
 );

  GTP_OSERDES #(
    .OSERDES_MODE ("OMSER8"),
    .WL_EXTEND    (WL_EXTEND)
  ) u_oserdes_addr_8 (
      .DI        (adj_addr[8*8+7:8*8]),
      .TI        (4'b0000),
      .SERCLK    (a8_ioclk),
      .RCLK      (ddrphy_clkin),
      .OCLK      (a8_wclk_ca),
      .RST       (ddrphy_dqs_rst),
      .DO        (pado_mem_a[8]),
      .TQ        (padt_mem_a[8])
      );

  GTP_OUTBUFT  u_outbuft_addr_8
  (
      .O     (mem_a[8]),
      .I     (pado_mem_a[8]),
      .T     (padt_mem_a[8])
  ); 

//cas_n 
   GTP_OSERDES #(
    .OSERDES_MODE ("OMSER8"),
    .WL_EXTEND    (WL_EXTEND)
   )  u_oserdes_casn (
   .DI        (adj_cas_n),
   .TI        (4'b0000),
   .SERCLK    (cas_ioclk),
   .RCLK      (ddrphy_clkin),
   .OCLK      (cas_wclk_ca),
   .RST       (ddrphy_dqs_rst),
   .DO        (pado_mem_cas_n),
   .TQ        (padt_mem_cas_n)
   );
   
   GTP_OUTBUFT  u_outbuft_casn
   (
       .O     (mem_cas_n),
       .I     (pado_mem_cas_n),
       .T     (padt_mem_cas_n)
 );    



  GTP_OSERDES #(
    .OSERDES_MODE ("OMSER8"),
    .WL_EXTEND    (WL_EXTEND)
  ) u_oserdes_addr_14 (
      .DI        (adj_addr[14*8+7:14*8]),
      .TI        (4'b0000),
      .SERCLK    (a14_ioclk),
      .RCLK      (ddrphy_clkin),
      .OCLK      (a14_wclk_ca),
      .RST       (ddrphy_dqs_rst),
      .DO        (pado_mem_a[14]),
      .TQ        (padt_mem_a[14])
      );

  GTP_OUTBUFT  u_outbuft_addr_14
  (
      .O     (mem_a[14]),
      .I     (pado_mem_a[14]),
      .T     (padt_mem_a[14])
  );


  GTP_OSERDES #(
    .OSERDES_MODE ("OMSER8"),
    .WL_EXTEND    (WL_EXTEND)
  ) u_oserdes_addr_9 (
      .DI        (adj_addr[9*8+7:9*8]),
      .TI        (4'b0000),
      .SERCLK    (a9_ioclk),
      .RCLK      (ddrphy_clkin),
      .OCLK      (a9_wclk_ca),
      .RST       (ddrphy_dqs_rst),
      .DO        (pado_mem_a[9]),
      .TQ        (padt_mem_a[9])
      );

  GTP_OUTBUFT  u_outbuft_addr_9
  (
      .O     (mem_a[9]),
      .I     (pado_mem_a[9]),
      .T     (padt_mem_a[9])
  );

   GTP_OSERDES #(
   .OSERDES_MODE ("OMSER8"),
   .WL_EXTEND    (WL_EXTEND)
 ) u_oserdes_addr_1 (
     .DI        (adj_addr[1*8+7:1*8]),
     .TI        (4'b0000),
     .SERCLK    (a1_ioclk),
     .RCLK      (ddrphy_clkin),
     .OCLK      (a1_wclk_ca),
     .RST       (ddrphy_dqs_rst),
     .DO        (pado_mem_a[1]),
     .TQ        (padt_mem_a[1])
     );

 GTP_OUTBUFT  u_outbuft_addr_1
 (
     .O     (mem_a[1]),
     .I     (pado_mem_a[1]),
     .T     (padt_mem_a[1])
 );

    GTP_OSERDES #(
   .OSERDES_MODE ("OMSER8"),
   .WL_EXTEND    (WL_EXTEND)
 ) u_oserdes_addr_10 (
     .DI        (adj_addr[10*8+7:10*8]),
     .TI        (4'b0000),
     .SERCLK    (a10_ioclk),
     .RCLK      (ddrphy_clkin),
     .OCLK      (a10_wclk_ca),
     .RST       (ddrphy_dqs_rst),
     .DO        (pado_mem_a[10]),
     .TQ        (padt_mem_a[10])
     );

 GTP_OUTBUFT  u_outbuft_addr_10
 (
     .O     (mem_a[10]),
     .I     (pado_mem_a[10]),
     .T     (padt_mem_a[10])
 );

   GTP_OSERDES #(
   .OSERDES_MODE ("OMSER8"),
   .WL_EXTEND    (WL_EXTEND)
 ) u_oserdes_addr_11 (
     .DI        (adj_addr[11*8+7:11*8]),
     .TI        (4'b0000),
     .SERCLK    (a11_ioclk),
     .RCLK      (ddrphy_clkin),
     .OCLK      (a11_wclk_ca),
     .RST       (ddrphy_dqs_rst),
     .DO        (pado_mem_a[11]),
     .TQ        (padt_mem_a[11])
     );

 GTP_OUTBUFT  u_outbuft_addr_11
 (
     .O     (mem_a[11]),
     .I     (pado_mem_a[11]),
     .T     (padt_mem_a[11])
 );
        
GTP_OSERDES #(
  .OSERDES_MODE ("OMSER8"),
  .WL_EXTEND    (WL_EXTEND)
)  u_oserdes_ba1 (
      .DI        (adj_ba[1*8+7:1*8]),
      .TI        (4'b0000),
      .SERCLK    (ba1_ioclk ),
      .RCLK      (ddrphy_clkin),
      .OCLK      (ba1_wclk_ca),
      .RST       (ddrphy_dqs_rst),
      .DO        (pado_mem_ba[1]),
      .TQ        (padt_mem_ba[1])
      );

  GTP_OUTBUFT  u_outbuft_ba1
  (
      .O     (mem_ba[1]),
      .I     (pado_mem_ba[1]),
      .T     (padt_mem_ba[1])
  );  

   GTP_OSERDES #(
   .OSERDES_MODE ("OMSER8"),
   .WL_EXTEND    (WL_EXTEND)
 ) u_oserdes_addr_7 (
     .DI        (adj_addr[7*8+7:7*8]),
     .TI        (4'b0000),
     .SERCLK    (a7_ioclk),
     .RCLK      (ddrphy_clkin),
     .OCLK      (a7_wclk_ca),
     .RST       (ddrphy_dqs_rst),
     .DO        (pado_mem_a[7]),
     .TQ        (padt_mem_a[7])
     );

 GTP_OUTBUFT  u_outbuft_addr_7
 (
     .O     (mem_a[7]),
     .I     (pado_mem_a[7]),
     .T     (padt_mem_a[7])
 );  

  GTP_OSERDES #(
    .OSERDES_MODE ("OMSER8"),
    .WL_EXTEND    (WL_EXTEND)
  ) u_oserdes_addr_4 (
      .DI        (adj_addr[4*8+7:4*8]),
      .TI        (4'b0000),
      .SERCLK    (a4_ioclk),
      .RCLK      (ddrphy_clkin),
      .OCLK      (a4_wclk_ca),
      .RST       (ddrphy_dqs_rst),
      .DO        (pado_mem_a[4]),
      .TQ        (padt_mem_a[4])
      );

  GTP_OUTBUFT  u_outbuft_addr_4
  (
      .O     (mem_a[4]),
      .I     (pado_mem_a[4]),
      .T     (padt_mem_a[4])
  );  



  GTP_OSERDES #(
    .OSERDES_MODE ("OMSER8"),
    .WL_EXTEND    (WL_EXTEND)
  ) u_oserdes_addr_13 (
      .DI        (adj_addr[13*8+7:13*8]),
      .TI        (4'b0000),
      .SERCLK    (a13_ioclk),
      .RCLK      (ddrphy_clkin),
      .OCLK      (a13_wclk_ca),
      .RST       (ddrphy_dqs_rst),
      .DO        (pado_mem_a[13]),
      .TQ        (padt_mem_a[13])
      );

  GTP_OUTBUFT  u_outbuft_addr_13
  (
      .O     (mem_a[13]),
      .I     (pado_mem_a[13]),
      .T     (padt_mem_a[13])
 );


assign mem_rst_n = phy_rst ;

endmodule

