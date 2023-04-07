transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+D:/Users/HUIP/Desktop/LCD12864/src {D:/Users/HUIP/Desktop/LCD12864/src/LCD12864_drive.sv}
vlog -sv -work work +incdir+D:/Users/HUIP/Desktop/LCD12864/src {D:/Users/HUIP/Desktop/LCD12864/src/LCD12864_top.sv}

vlog -vlog01compat -work work +incdir+D:/Users/HUIP/Desktop/LCD12864/simulation/modelsim {D:/Users/HUIP/Desktop/LCD12864/simulation/modelsim/LCD12864_top.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  LCD12864_top_vlg_tst

add wave *
view structure
view signals
run -all
