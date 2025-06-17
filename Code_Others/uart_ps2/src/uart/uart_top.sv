module uart_top #(
    parameter CLK_FRE         = 50,
    parameter UART_RATE       = 115200,
    parameter SEND_FRE        = 1
    )(
    input         i_sys_clk,    //系统时钟
    input         i_rst_n,     //系统复位

	input         i_PS2_data_valid,   //PS2手柄数据有效标志
	input  [15:0] i_PS2_key,          //PS2手柄按键值
	input  [ 7:0] i_PS2_RX,           //PS2手柄右摇杆X轴值
	input  [ 7:0] i_PS2_RY,           //PS2手柄右摇杆Y轴值
	input  [ 7:0] i_PS2_LX,           //PS2手柄左摇杆X轴值
	input  [ 7:0] i_PS2_LY,           //PS2手柄左摇杆Y轴值
	input  [ 7:0] i_PS2_ID,           //PS2手柄ID
    
    input         i_uart_rx,
    output        o_uart_tx
);

typedef enum logic [1:0] {IDLE, SEND, LOOP}STATE_TOP;
STATE_TOP state;

logic [31:0] wait_cnt;
logic [ 7:0] send_cnt;
logic [ 7:0] send_data;
logic        send_en;
logic        send_busy;

logic [ 7:0] recv_data;
logic        recv_en;

//发送寄存器
parameter     ENG_NUM  = 52;//非中文字符数
parameter     CHE_NUM  = 0;//  中文字符数
parameter     DATA_NUM = CHE_NUM * 3 + ENG_NUM; //中文字符使用UTF8，占用3个字节
logic [ DATA_NUM * 8 - 1:0] char_data = {"ID:000 KEY:0000_0000_0000_0000 R:000 000 L:000 000","\r\n"};
logic [ DATA_NUM * 8 - 1:0] char_data_r;

//字符数据寄存器
always@(posedge i_sys_clk)begin
	//\R \N
	char_data_r[  0 * 8 +: 8] <= char_data[  0 * 8 +: 8];
	char_data_r[  1 * 8 +: 8] <= char_data[  1 * 8 +: 8];

	// L:000 000
	char_data_r[  2 * 8 +: 8] <= char_data[  2 * 8 +: 8] + i_PS2_LY % 'd10;
	char_data_r[  3 * 8 +: 8] <= char_data[  3 * 8 +: 8] + i_PS2_LY % 'd100 / 'd10;
	char_data_r[  4 * 8 +: 8] <= char_data[  4 * 8 +: 8] + i_PS2_LY / 'd100;
	char_data_r[  5 * 8 +: 8] <= char_data[  5 * 8 +: 8];//" "
	char_data_r[  6 * 8 +: 8] <= char_data[  6 * 8 +: 8] + i_PS2_LX % 'd10;
	char_data_r[  7 * 8 +: 8] <= char_data[  7 * 8 +: 8] + i_PS2_LX % 'd100 / 'd10;
	char_data_r[  8 * 8 +: 8] <= char_data[  8 * 8 +: 8] + i_PS2_LX / 'd100;
	char_data_r[  9 * 8 +: 8] <= char_data[  9 * 8 +: 8];//":"
	char_data_r[ 10 * 8 +: 8] <= char_data[ 10 * 8 +: 8];//"L"
	char_data_r[ 11 * 8 +: 8] <= char_data[ 11 * 8 +: 8];//" "

	// R:000 000
	char_data_r[ 12 * 8 +: 8] <= char_data[ 12 * 8 +: 8] + i_PS2_RY % 'd10;
	char_data_r[ 13 * 8 +: 8] <= char_data[ 13 * 8 +: 8] + i_PS2_RY % 'd100 / 'd10;
	char_data_r[ 14 * 8 +: 8] <= char_data[ 14 * 8 +: 8] + i_PS2_RY / 'd100;
	char_data_r[ 15 * 8 +: 8] <= char_data[ 15 * 8 +: 8];//" "
	char_data_r[ 16 * 8 +: 8] <= char_data[ 16 * 8 +: 8] + i_PS2_RX % 'd10;
	char_data_r[ 17 * 8 +: 8] <= char_data[ 17 * 8 +: 8] + i_PS2_RX % 'd100 / 'd10;
	char_data_r[ 18 * 8 +: 8] <= char_data[ 18 * 8 +: 8] + i_PS2_RX / 'd100;
	char_data_r[ 19 * 8 +: 8] <= char_data[ 19 * 8 +: 8];//":"
	char_data_r[ 20 * 8 +: 8] <= char_data[ 20 * 8 +: 8];//"R"
	char_data_r[ 21 * 8 +: 8] <= char_data[ 21 * 8 +: 8];//" "

	// KEY:0000_0000_0000_0000
	char_data_r[ 22 * 8 +: 8] <= char_data[ 22 * 8 +: 8] + i_PS2_key[15];
	char_data_r[ 23 * 8 +: 8] <= char_data[ 23 * 8 +: 8] + i_PS2_key[14];
	char_data_r[ 24 * 8 +: 8] <= char_data[ 24 * 8 +: 8] + i_PS2_key[13];
	char_data_r[ 25 * 8 +: 8] <= char_data[ 25 * 8 +: 8] + i_PS2_key[12];
	char_data_r[ 26 * 8 +: 8] <= char_data[ 26 * 8 +: 8];//"_"
	char_data_r[ 27 * 8 +: 8] <= char_data[ 27 * 8 +: 8] + i_PS2_key[11];
	char_data_r[ 28 * 8 +: 8] <= char_data[ 28 * 8 +: 8] + i_PS2_key[10];
	char_data_r[ 29 * 8 +: 8] <= char_data[ 29 * 8 +: 8] + i_PS2_key[ 9];
	char_data_r[ 30 * 8 +: 8] <= char_data[ 30 * 8 +: 8] + i_PS2_key[ 8];
	char_data_r[ 31 * 8 +: 8] <= char_data[ 31 * 8 +: 8];//"_"
	char_data_r[ 32 * 8 +: 8] <= char_data[ 32 * 8 +: 8] + i_PS2_key[ 7];
	char_data_r[ 33 * 8 +: 8] <= char_data[ 33 * 8 +: 8] + i_PS2_key[ 6];
	char_data_r[ 34 * 8 +: 8] <= char_data[ 34 * 8 +: 8] + i_PS2_key[ 5];
	char_data_r[ 35 * 8 +: 8] <= char_data[ 35 * 8 +: 8] + i_PS2_key[ 4];
	char_data_r[ 36 * 8 +: 8] <= char_data[ 36 * 8 +: 8];//"_"
	char_data_r[ 37 * 8 +: 8] <= char_data[ 37 * 8 +: 8] + i_PS2_key[ 3];
	char_data_r[ 38 * 8 +: 8] <= char_data[ 38 * 8 +: 8] + i_PS2_key[ 2];
	char_data_r[ 39 * 8 +: 8] <= char_data[ 39 * 8 +: 8] + i_PS2_key[ 1];
	char_data_r[ 40 * 8 +: 8] <= char_data[ 40 * 8 +: 8] + i_PS2_key[ 0];
	char_data_r[ 41 * 8 +: 8] <= char_data[ 41 * 8 +: 8];//":"
	char_data_r[ 42 * 8 +: 8] <= char_data[ 42 * 8 +: 8];//"Y"
	char_data_r[ 43 * 8 +: 8] <= char_data[ 43 * 8 +: 8];//"E"
	char_data_r[ 44 * 8 +: 8] <= char_data[ 44 * 8 +: 8];//"K"
	char_data_r[ 45 * 8 +: 8] <= char_data[ 45 * 8 +: 8];//" "

	// ID:000
	char_data_r[ 46 * 8 +: 8] <= char_data[ 46 * 8 +: 8] + i_PS2_ID % 'd10;
	char_data_r[ 47 * 8 +: 8] <= char_data[ 47 * 8 +: 8] + i_PS2_ID % 'd100 / 'd10;
	char_data_r[ 48 * 8 +: 8] <= char_data[ 48 * 8 +: 8] + i_PS2_ID / 'd100;
	char_data_r[ 49 * 8 +: 8] <= char_data[ 49 * 8 +: 8];//":"
	char_data_r[ 50 * 8 +: 8] <= char_data[ 50 * 8 +: 8];//"I"
	char_data_r[ 51 * 8 +: 8] <= char_data[ 51 * 8 +: 8];//"D"
