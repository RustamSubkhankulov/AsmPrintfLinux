global main

extern mysub 
extern kinda_printf

section .text

main:

	mov rdi, 10
	mov rsi, 2 

	call mysub 

	mov rsi, 13
	
	lea rdi, [String]
	mov rax, 0

	call kinda_printf
	
	;mov rdi, [stdout]
	;call fflush
	
	mov rax, 0x3c	; exit (rdi)
	xor rdi, rdi
	syscall

section .data

String db "Hello World %d", 0Ah, 0