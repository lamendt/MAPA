module PCU(input logic clk, input logic rst, input logic we, input logic [7:0] din, input logic [7:0] dout, input logic [7:0] addr, 
output logic [3:0] VGA_R, VGA_G, VGA_B, output logic VGA_HS, VGA_VS, inout wire [35:0] GPIO, input logic VGAclk);

VGA VGAcontroller(clk, rst, we, addr, din, dout, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGAclk);
PS2 PS2controller();
SD SDcontroller();

always_comb begin
	
end

endmodule

module VGA(input logic clk, input logic rst, input logic we, input logic [7:0] addr, input logic [7:0] din, input logic [7:0] dout, 
output logic [3:0] VGA_R, VGA_G, VGA_B, output logic VGA_HS, VGA_VS, input logic VGAclk);

logic [9:0] h_pos, v_pos;
logic [15:0] raddr, waddr;
logic [7:0] bin, bout;
logic ben;
buffer buffer(clk, ben, bin, bout, raddr, waddr, VGAclk);
logic [1:0] state = 0;
logic [7:0] color, x;

assign bin = color;

always_comb begin
	waddr = x+{din,8'h00};
	raddr = 16'(((h_pos + 1) >> 1) - 32) + {v_pos[8:1],8'h00};
end
always_ff @(posedge clk) begin
	if (we) begin
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

module PS2();

endmodule

module SD();

endmodule