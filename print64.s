%ifndef print64

;================================================
;================================================

%define print64 

section .text 

;===================Print64======================
;
; Descr:
; Entry:
; Exit:
; Desrt:
;================================================

Print64

            ret 

;==================PrintArg64====================
;
; Descr:
; Entry:
; Exit:
; Destr:
;================================================

Print64Arg

            ret 

;================================================

section .bss  

Print64ItoaBuf: resb 16                 ; buffer used for itoa

;================================================
;================================================

%endif








































; section .text

; global _start                           ; making _start global name

; ;===================MAIN=BODY====================

; ; Unit tests for printf

; _start:     call CharUnitTest
;             call StringUnitTest
;             call DigitUnitTest
;             call OctUnitTest
;             call HexUnitTest
;             call BinUnitTest
;             call ComplUnitTest

;             mov rax, 0x3C      ; exit64 (rdi)
;             xor rdi, rdi
;             syscall

; ;===================MACRO========================

; %macro      .PAUSE 0            
;                             ; getchar();
; 		    nop
; 		    xor rax, rax    ; read

; 		    mov rdi, 0      ; stdin - first arg
;             mov rsi, PauseBuf
;                             ; char* buf - second arg
;             mov rdx, 1      ; read one byte

;             syscall         ; call read         
            
; 		    nop
; %endmacro

; ;------------------------------------------------

; section .data 

; PauseBuf:   db 1

; ;==================INCLUDES======================

; ;include W:\PRINTF\PRINTF.ASM

; ;====================PRINTF======================

; ; 'Printf' assembler function made for DOSbox
; ;
; ; File consists unit tests for functions
; ; Includes STRLIB library 

; ; %s - '$'-terminated string
; ; %c - symbol
; ; %d - decimal
; ; %x - hexidecimal
; ; %o - octagonal
; ; %b - binary

; ;==================INCLUDES======================

; ;include W:\PRINTF\STRLIB\STRLIB.ASM

; ;================PRINTF=FUNC=====================
; ;
; ; Descr: Prints string in command line
; ; Entry: DS == ES == segment, where string 
; ;        is stored
; ;        First arg - format string terminated 
; ;                    with '$'
; ;        Next args - arguments of format string
; ; Exit:
; ; Destr: SI, BX, DL, 
; ;
; ; Note: calling convention - cdecl
; ;==================================================================================================

; section .text

; Printf  
;         mov rax, 01h                    ; write 
;         mov rdx, 01h                    ; 1 symbol

;         push rbp                         ; prologue
;         mov  rbp, rsp

;         mov si, [bp + 4]                ; getting address
;                                         ; of the string
;         lea bx, [bp + 6]                ; bx -> first arg after
;                                         ; format string            

;     PrintfLoop:
;         mov dl, [si]                    ; Dl - to be printed
;         mov [Symbbuf], dl               ; save to local var
;         inc si                          ; move to next symb

;         cmp dl, '%'                     ; if there argument
;         jne PrintSymb

;         call PrintArg                   ; print arg according to specifier
;         jmp  Print$Check

;     PrintSymb:
;         push rsi
;         push rdi 

;         mov rsi, Symbbuf                ; rsi -> SymbBuf
;         mov rdi, 1                      ; stdout 
;         syscall

;         pop rdi 
;         pop rsi

;     Print$Check:
;         cmp byte ptr [si], '$'
;         jne PrintfLoop                  ; repeat while si != 
;                                         ; terminating symbol
;         pop rbp                          ; epilogue
;         ret 

; section .data 

; Symbbuf:    db 0                        ; buffer for symbol to be printed

; ;-------------------PrintArg---------------------
; ;
; ; Descr: Function, used in printf to write 
; ;        correctly interpritated argument
; ; Entry: SI -> next symb after %
; ;        BX -> current argument in stack
; ; Exit:  None
; ; Destr: DX, DI, CL?, SI++, BX += 2; 
; ;------------------------------------------------

; PrintArg   
;             ;c   s   d   x   o   b 
;             ;63h 73h 64h 78h 6Fh 62h
;             ; a = 61h

;             ;offset
;             ; b  c  d  o   s   x  
;             ; 1d 2d 3d 14d 18d 23d

;             mov dl, [si]                ; load next symb

;             cmp dl, '%'
;             je DisplayCurSymb           ; %% specifier

;             sub dl, 'a' + 1             ; code -> offset from 'a'

