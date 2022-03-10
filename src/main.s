;================================================
;                         (c) Rustam4ik, 2029 - 7
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

%include    "PrintUnitTests.s"                  
                                        ; unit tests for 
                                        ; printf function

;================================================

section .text 

;==================Main=Body=====================

global _start

_start:     

            ;call CharUnitTest

            call StrUnitTest

            ;call DecUnitTest

            ;call OctUnitTest

            ;call HexUnitTest

            ;call BinUnitTest

            ;call PercUnitTest

            ;call DefUnitTest

            ;call ComplexUnitTest

            .EXIT

;================================================

section .data 

TestString:          db "Hello World",0Ah, 0
;MainBuf:    times 64 db (1)




