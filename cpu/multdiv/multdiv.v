module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY);

    input signed [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output signed [31:0] data_result;
    output data_exception, data_resultRDY;

    wire [31:0] mult_result, div_result;
    wire mult_exception, div_exception, mult_resultRDY, div_resultRDY, select_op;
    
    mult my_mult(.data_operandA(data_operandA), .data_operandB(data_operandB), .ctrl_MULT(ctrl_MULT), .clock(clock), 
    .data_result(mult_result), .data_exception(mult_exception), .data_resultRDY(mult_resultRDY));

    div my_div(.data_operandA(data_operandA), .data_operandB(data_operandB), .ctrl_DIV(ctrl_DIV), .clock(clock), 
    .data_result(div_result), .data_exception(div_exception), .data_resultRDY(div_resultRDY));

    dffe_ref op_ff(.q(select_op), .d(ctrl_DIV), .clk(clock), .en(ctrl_MULT || ctrl_DIV), .clr(1'b0)); 

    alu_mux_2 #(.WIDTH(32)) my_mux_1 (.out(data_result), .select(select_op), .in0(mult_result), .in1(div_result));
    alu_mux_2 #(.WIDTH(1)) my_mux_2 (.out(data_exception), .select(select_op), .in0(mult_exception), .in1(div_exception));
    alu_mux_2 #(.WIDTH(1)) my_mux_3 (.out(data_resultRDY), .select(select_op), .in0(mult_resultRDY), .in1(div_resultRDY));

    //assign data_result = 64'b0;
    //assign data_exception = 1'b0;
    //assign data_resultRDY = 1'b1;

endmodule