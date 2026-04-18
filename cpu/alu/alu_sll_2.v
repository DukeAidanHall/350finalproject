module alu_sll_2 (data_result, data_operandA, ctrl_shiftamt);
    input [31:0] data_operandA;
    input [4:0] ctrl_shiftamt;

    output [31:0] data_result;

    assign data_result[31:2] = data_operandA[29:0];
    assign data_result[0] = 0;
    assign data_result[1] = 0;
endmodule