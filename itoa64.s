%ifndef itoa64

;================================================
;================================================

%define itoa64 

section .text 

;===================Itoa64=======================
;
; Descr: translates number to string of symbols
;
; Exit : DI remains its value
;        R8 - number of symbols in string
;
; Entry: DI - start of the string
;        R9 - base of numeric system 
;        RBX - number to be translated
;
; Destr: RAX, RDX, 
;================================================

Itoa64 
        mov rax, rbx                    ; get value for
                                        ; counting offset
        mov r8, 1                       ; at least ine symb in string

    .CountOffset
        xor rdx, rdx                    ; rdx:rax / op64 = rax, rdx = remainder 
        div r9                          ; div by base

        cmp rax, 0                      ; cmp result with 0
        je .main                        ; if equal, jmp to main 
        inc r8                          ; increment addition counter
        int rdi                         ; move to next symbol

        jmp .CountOffset

    .main
        mov rax, rbx                    ; get value again
        mov rcx, r8                     ; get number of symbols

    .loop
        xor rdx, rdx                    ; for division
        div r9                          ; divide by base 

        mob dl, [rdx + XlatTable64]     ; converting symbol

        mov [rdi], dl                   ; place symbol in string
        dec rdi                         ; iterate to next one

        loop .loop                      ; repeat rcx times

        inc rdi                         ; di point to the start of string
        ret 

;===================Itoa64_2=====================
;
; Descr:
; Entry:
; Exit:
; Destr:
;================================================

Itoa64_2

        mov rax, rbx                    ; get value for
                                        ; counting offset
        mov r8, 1                       ; at least ine symb in string

    .CountOffset
        shr rax, r9
        cmp rax, 0
        le .loop 

        inc r8                          ; increment addition counter
        int rdi                         ; move to next symbol

        jmp .CountOffset

    .loop
        mov rbx, rax                    ; get value 
        and rbx, rdx                    ; use mask

        mov bl, [rbx + XlatTable64]     ; translate code
        mov [rdi], bl                   ; store in sting
        dec rdi                         ; iterate to next

        shr rax, r9                     ; ax /= 2^base
        cmp rax, 

        ret 

;================================================

section .data 

XlatTable64 db "0123456789ABCDEF"       ; translation table

;================================================
;================================================

%endif