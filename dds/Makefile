synth: 
	ghdl --synth --std=08 phase_acc > phase_acc.synth.vhd
	ghdl --synth --std=08 pdm > pdm.synth.vhd
	ghdl --synth --std=08 lookup_table > lookup_table.synth.vhd
	ghdl --synth --std=08 dds > dds.synth.vhd

phase_acc: 
	ghdl -a --std=08 phase_acc.vhd
	ghdl -e --std=08 phase_acc

pdm: 
	ghdl -a --std=08 pdm.vhd
	ghdl -e --std=08 pdm

lookup_table: 
	ghdl -a --std=08 lookup_table.vhd
	ghdl -e --std=08 lookup_table

dds: phase_acc pdm lookup_table
	ghdl -a --std=08 dds.vhd
	ghdl -e --std=08 dds

dds_tb: dds
	ghdl -a --std=08 dds_tb.vhd
	ghdl -e --std=08 dds_tb
	ghdl -r --std=08 dds_tb --wave=dds_tb.ghw

show:
	$(GTKWAVE) dds_tb.ghw dds_tb.sav

tex: 
	make -C doc tex

clean:
	$(RM) *.synth.vhd *.ghw *.cf *autosave.sav
	make -C doc clean

all: synth dds_tb tex
