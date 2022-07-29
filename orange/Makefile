booKernel: boot.bin kernel
	touch bootKernel
	dd if=boot.bin of=bootKernel bs=512 count=1 conv=notrunc
	dd if=kernel of=bootKernel bs=512 count=10 seek=1 conv=notrunc

# copyImg : boot.img
# 	dd if=boot.bin of=/Users/suntianwen/Downloads/bochs-2.7/boot.img bs=512 count=1 conv=notrunc
# 	dd if=kernel.bin of=/Users/suntianwen/Downloads/bochs-2.7/boot.img bs=512 count=10 seek=1 conv=notrunc

boot.img : boot.bin kernel

boot.bin : boot.asm
	nasm boot.asm -o boot.bin
kernel : main.o kernel.o
	ld kernel.o main.o -e _start -o kernel -m elf_i386 -Ttext 0x10000 --oformat binary
kernel.o : kernel.asm
	nasm kernel.asm -f elf -o kernel.o
main.o : main.c
	gcc -c main.c -o main.o -std=c99 -m32
clean :
	rm *.bin *.o kernel bootKernel
