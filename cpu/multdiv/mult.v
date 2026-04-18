module mult(
	data_operandA, data_operandB, 
	ctrl_MULT,
	clock, 
	data_result, data_exception, data_resultRDY);

    input signed [31:0] data_operandA, data_operandB;
    input ctrl_MULT, clock;

    output signed [31:0] data_result;
    output data_exception, data_resultRDY;

    wire ff2_out, overflow;
    wire[1:0] alu_opcode;
    wire signed [31:0] mcand, alu_out, mier;

    assign mcand = data_operandA; //multiplicand
    assign mier = data_operandB; //multiplier

    assign alu_opcode[1] = reg_out[0];
    assign alu_opcode[0] = ff2_out;

    mult_alu my_alu(reg_out[63:32], mcand, alu_opcode, alu_out, overflow); //alu

    wire signed [64:0] reg_in, reg_out, reg_in_shifted, reg_in_final;
    assign reg_in[63:32] = alu_out;
    assign reg_in[31:0] = reg_out[31:0];

    wire extra;
    xor xor1(extra, overflow, reg_in[63]);
    assign reg_in[64] = extra;

    assign reg_in_final = reg_in >> 1;

    dffe_ref extra_ff2(.q(ff2_out), .d(reg_in[0]), .clk(clock), .en(1'b1), .clr(ctrl_MULT)); //last extra bit
    reg_64 prod_reg(.clk(clock), .in_en(1'b1), .reset(ctrl_MULT), .in(reg_in_final), .out(reg_out), .mier(mier));

    count_32 counter(.q(data_resultRDY), .t(1'b1), .clk(clock), .en(1'b1), .clr(ctrl_MULT));

    assign data_result = reg_out[31:0];

    wire over_c1, over_c2;

    assign over_c1 = &reg_out[63:31];
    assign over_c2 = !(|reg_out[63:31]);

    assign data_exception = !(over_c1 || over_c2);

endmodule