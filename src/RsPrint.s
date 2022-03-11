;====================MACRO=======================

;-----------------.PROLOGUE----------------------
;
; Descr: pushes arguments in stack in normal order
;
;------------------------------------------------

%macro  .PROLOGUE   1-*                 
                                        ; 1 and more args
    %rep %0                             

        push %1 
        %rotate 1

    %endrep 

%endmacro

;------------------.EPILOGUE---------------------
;
; Descr: popes arguments from stack in reversed order
;
;------------------------------------------------

%macro .EPILOGUE   1-*

    %rep %0

        %rotate -1
        %pop %1

    %endrep 

%endmacro

;====================PRINTF======================

; 'Printf' assembler function made for 
;                         Linux x86_64
;
; File consists unit tests for functions
; Includes STRLIB library 

; %s - '0'-terminated string
; %c - symbol
; %d - decimal
; %x - hexidecimal
; %o - octagonal
; %b - binary

;   b   c   d   o   s   x
;   2d  2d  3d  14d 18d 23d
;   62h 63h 64h 6Fh 73h 78h

;================================================

%ifndef rsPrint
%define rsPrint 

;================================================

section .text 

;==================FUNCTIONS=====================

;-------------------RsPrint----------------------
;
; Descr: Prints string in terminal
; Entry: Gains arguments in stack (CDECL)
;        First arg  - format string
;        Next  args - arguments for format string
; Exit : None
; Desrt: a lot
;-------------------------------------------------

RsPrint:     
            push rbp
            mov rbp, rsp                ; make stack frame

            mov rsi, [rbp + 16]         ; rbp -> start of format string
            lea rbx, [rbp + 24]         ; rbx -> first argument

            xor rdx, rdx                ; counter of symbols 

            mov rdi, 01h                ; stdout

        .loop:
            cmp byte [rsi + rdx], 0     ; if there EOL
            je .fin

            cmp byte [rsi + rdx], '%'   ; if there specifier
            je .write 

            inc rdx                     ; to next symbol
            jmp .loop 

        .write:  
            cmp rdx, 0                  ; if counter == 0
            je .arg                     ; no need to write

            mov rax, 01h                ; 'write' syscall code
            syscall                     ; else write

        .arg:
            call RsPrintArg             ; print argument
            jmp .loop 

        .fin:
            cmp rdx, 0                  ; if counter == 0
            je .ret                     ; no need to write 

            mov rax, 01h                ; 'write' syscall code
            syscall                     ; else write

        .ret: 
            pop rbp                     ; restore rbp value
            ret 

;------------------RsPrintArg---------------------
;
; Descr: Prints in terminal argument in the way
;        according to specifier
;
; Entry: RSI + RDX -> % 
;        RBX -> next arg to be printed
;        RAX == 1 (write)
;        RDI == 1 (stdout)
;
; Exit : RDX == 0
;        RSI -> next symb after specifier
;
; Destr:
;------------------------------------------------

RsPrintArg:  
            add rsi, rdx                ; move rsi -> %  
            push rsi                    ; save current pos in format string  

            movzx r8, byte [rsi + 1]    
                                        ; get next symbol after '%'

            cmp r8, '%'
            jne .nodblpercent           ; '%%' case 

            mov rax, 01d                ; 'write' syscall 
            mov rdx, 01d                ; print one symb

            syscall                     ; 'write' one %

            jmp .fin 

        .nodblpercent:
            sub r8, 'b'                 ; r8 = offset of the symbol
                                        ; from 'b' in ASCII table

            cmp r8, 'x' - 1             ; if specifier is not recognized
            ja .casedefault             ; print two symbol incuding '%'

            mov r8, [.jmptable + r8 * 8]
            jmp r8                      ; else jmp using table

        .jmptable: 
            dq .binary                  ; %b
            dq .char                    ; %c
            dq .decimal                 ; %d

            times 'n' - 'd' dq .casedefault

            dq .octagonal               ; %o

            times 'r' - 'o' dq .casedefault

            dq .string                  ; %s

            times 'w' - 's' dq .casedefault

            dq .hexadecimal             ; %x

        .binary:
            mov rcx, 1
            jmp .case2n

        .octagonal:
            mov rcx, 3
            jmp .case2n

        .hexadecimal:
            mov rcx, 4
            jmp .case2n

        .decimal:
            call RsPrintArgDec
            jmp .fin

        .char: 
            call RsPrintArgChar
            jmp .fin 

        .string:
            call RsPrintArgStr
            jmp .fin

        .case2n:
            call RsPrintArg2n
            jmp .fin 

        .casedefault:
            mov rdx, 2                  ; write "%%"
            mov rax, 01d                ; 'write' syscall 
            syscall 

        .fin: 
            xor rdx, rdx                ; counter = 0
            pop rsi                     ; restore rsi value 
            add rsi, 2                  ; rsi -> next sym after specifier
            
            ret 

