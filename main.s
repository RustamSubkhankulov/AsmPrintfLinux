;================================================
;                            (c) Rustamchik, 2022
;================================================

.section text 

;====================Macro=======================

%macro      

;==================Includes======================

%include    print64.s                      
                                        ; printf function
%include    itoa64.s           
                                        ; itoa function

;%include    strlen64.s                     
                                        ; strlen function

;%include unittest64.s                  
                                        ; unit tests for 
                                        ; printf function

;==================Main=Body=====================

global _start

_start:




