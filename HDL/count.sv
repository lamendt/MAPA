module count (input logic clk, we,
input logic [7:0] in,
output logic [7:0] out,
input logic ce
output logic ovf);

always_ff @(posedge clk) begin
	if (we) begin
		out <= in;
		ovf <= 0;
	end
	if (ce) begin
		out <= out + 1;
		if (out == 0)
			ovf <= 1;
		else
			ovf <= 0;
	end
end

endmodule