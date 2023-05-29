module uart_top #(
	parameter CLK_FRE 		= 50,
	parameter UART_RATE 	= 115200,
	parameter SEND_FRE 		= 2
	)(
	input 				clk,    // 
	
	input [7:0][15:0] 	ad7606_data,	

	output				uart_tx
);

enum {SEND,WAIT}STATE_LOOP;
reg [1:0] state;

reg  [31:0] wait_cnt;
reg  [ 7:0] send_cnt;
reg  [ 7:0] send_data;
reg  	    send_en;

//发送寄存器
parameter 	ENG_NUM  = 80;//非中文字符数 /N算两个字符
parameter 	CHE_NUM  = 0;//  中文字符数
parameter 	DATA_NUM = CHE_NUM * 3 + ENG_NUM; //中文字符使用UTF8，占用3个字节
wire [ DATA_NUM * 8 - 1:0] char_data = {"CH0:00000 CH1:00000 CH2:00000 CH3:00000 CH4:00000 CH5:00000 CH6:00000 CH7:00000\n"};
wire [15:0] ADC_data;
wire [7:0] char_data_r;

always@(posedge clk)
	case(send_cnt)
		'd0 :ADC_data <= ad7606_data[0];
		'd10:ADC_data <= ad7606_data[1];
		'd20:ADC_data <= ad7606_data[2];
		'd30:ADC_data <= ad7606_data[3];
		'd40:ADC_data <= ad7606_data[4];
		'd50:ADC_data <= ad7606_data[5];
		'd60:ADC_data <= ad7606_data[6];
		'd70:ADC_data <= ad7606_data[7];
		default:ADC_data <= ADC_data;
	endcase

always@*
	case(send_cnt)
		'd4,'d14,'d24,'d34,'d44,'d54,'d64,'d74:char_data_r <= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + ADC_data / 10000;
		'd5,'d15,'d25,'d35,'d45,'d55,'d65,'d75:char_data_r <= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + ADC_data / 1000 % 10;
		'd6,'d16,'d26,'d36,'d46,'d56,'d66,'d76:char_data_r <= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + ADC_data / 100 % 10;
		'd7,'d17,'d27,'d37,'d47,'d57,'d67,'d77:char_data_r <= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + ADC_data / 10 % 10;
		'd8,'d18,'d28,'d38,'d48,'d58,'d68,'d78:char_data_r <= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8] + ADC_data % 10;
		default: char_data_r <= char_data[ (DATA_NUM - 1 - send_cnt) * 8 +: 8];
	endcase

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
				send_data 	<= char_data_r;
				send_cnt 	<= send_cnt + 1;
			end
		end

		WAIT://等待
			if(wait_cnt == CLK_FRE * 1000_000 / SEND_FRE)begin 
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