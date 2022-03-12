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

%define EOL     0                       
                                        ; end of line 
%define WRITE   1
                                        ; 'write' syscall code 

%define STDOUT  1                       
                                        ; stdout fd 

;================================================

%ifndef rsPrint
%define rsPrint

;================================================

global RsPrint 

extern RsStrlen, RsItoa,RsItoa2n

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
            lea r12, [rbp + 24]         ; r12 -> first argument

            xor rdx, rdx                ; counter of symbols

            ;mov rdi, STDOUT             ; stdout

        .loop:
            cmp byte [rsi + rdx], EOL   ; if there EOL
            je .fin

            cmp byte [rsi + rdx], '%'   ; if there specifier
            je .write

            inc rdx                     ; to next symbol
            jmp .loop

        .write:
            cmp rdx, 0                  ; if counter == 0
            je .arg                     ; no need to write

            ;mov rax, WRITE              ; 'write' syscall code
            call WriteInBuf
            ;syscall                     ; else write

        .arg:
            call PrintArg             ; print argument
            jmp .loop

        .fin:
            cmp rdx, 0                  ; if counter == 0
            je .ret                     ; no need to write

            ;mov rax, WRITE              ; 'write' syscall code
            ;syscall                     ; else write

            call WriteInBuf

            call FlushBuf

        .ret:
            pop rbp                     ; restore rbp value
            ret

;-------------------PrintArg----------------------
;
; Descr: Prints in terminal argument in the way
;        according to specifier
;
; Entry: RSI + RDX -> %
;        R12 -> next arg to be printed
;        RAX == 1 (write)
;        RDI == 1 (stdout)
;
; Exit : RDX == 0
;        RSI -> next symb after specifier
;        R12 -> next argument in stack (+8)
;
; Destr: R8, R9, RAX
;------------------------------------------------

PrintArg:
            add rsi, rdx                ; move rsi -> %
            push rsi                    ; save current pos in format string

            movzx r8, byte [rsi + 1]
                                        ; get next symbol after '%'

            cmp r8, '%'
            jne .nodblpercent           ; '%%' case

            ;mov rax, WRITE              ; 'write' syscall
            mov rdx, 01d                ; print one symb

            ;syscall                     ; 'write' one %

            call WriteInBuf

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
            jmp .casenum

        .octagonal:
            mov rcx, 3
            jmp .casenum

        .hexadecimal:
            mov rcx, 4
            jmp .casenum

        .decimal:
            mov rcx, 10
            
        .casenum:
            call PrintArgNum
            jmp .fin 

        .char:
            call PrintArgChar
            jmp .fin

        .string:
            call PrintArgStr
            jmp .fin

        .casedefault:
            mov rdx, 2                  ; write "%%"
            ;mov rax, WRITE              ; 'write' syscall
            ;syscall

            call WriteInBuf

        .fin:
            xor rdx, rdx                ; counter = 0
            pop rsi                     ; restore rsi value
            add rsi, 2                  ; rsi -> next sym after specifier

            ret

;-------------------PrintArgNum------------------
;
; Descr: writes %d, %b, %o or %x argument
;
; Entry: RCX = 10 for %d of 1,3 and 4 for
;        %b, %o and %x
;
; Exit:  R12 -> next arg (+8)
;
; Destr: RSI, RAX, RDX
;------------------------------------------------

PrintArgNum:
            lea rsi, [PrintArgBuf]      ; buffer for string
            mov rbx, [r12]              ; get argument value

            cmp rcx, 10
            je .decimal                 ; jmp if  %d (rcx == 10 )

            mov rdx, 1
            shl rdx, cl                 ; counting mask for Itoa2n
            dec rdx                     ; rdx = 2^n - 1 (mask)

            call RsItoa2n               ; get string in buffer
                                        ; rsi remains its value
                                        ; rdi still equals 1
            ;jmp .writestr               ; jmp to write from buffer

        .decimal:
            call RsItoa                 ; call Itoa for 10-numeric system

        ;.writestr:
            ;call WriteStr             ; call 'write'

            add r12, 8                  ; r12 -> next argument

            ret

;-------------------PrintArgStr------------------
;
; Descr: Writes string argument
;
; Entry: RDI == 1
;        R12 -> current arguments ( address of string)
;
; Exit : R12 -> next argument (+8)
;
; Destr: RDX, RAX, RSI
;------------------------------------------------

PrintArgStr:
            mov rsi, [r12]              ; rsi -> argument string
            call RsStrlen               ; rcx = lenght of string

            mov rdx, rcx                ; rdx = number of symbols
            mov rax, WRITE              ; now: rax == 1, rdi == 1

            syscall                     ; call 'write'

            add r12, 8                  ; r12 -> next arg

            ret

;-------------------PrintArgChar-----------------
;
; Descr: Writes char argument in terminal
;
; Entry: RDI == 1
;        R12 -> current  argument
;
; Exit:  R12 -> next argument (+8)
;
; Destr: RDX, RAX, RSI
;------------------------------------------------

PrintArgChar:
            ;mov r8, 01d                 ; one symbol
            ;lea rsi, [PrintArgBuf]      ; buffer for argument

            ;mov rdx, [r12]              ; get argument
            ;mov [rsi], rdx              ; store char in buffer

            ;call WriteStr             ; call 'write'

            ;add r12, 8                  ; r12 -> next argument

            ret

;--------------------WriteStr--------------------
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

WriteStr:
        mov rdx, r8                     ; rdx = number of symbols
        mov rax, WRITE                  ; 'write' syscall

        syscall                         ; call write

        ret

;------------------WriteInBuf--------------------
;
; Descr:
;
; Entry:
;
; Exit :
;
; Destr:
;------------------------------------------------

WriteInBuf 

        ret 

;-------------------FlushBuf---------------------
;
; Descr:
;
; Entry:
;
; Exit :
;
; Destr:
;------------------------------------------------

FlushBuf

        ret 

;------------------------------------------------

[section .bss]

PrintBuf: resb 200                 ; buffer for RsPrint

__SECT__

;================================================

%endif