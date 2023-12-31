	processor 6502

	include "vcs.h"
	include "macro.h"

;;;; start constant declarations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0HEIGHT equ 16
;; contants for use with game state
ST_TIMECOUNT equ %00010000  ; counting time?
ST_GAMEINPUT equ %00100000  ; checking player input?
ST_CHECKRST  equ %01000000  ; checking reset switch?
ST_CHECKSLCT equ %10000000  ; checking select switch?
;; constants for target arrow
SL_ARROWLT   equ %00000000  ; left arrow index
SL_ARROWRT   equ %00000001  ; right arrow index
SL_ARROWUP   equ %00000010  ; up arrow index
SL_ARROWDN   equ %00000011  ; down arrow index
;; contants for reading console switches
SW_RESET     equ %00000001  ; reset switch
SW_SELECT    equ %00000010  ; select switch
SW_COLOR     equ %00001000  ; b/w (0) / color (1)
SW_P0DIFF    equ %01000000  ; P0 difficulty | 0 = Beginner
SW_P1DIFF    equ %10000000  ; P1 difficulty | 1 = Advanced
;; constants for use with game mode
; position modes:
; 00 = center
; 01 = fixed correlated to arrow
; 10 = random
; 11 = fixed random (in central positions uncorrelated to arrow)
MP_FIXED     equ %00000001  ; fixed central positions
MP_RANDOM    equ %00000010  ; fixed central positions
; other constants
PENALTY_CYCLES equ 45       ; 3/4 second penalty for incorrect
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; end constant declarations

;;; $80 to $FF for variables, minus some at end if using stack
	seg.u variables
	org $80
;;;;  start variable declarations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0x	         byte ; (80) P0 x
P0y	         byte ; (81) P0 y
P0spritePtr  byte ; (82) y-adjusted sprite pointer
P0spriteHi	 byte ; (83) MSB of sprite pointer
P0time0      byte ; (84) P0 reaction budget 
P0time1      byte ; (85) P0 reaction budget 
P0score      byte ; (86) P0 score
P0bitmap     byte ; (87) P0bitmap (without screen-draw offset)
LeftScore4   byte ; (88) Score Digits
LeftScore5   byte ; (89) Score Digits
; GameState - bitwise game state, see ST_* constants
GameState    byte ; (8a) 
; GameMode - bitwise game mode, see M?_* constants
GameMode     byte ; (8b) 
DelayTime    byte ; (8c) Time left in delay
Rand8        byte ; (8d) 8-bit random
InputTime    byte ; (8e) Input re-check delay
ReposTime    byte ; (8f) Input re-check delay
CurrentArrow byte ; (90) Current target arrow index
P1spritePtr  byte ; (91) y-adjusted sprite pointer
P1spriteHi	 byte ; (92) MSB of sprite pointer
P1bitmap     byte ; (93) Bitmap pointer for P1

; Top Bar digit pointers
    org $a0
LeftScorePtr0    word ; (a0/1)
LeftScorePtr1    word ; (a2/3)
LeftScorePtr2    word ; (a4/5)
LeftScorePtr3    word ; (a6/7)
LeftScorePtr4    word ; (a8/9)
LeftScorePtr5    word ; (aa/b)
RightScorePtr0   word ; (ac/d)
RightScorePtr1   word ; (ae/f)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  end variables

;;; Begin code segment in ROM at $F000
	seg code
	org $F000

Start:
	CLEAN_START

;;;;  start variable initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; initialize Random seed
    lda INTIM    ; unknown from timer
	ora #$1       ; can't be zero
	sta Rand8
;;; Set initial P0bitmap to Up
    lda #SL_ARROWUP
	sta CurrentArrow
	lda #<UbitmapL
	sta P0bitmap
	lda #<UbitmapR
	sta P1bitmap
;;; set player colors to black
	lda #0
	sta COLUP0
	sta COLUP1
;;; player coordinates (match bitmap above)
    ; a is already 0 from above
	tay
	jsr SetPosition
;;; set timer to 1000 (decimal)
    lda #0
	sta P0time0
	lda #$10
	sta P0time1

;;; set ReposTime (for moving arrow)
    lda #16
	sta ReposTime

;;; Set Score Digits
    lda #$0a     ; blank
	sta LeftScore4
	sta LeftScore5

;;; set up Score pointer high bytes
    lda #>digitTableLeftRev
	sta LeftScorePtr0+1
	sta LeftScorePtr4+1
	sta LeftScorePtr5+1
	sta RightScorePtr1+1
    lda #>digitTableLeft
	sta LeftScorePtr1+1
    lda #>digitTableRight
	sta LeftScorePtr2+1
    lda #>digitTableRightRev
    sta LeftScorePtr3+1
    sta RightScorePtr0+1

