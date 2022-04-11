NAME=mc51_to_axi_bridge

compile:
	ghdl -a --std=08 $(NAME).vhd
	ghdl -e --std=08 $(NAME)

sim: compile
	ghdl -a --std=08 $(NAME)_tb.vhd
	ghdl -e --std=08 $(NAME)_tb
	ghdl -r --std=08 $(NAME)_tb --wave=$(NAME).ghw

wave: sim
	$(GTKWAVE) $(NAME).ghw *.sav

simple: compile
	ghdl --synth --out=verilog --std=08 $(NAME) > $(NAME).simple.v

all: compile sim simple
