module alu_sll_full (data_result, data_operandA, ctrl_shiftamt);
    input [31:0] data_operandA;
    input [4:0] ctrl_shiftamt;

    output [31:0] data_result;

    wire [31:0] w1, w2, w3, w4, w5, w6, w7, w8, w9;

    alu_sll_1 sll_1(w1, data_operandA, ctrl_shiftamt);
    alu_mux_2 mux_1(w2, ctrl_shiftamt[0], data_operandA, w1);

    alu_sll_2 sll_2(w3, w2, ctrl_shiftamt);
    alu_mux_2 mux_2(w4, ctrl_shiftamt[1], w2, w3);
    
    alu_sll_4 sll_4(w5, w4, ctrl_shiftamt);
    alu_mux_2 mux_3(w6, ctrl_shiftamt[2], w4, w5);

    alu_sll_8 sll_8(w7, w6, ctrl_shiftamt);
    alu_mux_2 mux_4(w8, ctrl_shiftamt[3], w6, w7);

    alu_sll_16 sll_16(w9, w8, ctrl_shiftamt);
    alu_mux_2 mux_5(data_result, ctrl_shiftamt[4], w8, w9);

endmodule