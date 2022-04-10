NAME=mc51_addr_dec

compile:
	ghdl -a --std=08 $(NAME).vhd
	ghdl -e --std=08 $(NAME)

sim: bridge
	ghdl -a --std=08 $(NAME)_tb.vhd
	ghdl -e --std=08 $(NAME)_tb
	ghdl -r --std=08 $(NAME)_tb --wave=$(NAME).ghw

wave: sim
	$(GTKWAVE) $(NAME).ghw *.sav

simple: compile
	ghdl --synth --out=verilog --std=08 $(NAME) > $(NAME).simple.v

all: sim simple
