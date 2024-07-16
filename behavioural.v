module mips_32(clk1, clk2);
  input clk1, clk2;
  reg [31:0] pc, if_id_npc, if_id_ir;
  reg [31:0] id_ex_ir, id_ex_npc, id_ex_A, id_ex_B, id_ex_imm;
  reg [2:0]  id_ex_type, ex_mem_type, mem_wb_type;
  reg        ex_mem_cond;
  reg [31:0] ex_mem_ALUout, ex_mem_ir, ex_mem_B;
  reg [31:0] mem_wb_ir, mem_wb_LMD, mem_wb_ALUout;
  
  reg [31:0] REG[0:31]; //32 x 32 register 
  reg [31:0] mem[0:1023]; // 32 x 1024 memory

  parameter add = 6'b000000, sub = 6'b00001, AND = 6'b000010, OR = 6'b000011, //ALU operations
            SLT = 6'b000100, MUL = 6'b000101, HLT = 6'b111111, LW = 6'b001000,
            SW = 6'b001001, ADD1 = 6'b001010, SUB1 = 6'b001011, SLT1 = 6'b001100,
            BNEQZ = 6'b001101, BEQZ = 6'b001110;
  parameter RR_alu = 3'b000, RM_alu = 3'b001, LOAD = 3'b010,
            STORE = 3'b011, BRANCH = 3'b100, HALT = 3'b101;
  reg taken_branch; // set if branch is taken
  reg halted; // set if halt is encountered at WB stage

  always @ (posedge clk1)                                                     // IF stage
  if (halted == 0) begin
    if (((ex_mem_ir[31:26] == BEQZ) && (ex_mem_cond == 1)) ||
        ((ex_mem_ir[31:26] == BNEQZ) && (ex_mem_cond == 0)))
        begin
          if_id_ir     <= #2 mem[ex_mem_ALUout];
          if_id_npc    <= #2 ex_mem_ALUout + 1;
          pc           <= #2 ex_mem_ALUout + 1;
          taken_branch <= #2 1'b1;

        end
    else begin
        if_id_ir  <= #2 mem[pc];
        pc        <= #2 pc + 1;
        if_id_npc <= #2 pc + 1;

    end
 end
  
  always @ (posedge clk2)                                                //ID stage
  if (halted == 0) begin

    if (if_id_ir[25:21] == 5'b00000) id_ex_A <= 0;
    else id_ex_A <= #2 REG[if_id_ir[25:21]];

    if (if_id_ir[20:16] == 5'b00000) id_ex_B <= 0;
    else id_ex_B <= #2 REG[if_id_ir[20:16]];

    id_ex_imm = #2 {{16{if_id_ir[15]}}, {if_id_ir[15:0]}};
    id_ex_ir <= #2 if_id_ir;
    id_ex_npc <= #2 if_id_npc;

    case (if_id_ir[31:26])
     add, sub, AND, OR, SLT, MUL:  id_ex_type <= #2 RR_alu;
     ADD1, SUB1, SLT1:             id_ex_type <= #2 RM_alu;
     BNEQZ, BEQZ:                  id_ex_type <= #2 BRANCH;
     LW:                           id_ex_type <= #2 LOAD;
     SW:                           id_ex_type <= #2 STORE;
     HLT:                          id_ex_type <= #2 HALT;
     default:                      id_ex_type <= #2 HALT;
    endcase
  end

   always @ (posedge clk1)                                                      // EX stage
   if (halted == 0) begin
    ex_mem_type <=  #2 id_ex_type ;
    ex_mem_ir   <=  #2 id_ex_ir;
    taken_branch <= #2 0;
    case (id_ex_type)
     RR_alu : begin case(id_ex_ir[31:26])              //opcode 
               add : ex_mem_ALUout   <= #2 id_ex_A + id_ex_B;
               sub : ex_mem_ALUout   <= #2 id_ex_A - id_ex_B;
               MUL : ex_mem_ALUout   <= #2 id_ex_A * id_ex_B;
               AND : ex_mem_ALUout   <= #2 id_ex_A & id_ex_B;
               OR  : ex_mem_ALUout   <= #2 id_ex_A | id_ex_B;
               SLT : ex_mem_ALUout   <= #2 id_ex_A < id_ex_B;
               default :ex_mem_ALUout<= 32'hxxxxxxxx;
              endcase
     end
     RM_alu : begin case (id_ex_ir[31:26])            //opcode
               ADD1 : ex_mem_ALUout  <= #2 id_ex_A + id_ex_imm;
               SUB1 : ex_mem_ALUout  <= #2 id_ex_A - id_ex_imm;
               SLT1 : ex_mem_ALUout  <= #2 id_ex_A < id_ex_imm;
               default :ex_mem_ALUout<= #2 32'hxxxxxxxx;
              endcase
     end
     LOAD, STORE : begin
                        ex_mem_B      <= #2 id_ex_B;
                        ex_mem_ALUout <= #2 id_ex_A + id_ex_imm;
                    end
     BRANCH : begin 
        ex_mem_ALUout <= #2 id_ex_npc + id_ex_imm;
        ex_mem_cond   <= #2 (id_ex_A == 0);
     end

    endcase           
   end

   always @ (posedge clk2)                                             // MEM stage
   if (halted == 0 ) begin
    mem_wb_type   <= #2 ex_mem_type;
    mem_wb_ir     <= #2 ex_mem_ir;
    case (ex_mem_type) 
     RR_alu, RM_alu : mem_wb_ALUout <= #2 ex_mem_ALUout;
     LOAD           : mem_wb_LMD    <= #2 mem[ex_mem_ALUout];
     STORE          : if (taken_branch == 0)          //when storing disable write
                      begin
                        mem[ex_mem_ALUout] <= #2 ex_mem_B;
                      end
    endcase
   end

  always @ (posedge clk1) begin                                           // WB stage
    if (taken_branch == 0) begin
        case (mem_wb_type)
         RR_alu : REG[mem_wb_ir[15:11]] <= #2 mem_wb_ALUout;
         RM_alu : REG[mem_wb_ir[20:16]] <= #2 mem_wb_ALUout;
         LOAD   : REG[mem_wb_ir[20:16]] <= #2 mem_wb_LMD;
         HALT   : halted                <= #2 1'b1;
        endcase
    end
  end



endmodule