BIN_FILES	= boot_sector.bin

all: main.bin
	@echo "[+] done!"

%.bin: %.asm
	@echo "compiling $@..."
	@nasm -f bin $< -o $@

main.bin: $(BIN_FILES)
	@echo "creating boot.bin..."
	@cat $^ > $@

run: main.bin
	@qemu-system-x86_64 -s -fda main.bin

clean:
	@echo "[-] cleaning..."
	@rm -rf *.o *.bin
