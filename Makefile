all:
	../bin/dasm *.asm -f3 -v0 -ocart.bin


verbose:
	../bin/dasm *.asm -f3 -v1 -ocart.bin
