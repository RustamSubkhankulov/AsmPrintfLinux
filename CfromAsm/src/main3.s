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

	call printf     ; call standart printf
	
	;mov rdi, [stdout]
	;call fflush
	
	mov rax, 0x3c	; exit function syscall code  
	xor rdi, rdi    ; exit code
	syscall         

;================================================

section .data

Format db "Hello World", 0Ah, 0