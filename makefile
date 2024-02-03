BIN_FILES	= stage0.bin boot.bin

all: main.bin
	@echo "[+] done!"

%.bin: %.asm
	@echo "compiling $@..."
	@nasm -f bin $< -o $@

main.bin: $(BIN_FILES)
	@echo "creating boot.bin..."
	@cat $^ > $@

run: main.bin
	@qemu-system-x86_64 main.bin

clean:
	@echo "[-] cleaning..."
	@rm -rf *.o *.bin
