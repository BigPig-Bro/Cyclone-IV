transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/Users/HUIP/Desktop/SPI_OLED/src {D:/Users/HUIP/Desktop/SPI_OLED/src/top.v}
vlog -vlog01compat -work work +incdir+D:/Users/HUIP/Desktop/SPI_OLED/src {D:/Users/HUIP/Desktop/SPI_OLED/src/spi_master.v}
vlog -sv -work work +incdir+D:/Users/HUIP/Desktop/SPI_OLED/src {D:/Users/HUIP/Desktop/SPI_OLED/src/oled_ctrl.sv}

vlog -vlog01compat -work work +incdir+D:/Users/HUIP/Desktop/SPI_OLED/src {D:/Users/HUIP/Desktop/SPI_OLED/src/spi_master_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  spi_master_tb

add wave *
view structure
view signals
run -all
