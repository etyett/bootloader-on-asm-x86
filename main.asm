bits 16

start:
    mov si, msg_start
    call print

    call cls

    call print_logo
    mov si, msg_welcome
    call print
    mov si, new_line
    call print
    mov si, msg_help
    call print
    mov si, new_line
    call print

    jmp main_loop

print:
    mov ah, 0x0e

.loop:
    lodsb
    test al, al
    jz .print_done
    int 10h
    jmp .loop

.print_done:
    ret

print_logo:
    mov si, logo_line1
    call print
    mov si, logo_line2
    call print
    mov si, logo_line3
    call print
    mov si, logo_line4
    call print
    mov si, logo_line5
    call print
    mov si, new_line
    call print
    mov si, new_line
    call print
    ret

main_loop:
    mov si, msg_prompt
    call print

    mov di, buffer
    call input

    call chek_prompt

    jmp main_loop

cls:
    mov ax, 3
    int 10h
    ret

input:
    pusha
    mov cx, 0

.input_loop:
    mov ah, 0
    int 16h
    cmp al, 0x0d          
    je .input_done
    cmp al, 0x08          
    je .backspace
    cmp cx, 64            
    je .input_loop        
    mov [di], al
    inc di
    inc cx
    mov ah, 0x0e
    int 10h
    jmp .input_loop

.backspace:
    cmp cx, 0
    je .input_loop
    dec di
    dec cx
    mov ah, 0x0e
    mov al, 0x08
    int 10h
    mov al, ' ' 
    int 10h
    mov al, 0x08
    int 10h
    jmp .input_loop

.input_done:
    mov byte [di], 0      
    mov ah, 0x0e
    mov al, 0x0d
    int 10h
    mov al, 0x0a
    int 10h
    
    popa
    ret                   

chek_prompt:
    pusha
    
    mov si, buffer
    cmp byte [si], 0
    je .chek_end          
     
    mov si, buffer
    mov di, command_help
    call compare
    jc .cmd_help

    mov si, buffer
    mov di, command_cls
    call compare
    jc .cmd_cls

    mov si, buffer
    mov di, command_reboot
    call compare
    jc .cmd_reboot

    mov si, buffer
    mov di, command_logo
    call compare
    jc .cmd_logo

    mov si, msg_unknown_cmd
    call print
    jmp .chek_end

.cmd_help:
    mov si, new_line
    call print
    mov si, msg_help1
    call print
    mov si, msg_help2
    call print
    mov si, msg_help3
    call print
    mov si, new_line
    call print
    jmp .buffer_clear     
.cmd_cls:
    call cls
    jmp .buffer_clear     
.cmd_logo:
    call print_logo
    jmp .buffer_clear

.cmd_reboot:
    mov si, msg_reboot
    call print
    mov cx, 02h

.delay:
    loop .delay
    int 19h

.buffer_clear:
    mov cx, 64
    mov di, buffer
    xor al, al
    rep stosb
    mov byte [buffer], 0

.chek_end:
    popa
    ret

compare:
    pusha

.compare_loop:
    mov al, [si]
    mov bl, [di]
    cmp al, 0
    je .compare_chek
    cmp bl, 0
    je .not_equal
    cmp al, bl
    jne .not_equal
    inc si
    inc di
    jmp .compare_loop

.compare_chek:
    cmp byte [di], 0
    jne .not_equal
    popa
    stc          
    ret

.not_equal:
    popa
    clc          
    ret

; Данные
logo_line1 db " __     __    _     _  ____                ", 0xd, 0xa, 0
logo_line2 db " \ \   / /__ (_) __| |/ ___|___  _ __ ___  ", 0xd, 0xa, 0
logo_line3 db "  \ \ / / _ \| |/ _` | |   / _ \| '__/ _ \ ", 0xd, 0xa, 0
logo_line4 db "   \ V / (_) | | (_| | |__| (_) | | |  __/ ", 0xd, 0xa, 0
logo_line5 db "    \_/ \___/|_|\__,_|\____\___/|_|  \___| ", 0xd, 0xa, 0

msg_welcome db "Welcome to VoidCore OS", 0xd, 0xa, 0
msg_help db "Type 'help' to show a list of commands", 0xd, 0xa, 0
new_line db 0xd, 0xa, 0
msg_prompt db "> ", 0
msg_reboot db "Rebooting...", 0xd, 0xa, 0
msg_unknown_cmd db "Unknown command", 0xd, 0xa, 0
msg_start db "Starting VoidCore OS...", 0xd, 0xa, 0

command_help db "help", 0
command_cls db "cls", 0
command_reboot db "reboot", 0
command_logo db "logo", 0

msg_help1 db "cls               Clear screen", 0xd, 0xa, 0
msg_help2 db "logo              Show logo VoidCore OS", 0xd, 0xa, 0
msg_help3 db "reboot            Reboot system", 0xd, 0xa, 0

buffer times 65 db 0
