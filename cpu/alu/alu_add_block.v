module alu_add_block (Sout, Gout, Pout, carryIn, data_operandA, data_operandB);
    input [7:0] data_operandA, data_operandB;
    input carryIn;
    output [7:0] Sout;
    output Gout, Pout;

    wire[7:0] g, p, c;
    wire w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18, w19, w20, w21, w22, w23, w24, w25, w26, w27, w28, w29, w30, w31, w32, w33, w34, w35, w36;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : pg_assign
            and(g[i], data_operandA[i], data_operandB[i]);
            or(p[i], data_operandA[i], data_operandB[i]);
        end
    endgenerate

    // c0
    assign c[0] = carryIn;

    //c1
    and and0(w1, p[0], carryIn);
    or or0(c[1], g[0], w1);

    //c2
    and and1(w2, p[1], g[0]);
    and and2(w3, p[1], p[0], carryIn);
    or or1(c[2], g[1], w2, w3);

    //c3
    and and3(w4, p[2], g[1]);
    and and4(w5, p[2], p[1], g[0]);
    and and5(w6, p[2], p[1], p[0], carryIn);
    or or2(c[3], g[2], w4, w5, w6);

    //c4
    and and6(w7, p[3], g[2]);
    and and7(w8, p[3], p[2], g[1]);
    and and8(w9, p[3], p[2], p[1], g[0]);
    and and9(w10, p[3], p[2], p[1], p[0], carryIn);
    or or3(c[4], g[3], w7, w8, w9, w10);

    //c5
    and and10(w11, p[4], g[3]);
    and and11(w12, p[4], p[3], g[2]);
    and and12(w13, p[4], p[3], p[2], g[1]);
    and and13(w14, p[4], p[3], p[2], p[1], g[0]);
    and and14(w15, p[4], p[3], p[2], p[1], p[0], carryIn);
    or or4(c[5], g[4], w11, w12, w13, w14, w15);

    //c6
    and and15(w16, p[5], g[4]);
    and and16(w17, p[5], p[4], g[3]);
    and and17(w18, p[5], p[4], p[3], g[2]);
    and and18(w19, p[5], p[4], p[3], p[2], g[1]);
    and and19(w20, p[5], p[4], p[3], p[2], p[1], g[0]);
    and and20(w21, p[5], p[4], p[3], p[2], p[1], p[0], carryIn);
    or or5(c[6], g[5], w16, w17, w18, w19, w20, w21);

    //c7
    and and21(w22, p[6], g[5]);
    and and22(w23, p[6], p[5], g[4]);
    and and23(w24, p[6], p[5], p[4], g[3]);
    and and24(w25, p[6], p[5], p[4], p[3], g[2]);
    and and25(w26, p[6], p[5], p[4], p[3], p[2], g[1]);
    and and26(w27, p[6], p[5], p[4], p[3], p[2], p[1], g[0]);
    and and27(w28, p[6], p[5], p[4], p[3], p[2], p[1], p[0], carryIn);
    or or6(c[7], g[6], w22, w23, w24, w25, w26, w27, w28);


    //Gout
    and and28(w29, p[7], g[6]);
    and and29(w30, p[7], p[6], g[5]);
    and and30(w31, p[7], p[6], p[5], g[4]);
    and and31(w32, p[7], p[6], p[5], p[4], g[3]);
    and and32(w33, p[7], p[6], p[5], p[4], p[3], g[2]);
    and and33(w34, p[7], p[6], p[5], p[4], p[3], p[2], g[1]);
    and and34(w35, p[7], p[6], p[5], p[4], p[3], p[2], p[1], g[0]);
    or or7(Gout, g[7], w29, w30, w31, w32, w33, w34, w35);

    //Pout
    and and36(Pout, p[7], p[6], p[5], p[4], p[3], p[2], p[1], p[0]);

    //Sout
    genvar j;
    generate
        for (j = 0; j < 8; j = j + 1) begin : Sout_assign
            xor(Sout[j], data_operandA[j], data_operandB[j], c[j]);
        end
    endgenerate




endmodule