    align 256
BitmapIndexR:
    byte #<LbitmapR
    byte #<RbitmapR
    byte #<UbitmapR
    byte #<DbitmapR

BitmapTableR:
LbitmapR:
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%11111111
	byte #%11111111
	byte #%11111111
	byte #%11111111
	byte #%11111111
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000

RbitmapR:
	byte #%00000000
	byte #%10000000
	byte #%11000000
	byte #%11100000
	byte #%11110000
	byte #%11111000
	byte #%11111100
	byte #%11111110
	byte #%11111111
	byte #%11111110
	byte #%11111100
	byte #%11111000
	byte #%11110000
	byte #%11100000
	byte #%11000000
	byte #%10000000
	byte #%00000000

DbitmapR:
	byte #%00000000
	byte #%00000000
	byte #%10000000
	byte #%11000000
	byte #%11100000
	byte #%11110000
	byte #%11111000
	byte #%11111100
	byte #%11111110
	byte #%11100000
	byte #%11100000
	byte #%11100000
	byte #%11100000
	byte #%11100000
	byte #%11100000
	byte #%11100000
	byte #%00000000

UbitmapR:
	byte #%00000000
	byte #%11100000
	byte #%11100000
	byte #%11100000
	byte #%11100000
	byte #%11100000
	byte #%11100000
	byte #%11100000
	byte #%11111110
	byte #%11111100
	byte #%11111000
	byte #%11110000
	byte #%11100000
	byte #%11000000
	byte #%10000000
	byte #%00000000
	byte #%00000000

XbitmapR:
	byte #%00000000
	byte #%00000011
	byte #%00000110
	byte #%00001100
	byte #%00011000
	byte #%00110000
	byte #%01100000
	byte #%11000000
	byte #%10000000
	byte #%11000000
	byte #%01100000
	byte #%00110000
	byte #%00011000
	byte #%00001100
	byte #%00000110
	byte #%00000011
	byte #%00000000

NullBitmapR:
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000
	byte #%00000000

TimeBitmapR:
    byte #%00000000
    byte #%11111111
    byte #%11111110
    byte #%11111100
    byte #%11101000
    byte #%10010000
    byte #%00100000
    byte #%01000000
    byte #%01000000
    byte #%01000000
    byte #%00100000
    byte #%00010000
    byte #%00001000
    byte #%00000100
    byte #%00000010
    byte #%11111111
    byte #%00000000

P1color:
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00