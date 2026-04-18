module count_32 (q, t, clk, en, clr);
   
   //Inputs
   input t, clk, en, clr;

   wire q0, q1, q2, q3, q4, q5;
   
   //Output
   output q;

   t_flip_flop tff1(.q(q0), .t(t), .clk(clk), .en(en), .clr(clr));
   t_flip_flop tff2(.q(q1), .t(q0), .clk(clk), .en(en), .clr(clr));
   t_flip_flop tff3(.q(q2), .t(q0 && q1), .clk(clk), .en(en), .clr(clr));
   t_flip_flop tff4(.q(q3), .t(q0 && q1 && q2), .clk(clk), .en(en), .clr(clr));
   t_flip_flop tff5(.q(q4), .t(q0 && q1 && q2 && q3), .clk(clk), .en(en), .clr(clr));
   t_flip_flop tff6(.q(q5), .t(q0 && q1 && q2 && q3 && q4), .clk(clk), .en(en), .clr(clr));

   assign q = q5;

endmodule