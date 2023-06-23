module dc_top#(
    parameter       CLK_FRE = 50
)(
    input               clk,
    input               dc_dir,
    input       [7:0]  dc_duty,

    output reg [1:0]   dc_io
);

parameter TIME_20MS     = 20_000 * CLK_FRE - 1; // 20ms

reg [23:0] cnt_duty;
reg [23:0] cnt_20ms;

always @(posedge clk) begin
    if (cnt_20ms >= TIME_20MS) begin
        cnt_20ms <= 0;
        cnt_duty <= TIME_20MS * dc_duty / 100;
    end 
    else begin
        cnt_20ms <= cnt_20ms + 1;
        if (cnt_20ms < cnt_duty) 
            dc_io <= dc_dir? 2'b10 : 2'b01;
        else 
            dc_io <= 2'b00;
        
    end
end

endmodule