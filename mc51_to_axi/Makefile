NAME=mc51_to_axi_bridge

bridge:
	ghdl -a --std=08 $(NAME).vhd
	ghdl -e --std=08 $(NAME)

sim: 
	ghdl -a --std=08 $(NAME)_tb.vhd
	ghdl -e --std=08 $(NAME)_tb
	ghdl -r --std=08 $(NAME)_tb --wave=$(NAME).ghw

wave:
	$(GTKWAVE) $(NAME).ghw *.sav

simple:
	ghdl --synth --std=08 $(NAME) > $(NAME).simple.vhd
