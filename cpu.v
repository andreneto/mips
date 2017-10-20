module cpu(out_IR_15_0,out_SignExtend16to32, clk, rst, next_state, out_PCSrc, out_PC, out_Mem, out_AluSrcA, out_AluSrcB, out_ALU, div_zero, overflow, mult_ctrl, div_ctrl, ir_write, reg_write, write_mem, epc_write, pc_write, pc_write_cond, hi_ctrl, lo_ctrl, mult_end, div_end, alu_srca, alu_srcb, branch_type, shift_srca, shift_srcb, store_type, load_type, out_IR_31_26 );
input wire clk, rst;


//Sinais de 1 bit
wire div_zero, overflow, mult_ctrl, div_ctrl, ir_write, reg_write, write_mem, epc_write, pc_write, pc_write_cond, hi_ctrl, lo_ctrl, mult_end, div_end;

//Sinais de 2 bits
wire [1:0] alu_srca, alu_srcb, branch_type, shift_srca, shift_srcb, store_type, load_type;

//Sinais de 3 bits
wire [2:0] iord, pc_src, alu_op, shift, reg_dst;

//Sinais de 4 bits
wire [3:0] mem_to_reg;

// Fios de 1 bit
wire out_PCWrite, out_PCWriteCond;


//Fios da ISA
wire [5:0] out_IR_31_26; //opcode
wire [4:0] out_IR_25_21; // rs
wire [4:0] out_IR_20_16; // rt

wire [15:0] out_IR_15_0; //imediate
wire [4:0] out_IR_15_11; // rd
wire [4:0] out_IR_10_6; // shamt
wire [5:0] out_IR_5_0; // funct

// Fios de 1 bit
wire outZero_ALU, outGT_ALU, outLT_ALU, outET_ALU, outOVF_ALU,
out_BranchType;

//Fio de 5 bits
wire [4:0] out_RegDst, out_ShiftSrcB;

//Fios de 32 bits
wire [31:0] out_PCSrc, out_PC, out_IorD, out_Mem, out_Extend8to32, 
out_LoadMem, out_StoreMem, out_MDR, outA_RegBank, outB_RegBank, 
out_JumpAddress, out_AluSrcA, out_AluSrcB, out_SignExtend16to32, 
out_BranchAddress, out_ALU, out_SetLessThanBit, out_ALUout, out_EPC, 
out_MemToReg, out_ShiftSrcA, out_Shifter, outHi_Mult, outLo_Mult, 
outHi_Div, outLo_Div, out_HICtrl, out_LOCtrl, out_HI, out_LO;

//Exceptions
parameter OPCODE_INEX_HANDLER = 32'd253;
parameter OPCODE_INEX_CODE = 32'd1;

parameter OVERFLOW_HANDLER = 32'd254;
parameter OVERFLOW_CODE = 32'd2;

parameter DIV_ZERO_HANDLER = 32'd255;
parameter DIV_ZERO_CODE = 32'd3;

// Misc
parameter REG_31 = 5'd31;
parameter REG_30 = 5'd30;
parameter REG_29 = 5'd29;
parameter STACK_TOP_ADDRESS = 32'd227;
parameter NULL = 0;

// Debug

output wire [5:0] next_state;

output wire [31:0] out_PCSrc, out_PC, out_Mem, out_AluSrcA, out_AluSrcB, out_ALU, out_SignExtend16to32;
output wire div_zero, overflow, mult_ctrl, div_ctrl, ir_write, reg_write, write_mem, epc_write, pc_write, pc_write_cond, hi_ctrl, lo_ctrl, mult_end, div_end;
output wire [1:0] alu_srca, alu_srcb, branch_type, shift_srca, shift_srcb, store_type, load_type;
output wire [5:0] out_IR_31_26;
output wire [15:0] out_IR_15_0;



