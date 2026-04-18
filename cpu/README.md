# Processor
## NAME (NETID)
Aidan Hall (jah202)


## Description of Design
The is the final submission of my CPU: Complete CPU. This version can handle all instructions from the provided ISA with bypassing and stalling as well. The overall structure is a word-addressed 32-bit 5-stage pipeline CPU with stages Fetch (F), Decode (D), Execute (X), Memory (M), and Writeback (W). The purpose of each is the following:

1. Fetch: Manages PC, gets corresponding instruction from Imem.
2. Decode: Reads chosen registers from register file.
3. Execute: Computes relevant calculations from the ALU or MultDiv module for later use, flags for exceptions, changes the PC if necessary (resulting in a flush operation), holds all the bypass logic (see bypassing section).
4. Memory: Allows for reads and writes in Dmem.
5. Writeback: Writes relevant data into chosen register in regfile.

In each stage their is a variety of logic/hardware to implement the features of that stage. In between each section, there are registers that store the results of the previous stage on the falling edge of the clock. Most wires and common modules used have a prefix to describe which section they are a part of, typically within one of the 5 stages or between them. There are also extra sections before the main pipeline called "Necessary Top Wire Declarations", "Stall", "Clock / WE Management", "NOP". The purpose of each is the following:

1. Necessary Top Wire Declarations: Needed to use some wires that are assigned later in earlier contexts, so defines them here at the top.
2. Stall: Stall Management (see stalling section).
3. Clock / WE Management: Allows for manipulation of the clock and write enable of registers. Clock manipulation is no longer used as it was unnecessary. Seperate WE control for the registers in the fetch stage and the rest of the registers in the CPU.
4. NOP: Creates a NOP and handles the flags for when it should be used.


## Bypassing
Implemented 3 different types of bypassing to avoid data hazards: Memory-Execute (MX), Writeback-Execute (WX), Writeback-Memory (WM). Each works as follows:

1. MX: If a register's value is about to be used in the execute stage and if the value may be updated in the memory stage since it was pulled from the register file, it bypasses the updated value of this register to the execute stage. This occurs for both A and B in the DX register.
2. WX: If a register's value is about to be used in the execute stage and if the value may be updated in the writeback stage since it was pulled from the register file, it bypasses the updated value of this register to the execute stage. This occurs for both A and B in the DX register.
3. WM: If a register's value is about to be used in the memory stage and if the value may be updated in the writeback stage since it was pulled from the register file, it bypasses the updated value of this register to the memory stage. This occurs for B in the XM register.

Note that there are cases in which there can be both a MX and WX bypass on the same value. In this case, the MX bypass takes precedence over the WX bypass.


## Stalling
Developed typical stalling process where the fetch registers are frozen (WE disabled), the DX register recieves a custom input, and the rest of the register continue. The cases are:

1. Unbypassable data hazard: Stalls fetch registers and pushes NOP through DX register. Logic for when to use on Lecture 13 slides 31-32.
2. Exception: Stalls fetch registers and pushes corresponding setx exception instruction through DX register. Occurs whenever an exception results from the execute stage.
3. Mult-Mult Div-Div: Because of how the multdiv module keeps track of when to operate, a mult operation followed directly by a mult operation or div operation followed directly by a div operation causes an issue. To resolve this, the fetch registers stall, and push a NOP between the two operations in these two edge cases.

4. (Special Case) MultDiv computation: All registers are stalled until the MultDiv module completes its calculation.


## Optimizations
No optimizations were used outside of basic CPU construction discussed in class / lecture slides.


## Bugs
No bugs! Autograder score 150/150.