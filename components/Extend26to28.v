module Extend26to28(in, out);
	input wire [25:0] in;
	output wire [27:0] out;
	
	assign out = {{2{1'b0}}, {in}};
endmodule