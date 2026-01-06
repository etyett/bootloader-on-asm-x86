org 0x7c00
bits 16

    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    mov ah, 0x02
    mov al, 4
    mov ch, 0
    mov dh, 0
    mov cl, 2
    mov bx, 0x7E00
    int 0x13

    jmp 0x7e00

times 510-($-$$) db 0
dw 0xaa55

%include 'C:\Users\eneze\Desktop\OS\main.asm'
