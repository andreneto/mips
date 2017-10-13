module controle (clock, reset, div_zero, opcode_inex, overflow, mult_ctrl, div_ctrl, ir_write, reg_write, write_mem, epc_write, pc_write, pc_write_cond, hi_ctrl, lo_ctrl, load_type, store_type, branch_type, alu_srca, alu_srcb, shift_srca, shift_srcb, alu_op, iord, pc_src, reg_dst, shift, mem_to_reg, mult_end, div_end);
		
		input wire [0:0] clock, reset, div_zero, opcode_inex, overflow;
		input wire [5:0] opcode;
		input reg [0:0] mult_end, div_end;
		
		output wire [0:0] mult_ctrl, div_ctrl, ir_write, reg_write, write_mem, epc_write, pc_write, pc_write_cond, hi_ctrl, lo_ctrl;
		output wire [1:0] load_type, store_type, branch_type, alu_srca, alu_srcb, shift_srca, shift_srcb, alu_op;
		output wire [2:0] iord, pc_src, reg_dst, shift;
		output wire [3:0] mem_to_reg;
		
		reg [5:0] state
		reg [5:0] next_state
		reg [5:0] funct
		
		//OPCODE
		parameter R = 6'b000000		
		parameter ADDI = 6'b001000
		parameter ADDIU = 6'b001001
		parameter BEQ = 6'b000100
		parameter BNE = 6'b000101
		parameter BLE = 6'b000110
		parameter BGT = 6'b000111
		parameter BEQM = 6'b000001
		parameter LB = 6'b100000
		parameter LH = 6'b100001
		parameter LUI = 6'b001111
		parameter LW = 6'b100011
		parameter SB = 6'b101000
		parameter SH = 6'b101001
		parameter SLTI = 6'b001010
		parameter SW = 6'b101011
		parameter J = 6'b000010
		parameter JAL = 6'b000011
		
		//FUNCT
		parameter ADD = 6'b100000
		parameter AND = 6'b100100
		parameter DIV = 6'b011010
		parameter MULT = 6'b011000
		parameter JR = 6'b001000
		parameter MFHI = 6'b010000
		parameter MFLO = 6'b010010
		parameter SLL = 6'b000000
		parameter SLLV = 6'b000100
		parameter SLT = 6'b101010
		parameter SRA = 6'b000011
		parameter SRAV = 6'b000111
		parameter SRL = 6'b000010
		parameter SUB = 6'b100010
		parameter BREAK = 6'b001101
		parameter RTE = 6'b010011
		
		parameter RESET = 6'b111111
		parameter FETCH = 6'b
		parameter BRANCH = 6'b 
		parameter ALU_EXECUTE = 6'b
		parameter IMEDIATE_END = 
		parameter DIV_2 =
		parameter MULT_2 =
		parameter SHIFT_INIT =
		parameter SHIFT_END = 
		parameter SLT_2 =
		
		case (state)
		    //instrucoes do tipo R 
			R: case (funct)
				ADD: 
					alu_srca = 2'b01;
					alu_srcb = 2'b00;
				    alu_op = 3'b001;
			        next_state = ALU_EXECUTE;
					 
				ALU_EXECUTE: 
					mem_to_reg = 4'b0000;
				    reg_write = 1'b1;
					reg_dst = 3'b001;
					next_state = FETCH;
							 
				AND: 
					alu_srca = 2'b01;
				    alu_srcb = 2'b00;
					alu_op = 3'b011;
					next_state = ALU_EXECUTE;
					 
				SUB: 
					alu_srca = 2'b01;
				    alu_srcb = 2'b00; 
					alu_op = 3'b010;
					next_state = ALU_EXECUTE;
				
				DIV: 
					div_ctrl = 1'b1;
					//verificar se esta correto
					if (div_end == 1'b1) begin
						next_state = DIV_2;
					end else begin 
						next_state = DIV;
						
				DIV_2: 
					hi_ctrl = 1'b1;
					lo_ctrl = 1'b1;
					next_state = FETCH;
				
				MULT: 
					mult_ctrl = 1'b1;
					//verificar se esta correto
					if (mult_end == 1'b1) begin
						next_state = MULT_2;
					end else begin
						next_state = MULT;
						
				MULT_2:
					hi_ctrl = 1'b0;
					lo_ctrl = 1'b0;
					next_state = FETCH;
						
				MFHI: 
					reg_dst = 3'b001;
					mem_to_reg = 4'b0100;
					reg_write = 1'b1;
					next_state = FETCH;
					
				MFLO:
					reg_dst = 3'b001;
					mem_to_reg = 4'b0101;
					next_state = FETCH;
					
				JR:
					pc_src =3'b100;
					pc_write = 1'b1;
					next_state = FETCH;
					
				BREAK: 
					alu_srca = 2'b00;
					alu_srcb = 2'b01;
					alu_op = 3'b010;
					pc_src = 3'b001;
					pc_write = 1'b1;
					next_state = FETCH;
					
				RTE:
					pc_src = 3'b010;
					pc_write = 1'b1;
					next_state = FETCH;
					
				SHIFT_INIT:
					shift = 3'b001;
					//?????
					
				SLL:
					shift_srca = 2'b01;
					shift_srcb = 2'b00;
					shift = 3'b010;
					next_state = SHIFT_END;
				
				SLLV:
					shift_srca = 2'b00;
					shift_srcb = 2'b01;
					shift = 3'b010;
					next_state = SHIFT_END;
				
				SRA:
					shift_srca = 2'b01;
					shift_srcb = 2'b00;
					shift = 3'b100;
					next_state = SHIFT_END;
					
				SRAV:
					shift_srca = 2'b00;
					shift_srcb = 2'b01;
					shift = 3'b100;
					next_state = SHIFT_END;
					
				SRL:
					shift_srca = 2'b01;
					shift_srcb = 2'b00;
					shift = 3'b011;
					next_state = SHIFT_END;
					 
				SHIFT_END:
					mem_to_reg = 4'b1010;
					reg_dst = 2'b01;
					reg_write = 1'b1;
					next_state = FETCH;
					
				SLT:
					alu_srca = 2'b01;
					alu_srcb = 2'b00;
					alu_op = 3'b111;
					next_state = SLT_2;
				
				SLT_2:
					mem_to_reg = 4'b0011;
					reg_dst = 2'b01;
					reg_write = 1'b1;
					next_state = FETCH;
				
				endcase
				
			ADDI:
				alu_srca = 2'b01;
				alu_srcb = 2'b10;
				alu_op = 3'b001;
				next_state = IMEDIATE_END;
				
			ADDIU:
				alu_srca = 2'b01;
				alu_srcb = 2'b10;
				alu_op = 3'b001;
				next_state = IMEDIATE_END;
				
			LUI:
				shift_srca = 2'b10;
				shift_srcb = 2'b10;
				shift = 3'b010;
				next_state = IMEDIATE_END;
			
			SLTI:
				alu_srca = 2'b01;
				alu_srcb = 2'b10;
				alu_op = 3'b111;
				next_state = SLTI_2;
			
			
			
			
			
			
			
			