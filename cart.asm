	processor 6502

	include "vcs.h"
	include "macro.h"

;;;; start constant declarations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0HEIGHT equ 9
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; end constant declarations

;;; $80 to $FF for variables, minus some at end if using stack
	seg.u variables
	org $80
;;;;  start variable declarations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0x	           byte ; (80) P0 x
P0y	           byte ; (81) P0 y
P0spritePtr	   byte ; (82) y-adjusted sprite pointer
P0spriteHi	   byte ; (83) MSB of sprite pointer
P0reactionTime byte ; (84) P0 reaction budget 
P0score        byte ; (85) P0 score
P0bitmap       byte ; (86) P0bitmap (without screen-draw offset)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  end variables

;;; Begin code segment in ROM at $F000
	seg code
	org $F000

Start:
	CLEAN_START

;;;;  start variable initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda #50
	sta P0x
	sta P0y
;;; Set high byte of P0spritePtr (low byte updated per frame)
	lda #>BitmapTable
	sta P0spriteHi
;;; Set initial P0bitmap
	lda #<Ubitmap
	sta P0bitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  end variable initialization

StartFrame:
	lda #2
	sta VSYNC

;;; 3 lines of VSYNC
	sta WSYNC	; store halts until scanline complete
	sta WSYNC	; 2nd
	sta WSYNC	; 3rd

;;;; set timer for VBLANK
	LDA #44
	STA	TIM64T

	lda #0
	sta VSYNC	; turn off VSYNC

;;;;  start game vblank logic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; skip input detection if sprite is null
    ldx #<NullBitmap
	cpx P0bitmap
	beq EndP0Input
;;; sprite is active, consume time (?? maybe move lower)
    dec P0reactionTime

;;; check input signals
CheckP0Up:
	lda #%00010000
	bit SWCHA
	bne CheckP0Down
	ldx #<Ubitmap
CheckP0Down:
	lda #%00100000
	bit SWCHA
	bne CheckP0Right
	ldx #<Dbitmap
CheckP0Right:
	lda #%10000000
	bit SWCHA
	bne CheckP0Left
	ldx #<Rbitmap
CheckP0Left:
	lda #%01000000
	bit SWCHA
	bne EndP0InputCheck
	ldx #<Lbitmap
EndP0InputCheck:

;;; do input-related processing
CheckInputCorrect:
    cpx #<NullBitmap   ; if x hasn't changed
	beq EndP0Input	   ; we didn't get input
	cpx P0bitmap    ; check if input matches icon
	bne P0Incorrect
P0Correct:
    inc P0score        ; score 1
	lda #<NullBitmap   ; set bitmap to null
	sta P0bitmap
    jmp EndP0Input
P0Incorrect:
	lda #<Xbitmap      ; set bitmap to X
	sta P0bitmap
;;; end of input processing	
EndP0Input:

;;; P0 horizontal position
	ldx #0
	lda P0x
	jsr PosObject
;;; P0 vertical position
    lda P0bitmap           ; bitmap base
	clc                    ; clear carry for add
	adc #P0HEIGHT-1        ; bitmap high end
	sec                    ; set carry for subtract
	sbc P0y                ; offset by P0y for draw logic
	sta P0spritePtr        ; store in sprite pointer
	lda #>BitmapTable      ; load 2nd byte of bitmap table
	sbc #0                 ; subtract 0 (decrements if carry is clear from previous)
	sta P0spritePtr+1     ; store in high byte of sprite pointer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  end game vblank logic

;;;; Wait for rest of VBLANK
.VblankWaitLoop
	lda INTIM 	; load timer interrupt
	bne	.VblankWaitLoop
	sta WSYNC 	; wait for next wsync
	sta VBLANK	; turn off VBlank

;;;; kernel (192 visible scan lines)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ldy #192	; counter
.LoopVisible:
;;; for rainbow background
	sty COLUBK	; set bg color to loop var

;;; draw P0
	sec	; 2 set carry
	tya	; 2
	sbc P0y	; 3
	adc P0HEIGHT	; 2
	bcs .DrawP0

	nop	; 2
	nop	; 2
	sec	; 2
	bcs .NoDrawP0	; 3
.DrawP0
	lda (P0spritePtr),Y	; 5
	sta GRP0	; 3
.NoDrawP0

	sta WSYNC	; wait for next scanline
	dey	; y--
	bne .LoopVisible	; go back until x = 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; end kernel

