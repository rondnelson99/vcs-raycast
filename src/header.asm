.include "defines.asm"


.SLOT "ROM"
.SECTION "init", FREE


; The CLEAN_START macro zeroes RAM and registers
Start	CLEAN_START






; Go back and do another frame
	jmp DoLogic
.ENDS

.orga $fffc
.SECTION "b", FORCE
	.word Start
	.word Start
.ENDS