module uart_top(
	input                        clk,
	input                        rst_n,

	input						 key_update,key_check,
	output		 				 update_led,
	output	reg 				 check_done,

	input						 ram_sel,
	output 	reg					 ram_clk,
	output	reg [255:0] 		 ram_data,
	output	 	[7:0] 		 	 ram_add,

	input                        uart_rx,
	output                       uart_tx
);

parameter                        CLK_FRE = 9;//Mhz

reg[7:0]                         tx_data;
reg                              tx_data_valid;
wire                             tx_data_ready;
reg[7:0]                         tx_cnt;
wire[7:0]                        rx_data;
wire                             rx_data_valid;
wire                             rx_data_ready;
reg[31:0]                        wait_cnt;
reg[3:0]                         state;
reg[9:0] 						 rx_cnt;
reg[8:0] 						 rx_image_loop;
reg[3:0] 						 rx_state;
reg[95:0] 	                     cmd_state   ={8'hEF,8'h01,8'hFF,8'hFF,8'hFF,8'hFF,8'h01,8'h00,8'h03,8'h01,8'h00,8'h05};
//应答格式 EF01 FFFFFFFF 07 03 XX SUM, XX= 00success 01error 02wait 03unsuccess
reg[95:0] 	                     cmd_upimage ={8'hEF,8'h01,8'hFF,8'hFF,8'hFF,8'hFF,8'h01,8'h00,8'h03,8'h0A,8'h00,8'h0E};
//应答格式 EF01 FFFFFFFF 07 03 00 SUM + (EF01 FFFFFFFF 02 00 82 FF*128 SUM ) * 288
reg update_state;

assign rx_data_ready = 1'b1;//always can receive data,
assign ram_add = rx_image_loop[7:0];
assign update_led = update_state;

reg key_update_r,key_check_r;
reg rx_data_valid_r;
reg [7:0] state_data;
always@(posedge clk)begin
	key_check_r <= key_check;
	key_update_r <= key_update;
	rx_data_valid_r <= rx_data_valid;
end


