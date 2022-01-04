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

.ENDS

.def HFOV 70
.def NUM_SCANLINES 192
.def NUM_VECTOR_DOUBLES 4
.def NUM_VECTOR_ANGLES NUM_SCANLINES/2 
;half the size of the trig tables by only rendering half the scanlines with different angles

.slot "ROM"


.SECTION "Initial X Vector table Top Right", FREE
YVectorTableBottomRight:
XVectorTableTopRight:   .DBSIN	0, 90 / HFOV * NUM_SCANLINES , HFOV / NUM_SCANLINES, 255.999 / (2^NUM_VECTOR_DOUBLES), 0
.ENDS

.SECTION "Initial X Vector table Bottom Right", FREE
YVectorTableBottomLeft:
XVectorTableBottomRight:   .DBSIN	90, 90 / HFOV * NUM_SCANLINES , HFOV / NUM_SCANLINES, 255.999 / (2^NUM_VECTOR_DOUBLES), 0
.ENDS

.SECTION "Initial X Vector table Bottom Left", FREE
YVectorTableTopLeft:
XVectorTableBottomLeft:   .DBSIN    180, 90 / HFOV * NUM_SCANLINES , HFOV / NUM_SCANLINES, 255.999 / (2^NUM_VECTOR_DOUBLES), 0
.ENDS

.SECTION "Initial X Vector table Top Left", FREE
YVectorTableTopRight:
XVectorTableTopLeft:   .DBSIN    270, 90 / HFOV * NUM_SCANLINES , HFOV / NUM_SCANLINES, 255.999 / (2^NUM_VECTOR_DOUBLES), 0
.ENDS


.SECTION "Draw Frame Top Right", FREE
DrawFrame:
DrawFrameTopRight:
    lda wPlayerFacingAngle
    sta wRayAngle ;copy the permanent angle to a temporary copy used for ray casting

    lda wPlayerX + 1
    asl a
    tay ;get the offset to the level data pointer
    lda wPlayerY + 1
    sta wLevelPtrHigh ;store the high byte of the level pointer

CastRayTopRight:
    ;start by getting the X and Y componesnts of the ray
    ldx wRayAngle
    cpx # 90 / HFOV * NUM_SCANLINES + 1
    bcc _continue

_continue
    lda.w XVectorTableTopRight,x ;get the initial x component of the ray
    lsr a ;the x component get halved for the first half-step
    sta wXComponent

    ; now cast the ray the first half-step
    adc wPlayerX ;add the player's x coordinate to the x component of the ray
    sta wRayX ;store the new x coordinate of the ray
    bcc _first_x_done

    ;if the ray's fractional x coordinate overflowed, then increment the integer part
    ;this is in Y
    iny
    iny

    ;now check for collision with the level
    iny
    lda (wLevelPtr),y ;read the level data
    beq _first_x_done_dey

    ;if the ray hit a wall, then a contains the wall's color
    sta COLUPF
    lda #$ff
    sta PF0 ;fill the playfield
    sta PF1
    sta PF2

    jmp CastRayTopRight

_first_x_done_dey
    dey

_first_x_done
    lda.w YVectorTableTopRight,x ;get the initial y component of the ray
    ; no halving for the Y
    sta wYComponent




    

.ENDS