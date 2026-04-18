module alu_add_full (data_result, overflow, data_operandA, data_operandB, c0);
    input [31:0] data_operandA, data_operandB;
    input c0;

    output [31:0] data_result;
    output overflow;

    wire G0, P0, c0;
    wire G1, P1, c8;
    wire G2, P2, c16;
    wire G3, P3, c24;
    wire G4, P4, c32;
    wire w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15;

    alu_add_block first_block(data_result[7:0], G0, P0, c0, data_operandA[7:0], data_operandB[7:0]);
    and and0(w1, P0, c0);
    or or0(c8, G0, w1);

    alu_add_block second_block(data_result[15:8], G1, P1, c8, data_operandA[15:8], data_operandB[15:8]);
    and and1(w2, P1, G0);
    and and2(w3, P1, P0, c0);
    or or1(c16, G1, w2, w3);

    alu_add_block third_block(data_result[23:16], G2, P2, c16, data_operandA[23:16], data_operandB[23:16]);
    and and3(w4, P2, G1);
    and and4(w5, P2, P1, G0);
    and and5(w6, P2, P1, P0, c0);
    or or2(c24, G2, w4, w5, w6);

    alu_add_block fourth_block(data_result[31:24], G3, P3, c24, data_operandA[31:24], data_operandB[31:24]);
    and and6(w7, P3, G2);
    and and7(w8, P3, P2, G1);
    and and8(w9, P3, P2, P1, G0);
    and and9(w10, P3, P2, P1, P0, c0);
    or or3(c32, G3, w7, w8, w9, w10);

    not not0(w11, data_result[31]);
    not not1(w12, data_operandA[31]);
    not not2(w13, data_operandB[31]);
    and and10(w14, data_operandA[31], data_operandB[31], w11);
    and and11(w15, w12, w13, data_result[31]);
    or or4(overflow, w14, w15);

endmodule