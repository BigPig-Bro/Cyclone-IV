module LCD1602_top (
	input 		 	clk,    // Clock
	input 		 	rst_n,  // Asynchronous reset active low

	output 		 	LCD1602_RS,
	output 		 	LCD1602_E,
	output 		 	LCD1602_RW,
	output [ 7:0] 	LCD1602_DAT
);

parameter RS_DAT = 1;
parameter RS_CMD = 0;
parameter INIT_CMD_NUM = 5;
parameter DISPLAY_NUM  = 16;
logic 			send_en;
logic 	[7:0] 	send_data = 'd0;
logic 	[7:0] 	send_cnt = 'd0;
logic 			send_busy;
logic 			send_rs = 'd0;

logic [31:0] clk_cnt = 'd0;

logic [15:0][7:0] dis_data1 = "KFCCrazyThursday"; 
logic [15:0][7:0] dis_data2 = "PleaseVme50 Thx!"; 
logic [INIT_CMD_NUM - 1:0][7:0] init_cmd  = {8'h3A,8'h0C,8'h06,8'h01,8'h80};

enum {IDLE,INIT,SET_H,DISPLAY_H,SET_L,DISPLAY_L,WAIT_1S,WAIT_BUSY}STATE;
logic [3:0] state_main = 'd0, pre_state = 'd0;

always_ff@(posedge clk,negedge rst_n)
	if (!rst_n) begin
		state_main <= IDLE;
		send_cnt <= 'd0;
	end
	else
		case(state_main)
			IDLE://
				state_main <= INIT;

			INIT:
				if (send_cnt == INIT_CMD_NUM) //初始化完成
				begin 
					send_en <= 0;
					send_cnt <= 0;

					state_main <= SET_H;
				end
				else if(!send_busy)begin 		  
					send_en <= 1;
					send_rs <= RS_CMD;
					send_data <= init_cmd[INIT_CMD_NUM - 1 - send_cnt];
					send_cnt <= send_cnt + 'd1;

					pre_state <= state_main;
					state_main <= WAIT_BUSY;
				end
				else
					send_en <= 0;

			SET_H:
				if(!send_busy)begin 		  
					state_main <= DISPLAY_H;
					send_en <= 1;
					send_rs <= RS_CMD;
					send_data <= 8'h80;

					pre_state <= state_main + 1;
					state_main <= WAIT_BUSY;
				end
				else
					send_en <= 0;

			DISPLAY_H:
				if (send_cnt == DISPLAY_NUM) //初始化完成
				begin 
					send_en <= 0;
					send_cnt <= 0;

					state_main <= SET_L;
				end
				else if(!send_busy)begin 		  
					send_en <= 1;
					send_rs <= RS_DAT;
					send_data <= dis_data1[15 - send_cnt];
					send_cnt <= send_cnt + 'd1;

					pre_state <= state_main;
					state_main <= WAIT_BUSY;
				end
				else
					send_en <= 0;

			SET_L:
				if(!send_busy)begin 		  
					state_main <= DISPLAY_L;
					send_en <= 1;
					send_rs <= RS_CMD;
					send_data <= 8'hC0;

					pre_state <= state_main + 1;
					state_main <= WAIT_BUSY;
				end
				else
					send_en <= 0;

			DISPLAY_L:
				if (send_cnt == DISPLAY_NUM) //初始化完成
				begin 
					send_en <= 0;
					send_cnt <= 0;

					state_main <= WAIT_1S;
				end
				else if(!send_busy)begin 		  
					send_en <= 1;
					send_rs <= RS_DAT;
					send_data <= dis_data2[15 - send_cnt];
					send_cnt <= send_cnt + 'd1;

					pre_state <= state_main;
					state_main <= WAIT_BUSY;
				end
				else
					send_en <= 0;

			WAIT_1S:
				if (clk_cnt == 20_000_000) begin
					clk_cnt <= 'd0;
					state_main <= INIT;
				end
				else
					clk_cnt ++;

			WAIT_BUSY:
				if(send_busy) state_main <= pre_state;

		endcase


LCD1602_drive #(
	.CLK_FRE (20 			)
	)LCD1602_drive_m0(
	.clk			( clk			),

	.send_en		(send_en		),
	.send_data		(send_data		),
	.send_busy		(send_busy		),
	.send_rs		(send_rs		),
	.send_rw		(1'b0			), // 1602只有写

	.LCD1602_RS		( LCD1602_RS	),	
	.LCD1602_E		( LCD1602_E		),	
	.LCD1602_RW		( LCD1602_RW	),	
	.LCD1602_DAT	( LCD1602_DAT	)		
	);
endmodule