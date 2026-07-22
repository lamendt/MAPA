module tb;
    logic clk = 0;
	 logic [9:0] switch = 0;
	 logic [9:0] led;
    always #1 clk = ~clk;
		
    top dut (clk, switch, led);
	 
	 initial begin
		switch[9] = 1;
		#3;
		switch[9] = 0;
		#200;
		switch[7:0] = 8'b10101010;
		#200;
		switch[7:0] = 0;
		#200;
	 end
endmodule