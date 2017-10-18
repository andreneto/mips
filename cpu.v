module cpu(clk, rst);
input wire clk, rst;

//Sinais de 1 bit
wire div_zero, opcode_inex, overflow, mult_ctrl, div_ctrl, ir_write, reg_write, write_mem, epc_write, pc_write, pc_write_cond, hi_ctrl, lo_ctrl, mult_end, div_end;

//Sinais de 2 bits
wire alu_srca, alu_srcb, branch_type, shift_srca, shift_srcb, store_type, load_type;

//Sinais de 3 bits
wire iord, pc_src, alu_op, shift, reg_dst;

//Sinais de 4 bits
wire  mem_to_reg;

controle (
	.clock(clk),  
	.reset(rst), 
	.div_zero(div_zero), 
	.opcode_inex(opcode_inex), 
	.overflow(overflow), 
	.mult_ctrl(mult_ctrl), 
	.div_ctrl(div_ctrl), 
	.ir_write(ir_write), 
	.reg_write(reg_write), 
	.write_mem(write_mem), 
	.epc_write(epc_write), 
	.pc_write(pc_write), 
	.pc_write_cond(pc_write_cond), 
	.hi_ctrl(hi_ctrl), 
	.lo_ctrl(lo_ctrl), 
	.load_type(load_type), 
	.store_type(store_type), 
	.branch_type(branch_type), 
	.alu_srca(alu_srca), 
	.alu_srcb(alu_srcb), 
	.shift_srca(shift_srca), 
	.shift_srcb(shift_srcb), 
	.alu_op(alu_op), 
	.iord(iord), 
	.pc_src(pc_src), 
	.reg_dst(reg_dst), 
	.shift(shift), 
	.mem_to_reg(mem_to_reg),
	.mult_end(mult_end), 
	.div_end(div_end)
	); 

Registrador PC( .clk(clk), .reset(rst), .load(), .entrada(), .saida());
mux8 IorD(.in_0(), .in_1(), .in_2(), .in_3(), .in_4(), .in_5(), .in_6(), .in_7(), .control(), .out());
Memoria Mem(.address(), .clock(), .wr(), .datain(), .dataout());
Extend8to32 ExceptionHandlerAddress( .in(), .out());
Load LoadMem(.mem_data(), .load_type(), .out_data());
Store StoreMem(.MemData(), .B(), .StoreType(), .data());
Registrador MDR( .clk(clk), .reset(rst), .load(), .entrada(), .saida());

Instr_Reg IR(.clk(), .reset(), .load_ir(), .entrada(), .instr31_26(), .instr25_21(), .instr20_16(), .instr15_0());
mux8 RegDst(.in_0(), .in_1(), .in_2(), .in_3(), .in_4(), .in_5(), .in_6(), .in_7(), .control(), .out());
Banco_reg registers(.clk(), .reset(), .regWrite(), .readReg1(), .readReg2(), .writeReg(), .writeData(), .readData1(), .readData2());
mux4 AluSrcA(.in_0(), .in_1(), .in_2(), .in_3(), .control(), .out());
mux4 AluSrcB(.in_0(), .in_1(), .in_2(), .in_3(), .control(), .out());
SignExtend16to32 ExtendImediate(.in(), .out());
ShiftLeft2 BranchAddress(.in(), .out());
Ula32 ALU(.a(), .b(), .seletor(), .s(), .overflow(), .negativo(), .z(), .igual(), .maior(), .menor() );
Extend1to32 SetLessThanBit( .in(), .out());
Registrador ALUout( .clk(clk), .reset(rst), .load(), .entrada(), .saida());
Registrador EPC( .clk(clk), .reset(rst), .load(), .entrada(), .saida());
mux8 PCSrc(.in_0(), .in_1(), .in_2(), .in_3(), .in_4(), .in_5(), .in_6(), .in_7(), .control(), .out());

not NotEqual();
or LessOrEqual();
mux4 BranchType(.in_0(), .in_1(), .in_2(), .in_3(), .control(), .out());
and PCWriteCond();
or PCWrite();

mux16 MemToReg(.in_0(), .in_1(), .in_2(), .in_3(), .in_4(), .in_5(), .in_6(), .in_7(), .in_8(), .in_9(), .in_10(), .in_11(), .in_12(), .in_13(), .in_14(), .in_15(), .control(), .out());
mux4 ShiftSrcA(.in_0(), .in_1(), .in_2(), .in_3(), .control(), .out());
mux4 ShiftSrcB(.in_0(), .in_1(), .in_2(), .in_3(), .control(), .out());
RegDesloc Shift(.clk(), .reset(), .shift(), .n(), .entrada(), .saida());
mult Mult(.clk(), .rst(), .mult_start(), .mult_end(), .A(), .B(), .hi(), .lo());
div Div(.clk(), .rst(), .div_start(), .dividend(), .divisor(), .div_end(), .hi(), .lo(), .div_by_zero());
mux2 HICtrl(.in_0(), .in_1(), .control(), .out());
mux2 LOCtrl(.in_0(), .in_1(), .control(), .out());
Registrador HI( .clk(clk), .reset(rst), .load(), .entrada(), .saida());
Registrador LO( .clk(clk), .reset(rst), .load(), .entrada(), .saida());
endmodule
