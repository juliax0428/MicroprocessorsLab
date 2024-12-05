#include <xc.inc>
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RA0=input_1, RD2=Input_2, RG3=input_3, RB4=Input_4			;
; Motor driver = TC78H651AFNG						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
global Forward, Backward, Right, Left, Stop, motor_setup, motor_test

psect	udata_acs

;psect	data
;R_Input1  EQU 1    ; RC1 -> Right Motor Input 1
;R_Input2  EQU 2    ; RC2 -> Right Motor Input 2
;L_Input1  EQU 3    ; RC3 -> Left Motor Input 1
;L_Input2  EQU 4    ; RC4 -> Left Motor Input 2


psect	motors_code, class=CODE

motor_setup:
    CLRF PORTC, A        ; Clear PORTC
    bcf TRISA, 0, A      ; Set RA0 as input 1
    bcf TRISD, 2, A      ; Set RD2 as input 2
    bcf TRISG, 3, A      ; Set RG3 as input 3
    bcf TRISB, 3, A      ; Set RB3 as input 4

Forward:
    bsf TRISA, 0, A      ; Set RA0 as High
    bcf TRISD, 2, A      ; Set RD2 as Low
    bsf TRISG, 3, A      ; Set RG3 as High
    bcf TRISB, 3, A      ; Set RB3 as Low
    call Delay			; Delay for specified time
    return

Backward:
    bcf TRISA, 0, A      ; Set RA0 as Low
    bsf TRISD, 2, A      ; Set RD2 as High
    bcf TRISG, 3, A      ; Set RG3 as Low
    bsf TRISB, 3, A      ; Set RB3 as High
    call Delay			; Delay for specified time
    return

Right:
    bsf TRISA, 0, A      ; Set RA0 as High
    bcf TRISD, 2, A      ; Set RD2 as Low
    bcf TRISG, 3, A      ; Set RG3 as Low
    bsf TRISB, 3, A      ; Set RB3 as High
    call Delay			; Delay for specified time
    return

Left:
    bcf TRISA, 0, A      ; Set RA0 as Low
    bsf TRISD, 2, A      ; Set RD2 as High
    bsf TRISG, 3, A      ; Set RG3 as High
    bcf TRISB, 3, A      ; Set RB3 as Low
    call Delay			; Delay for specified time
    return

Stop:
    bcf TRISA, 0, A      ; Set all as Low
    bcf TRISD, 2, A
    bcf TRISG, 3, A
    bcf TRISB, 3, A 
    call Delay			; Delay for specified time
    return

; Delay Subroutine (approximately 1 ms delay per call)
Delay:  
    MOVLW   0xFF                ; Load WREG with delay count (adjust as needed)
    MOVWF   0x20, A                ; Store in memory (temp register 0x20)
Delay_Loop:
    decfsz  0x20, F, A             ; Decrement delay counter
    goto    Delay_Loop          ; Repeat until counter reaches zero
    return                      ; Return from delay

motor_test:
    ; Execute motion sequences
    call Forward
    call Delay
    call Stop
    call Delay
    call Backward
    call Delay
    call Stop
    call Delay
    call Left
    call Delay
    call Stop
    call Delay
    call Right
    call Delay
    call Stop
    call Delay
    GOTO motor_test    ; Repeat forever

END 
