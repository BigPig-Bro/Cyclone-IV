module ds1302_drive #(
	parameter CLK_FRE 		= 50,	
	parameter DS1302_FRE 	= 100000
	) (
	input 				clk,    // Clock
		
	input 		[ 7:0]	addr ,		
	input 		[ 7:0]	send_data ,	
	output reg  [ 7:0]	recv_data ,	
	input 				send_en ,	
	output 				busy ,	

	output reg			ds1302_sck ,
	inout 				ds1302_dat ,
	output reg			ds1302_rst 
);


reg DAT_IN;
reg dat_out;
//分出个SCL X2出来
parameter CLK_DIV = CLK_FRE * 500 * 1000 / DS1302_FRE;
reg [9:0] clk_delay = 0;
reg scl_x2 = 0;
always@(posedge clk) clk_delay <= (clk_delay == CLK_DIV)? 0 : clk_delay + 'd1;
always@(posedge clk) scl_x2 <= clk_delay >= CLK_DIV / 2;

assign ds1302_dat = DAT_IN? 1'bz : dat_out;

//端口采样，避免影响主机时序
reg [ 7:0] send_data_r  	= 0;
reg [ 7:0] addr_r  			= 0;

reg [7:0] recv_data_r = 0;
reg [3:0] send_cnt    = 0;

enum { STATE_IDLE, STATE_REG, STATE_DATA } STATE;	
reg [ 2:0] state_main = 0;
reg [ 1:0] state_sub = 0;

assign busy = state_main != STATE_IDLE;

assign ds1302_rst = state_main != STATE_IDLE;

always@(posedge scl_x2)
	case (state_main)
		STATE_IDLE://等待 en 触发信号
			if (send_en) begin
				DAT_IN 		<= 'b0;
				send_data_r <= send_data;
				addr_r 		<= addr;

				state_main <= STATE_REG;
			end

		STATE_REG:
			case (state_sub)
				2'd0:begin//下降沿 准备数据
					ds1302_sck 	<= 0;
					dat_out  	<= (send_cnt == 8)? 'd0 :addr_r[send_cnt];

					send_cnt  	<= (send_cnt == 8)? 'd0 : send_cnt + 'd1;
					state_main 	<= (send_cnt == 8)? STATE_DATA  : state_main;
					DAT_IN 	   	<= (send_cnt == 8)? addr_r[0] : DAT_IN;
					state_sub  	<= (send_cnt == 8)? 'd0 : state_sub + 'd1;
				end

				2'd1:begin//上升沿 发送数据
					ds1302_sck <= 1;

					state_sub <= 'd0;
				end
			endcase

		STATE_DATA:
			case (state_sub)
				2'd0:begin//下降沿 准备数据
					ds1302_sck 	<= 0;
					dat_out  	<= (send_cnt == 8)? 'd0 :send_data_r[send_cnt];

					send_cnt   <= (send_cnt == 8)? 'd0 : send_cnt + 'd1;
					state_main <= (send_cnt == 8			 )? STATE_IDLE  : state_main;
					recv_data  <= (send_cnt == 8 && addr_r[0])? recv_data_r  : recv_data;
					state_sub  <= (send_cnt == 8)? 'd0 : state_sub + 'd1;
				end

				2'd1:begin//上升沿 发送数据
					ds1302_sck <= 1;
					recv_data_r <= {ds1302_dat,recv_data_r[7:1]} ;

					state_sub <= 'd0;
				end
			endcase
	endcase

endmodule