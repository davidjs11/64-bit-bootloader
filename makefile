HOME		= .
SRC 	    = $(HOME)/.
OBJ			= $(HOME)/.
ASM_FILES   = $(wildcard $(SRC)/*.asm)
OBJ_FILES   = $(patsubst $(SRC)/%.asm, $(OBJ)/%.o, $(ASM_FILES))

all: main.bin
	@echo "[+] done!"

# %.o: %.asm
# 	@echo "compiling $<..."
# 	@nasm -f bin $< -o $@

main.bin: $(ASM_FILES)
	@echo "compiling $@..."
	@nasm -f bin main.asm -o $@

run: main.bin
	@qemu-system-x86_64 main.bin

clean:
	@echo "[-] cleaning..."
	@rm -rf *.o *.bin
