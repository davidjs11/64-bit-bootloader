; --- boot_sector.asm -----------------------------------------------
[org 0x7C00]                ; set 0x7C0 segment


; --- 16-bit program ------------------------------------------------
[bits 16]
start_16:
    ; init the stack
    mov bp, 0x9000
    mov sp, bp

    ; switch to 32-bit protected mode
    call switch_protected_mode


; --- 32-bit program ------------------------------------------------
[bits 32]
start_32:
    ; set segment registers
    mov ax, GDT_32.data
    mov ds, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; switch to 64-bit mode
    jmp switch_long_mode


; --- 64-bit program ------------------------------------------------
[bits 64]
start_64:
    ; set segment registers
    mov ax, GDT_64.data
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; clear screen
    mov edi, 0xB8000
    mov rax, 0x1F201F201F201F20
    mov ecx, 500
    rep stosq

    ; print something
    mov rdi, 0xB821C
    mov rsi, MSG_64

    print64_loop:
        lodsb
        test al, al
        jz print64_end 

        or rax, 0x0F00
        mov qword [rdi], rax

        inc rdi
        inc rdi
        jmp print64_loop

    print64_end:
        
    hlt
    jmp print64_loop
    jmp $


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
    
    ; set 32-bit flag on control register
    mov eax, cr0
    or  eax, 0x1
    mov cr0, eax

    ; far-jump to protected mode routine
    jmp GDT_32.code:start_32


[bits 32]
switch_long_mode:
    ; page tables
    ; PML4T:  0x1000 - 0x1FFF
    ; PDPT :  0x2000 - 0x2FFF
    ; PDT  :  0x3000 - 0x3FFF
    ; PT   :  0x4000 - 0x4FFF

    ; clear the tables
    mov edi, 0x1000     ; set destination index to 0x1000
    mov cr3, edi        ; set cr3 to destination index
    mov ecx, 4096       ; fill 4096 double words (16KB)
    xor eax, eax        ;   with 0x00000000
    rep stosd           ;     at edi (0x1000)
    mov edi, cr3        ; set destination index to cr3

    ; set the first entries on each table
    ; the '3' is to set presence and R/W bits
    mov dword [edi], 0x2000 | 3 ; PDPT
    add edi, 4096
    mov dword [edi], 0x3000 | 3 ; PDT
    add edi, 4096
    mov dword [edi], 0x4000 | 3 ; PT
    add edi, 4096

    ; initialize pages for first 2MB
    mov ebx, 0x00000003     ; first page
    mov ecx, 512            ; 512 entries
    .set_page_entry:
        mov dword [edi], ebx
        add edi, 8
        add ebx, 0x1000
        loop .set_page_entry

    ; enable PAE paging
    mov eax, cr4    ; read control register 4
    or eax, 1 << 5  ; set bit 5
    mov cr4, eax    ; write control register 4

    ; set the LM-bit
    mov ecx, 0xC0000080 ; select register EFER MSR
    rdmsr               ; read model specific register
    or eax, 1 << 8      ; set bit 8
    wrmsr               ; write model specific register

    ; set PG bit
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ; load the 64-bit GDT and jump to long mode code
    lgdt [GDT_64.pointer]
    jmp GDT_64.code:start_64


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


; a little string...
MSG_64: db "now in 64-bit mode!", 0x00


; --- mbr signature -------------------------------------------------
times 510-($-$$) db 0x00
dw 0xAA55
