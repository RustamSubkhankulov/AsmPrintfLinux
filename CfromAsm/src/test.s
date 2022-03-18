global _start

section .text

_start:
	mov rsi, 13
	
	lea rdi, [String]
	mov rax, 0

	call printf

	mov rdi, [stdout]
	call fflush
	
	mov rax, 0x3c	; exit (rdi)
	xor rdi, rdi
	syscall

section .data

String db 'Hello World %d