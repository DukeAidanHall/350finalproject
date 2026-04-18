module alu_sll_16 (data_result, data_operandA, ctrl_shiftamt);
    input [31:0] data_operandA;
    input [4:0] ctrl_shiftamt;

    output [31:0] data_result;

    assign data_result[31:16] = data_operandA[15:0];
    assign data_result[0] = 0;
    assign data_result[1] = 0;
    assign data_result[2] = 0;
    assign data_result[3] = 0;
    assign data_result[4] = 0;
    assign data_result[5] = 0;
    assign data_result[6] = 0;
    assign data_result[7] = 0;
    assign data_result[8] = 0;
    assign data_result[9] = 0;
    assign data_result[10] = 0;
    assign data_result[11] = 0;
    assign data_result[12] = 0;
    assign data_result[13] = 0;
    assign data_result[14] = 0;
    assign data_result[15] = 0;

endmodule