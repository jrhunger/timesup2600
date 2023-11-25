all:
	../bin/dasm *.asm -f3 -v0 -otimesup.bin -ltimesup.lst -stimesup.sym


verbose:
	../bin/dasm *.asm -f3 -v1 -otimesup.bin -ltimesup.lst -stimesup.sym

clean:
	/bin/rm -f timesup.bin timesup.lst timesup.sym