;;; game state -  check input but don't consume time
    lda #ST_GAMEINPUT | ST_CHECKSLCT
	sta GameState

;;; game mode
    lda #0       ; all mode bits clear
	sta GameMode

;;; register setup
    ; playfield color
    lda #55
	sta COLUPF
	; player/missile size register
	lda #%00000000    ; one player, single-sized
	;lda #%00000101    ; one player, double-sized
	;lda #%00000111    ; one player, quad-sized
	sta NUSIZ0
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

;;; Consume Time if applicable
	jsr ConsumeTime
;;; check if open for input
    lda #ST_GAMEINPUT
    bit GameState
	beq NotActive   
	jmp CheckInput
;;; not active so check if time to activate
NotActive
    lda DelayTime
	beq NoNewBitmap  ; already zero
	sec
	sbc #1
	sta DelayTime
	bne NoNewBitmap
NewBitmap
    jsr Random       ; get a random #
	and #%00000011   ; truncate to 2 bits
	sta CurrentArrow ; store as current
    tay              ; put in Y
	clc
	lda BitmapIndexL,Y
	sta P0bitmap
	lda BitmapIndexR,Y
	sta P1bitmap
	jsr SetPosition
SetActive:	
	; set Active
	lda #ST_GAMEINPUT | ST_TIMECOUNT
	sta GameState
NoNewBitmap
    jmp EndP0Input

;;; check input signals
CheckInput
    ldx #<NullBitmapL
CheckP0Up:
	lda #%00010000
	bit SWCHA
	bne CheckP0Down
	ldx #<UbitmapL
CheckP0Down:
	lda #%00100000
	bit SWCHA
	bne CheckP0Right
	ldx #<DbitmapL
CheckP0Right:
	lda #%10000000
	bit SWCHA
	bne CheckP0Left
	ldx #<RbitmapL
CheckP0Left:
	lda #%01000000
	bit SWCHA
	bne EndP0InputCheck
	ldx #<LbitmapL
EndP0InputCheck:

;;; do input-related processing
CheckInputCorrect:
    cpx #<NullBitmapL  ; if x hasn't changed
	beq NoInput	       ; we didn't get input
	lda #0             ; if we did get input
	sta GameState      ; stop time counter and input checking
	cpx P0bitmap       ; check if input matches icon
	bne P0Incorrect
P0Correct:
	; increment (decimal) score
    clc
    lda P0score
	sed
	adc #1
	sta P0score
	cld
    ; set bitmap to null
	lda #<NullBitmapL
	sta P0bitmap
	lda #<NullBitmapR
	sta P1bitmap
    jmp SetDelay
P0Incorrect:
	lda #<XbitmapL      ; set bitmap to X
	sta P0bitmap
	lda #<XbitmapR      ; set bitmap to X
	sta P1bitmap
	lda #ST_TIMECOUNT   ; time active, input not
	sta GameState
	lda #PENALTY_CYCLES ; length of time lost for incorrect
	sta DelayTime
	jmp EndP0Input
SetDelay:
	; set a random delay
	jsr Random
	and #%00111111     ; max 127 (just over 2 second)
	ora #%00001000     ; min 16 (around 1/4 second)
	sta DelayTime
	jmp EndP0Input
NoInput:
    lda #ST_TIMECOUNT
	bit GameState
	bne EndP0Input
	dec ReposTime
	beq ChangePosition
	jmp EndP0Input
ChangePosition
    lda #16
	sta ReposTime
	lda #2
	tay
    jsr SetPosition
EndP0Input:
; check for game switches 
; (subroutines know if input being accepted based on current state)
    jsr ResetCheck
    jsr SelectCheck
	jsr ModeCheck
;;; end of input processing	


;;; P0 horizontal position
	ldx #0
	lda P0x
	jsr PosObject
;;; P1 horizontal position
    ldx #1
	lda P0x
	clc
	adc #8
	jsr PosObject
	; see https://forums.atariage.com/topic/162520-fine-positioning-not-working/?do=findComment&comment=2006722
	; if HMOVE is strobed too late in the line it doesn't move the player enough, so WSYNC first
	sta WSYNC
 	sta HMOVE
