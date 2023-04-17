section .data
    prompt db 'Enter a string: '
    prompt_len equ $-prompt

section .bss
    buffer resb 128

section .text
    global _start

_start:
    ; print the prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; read in the input
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 128
    int 0x80

    ; find the length of the input
    xor ebx, ebx
    mov bl, byte [buffer + eax - 1] ; get the last character of the input
    sub bl, '0' ; convert the character to a number
    mov ecx, eax
    sub ecx, 1
    xor eax, eax
    mov al, bl
    mov ebx, 10
    mul ebx ; multiply the length by 10 to get the actual length
    add ecx, eax ; add the actual length to the buffer size

    ; read in the rest of the input
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer ; start reading after the length prefix
    mov edx, ecx ; use ecx as a counter for the number of bytes read
.read_loop:
    sub edx, ecx ; subtract the number of bytes read from the counter
    add edx, ecx ; add the buffer size back to the counter
    cmp edx, ecx ; compare the counter to the buffer size
    jae .read_done ; if the counter is greater than or equal to the buffer size, we're done
    mov eax, 3
    mov ebx, 0
    add ebx, buffer ; use ebx as the file descriptor for stdin
    add ecx, edx ; add the number of bytes read to the buffer address
    mov edx, 128
    sub edx, edx ; zero out edx
    int 0x80
    jmp .read_loop
.read_done:

    ; print the input
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer ; start printing after the length prefix
    mov edx, ecx ; use ecx as the length of the input string
    int 0x80

    ; exit
    mov eax, 1
    xor ebx, ebx
    int 0x80
