module SignExtend16to32(in, out);
	input wire [15:0] in;
	output wire [31:0] out;
	
	assign out = (in[15] == 1'b1) ? {{16{1'b1}}, {in}} : {{16{1'b0}}, {in}};
endmodule