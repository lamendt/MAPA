module simclocks (input logic inclock, output logic clk, invclk, VGAclk);

logic [3:0] clkcnt = 0;
assign invclk = ~clk;

always_ff @(posedge inclock) begin
	if (clkcnt[0])
		VGAclk <= 0;
	else
		VGAclk <= 1;
	if (clkcnt == 4'h9) begin
		clkcnt <= 0;
		clk <= 0;
	end
	else begin
		clkcnt <= clkcnt + 1;
		if (clkcnt == 4'h4)
			clk <= 1;
	end
end

endmodule