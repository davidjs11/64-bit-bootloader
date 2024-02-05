; --- boot_sector.asm -----------------------------------------------
[org 0x7C00]                ; set 0x7C0 segment

; main function
[bits 16]
_start:
    ; init the stack
    mov bp, 0x9000
    mov sp, bp

    ; switch to 32-bit protected mode
    call switch_protected_mode


; --- disk reading routines -----------------------------------------
; read from disk
; al - number of sectors to read
; es:bx - destiny buffer
[bits 16]
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


; --- mode switching routines ---------------------------------------
[bits 16]
switch_protected_mode:
    cli                     ; disable interrupts
    lgdt [GDT_32.pointer]   ; load the GDT pointer
    mov eax, cr0            ; set 32-bit flag on control register
    or  eax, 0x1
    mov cr0, eax

    jmp GDT_32.code:PM_Code


; --- 32-bit program ------------------------------------------------
[bits 32]
PM_Code:
    ; set segment registers
    mov ax, GDT_32.data
    mov ds, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp $


; --- 32-bit GDT ----------------------------------------------------
GDT_32:
    ; null segment -> all zero
    .null: equ $ - GDT_32
        dd 0x00000000
        dd 0x00000000
    
    ; base: 0x0  -  limit: 0xFFFF
    .code: equ $ - GDT_32
        dw 0xFFFF, 0x0000
        db 0x00, 0x9A, 0xCF, 0x00

    ; base: 0x0  -  limit: 0xFFFF
    .data: equ $ - GDT_32
        dw 0xFFFF, 0x0000
        db 0x00, 0x92, 0xCF, 0x00
    
    .pointer:
        dw $ - GDT_32 - 1   ; limit
        dd GDT_32           ; base


; --- 64-bit GDT ----------------------------------------------------
GDT_64:
    ; null segment -> all zero
    .null: equ $ - GDT_64
        dd 0x00000000
        dd 0x00000000

    ; bit 41: readable
    ; bit 43: executable
    ; bit 44: descriptor type (1 for code/data)
    ; bit 47: present
    ; bit 53: '64-bit'
    .code: equ $ - GDT_64
        dq (1<<41) | (1<<43) | (1<<44) | (1<<47) | (1<<53)

    ; bit 41: writable
    ; bit 44: descriptor type (1 for code/data)
    ; bit 47: present
    .data: equ $ - GDT_64
        dq (1<<41) | (1<<44) | (1<<47)

    .pointer:
        dw $ - GDT_64 - 1   ; limit
        dd GDT_64           ; base


; --- mbr signature -------------------------------------------------
times 510-($-$$) db 0x00
dw 0xAA55
