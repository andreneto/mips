module mux2(in_0, in_1, control, out);
	input wire [31:0] in_0, in_1;
	input wire control;
	output reg [31:0] out;
	
	always@(control) begin
		case(control)
			0: out = in_0;
			1: out = in_1;
		endcase
	end
endmodule	