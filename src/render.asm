.include "defines.asm"

.RAMSECTION "Render Vars" SLOT "RAM"
wPlayerX: dw ; Player X in 8.8 fixed point
wPlayerY: dw ; Player Y in 8.8 fixed point
wPlayerFacingAngle: db ;the scale of this is decided by the FOV
wPlayerFacingQuadrant: db  ;where 0 is top-right, 1 is bottom-right, 2 is bottom-left, 3 is top-left
wRayAngle: db ;the angle of the ray being cast
wRayX: db ;the x-coordinate of the ray being cast
wRayY: db ;the y-coordinate of the ray being cast
wXComponent: db ;the x component of the ray
wYComponent: db ;the y component of the ray
wLevelPtr: db ;the low byte of the level pointer
wLevelPtrHigh: db ;the high byte of the level pointer
wScanlineCount: db ;how many scanlines are left to draw

.ENDS

.def HFOV 70
.def NUM_SCANLINES 192
.def NUM_VECTOR_DOUBLES 4
.def NUM_VECTOR_ANGLES NUM_SCANLINES/2 
;half the size of the trig tables by only rendering half the scanlines with different angles
.def NUM_RAY_STEPS 13 ;how many times to march the ray in a loop until we just give up




.slot "ROM"

.macro playfield0 args SIZE
    .db $ff00 >> (SIZE - 16) & $ff
.endm
.macro playfield1 args SIZE
    .db ($ffff << (SIZE - 8)) >> 16 & $ff
.endm
.macro playfield2 args SIZE
    .db $ffffff00 >> (SIZE) & $ff
.endm



.arraydefine pfSizePerStep NUM_RAY_STEPS
.arrayin pfSizePerStep 0 19,14,11,10,8,7,6,5,4,3,2,1,1

.SECTION "PF0 per ray step", FREE
    .rept NUM_RAY_STEPS

    .endr
.ENDS

.SECTION "Vector Double Table", FREE
VectorDoubleTable:
; uses 0 and 1 bytes to tell whether to shift the ray step vectors left or not
; this is indexed using a decrementing pointer, so the order is backwards
.db 0,0,1,1,0,1,1,0,0,0,0,0,0
.ENDS



.SECTION "Initial X Vector table Top Right", FREE
YVectorTableBottomRight:
XVectorTableTopRight:   .DBSIN	0, 90 / HFOV * NUM_VECTOR_ANGLES , HFOV / NUM_VECTOR_ANGLES, 255.999 / (2^NUM_VECTOR_DOUBLES), 0
.ENDS

.SECTION "Initial X Vector table Bottom Right", FREE
YVectorTableBottomLeft:
XVectorTableBottomRight:   .DBSIN	90, 90 / HFOV * NUM_VECTOR_ANGLES , HFOV / NUM_VECTOR_ANGLES, 255.999 / (2^NUM_VECTOR_DOUBLES), 0
.ENDS

.SECTION "Initial X Vector table Bottom Left", FREE
YVectorTableTopLeft:
XVectorTableBottomLeft:   .DBSIN    180, 90 / HFOV * NUM_VECTOR_ANGLES , HFOV / NUM_VECTOR_ANGLES, 255.999 / (2^NUM_VECTOR_DOUBLES), 0
.ENDS

.SECTION "Initial X Vector table Top Left", FREE
YVectorTableTopRight:
XVectorTableTopLeft:   .DBSIN    270, 90 / HFOV * NUM_VECTOR_ANGLES , HFOV / NUM_VECTOR_ANGLES, 255.999 / (2^NUM_VECTOR_DOUBLES), 0
.ENDS


.SECTION "Draw Frame Top Right", FREE
DrawFrame:
    ; init the level pointer
    lda # LevelRow0 & $ff ;low byte of the level data chunks
    sta wLevelPtr
    lda wPlayerFacingAngle
    sta wRayAngle ;copy the permanent angle to a temporary copy used for ray casting
    
DrawFrameTopRight:
   
CastRayTopRight:
    inc wRayAngle
    lda wPlayerY + 1 ;high byte of the player y-coordinate
    ora #$f0 ;adjust the pointer to point to ROM
    sta wLevelPtrHigh
    lda wPlayerX + 1 ;high byte of the player x-coordinate
    asl
    tay ;20 cycles
    ;start by getting the X and Y componesnts of the ray
    ldx wRayAngle
    cpx # 90 / HFOV * NUM_VECTOR_ANGLES + 1
    bcc _continue_wait
    ;jmp CastRayBottomRight_continue
_continue_wait
    nop ;30 cycles
_continue
    lda.w XVectorTableTopRight,x ;get the initial x component of the ray
    sta wXComponent
    lsr a ;the x component get halved for the first half-step
    ; 39 cycles

    ; now cast the ray the first half-step
    adc wPlayerX ;add the player's x coordinate to the x component of the ray
    sta wRayX ;store the new x coordinate of the ray
    bcc _first_x_done 

    ;if the ray's fractional x coordinate overflowed, then increment the integer part
    ;this is in Y
    iny
    iny ;51 cycles

    ;now check for collision with the level
    iny
    lda (wLevelPtr),y ;read the level data
    beq _first_x_done_dey

    ;if the ray hit a wall, then a contains the wall's color
    sta COLUPF
    fill_pf_pixels 20

    jmp CastRayTopRight
