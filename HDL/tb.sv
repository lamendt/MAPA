module tb;
    logic clk = 0;
	 logic rst = 0;
    always #1 clk = ~clk;
		
    top dut (clk, rst);
	 
	 initial begin
		rst = 1;
		#4;
		rst = 0;
		#100;
	 end
endmodule