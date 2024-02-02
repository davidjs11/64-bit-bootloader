[org 0x7C00]        ; set offset
[bits 16]           ; 16-bit real mode

; init the stack
mov bp, 0x8000
mov sp, bp

; main function
_start:
    mov di, string
    call print
    jmp $-3

; include other routines
%include "print.asm"

; string definition
string: db "hey ;)                           ", 0x00

; mbr signature
times 510-($-$$) db 0x00
dw 0xAA55
