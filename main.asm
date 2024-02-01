[bits 16]

_start:
    xor ax, ax

times 510-($-$$) db 0
dw 0xAA55
