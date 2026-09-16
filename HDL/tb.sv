module tb;
    logic clk = 0;
	 logic switch = 0;
	 logic PCMSB;
    always #1 clk = ~clk;
		
    top dut (clk, switch, PCMSB);
	 
	 initial begin
		switch = 0;
		#20;
		switch = 1;
		#200;
	 end
endmodule