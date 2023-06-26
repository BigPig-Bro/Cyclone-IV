module beep_driver #(
	parameter CLK_FRE = 50 //时钟频率 Mhz
)( 
	input 		clk,//输入的时钟

	input 		start,//开始信号
	output reg  done,//输出的结束信号
	input [3:0] high,long,level,//音高 音长 音符

	output reg  beep);//输出的蜂鸣器信号和结束信号

reg [31:0] timer,counter;//音符发声的振动周期 和 发声的音长
reg [3:0] state = 0;//状态机
reg [7:0] mic;//音高+音符

/******************************************************/
/****************** 将输入时钟降为1Mhz  *****************/
/******************************************************/
reg [15:0] clk_1Mhz_cnt;//降频计数器
always@(posedge clk)
	if(clk_1Mhz_cnt == CLK_FRE - 1)
		clk_1Mhz_cnt <= 32'd0;
	else 
		clk_1Mhz_cnt <= clk_1Mhz_cnt + 1;

/******************************************************/
/******************** 控制电平翻转  *******************/
/******************************************************/
always@(posedge clk)
	case(state)
		4'd0://等待开始信号
			if(start)//判断开始信号
			begin
				state <= state + 4'd1;//状态机加一
				mic <= high + level * 8'd10;//确定音符振动周期
				done <= 1'b0;//将结束信号拉低
			end
			else
				done <= 1'b1;//结束信号拉高，表示空闲状态
		
		4'd1://发声振动部分
		if((counter < (32'd1_000_000  / long)) & timer != 32'd0)//在音长内且不为空闲音符0
			if(counter %  timer == 32'd0 & clk_1Mhz_cnt == 0)//每个发声半周期取反一次，形成这个声音的波
				beep <= ~beep;
			else
				beep <= beep;
		else if(!timer)//如果是空闲0音符
		begin
			beep <= beep;//蜂鸣器不振动，也就是不发声
			if(counter == (32'd1_000_000 / long))begin//到达音长后
				state <= 4'd0;//返回等待开始信号
				done <= 1'b1;//结束信号拉高
			end
			else
				state <= state;//在发声音长内，状态机不变
		end
		else begin
			state <= 4'd0;//返回等待开始信号
			done <= 1'b1;//结束信号拉高
		end
		
		default: state <= 4'd0;//防止卡死
	endcase
	
/******************************************************/
/******************** 时间计数器-降频  *******************/
/******************************************************/
always@(posedge clk)
	if((counter <= (32'd1_000_000 / long)) & !done)//在音长内以及结束信号无效
		counter <= clk_1Mhz_cnt == 0 ? counter + 32'd1 : counter;
	else
		counter <= 32'd1;

/******************************************************/
/******************** 音符半周期表  *******************/
/******************************************************/
always@(*)
	case(mic)
		8'd0:timer = 32'd0;//空闲音符
		//低音区
		8'd1:timer = 32'd1908;//1
		8'd2:timer = 32'd1700;//2
		8'd3:timer = 32'd1516;//3
		8'd4:timer = 32'd1433;//4
		8'd5:timer = 32'd1276;//5
		8'd6:timer = 32'd1136;//6
		8'd7:timer = 32'd1012;//7
		//中音区
		8'd11:timer = 32'd956;//1
		8'd12:timer = 32'd842;//2
		8'd13:timer = 32'd759;//3
		8'd14:timer = 32'd716;//4
		8'd15:timer = 32'd638;//5
		8'd16:timer = 32'd568;//6
		8'd17:timer = 32'd506;//7
		//高音区
		8'd21:timer = 32'd478;//1
		8'd22:timer = 32'd426;//2
		8'd23:timer = 32'd372;//3
		8'd24:timer = 32'd358;//4
		8'd25:timer = 32'd319;//5
		8'd26:timer = 32'd284;//6
		8'd27:timer = 32'd253;//7
		
		default:timer = 32'd0;//防止卡死
	endcase
endmodule 