end

//仲裁机制
always@(posedge i_sys_clk)begin
    if(!i_rst_n)begin
        wait_cnt    <= 'd0;
        send_cnt    <= 'd0;
        send_en     <= 'b0;
        send_data   <= 'b0;

        state       <= IDLE;
    end else begin
        case(state)
            IDLE: // 空闲状态
                if(wait_cnt >= CLK_FRE * 1000_000 / SEND_FRE && i_PS2_data_valid)begin 
                   wait_cnt    <= 'd0;

                   state       <= SEND;
                end else begin
                    wait_cnt    <= (wait_cnt >= CLK_FRE * 1000_000 / SEND_FRE ) ? wait_cnt : wait_cnt + 'd1;
                end

            SEND:begin // 主动发送
                if(send_cnt >= DATA_NUM + 1)begin 
                    send_en     <= 'b0;
                    send_cnt    <= 'd0;

                    state       <= IDLE;
                end
                else if(!send_busy)begin
                    send_en     <= 'b1;
                    send_data   <= char_data_r[ (DATA_NUM - 1 - send_cnt) * 8 +: 8];
                    send_cnt    <= send_cnt + 'd1;
                end
            end

            default:begin // 默认状态
                state       <= IDLE;
            end
        endcase
    end
end

//发送模块
uart_tx #(
    .CLK_FRE            (CLK_FRE           ),
    .UART_RATE          (UART_RATE         )
)uart_tx_m0(
    .i_sys_clk          (i_sys_clk         ),
    .i_rst_n            (i_rst_n           ),

    .i_send_en          (send_en           ),
    .o_send_busy        (send_busy         ),
    .i_send_data        (send_data         ),

    .o_tx_pin           (o_uart_tx         )
);

//接收模块
uart_rx #(
    .CLK_FRE            (CLK_FRE            ),
    .UART_RATE          (UART_RATE          )
)uart_rx_m0(
    .i_sys_clk          (i_sys_clk          ),
    .i_rst_n            (i_rst_n            ),

    .o_recv_en          (recv_en            ),
    .o_recv_data        (recv_data          ),

    .i_rx_pin           (i_uart_rx          )
);

endmodule