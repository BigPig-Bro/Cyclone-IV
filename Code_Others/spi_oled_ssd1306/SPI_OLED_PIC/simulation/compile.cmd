@echo off
color 0a
"E:\TOOL\restart\iverilogAssistant\iverilog\bin\iverilog.exe" -o "spi_tb.o" "tb\spi_tb.v" "src\spi_master.v" 
"E:\TOOL\restart\iverilogAssistant\iverilog\bin\vvp.exe" "spi_tb.o" 
pause