;;;; set timer for OVERSCAN
	lda #2
	sta WSYNC
	sta VBLANK
	lda #36
	sta TIM64T

;;;;  start game overscan logic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  end game overscan logic


;;;; Wait for rest of OVERSCAN
.OverscanWaitLoop:
	lda INTIM
	bne .OverscanWaitLoop
	lda #2
	sta WSYNC

;;; new frame
	jmp StartFrame

;;;;   start subroutines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; PosObject from https://www.biglist.com/lists/stella/archives/200403/msg00260.html
; Positions an object horizontally
; Inputs: A = Desired position.
; X = Desired object to be positioned (0-5). *jh* (P0, P1, M0, M1, Ball)
; scanlines: If control comes on or before cycle 73 then 1 scanline is consumed.
; If control comes after cycle 73 then 2 scanlines are consumed.
; Outputs: X = unchanged
; A = Fine Adjustment value.
; Y = the "remainder" of the division by 15 minus an additional 15.
; control is returned on cycle 6 of the next scanline.
PosObject SUBROUTINE

	STA WSYNC ; 00 Sync to start of scanline.
	SEC ; 02 Set the carry flag so no borrow will be applied during the division.
.divideby15
	SBC #15 ; 04 ; Waste the necessary amount of time dividing X-pos by 15!
	BCS .divideby15 ; 06/07 - 11/16/21/26/31/36/41/46/51/56/61/66

	TAY ; 08 ; At this point the value in A is -1 to -15. In this code I use a table
; to quickly convert that value to the fine adjust value needed.
	LDA fineAdjustTable,Y ; 13 -> Consume 5 cycles by guaranteeing we cross a page boundary
; In your own code you may wish to consume only 4.
	STA HMP0,X ; 17 Store the fine adjustment value.
	STA RESP0,X ; 21/ 26/31/36/41/46/51/56/61/66/71 - Set the rough position.

	STA WSYNC
	RTS

;;; end PosObject from https://www.biglist.com/lists/stella/archives/200403/msg00260.html
;;; (see link for alternate way without lookup table)
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;   end subroutines

;;;;  start ROM lookup tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    align 256
BitmapTable:
Lbitmap:
	byte #%00000000
	byte #%00010000
	byte #%00110000
	byte #%01111111
	byte #%11111111
	byte #%01111111
	byte #%00110000
	byte #%00010000
	byte #%00000000

Rbitmap:
	byte #%00000000
	byte #%00001000
	byte #%00001100
	byte #%11111110
	byte #%11111111
	byte #%11111110
	byte #%00001100
	byte #%00001000
	byte #%00000000

Dbitmap:
	byte #%00000000
	byte #%00010000
	byte #%00111000
	byte #%01111100
	byte #%11111110
	byte #%00111000
	byte #%00111000
	byte #%00111000
	byte #%00000000

Ubitmap:
	byte #%00000000
	byte #%00111000
	byte #%00111000
	byte #%00111000
	byte #%11111110
	byte #%01111100
	byte #%00111000
	byte #%00010000
	byte #%00000000

Xbitmap:
	byte #%00000000
	byte #%10000010
	byte #%01000100
	byte #%00101000
	byte #%00010000
	byte #%00101000
	byte #%01000100
	byte #%10000010
	byte #%00000000

NullBitmap:
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000

P0color:
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00

P0Index:
    byte #<Lbitmap
	byte #<Rbitmap
	byte #<Ubitmap
	byte #<Dbitmap
	byte #<NullBitmap
	byte #<Xbitmap

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  end ROM lookup tables

;;; fine adjustment for PosObject
;;; some explanation on "negative index" is here: 
;;; - https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-24.html

fineAdjustBegin
	DC.B %01110000; Left 7 
	DC.B %01100000; Left 6
	DC.B %01010000; Left 5
	DC.B %01000000; Left 4
	DC.B %00110000; Left 3
	DC.B %00100000; Left 2
	DC.B %00010000; Left 1
	DC.B %00000000; No movement.
	DC.B %11110000; Right 1
	DC.B %11100000; Right 2
	DC.B %11010000; Right 3
	DC.B %11000000; Right 4
	DC.B %10110000; Right 5
	DC.B %10100000; Right 6
	DC.B %10010000; Right 7
fineAdjustTable EQU fineAdjustBegin - %11110001 ; NOTE: %11110001 = -15

;;; Complete to 4kB
	org $FFFC
	.word Start
	.word Start