;                                         ; jmp to default
;                                         ; if
;             cmp dl, 22                  ; value is out
;             ja PrintDefault             ; of range

;             xor dh, dh
;             mov di, dx                  ; di == dl
;             shl di, 1                   ; di *= 2

;             lea di, JumpTable[di]
;             jmp [di]                    ; jump to particlar 
;                                         ; option from table

;             align 2                     ; alignment

;         JumpTable:
;             dw PrintBin                 ;1
;             dw PrintChar                ;2
;             dw PrintDec                 ;3
;             dw PrintDefault             ;4
;             dw PrintDefault             ;5
;             dw PrintDefault             ;6
;             dw PrintDefault             ;7
;             dw PrintDefault             ;8
;             dw PrintDefault             ;9
;             dw PrintDefault             ;10
;             dw PrintDefault             ;11
;             dw PrintDefault             ;12
;             dw PrintDefault             ;13
;             dw PrintOct                 ;14
;             dw PrintDefault             ;15
;             dw PrintDefault             ;16
;             dw PrintDefault             ;17
;             dw PrintStr                 ;18
;             dw PrintDefault             ;19
;             dw PrintDefault             ;20
;             dw PrintDefault             ;21
;             dw PrintDefault             ;22
;             dw PrintHex                 ;23

;         PrintBin:
;             mov cl, 1
;             jmp Print2n

;         PrintOct:
;             mov cl, 3
;             jmp Print2n

;         PrintHex:
;             mov cl, 4

;         Print2n:
;             call Print2nArg
;             jmp PrintRet

;         PrintChar:
;             call PrintCharArg
;             jmp PrintRet

;         PrintDec:
;             call PrintDecArg
;             jmp PrintRet

;         PrintStr:
;             call PrintStrArg
;             jmp PrintRet

;         PrintDefault:
;             mov [SymbBuf], '%'

;             push rdi 
;             push rsi 
;             push rdx 

;             mov rdi, 1                  ; to stdout
;             mov rsi, SymbBuf            ; from src 
;             mov rdx, 1                  ; print 1 symbol

;             syscall                     ; write

;             pop rdx
;             pop rsi
;             pop rdi 

;             mov dl, [si]                ; get current symbol 

;         DisplayCurSymb:
;             mov [SymbBuf], dl
;             int 21h                     ; display char from dl

;         PrintRet:
;             inc si                      ; iterate to next symb
;             ret

; ;-----------------PrintCharArg-------------------
; ;
; ; Descr: Displays char argument from stack
; ; Entry: BX - current argument
; ;        AH = 02h
; ; Exit: None
; ; Destr: BX->next arg in stack(+2)
; ;------------------------------------------------

; PrintCharArg    
;                 push rdx                ; save rdx
;                 push rsi 
;                 push rdi 

;                 mov dx, [bx]            ; get char
;                 add bx, 2               ; iterate to next arg

;                 mov rsi, SymbBuf
;                 mov rdx, 1
;                 mov rdi, 1

;                 pop rdi 
;                 pop rsi 
;                 pop rdx 

;                 ret 

; ;-----------------PrintStrArg--------------------
; ;
; ; Descr: Displays in cmnd line string argument
; ;        Takes argument from stack
; ; Entry: BX -> current argument
; ; Exit:
; ; Destr: DI, BX -> next arg in stack(+2)
; ;------------------------------------------------

; PrintStrArg    
;                 push rax                 ; save ax value
;                 push rdx 

;                 mov dx, [bx]           ; get arg from stack
;                 add bx, 2               ; iterate to next arg

;                 mov ah, 09h
;                 int 21h                 ; display string

;                 pop rdx 
;                 pop rax                  ; restore ax value
;                 ret 

; ;-----------------PrintDecArg--------------------
; ;
; ; Descr:
; ; Entry:
; ; Exit:
; ; DEstr: BX->next arg in stack(+2), CX, DI, DX
; ;------------------------------------------------

; PrintDecArg    
;                 push rbx                ; save bx value
;                 push rsi                ; save si value

;                 mov bx, [bx]            ; get arg
;                 mov cx, 10              ; base of the numeric system
;                 mov di, ItoaBuf         ; where string will be stored

;                 push rax                ; save ax value
;                 call rnumtoa            ; translate number to string
;                 pop rax                 ; restore ax value

;                 mov cx, si              ; cx = number of symbols in string
;                 call DisplayStr         ; Display string  

;                 pop rsi                 ; restore si value
;                 pop rbx 
;                 add bx, 2               ; restore bx value
;                                         ; and iterate to next arg
;                 ret

