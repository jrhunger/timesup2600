    align 256
BitmapIndex:
    byte #<Lbitmap
    byte #<Rbitmap
    byte #<Ubitmap
    byte #<Dbitmap

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

TimeBitmap:
	byte #%00000000
	byte #%11111111
	byte #%01011010
	byte #%00100100
	byte #%00011000
	byte #%00100100
	byte #%01000010
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