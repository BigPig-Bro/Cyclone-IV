//需要上电按复位键
module LCD12864_top (
	input 			clk,    // Clock
	input 			rst_n,  // Asynchronous reset active low
	output reg [15:0] cnt,
	output 			LCD_RST,
	output 			LCD_RS, //CMD DAT
	output 			LCD_E, //CLK
	output 			LCD_RW, //READ WRITE
	output 			LCD_PSB, //串并转换 1并口
	inout [ 7:0] 	LCD_DAT
);
always@(posedge clk) cnt ++;
parameter RS_DAT = 1;
parameter RS_CMD = 0;
parameter CLK_FRE 		= 20;
parameter INIT_CMD_NUM 	= 4;
parameter SET_CMD_NUM 	= 4;
parameter END_CMD_NUM 	= 2;

parameter PAGE_NUM 			= 2; // 整个12864由 2个page * 32个块，每个块写16个8bit
parameter BLOCK_NUM 		= 32;
parameter BLOCK_BYTE_NUM 	= 16;

parameter DELAY_1000MS 	= CLK_FRE * 1000 * 1000 ;
enum {RESET,INIT,DISPLAY,DELAY_1S,WAIT_BUSY}STATE_M;
enum {SET_XY,SEND_BLOCK,END}STATE_S;

logic [INIT_CMD_NUM - 1:0][7:0] init_cmd  = {8'h30,8'h01,8'h06,8'h0C};
logic [SET_CMD_NUM  - 1:0][7:0] set_cmd   = {8'h34,8'h80,8'h80,8'h30};
logic [END_CMD_NUM  - 1:0][7:0] end_cmd   = {8'h36,8'h30};
reg [7:0] ram_data[1023:0];
initial $readmemh("VME50.txt", ram_data);
 
logic [ 3:0] state_main = 'd0;
logic [ 3:0] state_sub 	= 'd0;
logic [ 3:0] state_pre 	= 'd0;
logic [31:0] clk_cnt 	= 'd0;

logic 			send_en = 'd0;
logic 	[7:0] 	send_data = 'd0;
logic 	[7:0] 	send_cnt = 'd0;
logic 			send_busy;
logic 			send_rs = 'd0;

logic [ 6:0] 	block_cnt	 = 'd0;
logic [ 3:0] 	page_cnt = 'd0;

assign 	LCD_RST = 1'b1;
assign 	LCD_PSB = 1'b1; //串并转换 1并口

reg [7:0] data_r = 'd0;
always@(posedge clk) data_r <= ~ram_data[page_cnt * 512 + block_cnt * 16 + send_cnt];

always@(posedge clk,negedge rst_n)
	if (!rst_n) begin
		state_main <= RESET;
		send_cnt <= 'd0;
		send_en <= 'd0;
	end
	else
		case (state_main)
			RESET:
				if(clk_cnt == DELAY_1000MS)begin 
					clk_cnt <= 'd0;
					state_main <= INIT;
				end
				else 
					clk_cnt <= clk_cnt + 'd1; 
			INIT:
				if (send_cnt == INIT_CMD_NUM) //初始化完成
				begin 
					send_en <= 0;
					send_cnt <= 0;

					state_main <= DISPLAY;
				end
				else if(!send_busy)begin 		  
					send_en <= 1;
					send_rs <= RS_CMD;
					send_data <= init_cmd[INIT_CMD_NUM - 1 - send_cnt];
					send_cnt <= send_cnt + 'd1;

					state_pre <= state_main;
					state_main <= WAIT_BUSY;
				end
				else
					send_en <= 0;

			DISPLAY:
				case(state_sub)
					SET_XY:
						if(page_cnt == PAGE_NUM - 1 && block_cnt == BLOCK_NUM )begin
							page_cnt 	<= 'D0;
							block_cnt 	<= 'D0;
							state_sub	<= END; 
						end
						else if(block_cnt == BLOCK_NUM )begin
							page_cnt   <= page_cnt + 'D1 ;
							block_cnt 	<= 'D0;
							state_sub	<= END; 
						end
						else if (send_cnt == INIT_CMD_NUM) //初始化完成
						begin 
							send_en <= 0;
							send_cnt <= 0;

							state_sub <= SEND_BLOCK;
						end
						else if(!send_busy)begin 		  
							send_en <= 1;
							send_rs <= RS_CMD;

							case (send_cnt)
								0: send_data <= set_cmd[SET_CMD_NUM - 1 - send_cnt];
								1: send_data <= set_cmd[SET_CMD_NUM - 1 - send_cnt] + block_cnt;
								2: send_data <= set_cmd[SET_CMD_NUM - 1 - send_cnt] + page_cnt * 8;
								3: send_data <= set_cmd[SET_CMD_NUM - 1 - send_cnt];
							endcase
							send_cnt <= send_cnt + 'd1;

							state_pre <= state_main;
							state_main <= WAIT_BUSY;
						end
						else
							send_en <= 0;
					SEND_BLOCK:
						if (send_cnt == BLOCK_BYTE_NUM) //初始化完成
						begin 
							send_en <= 0;
							send_cnt <= 0;
							block_cnt  <= block_cnt + 'd1;

							state_sub <= SET_XY;
						end
						else if(!send_busy)begin 		  
							send_en <= 1;
							send_rs <= RS_DAT;

							send_data <= data_r;
							send_cnt <= send_cnt + 'd1;

							state_pre <= state_main;
							state_main <= WAIT_BUSY;
						end
						else
							send_en <= 0;

					END:
						if (send_cnt == END_CMD_NUM) //初始化完成
						begin 
							send_en <= 0;
							send_cnt <= 0;

							state_main <= DELAY_1S; // 循环显示
							state_sub <= 'd0;
						end
						else if(!send_busy)begin 		  
							send_en <= 1;
							send_rs <= RS_CMD;
							send_data <= end_cmd[END_CMD_NUM - 1 - send_cnt];
							send_cnt <= send_cnt + 'd1;

							state_pre <= state_main;
							state_main <= WAIT_BUSY;
						end
						else
							send_en <= 0;
				endcase

			DELAY_1S:begin
				if(clk_cnt == DELAY_1000MS)begin 
					clk_cnt <= 'd0;
				end
				else 
					clk_cnt <= clk_cnt + 'd1; 
			end

			WAIT_BUSY:
				if(send_busy) state_main <= state_pre;
		endcase


LCD12864_drive #(
	.CLK_FRE (CLK_FRE 		)
	) LCD12864_drive_m0(
	.clk 		(clk 	 ),
	.rst_n 		(rst_n 	 ),

	.send_en		(send_en		),
	.send_data		(send_data		),
	.send_busy		(send_busy		),
	.send_rs		(send_rs		),
	.send_rw		(1'b0			), // 12864不读，只读BUSY

	.LCD12864_RS	(LCD_RS	 		),
	.LCD12864_RW	(LCD_RW	 		),
	.LCD12864_E		(LCD_E 			),	
	.LCD12864_DAT	(LCD_DAT 		)	
	);
endmodule