controle (
	.clock(clk),  
	.reset(rst),
	.opcode(out_IR_31_26),
	.funct(out_IR_15_0[5:0]),
	.next_state(next_state),
	.div_zero(div_zero), 
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


Registrador PC( .clk(clk), .reset(rst), .load(out_PCWrite), .entrada(out_PCSrc), .saida(out_PC));
mux8 IorD(.in_0(out_PC), .in_1(outA_RegBank), .in_2(OPCODE_INEX_HANDLER), .in_3(OVERFLOW_HANDLER), .in_4(DIV_ZERO_HANDLER), .in_5(out_ALUout), .in_6(0), .in_7(0), .control(iord), .out(out_IorD));
Memoria Mem(.address(out_IorD), .clock(clk), .wr(write_mem), .datain(out_StoreMem), .dataout(out_Mem));
Extend8to32 ExceptionHandlerAddress(.in(out_Mem), .out(out_Extend8to32));
Load LoadMem(.mem_data(out_Mem), .load_type(load_type), .out_data(out_LoadMem));
Store StoreMem(.MemData(out_Mem), .B(outB_RegBank), .StoreType(store_type), .data(out_StoreMem));
Registrador MDR( .clk(clk), .reset(rst), .load(clk), .entrada(out_LoadMem), .saida(out_MDR));

Instr_Reg IR(.clk(clk), .reset(rst), .load_ir(ir_write), .entrada(out_Mem), .instr31_26(out_IR_31_26), .instr25_21(out_IR_25_21), .instr20_16(out_IR_20_16), .instr15_0(out_IR_15_0));
mux8 RegDst(.in_0(out_IR_20_16), .in_1(out_IR_15_0[15:11]), .in_2(REG_31), .in_3(REG_30), .in_4(REG_29), .in_5(0), .in_6(0), .in_7(0), .control(reg_dst), .out(out_RegDst));
Banco_reg RegBank(.clk(clk), .reset(rst), .regWrite(reg_write), .readReg1(out_IR_25_21), .readReg2(out_IR_20_16), .writeReg(out_RegDst), .writeData(out_MemToReg), .readData1(outA_RegBank), .readData2(outB_RegBank));
//Extend26to28 JumpAddress(.in(), .out(out_JumpAddress));
mux4 AluSrcA(.in_0(out_PC), .in_1(outA_RegBank), .in_2(out_MDR), .in_3(0), .control(alu_srca), .out(out_AluSrcA));
mux4 AluSrcB(.in_0(outB_RegBank), .in_1(32'd4), .in_2(out_SignExtend16to32), .in_3(out_BranchAddress), .control(alu_srcb), .out(out_AluSrcB));
SignExtend16to32 ExtendImediate(.in(out_IR_15_0), .out(out_SignExtend16to32));
ShiftLeft2 BranchAddress(.in(out_SignExtend16to32), .out(out_BranchAddress));
Ula32 ALU(.a(out_AluSrcA), .b(out_AluSrcB), .seletor(alu_op), .s(out_ALU), .overflow(overflow), .negativo(0), .z(outZero_ALU), .igual(outET_ALU), .maior(outGT_ALU), .menor(outLT_ALU) );
Extend1to32 SetLessThanBit( .in(outLT_ALU), .out(out_SetLessThanBit));
Registrador ALUout( .clk(clk), .reset(rst), .load(clk), .entrada(out_ALU), .saida(out_ALUout));
Registrador EPC( .clk(clk), .reset(rst), .load(epc_write), .entrada(out_ALU), .saida(out_EPC));
mux8 PCSrc(.in_0(out_Extend8to32), .in_1(out_ALU), .in_2(out_EPC), .in_3(out_ALUout), .in_4(outA_RegBank), .in_5(out_JumpAddress), .in_6(0), .in_7(0), .control(pc_src), .out(out_PCSrc));

not NotEqual(out_NotEqual, outZero_ALU);
or LessOrEqual(out_LessOrEqual, outLT_ALU, outET_ALU);
mux4 BranchType(.in_0(out_LessOrEqual), .in_1(outGT_ALU), .in_2(outZero_ALU), .in_3(out_NotEqual), .control(branch_type), .out(out_BranchType));
and PCWriteCond(out_PCWriteCond, out_BranchType, pc_write_cond);
or PCWrite(out_PCWrite, pc_write, out_PCWriteCond);

mux16 MemToReg(.in_0(out_ALUout), .in_1(out_MDR), .in_2(out_PC), .in_3(out_SetLessThanBit), .in_4(out_HI), .in_5(out_LO), .in_6(STACK_TOP_ADDRESS), .in_7(OPCODE_INEX_CODE), .in_8(OVERFLOW_CODE), .in_9(DIV_ZERO_CODE), .in_10(out_Shifter), .in_11(0), .in_12(0), .in_13(0), .in_14(0), .in_15(0), .control(mem_to_reg), .out(out_MemToReg));
mux4 ShiftSrcA(.in_0(outA_RegBank), .in_1(outB_RegBank), .in_2(out_SignExtend16to32), .in_3(0), .control(shift_srca), .out(out_ShiftSrcA));
mux4 ShiftSrcB(.in_0(out_IR_15_0[10:6]), .in_1(outB_RegBank[4:0]), .in_2(5'd16), .in_3(0), .control(shift_srcb), .out(out_ShiftSrcB));
RegDesloc Shifter(.clk(clk), .reset(rst), .shift(shift), .n(out_ShiftSrcB), .entrada(out_ShiftSrcA), .saida(out_Shifter));
mult Mult(.clk(clk), .rst(rst), .mult_start(mult_ctrl), .mult_end(mult_end), .A(outA_RegBank), .B(outB_RegBank), .hi(outHi_Mult), .lo(outLo_Mult));
div Div(.clk(clk), .rst(rst), .div_start(div_ctrl), .dividend(outA_RegBank), .divisor(outB_RegBank), .div_end(div_end), .hi(outHi_Div), .lo(outLo_Div), .div_by_zero(div_zero));
mux2 HICtrl(.in_0(outHi_Mult), .in_1(outHi_Div), .control(hi_ctrl), .out(out_HICtrl));
mux2 LOCtrl(.in_0(outLo_Mult), .in_1(outLo_Div), .control(lo_ctrl), .out(out_LOCtrl));
Registrador HI( .clk(clk), .reset(rst), .load(clk), .entrada(out_HICtrl), .saida(out_HI));
Registrador LO( .clk(clk), .reset(rst), .load(clk), .entrada(out_LOCtrl), .saida(out_LO));
endmodule
