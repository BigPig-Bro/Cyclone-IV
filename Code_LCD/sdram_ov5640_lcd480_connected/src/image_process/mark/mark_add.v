//模块名   mark_add
//模块功能 ：合成窗选框
//特殊说明 ：
//      	  由于地址与标记挂钩，所以0地址没有用上
//**************************************************************
//存在问题：
//         数据未完成读取，可以改进读取的逻辑
//         可以完成收拢的多阶连通域，不可合拢后被覆盖的连通域继续向外延伸，见备注文件
//修改日志：1：实现合成功能                                                                  	2019年3月24日02:42:30
//         2:调整时序，增加多阶连通域面积框识别                                               	2019年3月26日11:58:30
//         3：调整面积框扩大时序，实现一阶连通域的识别                                         	2019年3月26日23:28:38
//         4：调整时钟，减少误差                                                             	2019年3月27日16:19:28
//         5: 发现问题，合并连通域的时候地址调用有误
//         6: 解决5的问题，合成后右边界会出问题，正在调整连通域右边界的识别                      	2019年3月30日16:35:22
//            减少调用地址时序
//            增加面积框输出时序（需要后期加入具体取出具体哪个面积框，可以用有效点来统计）        	2019年3月30日17:15:51
//            测试X,V,L形连通域                                                             	2019年3月30日22:46:48
//         7：发现问题，如果在忙碌中发送过来合并连通域的信号导致没有办法处理                     	2019年3月31日10:37:40
//            已通过后续的点连接解决，无法解决7的问题，所以如果两个连通域之间只有一两个像素点相连，很有可能漏掉
//            L形测试通过                                                                 	2019年3月31日11:16:39
//            X形测试通过                                                                 	2019年3月31日11:27:31
//            V形测试通过                                                                 	2019年3月31日11:27:41
//         8: 优化连通域代码，解决了目标边界操作时导致的地址为0，改为新的地址改变，为0不变        	2019年3月31日16:03:32
//      ***   添加注释，优化代码，被注释掉的状态机不敢删，万一出了问题再加回去                   	2019年3月31日16:20:23
//         9: 加入对面积数量的技术，但是由于时钟加倍了很多，导致面积的数值也会加大很多,存储周期为
//      ***   两个时钟，放大的时钟倍数为3倍，所以面积应该增加了1.5倍                           	2019年3月31日20:52:35
//         10: 发现面积叠加问题，测试X,V,L形面积叠加中                                       	2019年3月31日23:56:35
// 		   11：整理代码，减少代码量 															2021年1月13日18:58:39
//		   12：增加位宽，最大标记数256->1024	   												2021年1月15日20:01:25
// 		   13：继续整理代码，进一步减少代码量（250+-->220+) 									2021年1月16日11:00:33
// 		   14：优化坐标比较，节省了部分资源消耗量 1380-->1344 									2021年1月16日14:26:39
//  	   15: 减少代码量（220+-->170+），将两个RAM合二为一 									2021年1月20日15:22:20
//		   16：调整代码顺序，全部改为非阻塞，方便调试(170+->150+) 								2021年1月21日14:22:49
//         17:调整代码结构，使3倍PLL改为2倍PLL                                                2021年1月21日15:16:12
// 		   18：修复了最右边一个像素未计入的BUG 												2021年1月23日14:47:30
// 		   19：去除we2，地址2只用于读取比较，不写入 											2021年1月23日14:51:45
// 		   20：修复了最终地址可能找不到，指向0的bug 										  	2021年1月23日17:25:54
//		   21：修复了连通域跨左右边界时面积选择问题 											2021年1月23日20:51:21
// 		   22：完成最终版修订，代码150+->120+													2021年1月23日23:09:02
// 		   23：调整状态机优先级，避免因为还在写入，错过了输出面积框 								2021年1月24日17:20:46
// 		   24: 合并后只清空面积，防止二次合并导致与(0,0)合并									2022年4月24日16:07:46
module mark_add(
	input               con_clk			,         //输入 采样时钟，2倍时钟！！！

	input [ 1:0]        data_state		,      	  //输入 数据状态信号==指示面积框合成替代信号，面积框扩大信号
	input [ 9:0]        mark_1,mark_2	,         //输入 操作的地址1和地址2---标记即地址
	input [11:0]        data_x,data_y	,         //输入 操作对应的XY坐标值
	input 				out_en 			, 		  //输入 提取数据信号
	input [ 9:0]		mark_cnt		, 		  //输入 当前帧标记数
	input 				frame_start,
	output [47:0]   data_out1, data_out2,data_out3 //输出 被选中的坐标框的边界坐标值
);	
	reg [ 2:0]          state 				;               //总状态机
	wire[ 9:0]          ram_add1,ram_add2 	;               //采集瞬间的地址 （避免过程中突变）
	reg                 ram_wren1			;               //地址写入使能，保护数据
	//以下为连接面积框像素点数量RAM的定义	格式{18 面积，12 上，12 下，12 左，12 右}
	reg  [65:0]          ram_in1 			;          		//写入地址的数据寄存器
	wire [65:0]          ram_in2 			;          		//写入地址的数据寄存器
	wire [65:0]          ram_out1,ram_out2	;         		//RAM返回数据
    
	assign ram_in2 = {18'b0,ram_in1[47:0]};

    //以下为筛选条件变量定义   	
	reg [47:0]           out_data[2:0];
	reg [9:0] 			 out_add;
	reg [1:0]			 out_cnt;

	reg [9:0]			out_data_addr[2:0] /*synthesis noprune*/;
	reg ram_wren2;
	assign data_out1 = out_data[0];
	assign data_out2 = out_data[1];
	assign data_out3 = out_data[2];
	
	//以下为连接数据寄存器和RAM
	assign ram_add1     = (state == 3'd6 || out_en)?         out_add : mark_1 ;//采集当前标记（地址）,但提取信号时，选取特定地址
	assign ram_add2 	= mark_2 ;							 //解决了*日志8*中所描述的问题，避免了地址指向0的问题 //已在例化中解决0地址问题


	
	always@(posedge con_clk)
	begin
	 ram_wren2 <= 1'b0;	
		case(state)
			3'd0://等待写入使能和视频流结束
			begin//***********************//输出面积框***********************************************
				if(out_en) //注23
				begin
					state <= 3'd6	;		//跳转到指定状态机
					out_add <= mark_cnt - 10'd1;
					out_cnt <= 2'd0;
					out_data[0] <= 0;
					out_data[1] <= 0;
					out_data[2] <= 0;
					out_data_addr[0] <= 0;
					out_data_addr[1] <= 0;
					out_data_addr[2] <= 0;
					ram_wren1 <= 1'b0;
				end
				//*********************//两个标记合并*******************
				else if(data_state == 2'd1) begin 
					state    	<= 3'd3;//跳转到面积框合并的程序中
					ram_wren1 <= 1'b0;
				//**********************//新的起点***************				
				end else if(data_state == 2'd2)
				begin
					ram_in1 	<= {18'd1,data_y,data_y,data_x,data_x}; //新建点-面积数据 起始 1-框边界
					if(data_y !=0 && data_x != 0) ram_wren1   <= 1'b1;//打开使能
					else 
					ram_wren1 <= 1'b0;
					state   	<= 3'd5;//跳转到写入的状态机
				end//*******************//面积框的拓展*****************
				else if(data_state == 2'd0)begin
					state 		<= 3'd1;//跳转到面积框拓展的状态机
					ram_wren1 <= 1'b0;
				 end 
				 else//***************************************************************
					ram_wren1   <= 1'b0;//关闭使能，保护数据

				ram_wren2 <= 1'b0;	
			end
			//***************//拓展面积框*************************************************************************			
			3'd1:
			begin
				//if(ram_out1[65:48] != 18'b0&& ram_out1[23:12] != 12'b0&& ram_out1[47:36] != 12'b0) begin
					ram_wren1   <= 1'b1;						//打开地址1 写入使能
					
					if(ram_out1[11:0] >= data_x )				//右 边界判定
						ram_in1[11:0] <= ram_out1[11:0];
					else
						ram_in1[11:0] <= data_x;

					if(ram_out1[23:12] <= data_x)				//左 边界判定
						ram_in1[23:12] <= ram_out1[23:12];
					else
						ram_in1[23:12] <= data_x;
					
					ram_in1[35:24] <= data_y;					//下 新点一定在连通域外面，根据扫描方向向下扩展，故上边界不动，下边界拓展
					ram_in1[47:36] <= ram_out1[47:36];			//上 新点一定在连通域外面，根据扫描方向向下扩展，故上边界不动，下边界拓展
					// if(ram_out1[65:48])
						ram_in1[65:48] <= ram_out1[65:48] + 18'd1;  //面积计数+1
					// else
					// 	ram_in1[65:48] <= 18'd0;  

				// end
				// else begin
				// 	ram_wren1 <= 1'b0;
				// end 
				
				state <= 3'd0;
			end
			//**************//两个标记合并*************************************************************************	
			3'd3://比较两个寄存器中的上下左右后存入
			begin
				//if(ram_out2 != 66'b0 && ram_out2[23:12] != 12'b0 && ram_out2[47:36] != 12'b0) begin

					ram_wren1   <= 1'b1;						//打开地址1 写入使能


					if(ram_out1[11:0] >= ram_out2[11:0])		//右边界判定
						ram_in1[11:0] <= ram_out1[11:0];
					else
						ram_in1[11:0] <= ram_out2[11:0];

					if(ram_out1[23:12] <= ram_out2[23:12])		//左边界判定
						ram_in1[23:12] <= ram_out1[23:12];
					else 
						ram_in1[23:12] <= ram_out2[23:12];
					

					ram_in1[35:24] <= ram_out1[35:24];			//下 因连通域以左边延伸，故下边界一定是 地址1更“下”

					if(ram_out1[47:36] <= ram_out2[47:36])		//上 边界判定
						ram_in1[47:36] <= ram_out1[47:36];
					else 
						ram_in1[47:36] <= ram_out2[47:36];
					if( ram_out1[65:48] != 18'b0) begin
						ram_wren2 <= 1'b1;
						ram_in1[65:48] <= ram_out1[65:48] + ram_out2[65:48] + 18'd1;//面积计数合并
					end
					else begin
						ram_in1[65:48] <= 18'b0;
						ram_wren2 <= 1'b0;
					end
				//end else begin
				//	ram_wren1 <= 1'b0;
				//end
				
				state       <= 3'd0; 
			end
			//**************//写入新的面积点，空状态机，无意义，仅示意***********************************************
			3'd5:

				state <= 3'd0;
			//***************//输出指定面积框**********************************************************************
			3'd6://输出指定面积框
			begin
				if(out_cnt == 2'd3 || out_add == 10'd0)
				 	state    <= 3'd0;
				else if(ram_out1[65:48] > 18'd500)
				begin
					out_data[out_cnt] <= ram_out1[47:0];
					out_data_addr[out_cnt] <= out_add;
					out_cnt <= out_cnt + 2'd1;
				end

				out_add <= out_add - 10'd1;
			end
			
			default:state <= 3'd0;
		endcase
	end
	
	//面积像素点数量的储存 //框边界数据的储存 双端口RAM 深度1024 宽度68
	mark_ram mark_ram_m0(
		.clock       (con_clk       ), 	//输入 视频双倍时钟
		.aclr		 (frame_start	),
		.data_a 	 (ram_in1  		),	//输入 写入的数据
		.address_a	 (ram_add1		),	//输入 操作地址 1
		.q_a		 (ram_out1      ),  //输出 地址1对应数据
		.wren_a		 (ram_wren1     ),
		
		.data_b      (ram_in2		),  //只需要一个数据写入，第二个仅做读取数据对比 无数据
		.address_b   (ram_add2  	),  //输入 操作地址2 仅读取
		.q_b         (ram_out2      ),  //输出 地址2对应数据
		.wren_b		 (ram_wren2 	) 	// 只需要一个数据写入，第二个仅做读取数据对比，使能关闭
	);
	
endmodule 