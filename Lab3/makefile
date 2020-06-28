all: floatingpoint

floatingpoint: floatingpoint.o
	ld floatingpoint.o -o floatingpoint

floatingpoint.o: floatingpoint.s
	as floatingpoint.s -o floatingpoint.o
