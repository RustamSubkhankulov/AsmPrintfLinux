%ifndef rsItoa
%define rsItoa 

;================================================

section .text 

;==================FUNCTIONS=====================

;-------------------MyItoa-------------------------
;
; Descr: translates number to string of symbols
;
; Exit : RSI remains its value
;        R8 - number of symbols in string
;
; Entry: RSI - start of the string
;        R9 - base of numeric system 
;        RBX - number to be translated
;
; Destr: RAX, RDX
;------------------------------------------------

RsItoa:
        mov rax, rbx                    ; get value for
                                        ; counting offset
        mov r8, 1                       ; at least ine symb in string

    .CountOffset:
        xor rdx, rdx                    ; rdx:rax / op64 = rax, rdx = remainder 
        div r9                          ; div by base

        cmp rax, 0                      ; cmp result with 0
        je .main                        ; if equal, jmp to main 
        inc r8                          ; increment addition counter
        inc rsi                         ; move to next symbol

        jmp .CountOffset

    .main:
        mov rax, rbx                    ; get value again
        mov rcx, r8                     ; get number of symbols

    .loop:
        xor rdx, rdx                    ; for division
        div r9                          ; divide by base 

        mov dl, [rdx + XlatTable64]     ; converting symbol

        mov [rsi], dl                   ; place symbol in string
        dec rsi                         ; iterate to next one

        loop .loop                      ; repeat rcx times

        inc rsi                         ; di point to the start of string
        ret 

;--------------------RsItoa2n--------------------
;
; Descr: optimized version of the itoa64, made for
;        numeric sytems with base - power of two
;
; Entry: RBX - number to be translated
;        RCX  - n
;        RDX - mask for division (2^n - 1)
;        RSI - start of the string
;
; Exit : RSI remains its value
;        R8 - number of symbols in string
;
; Destr: RAX, RBX
;------------------------------------------------

RsItoa2n:

        mov rax, rbx                    ; get value for
                                        ; counting offset
        mov r8, 1                       ; at least ine symb in string

    .CountOffset:
        shr rax, cl 
        cmp rax, 0
        je .loop 

        inc r8                          ; increment addition counter
        inc rsi                         ; move to next symbol

        jmp .CountOffset

    .loop:
        mov rax, rbx                    ; get value 
        and rax, rdx                    ; use mask

        mov al, [rax + XlatTable64]     ; translate code
        mov [rsi], al                   ; store in sting
        dec rsi                         ; iterate to next

        shr rbx, cl                   ; ax /= 2^base

        cmp rbx, 0                      
        jne .loop                       ; while (rax != 0)

        inc rsi                         ; rdi -> start of the string
        ret 

;------------------------------------------------

section .data 

XlatTable64 db "0123456789ABCDEF"       ; translation table

;================================================

%endif