module display (
	input 				video_clk,search_clk,    // Clock
	input				rst_n,
	
	input [9:0] 		x_in,
	input [9:0] 		y_in,

	input				test_done,
	//显示的图像数据
	output 	   [7:0] 	video_ram_add,
	input [255:0] 		video_ram_data1,
	input [255:0]		video_ram_test,
	//搜索匹配的图像数据
	input [255:0] 		search_ram_data1,search_ram_test_data,
	output[8:0] 		search_ram_test_add,search_ram_add,

	output reg[7:0]     max_false,max_right,
	output test_video,test_fp,

	output reg [7:0] 	rgb_out 	
);

parameter		RIGHT_THES 		= 16'd0; //  匹配点 在 30% 以上 (fp有 test 有)
parameter		FALSE_THES_PRE 	= 16'd100;//非匹配点 在 100% 以下 (fp有 test 无 fp无 test有) ,
parameter		FALSE_THES 	 	= FALSE_THES_PRE * 5 / 4;//  宏定义为实际值的四分之五大小

reg [17:0] right_cnt,right_full;
reg [31:0] false_cnt;
reg [7:0]  right_percnt,false_percnt;
reg [ 3:0] state = 0;

assign test_video = search_ram_data1    [win_x + search_x];
assign test_fp	  = search_ram_test_data[63    + search_x];

assign	video_ram_add = y_in[7:0];

reg t_r;
always@(posedge video_clk) t_r <= test_done;

