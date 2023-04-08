module bt656_rx (
  input         clk1,		// 27 MHz
 // input Gclk,
  input       rst_n,
  input [7:0] din,

  output  reg   lcc2,
  output  reg  de,
  output  reg  v,
  output  reg  h,
  output reg [7:0] y,
  output reg [7:0] cb,
  output reg [7:0] cr,
  output reg [8:0]	    line
  );
  //---------------------------------------------------------------------------
  // Scan input stream to decode timing reference signals
  //---------------------------------------------------------------------------
  reg [1:0]    time_ref;


  parameter idle	= 2'b00,
	    ff		= 2'b01,
	    ff00	= 2'b10,
	    ff0000	= 2'b11;

  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      time_ref <= idle;
    else
      case (time_ref)
	idle:
	  if (din == 8'hff)
	    time_ref <= ff;

	ff:
	  if (din == 8'h0)
	    time_ref <= ff00;
	  else
	    time_ref <= idle;

	ff00:
	  if (din == 8'h0)
	    time_ref <= ff0000;
	  else
	    time_ref <= idle;

	ff0000:
	  time_ref <= idle;
      endcase

  wire 	    timing_ref = (time_ref == ff0000);

  reg 	    timing_ref_r;
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      timing_ref_r <= 1'b0;
    else
      timing_ref_r <= timing_ref;

   wire   clk = clk1;

  //---------------------------------------------------------------------------
  // blanking flags
  //---------------------------------------------------------------------------
  
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      de <= 1'b0;
    else if (timing_ref)
      de <= din[6];
  
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      v <= 1'b0;
    else if (timing_ref)
      v <= din[5];

  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      h <= 1'b0;
    else if (timing_ref)
      h <= din[4];

  //---------------------------------------------------------------------------
  // Input capture registers
  //---------------------------------------------------------------------------
  reg [1:0] input_phase;
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      input_phase <= 2'b0;
    else if (h | v)
      input_phase <= 2'b0;
    else
      input_phase <= input_phase + 2'b01;
      
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
	  lcc2 <= 1'b0;
    else
	lcc2 <= ~lcc2;
  //
  reg [7:0] y_reg;
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      y_reg <= 8'b0;
    else if (input_phase[0])
      y_reg <= din;
  
  reg [7:0] cb_reg;
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      cb_reg <= 8'b0;
    else if (input_phase == 2'b00)
      cb_reg <= din;
  
  reg [7:0] cr_reg;
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      cr_reg <= 8'b0;
    else if (input_phase == 2'b10)
      cr_reg <= din;

  reg 	    sav;
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      y <= 8'b0;
    else if (input_phase[0] & ~sav & ~timing_ref)
      y <= y_reg;
  
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      cb <= 8'b0;
    else if ((input_phase == 2'b11) & ~timing_ref)
      cb <= cb_reg;
  
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      cr <= 8'b0;
    else if ((input_phase == 2'b11) & ~timing_ref)
      cr <= cr_reg;
  //sav
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      sav <= 1'b0;
    else if (timing_ref & ((din == 8'h80) | (din == 8'hc7)))
      sav <= 1'b1;
    else if (input_phase == 2'b10)
      sav <= 1'b0;

  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      line <= 9'b0;
    else if (v)
      line <= 9'b0;
    else if (timing_ref_r & sav)
      line <= line + 9'b1;

  
endmodule	// bt656_rx
