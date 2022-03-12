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
;   1d  2d  3d  14d 18d 23d
;   62h 63h 64h 6Fh 73h 78h

;================================================

%define EOL     0                       
                                        ; end of line 
%define WRITE   1
                                        ; 'write' syscall code 

%define STDOUT  1                       
                                        ; stdout fd 

%define BufSize 10d                     
                                        ; size of buffer for RsPrint

%define RealBufSize BufSize + 64            
                                        ; real size of PrintBuf

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
; Desrt: R8, RAX, RBX, RCX, R15, RDX, RSI, RDI, R13
;-------------------------------------------------

RsPrint:
            push rbp
            mov rbp, rsp                ; make stack frame

            mov rsi, [rbp + 16]         ; rbp -> start of format string
            lea r12, [rbp + 24]         ; r12 -> first argument

            xor rdx, rdx                ; counter of symbols
            xor r13, r13                ; counter in PrintBuf

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

            call WriteInBuf             ; write symbols from format 
                                        ; string in buffer

        .arg:
            call PrintArg               ; print argument
            jmp .loop

        .fin:
            cmp rdx, 0                  ; if counter == 0
            je .flushcheck              ; no need to write
                                        ; but buffer can be not empty
            call WriteInBuf

        .flushcheck:
            cmp r13, 0                  ; is buffer empty
            je .ret                     ; jmp to ret if it is 

            call FlushBuf               ; final flush of buffer 
                                        ; if it is not empty
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
;        R13 == number of symbols in buffer
;
; Destr: R8, RAX, RBX, RCX, R15, RDI
;------------------------------------------------

PrintArg:
            push rsi                    ; save current pos in format string

            movzx r8, byte [rsi + 1]
                                        ; get next symbol after '%'

            cmp r8, '%'
            jne .nodblpercent           ; '%%' case

            mov byte [PrintBuf + r13], '%'
            inc r13                     ; store one '%' in buffer
            jmp .fin                    ; and jump to return

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
            mov rdx, 2                  ; store two symbols in buffer
            call WriteInBuf             ; '%' and next after it 

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
;        R12 -> current argument in stack
;        R13 -> counter of symbols in buffer
;
; Exit:  R12 -> next arg (+8)
;        R13 = R13 + number of printed symbols
;
; Destr: RSI, RAX, RDX, RBX, R15, RDI 
;------------------------------------------------

PrintArgNum:
            lea rsi, [PrintBuf + r13]   ; write in PrintBuf
            mov rbx, [r12]              ; get argument value

            cmp rcx, 10
            je .decimal                 ; jmp if  %d (rcx == 10 )

            mov rdx, 1
            shl rdx, cl                 ; counting mask for Itoa2n
            dec rdx                     ; rdx = 2^n - 1 (mask)

            call RsItoa2n               ; get string in buffer
                                        ; rsi remains its value
            jmp .skip                   ; rdi still equals 1

        .decimal:
            call RsItoa                 ; call Itoa for 10-numeric system

        .skip
            add r13, r8                 ; increment counter in buffer
            add r12, 8                  ; r12 -> next argument

            ret

;-------------------PrintArgStr------------------
;
; Descr: Writes string argument
;
; Entry: R12 -> current arguments ( address of string)
;
; Exit : R12 -> next argument (+8)
;
; Destr: RDX, RAX, RSI, RCX, RDI 
;------------------------------------------------

PrintArgStr:
            mov rsi, [r12]              ; rsi -> argument string
            
            xor rdx, rdx 
            neg rdx                     ; rdx = maximum value

            call WriteInBuf             ; store argument in buffer

            add r12, 8                  ; r12 -> next arg

            ret

;-------------------PrintArgChar-----------------
;
; Descr: Writes char argument in terminal
;
; Entry: R12 -> current argument
;        R13 - counter of symbols in buffer
;
; Exit:  R12 -> next argument (+8)
;        R13 += 1
;
; Destr: RDX
;------------------------------------------------

PrintArgChar:
            mov dl, [r12]
            mov [PrintBuf + r13], dl    ; store arg in buffer

            inc r13                     ; inc counter in buffer
            add r12, 8                  ; r12 -> next argument

            ret

;------------------WriteInBuf--------------------
;
; Descr: copies RDX bytes from RSI to PrintBuf
;
; Note: stops copying if *src == \0
;
; Entry: RDX == number of symbols to be written
;        RSI -> source 
;
; Exit : RSI = RSI + RDX (number of symbols 
;                         written in buffer)
;        R13 = number of symbols in buffer
;
; Destr: RCX, RDX, RDI 
;------------------------------------------------

WriteInBuf:
        mov rcx, rdx                    ; rcx = counter of symbols to be moved
                                        ; to buffer 
        cmp r13, BufSize
        jbe .loop                       ; flush buffer if it is full
                                        ; else skip 
        call FlushBuf                              

    .loop:
        mov dl, byte [rsi]              ; get one byte from src 

        cmp dl, 0
        je .ret                         ; stop if *src == \0

        mov byte [PrintBuf + r13], dl   ; store byte in PrintBuf 

        inc rsi                         ; iterate to next symbol

        inc r13                         ; increment counter in buffer
        cmp r13, BufSize
        jb .noflush                     ; no flush if buffer is not full

        call FlushBuf                   ; else flush buffer

    .noflush: 
        loop .loop                      ; repeat rcx times

    .ret
        ret 

;-------------------FlushBuf---------------------
;
; Descr: flushes bytes from PrintBuf to terminal
;        using 'write' 01h syscall
;
; Entry: R13 -> counter of symbols in buffer
;
; Exit : R13 == 0
;        RAX == number of symbols printed 
;
; Destr: RDI, RDX 
;------------------------------------------------

FlushBuf:
        push rsi                        ; save position in source
        push rcx                        ; being corrupted by syscall

        mov rax, WRITE                  ; 'write' syscall
        mov rdx, r13                    ; rdx = number of symbols 
        mov rdi, STDOUT                 ; to stdout 

        lea rsi, [PrintBuf]             ; from PrintBuf

        syscall                         ; call 'write'

        xor r13, r13                    ; PrintBuf is now empty

        pop rcx 
        pop rsi                         ; restore rsi and rcx values

        ret                            

;------------------------------------------------

[section .bss]

PrintBuf: resb BufSize + 64              ; buffer for RsPrint

__SECT__

;================================================

%endif