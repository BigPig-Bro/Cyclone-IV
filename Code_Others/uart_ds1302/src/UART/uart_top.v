module uart_top#(
	parameter                   CLK_FRE 	= 50,//Mhz
	parameter					BAUD_RATE = 115200
	)(
	input                        clk,
	input                        rst_n,
	input [7:0] 				 sec_data,
	input                        uart_rx,
	output                       uart_tx
);

localparam                       IDLE =  0;
localparam                       SEND =  1;   //send HELLO ALINX\r\n
localparam                       WAIT =  2;   //wait 1 second and send uart received data
reg[7:0]                         tx_data;
reg[7:0]                         tx_str;
reg                              tx_data_valid;
wire                             tx_data_ready;
reg[7:0]                         tx_cnt;
wire[7:0]                        rx_data;
wire                             rx_data_valid;
wire                             rx_data_ready;
reg[31:0]                        wait_cnt;
reg[3:0]                         state;

assign rx_data_ready = 1'b1;//always can receive data,
							//if HELLO ALINX\r\n is being sent, the received data is discarded

always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		wait_cnt <= 32'd0;
		tx_data <= 8'd0;
		state <= IDLE;
		tx_cnt <= 8'd0;
		tx_data_valid <= 1'b0;
	end
	else
	case(state)
		IDLE:
			state <= SEND;
		SEND:
		begin
			wait_cnt <= 32'd0;
			tx_data <= tx_str;

			if(tx_data_valid == 1'b1 && tx_data_ready == 1'b1 && tx_cnt < DATA_NUM - 1)//Send 12 bytes data
			begin
				tx_cnt <= tx_cnt + 8'd1; //Send data counter
			end
			else if(tx_data_valid && tx_data_ready)//last byte sent is complete
			begin
				tx_cnt <= 8'd0;
				tx_data_valid <= 1'b0;
				state <= WAIT;
			end
			else if(~tx_data_valid)
			begin
				tx_data_valid <= 1'b1;
			end
		end
		WAIT:
		begin
			wait_cnt <= wait_cnt + 32'd1;

			if(wait_cnt >= CLK_FRE * 1000000) // wait for 1 second
				state <= SEND;
		end
		default:
			state <= IDLE;
	endcase
end 

//combinational logic
parameter 	ENG_NUM  = 11;//非中文字符数
parameter 	CHE_NUM  = 4;//  中文字符数
parameter 	DATA_NUM = CHE_NUM * 3 + ENG_NUM; //中文字符使用UTF8，占用3个字节
wire [ DATA_NUM * 8 - 1:0] send_data = {"DS1302的秒数是: 00\n"};
always@(*)
	case(tx_cnt)
		20:tx_str <= send_data[(DATA_NUM - 1 - tx_cnt) * 8 +: 8] + sec_data[7:4];
		21:tx_str <= send_data[(DATA_NUM - 1 - tx_cnt) * 8 +: 8] + sec_data[3:0];
		default:tx_str <= send_data[(DATA_NUM - 1 - tx_cnt) * 8 +: 8];
	endcase

uart_tx#
(
	.CLK_FRE(CLK_FRE),
	.BAUD_RATE(BAUD_RATE)
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