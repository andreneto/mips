module mux16(in_0, in_1, in_2, in_3, in_4, in_5, in_6, in_7, in_8, in_9, in_10, in_11, in_12, in_13, in_14, in_15, control, out);
	input wire [31:0] in_0, in_1, in_2, in_3, in_4, in_5, in_6, in_7, in_8, in_9, in_10, in_11, in_12, in_13, in_14, in_15;
	input wire [3:0] control;
	output reg [31:0] out;
	
	always@(control) begin
		case(control)
			4'b0000: out = in_0;
			4'b0001: out = in_1;
			4'b0010: out = in_2;
			4'b0011: out = in_3;
			4'b0100: out = in_4;
			4'b0101: out = in_5;
			4'b0110: out = in_6;
			4'b0111: out = in_7;
			4'b1000: out = in_8;
			4'b1001: out = in_9;
			4'b1010: out = in_10;
			4'b1011: out = in_11;
			4'b1100: out = in_12;
			4'b1101: out = in_13;
			4'b1110: out = in_14;
			4'b1111: out = in_15;
		endcase
	end
endmodule	