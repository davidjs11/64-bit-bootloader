[bits 16]

; dh - number of sectors to read
; es:bx - destiny buffer
read_disk:
    pusha           ; save registers

    ; setup disk reading arguments
    mov ah, 0x02    ; read function (BIOS)
    mov al, dh      ; number of sectors to read
    mov ch, 0x00    ; cylinder number (check doc. for more info)
    mov cl, 0x02    ; sector number (1 is for mbr, 2 is available)
    mov dh, 0x00    ; head number

    int 0x13        ; reading interrupt (BIOS)
    
    popa            ; restore registers
    ret             ; return from call
