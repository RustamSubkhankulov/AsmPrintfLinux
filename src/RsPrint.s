;====================MACRO=======================

;------------------MultiPush---------------------

%macro multipush 1-* 
                                        ; >= 1 args
    %rep %0                             
                                        ; %0 == number of args
        push %1                         ; push first arg
        %rotate 1                       ; now second arg is first

    %endrep 

%endmacro

;-------------------MultiPop---------------------

%macro multipop 1-* 
                                        ; >= 1 args
    %rep %0 
                                        ; %0 == number of args
        %rotate -1                      ; previous arg is current
        pop %1                          ; pop arg

    %endrep 

%endmacro

;------------------------------------------------

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

section .text

;================================================

global RsPrint
global RsPrintC:function

extern RsItoa,RsItoa2n
extern printf 

;==================FUNCTIONS=====================

;-------------------RsPrintC---------------------
;
; Descr: RsPrint shell for C ( according to 
;                             Calling Convention)
; Entry: RDI, RSI, RDX, RCX, R8, R9 - first six 
;        arguments
;        Other - in stack
;
; Exit : RAX == exit code 
;
; Destr: works according to calling convention 
;------------------------------------------------

RsPrintC:
        pop rax                         ; pop return ip from stack
        mov [RetAddr], rax              ; store it in variable 

        multipush r9, r8, rcx, rdx, rsi, rdi 
                                        ; push first 6 args

        call RsPrint

        multipop  r9, r8, rcx, rdx, rsi, rdi 
                                        ; pop args 

        ;push qword [RetAddr]            ; push return addr
        
        xor rax, rax                    ; number of float parameters 
        call printf 

        push qword [RetAddr]            ; push return addr

        ret

;-------------------RsPrint----------------------
;
; Descr: Prints string in terminal
; Entry: Gains arguments in stack (CDECL)
;        First arg  - format string
;        Next  args - arguments for format string
; Exit : None
;
; Desrt: R8, RAX, RCX, R11, RDX, RSI, RDI, R9, R10
;
; Saves: RBX
;-------------------------------------------------

RsPrint:
            push rbp
            mov rbp, rsp                ; make stack frame

            push rbx                    ; save rbx 

            mov rsi, [rbp + 16]         ; rbp -> start of format string
            lea r10, [rbp + 24]         ; r10 -> first argument

            xor rdx, rdx                ; counter of symbols
            xor r9, r9                  ; counter in PrintBuf

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
            cmp r9, 0                   ; is buffer empty
            je .ret                     ; jmp to ret if it is 

            call FlushBuf               ; final flush of buffer 
                                        ; if it is not empty
        .ret:
            pop rbx                     ; restore rbx value 
            pop rbp                     ; restore rbp value
            ret

;-------------------PrintArg----------------------
;
; Descr: Prints in terminal argument in the way
;        according to specifier
;
; Entry: RSI + RDX -> %
;        r10 -> next arg to be printed
;        RAX == 1 (write)
;        RDI == 1 (stdout)
;
; Exit : RDX == 0
;        RSI -> next symb after specifier
;        r10 -> next argument in stack (+8)
;        R9 == number of symbols in buffer
;
; Destr: R8, RAX, RBX, RCX, R11, RDI
;------------------------------------------------

PrintArg:
            push rsi                    ; save current pos in format string

            movzx r8, byte [rsi + 1]
                                        ; get next symbol after '%'

            cmp r8, '%'
            jne .nodblpercent           ; '%%' case

            mov byte [PrintBuf + r9], '%'
            inc r9                      ; store one '%' in buffer
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
;        r10 -> current argument in stack
;        R9  -> counter of symbols in buffer
;
; Exit:  r10 -> next arg (+8)
;        R9  = R9 + number of printed symbols
;
; Destr: RSI, RAX, RDX, RBX, r11, RDI 
;------------------------------------------------

PrintArgNum:
            lea rsi, [PrintBuf + r9]    ; write in PrintBuf
            mov rbx, [r10]              ; get argument value

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

        .skip:
            add r9, r8                  ; increment counter in buffer
            add r10, 8                  ; r10 -> next argument

            ret

;-------------------PrintArgStr------------------
;
; Descr: Writes string argument
;
; Entry: r10 -> current arguments ( address of string)
;
; Exit : r10 -> next argument (+8)
;
; Destr: RDX, RAX, RSI, RCX, RDI 
;------------------------------------------------

PrintArgStr:
            mov rsi, [r10]              ; rsi -> argument string
            
            xor rdx, rdx 
            neg rdx                     ; rdx = maximum value

            call WriteInBuf             ; store argument in buffer

            add r10, 8                  ; r10 -> next arg

            ret

;-------------------PrintArgChar-----------------
;
; Descr: Writes char argument in terminal
;
; Entry: r10 -> current argument
;        R9 - counter of symbols in buffer
;
; Exit:  r10 -> next argument (+8)
;        R9 += 1
;
; Destr: RDX
;------------------------------------------------

PrintArgChar:
            mov dl, [r10]
            mov [PrintBuf + r9], dl     ; store arg in buffer

            inc r9                     ; inc counter in buffer
            add r10, 8                  ; r10 -> next argument

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
;        R9  = number of symbols in buffer
;
; Destr: RCX, RDX, RDI 
;------------------------------------------------

WriteInBuf:
        mov rcx, rdx                    ; rcx = counter of symbols to be moved
                                        ; to buffer 
        cmp r9, BufSize
        jbe .loop                       ; flush buffer if it is full
                                        ; else skip 
        call FlushBuf                              

    .loop:
        mov dl, byte [rsi]              ; get one byte from src 

        cmp dl, 0
        je .ret                         ; stop if *src == \0

        mov byte [PrintBuf + r9], dl    ; store byte in PrintBuf 

        inc rsi                         ; iterate to next symbol

        inc r9                          ; increment counter in buffer
        cmp r9, BufSize
        jb .noflush                     ; no flush if buffer is not full

        call FlushBuf                   ; else flush buffer

    .noflush: 
        loop .loop                      ; repeat rcx times

    .ret:
        ret 

;-------------------FlushBuf---------------------
;
; Descr: flushes bytes from PrintBuf to terminal
;        using 'write' 01h syscall
;
; Entry: R9 -> counter of symbols in buffer
;
; Exit : R9 == 0
;        RAX == number of symbols printed 
;
; Destr: RDI, RDX 
;------------------------------------------------

FlushBuf:
        push rsi                        ; save position in source
        push rcx                        ; being corrupted by syscall

        mov rax, WRITE                  ; 'write' syscall
        mov rdx, r9                     ; rdx = number of symbols 
        mov rdi, STDOUT                 ; to stdout 

        lea rsi, [PrintBuf]             ; from PrintBuf

        syscall                         ; call 'write'

        xor r9, r9                      ; PrintBuf is now empty

        pop rcx 
        pop rsi                         ; restore rsi and rcx values

        ret                            

;------------------------------------------------

[section .bss]

RetAddr:  resq 1                        ; Return Address for RsPrintC  

PrintBuf: resb RealBufSize              ; buffer for RsPrint

__SECT__

;================================================

%endif