; ;-----------------Print2nArg--------------------
; ;
; ; Descr: Prints arguments in numerci system 
; ;        with base = 2^n
; ; Entry: CL = n; 
; ; Exit:  None
; ; Destr: BX -> next arg in stack(+2); DI, AX
; ;------------------------------------------------

; Print2nArg      
;                 xor ch, ch
;                 push rax                 ; save ax value

;                 mov dx, 1               ;
;                 shl dx, cl              ; dx = 2^n
;                 dec dx                  ; dx == mask == 2^n - 1

;                 mov ax, [bx]            ; get argument from stack
;                 add bx, 2               ; iterate to next argument

;                 mov di, ItoaBuf         ; where string will be stored

;                 push rsi                 ; save si value
;                 call rnumtoa2           

;                 mov cx, si              ; cx = number of symbols in string
;                 pop rsi                  ; restore si value

;                 call DisplayStr         ; display string in cmnd line
;                 pop rax                  ; restore ax value

;                 ret 

; ;--------------------DisplayStr------------------
; ;
; ; Descr: prints string in command line
; ; Entry: DI - start of the string
; ;        CX - lenght of the string
; ; Exit:  None
; ; Destr: DX, DI
; ;------------------------------------------------

; DisplayStr      
;                 mov dx, di              ; dx -> start of string
;                 add di, cx              ; di -> end of the string

;                 mov byte ptr [di], '$'  ; add terminatin '$'

;                 push rax 

;                 mov ah, 09h     
;                 int 21h                 ; 'display text'

;                 pop rax                  ; save and restore ax value

;                 ret   

; ;------------------------------------------------
; section .data 

; ItoaBuf     times 16 + 1 db (1)

; ;==============UNIT=TEST=FUNCTIONS=================================================================

; ;----------------CharUnitTest--------------------
; ;
; ; Descr: Test '%c' in printf
; ;
; ; Entry: None
; ; Exit:  None
; ; Destr: same as printf
; ;------------------------------------------------

; section .text 

; CharUnitTest    
;                 mov ax, 'J'
;                 push rax
;                 mov ax, TestChar
;                 push rax
            
;                 call Printf
;                 .PAUSE

;                 add sp, 16

;                 ret

; section .data

; TestChar        db "(Test %%c) This char - %c - printed by printf", 0Ah, 24h

; ;----------------StringUnitTest-------------------
; ;
; ; Descr: Test '%s' in printf
; ;
; ; Entry: None
; ; Exit:  None
; ; Destr: same as printf
; ;------------------------------------------------

; StringUnitTest  
;                 mov ax, Voiceline
;                 push rax
;                 mov ax, TestString
;                 push rax

;                 call printf
;                 .PAUSE

;                 add sp, 16

;                 ret

; section .data 

; TestString      db "(Test %%s) Saymon says: %s", 0Ah, 24h
; Voiceline       db "Hello world!$"

; ;----------------DigitUnitTest-------------------
; ;
; ; Descr: Test '%d' in printf
; ;
; ; Entry: None
; ; Exit:  None
; ; Destr: same as printf
; ;------------------------------------------------

; section .text 

; DigitUnitTest   
;                 mov ax, 6
;                 push rax 
;                 mov ax, TestDigit
;                 push rax

;                 call printf
;                 .PAUSE

;                 add sp, 16

;                 ret

; section .data 

; TestDigit       db "(Test %%d) 2 multiply by 3 is %d", 0Ah, 24h

; ;------------------HexUnitTest-------------------
; ;
; ; Descr: Test '%x' in printf
; ;
; ; Entry: None
; ; Exit:  None
; ; Destr: same as printf
; ;------------------------------------------------

; section .text 

; HexUnitTest     
;                 mov ax, 31 
;                 push rax
;                 mov ax, TestHex
;                 push rax

;                 call printf 
;                 .PAUSE

;                 add sp, 16

;                 ret 

; section .data 

; TestHex         db "(Test %%x) 31 in hex is %x", 0Ah, 24h

; ;------------------OctUnitTest-------------------
; ;
; ; Descr: Test '%o' in printf
; ;
; ; Entry: None
; ; Exit:  None
; ; Destr: same as printf
; ;------------------------------------------------

; section .text 

; OctUnitTest     
;                 mov ax, 31 
;                 push rax
;                 mov ax, TestOct
;                 push rax

