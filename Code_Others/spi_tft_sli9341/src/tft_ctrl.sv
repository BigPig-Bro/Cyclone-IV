module tft_ctrl#(
	parameter CLK_FRE = 50
	) (
	input 			  clk,rst_n,

	output reg		  state_rst  = 'd0,
	input 			  send_busy ,	
	output reg 		  send_en = 'd0,   	
	output reg  	  send_dc = 'd0,   	
	output reg [ 7:0] send_data = 'd0	
);

parameter DELAY_120MS = CLK_FRE  *1000 * 120;

parameter INIT_CMD_NUM 	= 80 ;
parameter SET_CMD_NUM 	= 11 ;

// parameter PIXEL_X = 320 ;
// parameter PIXEL_Y = 240 ;

parameter TFT_REG     = 1'B0;
parameter TFT_DAT     = 1'B1;
parameter CMD_WAKE     = 8'h29;

//测试区域
parameter TEST_X1   = 16'd100;
parameter TEST_X2   = 16'd200;
parameter TEST_Y1   = 16'd100;
parameter TEST_Y2   = 16'd200;
// reg [15:0] TEST_COLOR; //以X赋值，彩条

enum {STATE_RESET ,STATE_INIT  ,STATE_SLEEP ,STATE_WAKE ,STATE_WRITE ,STATE_WAIT } state;

logic [ 2:0] pre_state = 0;
logic [ 2:0] state_main = 0;
logic [ 2:0] state_sub = 0;
logic [31:0] clk_delay = 0;

logic [18:0] send_cnt = 0;
logic [ 8:0] init_cmd[INIT_CMD_NUM - 1:0] ;
initial $readmemh("init.txt",init_cmd);

logic [SET_CMD_NUM - 1:0][ 7:0] set_cmd = //CMDX X1H X1L X2H X2L CMDY Y1H Y1L Y2H Y2L  
{8'h2A,8'h00,8'h00,8'h00,8'h00,8'h2B,8'h00,8'h00,8'h00,8'h00,8'h2C};

always@(posedge clk,negedge rst_n)
	if(!rst_n)begin 
		state_main <= 0;
		state_sub  <= 0;
	end
	else
		case (state_main)
			STATE_RESET://reset
				case (state_sub)
					3'd0:
						if(clk_delay == DELAY_120MS)begin
							state_rst <= 'b0;
							clk_delay <= 'd0;
							state_sub ++;
						end
						else begin 
							state_rst <= 'b1;
							clk_delay ++;
						end

					3'd1:
						if(clk_delay == DELAY_120MS)begin
							state_rst <= 'b1;
							clk_delay <= 'd0;
							state_sub ++;
						end
						else  
							clk_delay ++;

					3'd2:
						if(clk_delay == DELAY_120MS)begin
							clk_delay <= 'd0;
							state_sub <= 0;

							send_cnt <= 0;
							state_main ++;
						end
						else begin 
							clk_delay ++;
						end
				endcase
			STATE_INIT://initial oled
				if (send_cnt == INIT_CMD_NUM) //初始化完成
				begin 
					send_en <= 0;
					send_cnt <= 0;
					state_sub <= 0;

					state_main ++;
				end
				else if(!send_busy)begin 		  //spi空闲
					send_en <= 1;
					send_dc <= init_cmd[send_cnt][8];
					send_data <= init_cmd[send_cnt][7:0];
					send_cnt ++;

					pre_state <= state_main;
					state_main <= STATE_WAIT;
				end
				else
					send_en <= 0;

			STATE_SLEEP:
				if(clk_delay == DELAY_120MS)begin
					clk_delay <= 'd0;
					state_main ++;
				end
				else begin 
					clk_delay ++;
				end

			STATE_WAKE:
				if(!send_busy)begin 		  //spi空闲
					send_en <= 1;
					send_dc <= TFT_REG;
					send_data <= CMD_WAKE;
					send_cnt <= 0;

					pre_state <= state_main + 'd1;
					state_main <= STATE_WAIT;
				end
				else
					send_en <= 0;
				
			STATE_WRITE://write data
				case (state_sub)
					3'd0: //定位具体 左上右下
						if (send_cnt == SET_CMD_NUM) begin//初始化完成
							send_en <= 0;
							send_cnt <=0;
							// state_main ++; //维持在这儿
							state_sub <= state_sub + 'd1;
						end
						else if(!send_busy) begin 		  //spi空闲
							send_en <= 1;
							send_dc <= ((send_cnt == 0 ) || (send_cnt == 5 ) || (send_cnt == 10 ))?TFT_REG : TFT_DAT;
							case (send_cnt)
								 0: send_data <= set_cmd[SET_CMD_NUM -  1 - send_cnt];
								 1: send_data <= set_cmd[SET_CMD_NUM -  1 - send_cnt] + TEST_X1[15:8];
								 2: send_data <= set_cmd[SET_CMD_NUM -  1 - send_cnt] + TEST_X1[ 7:0];
								 3: send_data <= set_cmd[SET_CMD_NUM -  1 - send_cnt] + TEST_X2[15:8];
								 4: send_data <= set_cmd[SET_CMD_NUM -  1 - send_cnt] + TEST_X2[ 7:0];
								 5: send_data <= set_cmd[SET_CMD_NUM -  1 - send_cnt];
								 6: send_data <= set_cmd[SET_CMD_NUM -  1 - send_cnt] + TEST_Y1[15:8];
								 7: send_data <= set_cmd[SET_CMD_NUM -  1 - send_cnt] + TEST_Y1[ 7:0];
								 8: send_data <= set_cmd[SET_CMD_NUM -  1 - send_cnt] + TEST_Y2[15:8];
								 9: send_data <= set_cmd[SET_CMD_NUM -  1 - send_cnt] + TEST_Y2[ 7:0];
								10: send_data <= set_cmd[SET_CMD_NUM -  1 - send_cnt];
							endcase
							send_cnt ++;

							pre_state <= state_main;
							state_main <= STATE_WAIT;
						end
						else
							send_en <= 0;
					3'd1://写入 显示数据
						if (send_cnt == ((TEST_Y2 - TEST_Y1) * (TEST_X2 - TEST_X1)) * 2) begin
							send_en <= 0;
							send_cnt <= 0;
							state_sub <= 0;
						end
						else if(!send_busy) begin 		  //spi空闲
							send_en <= 1;
							send_dc <= TFT_DAT;
							send_data <= send_cnt [18:11]; //以X赋值，彩条;
							send_cnt ++;

							pre_state <= state_main;
							state_main <= STATE_WAIT;
						end
						else
							send_en <= 0;
				endcase
			STATE_WAIT://WAIT FOR BUSY 
				if(send_busy) state_main <= pre_state;

			default : begin
				state_main <= 'd0;
				state_sub  <= 'd0;
			end
		endcase

endmodule	
