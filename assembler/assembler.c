#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef uint16_t addr;
typedef unsigned char byte;

typedef struct {
    byte *ascii;
    byte argSize;
    byte binary;
} opdict;

opdict opcode_table[] = {
    {"ADDI", 1, 0x00},
    {"ADD", 2, 0x02},
    {"ADDO", 1, 0x03},
    {"ADS", 2, 0x04},
    {"ADSO", 1, 0x05},
    {"SUBI", 1, 0x08},
    {"SUB", 2, 0x0a},
    {"SUBO", 1, 0x0b},
    {"ANDI", 1, 0x10},
    {"AND", 2, 0x12},
    {"ANDO", 1, 0x13},
    {"ORI", 1, 0x18},
    {"OR", 2, 0x1a},
    {"ORO", 1, 0x1b},
    {"XORI", 1, 0x20},
    {"XOR", 2, 0x22},
    {"XORO", 1, 0x23},
    {"CMPI", 1, 0x28},
    {"CMP", 2, 0x2a},
    {"CMPO", 1, 0x2b},
    {"CMP&I", 1, 0x2c},
    {"SLI",  0, 0x30},
    {"SL", 2, 0x32},
    {"SLO", 1, 0x33},
    {"SRI", 0, 0x38},
    {"SR", 2, 0x3a},
    {"SRO", 1, 0x3b},
    {"BEQ", 2, 0x40},
    {"BEQI", 2, 0x42},
    //{"BEQP", 1, 0x41},
    //{"BEQ*P", 0x43},
    {"BNE", 2, 0x44},
    {"BNEI", 2, 0x46},
    //{"BNEP", 0x45},
    //{"BNE*P", 0x47},
    {"BLTU", 2, 0x48},
    {"BLTUI", 2, 0x4a},
    //{"BLTUP", 0x49},
    //{"BLTU*P", 0x4b},
    {"BGEU", 2, 0x4c},
    {"BGEUI", 2, 0x4e},
    //{"BGEUP", 0x4d},
    //{"BGEU*P", 0x4f},
    {"BLTS", 2, 0x50},
    {"BLTSI", 2, 0x52},
    //{"BLTSP", 0x51},
    //{"BLTS*P", 0x53},
    {"BGES", 2, 0x54},
    {"BGESI", 2, 0x56},
    //{"BGESP", 0x55},
    //{"BGES*P", 0x57},
    {"JMP", 2, 0x58},
    {"JMPI", 2, 0x5a},
    //{"JMPP", 0x59},
    //{"JMP*P", 0x5b},
    {"BAZ", 2, 0x5c},
    {"BAZI", 2, 0x5d},
    {"BANZ", 2, 0x5e},
    {"BANZI", 2, 0x5f},
    {"STR", 2, 0x60},
    {"STRO", 1, 0x61},
    {"LD", 2, 0x62},
    {"LDO", 1, 0x63},
    {"LINK", 2, 0x64},
    {"LINKO", 1, 0x65},
    {"IMMP", 2, 0x68},
    {"ADDIP", 2, 0x69},
    {"LDP", 2, 0x6c},
    {"LDPO", 1, 0x6d},
    {"STRP", 2, 0x6e},
    //{"STRPP", 0x6f},
    {"INCI", 0, 0x70},
    {"INC", 2, 0x72},
    {"INCO", 1, 0x73},
    {"DECI", 0, 0x75},
    {"DEC", 2, 0x76},
    {"DECO", 1, 0x77},
    {"IMM", 1, 0x78},
    {"NOP", 0, 0x79},
    {"INCP", 0, 0x7a},
    {"ADDAP", 0, 0x7b},
    {"RET", 0, 0x7c},
    {"CALL", 2, 0x7d},
    {"CALLI", 2, 0x7e},
    {"PCURD", 2, 0x7f},
    {"ADCI", 1, 0x80},
    {"ADC", 2, 0x82},
    {"ADCO", 1, 0x83},
    {"ACS", 2, 0x84},
    {"ACSO", 1, 0x85},
    {"SLCI", 0, 0xb0},
    {"SLC", 2, 0xb2},
    {"SLCO", 1, 0xb3},
    {"ICCI", 0, 0xf0},
    {"ICC", 2, 0xf2},
    {"ICCO", 1, 0xf3},
    {"DCCI", 0, 0xf5},
    {"DCC", 2, 0xf6},
    {"DCCO", 1, 0xf7},
};

int optabsize = 84;

typedef struct {
    byte name[14];
    addr location;
} symbtabentry;

symbtabentry symbtab[256];

addr line = 0;
addr inLine = 0;
addr offset = 0x8000;
symbtabentry *symbtabp = symbtab;
opdict *optabp;
char line_buffer[256];

int stringeq(byte *str1, byte *str2) {
    while (*str1 == *str2 && !(*str1 == ' ' || *str1 == '\n' || *str1 == '\0') && !(*str2 == ' ' || *str2 == '\n' || *str2 == '\0')) {
        str1++;
        str2++;
    }
    if ((*str1 == ' ' || *str1 == '\n' || *str1 == '\0') && (*str2 == ' ' || *str2 == '\n' || *str2 == '\0'))
        return 1;
    return 0;
}