;                 call Printf
;                 .PAUSE

;                 add sp, 16

;                 ret

; section .data 

; TestOct         db "(Test %%0) 31 in oct is %o", 0Ah, 24h

; ;------------------BinUnitTest-------------------
; ;
; ; Descr: Test '%b' in printf
; ;
; ; Entry: None
; ; Exit:  None
; ; Destr: same as printf
; ;------------------------------------------------

; section .text 

; BinUnitTest     
;                 mov ax, 31
;                 push rax
;                 mov ax, TestBin
;                 push rax 

;                 call printf 
;                 .PAUSE

;                 add sp, 16

;                 ret 

; section .data 

; TestBin         db "(Test %%b) 31 in binary is %b", 0Ah, 24h

; ;-----------------ComplUnitTest------------------
; ;
; ; Descr: tests several specifiers in printf
; ;
; ; Entry: None
; ; Exit:  None
; ; Destr: same as printf
; ;------------------------------------------------

; section .text 

; ComplUnitTest   
;                 mov ax, 18
;                 push rax
;                 push rax
;                 mov ax, My_name
;                 push rax 
;                 mov ax, '!'
;                 push rax 
;                 mov ax, TestTest
;                 push rax 

;                 call printf
;                 .PAUSE

;                 add sp, 40

;                 ret 

; section .data  

; TestTest        db "(Test various %%) Hello%c, my %1 name is %s, my %age is %d, in hex it is %x", 0Ah, 24h
; My_name         db "Rustam$"

; ;==================================================================================================

; ;--------------------RNUMTOA---------------------
; ;
; ; Description: Translates number into string
; ; Entry:       ES - points to the segment, where
; ;                   string will be stored
; ;              DI - points to the address of the
; ;                   first symbol in string
; ;              BX - number to be translated
; ;              CX - base of the numeric system 
; ; Exit:        DI remains it value
; ;              SI - number of symbols in string
; ; Destr:       BX, AX, DX
; ;------------------------------------------------

; section .text 

; rnumtoa     
;             mov ax, bx   
;             mov si, 1           ; start value of counter       

;         rnumtoaCount:           ; counting offset
;             xor dx, dx
;             div cx

;             cmp ax, 0
;             je rnumtoaMain
;             inc di              ; iterate to next symb
;             inc si              ; increments counter
;             jmp rnumtoaCount

;         rnumtoaMain:
;             mov ax, bx

;         rnumtoaLoop:
;             xor dx, dx          ; for 'div' command
;             div cx

;             mov bx, dx          ; converting remainder to symbol
;             mov dl, [bx + RSYMB_TABLE]   
;                                    ; prints number from end
;             mov es:[di], dl     
;             dec di              ; iterate to next symbol

;             cmp ax, 0
;             jne rnumtoaLoop

;             inc di              ; si points to the start of string
;             ret

; section .data 

; RSYMB_TABLE db '0123456789ABCDEF'

; ;-----------------RNUMTOA2-----------------------
; ;
; ; Description: optimized version of 'rnumtoa'
; ;              function, used for numeric systems
; ;              with base 2^n, n = 1, 2, 3 or 4
; ; Entry:       ES - points to the segment, where
; ;                   string will be stored
; ;              DI - points to the first symbol 
; ;                   in this string
; ;              AX - number to be translated
; ;              CL - n
; ;              DX - mask
; ; Exit:        DI - remains it value
; ;              SI - number of charasters in string
; ; Destr:       AX, SI, BX
; ;------------------------------------------------

; section .text 

; rnumtoa2    
;             mov bx, ax
;             mov si, 1           ; start value of symb counter

;         rnumtoa2Count:          ; count shift in string
;             shr bx, cl
;             cmp bx, 0
;             je  rnumtoa2Loop    ; stop if bx == 0 

;             inc di              ; move si to next symbol
;             inc si              ; incfrement additional counter
;             jmp rnumtoa2Count   ; repeat while bx != 0

;         rnumtoa2Loop:           ; main cycle
;             mov bx, ax 
;             and bx, dx          ; using mask

;             mov bl, [bx + XlatTable]           
;             mov es:[di], bl     ; store translated code of the symbol
;             dec di              ; move to next symbol in string

;             shr ax, cl          ; ax := 2^base
;             cmp ax, 0           

;             jne rnumtoa2Loop    ; repeat while si != 0

;             inc di              ; di points to the start
;             ret

; section .data 

; XlatTable db '0123456789ABCDEF' ; translation table