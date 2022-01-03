.include "defines.asm"

DoLogic:
    ; Enable VBLANK again
	lda #2
	sta VBLANK
	; 30 lines of overscan 
	ldx #30
LVOver	sta WSYNC
	dex
	bne LVOver

; Enable VBLANK (disable output)
	lda #2
    sta VBLANK
; At the beginning of the frame we set the VSYNC bit...
	lda #2
	sta VSYNC
; And hold it on for 3 scanlines...
	sta WSYNC
	sta WSYNC
	sta WSYNC
; Now we turn VSYNC off.
	lda #0
	sta VSYNC

; Now we need 37 lines of VBLANK...
	ldx #37
LVBlank	sta WSYNC	; accessing WSYNC stops the CPU until next scanline
	dex		; decrement X
	bne LVBlank	; loop until X == 0

; Re-enable output (disable VBLANK)
	lda #0
    sta VBLANK

    jmp DrawFrame