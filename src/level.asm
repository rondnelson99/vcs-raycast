.INCLUDE "defines.asm"
.def NUM_ROWS 16
.def NUM_COLS 16
.ARRAYDEFINE NAME level_horiz SIZE NUM_ROWS*NUM_COLS
.ARRAYDEFINE NAME level_vert SIZE NUM_ROWS*NUM_COLS
.ARRAYIN level_horiz 0*NUM_ROWS  8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
.ARRAYIN level_vert 0*NUM_COLS  8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
.ARRAYIN level_horiz 1*NUM_ROWS  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.ARRAYIN level_vert 1*NUM_COLS  8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
.ARRAYIN level_horiz 2*NUM_ROWS  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.ARRAYIN level_vert 2*NUM_COLS  8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
.ARRAYIN level_horiz 3*NUM_ROWS  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.ARRAYIN level_vert 3*NUM_COLS  8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
.ARRAYIN level_horiz 4*NUM_ROWS  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.ARRAYIN level_vert 4*NUM_COLS  8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
.ARRAYIN level_horiz 5*NUM_ROWS  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.ARRAYIN level_vert 5*NUM_COLS  8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
.ARRAYIN level_horiz 6*NUM_ROWS  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.ARRAYIN level_vert 6*NUM_COLS  8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
.ARRAYIN level_horiz 7*NUM_ROWS  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.ARRAYIN level_vert 7*NUM_COLS  8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
.ARRAYIN level_horiz 8*NUM_ROWS  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.ARRAYIN level_vert 8*NUM_COLS  8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
.ARRAYIN level_horiz 9*NUM_ROWS  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.ARRAYIN level_vert 9*NUM_COLS  8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
.ARRAYIN level_horiz 10*NUM_ROWS 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.ARRAYIN level_vert 10*NUM_COLS 8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
.ARRAYIN level_horiz 11*NUM_ROWS 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.ARRAYIN level_vert 11*NUM_COLS 8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
.ARRAYIN level_horiz 12*NUM_ROWS 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.ARRAYIN level_vert 12*NUM_COLS 8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
.ARRAYIN level_horiz 13*NUM_ROWS 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.ARRAYIN level_vert 13*NUM_COLS 8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
.ARRAYIN level_horiz 14*NUM_ROWS 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.ARRAYIN level_vert 14*NUM_COLS 8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
.ARRAYIN level_horiz 15*NUM_ROWS 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
.ARRAYIN level_vert 15*NUM_COLS 8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8

;define a macro for each row of the level
.macro level_row 
    .slot 0
    .orga $f000 + (ROW << 8)
    .section "level_row_\1" FORCE
        LevelRow\1:
        .rept NUM_COLS index COL
            .arraydb level_horiz COL+ROW*NUM_COLS
            .arraydb level_vert COL+ROW*NUM_COLS
        .endr
    .ends
.endm

;now actually write the level
.rept NUM_ROWS index ROW
    level_row ROW
.endr










