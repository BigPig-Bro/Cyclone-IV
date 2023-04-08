module lcd_display(
	input				clk,
	input 				rst_n,

	input				key_sw,
	input				key_l,
	input				key_r,

	input				hs_in,
	input 				vs_in,
	input 				de_in,
	input [15:0] 		x_in,
	input [15:0] 		y_in,
	output reg [3:0]	 	ram_state,
	output reg			hs_out,
	output reg			vs_out,
	output reg			de_out,
	output reg	[23:0]	rgb_out = 24'hff0000,
	output 				pwm_out
	);

/*************************************************************************************************/
/*************************************************************************************************/
/********************************** 	              	******************************************/
/********************************** 	 按键控制逻辑  	******************************************/
/********************************** 	              	******************************************/
/*************************************************************************************************/
/*************************************************************************************************/
reg  			state = 0;		//画面显示切换
reg [1:0]		level_mode; //难度选择

reg [1:0] 		key_l_reg;//按键寄存器 L
reg [1:0]		key_r_reg;//按键寄存器 R
reg [1:0]		key_s_reg;//按键寄存器 SW

always@(posedge clk)begin 
	key_l_reg <= {key_l_reg[0],key_l };
	key_r_reg <= {key_r_reg[0],key_r };
	key_s_reg <= {key_s_reg[0],key_sw};
end