always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		wait_cnt <= 32'd0;
		tx_data <= 8'd0;
		state <= 0;
		tx_cnt <= 8'd0;
		tx_data_valid <= 1'b0;
	end
	else
		case(state)
			4'd0:begin //等待按键触发 update check
				ram_clk <= 0;
				update_state <= 1'b0;

				if (!key_update_r && key_update) begin
					state <= 4'd1;
				end
				else if (!key_check_r &&  key_check) begin
					state <= 4'd1;
				end
			end
	
			/*发送指令， 确定指纹是否录入*/
			4'd1:begin//发送确认指令
				tx_data <= cmd_state[95 - tx_cnt *8 -:8];
	
				if(tx_data_valid == 1'b1 && tx_data_ready == 1'b1 && tx_cnt < 8'd11)//Send 12 bytes data
				begin
					tx_cnt <= tx_cnt + 8'd1; //Send data counter
				end
				else if(tx_data_valid && tx_data_ready)//last byte sent is complete
				begin
					tx_cnt <= 8'd0;
					tx_data_valid <= 1'b0;
					rx_state <= 4'd0;
					rx_cnt <= 10'd0;
	
					state <= 4'd2;
				end
				else if(~tx_data_valid)
				begin
					tx_data_valid <= 1'b1;
				end
			end
	
			4'd2:begin//读取应答包
				case (rx_state)
					4'd0:begin //包头 EF01
						if (!rx_data_valid_r &&   rx_data_valid && rx_cnt < 10'd1) begin
							state_data <= rx_data;
							rx_cnt <= rx_cnt + 1;
						end
						else if (!rx_data_valid_r &&   rx_data_valid &&  rx_cnt == 10'd1) begin
							rx_cnt <= 10'd0;
							rx_state <= rx_state + 1;
						end
					end
	
					4'd1:begin //芯片地址 FFFFFFFF
						if (!rx_data_valid_r &&   rx_data_valid && rx_cnt < 10'd3) begin
							state_data <= rx_data;
							rx_cnt <= rx_cnt + 1;
						end
						else if (!rx_data_valid_r &&   rx_data_valid &&  rx_cnt == 10'd3) begin
							rx_cnt <= 10'd0;
							rx_state <= rx_state + 1;
						end
					end

					4'd2:begin //包标识 07
						if (!rx_data_valid_r &&   rx_data_valid) begin
							state_data <= rx_data;
							rx_state <= rx_state + 1;
						end
					end

					4'd3:begin //包长度 0003
						if (!rx_data_valid_r &&   rx_data_valid && rx_cnt < 10'd1) begin
							state_data <= rx_data;
							rx_cnt <= rx_cnt + 1;
						end
						else if (!rx_data_valid_r &&   rx_data_valid &&  rx_cnt == 10'd1) begin
							rx_cnt <= 10'd0;
							rx_state <= rx_state + 1;
						end
					end

					4'd4:begin //确认码 XX= 00success 01error 02wait 03unsuccess
						if (!rx_data_valid_r &&   rx_data_valid) begin
							update_state <= (rx_data == 8'h00)?1'b1:1'b0;
							rx_state <= rx_state + 1;
						end
					end

					4'd5:begin //校验码 xxxx sum
						if (!rx_data_valid_r &&   rx_data_valid && rx_cnt < 10'd1) begin
							state_data <= rx_data;
							rx_cnt <= rx_cnt + 1;
						end
						else if (!rx_data_valid_r &&   rx_data_valid &&  rx_cnt == 10'd1) begin
							rx_cnt <= 10'd0;
							rx_state <= 0;

							state <= update_state? 4'd4 : 4'd1;
						end
					end
				endcase
			end
	
			/*发送指令， 读取指纹画面*/
			4'd4:begin//发送读取指令
				tx_data <= cmd_upimage[95 - tx_cnt *8 -:8];
	
				if(tx_data_valid == 1'b1 && tx_data_ready == 1'b1 && tx_cnt < 8'd12)//Send 12 bytes data
				begin
					tx_cnt <= tx_cnt + 8'd1; //Send data counter
				end
				else if(tx_data_valid && tx_data_ready)//last byte sent is complete
				begin
					tx_cnt <= 8'd0;
					tx_data_valid <= 1'b0;
					rx_state <= 4'd0;
					rx_cnt <= 10'd0;
					rx_image_loop <= 10'd0;
					update_state <= 1'b1;

	
					state <= 4'd5;
				end
				else if(~tx_data_valid)
				begin
					tx_data_valid <= 1'b1;
				end
			end
	
			4'd5:begin//读取图像数据包 包头
				case (rx_state)
					4'd0:begin //包头 EF01
						if (!rx_data_valid_r &&   rx_data_valid && rx_cnt < 10'd1) begin
							state_data <= rx_data;
							rx_cnt <= rx_cnt + 1;
						end
						else if (!rx_data_valid_r &&   rx_data_valid &&  rx_cnt == 10'd1) begin
							rx_cnt <= 10'd0;
							rx_state <= rx_state + 1;
						end
					end
	
					4'd1:begin //芯片地址 FFFFFFFF
						if (!rx_data_valid_r &&   rx_data_valid && rx_cnt < 10'd3) begin
							state_data <= rx_data;
							rx_cnt <= rx_cnt + 1;
						end
						else if (!rx_data_valid_r &&   rx_data_valid &&  rx_cnt == 10'd3) begin
							rx_cnt <= 10'd0;
							rx_state <= rx_state + 1;
						end
					end

					4'd2:begin //包标识 02
						if (!rx_data_valid_r &&   rx_data_valid) begin
							state_data <= rx_data;
							rx_state <= rx_state + 1;
						end
					end

					4'd3:begin //包长度 0082
						if (!rx_data_valid_r &&   rx_data_valid && rx_cnt < 10'd1) begin
							state_data <= rx_data;
							rx_cnt <= rx_cnt + 1;
						end
						else if (!rx_data_valid_r &&   rx_data_valid &&  rx_cnt == 10'd1) begin
							rx_cnt <= 10'd0;
							rx_state <= rx_state + 1;
						end
					end

					4'd4:begin //确认码
						if (!rx_data_valid_r &&   rx_data_valid) begin
							state_data <= rx_data;
							rx_state <= rx_state + 1;
						end
					end

					4'd5:begin //校验码 xxxx sum
						if (!rx_data_valid_r &&   rx_data_valid && rx_cnt < 10'd1) begin
							state_data <= rx_data;
							rx_cnt <= rx_cnt + 1;
						end
						else if (!rx_data_valid_r &&   rx_data_valid &&  rx_cnt == 10'd1) begin
							rx_cnt <= 10'd0;
							rx_state <= 4'D0;

							rx_image_loop <= 0;
							state <= state +  4'd1;
						end
					end
				endcase
			end 

			4'd6:begin//读取图像数据包 数据
				case (rx_state)
					4'd0:begin //包头 EF01
						if (!rx_data_valid_r &&   rx_data_valid && rx_cnt < 10'd1) begin
							state_data <= rx_data;
							rx_cnt <= rx_cnt + 1;
						end
						else if (!rx_data_valid_r &&   rx_data_valid &&  rx_cnt == 10'd1) begin
							rx_cnt <= 10'd0;
							rx_state <= rx_state + 1;
						end
					end
	
					4'd1:begin //芯片地址 FFFFFFFF
						if (!rx_data_valid_r &&   rx_data_valid && rx_cnt < 10'd3) begin
							state_data <= rx_data;
							rx_cnt <= rx_cnt + 1;
						end
						else if (!rx_data_valid_r &&   rx_data_valid &&  rx_cnt == 10'd3) begin
							rx_cnt <= 10'd0;
							rx_state <= rx_state + 1;
						end
					end

					4'd2:begin //包标识 07
						if (!rx_data_valid_r &&   rx_data_valid) begin
							state_data <= rx_data;
							rx_state <= rx_state + 1;
						end
					end

					4'd3:begin //包长度 0082
						if (!rx_data_valid_r &&   rx_data_valid && rx_cnt < 10'd1) begin
							state_data <= rx_data;
							rx_cnt <= rx_cnt + 1;
						end
						else if (!rx_data_valid_r &&   rx_data_valid &&  rx_cnt == 10'd1) begin
							rx_cnt <= 10'd0;
							ram_clk <= 1'b0;

							rx_state <= rx_state + 1;
						end
					end

					4'd4:begin //数据 （4+4） * 128
						if (!rx_data_valid_r &&   rx_data_valid && rx_cnt < 10'd254) begin
							ram_data[rx_cnt  	 ] <= (rx_data[7:4] >= 4'd3)?1'b0:1'b1;
							ram_data[rx_cnt + 1  ] <= (rx_data[3:0] >= 4'd3)?1'b0:1'b1;
							rx_cnt <= rx_cnt + 2;
						end
						else if (!rx_data_valid_r &&   rx_data_valid &&  rx_cnt == 10'd254) begin
							rx_cnt <= 10'd0;
							ram_clk <= 1'b1;
							check_done <= (ram_sel & rx_image_loop == 10'd255)? 1'b1 :1'b0;

							rx_state <= rx_state + 1;
						end
					end

					4'd5:begin //校验码 000A sum
						if (!rx_data_valid_r &&   rx_data_valid && rx_cnt < 10'd1) begin
							state_data <= rx_data;
							rx_cnt <= rx_cnt + 1;
						end
						else if (!rx_data_valid_r &&   rx_data_valid &&  rx_cnt == 10'd1) begin
							rx_cnt <= 10'd0;
							rx_state <= 4'D0;
							rx_image_loop <= rx_image_loop + 1;

							update_state <= (rx_image_loop == 10'd255)? 0 : 1;
							check_done <= (ram_sel & rx_image_loop == 10'd255)? 1'b1 :1'b0;
							state <= (rx_image_loop == 10'd255)? 4'd0 : state;
						end
					end
				endcase
			end 

			default:
				state <= 4'd0;
		endcase
end


uart_rx#
(
	.CLK_FRE(CLK_FRE),
	.BAUD_RATE(57600)
) uart_rx_inst
(
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.rx_data                    (rx_data                  ),
	.rx_data_valid              (rx_data_valid            ),
	.rx_data_ready              (rx_data_ready            ),
	.rx_pin                     (uart_rx                  )
);

uart_tx#
(
	.CLK_FRE(CLK_FRE),
	.BAUD_RATE(57600)
) uart_tx_inst
(
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.tx_data                    (tx_data                  ),
	.tx_data_valid              (tx_data_valid            ),
	.tx_data_ready              (tx_data_ready            ),
	.tx_pin                     (uart_tx                  )
);
endmodule