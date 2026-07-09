module alu (input logic cin, mode
input logic [3:0] s,
input logic [7:0] a, b
output logic [8:0] out,
output logic [3:0] flags);

always_comb begin
	casez({s, mode, cin})
		6'b100101: out = a+b;
		6'b011000: out = a-b;
		6'b10111?: out = a & b;
		6'b11101?: out = a | b;
		6'b01101?: out = a ^ b;
		6'b11111?: out = a;
		6'b10101?: out = b;
		6'b000000: out = a+1;
		6'b111101: out = a-1;
		6'b110001: out = a << 1;
		6'b111100: out = a >>> 1;
		default: out = 0;
	endcase
		flags[7:4] == 4'b0000;
		flags[0] = out[7];
		flags[1] = out[7:0] == 0;
		flags[2] = out[8];
		flags[3] = (a[7] != b[7]) && (out[7] == b[7]);
end

endmodule