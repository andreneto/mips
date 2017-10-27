module div(clk, rst, div_start, dividend, divisor, div_end, hi, lo, div_by_zero);

input wire clk, rst, div_start;
input wire signed [31:0] dividend, divisor;
output reg div_end, div_by_zero;
output reg [31:0] hi, lo;

//Helpers
reg signed [63:0] divisor_acc, dividend_acc;
reg signed [31:0] quotient;
reg [4:0] N;
reg do_div, diff_bit;

initial begin
	do_div = 1'b0;
end

always @(posedge clk) begin
	if (rst) begin
		do_div = 1'b0;
	end
	else if (~do_div && div_start) begin

		if (divisor==32'b0) begin //Checking division by zero
			div_by_zero <= 1'b1;
		end else begin
			if (divisor[31]!=dividend[31]) begin //In case of divisor and dividend having opposite signs, invert divisor sign and set diff_bit
				divisor_acc <=  { {~divisor[31]}, {-divisor[31:0]}, {31{1'b0}} };
				diff_bit<=1'b1;
			end
			else begin // If both are positive or negative, do not mess with them
				divisor_acc <=  { {divisor[31]}, {divisor[31:0]}, {31{1'b0}} };	
				diff_bit<=1'b0;
			end

			dividend_acc <=  { {32{dividend[31]}} , {dividend[31:0]} };
			quotient <= 32'd0;
			do_div <= 1'b1;
			div_end <= 1'b0;
			N = 5'd31;
		end
	end
	else if (do_div) begin
		if (N!=0) begin
			if ( (dividend_acc>=divisor_acc && ~divisor_acc[63]) || (dividend_acc<=divisor_acc && divisor_acc[63]) ) begin
				dividend_acc <= dividend_acc - divisor_acc;
				quotient <= (diff_bit) ? quotient - (32'b1 << N) : quotient + (32'b1 << N);
			end

			divisor_acc <= divisor_acc >>> 1;
			N <= N-1;
		end
		else begin

			if ((dividend_acc>=divisor_acc && ~divisor_acc[63]) || (dividend_acc<=divisor_acc && divisor_acc[63])) begin
				hi <= (dividend_acc[31:0] - divisor_acc[31:0]);
				lo <= (diff_bit) ? quotient - (32'b1 << N) : quotient + (32'b1 << N);
			end
			else begin
				hi <= dividend_acc[31:0];
				lo <= quotient;
			end

			div_end <= 1'b1;
			N = 5'd31;
			do_div = 1'b0;
		end
		
	end
	else begin
		div_end <= 1'b0;
		div_by_zero <= 1'b0;
	end
	
end


endmodule