;;; P0 vertical position
    lda P0bitmap           ; bitmap base
	clc                    ; clear carry for add
	adc #P0HEIGHT          ; bitmap high end
	sec                    ; set carry for subtract
	sbc P0y                ; offset by P0y for draw logic
	sta P0spritePtr        ; store in sprite pointer
	lda #>BitmapTableL     ; load 2nd byte of bitmap table
	sbc #0                 ; subtract 0 (decrements if carry is clear from previous)
	sta P0spriteHi        ; store in high byte of sprite pointer
;;; P1 vertical position
    lda P1bitmap           ; bitmap base
	clc                    ; clear carry for add
	adc #P0HEIGHT          ; bitmap high end
	sec                    ; set carry for subtract
	sbc P0y                ; offset by P0y for draw logic
	sta P1spritePtr        ; store in sprite pointer
	lda #>BitmapTableR     ; load 2nd byte of bitmap table
	sbc #0                 ; subtract 0 (decrements if carry is clear from previous)
	sta P1spriteHi         ; store in high byte of sprite pointer

;;; Setup score pointers for display
    jsr LoadScorePointers

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
	ldy #14
;;; display 14 rows of "score"
.ScrollLoop
	sta WSYNC		; 3| 0
	lda (LeftScorePtr0),Y	; 5| 5 PF0 is single digit
	sta PF0			; 3| 8
	lda (LeftScorePtr1),Y	; 4|12
	ora (LeftScorePtr2),Y	; 5|17
	sta PF1			; 3|20
	lda (LeftScorePtr3),Y	; 5|25
	ora (LeftScorePtr4),Y	; 5|30
	sta PF2			; 3|33
	lda (LeftScorePtr5),Y	; 5|38
	sta PF0			; 3|41
;; need to redo counts
;	lda (ScrollPtr6),Y	; 5|46
;	ora (ScrollPtr7),Y	; 5|51
	lda #0
	sta PF1			; 3|54
	lda (RightScorePtr0),Y	; 5|59
	ora (RightScorePtr1),Y	; 5|64
	sta PF2			; 3|67
	dey			    ; 2|69
	bne .ScrollLoop		; 3|75/76

;;; one more black line before moving to play area
	sta WSYNC
	ldy #177	; counter
	ldx #0      ; first GRP0 should be 0
	lda #0      ; first GRP1 should be 0
.LoopVisible:
;;; player bitmaps calculated on previous line
    sta GRP1    ; 
	stx GRP0	; 3
;;; for rainbow background
	sty COLUBK	; set bg color to loop var

;;; draw P0
	sec	; 2 set carry
	tya	; 2
	sbc P0y	; 3
	adc #P0HEIGHT	; 2
	bcs .DrawP0
	lda #0          ; A used for P1 sprite, so clear it if not drawing
	jmp .NoDrawP0
.DrawP0
	lda (P0spritePtr),Y	; 5
	tax
	lda (P1spritePtr),Y ; 5
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
;;; cycle the Random a tick
    jsr Random

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
;;; Load Score Pointers based on corresponding values

ResetCheck SUBROUTINE
    lda #ST_CHECKRST
	bit GameState
	beq .end
	lda #SW_RESET
	bit SWCHB
	beq .reset
	lda #%10000000     ; only bit 7 used
	bit INPT4
	beq .reset
	jmp .end
.reset
	; actual RESET behavior
	jmp Start
.end:
    rts

SelectCheck SUBROUTINE
    lda #ST_CHECKSLCT
	bit GameState
	beq .end
	lda InputTime
	beq .checkselect
	dec InputTime
	jmp .end
.checkselect
	lda #SW_SELECT
	bit SWCHB
	bne .end
	; actual SELECT behavior
    lda P0time1
	sed
	clc
	adc #5
	cld
	cmp #$30
	bne .store
	lda #5
.store
	sta P0time1
	lda #15
	sta InputTime
.end:
    rts

;; Check switches to set GameMode
ModeCheck SUBROUTINE
    lda #SW_P0DIFF
	bit SWCHB
	beq .p0beginner
.p0advanced
	lda GameMode
	ora #MP_FIXED
	sta GameMode
	jmp .checkp1diff
.p0beginner	
    lda #MP_FIXED ^ #$FF  ; invert mask
	and GameMode
	sta GameMode
.checkp1diff
    lda #SW_P1DIFF
	bit SWCHB
	beq .p1beginner
.p1advanced
	lda GameMode
	ora #MP_RANDOM
	sta GameMode
	rts
.p1beginner
    lda #MP_RANDOM ^ #$FF  ; invert mask
	and GameMode
	sta GameMode
	rts

