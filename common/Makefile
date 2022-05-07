common:
	ghdl -a --std=08 --work=ti --workdir=../libs common_pkg.vhd
	ghdl -a --std=08 --work=ti --workdir=../libs priority_encoder.vhd
	ghdl -a --std=08 --work=ti --workdir=../libs fifo_fwft.vhd

common_test: common
	ghdl -a -P../libs --std=08 common_pkg_tb.vhd
	ghdl -e -P../libs --std=08 common_tb
	ghdl -r -P../libs --std=08 common_tb

fwft_test: common
	ghdl -a --std=08 -P../libs fifo_fwft_tb.vhd
	ghdl -m --std=08 -P../libs fifo_fwft_tb
	ghdl -r --std=08 -P../libs fifo_fwft_tb

test: common_test fwft_test
