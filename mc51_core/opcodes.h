struct opcode {
    uint8_t op;
    int bytes;
    char name[50];
};

struct opcode opcodes[256] = {
    {0x00, 1, "NOP "},
    {0x01, 2, "AJMP addr11"},
    {0x02, 3, "LJMP addr16"},
    {0x03, 1, "RR A"},
    {0x04, 1, "INC A"},
    {0x05, 2, "INC direct"},
    {0x06, 1, "INC @R0"},
    {0x07, 1, "INC @R1"},
    {0x08, 1, "INC R0"},
    {0x09, 1, "INC R1"},
    {0x0A, 1, "INC R2"},
    {0x0B, 1, "INC R3"},
    {0x0C, 1, "INC R4"},
    {0x0D, 1, "INC R5"},
    {0x0E, 1, "INC R6"},
    {0x0F, 1, "INC R7"},
    {0x10, 3, "JBC bit, offset"},
    {0x11, 2, "ACALL addr11"},
    {0x12, 3, "LCALL addr16"},
    {0x13, 1, "RRC A"},
    {0x14, 1, "DEC A"},
    {0x15, 2, "DEC direct"},
    {0x16, 1, "DEC @R0"},
    {0x17, 1, "DEC @R1"},
    {0x18, 1, "DEC R0"},
    {0x19, 1, "DEC R1"},
    {0x1A, 1, "DEC R2"},
    {0x1B, 1, "DEC R3"},
    {0x1C, 1, "DEC R4"},
    {0x1D, 1, "DEC R5"},
    {0x1E, 1, "DEC R6"},
    {0x1F, 1, "DEC R7"},
    {0x20, 3, "JB bit, offset"},
    {0x21, 2, "AJMP addr11"},
    {0x22, 1, "RET "},
    {0x23, 1, "RL A"},
    {0x24, 2, "ADD A, #immed"},
    {0x25, 2, "ADD A, direct"},
    {0x26, 1, "ADD A, @R0"},
    {0x27, 1, "ADD A, @R1"},
    {0x28, 1, "ADD A, R0"},
    {0x29, 1, "ADD A, R1"},
    {0x2A, 1, "ADD A, R2"},
    {0x2B, 1, "ADD A, R3"},
    {0x2C, 1, "ADD A, R4"},
    {0x2D, 1, "ADD A, R5"},
    {0x2E, 1, "ADD A, R6"},
    {0x2F, 1, "ADD A, R7"},
    {0x30, 3, "JNB bit, offset"},
    {0x31, 2, "ACALL addr11"},
    {0x32, 1, "RETI "},
    {0x33, 1, "RLC A"},
    {0x34, 2, "ADDC A, #immed"},
    {0x35, 2, "ADDC A, direct"},
    {0x36, 1, "ADDC A, @R0"},
    {0x37, 1, "ADDC A, @R1"},
    {0x38, 1, "ADDC A, R0"},
    {0x39, 1, "ADDC A, R1"},
    {0x3A, 1, "ADDC A, R2"},
    {0x3B, 1, "ADDC A, R3"},
    {0x3C, 1, "ADDC A, R4"},
    {0x3D, 1, "ADDC A, R5"},
    {0x3E, 1, "ADDC A, R6"},
    {0x3F, 1, "ADDC A, R7"},
    {0x40, 2, "JC offset"},
    {0x41, 2, "AJMP addr11"},
    {0x42, 2, "ORL direct, A"},
    {0x43, 3, "ORL direct, #immed"},
    {0x44, 2, "ORL A, #immed"},
    {0x45, 2, "ORL A, direct"},
    {0x46, 1, "ORL A, @R0"},
    {0x47, 1, "ORL A, @R1"},
    {0x48, 1, "ORL A, R0"},
    {0x49, 1, "ORL A, R1"},
    {0x4A, 1, "ORL A, R2"},
    {0x4B, 1, "ORL A, R3"},
    {0x4C, 1, "ORL A, R4"},
    {0x4D, 1, "ORL A, R5"},
    {0x4E, 1, "ORL A, R6"},
    {0x4F, 1, "ORL A, R7"},
    {0x50, 2, "JNC offset"},
    {0x51, 2, "ACALL addr11"},
    {0x52, 2, "ANL direct, A"},
    {0x53, 3, "ANL direct, #immed"},
    {0x54, 2, "ANL A, #immed"},
    {0x55, 2, "ANL A, direct"},
    {0x56, 1, "ANL A, @R0"},
    {0x57, 1, "ANL A, @R1"},
    {0x58, 1, "ANL A, R0"},
    {0x59, 1, "ANL A, R1"},
    {0x5A, 1, "ANL A, R2"},
    {0x5B, 1, "ANL A, R3"},
    {0x5C, 1, "ANL A, R4"},
    {0x5D, 1, "ANL A, R5"},
    {0x5E, 1, "ANL A, R6"},
    {0x5F, 1, "ANL A, R7"},
    {0x60, 2, "JZ offset"},
    {0x61, 2, "AJMP addr11"},
    {0x62, 2, "XRL direct, A"},
    {0x63, 3, "XRL direct, #immed"},
    {0x64, 2, "XRL A, #immed"},
    {0x65, 2, "XRL A, direct"},
    {0x66, 1, "XRL A, @R0"},
    {0x67, 1, "XRL A, @R1"},
    {0x68, 1, "XRL A, R0"},
    {0x69, 1, "XRL A, R1"},
    {0x6A, 1, "XRL A, R2"},
    {0x6B, 1, "XRL A, R3"},
    {0x6C, 1, "XRL A, R4"},
    {0x6D, 1, "XRL A, R5"},
    {0x6E, 1, "XRL A, R6"},
    {0x6F, 1, "XRL A, R7"},
    {0x70, 2, "JNZ offset"},
    {0x71, 2, "ACALL addr11"},
    {0x72, 2, "ORL C, bit"},
    {0x73, 1, "JMP @A+DPTR"},
    {0x74, 2, "MOV A, #immed"},
    {0x75, 3, "MOV direct, #immed"},
    {0x76, 2, "MOV @R0, #immed"},
    {0x77, 2, "MOV @R1, #immed"},
    {0x78, 2, "MOV R0, #immed"},
    {0x79, 2, "MOV R1, #immed"},
    {0x7A, 2, "MOV R2, #immed"},
    {0x7B, 2, "MOV R3, #immed"},
    {0x7C, 2, "MOV R4, #immed"},
    {0x7D, 2, "MOV R5, #immed"},
    {0x7E, 2, "MOV R6, #immed"},
    {0x7F, 2, "MOV R7, #immed"},
    {0x80, 2, "SJMP offset"},
    {0x81, 2, "AJMP addr11"},
    {0x82, 2, "ANL C, bit"},
    {0x83, 1, "MOVC A, @A+PC"},
    {0x84, 1, "DIV AB"},
    {0x85, 3, "MOV direct, direct"},
    {0x86, 2, "MOV direct, @R0"},
    {0x87, 2, "MOV direct, @R1"},
    {0x88, 2, "MOV direct, R0"},
    {0x89, 2, "MOV direct, R1"},
    {0x8A, 2, "MOV direct, R2"},
    {0x8B, 2, "MOV direct, R3"},
    {0x8C, 2, "MOV direct, R4"},
    {0x8D, 2, "MOV direct, R5"},
    {0x8E, 2, "MOV direct, R6"},
    {0x8F, 2, "MOV direct, R7"},
    {0x90, 3, "MOV DPTR, #immed"},
    {0x91, 2, "ACALL addr11"},
    {0x92, 2, "MOV bit, C"},
    {0x93, 1, "MOVC A, @A+DPTR"},
    {0x94, 2, "SUBB A, #immed"},
    {0x95, 2, "SUBB A, direct"},
    {0x96, 1, "SUBB A, @R0"},
    {0x97, 1, "SUBB A, @R1"},
    {0x98, 1, "SUBB A, R0"},
    {0x99, 1, "SUBB A, R1"},
    {0x9A, 1, "SUBB A, R2"},
    {0x9B, 1, "SUBB A, R3"},
    {0x9C, 1, "SUBB A, R4"},
    {0x9D, 1, "SUBB A, R5"},
    {0x9E, 1, "SUBB A, R6"},
    {0x9F, 1, "SUBB A, R7"},
    {0xA0, 2, "ORL C, /bit"},
    {0xA1, 2, "AJMP addr11"},
    {0xA2, 2, "MOV C, bit"},
    {0xA3, 1, "INC DPTR"},
    {0xA4, 1, "MUL AB"},
    {0xA5, 0, "reserved "},
    {0xA6, 2, "MOV @R0, direct"},
    {0xA7, 2, "MOV @R1, direct"},
    {0xA8, 2, "MOV R0, direct"},
    {0xA9, 2, "MOV R1, direct"},
    {0xAA, 2, "MOV R2, direct"},
    {0xAB, 2, "MOV R3, direct"},
    {0xAC, 2, "MOV R4, direct"},
    {0xAD, 2, "MOV R5, direct"},
    {0xAE, 2, "MOV R6, direct"},
    {0xAF, 2, "MOV R7, direct"},
    {0xB0, 2, "ANL C, /bit"},
    {0xB1, 2, "ACALL addr11"},
    {0xB2, 2, "CPL bit"},
    {0xB3, 1, "CPL C"},
    {0xB4, 3, "CJNE A, #immed, offset"},
    {0xB5, 3, "CJNE A, direct, offset"},
    {0xB6, 3, "CJNE @R0, #immed, offset"},
    {0xB7, 3, "CJNE @R1, #immed, offset"},
    {0xB8, 3, "CJNE R0, #immed, offset"},
    {0xB9, 3, "CJNE R1, #immed, offset"},
    {0xBA, 3, "CJNE R2, #immed, offset"},
    {0xBB, 3, "CJNE R3, #immed, offset"},
    {0xBC, 3, "CJNE R4, #immed, offset"},
    {0xBD, 3, "CJNE R5, #immed, offset"},
    {0xBE, 3, "CJNE R6, #immed, offset"},
    {0xBF, 3, "CJNE R7, #immed, offset"},
    {0xC0, 2, "PUSH direct"},
    {0xC1, 2, "AJMP addr11"},
    {0xC2, 2, "CLR bit"},
    {0xC3, 1, "CLR C"},
    {0xC4, 1, "SWAP A"},
    {0xC5, 2, "XCH A, direct"},
    {0xC6, 1, "XCH A, @R0"},
    {0xC7, 1, "XCH A, @R1"},
    {0xC8, 1, "XCH A, R0"},
    {0xC9, 1, "XCH A, R1"},
    {0xCA, 1, "XCH A, R2"},
    {0xCB, 1, "XCH A, R3"},
    {0xCC, 1, "XCH A, R4"},
    {0xCD, 1, "XCH A, R5"},
    {0xCE, 1, "XCH A, R6"},
    {0xCF, 1, "XCH A, R7"},
    {0xD0, 2, "POP direct"},
    {0xD1, 2, "ACALL addr11"},
    {0xD2, 2, "SETB bit"},
    {0xD3, 1, "SETB C"},
    {0xD4, 1, "DA A"},
    {0xD5, 3, "DJNZ direct, offset"},
    {0xD6, 1, "XCHD A, @R0"},
    {0xD7, 1, "XCHD A, @R1"},
    {0xD8, 2, "DJNZ R0, offset"},
    {0xD9, 2, "DJNZ R1, offset"},
    {0xDA, 2, "DJNZ R2, offset"},
    {0xDB, 2, "DJNZ R3, offset"},
    {0xDC, 2, "DJNZ R4, offset"},
    {0xDD, 2, "DJNZ R5, offset"},
    {0xDE, 2, "DJNZ R6, offset"},
    {0xDF, 2, "DJNZ R7, offset"},
    {0xE0, 1, "MOVX A, @DPTR"},
    {0xE1, 2, "AJMP addr11"},
    {0xE2, 1, "MOVX A, @R0"},
    {0xE3, 1, "MOVX A, @R1"},
    {0xE4, 1, "CLR A"},
    {0xE5, 2, "MOV A, direct"},
    {0xE6, 1, "MOV A, @R0"},
    {0xE7, 1, "MOV A, @R1"},
    {0xE8, 1, "MOV A, R0"},
    {0xE9, 1, "MOV A, R1"},
    {0xEA, 1, "MOV A, R2"},
    {0xEB, 1, "MOV A, R3"},
    {0xEC, 1, "MOV A, R4"},
    {0xED, 1, "MOV A, R5"},
    {0xEE, 1, "MOV A, R6"},
    {0xEF, 1, "MOV A, R7"},
    {0xF0, 1, "MOVX @DPTR, A"},
    {0xF1, 2, "ACALL addr11"},
    {0xF2, 1, "MOVX @R0, A"},
    {0xF3, 1, "MOVX @R1, A"},
    {0xF4, 1, "CPL A"},
    {0xF5, 2, "MOV direct, A"},
    {0xF6, 1, "MOV @R0, A"},
    {0xF7, 1, "MOV @R1, A"},
    {0xF8, 1, "MOV R0, A"},
    {0xF9, 1, "MOV R1, A"},
    {0xFA, 1, "MOV R2, A"},
    {0xFB, 1, "MOV R3, A"},
    {0xFC, 1, "MOV R4, A"},
    {0xFD, 1, "MOV R5, A"},
    {0xFE, 1, "MOV R6, A"},
    {0xFF, 1, "MOV R7, A"},
};