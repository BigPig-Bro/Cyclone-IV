module LCD12864_drive#(
	parameter CLK_FRE = 50 
	) (
	input 				clk,rst_n,    // Clock
	
	input 				send_en,
	input 		[7:0]	send_data,
	output 				send_busy,
	input 				send_rs,
	input 				send_rw,

	output reg 		 	LCD12864_RS,
	output reg 		 	LCD12864_E,
	output reg 		 	LCD12864_RW,
	inout  		[ 7:0] 	LCD12864_DAT
);

logic [31:0] clk_cnt = 0;
logic 		clk_1k = 0;

always_ff@(posedge clk)
	if (clk_cnt == CLK_FRE  * 1000 / 2) begin
		clk_cnt <= 'd0;
		clk_1k	<= ~clk_1k;
	end
	else
		clk_cnt <= clk_cnt + 'd1;

enum {IDLE,DEC_BUSY,SEND,WAIT}STATE;
logic [2:0] state = 'd0;
logic [2:0] state_busy = 'd0;
logic [7:0] DAT_REG = 'd0;
logic     	DAT_IN = 'd0;

assign send_busy = ~(state == IDLE || state == DEC_BUSY);
assign LCD12864_DAT = DAT_IN? 'BZ : DAT_REG;

always_ff@(posedge clk_1k,negedge rst_n)
	if(!rst_n)begin 
		state <= 'd0;
		state_busy <= 'd0;

		DAT_IN 			<= 'd0;
		DAT_REG 		<= 'D0;
		LCD12864_RW		<= 'd0;
		LCD12864_RS  	<= 'D0;
	end
	else	
		case(state)
		IDLE:begin
			LCD12864_E	<= 'd0;

			if(send_en) begin
				state 			<= DEC_BUSY;
				state_busy 		<= 'd0;
				DAT_IN 			<= 'd1;
				DAT_REG			<= 8'hff;
				LCD12864_RW		<= 'd1;
				LCD12864_RS  	<= 'D0;
			end
			else begin
				DAT_IN 			<= 'd0;
				DAT_REG 		<= 'D0;
				LCD12864_RW		<= 'd0;
				LCD12864_RS  	<= 'D0;
			end
		end

		DEC_BUSY:
			case (state_busy)
				0:begin
					LCD12864_E	<= 'd1;

					state_busy <= state_busy + 'b1;
				end

				1:begin
					LCD12864_E	<= 'd0;
					if(LCD12864_DAT[7] == 0)begin

						DAT_IN <= 'd0;
						LCD12864_RW	<= send_rw;
						DAT_REG		<= send_data;
						LCD12864_RS	<= send_rs;
						state_busy <= 'd0;
						state <= SEND;
					end
					else begin
						DAT_REG		<= 8'hff;
						state_busy  <= 'd0;
					end
				end
			endcase
			
		SEND:begin
			LCD12864_E	<= 'd1;

			state <= WAIT;
		end

		WAIT:begin
			LCD12864_E	<= 'd0;

			state <= IDLE;
		end
		endcase

endmodule