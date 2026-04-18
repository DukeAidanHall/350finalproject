module alu_sra_1 (data_result, data_operandA, ctrl_shiftamt);
    input [31:0] data_operandA;
    input [4:0] ctrl_shiftamt;

    output [31:0] data_result;

    assign data_result[30:0] = data_operandA[31:1];
    assign data_result[31] = data_operandA[31];
endmodule