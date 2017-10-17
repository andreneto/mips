module load(mem_data, load_type, out_data);

  input wire [1:0] load_type;
  input reg [31:0] mem_data;
  output reg [31:0] out_data;

  assign out_data = (load_type == 2'b00)? {mem_data[31:24], 24'b0} : ((load_type == 2'b01)? {mem_data[31:16], 16'b0} : ((load_type == 2'b10)? mem_data : ((load_type == 2'b11)? 32'b0 : 32'b0))));

endmodule
