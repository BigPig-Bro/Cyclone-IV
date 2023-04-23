//模块名  ：mark_fifo
//模块功能：连通域标记，定位
//特殊说明：
//**************************************************************
//存在问题：
//         *****为等价表标记
//修改日志：1：做出基本的标记功能
//         2：通过增加右上角的判断，减少大部分的标记
// 		   3：减少标记时间错位
//         4：实现多方位标记，减少处理难度，						2019年3月23日04:25:38
//         5: 判断连通域方式另一种为直接判断双方标记是否相同，
//			  此处用的是分点的位置，再去调用标记
// 		   6：整理代码，增加注释 									2021年1月13日12:54:27
// 		   7：将2*3算子改为2*2，减少代码量							2021年1月13日12:58:46
//		   8：增加边界判定，防止上下左右边界在fifo内相连判定失误		2021年1月13日13:13:02
// 		   9：将标记数从256-1提到1024-1，避免标记重叠 				2021年1月13日13:47:19
//		  10: 修复了标记位宽和输出位宽不匹配的问题 					2021年1月13日14:17:05
// 		  11: 2*2算子减少了代码量，但增加了数据量，还是改回了2*3    2021年1月13日15:22:46
//			  优化了2*3算子结构，状态分布减少为4个
//		  12：对齐P11和x 坐标，同时调整了其他信号 					2021年1月15日11:36:56
//		  13：减少标记数和代码量 									2021年1月15日15:52:37
// 		  14:调整信号，消除视频右边拉伸效果 						2021年1月15日18:17:18
// 		  15:修复了连通域触及边界消失的bug  						2021年1月15日18:55:12
//		  16：调整输入xy位宽 										2021年1月15日20:02:28
//		  17：调整等价表合并条件，仅限边界触发，内部不触发，方便调试 2021年1月20日20:58:43 //后续可删减，此处方便调试增加
// 		  18：调整注释17，修复因上下标记相同导致面积不增加的bug     2021年1月22日23:44:43
// 		  19：优化标记点状态（新，拓，合，无）  减少资源使用量      2021年1月23日14:56:33
// 		  20：调整注释17，修复右边界和0地址比较的bug 				2021年1月23日15:39:16
// 		  21：修复了调用地址信号位宽问题，它会导致输出无响应		 	2021年1月23日17:43:21
// 		  22：修复了判定点移动导致的无法进入合并					2021年1月23日21:57:01
// 		  23：完成最终版，恢复数据格式								2021年1月23日23:20:33
// 		  24：修复了判定边界问题 									2021年1月24日16:42:29
//		  25：修复了第一行像素标记0，下一行跟进导致像素消失的BUG 	2021年3月15日16:07:02
//		  26:修复右上为空，上有标记式，标记异常继承的情况			2022年4月24日16:07:46
module mark_fifo
#
(
	parameter hmax = 480,						//视频分辨率参数定义
	parameter vmax = 272
)
(
	input      			video_clk	,			//输入  视频像素时钟
	input 				con_clk		,	    	//输入 连通域处理时钟

	input      			data_in		,			//输入 处理视频 像素
	input      			hs_in		,			//输入 处理视频 hs
	input      			vs_in		,			//输入 处理视频 vs
	input      			de_in		,			//输入 处理视频 de
	input [11:0]       	x_in 		,			//输入 处理视频 x坐标
	input [11:0]       	y_in 		,			//输入 处理视频 y坐标

	output reg [9:0] 	data_out	,			//输出 标记后像素
	output   			hs_out		, 			//输出 后 hs
	output   			vs_out		, 			//输出 后 vs
	output   			de_out		,			//输出 后 de

	output [47:0]       loc_out1,loc_out2,loc_out3	//输出 被选择的连通域区域边界
		
);
//********************************视频流和标记缓存***********************************************//	
	//视频流缓存
	linebuffer_Wapper#
	(
		.no_of_lines		(1			),		//原生视频 缓存上一行
		.samples_per_line	(hmax		),		//原生视频 横向分辨率作为fifo深度
		.data_width			(1			)		//原生视频 像素位宽 1
	)
	 linebuffer_Wapper_m0
	 (
		.ce         		(1'b1   	),		//模块选择使能 1 一直有效

		.wr_clk     		(video_clk  ),		//写入 时钟 原生视频 时钟
		.wr_en      		(de_buf[0]  ),		//写入 使能 原生视频 de信号(fifo内已写入x-1，x行)
		.data_in    		(data_in	),		//写入 数据 原生视频 像素
		.wr_rst     		(1'b0   	),		//写入 重置 0 一直无效，不重置

		.rd_clk     		(video_clk  ),		//读取 时钟 原生视频 时钟
		.rd_en      		(de_in   	),		//读取 使能 原生视频 de信号(fifo内读取x-1,x行)
		.data_out   		(p20 		),		//读取 数据 原生视频 像素，p2为上一行
		.rd_rst     		(1'b0   	)		//读取 重置 0 一直无效，不重置
	);
	
	//上一行标记 *标记数不超过1023
	linebuffer_Wapper#
	(
		.no_of_lines		(1			),		//像素标记 只缓存上一行
		.samples_per_line	(hmax		),		//原生视频 横向分辨率作为fifo深度		
		.data_width			(10			)		//像素标记 最大标记数 1023
	)
	 linebuffer_Wapper_m1
	 (
		.ce         		(1'b1   	),		//模块选择使能 1 一直有效

		.wr_clk     		(video_clk  ),		//写入 时钟 原生视频 时钟，随像素一起写入标记
		.wr_en      		(de_buf[3]  ),		//写入 使能 原生视频 de信号延时后
		.data_in    		(data_out	),		//写入 数据 像素标记
		.wr_rst     		(1'b0   	),		//写入 重置 0 一直无效，不重置

		.rd_clk     		(video_clk  ),		//读取 时钟 连通域高速 时钟
		.rd_en      		(de_in   	),		//读取 使能 原生视频 de信号	
		.data_out   		(mark_p20 	),		//读取 数据 上一行标记
		.rd_rst     		(1'b0   	)		//读取 重置 0 一直无效，不重置
	);

//********************************标记运算***********************************************//	
	reg  [9:0]	mark_p21,mark_p22 		; 	//上一个点标记
	wire [9:0]	mark_p20		 		;  	//右上一行相邻两个点标记
	reg  [9:0]	mark_cnt				;	//已有标记计数器

	wire					p20 		;	//算子延迟
	reg       			p10,p11,p21,p12 ; 	//算子延迟
	reg [1:0] 			state 			;	//状态机变量	 0 拓展 1 合并 2 新点  3 啥没有
	
	//创建新起点 面积框合并
	//state含义：0拓展 2合并 3新起点 7无效
	mark_add mark_add_m0(
		.con_clk 	(con_clk 		 ),		//输入 连通域高速时钟

		.mark_1 	(data_out 	     ),		//输入 当前行标记
		.mark_2 	(mark_p22 		 ),		//输入 上一行标记
		.data_state (state 			 ),		//输入 state信号==拓展+合并+新起点
		.data_x 	(x_in			 ),		//输入 连通域数据 x坐标 //见注 16
		.data_y 	(y_in		  	 ), 	//输入 连通域数据 y坐标
		.frame_start(y_in == 0),
		.out_en 	( y_in == vmax-1 && x_in == hmax-1),//输入，到达末尾，发送提取数据信号，这个点可不是乱选的
		.mark_cnt 	(mark_cnt 		 ), 	//输入 当前帧标记数
		.data_out1 	(loc_out1 		 ),		//输出 根据条件筛选出的某个联通域的上下左右边界数据
		.data_out2 	(loc_out2 		 ),		//输出 根据条件筛选出的某个联通域的上下左右边界数据
		.data_out3 	(loc_out3 		 ),		//输出 根据条件筛选出的某个联通域的上下左右边界数据
	);
	
	/////	 p21 			p20			 ///mark同理
	/////p12 p11（处理点） 	p10   data_in//———>运算移动方向
	always@(posedge video_clk)
	begin
		//********像素延迟构成像素算子********//
		p10 	 <= data_in ;	
		p11		 <= p10 ;	
		p12 	 <= p11 & de_buf[2]; //见注：15
		p21 	 <= p20 & y_in != 12'd0; //见注：25

		//********标记延迟构成标记算子********//	
		mark_p21 <= mark_p20;
		mark_p22 <= mark_p21;

		//********运算过程*****************//
		if (y_in == 12'd0)//新的一处理帧开始，数据初始化
		begin
			mark_cnt <= 10'd1;					//标记计数器初始化 1
			data_out <= 10'd0;					//无效数据 输出0
			state 	 <= 2'd3;					//
		end	
		else if( y_in > 12'd4 && x_in >12'd4&& y_in < vmax-4 && x_in < hmax-4 )		//前两行列存在边界相连，不做处理
		begin
			if(p11 & de_out)
			begin//以下为单个像素连续
				if((p20|p21) & !p12)					//与 上或右 连接
				begin
					if(p21)
					data_out <= mark_p21;
					else if(p20)
					data_out <= mark_p20;
					else data_out <= data_out;
					state <= 2'd0;						
				end
				else if(!p21 & p12)				//与 左 连接，标记不变化
				begin
					data_out <= data_out;
					state <= 2'd0;
				end
				else if(p21 & p12) //与 上左 连接，进行合并，标记以左边为准，即不变化
				begin 										     
					data_out <= data_out;
					state <= (mark_p22 == 10'd0 & mark_p21 != 10'd0)?2'd1:2'd0;//新条件设置为边界触发，见注17 注18 注20 注24
				end
				else//(!p12 & !p20 & !p21 )****上 右 左均无连接，则为新的起始点
				begin
					if(mark_cnt != 1023) begin
						data_out <= mark_cnt;
						mark_cnt <= mark_cnt + 16'd1;
						state <= 2'd2;
					end else begin
						data_out <= 0;
						state <= 3;
					end
				end
			end
			else
			begin
				data_out <= 10'd0 	;			//无数据 输出0
				state 	 <= 2'd3 	;			//
			end
		end

		else 									//不做处理的前两列无效边框
		begin
			data_out <= 10'd0;					//无效数据 输出0
			state 	 <= 2'd3;					//
		end
	
	end

//*******************************视频信号延迟************************************************//	
	reg [12:0] hs_buf,vs_buf,de_buf;				//视频信号延迟寄存器

	assign hs_out = hs_buf[2];
	assign vs_out = vs_buf[2];
	assign de_out = de_buf[2];	

	always@(posedge video_clk)
	begin
	   hs_buf <= {hs_buf[11:0], hs_in};
	   vs_buf <= {vs_buf[11:0], vs_in};
	   de_buf <= {de_buf[11:0], de_in};
	end
//*******************************************************************************//	

endmodule 