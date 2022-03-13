%ifndef rsPrintUnitTests
%define rsPrintUnitTests

;================================================

global  UnitTesting

extern  RsPrint

;================================================

section .text 

;===================MACRO========================

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

[section .data] 

PauseBuf    db 0                        ; reads one symb

__SECT__

;=================FUNCTIONS======================

;----------------UnitTesting---------------------
;
; Descr: executes unit testing of RsPrint
;
;------------------------------------------------

UnitTesting:

        call CharUnitTest
        .PAUSE

        call StrUnitTest
        .PAUSE

        call DecUnitTest
        .PAUSE

        call OctUnitTest
        .PAUSE

        call HexUnitTest
        .PAUSE

        call BinUnitTest
        .PAUSE

        call PercUnitTest
        .PAUSE

        call DefUnitTest
        .PAUSE

        call ComplexUnitTest
        .PAUSE

        ret 

;----------------CharUnitTest--------------------
;
; Descr: tests '%c' specifier
;
; Entry: none
;
; Exit : none
;
; Destr: 
;------------------------------------------------

CharUnitTest:

        push '!'
        push CharFormatStr              ; push arguments

        call RsPrint

        add rsp, 16                     

        ret 

;-----------------StrUnitTest--------------------
;
; Descr: tests '%s' specifier
;
; Entry: none
;
; Exit : none
;
; Destr:
;------------------------------------------------

StrUnitTest:

        push StrArgument
        push StrFormatStr

        call RsPrint

        add rsp, 16

        ret 

[section .data] 
StrArgument db "Rustam", 0
__SECT__ 

;-----------------DecUnitTest--------------------
;
; Descr: tests '%d' specifier
;
; Entry: none
;
; Exit : none
;
; Destr:
;------------------------------------------------

DecUnitTest:

        push 1256d
        push DecFormatStr

        call RsPrint

        add rsp, 16 

        ret 

;-----------------OctUnitTest--------------------
;
; Descr: tests '%o' specifier
;
; Entry: none
;
; Exit : none
;
; Destr:
;------------------------------------------------

OctUnitTest:

        push 24d
        push OctFormatStr

        call RsPrint

        add rsp, 16
        
        ret
;-----------------HexUnitTest--------------------
;
; Descr: tests '%x' specifier
;
; Entry: none
;
; Exit : none
;
; Destr:
;------------------------------------------------

HexUnitTest:

        push 3802d
        push HexFormatStr
        
        call RsPrint

        add rsp, 16

        ret 
;-----------------BinUnitTest--------------------
;
; Descr: tests '%b' specifier
;
; Entry: none
;
; Exit : none
;
; Destr:
;------------------------------------------------

BinUnitTest:

        push 1011011b
        push BinFormatStr

        call RsPrint

        add rsp, 16

        ret 

;-----------------PercUnitTest-------------------
;
; Descr: tests '%%' specifier
;
; Entry: none
;
; Exit : none 
;
; Destr:
;------------------------------------------------

PercUnitTest:

        push PercFormatStr

        call RsPrint

        add rsp, 8

        ret 

;-----------------DefUnitTest--------------------
;
; Descr: tests default case ( %f, %1 and etc)
;
; Entry: none
;
; Exit : none 
;
; Destr:
;------------------------------------------------

DefUnitTest:

        push DefFormatStr

        call RsPrint

        add sp, 8

        ret 

;-----------------ComplexUnitTest----------------
;
; Descr: tests different specifiers in one format
;        string
;
; Entry: none
;
; Exit : none 
;
; Destr:
;------------------------------------------------

ComplexUnitTest:

        push 25ABh
        push 24d 
        push 10110011b
        push 256255d
        push '!'
        push StrArgument
        push ComplexFormatStr

        call RsPrint

        add rsp, 56

        ret 

;================================================

[section .data] 

;------------------------------------------------

PercFormatStr:  db "Testing %%%% : %%", 0Ah, 0

;------------------------------------------------

DefFormatStr:   db "Testing default case: %a %1 %$", 0Ah, 0

;------------------------------------------------

CharFormatStr:  db "Testing %%c: printing symbol ! -  %c", 0Ah, 0

;------------------------------------------------

StrFormatStr:   db "Testing %%s: string 'Rustam' - %s", 0Ah, 0

;------------------------------------------------

BinFormatStr:   db "Testing %%b: number 1011011 - %b", 0Ah, 0

;------------------------------------------------

DecFormatStr:   db "Testing %%d: number 1256 - %d", 0Ah, 0

;------------------------------------------------

OctFormatStr:   db "Testing %%o: number 30 - %o", 0Ah, 0

;------------------------------------------------

HexFormatStr:   db "Testing %%x: 3802d - %x", 0Ah, 0

;------------------------------------------------

ComplexFormatStr:
                db "String: Rustam - %s, char ! - %c, decimal 256255 - %d, binary 10110011 - %b, oct 30 - %o, hex 25AB - %x", 0Ah, 0

__SECT__

;================================================

%endif 










