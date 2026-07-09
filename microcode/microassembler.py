ALU_OP = {
    "+": "101001",
    "+C": "001001",
    "-": "000110",
    "&": "011011",
    "|":  "011110",
    "^": "010110",
    "A": "011111",
    "B": "011010",
    "A+1": "000000",
    "A-1": "101111",
    "<": "101100",
    ">": "001111"
}
ALU_A = {
    "A": "00",
    "4": "01",
    "ABlo": "10",
    "ABhi": "11"
}
ALU_B = {
    "ABhi": "00",
    "R": "01",
    "Plo": "10",
    "Phi": "11"
}
DECODER = {
    "R": "000",
    "PClo": "001",
    "PChi": "010",
    "ABlo": "011",
    "ABhi": "100",
    "A": "101",
    "Plo": "110",
    "Phi": "111",
}
CE = {
    "NoCE": "0",
    "CE": "1"
}
RAM_SRC = {
    "PC": "0",
    "AB": "1"
}
FRE = {
    "NoFRE": "0",
    "FRE": "1"
}
LINK = {
    "NoLink": "0",
    "Link": "1"
}
FLAG_SEL = {
    "N": "000",
    "Z": "001",
    "C": "010",
    "V": "011",
    "N^V": "100",
    "Cout": "101"
}
COMMON = {
    "FetchHi": ["000000100101000111110010", 
    "000000100101000111110010"],
    "FetchAll": ["000000100101000111110010", 
    "000000100101000111110010",
    "000000100100110111110011", 
    "000000100100110111110011"],
    "FetchAndAdd": ["000000100101000111110010", 
    "000000100101000111110010",
    "000000100100110111110011", 
    "000000100100110111110011",
    "000101001000111010010100",
    "000101001000111010010100",
    "100111100001001010010101",
    "100111100001000010010101"],
}

import os

BIT_WIDTH = 24

def parse_line_to_bits(tokens, nextstate, flag):
    state = "0000"
    alu = "000000"
    link = "0"
    decode = "000"
    ce = "0"
    ram = "0"
    fren = "0"
    alua = "00"
    alub = "00"
    flagsel = "000"
    
    alu = ALU_OP[tokens[0]]
    decode = DECODER[tokens[1]]
    link = LINK[tokens[2]]
    ce = CE[tokens[3]]
    ram = RAM_SRC[tokens[4]]
    fren = FRE[tokens[5]]
    alua = ALU_A[tokens[6]]
    alub = ALU_B[tokens[7]]
    flagsel = FLAG_SEL[flag]

    combined = flagsel+alub+alua+fren+ram+ce+link+decode+alu+format(nextstate, '04b')

    return combined.rjust(BIT_WIDTH, "0")

def assemble_microcode(input_file, output_bin):

    rom_array = ["0" * BIT_WIDTH] * 8192

    with open(input_file, 'r') as f:
        lines = f.readlines()

    current_opcode = None
    step_counter = 0

    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        if len(line) == 8 and all(c in '01' for c in line):
            man_mode = 0
            current_opcode = line
            bits = "000000000101010111110001"
            addr_str = current_opcode + format(0, '04b')
            rom_idx = int(addr_str + "0", 2)
            rom_array[rom_idx] = bits
            rom_idx = int(addr_str + "1", 2)
            rom_array[rom_idx] = bits
            step_counter = 1
            continue

        if line == "man":
            man_counter = step_counter * 2
            man_mode = 1
            continue

        nextstate = step_counter + 1
            
        if man_mode:
            addr_str = current_opcode + format(man_counter, '05b')
            rom_idx = int(addr_str, 2)
            rom_array[rom_idx] = line
            man_counter += 1
            continue

        if line.startswith("end "):
            nextstate = 0
            line = line.replace("end ", "", 1).strip()
            
        if current_opcode:
            if line.startswith("if ") or line.startswith("else "):
                parts = line.split(":", 1)
                flag = parts[0].split(" ", 1)[1]
                tokens = [t.strip() for t in parts[1].split(",")]
                bits = parse_line_to_bits(tokens, nextstate, flag)
                if line.startswith("if "):
                    addr_str = current_opcode + format(step_counter, '04b') + "1"
                else:
                    addr_str = current_opcode + format(step_counter, '04b') + "0"
                    step_counter += 1
                rom_idx = int(addr_str, 2)
                rom_array[rom_idx] = bits
            elif line in COMMON:
                linecount = 0
                for l in COMMON.get(line):
                    addr_str = current_opcode + format(step_counter, '04b') + format(linecount%2)
                    rom_idx = int(addr_str, 2)
                    rom_array[rom_idx] = l
                    rom_idx = int(addr_str, 2)
                    rom_array[rom_idx] = l
                    if linecount%2 == 1:
                        step_counter += 1
                    linecount += 1
            else:
                tokens = [t.strip() for t in line.split(",")]
                bits = parse_line_to_bits(tokens, nextstate, "N")
                
                addr_str = current_opcode + format(step_counter, '04b')
                rom_idx = int(addr_str + "0", 2)
                rom_array[rom_idx] = bits
                rom_idx = int(addr_str + "1", 2)
                rom_array[rom_idx] = bits
                step_counter += 1

    with open(output_bin, "w") as f_out:
        for bit_str in rom_array:
            f_out.write(f"{bit_str}\n")

if __name__ == "__main__":
    assemble_microcode("microcode/microcode.txt", "microcode/microcode.bin")