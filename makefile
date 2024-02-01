TARGET	= -target x86_64-pc-none-elf

all: mbr
	@echo "[+] done!"

mbr:
	@echo "compiling MBR..."
	@nasm -f bin main.asm -o main.bin

run:
	@qemu-system-x86_64 main.bin

clean:
	@echo "[-] cleaning..."
	@rm -rf *.o *.bin
