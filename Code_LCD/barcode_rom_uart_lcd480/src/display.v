module display  (
	input 				clk,    // Clock
	
	input 		[ 9:0]	bar_left,bar_right,
	input 		[ 9:0]  x_in,y_in,

	input				in_hs,
	input				in_vs,
	input				in_de,
	input 				in_data,

	output reg 			out_hs,
	output reg 			out_vs,
	output reg 			out_de,
	output reg [23:0]	out_data
);

always@(posedge clk)
	if (in_de) 
		if((bar_right > bar_left + 100 ) && x_in >= bar_left && x_in <= bar_right && y_in >= 120 && y_in <= 124)
			out_data <= in_data? 24'h00ff00 :24'hffffff;
		else
			out_data <= in_data? 24'h000000 :24'hffffff;
	else
		out_data <= 24'h000000;

always@(posedge clk)begin 
	out_hs <= in_hs;
	out_vs <= in_vs;
	out_de <= in_de;
end

endmodule