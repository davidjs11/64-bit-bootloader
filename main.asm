[org 0x7C00]        ; set 0x7C0 segment
[bits 16]           ; 16-bit real mode

; init the stack
mov bp, 0x8000
mov sp, bp

; main function
_start:
    ; read disk
    mov bx, 0x8000          ; destiny: 0x0000:0x9000 (es:bx)
    mov dh, 0x02            ; read two sectors
    call  read_disk

    ; print characters stored in each sector
    mov di, 0x8000          ; first sector
    mov si, 0x1             ; one character
    call printn
    mov di, 0x8000 + 512    ; second sector
    call printn
    call printn
    call printn
    call printn
    call printn
    jmp $

; include other routines
%include "print.asm"
%include "disk.asm"

; string definition
string: db "hey ;)                           ", 0x00

; mbr signature
times 510-($-$$) db 0x00
dw 0xAA55

; define other disk sectors
times 512 db 0x78
times 512 db 0x64
