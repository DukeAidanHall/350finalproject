module alu_sra_2 (data_result, data_operandA, ctrl_shiftamt);
    input [31:0] data_operandA;
    input [4:0] ctrl_shiftamt;

    output [31:0] data_result;

    assign data_result[29:0] = data_operandA[31:2];
    assign data_result[31] = data_operandA[31];
    assign data_result[30] = data_operandA[31];
endmodule