NAME=mdio_controller
NAME2=mdio_controller2

compile:
	ghdl -a --std=08 $(NAME).vhd
	ghdl -e --std=08 $(NAME)
	ghdl -a --std=08 $(NAME2).vhd
	ghdl -e --std=08 $(NAME2)

sim: bridge
	ghdl -a --std=08 $(NAME)_tb.vhd
	ghdl -e --std=08 $(NAME)_tb
	ghdl -r --std=08 $(NAME)_tb --wave=$(NAME).ghw
	ghdl -a --std=08 $(NAME2)_tb.vhd
	ghdl -e --std=08 $(NAME2)_tb
	ghdl -r --std=08 $(NAME2)_tb --wave=$(NAME2).ghw

wave: sim
	$(GTKWAVE) $(NAME).ghw *.sav
	$(GTKWAVE) $(NAME2).ghw *.sav

simple: compile
	ghdl --synth --latches --out=verilog --std=08 $(NAME) > $(NAME).simple.v
	ghdl --synth --out=verilog --std=08 $(NAME2) > $(NAME2).simple.v

all: sim simple
