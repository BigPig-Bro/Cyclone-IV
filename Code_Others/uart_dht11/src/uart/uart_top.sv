module uart_top #(
	parameter CLK_FRE 		= 50,
	parameter UART_RATE 	= 115200
	)(
	input 			clk,    // 
	
	input [23:0] 	dht11_data,
	output 			thres_en,

	input 			uart_rx,
	output			uart_tx
);

enum {SEND,WAIT}STATE_LOOP;
reg [1:0] state;

reg  [31:0] wait_cnt;
reg  [ 7:0] send_cnt;
reg  [ 7:0] send_data;
reg  	    send_en;

wire [ 7:0] recv_data;
wire 		recv_en;

//发送寄存器
parameter 	ENG_NUM  = 22;//非中文字符数
parameter 	CHE_NUM  = 8;//  中文字符数
parameter 	DATA_NUM = CHE_NUM * 3 + ENG_NUM; //中文字符使用UTF8，占用3个字节
wire [ DATA_NUM * 8 - 1:0] char_data = {"DHT11 温度:00.00 湿度:00 湿度阈值:00","\r\n"};
	
//仲裁机制
always@(posedge clk)
	case(state)
		SEND:begin // 主动发送
			if(send_cnt == DATA_NUM + 1)begin 
				send_en 	<= 'b0;
				state 		<= WAIT;
			end
			else if(!send_busy)begin
				send_en 	<= 'b1;
				case(send_cnt)
					'd13:	send_data 	<= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + dht11_data[23:19];
					'd14:	send_data 	<= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + dht11_data[19:16];
					'd15:	send_data 	<= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + dht11_data[15:12];
					'd16:	send_data 	<= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + dht11_data[11: 8];

					'd26:	send_data 	<= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + dht11_data[ 7: 4];
					'd27:	send_data 	<= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + dht11_data[ 3: 0];
					
					'd42:	send_data 	<= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + temp_thres / 10;
					'd43:	send_data 	<= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + temp_thres % 10;
					default:	send_data 	<= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8];
				endcase
				send_cnt 	<= send_cnt + 1;
			end
		end

		WAIT:// 等待1s
			if(wait_cnt == CLK_FRE * 1_000_000)begin 
				wait_cnt 	<= 0;
				send_cnt 	<= 0;

				state <= SEND;
			end
			else begin
				wait_cnt <= wait_cnt + 1;
			end
	endcase

//接收寄存器
reg [7:0] temp_thres = 8'd40;
assign thres_en = (dht11_data[7:4] * 10 + dht11_data[3:0] ) >= temp_thres;
reg recv_en_r;
always@(posedge clk) recv_en_r <= recv_en;

always@(posedge clk)
	if(recv_en_r && !recv_en)
		case(recv_data) //调节阈值
			8'H30: temp_thres <= temp_thres - 1;
			8'H31: temp_thres <= temp_thres + 1;

			default:temp_thres <= temp_thres;
		endcase
	else
		temp_thres <= temp_thres;

//发送模块
uart_tx #(
	.CLK_FRE 	(CLK_FRE 		),
	.UART_RATE 	(UART_RATE 		)
	)uart_tx_m0(
	.clk 		(clk 			),

	.send_en 	(send_en 		),
	.send_busy 	(send_busy 		),
	.send_data 	(send_data 		),

	.tx_pin 	(uart_tx 		)
	);

//接收模块
uart_rx #(
	.CLK_FRE 	(CLK_FRE 		),
	.UART_RATE 	(UART_RATE 		)
	)uart_rx_m0(
	.clk 		(clk 			),

	.recv_en 	(recv_en 		),
	.recv_data 	(recv_data 		),

	.rx_pin 	(uart_rx 		)
	);

endmodule