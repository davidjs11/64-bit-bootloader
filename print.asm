; print.asm ---------------------------------------------------------
; printing routines using BIOS interrupts

[bits 16]

; print - print a string until null character
; di - char buffer
print:
    pusha           ; save registers
    mov ah, 0x0E    ; TTY output function

print_loop:
    mov al, [di]    ; get byte to print (ascii)
    test al, al     ; if character is null -> finish
    jz print_end

    int 0x10        ; call interrupt
    inc di          ; increment pointer
    jmp print_loop  ; loop again

print_end:
    popa            ; restore registers
    ret             ; return from call


; printn - print n characters
; di - char buffer
; si - string longitude
printn:
    pusha           ; save registers
    mov ah, 0x0E    ; TTY output function

printn_loop:
    mov al, [di]    ; 'al' - byte to print (ascii)
    int 0x10        ; call interrupt
    inc di          ; increment pointer
    dec si          ; decrement number of characters
    test si, si     ; if si isn't 0, loop
    jnz printn_loop

    popa            ; restore registers
    ret             ; return from call
