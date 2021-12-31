main : vhd.o
	cc -o vhdRead vhd.o vhdRead.c
	cc -o vhdWrite vhd.o vhdWrite.c
vhd.o : vhd.c
	cc -c vhd.c
clean :
	rm vhd.o
	rm vhdRead
	rm vhdWrite