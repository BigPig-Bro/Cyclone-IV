module ycbcr2rgb (
  input           clk,
  input   [ 7:0]  in_y,
  input   [ 7:0]  in_cb,
  input   [ 7:0]  in_cr,

  output  [ 7:0]  out_r,
  output  [ 7:0]  out_g,
  output  [ 7:0]  out_b
);

  //---------------------------------------------------------------------------
  // Equations for YCbCr to RGB
  //
  // R = 1.164(Y-16) + 1.596(Cr-128)
  // G = 1.164(Y-16) - 0.813(Cr-128) - 0.392(Cb-128)
  // B = 1.164(Y-16) + 1.017(Cb-128) + (Cb-128)
  //
  // The fractional multipliers are converted to 8-bit binary fractions with an
  // implied binary point between bits 7 and 6. Multiplying by the inputs gives
  // a 16 bit result with an implied binary point between bits 7 and 6. The
  // results of the multiplications are added/subtracted, together with the
  // constant terms giving a signed 18 bit result. The integer part of the
  // result is selected, truncating the two lsbs as we want a 6 bit output. A
  // negative result is replaced by zero. Anything greater than 63 is set to
  // 63.
  //---------------------------------------------------------------------------
//  
//  wire [15:0] mul1 = y * 8'b10010101;	// Y*1.164
//  wire [15:0] mul2 = cr * 8'b11001100;	// Cr*1.596
//  wire [15:0] mul3 = cr * 8'b01101000;	// Cr*0.813
//  wire [15:0] mul4 = cb * 8'b00110010;	// Cb*0.392
//  wire [15:0] mul5 = cb * 8'b10000010;	// Cb*1.017
  
  wire [15:0] mul1;	// Y*1.164
  wire [15:0] mul2;	// Cr*1.596
  wire [15:0] mul3;	// Cr*0.813
  wire [15:0] mul4;	// Cb*0.392
  wire [15:0] mul5;	// Cb*1.017

  mult6x6 mult1 (
		     .clock	( clk ),
		     .dataa	( in_y ),
		     .datab	( 8'b10010101 ),
		     
		     .result( mul1 )
		     );		     	  
  mult6x6 mult2 (
		     .clock	( clk ),
		     .dataa	( in_cr ),
		     .datab	( 8'b11001100 ),
		     
		     .result( mul2 )
		     );
  mult6x6 mult3 (
		     .clock	( clk ),
		     .dataa	( in_cr ),
		     .datab	( 8'b01101000 ),
		     
		     .result( mul3 )
		     );
  mult6x6 mult4 (
		     .clock	( clk ),
		     .dataa	( in_cb ),
		     .datab	( 8'b00110010 ),
		     
		     .result( mul4 )
		     );		     
  mult6x6 mult5 (
		     .clock	( clk ),
		     .dataa	( in_cb ),
		     .datab	( 8'b10000010 ),
		     
		     .result( mul5 )
		     );		     
		     
  wire [17:0] red 	= (mul1 + mul2) - {10'd222, 7'b0};//
  wire [17:0] green = (mul1 + {10'd136, 7'b0}) - (mul3 + mul4);//
  wire [17:0] blue 	= (mul1 + mul5) - ({10'd277, 7'b0} - {in_cb, 7'b0});//

  wire [10:0] red_int 	= red[17:7];
  wire [10:0] green_int = green[17:7];
  wire [10:0] blue_int 	= blue[17:7];
 
  assign out_r = red_int[10] 	? 8'b0 : ((|red_int[9:8]) 	? 8'hff : red_int[7:0]);
  assign out_g = green_int[10] 	? 8'b0 : ((|green_int[9:8]) ? 8'hff : green_int[7:0]);
  assign out_b = blue_int[10] 	? 8'b0 : ((|blue_int[9:8]) 	? 8'hff : blue_int[7:0]);
  
endmodule
