common:
	ghdl -a --std=08 common_pkg.vhd

common_test: common
	ghdl -a --std=08 common_pkg_tb.vhd
	ghdl -e --std=08 common_tb
	ghdl -r --std=08 common_tb
