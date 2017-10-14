module mult(clk, rst, mult_start, mult_end, A, B, hi, lo, P);

input wire clk, rst, mult_start;
input wire signed [31:0] A, B;
output reg [31:0] hi, lo;
output reg mult_end;

// Helpers
output reg signed [63:0] P;
reg signed [63:0] ADD, SUB;
reg [31:0] mult_control;
reg [4:0] N;
reg diff_bit, do_mult;

initial begin
	N <= 5'd0;
	diff_bit <= 0;
	do_mult <= 0;
	mult_end <= 0;
end

always @(negedge clk) begin
	if (rst) begin
		N <= 5'd0;
		P <= 64'd0;
		diff_bit <= 0;
		mult_end <= 1'b0;
	end
	else if (~do_mult && mult_start) begin

		ADD <= { {32{A[31]}}, {A[31:0]} };
		SUB <= { {32{~A[31]}}, {-A[31:0]} };
		mult_control <= B;
		P <=  64'b0;
		do_mult <= 1'b1;
		mult_end <= 1'b0;

	end
	else if (do_mult) begin
		if (N!=5'd31) begin
			if (diff_bit!=mult_control[0]) begin

				if (diff_bit) begin
					P <= P + (ADD<<N);
				end
				else begin
					P <= P + (SUB<<N);
				end
			end

			diff_bit <= mult_control[0];
			mult_control <= mult_control >> 1;
			N <= N + 5'b1;
		end
		else begin

			if (diff_bit!=mult_control[0]) begin

				if (diff_bit) begin
					{hi,lo} <= P + (ADD<<N);
					P <= P + (ADD<<N);
				end
				else begin
					{hi,lo} <= P + (SUB<<N);
					P <= P + (SUB<<N);
				end
			end
			do_mult <= 1'b0;
			diff_bit <= 1'b0;
			mult_end <= 1'b1;
			N <= 5'b0;
		end
		
	end

end

endmodule