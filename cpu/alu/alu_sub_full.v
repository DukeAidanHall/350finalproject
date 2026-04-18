module alu_sub_full (data_result, overflow, isNotEqual, isLessThan, data_operandA, data_operandB);
    input [31:0] data_operandA, data_operandB;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    wire [31:0] notB;
    wire add_over;
    wire w2, w3, w4, w5, w6;
    wire one;
    assign one = 1;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : notB_assign
            not(notB[i], data_operandB[i]);
        end
    endgenerate

    alu_add_full my_add(data_result, add_over, data_operandA, notB, one);

    not not0(w2, data_result[31]);
    not not1(w3, data_operandA[31]);
    not not2(w4, notB[31]);
    and and0(w5, data_operandA[31], notB[31], w2);
    and and1(w6, w3, w4, data_result[31]);
    or or0(overflow, w5, w6);

    xor xor0(isLessThan, data_result[31], overflow);

    or or1(isNotEqual, data_result[0], data_result[1], data_result[2], data_result[3],
    data_result[4], data_result[5], data_result[6], data_result[7],
    data_result[8], data_result[9], data_result[10], data_result[11],
    data_result[12], data_result[13], data_result[14], data_result[15],
    data_result[16], data_result[17], data_result[18], data_result[19],
    data_result[20], data_result[21], data_result[22], data_result[23],
    data_result[24], data_result[25], data_result[26], data_result[27],
    data_result[28], data_result[29], data_result[30], data_result[31]);

endmodule