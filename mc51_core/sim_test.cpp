//    Copyright (C) 2022	Tristan Itschner
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.

#include <verilated.h>
#include <verilated_vcd_c.h>
#include <Vmc8051_core.h>
#include <stdio.h>
#include "softmem.cpp"
#include "opcodes.h"


template<class MODULE> class TESTBENCH {
    public:
    unsigned long m_tickcount;
    MODULE *core;
    softrom *sm;
    uint8_t * rom;
    uint8_t ram[256];
    FILE * ram_fp = fopen("ram.log", "w");
    VerilatedVcdC* tfp;

    TESTBENCH(void) {
        core = new MODULE;
        Verilated::traceEverOn(true);
        tfp = new VerilatedVcdC;
        core->trace(tfp,3);
        tfp->open("trace.vcd");
    }

    ~TESTBENCH(void) {
        delete core;
        delete tfp;
        tfp->close();
    }


    int ram_data_in_tmp = 0;
    void tick(void) {
//        sm->eval();
        core->rom_data_i = this->rom[core->rom_adr_o];
        ram_data_in_tmp = this->ram[core->ram_adr_o];
        if(core->ram_en_o) {
            if (!core->ram_wr_o ) {
                fprintf(ram_fp, "cyc: %li Reading fram ram location \t%02x, value %02x\n", m_tickcount, core->ram_adr_o, ram[core->ram_adr_o]);
            } else {
                this->ram[core->ram_adr_o] = core->ram_data_o;
                fprintf(ram_fp, "cyc: %li Writing to ram location \t%02x, value %02x\n", m_tickcount, core->ram_adr_o, core->ram_data_o);
            }
        }
        tfp->dump(m_tickcount);
        core->clk = '1';
        core->eval();
        tfp->dump(m_tickcount++);
        core->clk = '0';
        core->eval();
        core->ram_data_i = ram_data_in_tmp; // registered output
        m_tickcount++;
    }

    void reset(void) {
        core->reset = 1;
        core->int0_i = 1;
        core->int1_i = 1;
        for (int i = 0; i < 100; i++) {
            this->tick();
        }
        core->reset = 0;
    }

    void initrom( char * fn ) {
        this->sm = new softrom (fn);
        this->rom = this->sm->getrom();
    }

    int opcount = 3;
    int sp = 2;
    int old_adr = 2;
//    int lastaddr = -1;
    void print_rom_access(FILE * fp) {
        fprintf(fp, "cyc: %li ROM: Addr: %04x \tData %02x", m_tickcount, core->rom_adr_o, core->rom_data_i);
        if ((old_adr < sp) || (old_adr >= sp + opcount )) { // doesn't work if instruction jumps to itself
            fprintf(fp, "\t%s,\t len: %i\n", opcodes[core->rom_data_i].name, opcodes[core->rom_data_i].bytes);
            old_adr = sp;
            sp = core->rom_adr_o;
            opcount = opcodes[core->rom_data_i].bytes;
        } else {
            fprintf(fp, "\n");
        }
//        if (lastaddr != core->rom_adr_o) this->opcount--;
//        lastaddr = core->rom_adr_o;
    }


    void record_rx(FILE * fp) {
        fprintf(fp, "cyc: %li UART: all_txd_o: %i\n", m_tickcount, core->all_txd_o);
    }
};

int main (int argc, char ** arv, char ** env) {
    TESTBENCH<Vmc8051_core> * tb = new TESTBENCH<Vmc8051_core>();
    char fn[] = "uart.hex"; // put your hex file here
    FILE * uart_log_fp = fopen("uart.log", "w");
    FILE * rom_log_fp = fopen("rom.log", "w");
    tb->initrom(fn);

    tb->reset();
    tb->tick();

    for (int i = 0; i < 10000; i++) {
        tb->print_rom_access(rom_log_fp);
        tb->record_rx(uart_log_fp);
        tb->tick();
    }
    delete tb;
    fclose(uart_log_fp);
    fclose(rom_log_fp);
}
