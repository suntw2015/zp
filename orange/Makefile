boot.img : boot.bin kernel.bin

boot.bin :
	nasm boot.asm -o boot.bin
	dd if=boot.bin of=/Users/suntianwen/Downloads/bochs-2.7/boot.img bs=512 count=1 conv=notrunc
kernel.bin :
	nasm kernel.asm -o kernel.bin
	dd if=kernel.bin of=/Users/suntianwen/Downloads/bochs-2.7/boot.img bs=512 count=10 seek=1 conv=notrunc
clean :
	rm *.bin *.o