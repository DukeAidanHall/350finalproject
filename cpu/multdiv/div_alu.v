module div_alu(data_operandA, data_operandB, ctrl_ALUopcode, data_result);
        
    input [31:0] data_operandA, data_operandB;
    input ctrl_ALUopcode;

    output [31:0] data_result;
    //output overflow;

    //wires
    wire [31:0] w1, w2;
    wire add_over, sub_over;
    wire isLessThan, isNotEqual;

    alu_add_full my_add(w1, add_over, data_operandA, data_operandB, 1'b0);
    alu_sub_full my_sub(w2, sub_over, isNotEqual, isLessThan, data_operandA, data_operandB);
    
    alu_mux_2#(32) final_mux(data_result, ctrl_ALUopcode, w1, w2);
    //alu_mux_2#(1) overflow_mux(overflow, ctrl_ALUopcode, add_over, sub_over);

endmodule