module SignExtend16to32(in, out);
	input wire [15:0] in;
	output reg [31:0] out;
	
	assign out = in >> 16;
endmodule