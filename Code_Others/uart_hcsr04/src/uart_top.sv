module uart_top #(
	parameter CLK_FRE 		= 50,
	parameter UART_RATE 	= 115200
	)(
	input 			clk,    // 
	
	input   [15:0]  data   ,
	output			uart_tx
);


enum {SEND,WAIT}STATE_LOOP;
reg [1:0] state;

reg  [31:0] wait_cnt;
reg  [ 7:0] send_cnt;
reg  [ 7:0] send_data;
reg  	    send_en;

//发送寄存器
parameter 	ENG_NUM  = 18;//非中文字符数
parameter 	CHE_NUM  = 0;//  中文字符数
parameter 	DATA_NUM = CHE_NUM * 3 + ENG_NUM; //中文字符使用UTF8，占用3个字节
wire [ DATA_NUM * 8 - 1:0] char_data = {"HC-SR04: 0000 mm","\r\n"};
reg [7:0] send_data_r;

always@*
	case (send_cnt)
		8'd9: send_data_r <= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + data / 1000 % 10 ;
		8'd10: send_data_r <= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + data / 100 % 10 ;
		8'd11: send_data_r <= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + data / 10 % 10 ;
		8'd12: send_data_r <= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + data % 10 ;
		default : send_data_r <= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8];
	endcase	

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
				send_data 	<= send_data_r;
				send_cnt 	<= send_cnt + 1;
			end
		end

		WAIT: 
			if(wait_cnt == CLK_FRE * 1000_000)begin 
				wait_cnt <= 0;
				state <= SEND;
			end
			else begin
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

endmodule