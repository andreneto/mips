module Store(MemData, B, StoreType, data);
	input wire [1:0] StoreType;
	input wire [31:0] B;
	input wire [31:0] MemData;
	
	output wire [31:0] data;
	
	assign data = (StoreType == 2'd0)?{MemData[31:8], B[7:0],}: //Byte
		(StoreType == 2'd1)?{MemData[31:16], B[15:0]}: //Half
		(StoreType == 2'd2)?{B}://Word
		(StoreType == 2'd3);//nada
endmodule
