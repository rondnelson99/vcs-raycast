.include "defines.asm"

.SLOT "RAM"
.SECTION "rendering variables", FREE

	

.ENDS

.SLOT "ROM"
.SECTION "init", FREE


; The CLEAN_START macro zeroes RAM and registers
Start	CLEAN_START

DrawFrame:

; 192 scanlines are visible
; We'll draw some rainbows
	ldx #192
	lda BGColor	; load the background color out of RAM
ScanLoop
	adc #1		; add 1 to the current background color in A
	sta COLUBK	; set the background color
	sta WSYNC	; WSYNC doesn't care what value is stored
	dex
	bne ScanLoop


; The next frame will start with current color value - 1
; to get a downwards scrolling effect
	dec BGColor

; Go back and do another frame
	jmp NextFrame
.ENDS

.orga $fffc
.SECTION "b", FORCE
	.word Start
	.word Start
.ENDS