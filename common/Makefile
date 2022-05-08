common:
	ghdl -a --std=08 --work=ti --workdir=../libs common_globals_pkg.vhd
	ghdl -a --std=08 --work=ti --workdir=../libs common_pkg.vhd
	ghdl -a --std=08 --work=ti --workdir=../libs priority_encoder.vhd
	ghdl -a --std=08 --work=ti --workdir=../libs fifo_fwft.vhd
	ghdl -a --std=08 --work=ti --workdir=../libs skidbuffer.vhd

synth: common
	ghdl -m --std=08 --work=ti --workdir=../libs skidbuffer
	ghdl --synth --std=08 --work=ti --workdir=../libs skidbuffer

common_test: common
	ghdl -a -P../libs --std=08 common_pkg_tb.vhd
	ghdl -e -P../libs --std=08 common_tb
	ghdl -r -P../libs --std=08 common_tb

fwft_test: common
	ghdl -a --std=08 -P../libs fifo_fwft_tb.vhd
	ghdl -m --std=08 -P../libs fifo_fwft_tb
	ghdl -r --std=08 -P../libs fifo_fwft_tb --wave=fifo_fwft_tb.ghw

skidbuffer_test: common
	ghdl -a --std=08 -P../libs skidbuffer_tb.vhd
	ghdl -m --std=08 -P../libs skidbuffer_tb
	ghdl -r --std=08 -P../libs skidbuffer_tb --wave=skidbuffer_tb.ghw

priority_encoder_test: common
	ghdl -a --std=08 -P../libs priority_encoder_tb.vhd
	ghdl -m --std=08 -P../libs priority_encoder_tb
	ghdl -r --std=08 -P../libs priority_encoder_tb --wave=priority_encoder_tb.ghw

priority_encoder_2_test: common
	ghdl -a --std=08 -P../libs priority_encoder_2_tb.vhd
	ghdl -m --std=08 -P../libs priority_encoder_2_tb
	ghdl -r --std=08 -P../libs priority_encoder_2_tb --wave=priority_encoder_2_tb.ghw

test: common_test fwft_test skidbuffer_test
