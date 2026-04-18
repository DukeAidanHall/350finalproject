module t_flip_flop (q, t, clk, en, clr);
   
   //Inputs
   input t, clk, en, clr;
   
   //Output
   output q;

   wire d_in;

   assign d_in = ((t && (!q)) || ((!t) && q));

   dffe_ref my_dffe(.q(q), .d(d_in), .clk(clk), .en(en), .clr(clr));
   

endmodule