 module linebuffer#(
    parameter       DATA_LINES      = 3,
    parameter       DATA_NUM        = 1024,
    parameter       DATA_WIDTH      = 8
)(      
    input                                               rst_n,

    input                                               in_clk,in_de,
    input       [DATA_WIDTH-1:0]                        in_data,

    input                                               out_clk,out_de,
    output   reg   [DATA_LINES * DATA_WIDTH -1 : 0]     out_data
);

logic [DATA_NUM - 1:0][DATA_WIDTH - 1 : 0]  fifo_data [0 : DATA_LINES - 1];

/*****************************************************************************************/
/********************************     写入数据      **************************************/
/***************************************************************************************/
//========================= 头数据  =============================
always@(posedge in_clk)
    if(!rst_n)   
        fifo_data[0][0] <= 0;
    else if(in_de) 
        fifo_data[0][0] <= in_data;
    else 
    	fifo_data[0][0] <= fifo_data[0][0];

genvar i1;
generate
    for( i1 = 0; i1 < DATA_LINES - 1; i1++)begin  : write_head
        always@(posedge in_clk)
            if(!rst_n)
                fifo_data[ i1 + 1 ][0] <= 0; 
            else if(in_de) 
                fifo_data[ i1 + 1 ][0] <= fifo_data[i1][DATA_NUM - 1];
            else
            	fifo_data[ i1 + 1 ][0] <= fifo_data[ i1 + 1 ][0];
    end
endgenerate

//========================= 移位数据  =============================
always@(posedge in_clk)
    if(!rst_n)   
        fifo_data[0][DATA_NUM - 1] <= 0;
    else if(in_de) 
        for(int i2 = 0; i2 < DATA_LINES; i2++) 
            for(int j = 1; j < DATA_NUM; j++) 
                fifo_data[i2][j] <= fifo_data[i2][ j - 1 ];
    else
    	for(int i2 = 0; i2 < DATA_LINES; i2++) 
            for(int j = 1; j < DATA_NUM; j++) 
                fifo_data[i2][j] <= fifo_data[i2][j];

/****************************************************************************************/
/*******************************     读取数据      **************************************/
/**************************************************************************************/
genvar i3;
generate
    for( i3 = 0; i3 < DATA_LINES; i3++)begin  : read_head
        always@(posedge out_clk) 
            if(out_de) 
                out_data[DATA_WIDTH * i3 +: DATA_WIDTH] <= fifo_data[i3][0]; 
            else 
            	out_data[DATA_WIDTH * i3 +: DATA_WIDTH] <= out_data[DATA_WIDTH * i3 +: DATA_WIDTH];
        end
endgenerate

endmodule 