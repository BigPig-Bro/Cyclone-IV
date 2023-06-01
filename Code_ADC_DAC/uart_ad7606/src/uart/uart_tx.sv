// 数据位 8 停止位 1 无奇偶校验
module uart_tx#(
	parameter CLK_FRE 	= 50,
	parameter UART_RATE = 115200
	) (
	input 				clk,    // 
	
	input 				send_en ,	
	output 	 			send_busy ,	
	input 		[ 7:0] 	send_data ,	

	output reg 			tx_pin = 1
);
parameter  RATE_CNT = (CLK_FRE * 1000_000 / UART_RATE) - 1;
reg [25:0] clk_cnt;

enum {WAIT,START,SEND,STOP}STATE_TX;
reg [1:0] state;

assign send_busy = state != WAIT;

reg [ 7:0] send_data_r;
reg [ 2:0] send_cnt;

always@(posedge clk)
	case(state)
		WAIT:
			if(send_en)begin 
				send_data_r <= send_data;
				send_cnt <= 'd0;

				state <= START;
			end

		START:begin 
			tx_pin <= 0;

			if(clk_cnt == RATE_CNT)begin 
				clk_cnt <= 0;
				state <= SEND;
			end
			else
				clk_cnt <= clk_cnt + 1;
		end

		SEND:begin 
			tx_pin <= send_data_r[send_cnt];

			if(clk_cnt == RATE_CNT)begin 
				clk_cnt <= 0;
				send_cnt <= send_cnt + 1;
				state <= (send_cnt == 7 )?STOP : SEND ;
			end
			else
				clk_cnt <= clk_cnt + 1;
		end

		STOP:begin 
			tx_pin <= 1;

			if(clk_cnt == RATE_CNT)begin 
				clk_cnt <= 0;
				state <= WAIT;
			end
			else
				clk_cnt <= clk_cnt + 1;
		end
	endcase
endmodule