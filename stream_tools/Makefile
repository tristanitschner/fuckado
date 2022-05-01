packet_holder:
	ghdl -i --std=08 packet_holder.vhd stream_pkg.vhd
	ghdl -e --std=08 packet_holder
	ghdl --synth --std=08 --out=verilog packet_holder > packet_holder_simple.v
	ghdl --synth --std=08 packet_holder > packet_holder_simple.vhd

prove: 
	sby --yosys "yosys -m ghdl" -f *sby prove

bmc: 
	sby --yosys "yosys -m ghdl" -f *sby bmc

show:
	$(GTKWAVE) 
