
#**************************************************************
# Create Clock
#**************************************************************

create_clock -name clk	 	 -period 20.000  [get_ports {clk}]
create_clock -name lcd_dclk	 -period 100.000 [get_ports {lcd_dclk}]
create_clock -name cmos_pclk -period 10.000  [get_ports {cmos_pclk}]


#**************************************************************
# Set Clock Groups
#**************************************************************

#set_clock_groups -asynchronous -group [get_clocks {sys_pll_m0|altpll_component|auto_generated|pll1|clk[1]}]
#set_clock_groups -asynchronous -group [get_clocks {sys_pll_m0|altpll_component|auto_generated|pll1|clk[0]}]
#set_clock_groups -asynchronous -group [get_clocks {cmos_pclk}]