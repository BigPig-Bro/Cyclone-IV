module ad7606_top #(
	parameter CLK_FRE = 50,  //SCLK 不低于24ns，即CLK_FRE不高于80.6MHz,这里用两个时钟去读
	parameter ADC_FRE = 1000 //采样频率,避免小数运算
)(
	input 					clk, 			
	input 					rst_n, 

	//软件
	input 					ad7606_start, 	
	output 	reg				ad7606_done = 0,	
	output 	reg	[7:0][15:0] ad7606_data,

	//硬件接口
	output 					ad7606_range,
	output 	reg				ad7606_convstA = 1, ad7606_convstB=1,
	input 		[15:0]		ad7606_db,		
	output 	reg				ad7606_cs_n = 1,	
	output 	reg				ad7606_rd_n = 1,	
	input 					ad7606_busy,	
	output 		[2:0]		ad7606_os,		
	output 	reg				ad7606_rst		
);

//固定信号
reg ad7606_convst;
assign ad7606_range 	= 0;//1:±10V,0:±5V
assign ad7606_os 		= 3'd0; // 0~7：2^0~2^7次采样取平均
assign ad7606_convstA 	= ad7606_convst;//AB控制各4个通道，A通道为0~3，B通道为4~7
assign ad7606_convstB 	= ad7606_convst;

//读写状态机控制
reg [31:0] fre_delay = 0;
reg [ 3:0] state = 0;
reg [31:0] state_delay;
reg [ 3:0] rec_cnt = 0;

always@(posedge clk)
	if(!rst_n)begin
		ad7606_rst 		<= 'B1;
		rec_cnt 		<= 'd0;
		ad7606_convst 	<= 'B1;
		ad7606_cs_n 	<= 'B1;
		ad7606_rd_n 	<= 'B1;

		state <= 0;
	end
	else 
		case(state)
			4'd0:begin //复位信号 10us t rst > 50ns
				ad7606_rst <= (fre_delay >= CLK_FRE * 1000 & fre_delay <= CLK_FRE * 5000)? 'B1 : 'B0;

				if(fre_delay > CLK_FRE * 1000_000)begin
					fre_delay 		<= 0;
					state 			<= state + 1;
				end
				else begin
					fre_delay 	<= fre_delay + 1;
				end
			end

			4'd1:begin //等待start信号
				ad7606_convst 	<= 1;
				ad7606_cs_n 	<= 1;
				ad7606_rd_n 	<= 1;

				if(ad7606_start) begin
					rec_cnt 		<= 0;	
					ad7606_done		<= 0;

					fre_delay 		<= 0;
					state 			<= state + 1;
				end
			end

			4'd2: begin //拉低转换信号 1us?(无根据)
				fre_delay <= fre_delay + 1;
 				if(fre_delay >= CLK_FRE)begin
					ad7606_convst 	<= 1;
					state <= state + 1;
				end
				else
					ad7606_convst 	<= 0;
			end

			4'd3:begin //等待BUSY拉高，ADC开始工作
				fre_delay <= fre_delay + 1;
				if(ad7606_busy)	
					state <= state + 1;
			end

			4'd4:begin //等待BUSY拉低，ADC工作结束
				fre_delay <= fre_delay + 1;
				if(!ad7606_busy)
					state <= state + 1;
			end

			4'd5:begin //拉低片选CS,操作器件
				fre_delay <= fre_delay + 1;
				
				ad7606_cs_n <= 0;

				state <= state + 1;
			end

			4'd6:begin //拉低RD ,开始读取数据
				fre_delay <= fre_delay + 1;
				ad7606_rd_n <= 0;

				state <= state + 1;
			end

			4'd7:begin //延时，避免输入时钟过高达不到24ns(3.3v min)
				fre_delay <= fre_delay + 1;
				ad7606_rd_n <= 0;

				state <= state + 1;
			end

			4'd8:begin //上升沿读取数据
				fre_delay <= fre_delay + 1;
				ad7606_rd_n 			<= 'd1;
				ad7606_data[rec_cnt] 	<= ad7606_db;
				rec_cnt 				<= rec_cnt + 1;

				ad7606_cs_n 			<= (rec_cnt == 'd7)?'d1 : 'd0;
				state 					<= (rec_cnt == 'd7)?'d9 : 'd6;
			end
			
			4'd9: //延时以匹配采样频率
				if(fre_delay < CLK_FRE * 1_000_000 / ADC_FRE - 1)
					fre_delay <= fre_delay + 1;
				else
					state <= 1;

		endcase
endmodule