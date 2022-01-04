```shell
nasm -f bin xxxx.asm -o xxx.bin
dd if=real_mbr.bin of=real_mbr.img count=1 bs=512

/Users/suntianwen/VirtualBox VMs/asm/asm.vhd
dd if=user_program.asm of='/Users/suntianwen/VirtualBox VMs/asm/asm.vhd' seek=100 bs=512 count=1

nasm -f bin user_program.asm -o user_program.bin

dd if=real_mbr.bin of=test.vhd bs=512 count=1 conv=notrunc
dd if=user_program.bin of=test.vhd bs=512 count=2 seek=1 conv=notrunc

nasm -f bin boot.asm -o boot.bin
dd if=boot.bin of=/Users/suntianwen/Downloads/bochs-2.7/boot.img bs=512 count=1 conv=notrunc
bochs -f ./.bochsrc
mount -t vfat -o loop /root/boot.img /mnt/asm
scp root@10.26.15.86:/root/boot.img /Users/suntianwen/Downloads/bochs-2.7/boot.img
```