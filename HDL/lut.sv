module lut (input logic clk,
output logic [23:0] out,
input logic [12:0] addr);

(* ramstyle = "M10K" *) logic [73:0] LUT [4095:0];

always_ff @(posedge clk) begin

		out <= RAM[addr];
end

endmodule