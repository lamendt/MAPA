module PCU(input logic clk, input logic rst, input logic we, input logic [7:0] din, output logic [7:0] dout, input logic [7:0] addr, 
output logic [3:0] VGA_R, VGA_G, VGA_B, output logic VGA_HS, VGA_VS, inout wire [35:0] GPIO, input logic VGAclk, input logic SPIclk);

logic [7:0] VGAout, PS2out, SDout;
logic VGAen, PS2en, SDen;

VGA VGAcontroller(clk, rst, VGAen, din, VGAout, addr, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGAclk);
PS2 PS2controller(clk, rst, PS2en, PS2out, GPIO);
SD SDcontroller(clk, rst, SDen, din, SDout, addr, GPIO, VGAclk);

always_comb begin
	VGAen = 0;
	PS2en = 0;
	SDen = 0;
	dout = 0;
	casez(addr[2:0])
		3'b00?: begin
			dout = VGAout;
			VGAen = we;
		end
		3'b01?: begin
			dout = PS2out;
			PS2en = we;
		end
		3'b10?: begin
			dout = SDout;
			SDen = we;
		end
	endcase
end

endmodule

module VGA(input logic clk, input logic rst, input logic we, input logic [7:0] din, output logic [7:0] dout, input logic [7:0] addr,
output logic [3:0] VGA_R, VGA_G, VGA_B, output logic VGA_HS, VGA_VS, input logic VGAclk);

logic [9:0] h_pos = 0;
logic [9:0] v_pos = 0;
logic [15:0] raddr, waddr;
logic [7:0] bin, bout;
logic ben;
buffer buffer(clk, ben, bin, bout, raddr, waddr, VGAclk);
logic [1:0] state = 0;
logic [7:0] color, x;
logic [7:0] flags = 0;

assign bin = color;
assign dout = flags;

always_comb begin
	waddr = x+{din,8'h00};
	raddr = 16'(((h_pos + 1) >> 1) - 32) + {v_pos[8:1],8'h00};
end
always_ff @(posedge clk) begin
	if (we && addr[0] == 0) begin
		ben <= (state == 2'b10);
		case(state)
			2'b00: begin
				state <= 2'b01;
				color <= din;
			end
			2'b01: begin
				state <= 2'b10;
				x <= din;
			end
			2'b10: begin
				state <= 2'b00;
			end
			default:
				state <= 0;
		endcase
	end
	else
		ben <= 0;
end

always_ff @(posedge VGAclk) begin
	if (h_pos >= 64 && h_pos < 576 && v_pos < 480) begin
		VGA_R <= {bout[7:5], bout[7]};
		VGA_G <= {bout[4:2], bout[4]};
		VGA_B <= {bout[1:0], bout[1:0]};
	end
	else begin
		VGA_R <= 0;
		VGA_G <= 0;
		VGA_B <= 0;
	end
	
	if (h_pos < 799)
			h_pos <= h_pos + 1;
	else begin
		h_pos <= 0;
		if (v_pos < 524)
			v_pos <= v_pos + 1;
		else
			v_pos <= 0;
	end
	
	
	if (h_pos >= 656 && h_pos < 752)
		VGA_HS <= 0;
	else
		VGA_HS <= 1;
	
	if (v_pos >= 490 && v_pos < 492)
		VGA_VS <= 0;
	else
		VGA_VS <= 1;
		
	if (v_pos == 490 && h_pos == 0)
		flags <= flags + 1;
	else if (addr[0] == 1 && we)
		flags <= din;
end

endmodule

module buffer(input logic clk, we,
input logic [7:0] in,
output logic [7:0] out,
input logic [15:0] raddr,
input logic [15:0] waddr,
input logic VGAclk);

(* ramstyle = "M10K" *) logic [7:0] RAM [61439:0] = '{default: 8'h00};

always_ff @(posedge clk) begin
	if (we)
		RAM[waddr] <= in;
end

always_ff @(posedge VGAclk)
	out <= RAM[raddr];

endmodule

module PS2(input logic clk, input logic rst, input logic we, output logic [7:0] dout, inout wire [35:0] GPIO);

