;================================================
;                            (c) Rustamchik, 2022
;================================================

section .text 

;====================Macro=======================

;-------------------.EXIT------------------------

%macro      .EXIT 0                 
                                        ; terminates programm
            xor rdi, rdi                ; exit code 0
            mov rax, 03Ch               ; exit
            syscall                 
%endmacro

;------------------------------------------------

;==================Includes======================

%include    "print.s"                      
                                        ; printf function
%include    "itoa.s"           
                                        ; itoa function

%include    "strlen.s"                     
                                        ; strlen function

;%include unittest64.s                  
                                        ; unit tests for 
                                        ; printf function

;================================================

section .text 

;==================Main=Body=====================

global _start

_start:     mov r9, 10d
            mov rdi, MainBuf
            mov rbx, 256d

            call Itoa 

            mov rax, 01h                ; write
            mov rdi, 1                  ; stdout
            mov rsi, MainBuf            ; char* buf
            mov rdx ,rdi                ; rdx = number of symbols

            syscall                     ; call write 

            .EXIT

;================================================

section .bss

MainBuf:    resb 64 




