; --- print.asm -----------------------------------------------------
; printing routines using BIOS interrupts

[bits 16]

; print - print a string until null character
; ds:si - buffer address
print:
    pusha           ; save registers
    mov ah, 0x0E    ; TTY output function (BIOS)
    xor bx, bx      ; set page 0

print_loop:
    lodsb           ; load byte from 'ds:si' and increment 'si'
    test al, al     ; if character is null:
    jz print_end    ;   finish

    int 0x10        ; print character (BIOS)
    jmp print_loop  ; loop again

print_end:
    popa            ; restore registers
    ret             ; return from call


; print32 - print a string in 32 bit protected mode
; ds:esi - buffer address
[bits 32]

print32:
    pusha               ; save registers
    mov edx, 0xB8000    ; video address
    mov ah,  0x0F       ; white on black
    
print32_loop:
    lodsb               ; get character
    test al, al         ; if character is null:
    jz print32_end      ;   finish

    mov [edx], ax       ; store color:character (ah:al = ax)
    inc edi             ; next character
    inc edx             ; move VGA text cursor
    inc edx

print32_end:
    popa                ; restore registers
    ret                 ; return from call
