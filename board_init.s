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