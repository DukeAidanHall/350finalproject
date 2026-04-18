module alu_sll_4 (data_result, data_operandA, ctrl_shiftamt);
    input [31:0] data_operandA;
    input [4:0] ctrl_shiftamt;

    output [31:0] data_result;

    assign data_result[31:4] = data_operandA[27:0];
    assign data_result[0] = 0;
    assign data_result[1] = 0;
    assign data_result[2] = 0;
    assign data_result[3] = 0;
endmodule