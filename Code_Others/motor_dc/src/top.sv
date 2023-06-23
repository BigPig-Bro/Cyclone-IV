module top (
    input           clk,
    input           dc_dir,

    output [1:0]    dc_io
);
parameter       CLK_FRE = 50;//FPGA 时钟频率 50MHz
// 速度占空比 范围 0~100%

//dc 占空比控制
wire [7:0]     dc_duty;
dc_ctrl#(
    .CLK_FRE    (CLK_FRE    )
) dc_ctrl_m0(
    .clk        (clk        ),

    .dc_duty  (dc_duty  )
);

//dc PWM信号生成
dc_top#(
    .CLK_FRE    (CLK_FRE    )
) dc_top_m0(
    .clk        (clk        ),
    .dc_dir     (dc_dir     ),
    .dc_duty  (dc_duty  ),

    .dc_io    (dc_io    )
);
endmodule