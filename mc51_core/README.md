This is a patched version of the Oregano Systems 8051 core. It is patched in such a manner, that it compiles with GHDL.

Furthermore it comes with a Verilator testbench and a simple Intel .hex file parser, that loads the file's contents into a virtual memory inside the C++ testbench and executes it. Log files also include disassembly information.

However, I do not know, whether this core is working as intended. The basic functionality seems to be good, but the changes I made might broke something. I tried to write a virtual UART driver, but the counter just wouldn't run propery. After trying to co-simulate both code paths in Vivado, and Vivado died on me for the billionth time because the default syntax checker (it is know to have a huge memory leak, if you read Xilinx forum entries) was selected, I called it quits. Somebody else might like to pick up, where I left off.
