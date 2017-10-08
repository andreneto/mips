module mux2(in_1, in_2, control, out);
	input wire [31:0] in_1, in_2;
	input wire control;
	output reg [31:0] out;
	
	always@(control) begin
		case(control)
			0: out = in_1;
			1: out = in_2;
		endcase
	end
endmodule	