_first_x_done_wait
    ;wait 15 cycles before moving to the Y
    jsr DelayRTS
    bcc _first_x_done
_first_x_done_dey
    dey ;63 cycles

_first_x_done
    ;the ray has now travelled approx. 1/4 of a step
    lda.w YVectorTableTopRight,x ;get the initial y component of the ray
    ; no halving for the Y
    sta wYComponent
    adc wPlayerY ;add the player's y coordinate to the y component of the ray
    sta wRayY ;store the new y coordinate of the ray
    bcs _first_y_done_wait ;78 cycles not taken
    ;if the ray's fractional y coordinate underflowed, then decrement the integer part
    ; this is in memory
    dec wLevelPtrHigh ;83 cycles
    ;now check for collision with the level
    lda (wLevelPtr),y ;read the level data
    beq _first_y_done
    ;if the ray hit a wall, then a contains the wall's color
    sta COLUPF
    fill_pf_pixels 20

    jmp CastRayTopRight
_first_y_done_wait
    ;wait 12 cycles before finishing
    jsr DelayRTS
_first_y_done

    ldx # NUM_RAY_STEPS
    ;91 cycles
_step_ray_loop_wsync
    sta WSYNC

_step_ray_loop
    ;first, check if we need to double the ray deltas
    lda VectorDoubleTable,x ; 4 cycles
    beq _skip_doubling ;6 cycles
    ;double the ray deltas
    asl wXComponent
    asl wYComponent ;16 cycles

_skip_doubling
    lda wRayX ; grab the ray x-coordinate 
    adc wXComponent
    sta wRayX ; store the x-coordinate
    bcc _x_done_wait\@ ;27 cycles
    ;if the ray's fractional x coordinate overflowed, then increment the integer part
    ;this is in Y
    iny
    iny ;31 cycles

    ;now check for collision with the level
    iny
    lda (wLevelPtr),y ;read the level data
    beq _x_done_dey\@ ;40 cycles

    fill_pf_pixels 20

    jmp CastRayTopRight
_x_done_wait\@
    ; 10 cycles have elapsed, so we need to wait 15 cycles before moving to the Y
    jsr DelayRTS
    bcc _x_done\@
_x_done_dey\@
    dey ;42 cycles

_x_done\@; 42 cycles elapsed

    lda wRayY
    adc wYComponent
    sta wRayY 
    bcs _y_done_wait\@ ;53 cycles not taken
    ;if the ray's fractional y coordinate underflowed, then decrement the integer part
    ; this is in memory
    dec wLevelPtrHigh ;58 cycles
    ;now check for collision with the level
    lda (wLevelPtr),y ;read the level data
    beq _y_done\@ ;66 cycles
    ;if the ray hit a wall, then a contains the wall's color
    sta COLUPF
    fill_pf_pixels 20

    jmp CastRayTopRight

_y_done_wait\@
    ; 39 cycles elapsed, so we need to wait 12 cycles before finishing
    jsr DelayRTS
_y_done\@ ;66 cycles have elapsed

_finish_ray_step
    dex ; moving to the next ray step ;68 cycles
    beq _exit ; 70 cycles
    jmp _step_ray_loop_wsync ;73 cycles, 76 after WSYNC

_exit ; exit after the ray goes too far. Allows a sort of "render distence" function.
.ends

/*
    ; the ray has now travveled approx. 3/4 steps
    stepRayTopRight 20 20 ;each one of these takes 49 cycles unless the ray collides with a wall
    ; the ray has now travveled approx. 1 3/4 steps
    stepRayTopRight 20 20
    ; the ray has now travveled approx. 2 3/4 steps
    jmp FourthStepTopRight
.ENDS

.SECTION "Draw Frame Top Right 2", FREE
FourthStepTopRight:
    stepRayTopRight 19 16
    ; the ray has now travveled approx. 3 3/4 steps

    stepRayTopRight 14 13
    ; the ray has now travveled approx. 4 3/4 steps
    stepRayTopRight 11 10
    
    jmp SeventhStepTopRight
.ends

.SECTION "Draw Frame Top Right 3", FREE
SeventhStepTopRight:
    ; the ray has now travveled approx. 5 3/4 steps
    stepRayTopRight 10 9
    ;the ray has now travveled approx. 6 3/4 steps
    ;now double the step size
    asl wXComponent
    asl wYComponent
    stepRayTopRight 8 7
    ;the ray has now travveled approx. 7 3/4 steps
    ;now double the step size again
    asl wXComponent
    asl wYComponent
    stepRayTopRight 6 5
    ;the ray has now travveled approx. 8 3/4 steps
    ;now double the step size again
    asl wXComponent
    asl wYComponent
    asl wYComponent ; double the Y step size twice

    jmp FinishTopRight
    
    
.ENDS
.SECTION "Draw Frame Top Right 4", FREE
FinishTopRight:
    stepRayTopRight 4 3
    asl wXComponent ;last shift
    ;the ray has now travveled approx. 9 3/4 steps
    stepRayTopRight 2 2
    ;now we just give up and clear the playfield
    lda #0
    sta PF0
    sta PF1
    sta PF2

    jmp CastRayTopRight
  
.ENDS*/