always@(posedge clk)begin 
	case (state)
		1'b0:begin // 选择难度
			if(key_l_reg == 2'b01)begin
				level_mode <= level_mode == 0? 0 : level_mode - 1;
			end
			else if(key_r_reg == 2'b01)begin
				level_mode <= level_mode == 2? 2 : level_mode + 1;
			end

			if(key_s_reg == 2'b01)
				state <= state + 1'b1;
		end

		1'b1:begin // 操控游戏界面 ，等待复位
			if(!rst_n)
				state <= 1'b0;
		end
	endcase
end

//速度变量控制
reg [7:0] speed;

always@(posedge vs_in)
	case(level_mode)
		2'b00: speed <= 8'd40 ;
		2'b01: speed <= 8'd20 ;
		2'b10:begin 
			if(vs_cnt == 30 && speed > 10) speed <= speed - 1;
		end
	endcase

/*************************************************************************************************/
/*************************************************************************************************/
/********************************** 	              	******************************************/
/********************************** 	 输出显示逻辑  	******************************************/
/********************************** 	              	******************************************/
/*************************************************************************************************/
/*************************************************************************************************/
reg [14:0]	num_add;
wire 		num_data;
reg [14:0]	lev_add;
wire 		lev_data;

assign pwm_out 		= 		1'b0;

always@(posedge clk) 
begin
	case(state)
		//显示具体的难度
		1'd0:
			if(x_in >= 16'd80 && x_in <= 16'd594 && y_in >= 16'd200 && y_in < 16'd250 )begin
				lev_add	<= (x_in - 16'd80) + (y_in - 16'd200)  * 15'd514;

				if(x_in <= 16'd210)
					rgb_out <= lev_data?24'hffffff:24'h000000;
				else if(x_in <= 16'd330)
					rgb_out <= lev_data?24'hffffff:(level_mode==0)?24'h007f00:24'h000000;
				else if(x_in <= 16'd460)
					rgb_out <= lev_data?24'hffffff:(level_mode==1)?24'h007f00:24'h000000;
				else 
					rgb_out <= lev_data?24'hffffff:(level_mode==2)?24'h007f00:24'h000000;
			end
			else
				rgb_out <= 24'h000000;

		//显示游戏区域
		1'd1:
			if(x_in >= 16'd49 && x_in <= 16'd349 && y_in >= 16'd30 && y_in < 16'd450 )//游戏区域
				if(x_in >= 16'd49 + 16'd30 && x_in < 16'd349 - 16'd30  && y_in >= 16'd30 + 16'd30 && y_in < 16'd450 - 16'd30 )
					if(     (y_in - 16'd60) / 16'd30 == cube_loc_y     && (x_in - 16'd49) / 16'd30 >=cube_loc_x&& (x_in - 16'd49) / 16'd30 <= cube_loc_x + 2)
						rgb_out  <= cube[     (2 - ((x_in - 16'd49) / 16'd30 - cube_loc_x)) ]?24'h00ff00:(game_ram[(y_in - 16'd60) / 16'd30][3'd7 - (x_in - 16'd79) / 16'd30] )? 24'hff0000 :24'h000000;	
					else if((y_in - 16'd60) / 16'd30 == cube_loc_y - 1 && (x_in - 16'd49) / 16'd30 >=cube_loc_x&& (x_in - 16'd49) / 16'd30 <= cube_loc_x + 2)
						rgb_out  <= cube[ 3 + (2 - ((x_in - 16'd49) / 16'd30 - cube_loc_x)) ]?24'h00ff00:(game_ram[(y_in - 16'd60) / 16'd30][3'd7 - (x_in - 16'd79) / 16'd30] )? 24'hff0000 :24'h000000;	
					else if((y_in - 16'd60) / 16'd30 == cube_loc_y - 2 && (x_in - 16'd49) / 16'd30 >=cube_loc_x&& (x_in - 16'd49) / 16'd30 <= cube_loc_x + 2)
						rgb_out  <= cube[ 6 + (2 - ((x_in - 16'd49) / 16'd30 - cube_loc_x)) ]?24'h00ff00:(game_ram[(y_in - 16'd60) / 16'd30][3'd7 - (x_in - 16'd79) / 16'd30] )? 24'hff0000 :24'h000000;
					else  //背景区域
						rgb_out  <= (game_ram[(y_in - 16'd60) / 16'd30][3'd7 - (x_in - 16'd79) / 16'd30] )? 24'hff0000 :24'h000000;	
				else //边框
					rgb_out <= 24'h8f8f8f;
			//显示 SCORE
			else if(x_in >= 16'd360 && x_in <= 16'd747 && y_in >= 16'd30 && y_in < 16'd130 )
			begin
				num_add	<= (x_in - 16'd360) / 16'd2 + (y_in - 16'd30) / 16'd2 * 15'd555;
				rgb_out <= (num_data)?24'h000000:24'hffffff;
			end//显示 分数十位
			else if(x_in >= 16'd550 && x_in <= 16'd598 && y_in >= 16'd140 && y_in < 16'd240 )
			begin
				num_add	<= 15'd316 + score / 16'd10 * 16'd24 + (x_in - 16'd550) / 16'd2 + (y_in - 16'd140) / 16'd2 * 15'd555;
				rgb_out <= (num_data)?24'h000000:24'hFFFFFF;
			end//显示 分数个位
			else if(x_in >= 16'd600 && x_in <= 16'd648 && y_in >= 16'd140 && y_in < 16'd240 )
			begin
				num_add	<= 15'd316 + score % 16'd10 * 16'd24 + (x_in - 16'd600) / 16'd2 + (y_in - 16'd140) / 16'd2 * 15'd555;
				rgb_out <= (num_data)?24'h000000:24'hFFFFFF;
			end

			//显示 TIME
			else if(x_in >= 16'd360 && x_in <= 16'd605 && y_in >= 16'd250 && y_in < 16'd350 )
			begin
				num_add	<= 15'd190 +(x_in - 16'd360) / 16'd2 + (y_in - 16'd250) / 16'd2 * 15'd555;
				rgb_out <= (num_data)?24'h000000:24'hffffff;
			end//显示 TIME百位
			else if(x_in >= 16'd500 && x_in <= 16'd548 && y_in >= 16'd360 && y_in < 16'd460 )
			begin
				num_add	<= 15'd316 + time_cnt / 16'd100 * 16'd24 + (x_in - 16'd500) / 16'd2 + (y_in - 16'd360) / 16'd2 * 15'd555;
				rgb_out <= (num_data)?24'h000000:24'hFFFFFF;
			end//显示 TIME十位
			else if(x_in >= 16'd550 && x_in <= 16'd598 && y_in >= 16'd360 && y_in < 16'd460 )
			begin
				num_add	<= 15'd316 + time_cnt / 16'd10 % 10 * 16'd24 + (x_in - 16'd550) / 16'd2 + (y_in - 16'd360) / 16'd2 * 15'd555;
				rgb_out <= (num_data)?24'h000000:24'hFFFFFF;
			end//显示 TIME个位
			else if(x_in >= 16'd600 && x_in <= 16'd648 && y_in >= 16'd360 && y_in < 16'd460 )
			begin
				num_add	<= 15'd316 + time_cnt % 16'd10 * 16'd24 + (x_in - 16'd600) / 16'd2 + (y_in - 16'd360) / 16'd2 * 15'd555;
				rgb_out <= (num_data)?24'h000000:24'hFFFFFF;
			end
			else
				rgb_out <= 24'h000000;
	endcase
end

always@(posedge clk) 
begin
	hs_out	<= hs_in;
	vs_out	<= vs_in;
	de_out	<= de_in;	
end

/*************************************************************************************************/
/*************************************************************************************************/
/********************************** 	              	******************************************/
/********************************** 	 游戏判定逻辑  	******************************************/
/********************************** 	              	******************************************/
/*************************************************************************************************/
/*************************************************************************************************/
reg	[5:0]	score = 6'd0;


reg [5:0]		cube_code;
reg	[8:0]		cube;
reg [3:0]		cube_loc_y = 4'd2;//控制的方块的 下坐标
reg [3:0]		cube_loc_x = 4'd2;//控制的方块的中间坐标
reg 			cube_new = 1'b1;

reg [7:0]		game_ram[11:0];
reg [7:0] 		ram_delay = 0;
reg [3:0]		score_scan = 0;

//计时单元
reg [7:0] vs_cnt;
reg [7:0] time_cnt;
always@(posedge vs_in)
	if(state == 1)begin 
		if ( vs_cnt < 59) begin
			vs_cnt <= vs_cnt + 1;
		end
		else begin
			vs_cnt <= 0;
			time_cnt <=  (ram_state != 9 )? time_cnt + 1 : time_cnt;
		end
	end
	else begin
		vs_cnt <= 0;
		time_cnt <= 0;
	end

//伪随机计算单元
reg [4:0]		cube_new_count = 5'd0;
always@(posedge clk)
	cube_new_count <= (cube_new_count + key_l + key_r + key_sw) % 7;

//方块移动判定单元
always@(posedge clk) 
	case(ram_state)
		4'd0:begin//RAM待机
			if(!rst_n)begin //复位
				game_ram[ 0] <= 8'h00;
				game_ram[ 1] <= 8'h00;
				game_ram[ 2] <= 8'h00;
				game_ram[ 3] <= 8'h00;
				game_ram[ 4] <= 8'h00;
				game_ram[ 5] <= 8'h00;
				game_ram[ 6] <= 8'h00;
				game_ram[ 7] <= 8'h00;
				game_ram[ 8] <= 8'h00;
				game_ram[ 9] <= 8'h00;
				game_ram[10] <= 8'h00;
				game_ram[11] <= 8'h00;

				cube_new 	<= 1'b1;
				score 		<= 6'd0;
			end
			else if(game_ram[3] != 8'h00)//如果触顶
				ram_state	<= 4'd9;
			else if(key_r_reg == 2'b01) // 按键 右移
				ram_state	<= 4'd2;
			else if(key_l_reg == 2'b01) // 按键 左移
				ram_state	<= 4'd3;
			else if(key_s_reg == 2'b01) // 按键 旋转
			begin
				cube_code[1:0] = cube_code[1:0] + 1;
			end
			else if(state && x_in == 16'd1 && y_in == 16'd470)//延时模块 控制方块的快慢
				if(ram_delay >= speed) begin ram_state <= cube_new? 4'b1:4'd7; ram_delay <= 0; end // 生成新块 or 旧块下移
				else ram_delay <= ram_delay + 1;
		end

		4'd1:begin//RAM写入新方块 
			cube_code[4:2]	= cube_new_count;//调用伪随机下一个方块
			
			cube_loc_y 	<= 4'd2;
			cube_loc_x 	<= 4'd3;
			cube_new 	<= 1'b0;
			ram_state	<= 4'd7;
		end

		4'd2:begin//RAM 右移
			if(cube[6] | cube[3] | cube[0])begin//算子有无空列
				if(cube_loc_x == 6) cube_loc_x <= cube_loc_x;
				else cube_loc_x <= cube_loc_x + 1;
			end
			else begin
				if(cube_loc_x == 7) cube_loc_x <= cube_loc_x;
				else cube_loc_x <= cube_loc_x + 1;
			end

			ram_state	<= 4'd0;
		end

		4'd3:begin//RAM 左移
			if(cube[8] | cube[5] | cube[2])begin//算子有无空列
				if(cube_loc_x == 1) cube_loc_x <= cube_loc_x;
				else cube_loc_x <= cube_loc_x - 1;
			end
			else begin
				if(cube_loc_x == 0) cube_loc_x <= cube_loc_x;
				else cube_loc_x <= cube_loc_x - 1;
			end

			ram_state	<= 4'd0;
		end

		4'd7://RAM移动操作，方块正常下落 ram_state <= ram_state + 4'd1;
			//当方块触底
			if(cube_loc_y == 4'd11 ||(game_ram[cube_loc_y - 4'd1][6 - cube_loc_x  +:3] & cube[8:6])||(game_ram[cube_loc_y][6 - cube_loc_x  +:3] & cube[5:3])||(game_ram[cube_loc_y+1][6 - cube_loc_x  +:3] & cube[2:0]))begin
				//将方块写入背景RAM
				game_ram [cube_loc_y - 4'd2 ][6 - cube_loc_x  +:3] <= game_ram [cube_loc_y - 4'd2][6 - cube_loc_x  +:3] | cube[8:6];
				game_ram [cube_loc_y - 4'd1 ][6 - cube_loc_x  +:3] <= game_ram [cube_loc_y - 4'd1][6 - cube_loc_x  +:3] | cube[5:3];
				game_ram [cube_loc_y  		][6 - cube_loc_x  +:3] <= game_ram [cube_loc_y	     ][6 - cube_loc_x  +:3] | cube[2:0];

				//更新方块RAM
				cube_new <= 1'b1;

				//计算分数
				score_scan <= 14;
				ram_state <= 4'd8;
			end
			//当方块没有触底
			else begin
				//背景不变

				//方块下落
				cube_loc_y <= cube_loc_y + 4'd1;
				cube_new <= 1'b0;

				//回去继续待机
				ram_state <= 4'd0;
			end
		
		4'd8://计算分数
			if(score_scan > 4'd2 && cube_new)begin // 方块触底 
				if(cube_loc_y <= 3)  // 方块触顶
					ram_state <= 9;
				else begin
					if(game_ram[score_scan] == 8'hff)begin
						score <= score + 1;

						game_ram[ 0] <= 8'h00;
						game_ram[ 1] <= score_scan> 0? game_ram[ 0] : game_ram[ 1];
						game_ram[ 2] <= score_scan> 1? game_ram[ 1] : game_ram[ 2];
						game_ram[ 3] <= score_scan> 2? game_ram[ 2] : game_ram[ 3];
						game_ram[ 4] <= score_scan> 3? game_ram[ 3] : game_ram[ 4];
						game_ram[ 5] <= score_scan> 4? game_ram[ 4] : game_ram[ 5];
						game_ram[ 6] <= score_scan> 5? game_ram[ 5] : game_ram[ 6];
						game_ram[ 7] <= score_scan> 6? game_ram[ 6] : game_ram[ 7];
						game_ram[ 8] <= score_scan> 7? game_ram[ 7] : game_ram[ 8];
						game_ram[ 9] <= score_scan> 8? game_ram[ 8] : game_ram[ 9];
						game_ram[10] <= score_scan> 9? game_ram[ 9] : game_ram[10];
						game_ram[11] <= score_scan>10? game_ram[10] : game_ram[11];
					end
					else
						score_scan <= score_scan - 1;
				end
			end
			else begin
				score <= score;

				ram_state <= 0;
			end
		
		4'd9://游戏结束，等待复位
			if(!rst_n)
				ram_state <= 4'd0;	

	endcase

//方块编码，四个方向
always@(*)
	case(cube_code)
		5'd0 : cube = 9'h007;//——
		5'd1 : cube = 9'h092;
		5'd2 : cube = 9'h007;
		5'd3 : cube = 9'h092;

		5'd4 : cube = 9'h03A;//T
		5'd5 : cube = 9'h0B2;
		5'd6 : cube = 9'h017;
		5'd7 : cube = 9'h09A;

		5'd8 : cube = 9'h033;//Z
		5'd9 : cube = 9'h05A;
		5'd10: cube = 9'h033;
		5'd11: cube = 9'h05A;

		5'd12: cube = 9'h01E;//S
		5'd13: cube = 9'h099;
		5'd14: cube = 9'h01E;
		5'd15: cube = 9'h099;

		5'd16: cube = 9'h093;//L 
		5'd17: cube = 9'h03C;
		5'd18: cube = 9'h192;
		5'd19: cube = 9'h00F;

		5'd20: cube = 9'h096;//I
		5'd21: cube = 9'h027;
		5'd22: cube = 9'h0D2;
		5'd23: cube = 9'h039;

		5'd24: cube = 9'h01B;//O
		5'd25: cube = 9'h01B;
		5'd26: cube = 9'h01B;
		5'd27: cube = 9'h01B;
	endcase

/*************************************************************************************************/
/*************************************************************************************************/
/********************************** 	              	******************************************/
/********************************** 	 使用到的ROM  	******************************************/
/********************************** 	              	******************************************/
/*************************************************************************************************/
/*************************************************************************************************/

//需要显示的难度文字ROM
level level_m0(
	.clock 		(clk	 	),
	.address	(lev_add 	),
	.q 			(lev_data	)
	);


//需要显示的数字ROM
number number_m0(
	.clock 		(clk	 	),
	.address	(num_add 	),
	.q 			(num_data	)
	);

endmodule 