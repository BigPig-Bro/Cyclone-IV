module top(
	input 			clk_50M,
	output reg 		seg_clk,
	output reg 		seg_cs,
	output reg 		seg_din
	);
//MAX7219最大时钟频率 10M，此处仿照单片机程序降到了100K左右，实际生成的seg_clk更低一点，能用就行
reg [7:0]	clk_div = 0;
wire 		clk_100K;
assign      clk_100K = clk_div[7];
always@(posedge clk_50M)
	clk_div <= clk_div + 8'd1;

reg [31:0]	clk_delay = 16'd0;
reg [4:0]	send_cnt = 0;
reg [7:0] 	send_data= 0;
reg [1:0] 	state = 2'd0; //总状态机
reg [4:0]	write_cnt= 0;

parameter 	SEG_ADDR	= 104'h090a0b0c0f_0102030405060708;
parameter	SEG_DATA	= 104'hff03070100_0102030405060708;

always@(posedge clk_100K)
	case(state)
		2'd0:begin//随便延时了一点点再发数据
			seg_cs 		<= 1'b1;
			seg_clk		<= 1'b1;
			seg_din		<= 1'b1;

			if(clk_delay == 32'd100_000)begin//随便做个延时
				state <= state + 2'b1;
				clk_delay <= 32'd0;
			end
			else
				clk_delay <= clk_delay + 32'd1;
		end

		2'd1:begin //读取数据，发送到7219
			seg_cs <= 1'b0;
			send_data <= write_cnt[0]?SEG_DATA[((13-write_cnt[4:1])*8 - 1)-:8]:SEG_ADDR[((13-write_cnt[4:1])*8 - 1)-:8];
			state <= state + 5'd1;
			//write_cnt <= write_cnt + 4'd1;
		end

		2'd2:begin
			send_cnt <= send_cnt + 5'd1;
			seg_clk  <= send_cnt[0];
			seg_din  <= send_cnt[0]?seg_din:send_data[7-send_cnt[3:1]];

			if( send_cnt[3:0]==4'd15)
				if(write_cnt == 5'd9) begin
					// seg_cs 	  <= 1'b1;
					write_cnt <= write_cnt + 5'd1;
					state <= 2'd0;	
				end
				else if(write_cnt == 5'd25) begin
					write_cnt 	<= 5'd0;
					state <= 2'd0;	
				end
				else 
					state <= state + 2'd1;
		end

		2'd3:begin
			write_cnt <= write_cnt + 5'd1;
			seg_cs 	  <= write_cnt[0];
			state  <= 2'd1;
		end 
	endcase
endmodule 

module seg_top(																//顶层模块定义
	input 				clk		,											//输入端口时钟定义
	
	output reg [5:0]	sel		,											//输出端口数码管位选定义
	output reg [7:0]  dig													//输出端口数码管段选定义
);
////*****************************************************************************************************////
reg [15:0] clk_count	;														//输入时钟降频计数器，思考为什么降频													//降频后的时钟

reg [2 :0] sel_count	;														//位选计数器
reg [3 :0] seg_data	;														//段选寄存器


parameter 		CLK_FRE  = 32'd50_000_000 ;							//定义输入的时钟频率为50M，类似于本地变量
parameter		SEG_FRE	= 32'd600		  ;							//定义降频后的数码管时钟，思考过大或者过小会有什么影响
parameter 		TEST_NUM = 32'd123456	  ;							//定义要显示的数字
 
initial clk_count 	= 16'd0		;										//初始化计数器归零
initial sel_count 	= 3'd0		;										//初始化计数器归零
////*****************************************************************************************************////
always@(posedge clk_count[15])													//循环体1 位选和段选数据输出，以seg_clk为变化时钟
begin
	sel_count <= sel_count + 3'd1;								//位选计数器 + 1
	
	case(sel_count)															//选择语句，根据括号内变量的值决定执行哪一条
		3'd0:
		begin
			sel 		 <= 6'b011111;											//输出位选信号，思考为什么是011111，位数和01分别有什么意义
			seg_data  <= TEST_NUM % 32'd10;								//得到显示数据的个位
		end
		
		3'd1:
		begin
			sel 		 <= 6'b101111;											//输出位选信号
			seg_data  <= TEST_NUM % 32'd100 / 32'd10;					//得到显示数据的十位
		end
		
		3'd2:
		begin
			sel_count <= sel_count + 'd1;								//位选计数器 + 1
			sel 		 <= 6'b110111;											//输出位选信号
			seg_data  <= TEST_NUM % 32'd1000 / 32'd100;			   //得到显示数据的百位
		end
		
		3'd3:
		begin
			sel 		 <= 6'b111011;											//输出位选信号
			seg_data  <= TEST_NUM % 32'd10000 / 32'd1000;			//得到显示数据的千位
		end
		
		3'd4:
		begin
			sel 		 <= 6'b111101;											//输出位选信号
			seg_data  <= TEST_NUM % 32'd100000 / 32'd10000;			//得到显示数据的万位
		end
		
		3'd5:
		begin
			sel 		 <= 6'b111110;											//输出位选信号
			seg_data  <= TEST_NUM % 32'd1000000 / 32'd100000;		//得到显示数据的十万位
		end
	endcase
end

////*****************************************************************************************************////
always@(posedge clk)															//循环体 2 降频，以clk为变化时钟
	clk_count <= clk_count + 16'd1;

////*****************************************************************************************************////
always@(*)																		//组合逻辑 1，为共阳极数码管段选编码，思考共阴共阳编码区别以及为什么？
begin
	case(seg_data)																//选择语句，根据括号内变量的值决定执行哪一条
		4'd0:dig<=8'b1100_0000;												//共阳 数字 0 编码
		4'd1:dig<=8'b1111_1001;												//共阳 数字 1 编码
		4'd2:dig<=8'b1010_0100;												//共阳 数字 2 编码
		4'd3:dig<=8'b1011_0000;												//共阳 数字 3 编码
		4'd4:dig<=8'b1001_1001;												//共阳 数字 4 编码
		4'd5:dig<=8'b1001_0010;												//共阳 数字 5 编码
		4'd6:dig<=8'b1000_0010;												//共阳 数字 6 编码
		4'd7:dig<=8'b1111_1000;												//共阳 数字 7 编码
		4'd8:dig<=8'b1000_0000;												//共阳 数字 8 编码
		4'd9:dig<=8'b1001_0000;												//共阳 数字 9 编码
		default:dig<=8'b0000_0000;											//默认全亮
	endcase
end
////*****************************************************************************************************////
endmodule 