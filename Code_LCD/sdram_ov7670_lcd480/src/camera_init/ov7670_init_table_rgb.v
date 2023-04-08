/*============================================================================
*
*  LOGIC CORE:          OV7670初始化寄存器表
*  MODULE NAME:         ov7670_init_table_rgb()
*  COMPANY:             武汉芯路恒科技有限公司
*                       http://xiaomeige.taobao.com
*  author:				小梅哥
*  Website:				www.corecourse.cn
*  REVISION HISTORY:  
*
*  Revision: 			1.0  04/10/2019     
*  Description: 		Initial Release.
*
*  FUNCTIONAL DESCRIPTION:
===========================================================================*/

module ov7670_init_table_rgb(
	addr,
	clk, 
	q
);	
	input clk;
	input [(ADDR_WIDTH-1):0] addr;
	output reg [(DATA_WIDTH-1):0] q;
	
	parameter DATA_WIDTH   = 16;
	parameter ADDR_WIDTH   = 8;
	parameter IMAGE_FLIP   = 1'b0;
	parameter IMAGE_MIRROR = 1'b0;

	// Declare the ROM variable
	reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];

	initial begin
		/*OV7670 VGA RGB565参数  */
		rom[0  ] = 16'h3a_04; //
		rom[1  ] = 16'h40_d0;	
		rom[2  ] = 16'h12_04;	//VGA,RGB输出
		
		//输出窗口设置
		rom[3  ] = 16'h32_b6;
		rom[4  ] = 16'h17_13;
		rom[5  ] = 16'h18_01;
		rom[6  ] = 16'h19_02;
		rom[7  ] = 16'h1a_7a;
		rom[8  ] = 16'h03_0a;
		
		rom[9  ] = 16'h0c_00;	
		rom[10 ] = 16'h15_00;	
		rom[11 ] = 16'h3e_00;	//10
		rom[12 ] = 16'h70_00;	
		rom[13 ] = 16'h71_01;	
		rom[14 ] = 16'h72_11;	
		rom[15 ] = 16'h73_00;	//
		
		rom[16 ] = 16'ha2_02;	//15
		rom[17 ] = 16'h11_80;	//时钟分频设置,0,不分频.
		rom[18 ] = 16'h7a_20;	
		rom[19 ] = 16'h7b_1c;	
		rom[20 ] = 16'h7c_28;
		
		rom[21 ] = 16'h7d_3c;	//20
		rom[22 ] = 16'h7e_55;	
		rom[23 ] = 16'h7f_68;	
		rom[24 ] = 16'h80_76;	
		rom[25 ] = 16'h81_80;
		
		rom[26 ] = 16'h82_88;	
		rom[27 ] = 16'h83_8f;	
		rom[28 ] = 16'h84_96;	
		rom[29 ] = 16'h85_a3;	
		rom[30 ] = 16'h86_af;
		
		rom[31 ] = 16'h87_c4;	//30
		rom[32 ] = 16'h88_d7;	
		rom[33 ] = 16'h89_e8;	
		rom[34 ] = 16'h13_e0;	
		rom[35 ] = 16'h00_00;	//AGC
      
		rom[36 ] = 16'h10_00;	
		rom[37 ] = 16'h0d_00;	 
		rom[38 ] = 16'h14_28;	//0x38, limit the max gain
		rom[39 ] = 16'ha5_05;	
		rom[40 ] = 16'hab_07;
		
		rom[41 ] = 16'h24_75;	//40
		rom[42 ] = 16'h25_63;	
		rom[43 ] = 16'h26_A5;	
		rom[44 ] = 16'h9f_78;	
		rom[45 ] = 16'ha0_68;
		
		rom[46 ] = 16'ha1_03;	//0x03,
		rom[47 ] = 16'ha6_df;	//0xdf,
		rom[48 ] = 16'ha7_df;	//0xdf,
		rom[49 ] = 16'ha8_f0;	
		rom[50 ] = 16'ha9_90;
		
		rom[51 ] = 16'haa_94;	//
		rom[52 ] = 16'h13_ef;	
		rom[53 ] = 16'h0e_61;	
		rom[54 ] = 16'h0f_4b;	
		rom[55 ] = 16'h16_02;
		
//		rom[56 ] = 16'h1e_31;	//图像输出镜像控制.0x01,
		rom[56 ] = {8'h1e, 8'H31};
		rom[57 ] = 16'h21_02;	
		rom[58 ] = 16'h22_91;	
		rom[59 ] = 16'h29_07;	
		rom[60 ] = 16'h33_0b;
		
		rom[61 ] = 16'h35_0b;	//60
		rom[62 ] = 16'h37_1d;	
		rom[63 ] = 16'h38_71;	
		rom[64 ] = 16'h39_2a;	
		rom[65 ] = 16'h3c_78;
		
		rom[66 ] = 16'h4d_40;	
		rom[67 ] = 16'h4e_20;	
		rom[68 ] = 16'h69_00;	
		rom[69 ] = 16'h6b_00;	//PLL*4=48Mhz
		rom[70 ] = 16'h74_19;	
		rom[71 ] = 16'h8d_4f;
		
		rom[72 ] = 16'h8e_00;	//70
		rom[73 ] = 16'h8f_00;	
		rom[74 ] = 16'h90_00;	
		rom[75 ] = 16'h91_00;	
		rom[76 ] = 16'h92_00;	//0x19,//0x66
		
		rom[77 ] = 16'h96_00;	
		rom[78 ] = 16'h9a_80;	
		rom[79 ] = 16'hb0_84;	
		rom[80 ] = 16'hb1_0c;	
		rom[81 ] = 16'hb2_0e;
		
		rom[82 ] = 16'hb3_82;	//80
		rom[83 ] = 16'hb8_0a;	
		rom[84 ] = 16'h43_14;	
		rom[85 ] = 16'h44_f0;	
		rom[86 ] = 16'h45_34;
		
		rom[87 ] = 16'h46_58;	
		rom[88 ] = 16'h47_28;	
		rom[89 ] = 16'h48_3a;	
		rom[90 ] = 16'h59_88;	
		rom[91 ] = 16'h5a_88;
		
		rom[92 ] = 16'h5b_44;	//90
		rom[93 ] = 16'h5c_67;	
		rom[94 ] = 16'h5d_49;	
		rom[95 ] = 16'h5e_0e;	
		rom[96 ] = 16'h64_04;	
		rom[97 ] = 16'h65_20;
		
		rom[98 ] = 16'h66_05;	
		rom[99 ] = 16'h94_04;	
		rom[100] = 16'h95_08;	
		rom[101] = 16'h6c_0a;	
		rom[102] = 16'h6d_55;
		
		rom[103] = 16'h4f_80;	
		rom[104] = 16'h50_80;	
		rom[105] = 16'h51_00;	
		rom[106] = 16'h52_22;	
		rom[107] = 16'h53_5e;	
		rom[108] = 16'h54_80;
		
		rom[109] = 16'h09_03;	//驱动能力最大
		rom[110] = 16'h6e_11;	//100
		rom[111] = 16'h6f_9f;	//0x9e for advance AWB
		rom[112] = 16'h55_00;	//亮度
		rom[113] = 16'h56_40;	//对比度
		rom[114] = 16'h57_80;	//0x40,  change according to Jim's request
	end

	always @ (posedge clk)
	begin
		q <= rom[addr];
	end

endmodule
