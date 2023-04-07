/***********************************
	此文件是数码管的显示文件
***************************************/
module tra(
	input clk,//普通时钟信号
	input [7:0] data_in1,data_in2,
	output reg [5:0] sel,
	output reg [7:0] dig);//段选和位选信号
	
	reg [7:0] temp;//扫描间隔计时器
	reg [3:0] cnt;//计数数字
	reg [2:0] count_sel;//位选协助
	reg [9:0] timer;//时间计数
	reg [7:0] sel_r;
		
	always@(posedge clk)//显示模块
	begin
		case(count_sel)
			3'd0:
			begin
				cnt <= data_in1[7:4];
				sel_r<=6'b011111;
			end
			
			3'd1:
			begin
				cnt <= data_in1[3:0];
				sel_r<=6'b101111;
			end
			
			3'd2:
			begin
				//cnt = data_in1[3:0];
				sel_r<=6'b111111;	
			end
			
			3'd3:
			begin
				//cnt = data_in1[3:0];
				sel_r<=6'b111111;	
			end
			
			3'd4:
			begin
				cnt <= data_in2[7:4];
				sel_r<=6'b111101;	
			end
			
			3'd5:
			begin
				cnt <= data_in2[3:0];
				sel_r<=6'b111110;	
			end
			
		endcase

		sel <= sel_r;
	end
	
	always@*
	    case(cnt)//以下为共阳数码管的编码
			4'd0 :dig=8'b1100_0000;
			4'd1 :dig=8'b1111_1001;
			4'd2 :dig=8'b1010_0100;
			4'd3 :dig=8'b1011_0000;
			4'd4 :dig=8'b1001_1001;
			4'd5 :dig=8'b1001_0010;
			4'd6 :dig=8'b1000_0010;
			4'd7 :dig=8'b1111_1000;
			4'd8 :dig=8'b1000_0000;
			4'd9 :dig=8'b1001_0000;
			4'd10:dig=8'b1000_1000;
			4'd11:dig=8'b1000_0011;
			4'd12:dig=8'b1100_0110;
			4'd13:dig=8'b1010_0001;
			4'd14:dig=8'b1000_0110;
			4'd15:dig=8'b1000_1110;
			default:dig=8'b0000_0000;
		endcase

	always@(posedge clk)//扫描模块
		timer = timer + 32'd1;

	always@(posedge timer[5])
		count_sel <= (count_sel == 3'd5)? 3'd0 : count_sel + 3'd1;

endmodule
