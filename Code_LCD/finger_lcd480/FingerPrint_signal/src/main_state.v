module main_state (
	input 				clk,    // Clock
	//按键控制输入
	input 				update_in,
	input				check_in,

	//指纹RAM控制
	output reg  	write_sel = 0,

	//比对通信
	input 				fp_state,
	output [1:0]		fp_start
);

reg u_r,c_r;
always@(posedge clk) begin
	u_r <= update_in;
	c_r <= check_in;
end

always@(posedge clk) begin
	if (!u_r && update_in) begin
		write_sel <= 0; //两个模板交替更新
	end
	else if (!c_r && check_in) begin
		write_sel <= 1; //待测图像写入第三个
	end
end

endmodule