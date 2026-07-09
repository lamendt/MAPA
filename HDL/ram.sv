module ram (input logic clk, we,
input logic [7:0] in,
output logic [7:0] out,
input logic [15:0] addr);

(* ramstyle = "M10K" *) logic [7:0] RAM [1023:0];

always_ff @(posedge clk) begin
	if (we) begin
		RAM[addr] <= in;
		out <= in;
	end
	
	else
		out <= RAM[addr];
end

endmodule