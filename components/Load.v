module Load(mem_data, load_type, out_data);

  input wire [1:0] load_type;
  input wire [31:0] mem_data;
  output wire [31:0] out_data;

  assign out_data = (load_type == 2'b00) ? { {24{mem_data[7]}} , mem_data[7:0] } : ((load_type == 2'b01)? { {16{mem_data[15]}} , mem_data[15:0] } : ((load_type == 2'b10)? mem_data : ((load_type == 2'b11)? 32'b0 : 32'b0)));

endmodule
