[bits 16]

; reset the disk to sector 0
disk_reset:
    xor ah, ah      ; 'reset' function (BIOS)
    int 0x13        ; disk interrupt (BIOS)
    jc disk_reset   ; if error -> try again
    ret             ; return from call


; es:bx - destiny buffer
disk_read:
    pusha           ; save registers

    ; setup disk reading arguments
    mov ah, 0x02    ; 'read' function (BIOS)
    mov al, 0x01    ; read one sector
    mov ch, 0x00    ; cylinder number (check doc. for more info)
    mov cl, 0x02    ; sector number (1 is for mbr, 2 is available)
    mov dh, 0x00    ; head number

    int 0x13        ; disk interrupt (BIOS)
    jc disk_read    ; if error -> try again
    
    popa            ; restore registers
    ret             ; return from call
