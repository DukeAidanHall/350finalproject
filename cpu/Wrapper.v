`timescale 1ns / 1ps
/**
 * 
 * READ THIS DESCRIPTION:
 *
 * This is the Wrapper module that will serve as the header file combining your processor, 
 * RegFile and Memory elements together.
 *
 * This file will be used to generate the bitstream to upload to the FPGA.
 * We have provided a sibling file, Wrapper_tb.v so that you can test your processor's functionality.
 * 
 * We will be using our own separate Wrapper_tb.v to test your code. You are allowed to make changes to the Wrapper files 
 * for your own individual testing, but we expect your final processor.v and memory modules to work with the 
 * provided Wrapper interface.
 * 
 * Refer to Lab 5 documents for detailed instructions on how to interface 
 * with the memory elements. Each imem and dmem modules will take 12-bit 
 * addresses and will allow for storing of 32-bit values at each address. 
 * Each memory module should receive a single clock. At which edges, is 
 * purely a design choice (and thereby up to you). 
 * 
 * You must change line 36 to add the memory file of the test you created using the assembler
 * For example, you would add sample inside of the quotes on line 38 after assembling sample.s
 *
 **/

module Wrapper (clock, reset, BTNC_In, BTND_In, 
Column_In, Err_out, Win1_out, Win2_out);

	input clock, reset;
	input [31:0] BTNC_In, BTND_In, Column_In;

	output reg Err_out, Win1_out, Win2_out;

	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut;


	// ADD YOUR MEMORY FILE HERE
	localparam INSTR_FILE = "connectFour";

	//Logic for memory mapped I
	wire useBTNC, useBTND, useColumn;
	wire [31:0] memDataOut1, memDataOut2, memDataOut3;
	assign useBTNC = (memAddr[11:0] == 12'd400);
	assign useBTND = (memAddr[11:0] == 12'd401);
	assign useColumn = (memAddr[11:0] == 12'd402);

	assign memDataOut1 = (useBTNC) ? BTNC_In : memDataOut;
	assign memDataOut2 = (useBTND) ? BTND_In : memDataOut1;
	assign memDataOut3 = (useColumn) ? Column_In : memDataOut2;

	//Logic for memory mapped O
	wire useErr, useWin1, useWin2;
	assign useErr = mwe && (memAddr[11:0] == 12'd300);
	assign useWin1 = mwe && (memAddr[11:0] == 12'd502);
	assign useWin2 = mwe && (memAddr[11:0] == 12'd501);
	
	
	wire ram_mwe;
	assign ram_mwe = mwe && (!useErr & !useWin1 & !useWin2);

	always @(posedge clock) begin
	    if (reset) begin
		    Err_out <= 1'b0;
		    Win1_out <= 1'b0;
		    Win2_out <= 1'b0;
		end
		else if (useErr) begin
			Err_out <= memDataIn[0];
		end
		else if (useWin1) begin
			Win1_out <= memDataIn[0];
		end
		else if (useWin2) begin
			Win2_out <= memDataIn[0];
		end
	end
	
	// Main Processing Unit
	processor CPU(.clock(clock), .reset(reset), 
								
		// ROM
		.address_imem(instAddr), .q_imem(instData),
									
		// Regfile
		.ctrl_writeEnable(rwe),     .ctrl_writeReg(rd),
		.ctrl_readRegA(rs1),     .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
									
		// RAM
		.wren(mwe), .address_dmem(memAddr), 
		.data(memDataIn), .q_dmem(memDataOut3)); 
	
	// Instruction Memory (ROM)
	ROM #(.MEMFILE({INSTR_FILE, ".mem"}))
	InstMem(.clk(clock), 
		.addr(instAddr[11:0]), 
		.dataOut(instData));
	
	// Register File
	regfile RegisterFile(.clock(clock), 
		.ctrl_writeEnable(rwe), .ctrl_reset(reset), 
		.ctrl_writeReg(rd),
		.ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB));
						
	// Processor Memory (RAM)
	RAM ProcMem(.clk(clock), 
		.wEn(ram_mwe), 
		.addr(memAddr[11:0]), 
		.dataIn(memDataIn), 
		.dataOut(memDataOut));

endmodule
