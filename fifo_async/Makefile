TOP = fifo2
SOURCES = async_cmp fifomem rptr_empty wptr_full

.PHONY: xpm

xpm:
	ghdl -i --std=08 --work=xpm  xpm/xpm_VCOMP.vhd xpm/xpm_cdc/hdl/*.vhd xpm/xpm_fifo/hdl/*.vhd xpm/xpm_fifo/simulation/*.vhd xpm/xpm_memory/hdl/*.vhd
	ghdl -e --std=08 --work=xpm xpm_memory_sdpram

compile: 	
	ghdl -i --std=08 $(SOURCES:=.vhd) $(TOP:=.vhd)
	ghdl -e --std=08 $(TOP)

sim: compile  
	ghdl -a --std=08 $(TOP)_tb.vhd
	ghdl -e --std=08 $(TOP)_tb
	ghdl -r --std=08 $(TOP)_tb --wave=$(TOP).ghw

wave: sim
	$(GTKWAVE) $(TOP).ghw *.sav

simple: compile
	ghdl --synth --latches --out=verilog --std=08 async_cmp > async_cmp.simple.v
	ghdl --synth --latches --out=verilog --std=08 fifomem > fifomem.simple.v
	ghdl --synth --latches --out=verilog --std=08 rptr_empty > rptr_empty.simple.v
	ghdl --synth --latches --out=verilog --std=08 wptr_full > wptr_full.simple.v
	ghdl --synth --latches --out=verilog --std=08 $(TOP) > $(TOP).simple.v

all: sim simple
