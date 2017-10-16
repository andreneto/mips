module Store(MemData, B, StoreType, data);
	input [1:0]StoreType;
	input [31:0] B;
	input [31:0] MemData;
	
	output [31:0] data;
	
	assign data = (StoreType == 2'd0)?{B[31:24],MemData[23:0]}: //Byte
		(StoreType == 2'd1)?{B[31:16],MemData[15:0]}: //Half
		(StoreType == 2'd2)?{B}://Word
		(StoreType == 2'd3);//nada
endmodule
