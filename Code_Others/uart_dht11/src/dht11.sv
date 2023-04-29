module dht11#(
	parameter  CLK_FRE = 50 //时钟频率
)(
	input clk,		//输入的时钟
	inout dht11_io,		//DHT11数据口
	output reg [3:0] dht11_state,
	output reg [23:0] data_rec //24位的接收到的数据
);

reg data_en,data_out;//输出输入控制，输出临时寄存器
reg [31:0] clk_delay;//延时专用
reg [ 7:0] data_cnt;//接收数据计数器
reg [39:0] data_tem;//数据临时寄存器

reg [ 1:0] dht11_step;//大小状态机

//相关变量的初始化
initial dht11_state = 'd0;//主状态机从状态0开始
initial dht11_step = 'd0;//小状态机归零
initial clk_delay = 'd0;//时钟延时归零
initial data_en = 'd1;//输出默认打开
initial data_out = 'b1;//默认输出高电平
initial data_rec = 'd0;//默认接收到的数据为0
initial data_cnt = 'd0;//接收数据的计数器归零

//DHT11数据口的控制
assign dht11_io = data_en ? data_out : 1'bz;

always@(posedge clk)
	case(dht11_state)
		4'd0://跳过2S的不稳定期
			if(clk_delay < CLK_FRE * 1000000 * 2)
			begin
				dht11_state <= dht11_state;
				clk_delay   <= clk_delay + 32'd1;
				
				data_en  <= 1'b1;
				data_out <= 1'b1;
			end
			else
			begin
				dht11_state <= dht11_state + 4'd1;
				clk_delay   <= 32'd0;
			end
		
		4'd1://开始信号，拉低18-30MS 取20ms
			if(clk_delay < CLK_FRE * 1000000 / 50)
			begin
				dht11_state <= dht11_state;
				clk_delay   <= clk_delay + 32'd1;
				
				data_en  <= 1'b1;
				data_out <= 1'b0;
			end
			else
			begin
				data_cnt   <= 8'd0;				
				dht11_state <= dht11_state + 4'd1;
				clk_delay   <= 32'd0;
			end
		
		4'd2://释放总线信号，10-35US 取 13us
			if(clk_delay < CLK_FRE * 13)
			begin
				clk_delay   <= clk_delay + 32'd1;
				
				data_en  <= 1'b1;
				data_out <= 1'b1;
			end
			else
			begin				
				dht11_state <= dht11_state + 4'd1;
				clk_delay   <= 32'd0;
			end

		4'D3:begin //等待拉低响应,最多等待3s
			data_en <= 1'b0;
			
			if(dht11_io & clk_delay < CLK_FRE * 1000000 * 3)
				clk_delay   <= clk_delay + 32'd1;
			else if(dht11_io & clk_delay >= CLK_FRE * 1000000 * 3) begin
				dht11_state <= 4'd1;
				clk_delay   <= 32'd0;
			end
			else begin
				dht11_state <= dht11_state + 4'd1;
				clk_delay   <= 32'd0;
			end
		end
		
		4'd4://响应信号1——典型值83US 低
			if( dht11_io & (clk_delay > (CLK_FRE *  32'd78 - 32'd1)) & (clk_delay < (CLK_FRE *  32'd88 - 32'd1)))begin
				dht11_state <= dht11_state + 4'd1;
				clk_delay   <= 32'd0;
			end
			else if ( !dht11_io & (clk_delay < (CLK_FRE *  32'd88 - 32'd1)))
				clk_delay   <= clk_delay + 32'd1;
			else begin
				dht11_state <= 4'd1;
				clk_delay   <= 32'd0;
			end
		
		4'd5://响应信号2——典型值87US 高
			if( !dht11_io & (clk_delay > (CLK_FRE *  32'd80 - 32'd1)) & (clk_delay < (CLK_FRE *  32'd92 - 32'd1))) begin				
				dht11_state <= dht11_state + 4'd1;
				clk_delay   <= 32'd0;
			end
			else if ( dht11_io &  clk_delay < (CLK_FRE *  32'd92 - 32'd1))
				clk_delay   <= clk_delay + 32'd1;
			else begin
				clk_delay   <= 32'd0;
				dht11_state <= 4'd1;
			end
		
		4'd6://延时补偿 10us
			if(clk_delay < CLK_FRE * 10)
				clk_delay <= clk_delay + 32'd1;
			else begin
				dht11_step <= 'd0;
				dht11_state <=  dht11_state + 4'd1;
				clk_delay   <= 32'd0;
			end
		
		4'd7://接收40位数据，8湿度整数+8湿度小数（0）+8温度整数+8温度小数+8校验码
			if(data_cnt <= 8'd39)
				case(dht11_step)//信号低电平中 50-58US 54//信号高电平中 0(23-27us) 24 1(68-74us) 71
					'd0://跳过低电平
						if(dht11_io)
							dht11_step <=  dht11_step + 4'd1;
					
					'd1://统计高电平时间
						if(dht11_io)
							clk_delay <= clk_delay + 32'd1;
						else
							dht11_step <= dht11_step + 4'd1;

					'd2:begin//读取数据
						data_tem['d39 - data_cnt] <= clk_delay < CLK_FRE * 30 ? 1'b0 : 1'b1;//27us以上为1
						data_cnt <= data_cnt + 'd1;
						clk_delay <= 32'd0;

						dht11_step <= 4'd0;
					end
					default: dht11_step <= 4'd0;
				endcase 
			else
				dht11_state <= dht11_state + 4'd1;
		
		4'd8://校验数据
			if(data_tem[7:0] == data_tem[31:24] + data_tem[23:16] + data_tem[15:8] + data_tem[39:32])
				dht11_state <= dht11_state + 4'd1;
			else
				dht11_state <= 4'd1;

		4'd9://最后的信号延时补偿 保证采样周期 2S以上
			if(clk_delay < CLK_FRE * 1000000 * 2)
				clk_delay <= clk_delay + 32'd1;
			else
			begin
				dht11_state <=  4'd1;

				//将DHT11的40位数据拆为BCD码输出
				data_rec[23:20] <= data_tem[23:16] / 10;//温度整数
				data_rec[19:16] <= data_tem[23:16] % 10;

				data_rec[15:12] <= data_tem[15: 8] / 10;//温度小数
				data_rec[11: 8] <= data_tem[15: 8] % 10;

				data_rec[ 7: 4] <= data_tem[39:32] / 10;//湿度整数
				data_rec[ 3: 0] <= data_tem[39:32] % 10;

				clk_delay <= 32'd0;
			end

		default: 
		begin
			dht11_state <= 4'd1;
			clk_delay <= 32'd0;
		end
	endcase 
	
endmodule 