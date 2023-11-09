all:
	../bin/dasm *.asm -f3 -v0 -ocart.bin -lcart.lst -scart.sym


verbose:
	../bin/dasm *.asm -f3 -v1 -ocart.bin -lcart.lst -scart.sym
