copyImg : boot.img
	dd if=boot.bin of=/Users/suntianwen/Downloads/bochs-2.7/boot.img bs=512 count=1 conv=notrunc
	dd if=kernel.bin of=/Users/suntianwen/Downloads/bochs-2.7/boot.img bs=512 count=10 seek=1 conv=notrunc

boot.img : boot.bin kernel.bin

boot.bin : boot.asm
	nasm boot.asm -o boot.bin
kernel.bin : main.o
	ld kernel.o main.o -lc -I /lib/Id-linux.so.2
kernel.o : kernel.asm
	nasm kernel.asm -o kernel.o
main.o : main.c
	gcc -mcmodel=large -fno-builtin -m64 -c main.c
clean :
	rm *.bin *.o