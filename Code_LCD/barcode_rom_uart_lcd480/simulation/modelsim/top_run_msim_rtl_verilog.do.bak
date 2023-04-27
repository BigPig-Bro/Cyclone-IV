transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/src {E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/src/rgb_timing.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/src {E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/src/display.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/src/ip_core {E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/src/ip_core/sys_pll.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/src/ip_core {E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/src/ip_core/pic.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/db {E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/db/sys_pll_altpll.v}
vlog -sv -work work +incdir+E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/src {E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/src/uart_tx.sv}
vlog -sv -work work +incdir+E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/src {E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/src/uart_top.sv}
vlog -sv -work work +incdir+E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/src {E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/src/thres_scan.sv}
vlog -sv -work work +incdir+E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/src {E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/src/top.sv}

vlog -sv -work work +incdir+E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/simulation/modelsim {E:/FPGA_work/Cyclone/Code_LCD/barcode_rom_uart_lcd480/simulation/modelsim/top_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  top_tb

add wave *
view structure
view signals
run -all
