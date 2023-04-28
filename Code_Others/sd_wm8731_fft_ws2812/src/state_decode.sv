//with a digital display of state_code
// 0:SD card is initializing
// 1:wait for the button to press
// 2:looking for the WAV file
// 3:playing
module state_decode(
    input      [3:0] state_code,
    output     [6:0] HEX0
);

always@*
    case(state_code) // 7段 共阳数码管译码
        'd0: HEX0 <= 7'b1000000;
        'd1: HEX0 <= 7'b1111001;
        'd2: HEX0 <= 7'b0100100;   
        'd3: HEX0 <= 7'b0110000;
        default: HEX0 <= 7'b1111111;
    endcase

endmodule