module decoder (input logic [3:0] in,
output logic [15:0] out);

always_comb begin
	out = 16'h0001 << in;
end

endmodule