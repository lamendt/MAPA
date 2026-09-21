transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/levia/Documents/hardisa/HDL {C:/Users/levia/Documents/hardisa/HDL/mhz25.v}
vlog -vlog01compat -work work +incdir+C:/Users/levia/Documents/hardisa/HDL/db {C:/Users/levia/Documents/hardisa/HDL/db/mhz25_altpll.v}
vlog -sv -work work +incdir+C:/Users/levia/Documents/hardisa/HDL {C:/Users/levia/Documents/hardisa/HDL/top.sv}

