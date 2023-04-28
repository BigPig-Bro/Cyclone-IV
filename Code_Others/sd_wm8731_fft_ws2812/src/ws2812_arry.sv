//功能描述：驱动 M*N 阵列个的WS2812 滚动显示
module ws2812_arry #(
	parameter CLK_FRE 	 	= 50_000_000	 	, // CLK的频率(Mhz)
	parameter WS2812_M      = 8   , // 行数
	parameter WS2812_N      = 8     // 列数 必须大于2
)(
	input 											clk,  //输入 时钟源  

	input 											key_rgb, //输入 按键控制
	input 	[WS2812_M - 1 : 0][WS2812_N - 1 : 0] 	arry_data,

	output reg 										ws2812_di //输出到WS2812的接口	
);

parameter WS2812_NUM 	= WS2812_M * WS2812_N  - 1     ; // WS2812的LED数量(1从0开始)
parameter WS2812_WIDTH 	= 24 	      					; // WS2812的数据位宽

parameter DELAY_1_HIGH 	= CLK_FRE / 1_000_000_0 * 8 - 1; //800ns≈850ns±150ns    1 高电平时间
parameter DELAY_1_LOW 	= CLK_FRE / 1_000_000_0 * 4 - 1; //≈400ns±150ns 		1 低电平时间
parameter DELAY_0_HIGH 	= CLK_FRE / 1_000_000_0 * 4 - 1; //≈400ns±150ns 		0 高电平时间
parameter DELAY_0_LOW 	= CLK_FRE / 1_000_000_0 * 8 - 1; //800ns≈850ns±150ns    0 低电平时间
parameter DELAY_RESET 	= CLK_FRE / 1_000 - 1; //1ms 复位时间 ＞280us

parameter WAIT_DELAY 	= CLK_FRE / 120;//每个刷新周期的间隔  120hz

parameter RESET 	 		= 0; //状态机声明
parameter DATA_SEND  		= 1;
parameter BIT_SEND_HIGH   	= 2;
parameter BIT_SEND_LOW   	= 3;
parameter WAIT   			= 4;

reg [WS2812_M - 1 : 0][WS2812_N - 1 : 0] 	arry_data_r;
reg [ 2:0] state       = 0 ; //主状态机控制
reg [ 4:0] bit_send    = 0; //数据数量发送控制
reg [ 7:0] data_send   = 0; //数据位发送控制
reg [31:0] clk_delay   = 0; //延时控制
reg [23:0] WS2812_data = 24'h1; // WS2812的颜色数据 G B R

reg [ 7:0] scan_y = 'd0;

always@(posedge clk)
	case (state)
		RESET:begin
			ws2812_di <= 0;
			if (clk_delay < DELAY_RESET) 
				clk_delay <= clk_delay + 1;
			else begin
				clk_delay <= 0;

				state <= DATA_SEND;
			end
		end

		DATA_SEND: begin
			//更新查表位置
			if(data_send % WS2812_N  == WS2812_N - 1 && bit_send == WS2812_WIDTH)
				scan_y <=  (scan_y  == WS2812_M - 1)?'d0:scan_y + 1;
			else 
				scan_y <= scan_y;

			WS2812_data <= (arry_data_r[scan_y][data_send % 8])?key_rgb?  24'h000200 : 24'h020000 : 24'D0;


			if (data_send == WS2812_NUM && bit_send == WS2812_WIDTH)begin 
				data_send <= 0;
				bit_send  <= 0;
				state <= WAIT;
			end 
			else if (bit_send < WS2812_WIDTH) 
				state    <= BIT_SEND_HIGH;
			else begin// if (bit_send == WS2812_WIDTH)
				data_send <= data_send + 1;

				bit_send  <= 0;
				state    <= BIT_SEND_HIGH;
			end
		end
			
		BIT_SEND_HIGH:begin
			ws2812_di <= 1;
			if (WS2812_data[23 - bit_send]) 
				if (clk_delay < DELAY_1_HIGH)
					clk_delay <= clk_delay + 1;
				else begin
					clk_delay <= 0;
					state    <= BIT_SEND_LOW;
				end
			else 
				if (clk_delay < DELAY_0_HIGH)
					clk_delay <= clk_delay + 1;
				else begin
					clk_delay <= 0;
					state    <= BIT_SEND_LOW;
				end
		end

		BIT_SEND_LOW:begin
			ws2812_di <= 0;
			if (WS2812_data[bit_send]) 
				if (clk_delay < DELAY_1_LOW) 
					clk_delay <= clk_delay + 1;
				else begin
					clk_delay <= 0;
					bit_send <= bit_send + 1;
					state    <= DATA_SEND;
				end
			else 
				if (clk_delay < DELAY_0_LOW) 
					clk_delay <= clk_delay + 1;
				else begin
					clk_delay <= 0;
					bit_send <= bit_send + 1;
					state    <= DATA_SEND;
				end
		end

		WAIT:begin
			if(clk_delay < WAIT_DELAY) clk_delay <= clk_delay + 1;
			else begin
				clk_delay <= 'd0;
				arry_data_r <= arry_data;
				state <= RESET;
			end
		end
	endcase
endmodule