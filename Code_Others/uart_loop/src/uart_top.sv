module uart_top (
	input 		clk,    // 
	
	input 		uart_rx,
	output		uart_tx
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

//发送寄存器
parameter 	ENG_NUM  = 9;//非中文字符数
parameter 	CHE_NUM  = 2;//  中文字符数
parameter 	DATA_NUM = CHE_NUM * 3 + ENG_NUM; //中文字符使用UTF8，占用3个字节
wire [ DATA_NUM * 8 - 1:0] char_data = {"你好  World","\r\n"};
	
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
				send_data 	<= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8];
				send_cnt 	<= send_cnt + 1;
			end
		end

		WAIT:// 回环测试发送
			if(wait_cnt == CLK_FRE * 1000_000)begin 
				wait_cnt <= 0;
				state <= SEND;
			end
			else begin
				send_en <= recv_en;
				send_data <= recv_data;
				wait_cnt <= wait_cnt + 1;
			end
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

//接收模块
uart_rx #(
	.CLK_FRE 	(CLK_FRE 	),
	.UART_RATE 	(UART_RATE 	)
	)uart_rx_m0(
	.clk 		(clk 		),

	.recv_en 	(recv_en 	),
	.recv_data 	(recv_data 	),

	.rx_pin 	(uart_rx 	)
	);

endmodule