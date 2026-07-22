#include <stdint.h>
#include <stdio.h>

typedef uint16_t addr;
typedef unsigned char byte;

typedef struct {
    byte *ascii;
    byte binary;
} opdict;

opdict opcode_table[] = {
    {"ADDI", 0x00},
    {"ADDD", 0x02},
    {"ADDP", 0x03},
    {"ADDRD", 0x04},
    {"ADDRP", 0x05},
    {"SUBI", 0x08},
    {"SUBD", 0x0a},
    {"SUBP", 0x0b},
    {"ANDI", 0x10},
    {"ANDD", 0x12},
    {"ANDP", 0x13},
    {"ORI", 0x18},
    {"ORD", 0x1a},
    {"ORP", 0x1b},
    {"XORI", 0x20},
    {"XORD", 0x22},
    {"XORP", 0x23},
    {"CMPI", 0x28},
    {"CMPD", 0x2a},
    {"CMPP", 0x2b},
    {"CMP&", 0x2c},
    {"SLA", 0x30},
    {"SLR", 0x32},
    {"SRA", 0x38},
    {"SRR", 0x3a},
    {"BEQD", 0x40},
    {"BEQ*D", 0x41},
    {"BEQP", 0x42},
    {"BEQ*P", 0x43},
    {"BNED", 0x44},
    {"BNE*D", 0x45},
    {"BNEP", 0x46},
    {"BNE*P", 0x47},
    {"BLTUD", 0x48},
    {"BLTU*D", 0x49},
    {"BLTUP", 0x4a},
    {"BLTU*P", 0x4b},
    {"BGEUD", 0x4c},
    {"BGEU*D", 0x4d},
    {"BGEUP", 0x4e},
    {"BGEU*P", 0x4f},
    {"BLTSD", 0x50},
    {"BLTS*D", 0x51},
    {"BLTSP", 0x52},
    {"BLTS*P", 0x53},
    {"BGESD", 0x54},
    {"BGES*D", 0x55},
    {"BGESP", 0x56},
    {"BGES*P", 0x57},
    {"JMPD", 0x58},
    {"JMP*D", 0x59},
    {"JMPP", 0x5a},
    {"JMP*P", 0x5b},
    {"STRAD", 0x60},
    {"STRAP", 0x61},
    {"LDAD", 0x62},
    {"LDAP", 0x63},
    {"LINKD", 0x64},
    {"LINKP", 0x65},
    {"IMMP", 0x66},
    {"ADDIP", 0x67},
    {"LDPD", 0x6c},
    {"LDPP", 0x6d},
    {"STRPD", 0x6e},
    {"STRPP", 0x6f},
    {"INCAA", 0x70},
    {"INCAR", 0x71},
    {"DECAA", 0x72},
    {"DECAR", 0x73},
    {"IMMA", 0x74},
    {"NOP", 0x75},
    {"INCP", 0x76},
    {"ADDAP", 0x77},
};

int optabsize = 73;

typedef struct {
    byte name[14];
    addr location;
} symbtabentry;

symbtabentry symbtab[256];

addr line = 0;
addr offset = 0x8000;
symbtabentry *symbtabp = symbtab;
opdict *optabp;
char line_buffer[16];

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

int linelen(byte *line) {
    byte *p = line;
    while (*p != '\n' && *p != '\0') {
        p++;
    }
    return p - line;
}

byte bytetobin(byte *p) {
    byte out = 0;
    if (p[0] < 58)
        out += (p[0] - 48) << 4;
    else
        out += (p[0] - 87) << 4;
    if (p[1] < 58)
        out += (p[1] - 48);
    else
        out += (p[1] - 87);
    return out;
}   

addr addrtobin(byte *p) {
    addr out = 0;
    for (int i = 0; i < 4; i++) {
        if (p[i] < 58)
            out += (p[i] - 48) << (12-4*i);
        else
            out += (p[i] - 87) << (12-4*i);
    }
    return out;
}   

int main(int argc, char *argv[]) {
    char *infilename = "test.asm";
    char *outfilename = "test.hex";

    if (argc == 3) {
        infilename = argv[1];
        outfilename = argv[2];
    }

    if (argc == 4) {
        infilename = argv[1];
        outfilename = argv[2];
        offset = addrtobin(argv[3]);
    }

    FILE *infile = fopen(infilename, "r");
    FILE *outfile = fopen(outfilename, "w");
    if (!infile || !outfile) {
        perror("File error");
        return 1;
    }

    //pass 1
    while (fgets(line_buffer, sizeof(line_buffer), infile) != NULL) {
        if (*line_buffer == '$') {
            if (linelen(line_buffer) == 3)
                line++;
            else
                line += 2;
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
        else {
            line++;
        }
    }

    //pass 2
    line = 0;
    rewind(infile);
    for (int i = 0; i < offset; i++)
        fprintf(outfile, "%02X\n", 0);

    while (fgets(line_buffer, sizeof(line_buffer), infile) != NULL) {
        if (*line_buffer == '$') {
            if (linelen(line_buffer) == 3) {
                line++;
                fprintf(outfile, "%02X\n", bytetobin(&(line_buffer[1])));
            }
            else {
                line += 2;
                symbtabp = symbtab;
                int found = 0;
                for (int i = 0; i < 256; i++) {
                    if (stringeq(&(line_buffer[1]),symbtabp->name)) {
                        fprintf(outfile, "%02X\n", (symbtabp->location >> 8) & 0xff);
                        fprintf(outfile, "%02X\n", (symbtabp->location) & 0xff);
                        found = 1;
                        break;
                    }
                    symbtabp++;
                }
                if (!found) {
                    fprintf(outfile, "%02X\n", bytetobin(&(line_buffer[1])));
                    fprintf(outfile, "%02X\n", bytetobin(&(line_buffer[2])));
                }
            }
        }
        else if (*line_buffer == '#' || *line_buffer == '\0' || *line_buffer == '\n') {
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
        else {
            line++;
            optabp = opcode_table;
            for (int i = 0; i < optabsize ; i++) {
                if (stringeq((byte*)line_buffer,optabp->ascii)) {
                    fprintf(outfile, "%02X\n", optabp->binary);
                    break;
                }
                optabp++;
            }
        }
    }

    fclose(infile);
    fclose(outfile);
    return 0;
}