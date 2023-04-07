module ds1302_top#(
	parameter  	CLK_FRE 	= 50,
	parameter  	DS1302_FRE 	= 10000,
	parameter  	START_SEC 	= 8'H00,
	parameter  	START_MIN 	= 8'H00,
	parameter  	START_HOU 	= 8'H12,
	parameter  	START_DAY 	= 8'H01,
	parameter  	START_MON 	= 8'H01,
	parameter  	START_WEK 	= 8'H01,
	parameter  	START_YEA 	= 8'H22
	) (
	input 				clk,    // Clock
	input 				rst_n,  // Asynchronous reset active low
	
	output reg [7:0] 	sec_data, 	
	output reg [7:0] 	min_data, 	
	output reg [7:0] 	hou_data, 	
	output reg [7:0] 	day_data, 	
	output reg [7:0] 	mon_data, 	
	output reg [7:0] 	wek_data, 	
	output reg [7:0] 	yea_data, 

	output 	 			ds1302_sck, 
	inout 	 			ds1302_dat, 
	output 	 			ds1302_rst 
);

parameter INIT_CMD_NUM 	= 9; 
parameter TIME_NUM 		= 7; 
parameter DELAY_10MS 	= CLK_FRE * 10 * 1000;

wire 		send_busy ;
wire [ 7:0] recv_data;
reg  [ 7:0] send_addr,send_data;
reg  [ 3:0] send_cnt;
reg 		send_en;

enum {DELAY,INIT_TIME,READ_TIME,WAIT_TIME,WAIT_BUSY}STATE;
reg  [ 3:0] state_main = 'd0;
reg  [ 3:0] state_next = 'd0;
reg  [19:0] clk_delay = 'd0;

always@(posedge clk,negedge rst_n)
	if(!rst_n)begin 
		state_main 	<= 'd0;
		send_cnt 	<= 'd0;
		send_en 	<= 'b0;
	end
	else
		case(state_main)
			DELAY:
				if(clk_delay == DELAY_10MS)begin
					clk_delay <= 'd0;
					state_main <= INIT_TIME;
				end
				else  
					clk_delay <= clk_delay + 'd1;

			INIT_TIME:
				if (send_cnt == INIT_CMD_NUM) //初始化完成
				begin 
					send_en <= 0;
					send_cnt <= 0;

					state_main <= READ_TIME;
				end
				else if(!send_busy)begin 		  
					send_en <= 1;
					send_cnt <= send_cnt + 'd1;
					case(send_cnt)
						0:begin //关闭写保护
							send_addr <= 8'H8E;
							send_data <= 8'H00;
						end

						1:begin 
							send_addr <= 8'H80;
							send_data <= START_SEC;
						end

						2:begin 
							send_addr <= 8'H82;
							send_data <= START_MIN;
						end

						3:begin 
							send_addr <= 8'H84;
							send_data <= START_HOU;
						end

						4:begin 
							send_addr <= 8'H86;
							send_data <= START_DAY;
						end

						5:begin 
							send_addr <= 8'H88;
							send_data <= START_WEK;
						end

						6:begin 
							send_addr <= 8'H8A;
							send_data <= START_MON;
						end

						7:begin 
							send_addr <= 8'H8C;
							send_data <= START_YEA;
						end

						8:begin //打开写保护
							send_addr <= 8'H8E;
							send_data <= 8'H80;
						end
					endcase

					state_next <= state_main;
					state_main <= WAIT_BUSY;
				end
				else
					send_en <= 0;

			READ_TIME:
				if (send_cnt == TIME_NUM) //初始化完成
				begin 
					send_en <= 0;
					send_cnt <= 0;
					yea_data <= recv_data;

					state_main <= WAIT_TIME;
				end
				else if(!send_busy)begin 		  
					send_en <= 1;
					send_cnt <= send_cnt + 'd1;
					case(send_cnt)
						0:begin 
							send_addr <= 8'H80 + 1;
						end

						1:begin 
							send_addr <= 8'H82 + 1;
							sec_data <= recv_data;
						end

						2:begin 
							send_addr <= 8'H84 + 1;
							min_data <= recv_data;
						end

						3:begin 
							send_addr <= 8'H86 + 1;
							hou_data <= recv_data;
						end

						4:begin 
							send_addr <= 8'H88 + 1;
							day_data <= recv_data;
						end

						5:begin 
							send_addr <= 8'H8A + 1;
							wek_data <= recv_data;
						end

						6:begin 
							send_addr <= 8'H8C + 1;
							mon_data <= recv_data;
						end
					endcase

					state_next <= state_main;
					state_main <= WAIT_BUSY;
				end
				else
					send_en <= 0;

			WAIT_TIME:
				if(clk_delay == DELAY_10MS)begin
					clk_delay <= 'd0;
					state_main <= READ_TIME;
				end
				else  
					clk_delay <= clk_delay + 'd1;

			WAIT_BUSY:begin
				if(send_busy)begin
					send_en <= 0;
					state_main <= state_next;
				end
			end

	endcase

ds1302_drive #(
	.CLK_FRE 	(CLK_FRE 	),
	.DS1302_FRE (DS1302_FRE )
	)m3(
	.clk 		(clk 		),

	.addr 		(send_addr 	),
	.send_data 	(send_data	),
	.recv_data 	(recv_data	),
	.send_en 	(send_en 	),
	.busy 		(send_busy  ),

	.ds1302_sck (ds1302_sck ),
	.ds1302_dat (ds1302_dat ),
	.ds1302_rst (ds1302_rst )
	);

endmodule