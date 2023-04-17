module cam_thrould(
	input 		 clk,

	input [15:0] in_data,
	input 		 in_hs,in_vs,in_de,

	output reg   thr_data,thr_de,thr_vs,thr_hs );
	//以下为RGB阈值，需要通过逻辑分析仪调节
	parameter threshold_red_min   = 5'd20;
	parameter threshold_red_max   = 5'd31; //0 - 31
	parameter threshold_green_min = 6'd40;
	parameter threshold_green_max = 6'd63; //0 - 63
	parameter threshold_blue_min  = 5'd20;
	parameter threshold_blue_max  = 5'd31; //0 - 31
	
	always@(posedge clk)
	begin
		if(in_data[4:0] <= threshold_blue_max & in_data[4:0] > threshold_blue_min 
		& in_data[10:5] <= threshold_green_max & in_data[10:5] > threshold_green_min 
		& in_data[15:11] <= threshold_red_max & in_data[15:11] > threshold_red_min  )
		begin
			thr_data = 1'b1;
		end
		else
		begin
			thr_data = 1'b0;
		end

		thr_de <= in_de;
		thr_hs <= in_hs;
		thr_vs <= in_vs;
	end
	
endmodule 