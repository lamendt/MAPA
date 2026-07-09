module register (input logic clk, we,
input logic [7:0] in,
output logic [7:0] out);

always_ff @(posedge clk) begin
	if (we)
		out <= in;
end

endmodule