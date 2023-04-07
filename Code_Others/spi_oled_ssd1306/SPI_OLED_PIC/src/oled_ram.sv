module oled_ram (
	input			 	clk, 	
	input 		[ 9:0]	write_addr, 
	input    	[ 7:0]	write_data, 

	input		[ 9:0]	read_addr, 	
	output reg  [ 7:0] 	read_data
);

reg [7:0] ram_data[1023:0];
initial $readmemh("VME50.txt", ram_data);

always@(posedge clk) 	ram_data[write_addr] <= write_data;
always@(posedge clk)  	read_data<= ram_data[read_addr];

endmodule
