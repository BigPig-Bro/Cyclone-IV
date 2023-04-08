module key(clk,key,key_out);//时钟，按键输出，整理输出
	input clk,key;
	output reg key_out;
	
	reg [31:0] cnt;//延时的计数器
	initial cnt = 0;//计时器归零
	
	always@(posedge clk)
	begin
		if(!key)//如果按键按下或者抖动导致按下
		begin
			cnt = cnt + 1;//计数器开始计数
			if(cnt === 50*1000*20)//持续计数20ms后如果仍为按下状态，确定按下
			begin
				key_out = 1;//输出按下的高电平信号
				cnt =50*1000*20-1;//计时器回归上一个状态使输出信号持续为高
			end
			else
			begin//计数器不到上限，输出为0
				key_out = 0;
			end
		end
		else
		begin//按键松开或者抖动导致的按键按下信号不够长
			key_out = 0;//输出为0
			cnt = 0;//计数器重置
		end
		
	end
endmodule
