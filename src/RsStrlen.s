%ifndef rsStrlen
%define rsStrlen 

;================================================

global RsStrlen

;================================================

section .text 

;===================FUNCTIONS====================

;--------------------RsStrlen--------------------
;
; Descr:   count lenght of the null-terimanted 
;                                       string
; Entry:   RSI - address of the string
;
; Exit:    RCX - lenght of the string
;          RSI remains its value
;
; Desrt:   none
;-------------------------------------------------

RsStrlen:    
            push rsi                    ; save rsi value

            xor rcx, rcx
            neg rcx                     ; rcx == 0xFFFFFFFFFFFFFFFF
            
        .loop:
            cmp byte [rsi], 0
            je .ret                     ; if ([rdi] == 0) stop

            inc rsi                     ; iterate to next symb
            loop .loop                  ; while ([di] != 0)

        .ret: 
            neg rcx      

            pop rsi                     ; restore rsi value 

            ret 

;================================================

%endif