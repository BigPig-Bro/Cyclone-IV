module display  (
	input 				clk,
	input 				key_sel,
	
	input 		[ 9:0]	bar_left,bar_right,
	input 		[ 9:0]  x_in,y_in,

	input				in1_hs,
	input				in1_vs,
	input				in1_de,
	input 	[15:0]		in1_data,

	input 					scan_en,
	input				in2_hs,
	input				in2_vs,
	input				in2_de,
	input 				in2_data,

	output reg 			out_hs,
	output reg 			out_vs,
	output reg 			out_de,
	output  reg 	[23:0]	out_data
);

parameter BAR_LOC_Y1 = 10'D80  + 4; //识别位置 1 + 扫描延迟
parameter BAR_LOC_Y2 = 10'D100 + 4; //识别位置 2 + 扫描延迟
parameter BAR_LOC_Y3 = 10'D130 + 4; //识别位置 3 + 扫描延迟

always@(posedge clk)begin 
	if(key_sel)begin
		out_hs 	 	<= in2_hs;
		out_vs 	 	<= in2_vs;
		out_de 	 	<= in2_de;

		if (in2_de) 
			if(y_in == BAR_LOC_Y1 || y_in == BAR_LOC_Y2 || y_in == BAR_LOC_Y3)
				out_data <= 24'hff0000;
			else
				out_data <= in2_data? 24'h000000 :24'hffffff;
		else
			out_data <= 24'h000000;
	end
	else begin
		out_hs 	 	<= in1_hs;
		out_vs 	 	<= in1_vs;
		out_de 	 	<= in1_de;
		out_data  <= in1_data;
	end
end

endmodule