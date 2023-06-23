module sg90_top#(
    parameter       CLK_FRE = 50
)(
    input               clk,
    input       [7:0]  sg90_duty,

    output reg          sg90_io
);

parameter TIME_20MS     = 20_000 * CLK_FRE - 1; // 20ms
parameter TIME_2MS      = 2_000 * CLK_FRE - 1; // 2.0ms 位置宽度
parameter TIME_0_5MS    = 500 * CLK_FRE - 1; // 0.5ms 固定起始宽度

reg [23:0] cnt_duty;
reg [23:0] cnt_20ms;

always @(posedge clk) begin
    if (cnt_20ms >= TIME_20MS) begin
        cnt_20ms <= 0;
        cnt_duty <= TIME_0_5MS + TIME_2MS * sg90_duty / 100;
    end 
    else begin
        cnt_20ms <= cnt_20ms + 1;
        if (cnt_20ms < cnt_duty) 
            sg90_io <= 1;
        else 
            sg90_io <= 0;
        
    end
end

endmodule