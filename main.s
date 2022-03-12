;================================================
;                        (c) Rustam4ik, 2029 - 7
;================================================

extern  CharUnitTest, StrUnitTest, DecUnitTest, OctUnitTest, HexUnitTest, BinUnitTest, PercUnitTest, DefUnitTest, ComplexUnitTest

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

;-------------------.PAUSE-----------------------

%macro      .PAUSE 0 
                                        ; getchar();
		    nop
		    xor rax, rax                ; read

		    mov rdi, 0                  ; stdin - first arg
            mov rsi, PauseBuf
                                        ; char* buf - second arg
            mov rdx, 1                  ; read one byte

            syscall                     ; call read         
            
		    nop
%endmacro

;------------------------------------------------

section .data 

PauseBuf    db 0                        ; reads one symb

section .text

;------------------------------------------------

; ;==================Includes======================

; %include    "RsPrint.s"                      
;                                         ; printf function
; %include    "RsItoa.s"           
;                                         ; itoa function

; %include    "RsStrlen.s"                     
;                                         ; strlen function

; %include    "PrintUnitTests.s"                  
;                                         ; unit tests for 
;                                         ; printf function

;================================================

section .text 

;==================Main=Body=====================

global _start

_start:     

            ;call CharUnitTest
            .PAUSE

            ;call StrUnitTest
            .PAUSE

            ;call DecUnitTest
            .PAUSE

            ;call OctUnitTest
            .PAUSE

            ;call HexUnitTest
            .PAUSE

            ;call BinUnitTest
            .PAUSE

            ;call PercUnitTest
            .PAUSE

            ;call DefUnitTest
            .PAUSE

            ;call ComplexUnitTest
            .PAUSE

            .EXIT

;================================================

section .data 

TestString:          db "Hello World",0Ah, 0
;MainBuf:    times 64 db (1)




