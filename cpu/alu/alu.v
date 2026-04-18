module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    //wires
    wire [31:0] w1, w2, w3, w4, w5, w6;
    wire add_over, sub_over;

    wire zero;
    assign zero = 0;

    
    alu_and my_and(w1, data_operandA, data_operandB);
    alu_or my_or(w2, data_operandA, data_operandB);
    alu_sll_full my_sll(w3, data_operandA, ctrl_shiftamt);
    alu_sra_full my_sra(w4, data_operandA, ctrl_shiftamt);
    alu_add_full my_add(w5, add_over, data_operandA, data_operandB, zero);
    alu_sub_full my_sub(w6, sub_over, isNotEqual, isLessThan, data_operandA, data_operandB);
    
    alu_mux_8 #(32) final_mux(data_result, ctrl_ALUopcode[2:0], w5, w6, w1, w2, w3, w4, 0, 0);
    alu_mux_2#(1) overflow_mux(overflow, ctrl_ALUopcode[0], add_over, sub_over);

    

endmodule