int memocpy(byte *p1, byte *p2) {
    while ((*p1 != ' ' && *p1 != '\n' && *p1 != '\0')) {
        *p2 = *p1;
        p1++;
        p2++;
    }
    *p2 = *p1;
    return 0;
}

int wordLen(byte *line) {
    byte *p = line;
    while (*p != '\n' && *p != '\0' && *p != ' ') {
        p++;
    }
    return p - line;
}

byte bytetobin(byte *p) {
    byte out = 0;
    if (p[0] < 58)
        out += (p[0] - 48) << 4;
    else
        out += (p[0] - 55) << 4;
    if (p[1] < 58)
        out += (p[1] - 48);
    else
        out += (p[1] - 55);
    return out;
}   

addr addrtobin(byte *p) {
    addr out = 0;
    for (int i = 0; i < 4; i++) {
        if (p[i] < 58)
            out += (p[i] - 48) << (12-4*i);
        else
            out += (p[i] - 55) << (12-4*i);
    }
    return out;
}   

int main(int argc, char *argv[]) {
    char *infilenames[4] = {};
    
    infilenames[0] = "../testcode/keyTest.s";
    char *outfilename = "../testcode/keyTest.hex";

    if (argc == 3) {
        infilenames[0] = argv[1];
        outfilename = argv[2];
    }

    if (argc == 4) {
        infilenames[0] = argv[1];
        outfilename = argv[2];
        if (argv[3] == 'b')
            offset = 0x0000;
        else if (argv[3] == 'k')
            offset = 0x4000;
        else
            offset = 0x8000;
    }

    FILE *outfile = fopen(outfilename, "w");
    if (!outfile) {
        perror("File error");
        return 1;
    }

    FILE *infile;
    for (int filenum = 0; infilenames[filenum] != NULL; filenum++) {
        infile = fopen(infilenames[filenum], "r");
        if (!infile) {
            perror("File error");
            return 1;
        }

        inLine = 0;
        //pass 1
        while (fgets(line_buffer, sizeof(line_buffer), infile) != NULL) {
            inLine++;
            if (*line_buffer == '$') {
                if (wordLen(line_buffer) == 3)
                    line++;
                else
                    line += 2;
            }
            else if (*line_buffer == '@') {
                line += 2;
            }
            else if (*line_buffer == '.') {
                memocpy((byte*)line_buffer + 1, (byte*)symbtabp);
                int i = 0;
                while (line_buffer[i] != ' ') {
                    i++;
                }
                i += 1;
                symbtabp->location = addrtobin(&(line_buffer[i+1]));
                symbtabp++;
            }
            else if (*line_buffer == '&') {
                infilenames[filenum + 1] = malloc(wordLen(line_buffer) - 1);
                memocpy((byte*)line_buffer + 1, infilenames[filenum + 1]);
                infilenames[filenum + 1][wordLen(line_buffer) - 1] = '\0';
            }
            else if (*line_buffer == '#' || *line_buffer == '\0' || *line_buffer == '\n') {
                continue;
            }
            else if (*line_buffer == ':') {
                memocpy((byte*)line_buffer + 1, (byte*)symbtabp);
                symbtabp->location = line + offset;
                symbtabp++;
            }
            else if (*line_buffer == '+') {
                line += addrtobin(&(line_buffer[1]));
            }
            else if (*line_buffer == '"') {
                int i = 1;
                while (line_buffer[i] != '"') {
                    if (line_buffer[i] == '\\')
                        i++;
                    i++;
                    line++;
                }
                line++;
            }
            else {
                optabp = opcode_table;
                int found = 0;
                for (int i = 0; i < optabsize; i++) {
                    if (stringeq((byte*)line_buffer,optabp->ascii)) {
                        found = 1;
                        break;
                    }
                    optabp++;
                }
                if (!found) {
                    printf("Invalid opcode: line %d", inLine);
                    return -1;
                }
                line += optabp->argSize + 1;
            }
        }
        fclose(infile);
    }

    //pass 2
    for (int filenum = 0; infilenames[filenum] != NULL; filenum++) {
        infile = fopen(infilenames[filenum], "r");
        if (!infile) {
            perror("File error");
            return 1;
        }

        inLine = 0;

        while (fgets(line_buffer, sizeof(line_buffer), infile) != NULL) {
            inLine++;
            if (*line_buffer == '$') {
                if (wordLen(line_buffer) == 3) {
                    line++;
                    fprintf(outfile, "%02X\n", bytetobin(&(line_buffer[1])));
                }
                else if (wordLen(line_buffer) == 5) {
                    line += 2;
                    fprintf(outfile, "%02X\n", bytetobin(&(line_buffer[3])));
                    fprintf(outfile, "%02X\n", bytetobin(&(line_buffer[1])));
                }
                else {
                    printf("Invalid arg: line %d", inLine);
                    return -1;
                }
            }
            else if (*line_buffer == '@') {
                line += 2;
                symbtabp = symbtab;
                int found = 0;
                for (int i = 0; i < 256; i++) {
                    if (stringeq(&(line_buffer[1]),symbtabp->name)) {
                        fprintf(outfile, "%02X\n", (symbtabp->location) & 0xff);
                        fprintf(outfile, "%02X\n", (symbtabp->location >> 8) & 0xff);
                        found = 1;
                        break;
                    }
                    symbtabp++;
                }
                if (!found) {
                    printf("Symbol not found: line %d", inLine);
                    return -1;
                }
            }
            else if (*line_buffer == '#' || *line_buffer == '\0' || *line_buffer == '\n' || *line_buffer == '.' || *line_buffer == '&') {
                continue;
            }
            else if (*line_buffer == ':') {
                continue;
            }
            else if (*line_buffer == '+') {
                addr size = addrtobin(&(line_buffer[1]));
                line += size;
                for (addr i = 0; i < size; i++)
                    fprintf(outfile, "%02X\n", 0x00);
            }
            else if (*line_buffer == '"') {
                int i = 1;
                while (line_buffer[i] != '"') {
                    if (line_buffer[i] == '\\') {
                        i++;
                        switch (line_buffer[i]) {
                            case '\\':
                                fprintf(outfile, "%02X\n", '\\');
                                break;
                            case '\"':
                                fprintf(outfile, "%02X\n", '\"');
                                break;
                            case '\n':
                                fprintf(outfile, "%02X\n", '\n');
                                break;
                            case '\0':
                                fprintf(outfile, "%02X\n", '\0');
                                break;
                            default:
                                printf("Illegal string: line %d", inLine);
                                return -1;
                                break;
                        }
                    }
                    else {
                        fprintf(outfile, "%02X\n", line_buffer[i]);
                    }
                    i++;
                    line++;
                }
                fprintf(outfile, "%02X\n", '\0');
                line++;
            }
            else {
                optabp = opcode_table;
                for (int i = 0; i < optabsize ; i++) {
                    if (stringeq((byte*)line_buffer,optabp->ascii)) {
                        break;
                    }
                    optabp++;
                }
                fprintf(outfile, "%02X\n", optabp->binary);
                if (optabp->argSize != 0) {
                    int i = 0;
                    while (line_buffer[i] != ' ') {
                        i++;
                    }
                    i += 1;
                    if (line_buffer[i] == '$') {
                        if (wordLen(&(line_buffer[i])) == 3) {
                            if (optabp->argSize != 1) {
                                printf("Invalid arg: line %d", inLine);
                                return -1;
                            }
                            fprintf(outfile, "%02X\n", bytetobin(&(line_buffer[i+1])));
                        }
                        else if (wordLen(&(line_buffer[i])) == 5) {
                            if (optabp->argSize != 2) {
                                printf("Invalid arg: line %d", inLine);
                                return -1;
                            }
                            fprintf(outfile, "%02X\n", bytetobin(&(line_buffer[i+3])));
                            fprintf(outfile, "%02X\n", bytetobin(&(line_buffer[i+1])));
                        }
                        else {
                            printf("Invalid arg: line %d", inLine);
                            return -1;
                        }
                    }
                    else {
                        if (optabp->argSize != 2 && optabp->argSize != 1) {
                            printf("Invalid arg: line %d", inLine);
                            return -1;
                        }

                        addr byteIsHi = 0;
                        if (line_buffer[i] == '^') {
                            byteIsHi = 1;
                            i++;
                        }
                        
                        symbtabp = symbtab;
                        int found = 0;
                        addr symbLoc = 0;
                        for (int j = 0; j < 256; j++) {
                            if (stringeq(&(line_buffer[i]),symbtabp->name)) {
                                symbLoc = symbtabp->location;
                                found = 1;
                                break;
                            }
                            symbtabp++;
                        }
                        if (!found) {
                            printf("Symbol not found: line %d", inLine);
                            return -1;
                        }

                        while (line_buffer[i] != ' ' && line_buffer[i] != '\n') {
                            i++;
                        }
                        if (line_buffer[i] == ' ') {
                            i += 1;
                            symbLoc += addrtobin(&(line_buffer[i]));
                        }

                        if (optabp->argSize == 2) {
                            fprintf(outfile, "%02X\n", (symbLoc) & 0xff);
                            fprintf(outfile, "%02X\n", (symbLoc >> 8) & 0xff);
                        }

                        if (optabp->argSize == 1) {
                            if (byteIsHi)
                                fprintf(outfile, "%02X\n", (symbLoc >> 8) & 0xff);
                            else
                                fprintf(outfile, "%02X\n", (symbLoc) & 0xff);
                        }
                    }
                }
                line += optabp->argSize + 1;
            }
        }
        fclose(infile);
    }
    fclose(outfile);
    return 0;
}