module key#(
	parameter CLK_FRE  = 50, //输入的时钟 Mhz
	parameter CNT 	   = 1
)(
	input 			 clk,
	input			 key_in,
	output reg [CNT - 1:0] key_cnt);
	parameter DELAY_MS = 20; //消抖延时 Ms （由于1024分频，实际更长一丢丢）

	//对于消抖来说，按键没必要那么大，浪费资源，这里降1K
	reg [9:0] clk_delay =0;
	always@(posedge clk) clk_delay <= clk_delay + 'd1;

	reg [15:0] cnt = 0;//延时的计数器

	reg key_clk;
	always@(posedge clk_delay[9])
		if(!key_in)//如果按键按下或者抖动导致按下
			if(cnt === CLK_FRE * DELAY_MS)//持续计数20ms后如果仍为按下状态，确定按下
			begin
				key_clk <= key_clk + 1;//输出按下的高电平信号
				//cnt <= cnt;//计时器保持使输出信号持续为高
			end
			else begin//计数器不到上限，输出为0
				cnt <= cnt + 1;//计数器开始计数
				key_clk <= key_clk;
			end
		else
		begin//按键松开或者抖动导致的按键按下信号不够长
			key_clk <= key_clk;
			cnt <= 0;//计数器重置
		end

	always@(posedge key_clk) key_cnt <= key_cnt + 1;
endmodule