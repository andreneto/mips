module mux8(in_0, in_1, in_2, in_3, in_4, in_5, in_6, in_7, control, out);
	input wire [31:0] in_0, in_1, in_2, in_3, in_4, in_5, in_6, in_7;
	input wire [2:0] control;
	output reg [31:0] out;
	
	always@(control) begin
		case(control)
			3'b000: out = in_0;
			3'b001: out = in_1;
			3'b010: out = in_2;
			3'b011: out = in_3;
			3'b100: out = in_4;
			3'b101: out = in_5;
			3'b110: out = in_6;
			3'b111: out = in_7;
		endcase
	end
endmodule	