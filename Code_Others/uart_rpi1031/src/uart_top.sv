module uart_top (
	input 			clk,    // 
	
	input 	[1:0]	RPI1031_state,
	output	[1:0] 	RPI1031_led,

	output			uart_tx
);
parameter CLK_FRE 		= 50;
parameter UART_RATE 	= 115200;

enum {SEND,WAIT}STATE_LOOP;
reg [1:0] state;

reg  [31:0] wait_cnt;
reg  [ 7:0] send_cnt;
reg  [ 7:0] send_data;
reg  	    send_en;

wire [ 7:0] recv_data;
wire 		recv_en;

assign RPI1031_led = RPI1031_state;

//发送寄存器
parameter 	ENG_NUM  = 18;//非中文字符数
parameter 	CHE_NUM  = 0;//  中文字符数
parameter 	DATA_NUM = CHE_NUM * 3 + ENG_NUM; //中文字符使用UTF8，占用3个字节
wire [ DATA_NUM * 8 - 1:0] char_data = {"RPI1031 STATE: 0","\r\n"};
	
//仲裁机制
always@(posedge clk)
	case(state)
		SEND:begin // 主动发送
			if(send_cnt == DATA_NUM + 1)begin 
				send_en 	<= 'b0;
				send_cnt 	<=  0;
				state 		<= WAIT;
			end
			else if(!send_busy)begin
				send_en 	<= 'b1;
				if(send_cnt == 15)
					send_data 	<= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + RPI1031_state;
				else
					send_data 	<= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8];
				send_cnt 	<= send_cnt + 1;
			end
		end

		WAIT:// 回环测试发送
			if(wait_cnt == CLK_FRE * 1000_000)begin 
				wait_cnt <= 0;
				state <= SEND;
			end
			else 
				wait_cnt <= wait_cnt + 1;
	endcase

//发送模块
uart_tx #(
	.CLK_FRE 	(CLK_FRE 	),
	.UART_RATE 	(UART_RATE 	)
	)uart_tx_m0(
	.clk 		(clk 		),

	.send_en 	(send_en 	),
	.send_busy 	(send_busy 	),
	.send_data 	(send_data 	),

	.tx_pin 	(uart_tx 	)
	);

endmodule