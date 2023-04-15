module hc_sr04_ctr#(
	parameter CLK_FRE = 50
	)(
	input 				clk,
	input 				echo,
	output reg 			trig,
	output reg [15:0] 	data );
	
	reg [3:0] state = 0;
	reg [31:0] clk_delay = 0;
	
	reg [31:0] echo_cnt = 1;
	
	always@(posedge clk)
		case(state)
			4'd0://发送10us以上的脉冲，此处选择12us
				if(clk_delay < 12 * CLK_FRE)begin
					clk_delay = clk_delay + 32'd1;
					trig = 1'b1;
					state = state;
				end
				else begin
					clk_delay = 32'd0;
					trig = 1'b0;
					state = state + 4'd1;
				end
			
			4'd1://等待回声
				if(echo)
					state = state + 4'd1;
			
			4'd2://对回声计时
			begin
				if(echo)
					echo_cnt = echo_cnt + 32'd1;
				else begin
			
					data = echo_cnt * 16'd17 / 16'd1_00 / CLK_FRE;//单位计数 * 340MM/MS / 毫秒 1000 / 来回 2
					echo_cnt = 32'd1;
					state = state + 4'd1;
				end
			end
			
			4'd3:////等待60MS的工作缓冲，避免以前的回声影响
				if(clk_delay < 32'd60 * 32'd1_000 *  CLK_FRE)
					clk_delay = clk_delay + 32'd1;
				else begin
					clk_delay = 32'd0;
					state = 4'd0;
				end
			
			default: state = 4'd0;
		endcase
	
endmodule 