assign PS2clk = GPIO[25];
assign PS2data = GPIO[24];
logic clkSync, dataSync, clkSync2, dataSync2;
logic [4:0] state = 0;
logic [7:0] inByte;
logic [7:0] queuedKeys [15:0];
logic [4:0] head, tail;

always_ff @(posedge clk) begin
	clkSync2 <= PS2clk;
	dataSync2 <= PS2data;
	clkSync <= clkSync2;
	dataSync <= dataSync2;
	if (clkSync && !clkSync2) begin
		casez(state)
		4'b0000: begin
			if (dataSync)
				state <= 0;
			else
				state <= 4'b1000;
		end
		4'b1???: begin
			inByte <= {dataSync, inByte[7:1]};
			if (state == 4'b1111)
				state <= 4'b0001;
			else
				state <= state + 1;
		end
		4'b0001: begin
			queuedKeys[tail] <= inByte;
			tail <= tail + 1;
			state <= 4'b0010;
		end
		default:
			state <= 0;
	endcase
	end
	if (we) begin
		if (head != tail) begin
			dout <= queuedKeys[head];
			head <= head + 1;
		end
		else begin
			dout <= 0;
		end
	end
end

endmodule

module SD(input logic clk, input logic rst, input logic we, input logic [7:0] din, output logic [7:0] dout, input logic [7:0] addr, 
inout wire [35:0] GPIO, input logic SPIclk);

logic CS, MOSI, CLKout, MISO;
logic risen, fallen;
logic clken = 0;
logic init = 1;
logic [7:0] inByte, outByte;
logic [6:0] clkcnt = 0;
logic weff;
logic GPIO28, GPIO27;

logic [3:0] bitc = 0;
logic [7:0] flags = 0;

assign GPIO[29:27] = {CS, GPIO28, GPIO27};
assign MISO = GPIO[26];
assign CS = ~flags[0];

always_comb begin
	if (addr[0])
		dout = flags;
	else
		dout = inByte;
	if (clken || !flags[0])
		GPIO27 = CLKout;
	else
		GPIO27 = 0;
	if (flags[0] && clken)
		GPIO28 = MOSI;
	else
		GPIO28 = 1;
end

always_ff @(posedge SPIclk) begin
	weff <= we;
	if (flags[1]) begin
		/*if (clkcnt == 0) begin
			clkcnt <= 1;
			risen <= 1;
			fallen <= 0;
			CLKout <= 1;
		end
		else begin
			clkcnt <= 0;
			fallen <= 1;
			risen <= 0;
			CLKout <= 0;
		end*/
		if (clkcnt == 0) begin
			risen <= 0;
			CLKout <= 1;
		end
		else if (clkcnt == 7'h03) begin
			fallen <= 1;
		end
		else if (clkcnt == 7'h04) begin
			fallen <= 0;
			CLKout <= 0;
		end
		else if (clkcnt == 7'h07) begin
			risen <= 1;
		end
		else begin
			fallen <= 0;
			risen <= 0;
		end
		if (clkcnt == 7'h0f)
				clkcnt <= 0;
		else
				clkcnt <= clkcnt + 1;
	end
	else begin
		if (clkcnt == 0) begin
			clkcnt <= 1;
			risen <= 1;
			fallen <= 0;
			CLKout <= 1;
		end
		else if (clkcnt == 7'h39) begin
			clkcnt <= clkcnt + 1;
			fallen <= 1;
			risen <= 0;
			CLKout <= 0;
		end
		else begin
			clkcnt <= clkcnt + 1;
			fallen <= 0;
			risen <= 0;
		end
	end
	if (we && !weff)
		if (addr[0]) begin
			flags <= din;
			clken <= 0;
			bitc <= 4'h9;
		end
		else begin
			bitc <= 0;
			outByte <= din;
			clken <= 0;
		end
	else begin
		if (bitc == 4'h0 && fallen)
			clken <= 1;
		else if (bitc == 4'h8 && fallen)
			clken <= 0;
		if (risen)
			inByte[8 - bitc] <= MISO;
		if (fallen) begin
			if (bitc < 4'h8)
				MOSI <= outByte[7 - bitc];
			else
				MOSI <= 1;
			if (bitc != 4'h9)
				bitc <= bitc + 1;
		end
	end
end

endmodule