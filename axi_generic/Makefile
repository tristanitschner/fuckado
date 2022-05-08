entity=ti_axil_datamover_s2mm
tb=ti_axil_datamover_s2mm_tb

analyze:
	ghdl -a --std=08 $(entity).vhd
	ghdl -a --std=08 $(tb).vhd

elaborate: analyze
	ghdl -e --std=08 $(entity)
	ghdl -e --std=08 $(tb)

test: elaborate
	ghdl -r --std=08 $(tb) --wave=$(tb).ghw

test_show:
	$(GTKWAVE) $(tb).ghw *sav

axi_pkg:
	ghdl -a --std=08 --work=ti --workdir=../libs axi_pkg.vhd

axi_pkg_test: axi_pkg
	ghdl -a --std=08 --work=ti --workdir=../libs axi_pkg_tb.vhd
	ghdl -m --std=08 --work=ti --workdir=../libs axi_pkg_tb
	ghdl -r --std=08 --work=ti --workdir=../libs axi_pkg_tb --wave=axi_pkg_tb.ghw
