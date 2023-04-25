module thres_scan(
	input 		 		clk, 			
	input 		[ 9:0]	loc_x, 			
	input 		[ 9:0]	loc_y,		
	input				thres_data,thres_de,

	output 	reg		  scan_en,//条形码识别 1:识别到 0:未识别到
	output reg 	[12:0][3:0]	scan_data // 13 * 6
	);

parameter BAR_LOC_Y1 = 10'D80; //识别位置 1
parameter BAR_LOC_Y2 = 10'D100; //识别位置 2
parameter BAR_LOC_Y3 = 10'D130; //识别位置 3

reg [ 9:0] bar_left,bar_right; //阈值区域宽度 94位的像素位宽
reg [ 9:0] bar_step ; // 半个条形码的宽度，用于识别采样点
reg [94:0] bar_data; //条形码数据 94位的数据
reg [ 7:0] bar_data_cnt; //条形码数据计数器
reg [ 6:0] bar_bit_witdh; 

reg  [1:0]		scan_state; //条形码识别状态机

always@(posedge clk)

/********************************************************************************/
/********************           输出数据             **************************/
/********************************************************************************/
    if(scan_en && (loc_x >= 10'd1 && loc_x <= 10'd12) &&  loc_y == 10'd1 )begin//输出识别结果
		scan_data[0] <= 9;// 前置码
		bar_data_cnt <= 8'd0;
		
		case(loc_x) // 前置码决定AB交替顺序
			'd1,'d4,'d6,'d8,'d9,'d11:scan_data[loc_x] <= bar_codeA;
			'd2,'d3,'d5,'d7,'d10,'d12:scan_data[loc_x] <= bar_codeB;
		endcase
	end
	else if(loc_x == 'd1 && loc_y =='d2 ) scan_en <= 0;
/********************************************************************************/
/********************           三次扫描            **************************/
/********************************************************************************/
	else if (!scan_en && loc_x == 'd1 && (loc_y == BAR_LOC_Y1 + 3 || loc_y == BAR_LOC_Y2 + 3|| loc_y == BAR_LOC_Y3 + 3))begin
		scan_en  		<= bar_data_cnt == 94; //判断扫描的结果是否为94位
	end
	else if((loc_y == BAR_LOC_Y1 || loc_y == BAR_LOC_Y2 || loc_y == BAR_LOC_Y3))begin//复位数据
		bar_left 		<= 'd1023;
		bar_right		<= 'd0;
		bar_data_cnt 	<= 'd0;
		bar_bit_witdh 	<= 'd0;
		scan_state 		<= 'd0;
		bar_data 		<= 'd0;
	end
	else if(loc_y == BAR_LOC_Y1+1 ||loc_y == BAR_LOC_Y2+1 ||loc_y == BAR_LOC_Y3+1 )begin//读取条形码宽度
		if(thres_data)begin
			if(loc_x < bar_left)begin
				bar_left <= loc_x;
			end
			if(loc_x > bar_right)begin
				bar_right <= loc_x;
			end
		end
	end
	else if(!scan_en && (loc_y == BAR_LOC_Y1 + 2 || loc_y == BAR_LOC_Y2 + 2 || loc_y == BAR_LOC_Y3 + 2 ))begin//读取条形码数据
		bar_step <= (bar_right - bar_left) / 94;//计算每个比特步进

		if(bar_right > bar_left + 100 && loc_x >= bar_left - 1  && loc_x <= bar_right)begin 
			case(scan_state)
				'd0:begin //等待数据
					if(thres_data)begin
						bar_bit_witdh <= bar_bit_witdh + 1;
						scan_state <= 1;
					end
				end

				'd1:begin //识别连续的1
					if(thres_data)
						bar_bit_witdh <= bar_bit_witdh + 1;
					else begin
						if(bar_bit_witdh >= bar_step * 7 / 2 )begin //1111
							bar_data[bar_data_cnt] <= 1;
							bar_data[bar_data_cnt+1] <= 1;
							bar_data[bar_data_cnt+2] <= 1;
							bar_data[bar_data_cnt+3] <= 1;
							
							bar_data_cnt <= bar_data_cnt + 4;
						end
						else if(bar_bit_witdh >= bar_step * 5 / 2 )begin //111
							bar_data[bar_data_cnt] <= 1;
							bar_data[bar_data_cnt+1] <= 1;
							bar_data[bar_data_cnt+2] <= 1;
							
							bar_data_cnt <= bar_data_cnt + 3;
						end
						else if(bar_bit_witdh >= bar_step * 3 / 2) begin //11
							bar_data[bar_data_cnt] <= 1;
							bar_data[bar_data_cnt+1] <= 1;

							bar_data_cnt <= bar_data_cnt + 2;
						end
						else begin //if(bar_bit_witdh >= bar_step * 1 / 2) //1
							bar_data[bar_data_cnt] <= 1;

							bar_data_cnt <= bar_data_cnt + 1;
						end

						bar_bit_witdh <= 0;
						scan_state <= 2;
					end
				end

				'd2:begin //识别连续的0
					if(!thres_data)
						bar_bit_witdh <= bar_bit_witdh + 1;
					else begin
						if(bar_bit_witdh > bar_step * 7 / 2)begin //0000
							bar_data[bar_data_cnt] <= 0;
							bar_data[bar_data_cnt+1] <= 0;
							bar_data[bar_data_cnt+2] <= 0;
							bar_data[bar_data_cnt+3] <= 0;

							bar_data_cnt <= bar_data_cnt + 4;
						end
						else if(bar_bit_witdh > bar_step * 5 / 2)begin //000
							bar_data[bar_data_cnt] <= 0;
							bar_data[bar_data_cnt+1] <= 0;
							bar_data[bar_data_cnt+2] <= 0;

							bar_data_cnt <= bar_data_cnt + 3;
						end
						else if(bar_bit_witdh > bar_step * 3 / 2) begin //00
							bar_data[bar_data_cnt] <= 0;
							bar_data[bar_data_cnt+1] <= 0;

							bar_data_cnt <= bar_data_cnt + 2;
						end
						else begin //if(bar_bit_witdh > bar_step * 1 / 2) //0
							bar_data[bar_data_cnt] <= 0;

							bar_data_cnt <= bar_data_cnt + 1;
						end

						bar_bit_witdh <= 0;
						scan_state <= 1;
					end
				end
			endcase
		end
	end

	else begin
		bar_left <= bar_left;
		bar_right <= bar_right;
		bar_data  <= bar_data  ;
	end

/************************************************/
/**************   条形码编码  ******************/
/************************************************/
wire [6:0] dec_data; // 7位的条形码编码数据
always@* 
	case(loc_x)//以下分配和前置码相关
		'd1 : dec_data = bar_data[ 9: 3];
		'd2 : dec_data = bar_data[16:10];
		'd3 : dec_data = bar_data[23:17];
		'd4 : dec_data = bar_data[30:24];
		'd5 : dec_data = bar_data[37:31];
		'd6 : dec_data = bar_data[44:38];

		'd7 : dec_data = {bar_data[50],bar_data[51],bar_data[52],bar_data[53],bar_data[54],bar_data[55],bar_data[56]};
		'd8 : dec_data = ~bar_data[63:57];
		'd9 : dec_data = ~bar_data[70:64];
		'd10: dec_data = {bar_data[71],bar_data[72],bar_data[73],bar_data[74],bar_data[75],bar_data[76],bar_data[77]};
		'd11: dec_data = ~bar_data[84:78];
		'd12: dec_data = {bar_data[85],bar_data[86],bar_data[87],bar_data[88],bar_data[89],bar_data[90],bar_data[91]};
		default: dec_data = 7'b0000000;
	endcase

reg  [3:0] bar_codeA,bar_codeB; // 4位的条形码解码数据
always@* begin
	case({dec_data[0],dec_data[1],dec_data[2],dec_data[3],dec_data[4],dec_data[5],dec_data[6]})
		7'b0001101: bar_codeA = 4'D0;
		7'b0011001: bar_codeA = 4'd1;
		7'b0010011: bar_codeA = 4'D2;
		7'b0111101: bar_codeA = 4'D3;
		7'b0100011: bar_codeA = 4'D4;
		7'b0110001: bar_codeA = 4'D5;
		7'b0101111: bar_codeA = 4'D6;
		7'b0111011: bar_codeA = 4'D7;
		7'b0110111: bar_codeA = 4'D8;
		7'b0001011: bar_codeA = 4'D9;
		default: bar_codeA = 4'b0000;
	endcase

	case(dec_data)
		7'b1110010: bar_codeB = 4'D0;
		7'b1100110: bar_codeB = 4'd1;
		7'b1101100: bar_codeB = 4'D2;
		7'b1000010: bar_codeB = 4'D3;
		7'b1011100: bar_codeB = 4'D4;
		7'b1001110: bar_codeB = 4'D5;
		7'b1010000: bar_codeB = 4'D6;
		7'b1000100: bar_codeB = 4'D7;
		7'b1001000: bar_codeB = 4'D8;
		7'b1110100: bar_codeB = 4'D9;
		default: bar_codeB = 4'b0000;
	endcase
end
endmodule
