.include "defines.asm"


.SLOT "ROM"
.SECTION "init", FREE


; The CLEAN_START macro zeroes RAM and registers
Start	CLEAN_START
	;init the player position
	lda #5
	sta wPlayerX + 1
	sta wPlayerY + 1
	lda #0
	sta wPlayerX
	sta wPlayerY
	





; Go back and do another frame
	jmp DoLogic
.ENDS

.orga $fffc
.SECTION "b", FORCE
	.word Start
	.word Start
.ENDS