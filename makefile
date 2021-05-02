bootdir=boot
kerneldir=kernel

# ==== color ====
RED='\033[0;31m'
NC='\033[0m'

# ==== gcc ====
C_SOURCES = $(wildcard kernel/*/*.c kernel/*.c)
HEADERS = $(wildcard kernel/*/*.h kernel/*.h)
OBJ = ${C_SOURCES:.c=.o }

all:clean boot
	echo -e ${RED}moving boot.img to desktop...${NC}
	rm -f /mnt/d/0--DeskTop--/boot.img
	cp ${bootdir}/boot.img /mnt/d/0--DeskTop--/boot.img
	make cleanobj

boot:boot.bin kernel.bin
	echo -e ${RED}building boot.img...${NC}
	dd if=/dev/zero of=${bootdir}/diska.img bs=512 count=2880
	dd if=${bootdir}/boot.bin of=${bootdir}/boot.img bs=512 count=1
	dd if=${bootdir}/diska.img of=${bootdir}/boot.img skip=1 seek=1 bs=512 count=2879
	rm ${bootdir}/diska.img
	cd ${bootdir} && cat boot.bin kernel.bin > boot.img
	echo -e ${RED}building SUCCESS${NC}

kernel.bin: ${OBJ} kernel_entry.o interrupt.o
	echo -e ${RED}linking kernel.bin...${NC}
	ld -m elf_i386 -o ${bootdir}/kernel.bin -Ttext 0x1000 -Tdata 0x3000 ${bootdir}/kernel_entry.o kernel/cpu/interrupt.o ${OBJ} --oformat binary

kernel_entry.o:
	echo -e ${RED}building kernel_entry.bin...${NC}
	cd ${bootdir} && nasm kernel_entry.asm -f elf32 -o kernel_entry.o

interrupt.o:
	echo -e ${RED}building kernel_entry.bin...${NC}
	nasm kernel/cpu/interrupt.asm -f elf32 -o kernel/cpu/interrupt.o

boot.bin:
	echo -e ${RED}building boot.bin...${NC}
	cd ${bootdir} && nasm ./boot.asm -o boot.bin

clean:
	echo -e ${RED}cleaning...${NC}
	rm -rf ${bootdir}/*.img
	rm -rf ${bootdir}/*.o
	rm -rf ${bootdir}/*.bin
	make cleanobj

cleanobj:
	echo -e ${RED}cleaning objects...${NC}
	rm -rf ${kerneldir}/*/*.o
	rm -rf ${bootdir}/*.o
	rm -rf ${kerneldir}/*.o

%.o: %.c ${HEADERS}
	echo -e ${RED}compiling $<...${NC}
	gcc -m32 -fno-pie -nostdlib -c $< -o $@

%.o: %.asm
	echo -e ${RED}compiling $<...${NC}
	nasm $< -f elf32 -o $@

