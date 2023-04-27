module display  (
	input 		[ 9:0]  x_in,y_in,

	input 				scan_en,
	input				in_hs,
	input				in_vs,
	input				in_de,
	input 				in_data,

	output reg 			out_hs,
	output reg 			out_vs,
	output reg 			out_de,
	output  reg 	[23:0]	out_data
);

parameter BAR_LOC_Y1 = 10'D2  + 2; //识别位置 1 + 扫描延迟
parameter BAR_LOC_Y2 = 10'D7  + 2; //识别位置 2 + 扫描延迟
parameter BAR_LOC_Y3 = 10'D12 + 2; //识别位置 3 + 扫描延迟

always@(*)begin 
	out_hs 	 	<= in_hs;
	out_vs 	 	<= in_vs;
	out_de 	 	<= in_de;

	if (in_de) 
		if(y_in == BAR_LOC_Y1 || y_in == BAR_LOC_Y2 || y_in == BAR_LOC_Y3)
			out_data <= scan_en? 24'h00ff00:24'hff0000;
		else
			out_data <= in_data? 24'h000000 :24'hffffff;
	else
		out_data <= 24'h000000;
end

endmodule