;; SetPosition expects the arrow bitmap index (0-3) in Y
SetPosition SUBROUTINE	
	; Update position
    lda #MP_FIXED | MP_RANDOM
	and GameMode
	beq .center
	cmp #MP_FIXED | MP_RANDOM
	beq .fixedrandom
	lda #MP_RANDOM
	bit GameMode
	bne .random
.fixed:
    lda PositionX,Y
	sta P0x
    lda PositionY,Y
	sta P0y
	rts
.fixedrandom:
    jsr Random
	and #%00000011
	tax
	lda PositionX,X
	sta P0x
	lda PositionY,X
	sta P0y
	rts
.random:
	jsr Random
	and #%01111111 ; upper bound 127 
	ora #%00010000 ; lower bound 16
	sta P0x
	jsr Random
	and #%01111111 ; upper bound 127 
	ora #%00010000 ; lower bound 16
	sta P0y
	rts
.center
	lda PositionX+2
	sta P0x
	lda PositionY
	sta P0y
    rts

ConsumeTime SUBROUTINE
    lda #ST_TIMECOUNT  ; check if TIMECOUNT bit
    bit GameState     ; is set in GameState
	bne .usetime
	rts
.usetime
	sed
    sec
    lda P0time0
	sbc #1
	sta P0time0
    lda P0time1
	sbc #0
	sta P0time1
	cld
	bcc .timesup
	rts
.timesup:
	; time's up, set back to 0 and deactivate countdown
	lda #0
	sta P0time0
	sta P0time1
	lda #ST_CHECKRST | ST_CHECKSLCT
	sta GameState
	lda #<TimeBitmapL
	sta P0bitmap
	lda #<TimeBitmapR
	sta P1bitmap
	lda PositionX+2
	sta P0x
	lda PositionY
	sta P0y
	rts

LoadScorePointers SUBROUTINE
    ; first byte (two digits) of timer
	lda #%11110000 	    ; mask for first decimal digit
	and P0time1  ;
	sta LeftScorePtr0	; store as is (already x16)

	lda #%00001111	    ; mask for 2nd decimal digit
	and P0time1  ; 
	asl		; 
	asl		; 
	asl		; 
	asl		; multiply by 16
	sta LeftScorePtr1	; store in pointer

    ; second byte (two digits) of timer
	lda #%11110000 	    ; mask for first decimal digit
	and P0time0  ;
	sta LeftScorePtr2	; store as is (already x16)

	lda #%00001111	    ; mask for 2nd decimal digit
	and P0time0  ; 
	asl		; 
	asl		; 
	asl		; 
	asl		; multiply by 16
	sta LeftScorePtr3	; store in pointer

	lda #%00001111	    ; mask for 2nd decimal digit
	and LeftScore4	    ; load the digit
	asl		; 
	asl		; 
	asl		; 
	asl		; multiply by 16
	sta LeftScorePtr4	; Put in LSB of ScrollPtr

    ; delay time countdown (MSB only)
	lda #%11110000 	    ; mask for first decimal digit
	and DelayTime	    ; load the digit
	sta LeftScorePtr5	; store as is (already x16)

    ; score digits
	lda #%11110000 	    ; mask for first decimal digit
	and P0score	        ;
	sta RightScorePtr0	; store as is (already x16)

	lda #%00001111	    ; mask for 2nd decimal digit
	and P0score	        ; 
	asl		; 
	asl		; 
	asl		; 
	asl		; multiply by 16
	sta RightScorePtr1	; store in pointer

	rts

    align 256 ; PosObject is timing dependent and can't cross page boundaries
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
	
;;; Random from https://forums.atariage.com/blogs/entry/11145-step-10-random-numbers/
Random SUBROUTINE
    lda Rand8
    lsr
	bcc .noeor
	eor #$B4
.noeor:
    sta Rand8
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;   end subroutines

;;;;  start ROM lookup tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    include "bitmapsL.h"
    include "bitmapsR.h"

;;; X and Y location per directional icon
PositionX:
	byte #53   ; left
	byte #107  ; right
	byte #80   ; up
	byte #80   ; down

PositionY:
	byte #93   ; left (177/2 - 9/2)
	byte #93   ; right
	byte #128  ; up
	byte #59   ; down

;;; digits.h should set digitTable at the beginning followed by
;;;          an array of 16 bytes for each digit 0-9
	include "digitTableRight.h"
	include "digitTableLeft.h"
	include "digitTableRightRev.h"
	include "digitTableLeftRev.h"

    align 256 ; set on page boundary per timing reasons
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  end ROM lookup tables

;;; Complete to 4kB
	org $FFFC
	.word Start
	.word Start