;------------------RsPrintArgDec-----------------
;
; Descr: Prints number in decimal numeric system
;
; Entry: RBX -> arguments
;        RDI == 1 (stdout)
;
; Exit : RBX -> next arguments (+8)
;
; Destr: RSI, RDX, RAX 
;------------------------------------------------

RsPrintArgDec:

            push rbx                    ; save current argument position in stack (rbx) 

            lea rsi, [PrintArgBuf]      ; buffer for string
            mov r9, 10d                 ; base of numeric system
            mov rbx, [rbx]              ; get argument value

            call RsItoa                 ; now R8 = number of symbols in string 
                                        ; rsi remains it value 
                                        ; rdi still equals 1

            call RsWriteStr             ; call 'write'

            pop rbx                     ; restore values
            add rbx, 8                  ; rbx -> next argument

            ret 

;------------------RsPrintArg2n------------------
;
; Descr: Print argument in numeric system with 
;        base, that is a power of 2 (2 ^n)
;
; Entry: RCX == n
;        RBX -> current argument
;        RDI == 1(stdout)
; Exit : RBX -> next argument (+8)
;
; Destr: RDX, RAX 
;------------------------------------------------

RsPrintArg2n:
            push rbx                    ; save current argument position in stack (rbx) 

            lea rsi, [PrintArgBuf]      ; buffer for string
            mov rbx, [rbx]              ; get argument value

            mov rdx, 1
            shl rdx, cl
            dec rdx                     ; rdx = 2^n - 1 (mask)

            call RsItoa2n               ; get string in buffer
                                        ; rsi remains its value
                                        ; rdi still equals 1

            call RsWriteStr             ; call 'write'

            pop rbx 
            add rbx, 8                  ; rbx -> next argument

            ret 

;------------------RsPrintArgStr-----------------
;
; Descr: Writes string argument
;
; Entry: RDI == 1
;        RBX -> current arguments ( address of string)
;
; Exit : RBX -> next argument (+8)
;
; Destr: RDX, RAX, RSI 
;------------------------------------------------

RsPrintArgStr:
            mov rsi, [rbx]              ; rsi -> argument string
            call RsStrlen               ; rcx = lenght of string

            mov rdx, rcx                ; rdx = number of symbols
            mov rax, 01d                ; now: rax == 1, rdi == 1

            syscall                     ; call 'write'

            add rbx, 8

            ret 

;------------------RsPrintArgChar----------------
;
; Descr: Writes char argument in terminal
;
; Entry: RDI == 1
;        RBX -> current  argument
;
; Exit:  RBX -> next argument (+8)
;
; Destr: RDX, RAX, RSI 
;------------------------------------------------

RsPrintArgChar:
            mov r8, 01d                 ; one symbol
            lea rsi, [PrintArgBuf]      ; buffer for argument

            mov rdx, [rbx]              ; get argument
            mov [rsi], rdx              ; store char in buffer

            call RsWriteStr             ; call 'write'

            add rbx, 8                  ; rbx -> next argument

            ret 
            

;-------------------RsWriteStr-------------------
;
; Descr: writes particular number of symbols in 
;        terminal using 'write' Linux system call 
;
; Entry: R8 - number of synbols to be printed
;        RSI - start of the string
;        RDI == 1 (stdout)
;
; Exit:  none 
;
; Destr: RDX, RAX 
;------------------------------------------------

RsWriteStr:
        mov rdx, r8                     ; rdx = number of symbols
        mov rax, 01d                    ; 'write' syscall

        syscall                         ; call write

        ret 

;------------------------------------------------

[section .bss]  

PrintArgBuf: resb 64                 ; buffer used for itoa

__SECT__

;================================================

%endif