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

%include    "RsPrint.s"                      
                                        ; printf function
%include    "RsItoa.s"           
                                        ; itoa function

%include    "RsStrlen.s"                     
                                        ; strlen function

;%include unittest64.s                  
                                        ; unit tests for 
                                        ; printf function

;================================================

section .text 

;==================Main=Body=====================

global _start

_start:     



            ;lea rdi, [TestString]

            ;call RsStrlen

            ;mov r9, 4d
            ;mov rdx, 0Fh
            ;lea rdi, [MainBuf]
            ;mov rbx, rcx 

            ;call RsItoa2n 

            ;mov rax, 01h                ; write
            ;mov rdi, 1                  ; stdout
            ;lea rsi, [MainBuf]          ; char* buf
            ;mov rdx, r8                 ; rdx = number of symbols

            ;ssyscall                     ; call write 

            .EXIT

;================================================

section .data 

;TestString:          db "Hello World", 0
;MainBuf:    times 64 db (1)




