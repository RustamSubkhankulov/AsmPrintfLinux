%ifndef rsStrlen
%define rsStrlen 

;================================================

section .text 

;===================FUNCTIONS====================

;--------------------Strlen----------------------
;
; Descr:   count lenght of the null-terimanted 
;                                       string
; Entry:   RDI - address of the string
;
; Exit:    RCX - lenght of the string
;
; Desrt:   RDI
;-------------------------------------------------

RsStrlen    
            xor rcx, rcx
            neg rcx                     ; rcx == 0xFFFFFFFFFFFFFFFF
            
        .loop:
            cmp byte [rdi], 0
            je .ret                     ; if ([rdi] == 0) stop

            inc rdi                     ; iterate to next symb
            loop .loop                  ; while ([di] != 0)

        .ret 
            ;add rcx, 2                   ; get lenght of the string
            neg rcx      

            ret 

;================================================

%endif