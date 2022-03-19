;================================================
;                        (c) Rustam4ik, 2029 - 7
;================================================

extern printf      

;================================================

section .text

;==================MainBody======================

global _start       
_start:

	lea rdi, [Format]
                    ; format string 
	mov rax, 0      ; number of float args 

	mov rsi, 1 
	mov rdx, 2
	mov rcx, 3 
	mov r8 , 4 
	mov r9 , 5

	push 9
	push 8 
	push 7 
	push 6

	call printf     ; call standart printf

	add rsp, 32
	
	;mov rdi, [stdout]
	;call fflush
	
	mov rax, 0x3c	; exit function syscall code  
	xor rdi, rdi    ; exit code
	syscall         

;================================================

section .data

Format db "Hello World %d %d %d %d %d %d %d %d %d ", 0Ah, 0