`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:Meyesemi 
// Engineer: Will
// 
// Create Date: 2023-03-17  
// Design Name:  
// Module Name: 
// Project Name: 
// Target Devices: Pango
// Tool Versions: 
// Description: 
//      
// Dependencies: 
// 
// Revision:
// Revision 1.0 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//camera中寄存器的配置程序
 module ov5640_reg_config(     
		  input clk_25M,
		  input camera_rstn,
		  input initial_en,
		  output reg_conf_done,
		  output i2c_sclk,
		  inout i2c_sdat,
		  output reg clock_20k,
		  output reg [8:0]reg_index
	  );

     reg [15:0]clock_20k_cnt;
     reg [1:0]config_step;	  
     reg [31:0]i2c_data;
     reg [23:0]reg_data;
     reg start;
	 reg reg_conf_done_reg;
	  
     i2c_com u1(.clock_i2c(clock_20k),
               .camera_rstn(camera_rstn),
               .ack(ack),
               .i2c_data(i2c_data),
               .start(start),
               .tr_end(tr_end),
               .i2c_sclk(i2c_sclk),
               .i2c_sdat(i2c_sdat));

assign reg_conf_done=reg_conf_done_reg;
//产生i2c控制时钟-20khz    
always@(posedge clk_25M)   
begin
   if(!camera_rstn) begin
        clock_20k<=0;
        clock_20k_cnt<=0;
   end
   else if(clock_20k_cnt<1249)
      clock_20k_cnt<=clock_20k_cnt+1'b1;
   else begin
         clock_20k<=!clock_20k;
         clock_20k_cnt<=0;
   end
end


////iic寄存器配置过程控制    
always@(posedge clock_20k)    
begin
   if(!camera_rstn) begin
       config_step<=0;
       start<=0;
       reg_index<=0;
		 reg_conf_done_reg<=0;
   end
   else begin
      if(reg_conf_done_reg==1'b0) begin          //如果camera初始化未完成
			  if(reg_index<360) begin               //配置寄存器
					 case(config_step)
					 0:begin
						i2c_data<={8'h78,reg_data};       //OV5640 IIC Device address is 0x78   
						start<=1;                         //i2c写开始
						config_step<=1;                  
					 end
					 1:begin
						if(tr_end) begin                  //i2c写结束               					
							 start<=0;
							 config_step<=2;
						end
					 end
					 2:begin
						  reg_index<=reg_index+1'b1;       //配置下一个寄存器
						  config_step<=0;
					 end
					 endcase
				end
			 else 
				reg_conf_done_reg<=1'b1;                //OV5640寄存器初始化完成
      end
   end
 end
			
////iic需要配置的寄存器值  			
always@(reg_index)   
 begin
    case(reg_index)
	 0    :reg_data   <=24'h310311 ;//      
	 1    :reg_data   <=24'h300882 ;//      
	 102  :reg_data   <=24'h300842 ;//      
	 103  :reg_data   <=24'h310303 ;//      
	 104  :reg_data   <=24'h3017ff ;//      
	 105  :reg_data   <=24'h3018ff ;//      
	 106  :reg_data   <=24'h30341A ;//      
	 107  :reg_data   <=24'h303713 ;//      
	 108  :reg_data   <=24'h310801 ;//      
	 109  :reg_data   <=24'h363036 ;//      
	 110  :reg_data   <=24'h36310e ;//       
	 111  :reg_data   <=24'h3632e2 ;//       
	 112  :reg_data   <=24'h363312 ;//       
	 113  :reg_data   <=24'h3621e0 ;//       
	 114  :reg_data   <=24'h3704a0 ;//       
	 115  :reg_data   <=24'h37035a ;//       
	 116  :reg_data   <=24'h371578 ;//       
	 117  :reg_data   <=24'h371701 ;//       
	 118  :reg_data   <=24'h370b60 ;//       
	 119  :reg_data   <=24'h37051a ;//       
	 120  :reg_data   <=24'h390502 ;//       
	 121  :reg_data   <=24'h390610 ;//       
	 122  :reg_data   <=24'h39010a ;//       
	 123  :reg_data   <=24'h373112 ;//       
	 124  :reg_data   <=24'h360008 ;//       
	 125  :reg_data   <=24'h360133 ;//       
	 126  :reg_data   <=24'h302d60 ;//       
	 127  :reg_data   <=24'h362052 ;//       
	 128  :reg_data   <=24'h371b20 ;//       
	 129  :reg_data   <=24'h471c50 ;//       
	 130  :reg_data   <=24'h3a1343 ;//       
	 131  :reg_data   <=24'h3a1800 ;//       
	 132  :reg_data   <=24'h3a19f8 ;//       
	 133  :reg_data   <=24'h363513 ;//       
	 134  :reg_data   <=24'h363603 ;//       
	 135  :reg_data   <=24'h363440 ;//       
	 136  :reg_data   <=24'h362201 ;///      
	 137  :reg_data   <=24'h3c0134 ;//       
	 138  :reg_data   <=24'h3c0428 ;//       
	 139  :reg_data   <=24'h3c0598 ;//       
	 140  :reg_data   <=24'h3c0600 ;//       
     141  :reg_data   <=24'h3c0708 ;//       
	 142  :reg_data   <=24'h3c0800 ;//       
	 143  :reg_data   <=24'h3c091c ;//       
	 144  :reg_data   <=24'h3c0a9c ;//       
	 145  :reg_data   <=24'h3c0b40 ;//       
	 146  :reg_data   <=24'h381000 ;//       
	 147  :reg_data   <=24'h381110 ;//       
	 148  :reg_data   <=24'h381200 ;//       
	 149  :reg_data   <=24'h370864 ;//       
	 150  :reg_data   <=24'h400102 ;//       
	 151  :reg_data   <=24'h40051a ;//       
	 152  :reg_data   <=24'h300000 ;//       
	 153  :reg_data   <=24'h3004ff ;//       
	 154  :reg_data   <=24'h300e58 ;//       
	 155  :reg_data   <=24'h302e00 ;//       
	 156  :reg_data   <=24'h430060 ;//       
	 157  :reg_data   <=24'h501f01 ;//       
	 158  :reg_data   <=24'h440e00 ;//       
	 159  :reg_data   <=24'h5000a7 ;//     
	 160  :;//reg_data   <=24'h3a0f28 ;//reg_data   <=24'h3a0f30 ;//  -0.7ev     
	 161  :;//reg_data   <=24'h3a1020 ;//reg_data   <=24'h3a1028 ;//       
	 162  :;//reg_data   <=24'h3a1b28 ;//reg_data   <=24'h3a1b30 ;//       
	 163  :;//reg_data   <=24'h3a1e20 ;//reg_data   <=24'h3a1e26 ;//       
	 164  :;//reg_data   <=24'h3a1151 ;//reg_data   <=24'h3a1160 ;//       
	 165  :;//reg_data   <=24'h3a1f10 ;//reg_data   <=24'h3a1f14 ;//       
	 166  :reg_data   <=24'h580023 ;//       
	 167  :reg_data   <=24'h580114 ;//       
	 168  :reg_data   <=24'h58020f ;//       
	 169  :reg_data   <=24'h58030f ;//       
	 170  :reg_data   <=24'h580412 ;//       
	 171  :reg_data   <=24'h580526 ;//       
	 172  :reg_data   <=24'h58060c ;//       
	 173  :reg_data   <=24'h580708 ;//       
	 174  :reg_data   <=24'h580805 ;//       
	 175  :reg_data   <=24'h580905 ;//       
	 176  :reg_data   <=24'h580a08 ;//       
	 177  :reg_data   <=24'h580b0d ;//       
	 178  :reg_data   <=24'h580c08 ;//       
	 179  :reg_data   <=24'h580d03 ;//       
	 180  :reg_data   <=24'h580e00 ;//       
	 181  :reg_data   <=24'h580f00 ;//       
	 182  :reg_data   <=24'h581003 ;//       
	 183  :reg_data   <=24'h581109 ;//       
	 184  :reg_data   <=24'h581207 ;//       
	 185  :reg_data   <=24'h581303 ;//       
	 186  :reg_data   <=24'h581400 ;//       
	 187  :reg_data   <=24'h581501 ;//       
	 188  :reg_data   <=24'h581603 ;//       
	 189  :reg_data   <=24'h581708 ;//       
	 190  :reg_data   <=24'h58180d ;//       
	 191  :reg_data   <=24'h581908 ;//       
	 192  :reg_data   <=24'h581a05 ;//       
	 193  :reg_data   <=24'h581b06 ;//       
	 194  :reg_data   <=24'h581c08 ;//       
	 195  :reg_data   <=24'h581d0e ;//       
	 196  :reg_data   <=24'h581e29 ;//       
	 197  :reg_data   <=24'h581f17 ;//       
	 198  :reg_data   <=24'h582011 ;//       
	 199  :reg_data   <=24'h582111 ;//       
	 200  :reg_data   <=24'h582215 ;//        
	 201  :reg_data   <=24'h582328 ;//        
	 202  :reg_data   <=24'h582446 ;//        
	 203  :reg_data   <=24'h582526 ;//        
	 204  :reg_data   <=24'h582608 ;//        
	 205  :reg_data   <=24'h582726 ;//        
	 206  :reg_data   <=24'h582864 ;//        
	 207  :reg_data   <=24'h582926 ;//        
	 208  :reg_data   <=24'h582a24 ;//        
	 209  :reg_data   <=24'h582b22 ;//        
	 210  :reg_data   <=24'h582c24 ;//        
	 211  :reg_data   <=24'h582d24 ;//        
	 212  :reg_data   <=24'h582e06 ;//        
	 213  :reg_data   <=24'h582f22 ;//        
	 214  :reg_data   <=24'h583040 ;//        
	 215  :reg_data   <=24'h583142 ;//        
	 216  :reg_data   <=24'h583224 ;//        
	 217  :reg_data   <=24'h583326 ;//        
	 218  :reg_data   <=24'h583424 ;//        
	 219  :reg_data   <=24'h583522 ;//        
	 220  :reg_data   <=24'h583622 ;//        
	 221  :reg_data   <=24'h583726 ;//        
	 222  :reg_data   <=24'h583844 ;//        
	 223  :reg_data   <=24'h583924 ;//        
	 224  :reg_data   <=24'h583a26 ;//        
	 225  :reg_data   <=24'h583b28 ;//        
	 226  :reg_data   <=24'h583c42 ;//        
	 227  :reg_data   <=24'h583dce ;//        
	 228  :reg_data   <=24'h5180ff ;//        
	 229  :reg_data   <=24'h5181f2 ;//        
	 230  :reg_data   <=24'h518200 ;//        
	 231  :reg_data   <=24'h518314 ;//        
	 232  :reg_data   <=24'h518425 ;//        
	 233  :reg_data   <=24'h518524 ;//        
	 234  :reg_data   <=24'h518609 ;//        
	 235  :reg_data   <=24'h518709 ;//        
	 236  :reg_data   <=24'h518809 ;//        
	 237  :reg_data   <=24'h518975 ;//        
	 238  :reg_data   <=24'h518a54 ;//        
	 239  :reg_data   <=24'h518be0 ;//        
	 240  :reg_data   <=24'h518cb2 ;//        
	 241  :reg_data   <=24'h518d42 ;//        
	 242  :reg_data   <=24'h518e3d ;//        
	 243  :reg_data   <=24'h518f56 ;//        
	 244  :reg_data   <=24'h519046 ;//        
	 245  :reg_data   <=24'h5191f8 ;//        
	 246  :reg_data   <=24'h519204 ;//        
	 247  :reg_data   <=24'h519370 ;//        
	 248  :reg_data   <=24'h5194f0 ;//        
	 249  :reg_data   <=24'h5195f0 ;//        
	 250  :reg_data   <=24'h519603 ;//        
	 251  :reg_data   <=24'h519701 ;//        
	 252  :reg_data   <=24'h519804 ;//        
	 253  :reg_data   <=24'h519912 ;//        
	 254  :reg_data   <=24'h519a04 ;//        
	 255  :reg_data   <=24'h519b00 ;//        
	 256  :reg_data   <=24'h519c06 ;//        
	 257  :reg_data   <=24'h519d82 ;//        
	 258  :reg_data   <=24'h519e38 ;//        
	 259  :reg_data   <=24'h548001 ;//        
	 260  :reg_data   <=24'h548108 ;//        
	 261  :reg_data   <=24'h548214 ;//        
	 262  :reg_data   <=24'h548328 ;//        
	 263  :reg_data   <=24'h548451 ;//        
	 264  :reg_data   <=24'h548565 ;//        
	 265  :reg_data   <=24'h548671 ;//        
	 266  :reg_data   <=24'h54877d ;//        
	 267  :reg_data   <=24'h548887 ;//        
	 268  :reg_data   <=24'h548991 ;//        
	 269  :reg_data   <=24'h548a9a ;//        
	 270  :reg_data   <=24'h548baa ;//        
	 271  :reg_data   <=24'h548cb8 ;//        
	 272  :reg_data   <=24'h548dcd ;//        
	 273  :reg_data   <=24'h548edd ;//        
	 274  :reg_data   <=24'h548fea ;//        
	 275  :reg_data   <=24'h54901d ;//        
	 276  :reg_data   <=24'h53811e ;//        
	 277  :reg_data   <=24'h53825b ;//        
	 278  :reg_data   <=24'h538308 ;//        
	 279  :reg_data   <=24'h53840a ;//        
	 280  :reg_data   <=24'h53857e ;//        
	 281  :reg_data   <=24'h538688 ;//        
	 282  :reg_data   <=24'h53877c ;//        
	 283  :reg_data   <=24'h53886c ;//        
	 284  :reg_data   <=24'h538910 ;//        
	 285  :reg_data   <=24'h538a01 ;//        
	 286  :reg_data   <=24'h538b98 ;//       
	 287  :reg_data   <=24'h558007 ;//        
	 288  :reg_data   <=24'h558340 ;//        
	 289  :reg_data   <=24'h558410 ;//        
	 290  :reg_data   <=24'h558910 ;//        
	 291  :reg_data   <=24'h558a00 ;//        
	 292  :reg_data   <=24'h558bf8 ;//        
	 293  :reg_data   <=24'h501d40 ;//        
	 294  :reg_data   <=24'h530008 ;//        
	 295  :reg_data   <=24'h530130 ;//        
	 296  :reg_data   <=24'h530210 ;//        
	 297  :reg_data   <=24'h530300 ;//        
	 298  :reg_data   <=24'h530408 ;//        
	 299  :reg_data   <=24'h530530 ;//        
	 300  :reg_data   <=24'h530608 ;//        
	 301  :reg_data   <=24'h530716 ;//        
	 302  :reg_data   <=24'h530908 ;//        
	 303  :reg_data   <=24'h530a30 ;//        
	 304  :reg_data   <=24'h530b04 ;//        
	 305  :reg_data   <=24'h530c06 ;//        
	 306  :reg_data   <=24'h502500 ;//        
	 307  :reg_data   <=24'h300802 ;//       
  //720 30帧/秒, night mode 5fps ;//         
  //input clock=24Mhz,PCLK=84Mhz ;//         
	 308  :reg_data <=24'h303521 ;//PLL      
	 309  :reg_data <=24'h303669 ;//PLL     
     310  :reg_data <=24'h3c0708 ;//        
	 311  :reg_data <=24'h382040 ;//        
	 312  :reg_data <=24'h382106 ;//        
	 313  :reg_data <=24'h381431 ;//        
	 314  :reg_data <=24'h381531 ;//        
	 315  :reg_data <=24'h380000 ;//        
	 316  :reg_data <=24'h380100 ;//        
	 317  :reg_data <=24'h380200 ;//        
	 318  :reg_data <=24'h3803fa ;//        
	 319  :reg_data <=24'h38040a ;//        
	 320  :reg_data <=24'h38053f ;//        
	 321  :reg_data <=24'h380606 ;//        
	 322  :reg_data <=24'h3807a9 ;//        
	 323  :reg_data <=24'h380803 ;//24'h380805 ;// 水平分辨率高       
	 324  :reg_data <=24'h3809c0 ;//24'h380900 ;//        
	 325  :reg_data <=24'h380a02 ;//24'h380a02 ;// 竖直分辨率      
	 326  :reg_data <=24'h380b1c ;//24'h380bd0 ;//        
	 327  :reg_data <=24'h380c07 ;//        
	 328  :reg_data <=24'h380d64 ;//        
	 329  :reg_data <=24'h380e02 ;//        
	 330  :reg_data <=24'h380fe4 ;//        
	 331  :reg_data <=24'h381304 ;//        
	 332  :reg_data <=24'h361800 ;//        
	 333  :reg_data <=24'h361229 ;//        
	 334  :reg_data <=24'h370952 ;//        
	 335  :reg_data <=24'h370c03 ;//        
	 336  :reg_data <=24'h3a0202 ;//        
	 337  :reg_data <=24'h3a03e0 ;//        

	 338  :reg_data <=24'h3a0800 ;//        
	 339  :reg_data <=24'h3a096f ;//        
	 340  :reg_data <=24'h3a0a00 ;//        
	 341  :reg_data <=24'h3a0b5c ;//        
	 342  :reg_data <=24'h3a0e06 ;//        
	 343  :reg_data <=24'h3a0d08 ;//        
	 344  :reg_data <=24'h3a1402 ;//         
	 345  :reg_data <=24'h3a15e0 ;//         
	 346  :reg_data <=24'h400402 ;//         
	 347  :reg_data <=24'h30021c ;//         
	 348  :reg_data <=24'h3006c3 ;//         
	 349  :reg_data <=24'h471303 ;//         
	 350  :reg_data <=24'h440704 ;//         
	 351  :reg_data <=24'h460b37 ;//           
     352  :reg_data <=24'h460c20 ;//          
	 353  :reg_data <=24'h483716 ;//         
	 354  :reg_data <=24'h382404 ;//         
	 355  :reg_data <=24'h5001ff ;//         
	 356  :reg_data <=24'h350300 ;//   

     357  :reg_data <=24'h558178 ;//sin因子
     358  :reg_data <=24'h558220 ;//cos因子
     359  :reg_data <=24'h558801 ;//应用参数        
	 default:reg_data<=24'hffffff;//        
    endcase      
end	 



endmodule

