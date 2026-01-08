bits 16

start:
    call clear_screen

    mov si, msg_start
    call print
    call delay1sec
    mov si, msg_pak
    call print

    mov ah, 0
    int 16h

    call clear_screen

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

    mov di, input_buffer
    call input

    call chek_prompt

    jmp main_loop

clear_screen:
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
    
    mov si, input_buffer
    cmp byte [si], 0
    je .chek_end          
     
    mov si, input_buffer
    mov di, command_help
    call compare
    jc .cmd_help

    mov si, input_buffer
    mov di, command_cls
    call compare
    jc .cmd_cls

    mov si, input_buffer
    mov di, command_reboot
    call compare
    jc .cmd_reboot

    mov si, input_buffer
    mov di, command_logo
    call compare
    jc .cmd_logo

    mov si, input_buffer
    mov di, command_systemoff
    call compare
    jc .cmd_systemoff

    mov si, input_buffer
    mov di, command_bill
    call compare
    jc .cmd_bill

    mov si, input_buffer
    mov di, command_calculator
    call compare
    jc .cmd_calculator

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
    mov si, msg_help4
    call print
    mov si, msg_help5
    call print
    mov si, new_line
    call print
    jmp .buffer_clear     
.cmd_cls:
    call clear_screen
    jmp .buffer_clear     
.cmd_logo:
    call print_logo
    jmp .buffer_clear

.cmd_bill:
    call bill_info
    jmp .buffer_clear

.cmd_calculator:
    call calculator
    jmp .buffer_clear

.cmd_reboot:
    mov si, msg_reboot
    call print
    call delay1sec
    call .sys_reboot
    jmp .buffer_clear

.cmd_systemoff:
    mov si, msg_systemoff
    call print
    call delay1sec
    call sys_off
    jmp .buffer_clear

.sys_reboot:
    mov cx, 02h
    int 19h
    ret

.buffer_clear:
    mov cx, 64
    mov di, input_buffer
    xor al, al
    rep stosb
    mov byte [input_buffer], 0
    jmp .chek_end

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

bill_info:
    mov si, bill_fio
    call print
    mov si, bill_number
    call print
    mov si, bill_adress
    call print
    mov si, new_line
    call print
    ret

delay1sec:
    pusha
    mov ah, 0
    int 1ah
    mov bx, dx
    add bx, 18

.wait:
    int 1ah
    cmp dx, bx
    jb .wait
    popa
    ret

sys_off:
    mov ax, 0x5301
    xor bx, bx
    int 0x15
    jc .error
    mov ax, 0x530E
    xor bx, bx
    mov cx, 0x0102
    int 0x15
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    mov ax, 0x5308
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    
.error:
    ret

calculator:
    pusha
    mov si, msg_efn
    call print
    call input_num
    mov [num1], ax
    mov si, new_line
    call print
    mov si, msg_esn
    call print
    call input_num
    mov [num2], ax
    mov si, msg_results
    call print

.plus:
    mov si, msg_plus
    call print
    mov ax, [num1]
    mov bx, [num2]
    add ax, bx
    mov [result], ax
    call print_num
    mov si, new_line
    call print

.minus:
    mov si, msg_minus
    call print
    mov ax, [num1]
    mov bx, [num2]
    sub ax, bx
    mov [result], ax
    call print_num
    mov si, new_line
    call print

.minus_reverse:
    mov si, msg_minus2
    call print
    mov ax, [num2]
    mov bx, [num1]
    sub ax, bx
    mov [result], ax
    call print_num
    mov si, new_line
    call print

.umnojenie:
    mov si, msg_umn
    call print
    mov ax, [num1]
    mov bx, [num2]
    mul bx
    call print_num
    mov si, new_line
    call print

.delenie:
    mov si, msg_del
    call print
    mov ax, [num1]
    cmp ax, 0
    je .del_zero
    mov bx, [num2]
    cmp bx, 0
    je .del_zero
    xor dx, dx
    div bx
    mov si, new_line
    call print

.del_zero:
    mov si, msg_error_del
    call print
    jmp .ask

.ask:
    mov si, msg_continue
    call print
    mov ah, 0
    int 16h
    cmp al, 'y' 
    je calculator
    cmp al, 'Y' 
    je calculator
    popa
    jmp main_loop

