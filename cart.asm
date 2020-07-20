	processor 6502

	include "vcs.h"
	include "macro.h"

	seg code
	org $F000

Start:
	CLEAN_START

StartFrame:
	lda #2
	sta VBLANK
	sta VSYNC

;;; 3 lines of VSYNC
	sta WSYNC	; store halts until scanline complete
	sta WSYNC	; 2nd
	sta WSYNC	; 3rd

	lda #0
	sta VSYNC	; turn off VSYNC

;;; 37 scanlines of VBLANK
	ldx #37
LoopVBlank:
	sta WSYNC	; wait for next scanline
	dex	; x--
	bne LoopVBlank	; repeat until X = 0

	lda #0
	sta VBLANK	; turn off VBlank

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 192 visible scan lines
	ldx #192	; counter
LoopVisible:
	stx COLUBK	; set bg color to loop var
	sta WSYNC	; wait for next scanline
	dex	; x--
	bne LoopVisible	; go back until x = 0

;;;;;;;;;;;;;;;;;;;;;;;
;; 30 lines of overscan
	lda #2
	sta VBLANK	; enable VBLANK
	
	ldx #30

LoopOverscan:
	sta WSYNC	;wait for next line
	dex	; x--
	bne LoopOverscan	; repeat until x = 0

	jmp StartFrame

;;; Complete to 4kB
	org $FFFC
	.word Start
	.word Start
