/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

	/* YOUR CODE STARTS HERE */

    // ============= Necessary Top Wire Declarations ==================== //
    wire[31:0] fdir_out;
    wire[31:0] dxir_out;
    wire[31:0] xmo_out;

    wire [31:0] w_mux_out;

    wire x_anyExcep;

    // ============= STALL ================= //

    //A stall
    wire[4:0] FD_IR_A, DX_IR_RD;
    wire s_readFD_A, s_writeDX_RD, s_writeDX_r30, 
    s_writeDX_r31, s_readFD_r30_A;
    assign FD_IR_A = ctrl_readRegA;
    assign DX_IR_RD = dxir_out[26:22];

    assign s_readFD_A = (fdir_out[31:27] == 5'b00000)
    || (fdir_out[31:27] == 5'b00111)
    || (fdir_out[31:27] == 5'b01000)
    || (fdir_out[31:27] == 5'b00010)
    || (fdir_out[31:27] == 5'b00110)
    || (fdir_out[31:27] == 5'b00101);

    assign s_readFD_r30_A = (fdir_out[31:27] == 5'b10110);

    assign s_writeDX_RD = (dxir_out[31:27] == 5'b00000)
    || (dxir_out[31:27] == 5'b01000)
    || (dxir_out[31:27] == 5'b00101);

    assign s_writeDX_r30 = (dxir_out[31:27] == 5'b10101);
    assign s_writeDX_r31 = (dxir_out[31:27] == 5'b00011);

    
    wire s_needStall_A;
    assign s_needStall_A = 
    (((FD_IR_A == DX_IR_RD) && s_readFD_A && s_writeDX_RD && (DX_IR_RD != 5'b00000)) 
    || (s_writeDX_r30 && ((FD_IR_A == 5'b11110) || s_readFD_r30_A))
    || (s_writeDX_r31 && (FD_IR_A == 5'b11111)));


    //B Stall

    wire[4:0] FD_IR_B;
    wire s_readFD_B;
    assign FD_IR_B = ctrl_readRegB;

    assign s_readFD_B = (fdir_out[31:27] == 5'b00000)
    || (fdir_out[31:27] == 5'b00111) 
    || (fdir_out[31:27] == 5'b00010)
    || (fdir_out[31:27] == 5'b00110)
    || (fdir_out[31:27] == 5'b00001)
    || (fdir_out[31:27] == 5'b00011)
    || (fdir_out[31:27] == 5'b00100);
    
    wire s_needStall_B;
    assign s_needStall_B = 
    ((FD_IR_B == DX_IR_RD) && s_readFD_B && s_writeDX_RD && (DX_IR_RD != 5'b00000))
    || (s_writeDX_r30 && (FD_IR_B == 5'b11110))
    || (s_writeDX_r31 && (FD_IR_B == 5'b11111));


    //Mult-Mult Div-Div Edge Case
    wire s_multmult;
    wire s_divdiv;
    assign s_multmult = ((fdir_out[31:27] == 5'b00000) && (fdir_out[6:2] == 5'b00110)) 
    && ((dxir_out[31:27] == 5'b00000) && (dxir_out[6:2] == 5'b00110));
    assign s_divdiv = ((fdir_out[31:27] == 5'b00000) && (fdir_out[6:2] == 5'b00111)) 
    && ((dxir_out[31:27] == 5'b00000) && (dxir_out[6:2] == 5'b00111));


    wire STALL;
    assign STALL = (((dxir_out[31:27] == 5'b01000) && 
    ((s_needStall_A) || 
    ((s_needStall_B) && (fdir_out[31:27] != 5'b00111))))
    || s_multmult || s_divdiv);



    // =============CLOCK / WE MANAGEMENT================= //

    //Clock (previousy had logic to manipulate)
    wire clockCTRL;
    assign clockCTRL = clock;

    //WE
    wire weCTRL;
    wire x_freeze_for_md;

    alu_mux_2 #(.WIDTH(1)) we_mux1(.out(weCTRL), .select(x_freeze_for_md), 
    .in0(1'b1), .in1(1'b0));

    wire pc_fd_weCTRL_in, pc_fd_weCTRL;
    alu_mux_2 #(.WIDTH(1)) we_mux2(.out(pc_fd_weCTRL_in), .select(STALL), 
    .in0(1'b1), .in1(1'b0));

    assign pc_fd_weCTRL = weCTRL && pc_fd_weCTRL_in && !x_anyExcep;

    // ============= NOP ================= //
    wire[31:0] NOP;
    assign NOP = 32'b00000000000000000000000000000000;

    wire pc_NOP_select = 1'b0;
    wire fd_NOP_select = f_newPCSet;
    wire dx_NOP_select = f_newPCSet || STALL;

    // ================FETCH STAGE=================== // 

    //PC
    wire[31:0] fpc_in_1, fpc_in_2, fpc_in_3, fpc_in_4, fpc_out;
    register #(.WIDTH(32)) F_PC(.clock(~clockCTRL), .reset(reset), .we(pc_fd_weCTRL), 
    .dataWrite(fpc_in_4), .dataRead(fpc_out));

    //PC + 1
    wire [31:0] fpc_out_1;
    alu_add_full my_add(.data_result(fpc_out_1), .overflow(), 
    .data_operandA(fpc_out), .data_operandB(32'b0), .c0(1'b1));

    //PC mux
    wire x_BNE_BLT_and_out;
    wire [31:0] x_pc_adder_out;
    alu_mux_2 #(.WIDTH(32)) F_mux1(.out(fpc_in_1), .select(x_BNE_BLT_and_out), 
    .in0(fpc_out_1), .in1(x_pc_adder_out));

    wire x_isJump;
    wire x_isJal;
    wire x_isTrueBex;
    wire[31:0] x_target;
    alu_mux_2 #(.WIDTH(32)) F_mux2(.out(fpc_in_2), .select(x_isJump || x_isJal || x_isTrueBex), 
    .in0(fpc_in_1), .in1(x_target));

    wire x_isJr;
    wire [31:0] x_jr_target;
    alu_mux_2 #(.WIDTH(32)) F_mux3(.out(fpc_in_3), .select(x_isJr), 
    .in0(fpc_in_2), .in1(x_jr_target));

    alu_mux_2 #(.WIDTH(32)) F_mux4(.out(fpc_in_4), .select(pc_NOP_select), 
    .in0(fpc_in_3), .in1(NOP));

    //PC Changed Flag
    wire f_newPCSet;
    assign f_newPCSet = (x_BNE_BLT_and_out || x_isJump || x_isJal || x_isTrueBex || x_isJr);

    //Imem
    assign address_imem = fpc_out;

    //FD_PC Register
    wire[31:0] fdpc_out;
    register #(.WIDTH(32)) FD_PC(.clock(~clockCTRL), .reset(reset), .we(pc_fd_weCTRL), 
    .dataWrite(fpc_out_1), .dataRead(fdpc_out));

    //FD_IR Register
    wire[31:0] fdir_in;

    alu_mux_2 #(.WIDTH(32)) F_mux5(.out(fdir_in), .select(fd_NOP_select), 
    .in0(q_imem), .in1(NOP));

    register #(.WIDTH(32)) FD_IR(.clock(~clockCTRL), .reset(reset), .we(pc_fd_weCTRL), 
    .dataWrite(fdir_in), .dataRead(fdir_out));

    // ================DECODE STAGE=================== //

    //Register File Inputs (readA, readB)
    wire d_mux_select1;
    assign d_mux_select1 = (fdir_out[31:27] == 5'b00111) 
    || (fdir_out[31:27] == 5'b00010)
    || (fdir_out[31:27] == 5'b00110)
    || (fdir_out[31:27] == 5'b00001)
    || (fdir_out[31:27] == 5'b00011)
    || (fdir_out[31:27] == 5'b00100);
    alu_mux_2 #(.WIDTH(5)) D_mux1(.out(ctrl_readRegB), .select(d_mux_select1), 
    .in0(fdir_out[16:12]), .in1(fdir_out[26:22]));

    wire d_mux_select2;
    assign d_mux_select2 = (fdir_out[31:27] == 5'b10110);
    alu_mux_2 #(.WIDTH(5)) D_mux2(.out(ctrl_readRegA), .select(d_mux_select2), 
    .in0(fdir_out[21:17]), .in1(5'b11110));

    //DX_PC Register
    wire[31:0] dxpc_out;
    register #(.WIDTH(32)) DX_PC(.clock(~clockCTRL), .reset(reset), .we(weCTRL), 
    .dataWrite(fdpc_out), .dataRead(dxpc_out));

    //DX_A Register
    wire[31:0] dxa_out;
    register #(.WIDTH(32)) DX_A(.clock(~clockCTRL), .reset(reset), .we(weCTRL), 
    .dataWrite(data_readRegA), .dataRead(dxa_out));

    //DX_B Register
    wire[31:0] dxb_out;
    register #(.WIDTH(32)) DX_B(.clock(~clockCTRL), .reset(reset), .we(weCTRL), 
    .dataWrite(data_readRegB), .dataRead(dxb_out));

    //DX_CtrlA Register
    wire[4:0] dxa_ctrl_out;
    register #(.WIDTH(5)) DX_CtrlA(.clock(~clockCTRL), .reset(reset), .we(weCTRL), 
    .dataWrite(ctrl_readRegA), .dataRead(dxa_ctrl_out));

    //DX_CtrlB Register
    wire[4:0] dxb_ctrl_out;
    register #(.WIDTH(5)) DX_CtrlB(.clock(~clockCTRL), .reset(reset), .we(weCTRL), 
    .dataWrite(ctrl_readRegB), .dataRead(dxb_ctrl_out));

    //DX_IR Register
    wire [31:0] x_customExInstruct;
    wire[31:0] dxir_in1, dxir_in2;
    alu_mux_2 #(.WIDTH(32)) D_mux3(.out(dxir_in1), .select(x_anyExcep), 
    .in0(fdir_out), .in1(x_customExInstruct));

    alu_mux_2 #(.WIDTH(32)) D_mux4(.out(dxir_in2), .select(dx_NOP_select), 
    .in0(dxir_in1), .in1(NOP));

    register #(.WIDTH(32)) DX_IR(.clock(~clockCTRL), .reset(reset), .we(weCTRL), 
    .dataWrite(dxir_in2), .dataRead(dxir_out));

    // ================EXECUTE STAGE================= //

    /////DX_A and XM_O Mux (MX and WX)

    //MX Bypassing for A
    //Need any situation where 
    //DX.IR.A (AND read) == XM.IR.RD (AND write)
    //Special Read bex($30)
    //Special Write setx($30) jal($31)
    wire[4:0] DX_IR_A, XM_IR_RD;
    wire x_readDX_A, x_writeXM_RD, x_writeXM_r30, x_writeXM_r31, x_readDX_r30_A;
    assign DX_IR_A = dxa_ctrl_out;
    assign XM_IR_RD = xmir_out[26:22];

    assign x_readDX_A = (dxir_out[31:27] == 5'b00000)
    || (dxir_out[31:27] == 5'b00111)
    || (dxir_out[31:27] == 5'b01000)
    || (dxir_out[31:27] == 5'b00010)
    || (dxir_out[31:27] == 5'b00110)
    || (dxir_out[31:27] == 5'b00101);

    assign x_readDX_r30_A = (dxir_out[31:27] == 5'b10110);


    assign x_writeXM_RD = (xmir_out[31:27] == 5'b00000)
    || (xmir_out[31:27] == 5'b00101);

    assign x_writeXM_r30 = (xmir_out[31:27] == 5'b10101);
    assign x_writeXM_r31 = (xmir_out[31:27] == 5'b00011);

    
    wire x_needMXBypassA;
    assign x_needMXBypassA = 
    ((DX_IR_A == XM_IR_RD) && x_readDX_A && x_writeXM_RD && (XM_IR_RD != 5'b00000)) 
    || (x_writeXM_r30 && ((DX_IR_A == 5'b11110) || x_readDX_r30_A))
    || (x_writeXM_r31 && (DX_IR_A == 5'b11111));

    //MX Bypassing for B
    //Need any situation where 
    //DX.IR.B == XM.IR.RD
    wire[4:0] DX_IR_B;
    wire x_readDX_B;
    assign DX_IR_B = dxb_ctrl_out;

    assign x_readDX_B = (dxir_out[31:27] == 5'b00000)
    || (dxir_out[31:27] == 5'b00111) 
    || (dxir_out[31:27] == 5'b00010)
    || (dxir_out[31:27] == 5'b00110)
    || (dxir_out[31:27] == 5'b00001)
    || (dxir_out[31:27] == 5'b00011)
    || (dxir_out[31:27] == 5'b00100);
    
    wire x_needMXBypassB;
    assign x_needMXBypassB = 
    ((DX_IR_B == XM_IR_RD) && x_readDX_B && x_writeXM_RD && (XM_IR_RD != 5'b00000))
    || (x_writeXM_r30 && (DX_IR_B == 5'b11110))
    || (x_writeXM_r31 && (DX_IR_B == 5'b11111));

    //WX Bypassing for A
    //Need any situation where 
    //DX.IR.A == MW.IR.RD
    wire[4:0] MW_IR_RD;
    wire x_writeMW_RD, x_writeMW_r30, x_writeMW_r31;
    assign MW_IR_RD = mwir_out[26:22];

    assign x_writeMW_RD = (mwir_out[31:27] == 5'b00000)
    || (mwir_out[31:27] == 5'b01000)
    || (mwir_out[31:27] == 5'b00101);

    assign x_writeMW_r30 = (mwir_out[31:27] == 5'b10101);
    assign x_writeMW_r31 = (mwir_out[31:27] == 5'b00011);
    
    wire x_needWXBypassA;
    assign x_needWXBypassA = 
    ((DX_IR_A == MW_IR_RD) && x_readDX_A && x_writeMW_RD && (MW_IR_RD != 5'b00000))
    || (x_writeMW_r30 && ((DX_IR_A == 5'b11110) || x_readDX_r30_A))
    || (x_writeMW_r31 && (DX_IR_A == 5'b11111));

    //WX Bypassing for B
    //Need any situation where 
    //DX.IR.B == MW.IR.RD
    
    wire x_needWXBypassB;
    assign x_needWXBypassB = 
    ((DX_IR_B == MW_IR_RD) && x_readDX_B && x_writeMW_RD && (MW_IR_RD != 5'b00000))
    || (x_writeMW_r30 && (DX_IR_B == 5'b11110))
    || (x_writeMW_r31 && (DX_IR_B == 5'b11111));

    //WM Bypassing
    //Only matters for sw following lw

    wire x_needWMBypass, x_isXM_sw, x_isMW_lw, x_WM_sameReg;
    assign x_isXM_sw = (xmir_out[31:27] == 5'b00111);
    assign x_isMW_lw = (mwir_out[31:27] == 5'b01000);
    assign x_WM_sameReg = (xmir_out[26:22] == mwir_out[26:22]);

    assign x_needWMBypass = (x_isXM_sw && x_isMW_lw && x_WM_sameReg 
    && (mwir_out[26:22] != 5'b00000));


    //Final ALUs for Bypassing
    wire [31:0] x_selectedA, x_selectedA_in;
    alu_mux_2 #(.WIDTH(32)) X_muxA1Byp(.out(x_selectedA_in), .select(x_needWXBypassA), 
    .in0(dxa_out), .in1(w_mux_out));
    alu_mux_2 #(.WIDTH(32)) X_muxA2Byp(.out(x_selectedA), .select(x_needMXBypassA), 
    .in0(x_selectedA_in), .in1(xmo_out));

    wire [31:0] x_selectedB, x_selectedB_in;
    alu_mux_2 #(.WIDTH(32)) X_muxB1Byp(.out(x_selectedB_in), .select(x_needWXBypassB), 
    .in0(dxb_out), .in1(w_mux_out));
    alu_mux_2 #(.WIDTH(32)) X_muxB2Byp(.out(x_selectedB), .select(x_needMXBypassB), 
    .in0(x_selectedB_in), .in1(xmo_out));

    /////

    //MultDiv
    wire x_isMult; 
    wire x_isMultPrev;
    assign x_isMult = (dxir_out[31:27] == 5'b00000) && (dxir_out[6:2] == 5'b00110);
    wire x_isDiv;
    wire x_isDivPrev;
    assign x_isDiv = (dxir_out[31:27] == 5'b00000) && (dxir_out[6:2] == 5'b00111);

    wire x_ctrl_mult;
    dffe_ref X_dff_1(.q(x_isMultPrev), .d(x_isMult), .clk(!clock), .en(1'b1), .clr(reset));
    assign x_ctrl_mult = (x_isMult && !x_isMultPrev);

    wire x_ctrl_div;
    dffe_ref X_dff_2(.q(x_isDivPrev), .d(x_isDiv), .clk(!clock), .en(1'b1), .clr(reset));
    assign x_ctrl_div = (x_isDiv && !x_isDivPrev);

    wire x_md_data_resultRDY;
    wire [31:0] x_md_data_result;
    wire x_md_exception;
    multdiv X_multdiv(.data_operandA(x_selectedA), .data_operandB(x_selectedB), 
    .ctrl_MULT(x_ctrl_mult), .ctrl_DIV(x_ctrl_div), .clock(clock), 
	.data_result(x_md_data_result), .data_exception(x_md_exception), .data_resultRDY(x_md_data_resultRDY));

    assign x_freeze_for_md = (x_isMult || x_isDiv) && (!x_md_data_resultRDY);

    //Sign Extended Immediate
    wire[31:0] x_immediate, x_immediate_se;
    assign x_immediate[16:0] = dxir_out[16:0];
    alu_mux_2 #(.WIDTH(15)) X_mux1(.out(x_immediate_se[31:17]), .select(x_immediate[16]), 
    .in0(15'b000000000000000), .in1(15'b111111111111111));
    assign x_immediate_se[16:0] = x_immediate[16:0];

    //T (Target) Construction
    assign x_target[31:27] = 5'b00000;
    assign x_target[26:0] = dxir_out[26:0];

    //Jr Target Construction (Special Case)
    assign x_jr_target = x_selectedB;

    //Jump Logic
    assign x_isJump = (dxir_out[31:27] == 5'b00001);

    //Jal Logic
    assign x_isJal = (dxir_out[31:27] == 5'b00011);

    //Jr Logic
    assign x_isJr = (dxir_out[31:27] == 5'b00100);

    //True bex logic
    assign x_isTrueBex = ((dxir_out[31:27] == 5'b10110)
    && (x_selectedA != 0));

    //SetX Logic
    wire x_isSetx;
    assign x_isSetx = (dxir_out[31:27] == 5'b10101);

    //PC Adder
    alu_add_full X_pc_adder(.data_result(x_pc_adder_out), .overflow(), 
    .data_operandA(dxpc_out), .data_operandB(x_immediate_se), .c0(1'b0));

    //DX_B and Immediate Mux
    wire x_mux_select;
    wire [31:0] x_mux_out;
    assign x_mux_select = (dxir_out[31:27] == 5'b00101) 
    || (dxir_out[31:27] == 5'b00111) 
    || (dxir_out[31:27] == 5'b01000);
    alu_mux_2 #(.WIDTH(32)) X_mux2(.out(x_mux_out), .select(x_mux_select), 
    .in0(x_selectedB), .in1(x_immediate_se));

    //ALU OpCode
    wire [4:0] x_alu_op, x_alu_op2;
    alu_mux_2 #(.WIDTH(5)) X_mux3(.out(x_alu_op), .select(x_mux_select), 
    .in0(dxir_out[6:2]), .in1(5'b00000));

    wire x_mux_select2;
    assign x_mux_select2 = (dxir_out[31:27] == 5'b00010)
    ||(dxir_out[31:27] == 5'b00110);
    alu_mux_2 #(.WIDTH(5)) X_mux4(.out(x_alu_op2), .select(x_mux_select2), 
    .in0(x_alu_op), .in1(5'b00001));

    //ALU
    wire[31:0] x_alu_out;
    wire x_isNotEqual;
    wire x_isLessThan;
    wire x_ALUover;
    alu X_alu(.data_operandA(x_selectedA), .data_operandB(x_mux_out), 
    .ctrl_ALUopcode(x_alu_op2), .ctrl_shiftamt(dxir_out[11:7]), 
    .data_result(x_alu_out), .isNotEqual(x_isNotEqual), 
    .isLessThan(x_isLessThan), .overflow(x_ALUover));

    //Exception CTRL
    wire x_isAddOver, x_isAddiOver, x_isSubOver, x_isMultOver, x_isDivOver;
    assign x_anyExcep = x_isAddOver || x_isAddiOver || x_isSubOver || x_isMultOver || x_isDivOver;
    assign x_isAddiOver = ((dxir_out[31:27] == 5'b00101) && x_ALUover);
    assign x_isAddOver = ((dxir_out[31:27] == 5'b00000) 
    && (dxir_out[6:2] == 5'b00000)
    && x_ALUover);
    assign x_isSubOver = ((dxir_out[31:27] == 5'b00000) 
    && (dxir_out[6:2] == 5'b00001)
    && x_ALUover);
    assign x_isMultOver = ((dxir_out[31:27] == 5'b00000) 
    && (dxir_out[6:2] == 5'b00110)
    && x_md_exception);
    assign x_isDivOver = ((dxir_out[31:27] == 5'b00000) 
    && (dxir_out[6:2] == 5'b00111)
    && x_md_exception);

    wire [2:0] x_over1, x_over2, x_over3, x_over4, x_overFinal;

    alu_mux_2 #(.WIDTH(3)) X_muxover1(.out(x_over1), .select(x_isAddOver), 
    .in0(3'b000), .in1(3'b001));
    alu_mux_2 #(.WIDTH(3)) X_muxover2(.out(x_over2), .select(x_isAddiOver), 
    .in0(x_over1), .in1(3'b010));
    alu_mux_2 #(.WIDTH(3)) X_muxover3(.out(x_over3), .select(x_isSubOver), 
    .in0(x_over2), .in1(3'b011));
    alu_mux_2 #(.WIDTH(3)) X_muxover4(.out(x_over4), .select(x_isMultOver), 
    .in0(x_over3), .in1(3'b100));
    alu_mux_2 #(.WIDTH(3)) X_muxover5(.out(x_overFinal), .select(x_isDivOver), 
    .in0(x_over4), .in1(3'b101));

    //This is an exception instruct that needs to run after the current instruct
    assign x_customExInstruct[31:27] = 5'b10101;
    assign x_customExInstruct[26:3] = 24'b000000000000000000000000;
    assign x_customExInstruct[2:0] = x_overFinal;

    //BNE/BLT And Gate
    wire x_isBNE, x_isBLT;
    assign x_isBNE = (dxir_out[31:27] == 5'b00010);
    assign x_isBLT = (dxir_out[31:27] == 5'b00110);
    assign x_BNE_BLT_and_out = (x_isNotEqual & x_isBNE)
    || (x_isNotEqual & !x_isLessThan & x_isBLT);

    //XM_O Register
    wire [31:0] xmo_in0, xmo_in1, xmo_in2, xmo_in3;

    alu_mux_2 #(.WIDTH(32)) X_mux8(.out(xmo_in0), .select(x_ALUover), 
    .in0(x_alu_out), .in1(NOP));

    alu_mux_2 #(.WIDTH(32)) X_mux5(.out(xmo_in1), .select(x_isJal), 
    .in0(xmo_in0), .in1(dxpc_out));

    alu_mux_2 #(.WIDTH(32)) X_mux6(.out(xmo_in2), .select(x_isMult || x_isDiv), 
    .in0(xmo_in1), .in1(x_md_data_result));

    alu_mux_2 #(.WIDTH(32)) X_mux7(.out(xmo_in3), .select(x_isSetx), 
    .in0(xmo_in2), .in1(x_target));

    register #(.WIDTH(32)) XM_O(.clock(~clockCTRL), .reset(reset), .we(weCTRL), 
    .dataWrite(xmo_in3), .dataRead(xmo_out));

    //XM_B Register
    wire[31:0] xmb_out;
    register #(.WIDTH(32)) XM_B(.clock(~clockCTRL), .reset(reset), .we(weCTRL), 
    .dataWrite(x_selectedB), .dataRead(xmb_out));

    //XM_IR Register
    wire[31:0] xmir_out;
    register #(.WIDTH(32)) XM_IR(.clock(~clockCTRL), .reset(reset), .we(weCTRL), 
    .dataWrite(dxir_out), .dataRead(xmir_out));

    // ================MEMORY STAGE=============== //

    //DMEM
    assign address_dmem = xmo_out;
    alu_mux_2 #(.WIDTH(32)) M_mux1(.out(data), .select(x_needWMBypass), 
    .in0(xmb_out), .in1(w_mux_out));
    assign wren = (xmir_out[31:27] == 5'b00111);

    //MW_O Register
    wire[31:0] mwo_out;
    register #(.WIDTH(32)) MW_O(.clock(~clockCTRL), .reset(reset), .we(weCTRL), 
    .dataWrite(xmo_out), .dataRead(mwo_out));

    //MW_D Register
    wire[31:0] mwd_out;
    register #(.WIDTH(32)) MW_D(.clock(~clockCTRL), .reset(reset), .we(weCTRL), 
    .dataWrite(q_dmem), .dataRead(mwd_out));

    //MW_IR Register
    wire[31:0] mwir_out;
    register #(.WIDTH(32)) MW_IR(.clock(~clockCTRL), .reset(reset), .we(weCTRL), 
    .dataWrite(xmir_out), .dataRead(mwir_out));

    // ================WRITEBACK STAGE=============== //

    //MW_O and MW_D Mux
    wire w_mux_select;
    assign w_mux_select = (mwir_out[31:27] == 5'b01000);
    alu_mux_2 #(.WIDTH(32)) W_mux1(.out(w_mux_out), .select(w_mux_select), 
    .in0(mwo_out), .in1(mwd_out));

    //Register File Inputs
    assign ctrl_writeEnable = (mwir_out[31:27] == 5'b00000) 
    || (mwir_out[31:27] == 5'b00101) 
    || (mwir_out[31:27] == 5'b01000)
    || (mwir_out[31:27] == 5'b00011)
    || (mwir_out[31:27] == 5'b10101);

    wire w_isJal;
    assign w_isJal = (mwir_out[31:27] == 5'b00011);
    wire w_isSetx;
    assign w_isSetx = (mwir_out[31:27] == 5'b10101);
    wire [4:0] ctrl_writeRegIn1;
    alu_mux_2 #(.WIDTH(5)) W_mux2(.out(ctrl_writeRegIn1), .select(w_isJal), 
    .in0(mwir_out[26:22]), .in1(5'b11111));
    alu_mux_2 #(.WIDTH(5)) W_mux3(.out(ctrl_writeReg), .select(w_isSetx), 
    .in0(ctrl_writeRegIn1), .in1(5'b11110));
    assign data_writeReg = w_mux_out;
	
	/* END CODE */

endmodule
