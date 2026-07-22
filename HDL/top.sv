module top(input logic MAX10_CLK1_50, input logic [9:0] SW, output logic [9:0] LEDR);

logic clk, rst;
logic [7:0] switch, led;
assign clk = MAX10_CLK1_50;
assign rst = SW[9];
assign switch = SW[7:0];
assign LEDR = {2'b0, led};

logic ovf, RAMen, leden;
logic [3:0] flags;
logic [7:0] RAMout, BOOTout, MEMout, ALUa, ALUb, ALUout, A, stateout, FRout, OpOut, delaysin, delaysout;
logic [12:0] LUTin;
logic [15:0] addr, MEMaddr, PC, decodeout, P;
logic [23:0] LUTout;

register statereg(clk, rst, 1, LUTout[3:0], stateout);
register opcodereg(clk, rst, stateout == 0, MEMout, OpOut);
register ABlo(clk, rst, decodeout[3], ALUout, addr[7:0]);
register ABhi(clk, rst, decodeout[4], ALUout, addr[15:8]);
register Plo(clk, rst, decodeout[6], ALUout, P[7:0]);
register Phi(clk, rst, decodeout[7], ALUout, P[15:8]);
register Acc(clk, rst, decodeout[5], ALUout, A);
register FR(clk, rst, LUTout[16], flags, FRout);
count PClo(clk, rst, decodeout[1], ALUout, PC[7:0], LUTout[14], ovf);
count PChi(clk, rst, decodeout[2], ALUout, PC[15:8], ovf);
alu ALU(LUTout[9],LUTout[8],LUTout[7:4],ALUa,ALUb,ALUout,flags);
ram RAM(~clk, RAMen,ALUout,RAMout,MEMaddr);
lut LUT(clk, LUTout,LUTin);
flash BOOT(~clk, BOOTout,MEMaddr);
decoder dec(LUTout[12:10], decodeout);
register coutdelay(clk, rst, 1, delaysin, delaysout);
register ledreg(clk, rst, leden, ALUout, led);

always_comb begin
	case(LUTout[15])
		1'b0: MEMaddr = PC;
		1'b1: MEMaddr = addr;
		default: MEMaddr = 0;
	endcase
	
	RAMen = 0;
	leden = 0;
	MEMout = 0;
	casez(MEMaddr[15:13])
		3'b000:
			MEMout = BOOTout;
		3'b001: begin
			case(MEMaddr[12:0])
				13'h0000:
					MEMout = switch;
				13'h0001:
					leden = decodeout[0];
			endcase
		end
		3'b010: begin
			MEMout = RAMout;
			if (decodeout[0] && !PC[15])
				RAMen = 1;
			else
				RAMen = 0;
		end
		default: begin
			MEMout = RAMout;
			RAMen = decodeout[0];
		end
	endcase
	
	delaysin = 0;
	delaysin[0] = flags[2];
	if (!LUTout[13]) begin	
		case(LUTout[18:17])
			2'b00: ALUa = A;
			2'b01: ALUa = 0;
			2'b10: ALUa = addr[7:0];
			2'b11: ALUa = addr[15:8];
			default: ALUa = 0;
		endcase
		case(LUTout[20:19])
			2'b00: ALUb = addr[15:8];
			2'b01: ALUb = MEMout;
			2'b10: ALUb = P[7:0];
			2'b11: ALUb = P[15:8];
			default: ALUb = 0;
		endcase
	end
	else begin
		case(LUTout[18:17])
			2'b00: ALUa = PC[7:0];
			2'b01: ALUa = PC[15:8];
			default: ALUa = 0;
		endcase
		ALUb = 8'b00000011;
	end
	case(LUTout[23:21])
		3'b000: LUTin[0] = FRout[0];
		3'b001: LUTin[0] = FRout[1];
		3'b010: LUTin[0] = FRout[2];
		3'b011: LUTin[0] = FRout[3];
		3'b100: LUTin[0] = FRout[0] ^ FRout[3];
		3'b101: LUTin[0] = delaysout[0];
		default: LUTin[0] = 0;
	endcase
	LUTin[12:5] = OpOut;
	LUTin[4:1] = stateout;
end

endmodule

module register(input logic clk, rst, we,
input logic [7:0] in,
output logic [7:0] out);

always_ff @(posedge clk) begin
	if (rst)
		out <= 0;
	else if (we)
		out <= in;
end

endmodule

module count(input logic clk, rst, we,
input logic [7:0] in,
output logic [7:0] out,
input logic ce,
output logic ovf);

always_ff @(posedge clk) begin
	if (rst) begin
		out <= 0;
		ovf <= 0;
	end
	else if (we) begin
		out <= in;
		ovf <= 0;
	end
	else if (ce) begin
		out <= out + 1;
		if (out == 8'b11111111)
			ovf <= 1;
		else
			ovf <= 0;
	end
end

endmodule

module alu(input logic cin, mode,
input logic [3:0] s,
input logic [7:0] a, b,
output logic [8:0] out,
output logic [3:0] flags);

always_comb begin
		casez({cin, mode, s})
			6'b101001: out = a+b;
			6'b001001: out = a+b+1;
			6'b000110: out = a-b;
			6'b?11011: out = a & b;
			6'b?11110: out = a | b;
			6'b?10110: out = a ^ b;
			6'b?11111: out = a;
			6'b?11010: out = b;
			6'b000000: out = a+1;
			6'b101111: out = a-1;
			6'b101100: out = a << 1;
			6'b001111: out = a >>> 1;
			default: out = 0;
	endcase
		flags[0] = out[7];
		flags[1] = out[7:0] == 0;
		if ({cin, mode, s} == 6'b000110)
			flags[2] = ~out[8];
		else
			flags[2] = out[8];
		flags[3] = (a[7] != b[7]) && (out[7] == b[7]);
end

endmodule

module ram(input logic clk, we,
input logic [7:0] in,
output logic [7:0] out,
input logic [15:0] addr);

(* ramstyle = "M10K" *) logic [7:0] RAM [65535:0];
initial begin
    $readmemh("../testcode/SWtoLED.hex", RAM);
end

//assign out = RAM[addr];

always_ff @(posedge clk) begin
	if (we)
		RAM[addr] <= in;
	out <= RAM[addr];
end

endmodule

module lut(input logic clk,
output logic [23:0] out,
input logic [12:0] addr);

(* ramstyle = "M10K" *) logic [23:0] LUT [8191:0];
initial begin
    $readmemb("../microcode/microcode.bin", LUT);
end

assign out = LUT[addr];

endmodule

module flash(input logic clk,
output logic [7:0] out,
input logic [15:0] addr);

(* ramstyle = "M10K" *) logic [7:0] BOOT [8191:0];
initial begin
    $readmemh("../boot/boot.hex", BOOT);
end

always_ff @(posedge clk)
	out <= BOOT[addr];

endmodule

module decoder(input logic [2:0] in,
output logic [15:0] out);

always_comb begin
	out = 16'h0001 << in;
end

endmodule