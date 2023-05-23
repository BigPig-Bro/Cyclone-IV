module pwm_ctr#(
	parameter CLK_FRE = 50
	)(
	input 		 	clk		    ,//输入的时钟
	input [9:0]  	pwm_duty		,//占空比0-100%整数
	input [20:0] 	pwm_rate 		,//频率0-500K（太大精度不够）
	output 	   		pwm_out); 	 //输出的PWM
	
	wire [20:0] RATE_CNT,PWM_CNT;
	
	assign RATE_CNT = CLK_FRE * 1_000_000 / pwm_rate - 32'd1;//一个波计数上限
	assign PWM_CNT  = (RATE_CNT + 32'd1) * pwm_duty / 32'd100;//在一个波内PWM上限计数器

	reg [20:0] cnt = 0;

	assign pwm_out = cnt < PWM_CNT;
	
	always@(posedge clk)
		if(cnt < RATE_CNT)
			cnt = cnt + 32'd1;
		else
			cnt = 32'd0;
	
endmodule 