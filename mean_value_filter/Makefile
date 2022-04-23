maf:
	ghdl -a --std=08 maf.vhd
	ghdl -e --std=08 maf

sim: maf
	ghdl -a --std=08 maf_tb.vhd
	ghdl -e --std=08 maf_tb
	ghdl -r --std=08 maf_tb --wave=maf_tb.ghw

show:
	$(GTKWAVE) maf_tb.ghw maf_tb.sav
