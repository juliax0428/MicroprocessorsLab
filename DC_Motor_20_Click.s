#include <xc.inc>
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;mikrobus1:
;RA0=input_1, RD2=Input_2, RG3=input_3, RB3=Input_4			;
;Motor driver = TC78H651AFNG						;
;mikrobus2:
;RA1=input_1, RD0=Input_2, RG0=input_3, RB2=Input_4			;
;Motor driver = TC78H651AFNG						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

extrn  delay
   
global Forward, Backward, Right, Left, Stop, motor_setup, motor_test

    
psect	udata_acs   ; reserve data space in access ram

psect	motors_code, class=CODE

motor_setup:
    clrf LATA, A         ; Clear LAT registers
    clrf LATD, A
    clrf LATG, A
    clrf LATB, A
    bcf TRISA, 1, A      ; Set RA1 as output 1
    bcf TRISD, 0, A      ; Set RD2 as output 2
    bcf TRISG, 0, A      ; Set RG3 as output 3
    bcf TRISB, 2, A      ; Set RB3 as output 4
    return
    
Forward:
    bsf PORTA, 1, A      ; Set RA1 as High
    bcf PORTD, 0, A      ; Set RD0 as Low
    bsf PORTG, 0, A      ; Set RG0 as High
    bcf PORTB, 2, A      ; Set RB2 as Low
    ;call Delay			; Delay for specified time
    return

Backward:
    bcf PORTA, 1, A      ; Set RA0 as Low
    bsf PORTD, 0, A      ; Set RD2 as High
    bcf PORTG, 0, A      ; Set RG3 as Low
    bsf PORTB, 2, A      ; Set RB3 as High
    ;call Delay			; Delay for specified time
    return

Right:
    bsf PORTA, 1, A      ; Set RA0 as High
    bcf PORTD, 0, A      ; Set RD2 as Low
    bcf PORTG, 0, A      ; Set RG3 as Low
    bsf PORTB, 2, A      ; Set RB3 as High
    ;call Delay			; Delay for specified time
    return

Left:
    bcf PORTA, 1, A      ; Set RA0 as Low
    bsf PORTD, 0, A      ; Set RD2 as High
    bsf PORTG, 0, A      ; Set RG3 as High
    bcf PORTB, 2, A      ; Set RB3 as Low
    ;call Delay			; Delay for specified time
    return

Stop:
    bcf PORTA, 1, A      ; Set all as Low
    bcf PORTD, 0, A
    bcf PORTG, 0, A
    bcf PORTB, 2, A 
    ;call Delay			; Delay for specified time
    return

; Delay Subroutine (approximately 1 ms delay per call)
;Delay:  
;    MOVLW   0xFF		    ; Load WREG with delay count (adjust as needed)
;    MOVWF   motor_counter, A        
;Delay_Loop:
;    decfsz  motor_counter, F, A             ; Decrement delay counter
;    goto    Delay_Loop			    ; Repeat until counter reaches zero
;    return				    ; Return from delay

    

motor_test:
    ; Execute motion sequences
    call Forward
    call delay
    call Stop
    call delay
    call Backward
    call delay
    call Stop
    call delay
    call Left
    call delay
    call Stop
    call delay
    call Right
    call delay
    call Stop
    call delay
    GOTO motor_test    ; Repeat forever

END 
