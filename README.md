This is where I keep my (public) VHDL / Verilog stuff.

Please not that all code, unless otherwise stated, is licensed under the license given in the top directory LICENSE file.


## Non-bullshit points why VHDL is a very bad language:

(this is still work in progress)

* No support for generics / templated programming.
  - Leads to code-duplication when needing e.g. a fifo for another datatype.
  - Changes then need to be backported manually.
* _Way too much_ boilerplate code.
* Hard to grasp concept of “libraries”.
* Allows for very complex syntax construct that may be unreadable or not supported.
  - This is due to the rule that in conditional statements the last statement wins. Almost nobody knows about this rule and it works inside as well as outside of process statements. (Knowing this rule actually solves a lot of problems around the generate statement.)
* Generate statement that is part of the syntax itself and not a preprocessor macro, thus losing a lot of its power.
* No global variables.
  - Global variables that stretch processes or even entities are in fact supported, but it's a hassle. (I'm talking about shared variables.)
* No records for in / out types. That is, if I need a complex port bus such as the AXI protocol, I must create two records: One for all the inputs and one for all the outputs (or vice versa).
* Code is only compatible with Verilog if only std\_logic is used for ports. (
  - This applies to commercial / vendor tools.
* processes /= sequential logic
  - FlipFlops outside processes possible.
  - Combinatorial logic inside processes possible.
* Event driven syntax leads to unreadable code.
* Did I already state, that there are no Generics? Yes, you have to rewrite your fifo for every datatype...
  - This points deserves so very much attention.
* Distinction between synthezisable code / non-synthezisable code is hard for the beginner.
* huge difference between process statements with and without a sensitivity list, that is not apparent to the beginner.
  - Process statements can be used for: Exciting process in a testbench, sequential logic and combinatorial logic.
* Very nice ieee standard libraries, that are documented nowhere and that almost nobody knows about.
  - Have a look at the sources: [ieee libraries](https://github.com/ghdl/ghdl/tree/master/libraries/ieee)
* Very nice ieee.env library that contains 2 function (or 3? I can't remember right now) 
  * This is actually a plus point, as I value simplicity.
  * [std.env library](https://github.com/ghdl/ghdl/blob/master/libraries/std/env.vhdl)
* Nearly unparsable syntax:
  - Quote: “The grammar constructed by standard rewriting of the EBNF contains 743 productions, 78 shift/reduce conflicts and foremostly 579 reduce/recduce conflicts.”
  - [A Note on the Parsing of Complete VHDL-2OO2](http://ftp.informatik.rwth-aachen.de/Publications/CEUR-WS/Vol-255/paper11.pdf)
  - This severely prevents the creation of open source tools.
* No concept of “interfaces“ nor of “standard components” such as a fifo / elasticity buffer / register-mapped interface.
* Anytime you need to index more than 31^2 - 1 elements, you're out of luck.
  - This is in fact not of much _practical_ relevance (for synthesis), but the issue comes up in simulation time and again.
* No unified entity or rather language tree abstractions. Every tools implements its own internal representation, which leads to incompatibilities.

What I would wish VHDL to look like:

**SpinalHDL**

(just without the slow JVM in the background)
