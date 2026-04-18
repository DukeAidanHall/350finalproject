module div(
	data_operandA, data_operandB, 
	ctrl_DIV,
	clock, 
	data_result, data_exception, data_resultRDY);

    input signed [31:0] data_operandA, data_operandB;
    input ctrl_DIV, clock;

    output signed [31:0] data_result;
    output data_exception, data_resultRDY;

    wire [31:0] dvend, dvisor, sub_out, negated_data_operandA, negated_data_operandB, negated_reg_out, likely_result;
    wire [63:0] reg_out_ls, final_in, reg_out, success;
    wire sub_over, isNotEqual, isLessThan, a_invert_over, b_invert_over, out_over, isnotzero;

    assign isnotzero = |data_operandB;

    alu_mux_2 #(.WIDTH(1)) zero_mux(.out(data_exception), .select(isnotzero), .in0(1'b1), .in1(1'b0));

    alu_add_full my_add_1(.data_result(negated_data_operandA), .overflow(a_invert_over), 
    .data_operandA(~data_operandA), .data_operandB(32'b0), .c0(1'b1));

    alu_add_full my_add_2(.data_result(negated_data_operandB), .overflow(b_invert_over), 
    .data_operandA(~data_operandB), .data_operandB(32'b0), .c0(1'b1));

    alu_mux_2 #(.WIDTH(32)) my_mux_a (.out(dvend), .select(data_operandA[31]), .in0(data_operandA), .in1(negated_data_operandA));
    alu_mux_2 #(.WIDTH(32)) my_mux_b (.out(dvisor), .select(data_operandB[31]), .in0(data_operandB), .in1(negated_data_operandB));
    
    reg_div prod_reg(.clk(clock), .in_en(1'b1), .reset(ctrl_DIV), .in(final_in), 
    .out(reg_out), .dvend(dvend)); //reg

    assign reg_out_ls [63:1] = reg_out[62:0]; //shift
    assign reg_out_ls [0] = 1'b0;

    alu_sub_full my_sub(.data_result(sub_out), .overflow(sub_over), .isNotEqual(isNotEqual), 
    .isLessThan(isLessThan), .data_operandA(reg_out_ls[63:32]), .data_operandB(dvisor));

    assign success[63:32] = sub_out; //success setup
    assign success[31:1] = reg_out_ls[31:1];
    assign success[0] = 1'b1;

    alu_mux_2 #(.WIDTH(64)) msb_mux(.out(final_in), .select(success[63]), .in0(success), .in1(reg_out_ls)); //0 for success or 1 for undo

    count_32 counter(.q(data_resultRDY), .t(1'b1), .clk(clock), .en(1'b1), .clr(ctrl_DIV)); //counter

    wire [1:0] result_select;

    alu_add_full my_add_3(.data_result(negated_reg_out), .overflow(out_over), 
    .data_operandA(~reg_out[31:0]), .data_operandB(32'b0), .c0(1'b1));

    assign result_select[0] = data_operandA[31];
    assign result_select[1] = data_operandB[31];

    alu_mux_4 #(.WIDTH(32)) out_mux(.out(likely_result), .select(result_select), 
    .in0(reg_out[31:0]), .in1(negated_reg_out), .in2(negated_reg_out), .in3(reg_out[31:0]));

    alu_mux_2 #(.WIDTH(32)) fina_out_mux(.out(data_result), .select(data_exception), .in0(likely_result), .in1(32'b0));


endmodule