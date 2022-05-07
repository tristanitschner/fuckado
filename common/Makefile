common:
	ghdl -a --work=ti --workdir=../libs --std=08 common_pkg.vhd
	ghdl -a --work=ti --workdir=../libs --std=08 priority_encoder.vhd
	ghdl -a --work=ti --workdir=../libs --std=08 fifo_fwft.vhd


common_test: common
	ghdl -a -P../libs --std=08 common_pkg_tb.vhd
	ghdl -e -P../libs --std=08 common_tb
	ghdl -r -P../libs --std=08 common_tb

fwft_test: common
	ghdl -a --std=08 -P../libs fifo_fwft_tb.vhd
	ghdl -e --std=08 -P../libs fifo_fwft_tb
	ghdl -m --std=08 -P../libs fifo_fwft_tb

test: common_test fwft_test
