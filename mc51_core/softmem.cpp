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
#include <assert.h>

class softrom{
    FILE * fp;
    uint8_t * rom;

    public:
    softrom(char * fn) {
        FILE * fp = fopen(fn, "r");
        if (fp == NULL) {
            fprintf(stderr, "Failed to open file %s.\n", fn);
            exit(-1);
        }
        this->rom = (uint8_t *) malloc(2048);
        for (int i = 0; i < 2048; i++) {
            rom[i] = 0;
        }
        printf("initialized romory\n");
        int bound = 2048;

        ssize_t read;
        char * line = NULL;
        size_t len = 0;
        unsigned char bytecount;
        uint16_t address;
        unsigned char recordtype;
        unsigned char checksum;
        char buf[4];
        unsigned char byte;
        while ((read = getline(&line, &len, fp)) != -1) {
            if (len == 0 || line[0] != ':') 
            {
                printf("skipping line\n");
                continue; // skip line
            }
            checksum = 0;
            // buf[0] = line[1]; buf[1] = line[2]; buf[2] = ' ';
            strncpy(buf, &(line[1]), 2); buf[2] = '\0';
            bytecount = strtoul(buf, NULL, 16); printf("bytecount 0x%02x\n", bytecount);
            checksum += bytecount;
            strncpy(buf, &(line[3]), 4); buf[4] = '\0';
            address = strtoul(buf, NULL, 16); printf("address 0x%04x\n", address);
            checksum += address / 256;
            checksum += address % 256;
            strncpy(buf, &(line[7]), 2); buf[2] = '\0';
            recordtype = strtoul(buf, NULL, 16); printf("recordtype 0x%02x\n", recordtype);
            checksum += recordtype;
            switch (recordtype) {
                case 0x00:
                    for (int i = 0; i < bytecount; i++) {
                        strncpy(buf, &(line[9 + 2*i]), 2); buf[2] = '\0';
                        byte = (unsigned char) strtoul(buf, NULL, 16);
                        if (address + i > bound) {
                            printf("exiting: out of bounds...\n");
                            exit(-1);
                        }
                        rom[address + i] = byte; printf("wrote byte 0x%02x to location 0x%04x\n", byte, address + i);
                        checksum += byte;
                    }
                    strncpy(buf, &(line[9 + 2*bytecount]), 2); buf[2] = '\0';
                    byte = strtoul(buf, NULL, 16);
                    printf("checksum given %02x, checksum calculatd %02x\n", byte, (unsigned char) (~checksum + 1));
                    assert(byte == (unsigned char) (~checksum + 1));
                    break;
                case 0x01:
                    printf("Reached eof...\n");
                    break;
                default:
                    printf("exiting: Unknown record type...\n");
                    exit(-1);
            }


        }
        fclose(fp);

        for (int i = 0; i < 2048; i++) {
            printf("romory adr: %04x, content: %02x\n", i, rom[i]);
        }
    }
    ~softrom() {
        free(this->rom);
    }

    /*
    void eval(void) {
        printf("setting %02x to %02x, addr %04x\n", this->d, this->rom[this->a], this->a);
        this->d = this->rom[this->a];
    }
    */

    uint8_t * getrom(void) {
        return  rom;
    }
};
