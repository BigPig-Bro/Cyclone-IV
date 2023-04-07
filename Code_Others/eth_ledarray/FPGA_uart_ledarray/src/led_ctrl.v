module led_ctrl (
	input 				clk 	,
	
	input				light_ctrl,			
	input [55:0]		data_in ,
				
	output 				led_A 	,
	output 				led_B 	,
	output 				led_C 	,
	output 				led_D 	,
	output reg			led_G 	,
	output reg			led_DI 	,
	output 				led_CLK ,
	output reg			led_LAT 
);

reg [3:0] addr;

assign led_A   = addr[0];
assign led_B   = addr[1];
assign led_C   = addr[2];
assign led_D   = addr[3];
assign led_CLK = clk_led;

reg [31:0] clk_cnt;
reg 	   clk_led;

//亮度控制
reg [10:0] light_cnt = 0;
always@(posedge clk_led) begin
	led_G  <= (light_ctrl)? light_cnt[10]: 0;
	light_cnt <= light_cnt + 1;
end

//降低扫描时钟
always@(posedge clk)
	if (clk_cnt > 32'd1) begin
		clk_cnt <= 0;
		clk_led = ~clk_led;
	end
	else clk_cnt <= clk_cnt + 1;

//行扫描
always@(posedge clk_led)
	addr <= data_cnt == 63? addr + 1 : addr;

//列扫描
reg [5:0] data_cnt = 0;
always@(posedge clk_led)
	data_cnt <= data_cnt + 1;

always@(posedge clk_led)
	if (data_cnt < 8) 
		led_DI <= ~num_char_data[5][data_cnt[2:0]];
	else if (data_cnt < 16) 
		led_DI <= ~num_char_data[4][data_cnt[2:0]];
	else if (data_cnt < 24) 
		led_DI <= ~num_char_data[3][data_cnt[2:0]];
	else if (data_cnt < 32) 
		led_DI <= ~num_char_data[2][data_cnt[2:0]];
	else if (data_cnt < 40) 
		led_DI <= ~num_char_data[1][data_cnt[2:0]];
	else if (data_cnt < 48) 
		led_DI <= ~num_char_data[0][data_cnt[2:0]];
	else //if (data_cnt < 64) 
		led_DI <= ~city_data[data_cnt[3:0]];
		

//595 锁存
always@(posedge clk_led)
	led_LAT <= data_cnt == 6'd63;

//字库
//京津冀晋蒙 辽吉黑沪浙 苏皖闽赣鲁 豫鄂湘粤桂 琼渝川贵云 藏陕甘青宁 新港澳台
wire [15:0] city_data;
city city_m0(
	.clock 		(clk 		    ),
	.address 	(data_in[55:48] * 16 + (addr == 15?0:addr+1) ),
	.q 			(city_data 		)
	);

//01234 56789 ABCDE FGHIJ KLMNO PQRST UVWXY Z 
wire [7:0] num_char_data[5:0];
num_char num_char_m0(
	.clock 		(clk 		    ),
	.address 	(data_in[47:40] * 16 + (addr == 15?0:addr+1)),
	.q 			(num_char_data[0] 		)
	);

num_char num_char_m1(
	.clock 		(clk 		    ),
	.address 	(data_in[39:32] * 16 + (addr == 15?0:addr+1)),
	.q 			(num_char_data[1] 		)
	);

num_char num_char_m2(
	.clock 		(clk 		    ),
	.address 	(data_in[31:24] * 16 + (addr == 15?0:addr+1)),
	.q 			(num_char_data[2] 		)
	);

num_char num_char_m3(
	.clock 		(clk 		    ),
	.address 	(data_in[23:16] * 16 + (addr == 15?0:addr+1)),
	.q 			(num_char_data[3] 		)
	);

num_char num_char_m4(
	.clock 		(clk 		    ),
	.address 	(data_in[15: 8] * 16 + (addr == 15?0:addr+1)),
	.q 			(num_char_data[4] 		)
	);

num_char num_char_m5(
	.clock 		(clk 		    ),
	.address 	(data_in[ 7: 0] * 16 + (addr == 15?0:addr+1)),
	.q 			(num_char_data[5] 		)
	);

endmodule
