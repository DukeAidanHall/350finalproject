### =============== START =================
CPUstart:
j init


### =============== MAIN LOOP =================
CPUloop:
bne r27, r0, update     #r27 is drop flag [INPUT]
j CPUloop



init:
### ================ INIT ================
##ALL THE ZEROS
addi r1, r0, 0          # pointer
addi r2, r0, 156        # counter
addi r3, r0, 0          # value

0loop:                   # all 0 board loop
    sw r3, 0(r1)
    addi r1, r1, 1
    addi r2, r2, -1
    bne r2, r0, 0loop


##ALL THE ONES
addi r1, r0, 39         # pointer
addi r3, r0, 1          # value
addi r4, r0, 7          # counter A
1loopA:                 # all 1 board loop
    addi r2, r0, 6      # counter B
    addi r4, r4, -1
    1loopB:
        sw r3, 0(r1)
        addi r1, r1, 1
        addi r2, r2, -1
        bne r2, r0, 1loopB
    addi r1, r1, 7
    bne r4, r0, 1loopA


##COUNTERS
addi r1, r0, 203        # pointer
addi r3, r0, 3          # value

sw r3, 0(r1)            # memory 203 (column 3)
addi r1, r1, 1
sw r3, 0(r1)            # memory 204 (column 4)
addi r1, r1, 1
sw r3, 0(r1)            # memory 205 (column 5)
addi r1, r1, 1
sw r3, 0(r1)            # memory 206 (column 6)
addi r1, r1, 1
sw r3, 0(r1)            # memory 207 (column 7)
addi r1, r1, 1
sw r3, 0(r1)            # memory 208 (column 8)
addi r1, r1, 1
sw r3, 0(r1)            # memory 209 (column 9)

addi r29, r0, 3         # set initial player

j CPUloop


update:
### ================ UPDATE ================

addi r3, r0, 3
bne r29, r3, player2

addi r29, r0, 2
j editBoard

player2:
addi r29, r0, 3

editBoard:

##EDIT BOARD
add r1, r0, r28         # r28 is column flag [INPUT from servo]
add r8, r0, r29         # r29 is player flag

lw r2, 200(r1)          # get height

#LANDING SPOT COMPUTATION
addi r3, r0, 12         # 12
mul r4, r3, r1          # column * 12
add r5, r4, r2          # landingSpot = column * 12 + height

#UPDATE LOGIC
lw r6, 0(r5)            # get memory[landingSpot]
addi r7, r0, 1          # r7 = 1
bne r6, r7, error       # if memory[landingSpot] != 1, ERROR

sw r8, 0(r5)            # memory[landingSpot] = X
addi r2, r2, 1          # height + 1
sw r2, 200(r1)          # set height counter = height + 1


##CHECK FOR WIN

#SETTING REGISTERS
add r1, r0, r5          # r1 = landingSpot address
add r2, r0, r8          # r2 = player 2 or 3
lw r3, 1(r1)            # r3 = memory[landingSpot + 1]
lw r4, 2(r1)            # r4 = memory[landingSpot + 2]
lw r5, 3(r1)            # r5 = memory[landingSpot + 3]
lw r6, 13(r1)           # r6 = memory[landingSpot + 13]
lw r7, 26(r1)           # r7 = memory[landingSpot + 26]
lw r8, 39(r1)           # r8 = memory[landingSpot + 39]
lw r9, 12(r1)           # r9 = memory[landingSpot + 12]
lw r10, 24(r1)          # r10 = memory[landingSpot + 24]
lw r11, 36(r1)          # r11 = memory[landingSpot + 36]
lw r12, 11(r1)          # r12 = memory[landingSpot + 11]
lw r13, 22(r1)          # r13 = memory[landingSpot + 22]
lw r14, 33(r1)          # r14 = memory[landingSpot + 33]

lw r15, -1(r1)          # r15 = memory[landingSpot - 1]
lw r16, -2(r1)          # r16 = memory[landingSpot - 2]
lw r17, -3(r1)          # r17 = memory[landingSpot - 3]
lw r18, -13(r1)         # r18 = memory[landingSpot - 13]
lw r19, -26(r1)         # r19 = memory[landingSpot - 26]
lw r20, -39(r1)         # r20 = memory[landingSpot - 39]
lw r21, -12(r1)         # r21 = memory[landingSpot - 12]
lw r22, -24(r1)         # r22 = memory[landingSpot - 24]
lw r23, -36(r1)         # r23 = memory[landingSpot - 36]
lw r24, -11(r1)         # r24 = memory[landingSpot - 11]
lw r25, -22(r1)         # r25 = memory[landingSpot - 22]
lw r26, -33(r1)         # r26 = memory[landingSpot - 33]

#Case 1
bne r2, r3, endcase1
bne r2, r4, endcase1
bne r2, r5, endcase1
j WIN
endcase1:

#Case 2
bne r2, r6, endcase2
bne r2, r7, endcase2
bne r2, r8, endcase2
j WIN
endcase2:

#Case 3
bne r2, r9, endcase3
bne r2, r10, endcase3
bne r2, r11, endcase3
j WIN
endcase3:

#Case 4
bne r2, r12, endcase4
bne r2, r13, endcase4
bne r2, r14, endcase4
j WIN
endcase4:

#Case 5
bne r2, r15, endcase5
bne r2, r16, endcase5
bne r2, r17, endcase5
j WIN
endcase5:

#Case 6
bne r2, r18, endcase6
bne r2, r19, endcase6
bne r2, r20, endcase6
j WIN
endcase6:

#Case 7
bne r2, r21, endcase7
bne r2, r22, endcase7
bne r2, r23, endcase7
j WIN
endcase7:

#Case 8
bne r2, r24, endcase8
bne r2, r25, endcase8
bne r2, r26, endcase8
j WIN
endcase8:

#Case 9
bne r2, r3, endcase9
bne r2, r4, endcase9
bne r2, r15, endcase9
j WIN
endcase9:

#Case 10
bne r2, r6, endcase10
bne r2, r7, endcase10
bne r2, r18, endcase10
j WIN
endcase10:

#Case 11
bne r2, r9, endcase11
bne r2, r10, endcase11
bne r2, r21, endcase11
j WIN
endcase11:

#Case 12
bne r2, r12, endcase12
bne r2, r13, endcase12
bne r2, r24, endcase12
j WIN
endcase12:

#Case 13
bne r2, r15, endcase13
bne r2, r16, endcase13
bne r2, r3, endcase13
j WIN
endcase13:

#Case 14
bne r2, r18, endcase14
bne r2, r19, endcase14
bne r2, r6, endcase14
j WIN
endcase14:

#Case 15
bne r2, r21, endcase15
bne r2, r22, endcase15
bne r2, r9, endcase15
j WIN
endcase15:

#Case 16
bne r2, r24, endcase16
bne r2, r25, endcase16
bne r2, r12, endcase16
j WIN
endcase16:

j CPUloop

WIN:
# show X won
addi r1, r0, 1         # memory[300] = 1
sw r1, 300(r0)
j end

error:
# it failed
addi r1, r0, 1
sw r1, 301(r0)         # memory[301] = 1
j end

end: