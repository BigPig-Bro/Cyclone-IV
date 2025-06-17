localparam PS2_IDLE    = 8'h00; //PS2手柄空闲状态
localparam PS2_START_A = 8'h01; //PS2手柄启动 A
localparam PS2_START_B = 8'h42; //PS2手柄启动 B

task RW_PS2_1Byte(
    input        [7:0]   PS2_Write_Data, //写入数据
    output logic [7:0]   PS2_Read_Data,  //读取数据

    output logic         send_req, //SPI开始信号
    input                spi_busy,  //SPI忙信号
    input                spi_recv_valid, //SPI接收使能
    input        [ 7:0]  spi_read_data, //SPI读取数据
    output logic [ 7:0]  spi_write_data //SPI写入数据
);
    //启动信号控制
    if (!spi_busy) begin //如果SPI不忙
        send_req = 1'b1; //启动SPI
    end else begin //如果SPI忙
        send_req = 1'b0;
    end

    //写入数据控制
    spi_write_data = PS2_Write_Data; //写入数据

    //读取数据控制
    if (spi_recv_valid) begin //如果SPI接收有效
        PS2_Read_Data = spi_read_data; //读取数据
    end 
endtask