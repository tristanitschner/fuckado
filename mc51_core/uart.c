#include "mcs51/8051.h"

void uart_send(char ch) {
    SBUF = ch;
    while (TI == 0);
    TI = 0;
    RI = 0;
}

char str[] = "Hello World\n";

int main() {
    PCON |= 0x80;
    TH1 = 0xef;
    TL1 = 0xef;
    SCON = 0x52;
    TMOD = 0x20;
//    TR1 = 1;
    TCON = 0x40;
    //EA = 1;
    for (;;) {
        for (int j = 0; j < 11; j++) {
        //    TCON = 0x40;
            uart_send(str[j]);
        }
    }

}
