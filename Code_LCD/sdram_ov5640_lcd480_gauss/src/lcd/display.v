module display  (
	input 				key_sel,

	input				in1_hs,
	input				in1_vs,
	input				in1_de,
	input 	[15:0]		in1_data,


	input				in2_hs,
	input				in2_vs,
	input				in2_de,
	input 	[15:0]		in2_data,

	output reg 			out_hs,
	output reg 			out_vs,
	output reg 			out_de,
	output   	[23:0]	out_data
);

reg [15:0]	out_data_r;
assign out_data = {out_data_r[15:11],3'd0,out_data_r[10:5],2'd0,out_data_r[4:0],3'd0};
always@*begin 
	out_hs 	 	<= key_sel? in2_hs:in1_hs;
	out_vs 	 	<= key_sel? in2_vs:in1_vs;
	out_de 	 	<= key_sel? in2_de:in1_de;
	out_data_r  <= key_sel? in2_data:in1_data;
end

endmodule