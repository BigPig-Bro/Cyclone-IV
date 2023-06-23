module sg90_ctrl#(
    parameter CLK_FRE  = 50
)(
    input            clk,

    output reg [7:0] sg90_duty
);

parameter TIME_20MS = 20_000 * CLK_FRE - 1; // 20ms
reg [23:0]  cnt_20ms;
reg         duty_dir;

always @(posedge clk) 
    if (cnt_20ms == TIME_20MS) begin
        cnt_20ms <= 0;
        duty_dir <= sg90_duty == 1 ? 1 : sg90_duty == 99 ? 0 : duty_dir;
        sg90_duty <= duty_dir? sg90_duty + 1 : sg90_duty - 1;
    end 
    else begin
        cnt_20ms <= cnt_20ms + 1;
    end
endmodule