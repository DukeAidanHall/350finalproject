module alu_sll_8 (data_result, data_operandA, ctrl_shiftamt);
    input [31:0] data_operandA;
    input [4:0] ctrl_shiftamt;

    output [31:0] data_result;

    assign data_result[31:8] = data_operandA[23:0];
    assign data_result[0] = 0;
    assign data_result[1] = 0;
    assign data_result[2] = 0;
    assign data_result[3] = 0;
    assign data_result[4] = 0;
    assign data_result[5] = 0;
    assign data_result[6] = 0;
    assign data_result[7] = 0;
endmodule