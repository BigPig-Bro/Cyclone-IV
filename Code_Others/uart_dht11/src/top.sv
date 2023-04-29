module top (
    input               clk,

    //DHT11 IO
    inout               dht11_io,

    //阈值使能
    output               thres_en,

    //串口 IO
    input               uart_rx,
    output              uart_tx
);

parameter CLK_FRE       = 50; //50MHz
parameter UART_RATE 	= 9600; //波特率

//==========================  读取DHT11数据 ==================================
wire [23:0] dht11_data;//[23:8] 温度 整数 小数 BCD码 [7:0]:湿度 整数 BCD码
dht11 #(
    .CLK_FRE    (CLK_FRE        )
)dht11_m0(
    .clk        (clk            ),

    .dht11_io   (dht11_io       ),
    .data_rec   (dht11_data     )
);

//==========================  串口收发数据 ==================================
uart_top#(
    .CLK_FRE    (CLK_FRE        ),
    .UART_RATE  (UART_RATE      )
)uart_top_m0(
    .clk        (clk            ),

    .dht11_data (dht11_data     ),
    .thres_en   (thres_en       ),

    .uart_rx    (uart_rx        ),
    .uart_tx    (uart_tx        )
);


endmodule