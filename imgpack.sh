echo ------[IMG MAKE START]------
pwd
cd asm
nasm ./boot.asm -o ../boot/boot.bin
nasm ./kernel_entry.asm -f elf -o ../boot/kernel_entry.o
cd ..
dd if=/dev/zero of=./boot/diska.img bs=512 count=2880
dd if=./boot/boot.bin of=./boot/boot.img bs=512 count=1
dd if=./boot/diska.img of=./boot/boot.img skip=1 seek=1 bs=512 count=2879
rm ./boot/diska.img

gcc -m32 -fno-pie -ffreestanding -c kernel/kernel.c -o kernel/kernel.o
ld -m elf_i386 -o ./boot/kernel.bin -Ttext 0x1000 ./boot/kernel_entry.o ./kernel/kernel.o --oformat binary

cat ./boot/boot.bin ./boot/kernel.bin > ./boot/boot.img

echo ------[IMG MAKE OK]------
rm -f /mnt/d/0--DeskTop--/boot.img
cp ./boot/boot.img /mnt/d/0--DeskTop--/boot.img
echo ------[IMG COPY OK]------