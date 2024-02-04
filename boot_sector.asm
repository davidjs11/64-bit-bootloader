; --- boot_sector.asm -----------------------------------------------

[org 0x7C00]                ; set 0x7C0 segment
[bits 16]                   ; 16-bit real mode

; init the stack
mov bp, 0x8000
mov sp, bp

; main function
_start:
    mov si, str_booting
    call print
    call newline
    jmp $
    

; --- printing routines ---------------------------------------------
; print a string until null character
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

; jump to a new line
newline:
    pusha           ; save registers
    mov ax, 0x0E0A  ; new line character
    int 0x10        ; print (BIOS)
    mov ax, 0x0E0D  ; carriage return
    int 0x10        ; print (BIOS)
    popa            ; restore registers
    ret             ; return from call


; --- disk reading routines -----------------------------------------
; read from disk
; al - number of sectors to read
; es:bx - destiny buffer
disk_read:
    pusha           ; save registers

    ; setup disk reading arguments
    mov ah, 0x02    ; 'read' function (BIOS)
    mov ch, 0x00    ; cylinder number (check doc. for more info)
    mov cl, 0x02    ; sector number (1 is for mbr, 2 is available)
    mov dh, 0x00    ; head number

    int 0x13        ; disk interrupt (BIOS)
    jc disk_read    ; if error -> try again
    
    popa            ; restore registers
    ret             ; return from call


; --- string definition ---------------------------------------------
str_reading:    db "reading disk... ", 0x00
str_booting:    db "booting up... ", 0x00
str_done:       db "done!", 0x00


; --- mbr signature -------------------------------------------------
times 510-($-$$) db 0x00
dw 0xAA55
