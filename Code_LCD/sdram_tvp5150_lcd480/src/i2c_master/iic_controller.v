// --------------------------------------------------------------------
// Copyright (c) 2005 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altrea Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL or Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:i2c controller
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Joe Yang          :| 05/07/10  :|      Initial Revision
// --------------------------------------------------------------------
`timescale 1ns/100ps
module I2C_Controller (
	CLOCK,
	I2C_SCLK,//I2C CLOCK
 	I2C_SDAT,//I2C DATA
	I2C_DATA,//DATA:[SLAVE_ADDR,SUB_ADDR,DATA]
	GO,      //GO transfor
	END,     //END transfor 
	W_R,     //W_R
	ACK,      //ACK
	RESET,
	//TEST
	SD_COUNTER,
	SDO
);
	input  CLOCK;
	input  [23:0]I2C_DATA;	
	input  GO;
	input  RESET;	
	input  W_R;
 	inout  I2C_SDAT;	
	output I2C_SCLK;
	output END;	
	output ACK;

//TEST
	output [7:0] SD_COUNTER;
	output SDO;


reg SDO;
reg SCLK;
reg END;
reg [23:0]SD;
reg [7:0]SD_COUNTER;
reg  I2C_SCLK;
//wire I2C_SCLK=SCLK | ( ((SD_COUNTER >= 4) & (SD_COUNTER <=30))? ~CLOCK :0 );
wire I2C_SDAT = SDO ? 1'bz : 0 ;

reg ACK1,ACK2,ACK3;
wire ACK=ACK1 | ACK2 |ACK3;

//--I2C COUNTER
always @(negedge RESET or posedge CLOCK ) begin
if (!RESET) SD_COUNTER=8'b11111111;
else begin
if (GO==0) 
	SD_COUNTER=8'd0;
	else 
	if (SD_COUNTER < 8'b11111111) SD_COUNTER=SD_COUNTER+1;	
end
end
//----

always @(negedge RESET or  posedge CLOCK ) begin
if (!RESET) begin I2C_SCLK=1;SDO=1; ACK1=0;ACK2=0;ACK3=0; END=1; end
else
case (SD_COUNTER)
	8'd0  : begin ACK1=1 ;ACK2=1 ;ACK3=1 ; END=0; SDO=1; I2C_SCLK=1;end
	//start
	8'd1  : begin SD=	#1	I2C_DATA;SDO=	#1	1;end
	8'd2  : begin SDO=	#1	0;	end
	//SLAVE ADDR
	8'd3  	: begin I2C_SCLK=	#1	0;	end
	8'd4	: begin SDO=	#1	SD[23];	end
	8'd5  	: begin I2C_SCLK=	#1	1;	end
	8'd6  	: begin I2C_SCLK=	#1	0;	end
	8'd7  	: SDO=	#1	SD[22];
	8'd8  	: begin I2C_SCLK=	#1	1;	end
	8'd9  	: begin I2C_SCLK=	#1	0;	end
	8'd10  	: SDO=	#1	SD[21];
	8'd11   : begin I2C_SCLK=	#1	1;	end
	8'd12   : begin I2C_SCLK=	#1	0;	end
	8'd13  	: SDO=	#1	SD[20];
	8'd14   : begin I2C_SCLK=	#1	1;	end
	8'd15   : begin I2C_SCLK=	#1	0;	end
	8'd16  : SDO=	#1	SD[19];
	8'd17   : begin I2C_SCLK=	#1	1;	end
	8'd18   : begin I2C_SCLK=	#1	0;	end
	8'd19  : SDO=	#1	SD[18];
	8'd20   : begin I2C_SCLK=	#1	1;	end
	8'd21   : begin I2C_SCLK=	#1	0;	end
	8'd22  : SDO=	#1	SD[17];
	8'd23   : begin I2C_SCLK=	#1	1;	end
	8'd24   : begin I2C_SCLK=	#1	0;	end
	8'd25 : SDO=	#1	SD[16];
	8'd26   : begin I2C_SCLK=	#1	1;	end
	8'd27   : begin I2C_SCLK=	#1	0;	end	
	8'd28 : begin SDO=	#1	1'b1;end
	8'd29	:	ACK1=	#1	I2C_SDAT;	//ACK
	8'd30   : begin I2C_SCLK=	#1	1;	end
	8'd31   : begin I2C_SCLK=	#1	0;	end	
	//SUB ADDR
	8'd32  : begin 	SDO=	#1	SD[15];  end
	8'd33   : begin I2C_SCLK=	#1	1;	end
	8'd34   : begin I2C_SCLK=	#1	0;	end
	8'd35  : SDO=	#1	SD[14];
	8'd36   : begin I2C_SCLK=	#1	1;	end
	8'd37   : begin I2C_SCLK=	#1	0;	end
	8'd38  : SDO=	#1	SD[13];
	8'd39   : begin I2C_SCLK=	#1	1;	end
	8'd40   : begin I2C_SCLK=	#1	0;	end
	8'd41  : SDO=	#1	SD[12];
	8'd42   : begin I2C_SCLK=	#1	1;	end
	8'd43   : begin I2C_SCLK=	#1	0;	end
	8'd44  : SDO=	#1	SD[11];
	8'd45   : begin I2C_SCLK=	#1	1;	end
	8'd46   : begin I2C_SCLK=	#1	0;	end
	8'd47  : SDO=	#1	SD[10];
	8'd48   : begin I2C_SCLK=	#1	1;	end
	8'd49   : begin I2C_SCLK=	#1	0;	end
	8'd50  : SDO=	#1	SD[9];
	8'd51   : begin I2C_SCLK=	#1	1;	end
	8'd52   : begin I2C_SCLK=	#1	0;	end
	8'd53  : SDO=	#1	SD[8];
	8'd54   : begin I2C_SCLK=	#1	1;	end
	8'd55   : begin I2C_SCLK=	#1	0;	end
	8'd56  : begin SDO=	#1	1'b1;end
	8'd57:	 begin ACK2=	#1	I2C_SDAT;end//ACK
	8'd58   : begin I2C_SCLK=	#1	1;	end
	8'd59   : begin I2C_SCLK=	#1	0;	end	
	//DATA
	8'd60  : begin	 SDO=	#1	SD[7]; end
	8'd61   : begin I2C_SCLK=	#1	1;	end
	8'd62   : begin I2C_SCLK=	#1	0;	end
	8'd63  : SDO=	#1	SD[6];
	8'd64   : begin I2C_SCLK=	#1	1;	end
	8'd65   : begin I2C_SCLK=	#1	0;	end
	8'd66  : SDO=	#1	SD[5];
	8'd67   : begin I2C_SCLK=	#1	1;	end
	8'd68   : begin I2C_SCLK=	#1	0;	end
	8'd69  : SDO=	#1	SD[4];
	8'd70   : begin I2C_SCLK=	#1	1;	end
	8'd71   : begin I2C_SCLK=	#1	0;	end
	8'd72  : SDO=	#1	SD[3];
	8'd73   : begin I2C_SCLK=	#1	1;	end
	8'd74   : begin I2C_SCLK=	#1	0;	end
	8'd75  : SDO=	#1	SD[2];
	8'd76   : begin I2C_SCLK=	#1	1;	end
	8'd77   : begin I2C_SCLK=	#1	0;	end
	8'd78  : SDO=	#1	SD[1];
	8'd79   : begin I2C_SCLK=	#1	1;	end
	8'd80   : begin I2C_SCLK=	#1	0;	end
	8'd81  : SDO=	#1	SD[0];
	8'd82   : begin I2C_SCLK=	#1	1;	end
	8'd83   : begin I2C_SCLK=	#1	0;	end
	8'd84  : begin SDO=	#1	1'b1;	end
	8'd85:	begin ACK3=	#1	I2C_SDAT;	end//ACK
	8'd86   : begin I2C_SCLK=	#1	1;	end
	8'd87   : begin I2C_SCLK=	#1	0;	end	

	
	//stop
    8'd88 : begin	SDO=	#1	1'b0; end
	8'd89:	begin 	I2C_SCLK=	#1	1'b1;		  end	
    8'd90 : begin SDO=	#1	1'b1; END=	#1	1; end 
	default:begin SDO=	#1	1'b1;	I2C_SCLK=	#1	1'b1; end 
endcase
end



endmodule

