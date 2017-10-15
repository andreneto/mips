module Extend8to32(in, out);
	input wire [7:0] in;
	output wire [31:0] out;
	
	assign out = {{24{1'b0}}, {in}};
endmodule