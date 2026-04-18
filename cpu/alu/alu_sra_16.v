module alu_sra_16 (data_result, data_operandA, ctrl_shiftamt);
    input [31:0] data_operandA;
    input [4:0] ctrl_shiftamt;

    output [31:0] data_result;

    assign data_result[15:0] = data_operandA[31:16];
    assign data_result[31] = data_operandA[31];
    assign data_result[30] = data_operandA[31];
    assign data_result[29] = data_operandA[31];
    assign data_result[28] = data_operandA[31];
    assign data_result[27] = data_operandA[31];
    assign data_result[26] = data_operandA[31];
    assign data_result[25] = data_operandA[31];
    assign data_result[24] = data_operandA[31];
    assign data_result[23] = data_operandA[31];
    assign data_result[22] = data_operandA[31];
    assign data_result[21] = data_operandA[31];
    assign data_result[20] = data_operandA[31];
    assign data_result[19] = data_operandA[31];
    assign data_result[18] = data_operandA[31];
    assign data_result[17] = data_operandA[31];
    assign data_result[16] = data_operandA[31];
endmodule