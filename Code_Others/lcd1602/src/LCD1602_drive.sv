module LCD1602_drive#(
	parameter CLK_FRE = 50 
	) (
	input 				clk,    // Clock
	
	input 				send_en,
	input 		[7:0]	send_data,
	output 				send_busy,
	input 				send_rs,
	input 				send_rw,

	output reg 		 	LCD1602_RS,
	output reg 		 	LCD1602_E,
	output reg 		 	LCD1602_RW,
	output reg [ 7:0] 	LCD1602_DAT
);

logic [31:0] clk_cnt = 0;
logic 		clk_1k = 0;

always_ff@(posedge clk)
	if (clk_cnt == CLK_FRE * 1000 / 2) begin
		clk_cnt <= 'd0;
		clk_1k	<= ~clk_1k;
	end
	else
		clk_cnt <= clk_cnt + 'd1;

enum {IDLE,SEND,WAIT}STATE;
logic [2:0] state = 'd0;

assign send_busy = state != IDLE;

always_ff@(posedge clk_1k)
	case(state)
		IDLE:begin
			LCD1602_E	<= 'd0;

			if(send_en) begin
				state <= SEND;
				LCD1602_RW	<= send_rw;
				LCD1602_DAT	<= send_data;
				LCD1602_RS	<= send_rs;
			end
			else begin
				LCD1602_RW	<= 'd0;
				LCD1602_RS  <= 'D0;
				LCD1602_DAT <= 'D0;
			end
		end
			
		SEND:begin
			LCD1602_E	<= 'd1;

			state <= WAIT;
		end

		WAIT:begin
			LCD1602_E	<= 'd0;

			state <= IDLE;
		end
	endcase

endmodule