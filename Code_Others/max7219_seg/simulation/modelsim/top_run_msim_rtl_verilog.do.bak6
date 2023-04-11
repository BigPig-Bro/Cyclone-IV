transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/HUIP/Desktop/max7219 {C:/Users/HUIP/Desktop/max7219/top.v}

vlog -vlog01compat -work work +incdir+C:/Users/HUIP/Desktop/max7219/simulation/modelsim {C:/Users/HUIP/Desktop/max7219/simulation/modelsim/top.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  top_vlg_tst

add wave *
view structure
view signals
run -all
