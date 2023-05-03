module uart_top (
	input 		clk,    // 
	
	output		uart_tx
);
//============================== 测试模块  ===============================================
reg [5:0] count;
always@(posedge state[0])
	count <= count + 1;

parameter CLK_FRE 		= 50;
parameter UART_RATE 	= 115200;

//============================== 串口模块  ===============================================
enum {SEND,WAIT}STATE_LOOP;
reg [1:0] state;

reg  [31:0] wait_cnt;
reg  [ 7:0] send_cnt;
reg  [ 7:0] send_data;
reg  	    send_en;
wire 	    send_busy;

//发送寄存器
parameter 	ENG_NUM  = 17;//字符数
wire [ ENG_NUM * 8 - 1:0] char_data_r = {"{plotter:00,00}","\r\n"};//数据1 数据2
wire [ 7:0] char_data;

always@*
	case(send_cnt)
		'd9: char_data = char_data_r[ (ENG_NUM - 1 - send_cnt) * 8 +: 8] + count / 10;
		'd10: char_data = char_data_r[ (ENG_NUM - 1 - send_cnt) * 8 +: 8] + count % 10;

		'd12: char_data = char_data_r[ (ENG_NUM - 1 - send_cnt) * 8 +: 8] + count[1:0];
		'd13: char_data = char_data_r[ (ENG_NUM - 1 - send_cnt) * 8 +: 8] + count[2];
		default: char_data = char_data_r[ (ENG_NUM - 1 - send_cnt) * 8 +: 8];
	endcase

//仲裁机制
always@(posedge clk)
	case(state)
		SEND:begin // 主动发送
			if(send_cnt == ENG_NUM + 1)begin 
				send_en 	<= 'b0;
				send_cnt 	<=  0;
				state 		<= WAIT;
			end
			else if(!send_busy)begin
				send_en 	<= 'b1;
				send_data 	<= char_data;
				send_cnt 	<= send_cnt + 1;
			end
		end

		WAIT:// 回环测试发送
			if(wait_cnt == CLK_FRE * 100_000)begin 
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