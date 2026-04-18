module reg_div (clk, in_en, reset, in, out, dvend);
	input clk, in_en, reset;
	input [63:0] in;
    input [31:0] dvend;
	output [63:0] out;

    wire [63:0] in_on_clear;
    wire [63:0] in_custom;
    assign in_on_clear[63:32] = 32'b00000000000000000000000000000000;
    assign in_on_clear[31:0] = dvend;

    alu_mux_2 #(.WIDTH(64)) reg_div_mux(.out(in_custom), .select(reset), 
    .in0(in), .in1(in_on_clear));

    genvar i;
    generate
        for (i=32; i<64; i=i+1) begin: loop0
            dffe_ref a_dff(.q(out[i]), .d(in_custom[i]), .clk(clk), .en(in_en), .clr(1'b0));
        end
    endgenerate

    genvar j;
    generate
        for (j=0; j<32; j=j+1) begin: loop1
            dffe_ref a_dff(.q(out[j]), .d(in_custom[j]), .clk(clk), .en(in_en), .clr(1'b0));
        end
    endgenerate

endmodule
