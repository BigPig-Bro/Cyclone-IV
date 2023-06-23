module top (
    input           clk,

    output         sg90_io
);
parameter       CLK_FRE = 50;//FPGA 时钟频率 50MHz
// 角度占空比 范围 0~100%

//SG90 占空比控制
wire [7:0]     sg90_duty;
sg90_ctrl#(
    .CLK_FRE    (CLK_FRE    )
) sg90_ctrl_m0(
    .clk        (clk        ),

    .sg90_duty  (sg90_duty  )
);

//SG90 PWM信号生成
sg90_top#(
    .CLK_FRE    (CLK_FRE    )
) sg90_top_m0(
    .clk        (clk        ),
    .sg90_duty  (sg90_duty  ),

    .sg90_io    (sg90_io    )
);
endmodule