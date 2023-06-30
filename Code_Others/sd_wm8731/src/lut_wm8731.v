module lut_wm8731(
	input[9:0]             lut_index, // Look-up table index address
	input[6:0] 					volume,    // Volume control
	output reg[31:0]       lut_data   // I2C device address register address register data
);

always@(*)
begin
	case(lut_index)
	    //To be compatible with the 16bit register address, add 8'h00
		8'd0: lut_data <= {8'h34,8'h00,8'h00,8'h97};          //(Left Line In) = 0x97: left line in mute
		8'd1: lut_data <= {8'h34,8'h00,8'h02,8'h97};          //(Right Line In) = 0x97: right line in mute
		8'd2: lut_data <= {8'h34,8'h00,8'h08,8'h15};          //(analogue audio path control) = 0x15 : MIC select to DAC
		8'd3: lut_data <= {8'h34,8'h00,8'h0a,8'h06};          //(digital Audio path control) = 0x00
		8'd4: lut_data <= {8'h34,8'h00,8'h0c,8'h00};          //(Power down control) = 0x00
		8'd5: lut_data <= {8'h34,8'h00,8'h0e,8'h40};          //(Digital Audio interface format) = 0x40 : right channel DAC when DACLRC low
		8'd6: lut_data <= {8'h34,8'h00,8'h10,8'h00};          //(Sampling control) = 0x00  
		8'd7: lut_data <= {8'h34,8'h00,8'h12,8'h01};          //(Active control) = 0x00  
		8'd8: lut_data <= {8'h34,8'h00,8'h04,1'b0,volume};          //(Left Headphone out) = 0x7f :left headphone +6dB
		8'd9: lut_data <= {8'h34,8'h00,8'h06,1'b0,volume};          //(right Headphone out) = 0x7f :right headphone +6dB
		default:lut_data <= {8'hff,16'hffff,8'hff};
	endcase
end


endmodule 