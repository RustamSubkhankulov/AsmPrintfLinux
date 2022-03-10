%ifndef rsPrintUnitTests
%define rsPrintUnitTests

;================================================

section .text 

;=================FUNCTIONS======================

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

section .data 

StrArgument db "Rustam", 0

section .text 

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

        push 25f25Ah
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

section .data 

;------------------------------------------------

PercFormatStr:  db "Testing %%%%", 0Ah, 0

;------------------------------------------------

DefFormatStr:   db "Testing default case: %a %1 %$", 0Ah, 0

;------------------------------------------------

CharFormatStr:  db "Testing %%c: printing symbol %c", 0Ah, 0

;------------------------------------------------

StrFormatStr:   db "Testing %%s: string - %s", 0Ah, 0

;------------------------------------------------

BinFormatStr:   db "Testing %%b: %b", 0Ah, 0

;------------------------------------------------

DecFormatStr:   db "Testing %%d: %d", 0Ah, 0

;------------------------------------------------

OctFormatStr:   db "Testing %%o: %0", 0Ah, 0

;------------------------------------------------

HexFormatStr:   db "Testin %%x: %x", 0Ah, 0

;------------------------------------------------

ComplexFormatStr:
                db "String: %s, char %c, decimal %d, binary %b, oct %o, hex %x", 0Ah, 0

;================================================

%endif 