input_num:
    pusha
    xor bx, bx

.input_num_loop:
    mov ah, 0
    int 16h
    cmp al, 0x0d
    je .done
    cmp al, 0x08
    je .backspace
    cmp al, '0' 
    jb .input_num_loop
    cmp al, '9' 
    ja .input_num_loop
    mov ah, 0x0e
    int 10h
    sub al, '0' 
    inc cx
    jmp .input_num_loop

.backspace:
    cmp bx, 0
    je .input_num_loop
    mov ah, 0x0e
    mov al, 0x08
    int 10h
    mov al, ' ' 
    int 10h
    mov al, 0x08
    int 10h
    mov ax, bx
    mov bx, 10
    xor dx, dx
    div bx
    mov bx, ax
    jmp .input_num_loop

.done:
    mov ax, bx
    popa
    ret

print_num:
    push ax
    push bx
    push cx
    push dx
    cmp ax, 0
    jne .not_zero
    mov ah, 0x0e
    mov al, '0' 
    int 10h
    jmp .print_num_done

.not_zero:
    mov bx, 10
    xor cx, cx

.divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .divide

.print_digit:
    pop ax
    add al, '0' 
    mov ah, 0x0e
    int 10h
    loop .print_digit

.print_num_done:
    pop ax
    pop bx
    pop cx
    pop dx
    ret

logo_line1 db " __     __    _     _  ____                ", 0xd, 0xa, 0
logo_line2 db " \ \   / /__ (_) __| |/ ___|___  _ __ ___  ", 0xd, 0xa, 0
logo_line3 db "  \ \ / / _ \| |/ _` | |   / _ \| '__/ _ \ ", 0xd, 0xa, 0
logo_line4 db "   \ V / (_) | | (_| | |__| (_) | | |  __/ ", 0xd, 0xa, 0
logo_line5 db "    \_/ \___/|_|\__,_|\____\___/|_|  \___| ", 0xd, 0xa, 0

new_line db 0xd, 0xa, 0

msg_welcome db "Welcome to VoidCore OS", 0xd, 0xa, 0
msg_help db "Type 'help' to show a list of commands", 0xd, 0xa, 0
msg_prompt db "> ", 0
msg_reboot db "Rebooting...", 0xd, 0xa, 0
msg_unknown_cmd db "Unknown command", 0xd, 0xa, 0
msg_start db "Starting VoidCore OS...", 0xd, 0xa, 0
msg_pak db "Press any key to continue... ", 0
msg_systemoff db "System off... ", 0
msg_efn db "Enter first number: ", 0
msg_esn db "Enter second number: ", 0
msg_results db "Results: ", 0xd, 0xa, 0
msg_plus db "a + b = ", 0
msg_minus db "a - b = ", 0
msg_minus2 db "b - a = ", 0
msg_umn db "a * b = ", 0
msg_del db "a / b = ", 0
msg_continue db "Do you want continue? [y/n]: ", 0
msg_error_del db "Error, you can't divide by zero", 0xd, 0xa, 0

command_help db "help", 0
command_cls db "cls", 0
command_reboot db "reboot", 0
command_logo db "logo", 0
command_bill db "bill", 0
command_systemoff db "systemoff", 0
command_calculator db "calculator", 0

msg_help1 db "cls               Clear screen", 0xd, 0xa, 0
msg_help2 db "logo              Show logo VoidCore OS", 0xd, 0xa, 0
msg_help3 db "systemoff         Shutdown system", 0xd, 0xa, 0
msg_help4 db "reboot            Reboot system", 0xd, 0xa, 0
msg_help5 db "calculator        Counting values", 0xd, 0xa, 0
msg_help6 db "help              Show list of commands", 0xd, 0xa, 0

bill_fio db "FIO:        Kramskih Valeriy Vasilyevich", 0xd, 0xa, 0
bill_number db "Number:     +7(913)-015-0302", 0xd, 0xa, 0
bill_adress db "Adress:     Russia, Novosibirsk, Noviy sharap, Pochtovaya 36", 0xd, 0xa, 0

input_buffer times 65 db 0

num1 times 16 db 0
num2 times 16 db 0
result times 16 db 0
number_buffer times 32 db 0
