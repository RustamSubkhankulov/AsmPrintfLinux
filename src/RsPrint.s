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

            mov rax, 01h                ; 'write' syscall code
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

            syscall                     ; else write

        .arg:
            call RsPrintArg             ; print argument
            jmp .loop 

        .fin:
            cmp rdx, 0                  ; if counter == 0
            je .ret                     ; no need to write 

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

            movzx r8, byte [rsi + 1]    
                                        ; get next symbol after '%'

            cmp r8, '%'
            jne .nodblpercent

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
            dq .char                    ; 1
            dq .decimal                 ; 2
            dq .casedefault             ; 3
            dq .casedefault             ; 4
            dq .casedefault             ; 5
            dq .casedefault             ; 6
            dq .casedefault             ; 7
            dq .casedefault             ; 8
            dq .casedefault             ; 9
            dq .casedefault             ; 10
            dq .casedefault             ; 11
            dq .casedefault             ; 12
            dq .octagonal               ; %o
            dq .casedefault             ; 14
            dq .casedefault             ; 15
            dq .casedefault             ; 16
            dq .string                  ; %s
            dq .casedefault             ; 18
            dq .casedefault             ; 19
            dq .casedefault             ; 20
            dq .casedefault             ; 21
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
            syscall 

        .fin: 
            xor rdx, rdx                ; counter = 0
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
; Destr: 
;------------------------------------------------

RsPrintArgDec:

            push rsi
            push rbx                    ; saving current position in format string
                                        ; no need to save rdx
                                        ; save current argument position in stack (rbx) 

            lea rsi, [PrintArgBuf]      ; buffer for string
            mov r9, 10d                 ; base of numeric system
            mov rbx, [rbx]              ; get argument value

            call RsItoa                 ; now R8 = number of symbols in string 
                                        ; rsi remains it value 
                                        ; rdi still equals 1

            call RsWriteStr             ; call 'write'

            pop rbx 
            pop rsi                     ; restore values
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
; Destr: RDX
;------------------------------------------------

RsPrintArg2n:
            push rsi
            push rbx                    ; saving current position in format string
                                        ; no need to save rdx
                                        ; save current argument position in stack (rbx) 

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
            pop rsi                     ; restore values
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
; Destr: RDX 
;------------------------------------------------

RsPrintArgStr:
            push rsi                    ; saving current position in format string
                                        ; no need to save rdx

            mov rsi, [rbx]              ; rsi -> argument string
            call RsStrlen               ; rcx = lenght of string

            mov rdx, rcx                ; rdx = number of symbols
            mov rax, 01d                ; now: rax == 1, rdi == 1

            syscall                     ; call 'write'

            pop rsi                     ; restore value
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
; Destr: RDX
;------------------------------------------------

RsPrintArgChar:
            push rsi                    ; saving current position in format string
                                        ; no need to save rdx

            mov r8, 01d                 ; one symbol
            lea rsi, [PrintArgBuf]      ; buffer for argument

            mov rdx, [rbx]              ; get argument
            mov [rsi], rdx              ; store char in buffer

            call RsWriteStr             ; call 'write'

            pop rsi 
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
; Exit:  RAX == 1
;
; Destr: RDX
;------------------------------------------------

RsWriteStr:

        mov rdx, r8                     ; rdx = number of symbols
        mov rax, 01d                    ; 'write' syscall

        syscall                         ; call write

        ret 

;------------------------------------------------

section .bss  

PrintArgBuf: resb 64                 ; buffer used for itoa

;================================================

%endif