module uart_top #(
	parameter CLK_FRE 		= 50,
	parameter UART_RATE 	= 115200
	)(
	input 		clk,    // 
	
	input [12:0] [3:0] scan_data, // 扫描矩阵数据
	output		uart_tx
);

enum {SEND,WAIT}STATE_LOOP;
reg [1:0] state;

reg  [ 7:0] send_cnt;
reg  [ 7:0] send_data;
reg  	    send_en;

wire [ 7:0] recv_data;
wire 		recv_en;

//发送寄存器
parameter 	ENG_NUM  = 20;//非中文字符数
parameter 	CHE_NUM  = 0;//  中文字符数
parameter 	DATA_NUM = CHE_NUM * 3 + ENG_NUM; //中文字符使用UTF8，占用3个字节
wire [ DATA_NUM * 8 - 1:0] char_data_r = {"Code:0000000000000","\r\n"};

wire [7:0] char_data;
always@*
	case(send_cnt)
		8'd5,8'd6,8'd7,8'd8, 8'd9,8'd10,8'd11,8'd12 ,8'd13,8'd14,8'd15,8'd16 ,8'd17:
			char_data = char_data_r[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + scan_data[send_cnt - 5]; 
		default:
			char_data = char_data_r[ (DATA_NUM - 1 - send_cnt) * 8 +: 8];
	endcase

//仲裁机制
reg [31:0] wait_cnt;
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
				send_data 	<= char_data;
				send_cnt 	<= send_cnt + 1;
			end
		end

		WAIT:
			if(wait_cnt <= CLK_FRE * 500_000)begin // 每半秒发送一次
				wait_cnt <= wait_cnt + 1;
			end
			else begin
				wait_cnt <= 0;
				state <= SEND;
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