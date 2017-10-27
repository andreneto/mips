module controle (next_state, clock, reset, div_zero, overflow, mult_ctrl, div_ctrl, ir_write, reg_write, alu_out_write, write_mem, epc_write, pc_write, pc_write_cond, hi_ctrl, lo_ctrl, load_type, store_type, branch_type, alu_srca, alu_srcb, shift_srca, shift_srcb, alu_op, iord, pc_src, reg_dst, shift, mem_to_reg, mult_end, div_end, funct, opcode);

  input wire clock;
  input wire reset;
  input wire div_zero;
  input wire overflow;
  input wire mult_end;
  input wire div_end;

  input wire [5:0] funct;
  input wire [5:0] opcode;

  output reg mult_ctrl;
  output reg div_ctrl;
  output reg ir_write;
  output reg reg_write;
  output reg alu_out_write;
  output reg write_mem;
  output reg epc_write;
  output reg pc_write;
  output reg pc_write_cond;
  output reg hi_ctrl;
  output reg lo_ctrl;

  output reg [1:0] load_type;
  output reg [1:0] store_type;
  output reg [1:0] branch_type;
  output reg [1:0] alu_srca;
  output reg [1:0] alu_srcb;
  output reg [1:0] shift_srca;
  output reg [1:0] shift_srcb;

  output reg [2:0] alu_op;
  output reg [2:0] iord;
  output reg [2:0] pc_src;
  output reg [2:0] reg_dst;
  output reg [2:0] shift;

  output reg [3:0] mem_to_reg;

  reg opcode_inex;
  reg [5:0] wait_counter;
  output reg [5:0] next_state;

  //next_state
  parameter RESET = 6'h0;
  parameter FETCH = 6'h1;
  parameter FETCH_WAIT = 6'h2;
  parameter DECODE = 6'h4;

  parameter ADD = 6'h5;
  parameter AND = 6'h6;
  parameter DIV = 6'h7;
  parameter MULT = 6'h8;
  parameter JR = 6'h9;
  parameter MFHI = 6'hA;
  parameter MFLO = 6'hB;
  parameter SLL = 6'hC;
  parameter SLLV = 6'hD;
  parameter SLT = 6'hE;
  parameter SRA = 6'hF;
  parameter SRAV = 6'h10;
  parameter SRL = 6'h11;
  parameter SUB = 6'h12;
  parameter BREAK = 6'h13;
  parameter RTE = 6'h14;

  parameter ADDI = 6'h15;
  parameter ADDIU = 6'h16;
  parameter BEQ = 6'h17;
  parameter BNE = 6'h18;
  parameter BLE = 6'h19;
  parameter BGT = 6'h1A;
  parameter BEQM = 6'h1B;
  parameter LB = 6'h1C;
  parameter LH = 6'h1D;
  parameter LUI = 6'h1E;
  parameter LW = 6'h1F;
  parameter SB = 6'h20;
  parameter SH = 6'h21;
  parameter SLTI = 6'h22;
  parameter SW = 6'h23;
  parameter J = 6'h24;
  parameter JAL = 6'h25;

  parameter ALU_EXECUTE = 6'h26;
  parameter IMEDIATE_END = 6'h27;
  parameter DIV_WAIT = 6'h28;
  parameter DIV_END = 6'h29;
  parameter MULT_WAIT = 6'h2A;
  parameter MULT_END = 6'h2B;
  parameter SHIFT_END = 6'h2C;
  parameter SLT_2 = 6'h2D;
  parameter SLTI_2 = 6'h2E;
  parameter BEQM_WAIT = 6'h2F;
  parameter BEQM_END = 6'h30;
  parameter LOAD_WAIT = 6'h31;
  parameter LOAD_END = 6'h32;
  parameter STORE_WAIT = 6'h33;
  parameter EXCEPTION = 6'h34;
  parameter OVERFLOW = 6'h35;
  parameter DIV_ZERO = 6'h36;
  parameter OPCODE_INEX = 6'h37;
  parameter EXCEPTION_WAIT = 6'h38;
  parameter EXCEPTION_END = 6'h39;
  parameter SHIFT_INIT = 6'h3A;
  parameter LOAD_STORE_INIT = 6'h3B;
  parameter LOAD_BEFORE_STORE = 6'h3C;
  parameter LOAD_BEFORE_STORE_WAIT = 6'h3D;
  parameter LUI_END = 6'h3E;

  //OPCODE
  parameter OPCODE_R = 6'h0;
  parameter OPCODE_ADDI = 6'h8;
  parameter OPCODE_ADDIU = 6'h9;
  parameter OPCODE_BEQ = 6'h4;
  parameter OPCODE_BNE = 6'h5;
  parameter OPCODE_BLE = 6'h6;
  parameter OPCODE_BGT = 6'h7;
  parameter OPCODE_BEQM = 6'h1;
  parameter OPCODE_LB = 6'h20;
  parameter OPCODE_LH = 6'h21;
  parameter OPCODE_LUI = 6'hf;
  parameter OPCODE_LW = 6'h23;
  parameter OPCODE_SB = 6'h28;
  parameter OPCODE_SH = 6'h29;
  parameter OPCODE_SLTI = 6'ha;
  parameter OPCODE_SW = 6'h2b;
  parameter OPCODE_J = 6'h2;
  parameter OPCODE_JAL = 6'h3;

  //FUNCT
  parameter FUNCT_ADD = 6'h20;
  parameter FUNCT_AND = 6'h24;
  parameter FUNCT_DIV = 6'h1a;
  parameter FUNCT_MULT = 6'h18;
  parameter FUNCT_JR = 6'h8;
  parameter FUNCT_MFHI = 6'h10;
  parameter FUNCT_MFLO = 6'h12;
  parameter FUNCT_SLL = 6'h0;
  parameter FUNCT_SLLV = 6'h4;
  parameter FUNCT_SLT = 6'h2a;
  parameter FUNCT_SRA = 6'h3;
  parameter FUNCT_SRAV = 6'h7;
  parameter FUNCT_SRL = 6'h2;
  parameter FUNCT_SUB = 6'h22;
  parameter FUNCT_BREAK = 6'hd;
  parameter FUNCT_RTE = 6'h13;

  always @ (posedge clock)
    begin: control
      if (reset == 1'b1) begin
        iord <= 1'b0;
        write_mem <= 1'b0;
        ir_write <= 1'b0;
        alu_srca <= 2'b00;
        alu_srcb <= 2'b00;
        alu_op <= 3'b000;
        pc_src <= 3'b001;

        pc_write <= 1'b0;
        mult_ctrl <= 1'b0;
        div_ctrl <= 1'b0;
        reg_write <= 1'b0;
        epc_write <= 1'b0;
        pc_write_cond <= 1'b0;
        hi_ctrl <= 1'b0;
        lo_ctrl <= 1'b0;
        load_type <= 2'b0;
        store_type <= 2'b0;
        branch_type <= 2'b0;
        shift_srca <= 2'b0;
        shift_srcb <= 2'b0;
        reg_dst <= 3'b0;
        shift <= 3'b0;
        mem_to_reg <= 4'b0;
        alu_out_write <=1'b0;
        
        reg_dst <= 3'b100;
        mem_to_reg <= 4'b0110;
        reg_write <= 1'b1;
        next_state <= FETCH;
      end
      else if (overflow == 1'b1 || div_zero == 1'b1) begin
        next_state <= EXCEPTION;
      end 
      else begin
         case (next_state)

        FETCH: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b01;
          alu_op <= 3'b001;
          pc_src <= 3'b001;
          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b1;
          next_state <= FETCH_WAIT;
        end

        FETCH_WAIT: begin
          pc_write <= 1'b0;
          reg_write <= 1'b0;
          ir_write <= 1'b0;
          alu_out_write <=1'b0;
          
          if(wait_counter==6'd2)begin
            wait_counter=6'd0;
            next_state <= DECODE;
          end 
          else if (wait_counter==6'd1) begin
            ir_write <= 1'b1;
            pc_write <= 1'b1;
            wait_counter <= wait_counter +1;
          end
          else begin
            wait_counter <= wait_counter + 1;
          end  
        end

        DECODE: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          alu_srca <= 2'b00;
          alu_srcb <= 2'b11;
          alu_op <= 3'b001;
          alu_out_write <=1'b1;
          
          case (opcode)
            //R type instructions opcode
            OPCODE_R: begin
              case (funct)
                FUNCT_ADD: begin
                  next_state <= ADD;
                end

                FUNCT_AND: begin
                  next_state <= AND;
                end

                FUNCT_SUB: begin
                  next_state <= SUB;
                end

                FUNCT_DIV: begin
                  next_state <= DIV;
                end

                FUNCT_MULT: begin
                  next_state <= MULT;
                end

                FUNCT_MFHI: begin
                  next_state <= MFHI;
                end

                FUNCT_MFLO: begin
                  next_state <= MFLO;
                end

                FUNCT_JR: begin
                  next_state <= JR;
                end

                FUNCT_BREAK: begin
                  next_state <= BREAK;
                end

                FUNCT_RTE: begin
                  next_state <= RTE;
                end

                FUNCT_SLL: begin
                  shift_srca <= 2'b01;
                  shift_srcb <= 2'b00;
                  shift <= 001;
                  next_state <= SHIFT_INIT;
                end

                FUNCT_SLLV: begin
                  shift_srca <= 2'b00;
                  shift_srcb <= 2'b01;
                  shift <= 001;
                  next_state <= SHIFT_INIT;
                end

                FUNCT_SRA: begin
                  next_state <= SHIFT_INIT;
                  shift_srca <= 2'b01;
                  shift_srcb <= 2'b00;
                  shift <= 001;
                end

                FUNCT_SRAV: begin
                  shift_srca <= 2'b00;
                  shift_srcb <= 2'b01;
                  shift <= 001;
                  next_state <= SHIFT_INIT;
                end

                FUNCT_SRL: begin
                  shift_srca <= 2'b01;
                  shift_srcb <= 2'b00;
                  shift <= 001;
                  next_state <= SHIFT_INIT;
                end

                FUNCT_SLT: begin
                  next_state <= SLT;
                end

                default: begin
                  opcode_inex <= 1'b1;
                  next_state <= EXCEPTION;
                end

              endcase
            end

            // I type instructions opcode
            OPCODE_ADDI: begin
              next_state <= ADDI;
            end

            OPCODE_ADDIU: begin
              next_state <= ADDIU;
            end

            OPCODE_LUI: begin
              shift_srca <= 2'b10;
              shift_srcb <= 2'b10;
              shift <= 001;
              next_state <= SHIFT_INIT;
            end

            OPCODE_SLTI: begin
              next_state <= SLTI;
            end

            OPCODE_BEQ: begin
              next_state <= BEQ;
            end

            OPCODE_BNE: begin
              next_state <= BNE;
            end

            OPCODE_BLE: begin
              next_state <= BLE;
            end

            OPCODE_BGT: begin
              next_state <= BGT;
            end

            OPCODE_BEQM: begin
              next_state <= BEQM;
            end

            OPCODE_LB: begin
              next_state <= LOAD_STORE_INIT;
            end

            OPCODE_LH: begin
              next_state <= LOAD_STORE_INIT;
            end

            OPCODE_LW: begin
              next_state <= LOAD_STORE_INIT;
            end

            OPCODE_SB: begin
              next_state <= LOAD_STORE_INIT;
            end

            OPCODE_SH: begin
              next_state <= LOAD_STORE_INIT;
            end

            OPCODE_SW: begin
              next_state <= LOAD_STORE_INIT;
            end

            //J type instructions opcode
            OPCODE_J: begin
              next_state <= J;
            end

            OPCODE_JAL: begin
              next_state <= JAL;
            end

            default: begin
              opcode_inex <= 1'b1;
              next_state <= EXCEPTION;
            end

          endcase
        end

        // R type instructions execute
        ADD: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          alu_srca <= 2'b01;
          alu_srcb <= 2'b00;
          alu_op <= 3'b001;
          alu_out_write <=1'b1;
          next_state <= ALU_EXECUTE;
        end

        AND: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;


          alu_srca <= 2'b01;
          alu_srcb <= 2'b00;
          alu_op <= 3'b011;
          alu_out_write <=1'b1;
          next_state <= ALU_EXECUTE;
        end

        SUB: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          alu_srca <= 2'b01;
          alu_srcb <= 2'b00;
          alu_op <= 3'b010;
          alu_out_write <=1'b1;
          next_state <= ALU_EXECUTE;
        end

        ALU_EXECUTE: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          mem_to_reg <= 4'b0000;
          reg_write <= 1'b1;
          reg_dst <= 3'b001;
          next_state <= FETCH;
        end

        DIV: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          div_ctrl <= 1'b1;
          next_state <= DIV_WAIT;
        end

        DIV_WAIT: begin
          div_ctrl <= 1'b0;
          hi_ctrl <= 1'b1;
          lo_ctrl <= 1'b1;
          if (div_end == 1'b1) begin
            next_state <= DIV_END;
          end else begin
            next_state <= DIV_WAIT;
          end
        end

        DIV_END: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          hi_ctrl <= 1'b1;
          lo_ctrl <= 1'b1;
          next_state <= FETCH;
        end

        MULT: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          mult_ctrl <= 1'b1;
          next_state <= MULT_WAIT;
        end

        MULT_WAIT: begin
          mult_ctrl <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          if (mult_end == 1'b1) begin
            next_state <= MULT_END;
          end else begin
            next_state <= MULT_WAIT;
          end
        end

        MULT_END: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          next_state <= FETCH;
        end

        MFHI: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          reg_dst <= 3'b001;
          mem_to_reg <= 4'b0100;
          reg_write <= 1'b1;
          next_state <= FETCH;
        end

        MFLO: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          reg_dst <= 3'b001;
          mem_to_reg <= 4'b0101;
          reg_write <= 1'b1;
          next_state <= FETCH;
        end

        JR: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          pc_src <= 3'b100;
          pc_write <= 1'b1;
          next_state <= FETCH;
        end

        BREAK: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          alu_srca <= 2'b00;
          alu_srcb <= 2'b01;
          alu_op <= 3'b010;
          pc_src <= 3'b001;
          pc_write <= 1'b1;
          alu_out_write <=1'b1;
          next_state <= FETCH;
        end

        RTE: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          pc_src <= 3'b010;
          pc_write <= 1'b1;
          next_state <= FETCH;
        end

        SHIFT_INIT: begin
          shift <= 3'b001;

          case(opcode)
            OPCODE_R: begin
              case (funct) 
                FUNCT_SLL: begin
                  next_state <= SLL;
                end

                FUNCT_SLLV: begin
                  next_state <= SLLV;
                end

                FUNCT_SRA: begin
                  next_state <= SRA;
                end

                FUNCT_SRAV: begin
                  next_state <= SRAV;
                end

                FUNCT_SRL: begin
                  next_state <= SRL;
                end
              endcase 
            end

            OPCODE_LUI:begin
              next_state <= LUI;
            end

          endcase
          
        end

        SLL: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          shift_srca <= 2'b01;
          shift_srcb <= 2'b00;
          shift <= 3'b010;
          next_state <= SHIFT_END;
        end

        SLLV: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b0;
          alu_srcb <= 2'b0;
          alu_op <= 3'b0;
          pc_src <= 3'b0;
          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          reg_dst <= 3'b0;
          mem_to_reg <= 4'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          shift <= 3'b0;
          alu_out_write <=1'b0;

          shift_srca <= 2'b00;
          shift_srcb <= 2'b01;
          shift <= 3'b010;
          next_state <= SHIFT_END;
        end

        SRA: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b0;
          alu_srcb <= 2'b0;
          alu_op <= 3'b0;
          pc_src <= 3'b0;
          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          reg_dst <= 3'b0;
          mem_to_reg <= 4'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          shift <= 3'b0;
          alu_out_write <=1'b0;

          shift_srca <= 2'b01;
          shift_srcb <= 2'b00;
          shift <= 3'b100;
          next_state <= SHIFT_END;
        end

        SRAV: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b0;
          alu_srcb <= 2'b0;
          alu_op <= 3'b0;
          pc_src <= 3'b0;
          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          reg_dst <= 3'b0;
          mem_to_reg <= 4'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          shift <= 3'b0;
          alu_out_write <=1'b0;

          shift_srca <= 2'b00;
          shift_srcb <= 2'b01;
          shift <= 3'b100;
          next_state <= SHIFT_END;
        end

        SRL: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b0;
          alu_srcb <= 2'b0;
          alu_op <= 3'b0;
          pc_src <= 3'b0;
          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          reg_dst <= 3'b0;
          mem_to_reg <= 4'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          shift <= 3'b0;
          alu_out_write <=1'b0;

          shift_srca <= 2'b01;
          shift_srcb <= 2'b00;
          shift <= 3'b011;
          next_state <= SHIFT_END;
        end

        SHIFT_END: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b0;
          alu_srcb <= 2'b0;
          alu_op <= 3'b0;
          pc_src <= 3'b0;
          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          reg_dst <= 3'b0;
          mem_to_reg <= 4'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          shift <= 3'b0;
          alu_out_write <=1'b0;

          mem_to_reg <= 4'b1010;
          reg_dst <= 3'b01;
          reg_write <= 1'b1;
          next_state <= FETCH;
        end

        SLT: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b0;
          alu_srcb <= 2'b0;
          alu_op <= 3'b0;
          pc_src <= 3'b0;
          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          reg_dst <= 3'b0;
          mem_to_reg <= 4'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          shift <= 3'b0;
          alu_out_write <=1'b0;

          alu_srca <= 2'b01;
          alu_srcb <= 2'b00;
          alu_op <= 3'b111;
          alu_out_write <=1'b1;
          mem_to_reg <= 4'b0011;
          reg_dst <= 3'b01;
          reg_write <= 1'b1;

          next_state <= FETCH;
        end

        //I type instructions execute
        ADDI: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b00;
          store_type <= 2'b00;
          branch_type <= 2'b00;
          shift_srca <= 2'b00;
          shift_srcb <= 2'b00;
          reg_dst <= 3'b000;
          shift <= 3'b000;
          mem_to_reg <= 4'b0000;
          alu_out_write <=1'b0;

          alu_srca <= 2'b01;
          alu_srcb <= 2'b10;
          alu_op <= 3'b001;
          alu_out_write <=1'b1;
          next_state <= IMEDIATE_END;
        end

        ADDIU: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b00;
          store_type <= 2'b00;
          branch_type <= 2'b00;
          shift_srca <= 2'b00;
          shift_srcb <= 2'b00;
          reg_dst <= 3'b000;
          shift <= 3'b000;
          mem_to_reg <= 4'b0000;
          alu_out_write <=1'b0;

          alu_srca <= 2'b01;
          alu_srcb <= 2'b10;
          alu_op <= 3'b001;
          alu_out_write <=1'b1;
          next_state <= IMEDIATE_END;
        end

        LUI: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b00;
          store_type <= 2'b00;
          branch_type <= 2'b00;
          shift_srca <= 2'b00;
          shift_srcb <= 2'b00;
          reg_dst <= 3'b000;
          shift <= 3'b000;
          mem_to_reg <= 4'b0000;
          alu_out_write <=1'b0;

          shift_srca <= 2'b10;
          shift_srcb <= 2'b10;
          shift <= 3'b010;
          next_state <= LUI_END;
        end

        LUI_END: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b00;
          store_type <= 2'b00;
          branch_type <= 2'b00;
          shift_srca <= 2'b00;
          shift_srcb <= 2'b00;
          reg_dst <= 3'b000;
          shift <= 3'b000;
          mem_to_reg <= 4'b0000;
          alu_out_write <=1'b0;

          mem_to_reg <= 4'b1010;
          reg_dst <= 3'b000;
          reg_write <= 1'b1;
          next_state <= FETCH;
        end

        IMEDIATE_END: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b00;
          store_type <= 2'b00;
          branch_type <= 2'b00;
          shift_srca <= 2'b00;
          shift_srcb <= 2'b00;
          reg_dst <= 3'b000;
          shift <= 3'b000;
          mem_to_reg <= 4'b0000;
          alu_out_write <=1'b0;

          mem_to_reg <= 4'b0000;
          reg_dst <= 3'b000;
          reg_write <= 1'b1;
          next_state <= FETCH;
        end

        SLTI: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b00;
          store_type <= 2'b00;
          branch_type <= 2'b00;
          shift_srca <= 2'b00;
          shift_srcb <= 2'b00;
          reg_dst <= 3'b000;
          shift <= 3'b000;
          mem_to_reg <= 4'b0000;
          alu_out_write <=1'b0;

          alu_srca <= 2'b01;
          alu_srcb <= 2'b10;
          alu_op <= 3'b111;
          alu_out_write <=1'b1;
          mem_to_reg <= 4'b0011;
          reg_dst <= 3'b000;
          reg_write <= 1'b1;
          next_state <= FETCH;
        end

        // SLTI_2: begin
        //   iord <= 1'b0;
        //   write_mem <= 1'b0;
        //   ir_write <= 1'b0;
        //   alu_srca <= 2'b00;
        //   alu_srcb <= 2'b00;
        //   alu_op <= 3'b000;
        //   pc_src <= 3'b001;

        //   pc_write <= 1'b0;
        //   mult_ctrl <= 1'b0;
        //   div_ctrl <= 1'b0;
        //   reg_write <= 1'b0;
        //   epc_write <= 1'b0;
        //   pc_write_cond <= 1'b0;
        //   hi_ctrl <= 1'b0;
        //   lo_ctrl <= 1'b0;
        //   load_type <= 2'b00;
        //   store_type <= 2'b00;
        //   branch_type <= 2'b00;
        //   shift_srca <= 2'b00;
        //   shift_srcb <= 2'b00;
        //   reg_dst <= 3'b000;
        //   shift <= 3'b000;
        //   mem_to_reg <= 4'b0000;
        //   alu_out_write <=1'b0;

        //   mem_to_reg <= 4'b0011;
        //   reg_dst <= 3'b000;
        //   reg_write <= 1'b1;
        //   next_state <= FETCH;
        // end

        BEQ: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b00;
          store_type <= 2'b00;
          branch_type <= 2'b00;
          shift_srca <= 2'b00;
          shift_srcb <= 2'b00;
          reg_dst <= 3'b000;
          shift <= 3'b000;
          mem_to_reg <= 4'b0000;
          alu_out_write <=1'b0;

          alu_srca <= 2'b01;
          alu_srcb <= 2'b00;
          alu_op <= 3'b010;
          alu_out_write <=1'b1;
          pc_src <= 3'b011;
          branch_type <= 2'b10;
          pc_write_cond <= 1'b1;
          next_state <= FETCH;
        end

        BNE: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b00;
          store_type <= 2'b00;
          branch_type <= 2'b00;
          shift_srca <= 2'b00;
          shift_srcb <= 2'b00;
          reg_dst <= 3'b000;
          shift <= 3'b000;
          mem_to_reg <= 4'b0000;
          alu_out_write <=1'b0;

          alu_srca <= 2'b01;
          alu_srcb <= 2'b00;
          alu_op <= 3'b010;
          alu_out_write <=1'b1;
          pc_src <= 3'b011;
          branch_type <= 2'b11;
          pc_write_cond <= 1'b1;
          next_state <= FETCH;
        end

        BLE: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b00;
          store_type <= 2'b00;
          branch_type <= 2'b00;
          shift_srca <= 2'b00;
          shift_srcb <= 2'b00;
          reg_dst <= 3'b000;
          shift <= 3'b000;
          mem_to_reg <= 4'b0000;
          alu_out_write <=1'b0;

          alu_srca <= 2'b01;
          alu_srcb <= 2'b00;
          alu_op <= 3'b111;
          alu_out_write <=1'b1;
          pc_src <= 3'b011;
          branch_type <= 2'b00;
          pc_write_cond <= 1'b1;
          next_state <= FETCH;
        end

        BGT: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b00;
          store_type <= 2'b00;
          branch_type <= 2'b00;
          shift_srca <= 2'b00;
          shift_srcb <= 2'b00;
          reg_dst <= 3'b000;
          shift <= 3'b000;
          mem_to_reg <= 4'b0000;
          alu_out_write <=1'b0;

          alu_srca <= 2'b01;
          alu_srcb <= 2'b00;
          alu_op <= 3'b111;
          alu_out_write <=1'b1;
          pc_src <= 3'b011;
          branch_type <= 2'b01;
          pc_write_cond <= 1'b1;
          next_state <= FETCH;
        end

        BEQM: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b00;
          store_type <= 2'b00;
          branch_type <= 2'b00;
          shift_srca <= 2'b00;
          shift_srcb <= 2'b00;
          reg_dst <= 3'b000;
          shift <= 3'b000;
          mem_to_reg <= 4'b0000;
          alu_out_write <=1'b0;

          iord <= 3'b001;
          write_mem <= 1'b0;
          load_type <= 2'b10;
          next_state <= BEQM_WAIT;
        end

        BEQM_WAIT: begin
          if (wait_counter==6'd1) begin
            next_state <= BEQM_END;
            wait_counter <=6'd0;
          end
          else begin
          wait_counter <= wait_counter + 1;
          end
        end

        BEQM_END: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b00;
          store_type <= 2'b00;
          branch_type <= 2'b00;
          shift_srca <= 2'b00;
          shift_srcb <= 2'b00;
          reg_dst <= 3'b000;
          shift <= 3'b000;
          mem_to_reg <= 4'b0000;
          alu_out_write <=1'b0;

          alu_srca <= 2'b10;
          alu_srcb <= 2'b00;
          alu_op <= 3'b010;
          alu_out_write <=1'b1;
          pc_src <= 3'b011;
          branch_type <= 2'b10;
          pc_write_cond <= 1'b1;
          next_state <= FETCH;
        end

        LOAD_STORE_INIT: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b00;
          store_type <= 2'b00;
          branch_type <= 2'b00;
          shift_srca <= 2'b00;
          shift_srcb <= 2'b00;
          reg_dst <= 3'b000;
          shift <= 3'b000;
          mem_to_reg <= 4'b0000;
          alu_out_write <=1'b0;

          alu_srca <= 2'b01;
          alu_srcb <= 2'b10;
          alu_op <= 3'b001;
          alu_out_write <=1'b1;

          case(opcode)
            OPCODE_LB: begin
              next_state <= LB;
            end
            OPCODE_LH: begin
              next_state <= LH;
            end
            OPCODE_LW: begin
              next_state <= LW;
            end

            OPCODE_SB: begin
              next_state <= LOAD_BEFORE_STORE;
            end
            OPCODE_SH: begin
              next_state <= LOAD_BEFORE_STORE;
            end
            OPCODE_SW: begin
              next_state <= LOAD_BEFORE_STORE;
            end

          endcase
        end

        LB: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b00;
          store_type <= 2'b00;
          branch_type <= 2'b00;
          shift_srca <= 2'b00;
          shift_srcb <= 2'b00;
          reg_dst <= 3'b000;
          shift <= 3'b000;
          mem_to_reg <= 4'b0000;
          alu_out_write <=1'b0;

          iord <= 3'b101;
          write_mem <= 1'b0;
          load_type <= 2'b00;
          next_state <= LOAD_WAIT;
        end

        LH: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b00;
          store_type <= 2'b00;
          branch_type <= 2'b00;
          shift_srca <= 2'b00;
          shift_srcb <= 2'b00;
          reg_dst <= 3'b000;
          shift <= 3'b000;
          mem_to_reg <= 4'b0000;
          alu_out_write <=1'b0;

          iord <= 3'b101;
          write_mem <= 1'b0;
          load_type <= 2'b01;
          next_state <= LOAD_WAIT;
        end

        LW: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b00;
          store_type <= 2'b00;
          branch_type <= 2'b00;
          shift_srca <= 2'b00;
          shift_srcb <= 2'b00;
          reg_dst <= 3'b000;
          shift <= 3'b000;
          mem_to_reg <= 4'b0000;
          alu_out_write <=1'b0;

          iord <= 3'b101;
          write_mem <= 1'b0;
          load_type <= 2'b10;
          next_state <= LOAD_WAIT;
        end

        LOAD_WAIT: begin
          if (wait_counter==6'd1) begin
            next_state <= LOAD_END;
            wait_counter <=6'd0;
          end
          else begin
          wait_counter <= wait_counter + 1;
          end
        end

        LOAD_END: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b00;
          store_type <= 2'b00;
          branch_type <= 2'b00;
          shift_srca <= 2'b00;
          shift_srcb <= 2'b00;
          reg_dst <= 3'b000;
          shift <= 3'b000;
          mem_to_reg <= 4'b0000;
          alu_out_write <=1'b0;

          mem_to_reg <= 4'b0001;
          reg_dst <= 3'b000;
          reg_write <= 1'b1;
          next_state <= FETCH;
        end

        LOAD_BEFORE_STORE: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          iord <= 3'b101;
          write_mem <= 1'b0;
          load_type <= 2'b10;
          next_state <= LOAD_BEFORE_STORE_WAIT;
          
        end

        LOAD_BEFORE_STORE_WAIT: begin

          case(opcode)
            OPCODE_SB: begin
              next_state <= SB;
            end
            OPCODE_SH: begin
              next_state <= SH;
            end
            OPCODE_SW: begin
              next_state <= SW;
            end
          endcase

        end

        SB: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          iord <= 3'b101;
          write_mem <= 1'b1;
          store_type <= 2'b00;
          next_state <= STORE_WAIT;
        end

        SH: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          iord <= 3'b101;
          write_mem <= 1'b1;
          store_type <= 2'b01;
          next_state <= STORE_WAIT;
        end

        SW: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          iord <= 3'b101;
          write_mem <= 1'b1;
          store_type <= 2'b10;
          next_state <= STORE_WAIT;
        end

        STORE_WAIT: begin
          next_state <= FETCH;
        end

        //J type instructions execute
        J: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b0;
          alu_srcb <= 2'b0;
          alu_op <= 3'b0;
          pc_src <= 3'b0;
          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          reg_dst <= 3'b0;
          mem_to_reg <= 4'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          shift <= 3'b0;
          alu_out_write <=1'b0;

          pc_src <= 3'b101;
          pc_write <= 1'b1;
          next_state <= FETCH;
        end

        JAL: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b0;
          alu_srcb <= 2'b0;
          alu_op <= 3'b0;
          pc_src <= 3'b0;
          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          reg_dst <= 3'b0;
          mem_to_reg <= 4'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          shift <= 3'b0;
          alu_out_write <=1'b0;

          mem_to_reg <= 4'b0010;
          reg_dst <= 3'b010;
          reg_write <= 1'b1;
          pc_src <= 3'b101;
          pc_write <= 1'b1;
          next_state <= FETCH;
        end

        EXCEPTION: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b0;
          alu_srcb <= 2'b0;
          alu_op <= 3'b0;
          pc_src <= 3'b0;
          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          reg_dst <= 3'b0;
          mem_to_reg <= 4'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          shift <= 3'b0;
          alu_out_write <=1'b0;

          alu_srca <= 2'b00;
          alu_srcb <= 2'b01;
          alu_op <= 3'b010;
          alu_out_write <=1'b1;

          epc_write <= 1'b1;
          if(overflow == 1'b1) begin
            next_state <= OVERFLOW;
          end
          if (div_zero == 1'b1) begin
            next_state <= DIV_ZERO;
          end
          if (opcode_inex == 1'b1) begin
            next_state <= OPCODE_INEX;
          end
        end

        OVERFLOW: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b0;
          alu_srcb <= 2'b0;
          alu_op <= 3'b0;
          pc_src <= 3'b0;
          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          reg_dst <= 3'b0;
          mem_to_reg <= 4'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          shift <= 3'b0;
          alu_out_write <=1'b0;

          iord <= 3'b010;
          write_mem <= 1'b0;
          next_state <= EXCEPTION_WAIT;
        end

        DIV_ZERO: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b0;
          alu_srcb <= 2'b0;
          alu_op <= 3'b0;
          pc_src <= 3'b0;
          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          reg_dst <= 3'b0;
          mem_to_reg <= 4'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          shift <= 3'b0;
          alu_out_write <=1'b0;

          iord <= 3'b011;
          write_mem <= 1'b0;
          next_state <= EXCEPTION_WAIT;
        end

        OPCODE_INEX: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;


          iord <= 3'b100;
          write_mem <= 1'b0;
          next_state <= EXCEPTION_WAIT;
        end

        EXCEPTION_WAIT: begin
          next_state <= EXCEPTION_END;
        end

        EXCEPTION_END: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;

          pc_src <= 3'b000;
          pc_write <= 1'b1;
          next_state <= FETCH;
        end

        default: begin
          iord <= 1'b0;
          write_mem <= 1'b0;
          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b00;
          alu_op <= 3'b000;
          pc_src <= 3'b001;

          pc_write <= 1'b0;
          mult_ctrl <= 1'b0;
          div_ctrl <= 1'b0;
          reg_write <= 1'b0;
          epc_write <= 1'b0;
          pc_write_cond <= 1'b0;
          hi_ctrl <= 1'b0;
          lo_ctrl <= 1'b0;
          load_type <= 2'b0;
          store_type <= 2'b0;
          branch_type <= 2'b0;
          shift_srca <= 2'b0;
          shift_srcb <= 2'b0;
          reg_dst <= 3'b0;
          shift <= 3'b0;
          mem_to_reg <= 4'b0;
          alu_out_write <=1'b0;


          ir_write <= 1'b0;
          alu_srca <= 2'b00;
          alu_srcb <= 2'b01;
          alu_op <= 3'b001;
          alu_out_write <=1'b1;
          pc_src <= 3'b001;
          pc_write <= 1'b0;
          
        
          reg_dst <= 3'b100;
          mem_to_reg <= 4'b0110;
          reg_write <= 1'b1;
          next_state <= FETCH_WAIT;
        end

      endcase
      end 
    end
endmodule
