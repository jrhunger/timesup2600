    align 256
BitmapIndexL:
    byte #<LbitmapL
    byte #<RbitmapL
    byte #<UbitmapL
    byte #<DbitmapL

BitmapTableL:
LbitmapL:
	byte #%00000000
	byte #%00000001
	byte #%00000011
	byte #%00000111
	byte #%00001111
	byte #%00011111
	byte #%00111111
	byte #%01111111
	byte #%11111111
	byte #%01111111
	byte #%00111111
	byte #%00011111
	byte #%00001111
	byte #%00000111
	byte #%00000011
	byte #%00000001
	byte #%00000000

RbitmapL:
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

DbitmapL:
	byte #%00000000
	byte #%00000001
	byte #%00000011
	byte #%00000111
	byte #%00001111
	byte #%00011111
	byte #%00111111
	byte #%01111111
	byte #%11111111
	byte #%00000111
	byte #%00000111
	byte #%00000111
	byte #%00000111
	byte #%00000111
	byte #%00000111
	byte #%00000111
	byte #%00000000

UbitmapL:
	byte #%00000000
	byte #%00000111
	byte #%00000111
	byte #%00000111
	byte #%00000111
	byte #%00000111
	byte #%00000111
	byte #%00000111
	byte #%11111111
	byte #%01111111
	byte #%00111111
	byte #%00011111
	byte #%00001111
	byte #%00000111
	byte #%00000011
	byte #%00000001
	byte #%00000000

XbitmapL:
	byte #%00000000
	byte #%11000000
	byte #%01100000
	byte #%00110000
	byte #%00011000
	byte #%00001100
	byte #%00000110
	byte #%00000011
	byte #%00000001
	byte #%00000011
	byte #%00000110
	byte #%00001100
	byte #%00011000
	byte #%00110000
	byte #%01100000
	byte #%11000000
	byte #%00000000

NullBitmapL:
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

TimeBitmapL:
    byte #%00000000
	byte #%11111111
    byte #%01111111
    byte #%00111111
    byte #%00010111
    byte #%00001011
    byte #%00000101
    byte #%00000010
    byte #%00000010
    byte #%00000010
    byte #%00000100
    byte #%00001000
    byte #%00010000
    byte #%00100000
    byte #%01000000
	byte #%11111111
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
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00
	byte #$00