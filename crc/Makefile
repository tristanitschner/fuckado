codegen:
	gcc crc_table_generator.c -o crc_table_generator
	./crc_table_generator crc_pkg.vhd
	ghdl -a --std=08 --work=ti crc_pkg.vhd 

example:
	ghdl -a --std=08 crc_example.vhd
	ghdl -e --std=08 crc_example
	ghdl --synth --std=08 --out=verilog crc_example > crc_example.v
