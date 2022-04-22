WNO = -Wno-UNOPTFLAT -Wno-COMBDLY -Wno-CASEINCOMPLETE

uart:
	sdcc uart.c
	packihx uart.ihx > uart.hex

verilog:
	ghdl -i -fsynopsys vhdl/*.vhd
	ghdl -m -fsynopsys mc8051_core
	ghdl --synth --out=verilog -fsynopsys mc8051_core > mc8051_core.v

verilate: verilog uart
	verilator $(WNO) --trace --cc --build --exe sim_test.cpp softmem.cpp mc8051_core.v

run: verilate
	./obj_dir/Vmc8051_core > run.log

show:
	gtkwave trace.vcd default.gtkw