//显示 测试图像
always@(posedge video_clk) begin
	case (state)
		4'd0: begin //正常显示 fp1 fp2
			if(x_in < 10'd240)begin // 左半边显示第一个指纹 二值
				rgb_out <= (video_ram_data1[x_in] & y_in < 255)?8'hff:0;
			end
			else if(x_in == 240) rgb_out <= 8'hff;
			else begin // 右半边显示 匹配 二值化图像
				if(x_in - 240 > 64 & x_in - 240 < 64 + 128 & y_in > 64 & y_in < 64 + 128)
					rgb_out <= (video_ram_test[x_in] & y_in < 255)?8'hff:0;
				else
					rgb_out <= (video_ram_test[x_in] & y_in < 255)?8'h20:0;
			end

			if (test_done & !t_r) begin
				state <= state + 1;
			end
		end

		4'd1:begin //128 * 128 卷积
			if(x_in < 10'd240)begin // 左半边显示第一个指纹 二值
				if(x_in > win_x & x_in  < win_x + 128 & y_in > win_y & y_in < win_y + 128)
					rgb_out <= (video_ram_data1[x_in] & y_in < 255)?8'hff:0;
				else 
					rgb_out <= (video_ram_data1[x_in] & y_in < 255)?8'H20:0;
			end
			else if(x_in == 240) rgb_out <= 8'hff;
			else begin // 右半边显示 匹配 二值化图像
				if(x_in - 240 > 64 & x_in - 240 < 64 + 128 & y_in > 64 & y_in < 64 + 128)
					rgb_out <= (video_ram_test[x_in] & y_in < 255)?8'hff:0;
				else
					rgb_out <= (video_ram_test[x_in] & y_in < 255)?8'h20:0;
			end


			//状态转移判断
			if (win_y == 9'd127) begin
				state <= state + 1;
			end
		end

		4'd2:begin//显示结果
			if(x_in < 10'd240)begin // 左半边显示第一个指纹 二值
				if (!max_en)	rgb_out <= (video_ram_data1[x_in] & y_in < 255)?8'hff:0;
				else if (x_in >= max_x && x_in <= max_x + 127 && y_in >= max_y && y_in <= max_y + 127 && max_en) begin
					rgb_out <=  (video_ram_data1[x_in] & y_in < 255)?8'hfF:0;
				end
				else 
					rgb_out <= (video_ram_data1[x_in] & y_in < 255)?8'h0f:0;
			end
			else if(x_in == 240) rgb_out <= 8'hff;
			else begin // 右半边显示 匹配 二值化图像
				if(x_in - 240 > 64 & x_in - 240 < 64 + 128 & y_in > 64 & y_in < 64 + 128)
					rgb_out <= (video_ram_test[x_in] & y_in < 255)?8'hff:0;
				else
					rgb_out <= (video_ram_test[x_in] & y_in < 255)?8'h20:0;
			end

			if (!rst_n) begin
				state <= 0;
			end
		end

	endcase
end

//快速匹配 算法
// 搜索范围 = win_x + win_y (左上点) ——> (win_x + search_x) + (win_y + search_y) (右下点) 
reg [3:0] search_state; //匹配状态机
reg [8:0] search_x,search_y; // x: 需要匹配的128个行内点 在 返回的 256 行点的匹配起点，y: 窗口坐标 + y = 范围
reg [8:0] win_x,win_y; //搜索窗口 128 * 128 在 256 * 288 中 左上点的坐标
//最高匹配度及其坐标
// reg [15:0] max_right,max_false;
reg [7:0]  max_x,max_y;
reg  	   max_en;

assign search_ram_add = win_y + search_y;
assign search_ram_test_add = 63 + search_y;

always@(posedge search_clk)
	case (search_state)
		4'd0:begin	//等待测试图像输入
			if (test_done & !t_r) begin
				//起始坐标归零
				win_x <= 0;
				win_y <= 0;
				search_x <= 0;
				search_y <= 0;
				// max_right <= 10;
				max_false <= 200;
				max_en <= 0;

				//统计 归零
				right_full <= 0;
				false_cnt <= 0;
				right_cnt <= 0;

				search_state <= search_state + 1;
			end
		end

		4'd1:begin //快速匹配 横向窗口数据
			//数据统计
			if (search_x <= 9'd127) begin
				// if 	   (search_ram_data1[win_x + search_x] & search_ram_test_data[128 + win_x] ) right_cnt <= right_cnt + 1; //fp1 有 test 有
				if( (!search_ram_data1[win_x + search_x] &&  search_ram_test_data[63 + search_x]) || 
				(     search_ram_data1[win_x + search_x] && !search_ram_test_data[63 + search_x]) ) false_cnt <= false_cnt + 1; //fp1 有 test 无 fp1 无 test 有 
				// if(search_ram_data1[win_x + search_x]) right_full <= right_full + 1;
			end

			//地址卷积递增
			search_x <= search_x + 1;

			//状态跳转
			if (false_percnt[0] >= FALSE_THES && false_percnt[1] >= FALSE_THES ) begin
				search_state <= search_state + 1;//非匹配点太多了，直接跳到下一个匹配
			end
			else if (search_x == 9'd127) begin // 横向搜索完成
				search_state <= search_state + 1;
			end
		end

		4'd2:begin//纵向卷积叠加 search_x y 
			if (search_y == 9'd128) begin // 128*128 搜索 128*128次后正常退出 (纵向搜索完成)
				search_x <= 0;
				search_y <= 0;

				search_state <= search_state + 1;
			end
			else begin
				if (search_x == 9'd128) begin
					search_x <= 0;
					search_y <= search_y + 1;
				end
				else search_x <= search_x + 1;

				search_state <= 4'd1;
			end
		end

		4'd3:begin //计算百分比
			// right_percnt <= right_cnt * 16'd100 / right_full; 
			false_percnt <= false_cnt[31:7]; //(false_cnt * 32'd100) >> 14;

			// right_full <= 0;
			// right_cnt <= 0;
			false_cnt <= 0;

			search_state <= search_state + 1;
		end

		4'd4: search_state <= search_state + 1;

		4'd5:begin//比较 当前卷积值 与 过往取最大值& false_percnt < FALSE_THES
			// 计算最优值
			if(false_percnt <= max_false ) begin
				// max_right <= right_percnt ;
				max_false <= false_percnt ;
				max_x <= win_x;
				max_y <= win_y;
				max_en <= 1;
			end
			else max_x <= max_x;

 			// 卷积完成 状态转移
			if (win_y == 9'd127 && win_x == 9'd127) begin
				search_state <= 0;
			end
			else begin
				if (win_x == 9'd127) begin
					win_x <= 0;
					win_y <= win_y + 1;
				end
				else win_x <= win_x + 1;

				search_state <= 4'd1;
			end
		end

	endcase

endmodule