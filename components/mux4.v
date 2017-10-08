module mux4(in_0, in_1, in_2, in_3, control, out);
	input wire [31:0] in_0, in_1, in_2, in_3;
	input wire [1:0] control;
	output reg [31:0] out;
	
	always@(control) begin
		case(control)
			2'b00: out = in_0;
			2'b01: out = in_1;
			2'b10: out = in_2;
			2'b11: out = in_3;
		endcase
	end
endmodule	