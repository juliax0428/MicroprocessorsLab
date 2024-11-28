#include <xc.inc>

psect	udata_acs

psect	data
R_Input1  EQU 1    ; RC1 -> Right Motor Input 1
R_Input2  EQU 2    ; RC2 -> Right Motor Input 2
L_Input1  EQU 3    ; RC3 -> Left Motor Input 1
L_Input2  EQU 4    ; RC4 -> Left Motor Input 2


psect	code
; Start of code
org 0x00
goto start           ; Jump to main program start

; Subroutines
FORWARD:
    BSF PORTC, R_Input1, A     ; Set L1 HIGH
    BCF PORTC,R_Input2, A  ; Set L2 LOW
    BSF PORTC,L_Input1, A     ; Set L3 HIGH
    BCF PORTC,L_Input2, A     ; Set L4 LOW
    CALL Delay    ; Delay for specified time
    RETURN

REVERSE:
    BCF PORTC, R_Input1, A     ; Set L1 LOW
    BSF PORTC, R_Input2, A     ; Set L2 HIGH
    BCF PORTC, L_Input1, A     ; Set L3 LOW
    BSF PORTC, L_Input2, A     ; Set L4 HIGH
    CALL Delay
    RETURN

RIGHT:
    BSF PORTC, R_Input1, A     ; Set L1 HIGH
    BCF PORTC, R_Input2, A     ; Set L2 LOW
    BCF PORTC, L_Input1, A     ; Set L3 LOW
    BSF PORTC, L_Input2, A     ; Set L4 HIGH
    CALL Delay
    RETURN

LEFT:
    BCF PORTC, R_Input1, A     ; Set L1 LOW
    BSF PORTC, R_Input2, A     ; Set L2 HIGH
    BSF PORTC, L_Input1, A     ; Set L3 HIGH
    BCF PORTC, L_Input2, A     ; Set L4 LOW
    CALL Delay
    RETURN

Stop:
    BCF PORTC, R_Input1, A     ; Set all pins LOW
    BCF PORTC, R_Input2, A
    BCF PORTC, L_Input1, A
    BCF PORTC, L_Input2, A
    CALL Delay
    RETURN

; Delay Subroutine (approximately 1 ms delay per call)
Delay:  
;    MOVLW   0xFF, A                ; Load WREG with delay count (adjust as needed)
    MOVWF   0x20, A               ; Store in memory (temp register 0x20)
Delay_Loop:
    DECFSZ  0x20, F, A             ; Decrement delay counter
    GOTO    Delay_Loop          ; Repeat until counter reaches zero
    RETURN                      ; Return from delay

; Main Program
start:

    CLRF PORTC, A        ; Clear PORTC
    BSF TRISC, 0, A      ; Set RC0 as output
    BSF TRISC, 1, A      ; Set RC1 as output
    BSF TRISC, 2, A    ; Set RC2 as output
    BSF TRISC, 3, A      ; Set RC3 as output

MAIN_LOOP:
    ; Execute motion sequences
    CALL FORWARD
    call Delay
    CALL Stop
    call Delay
    CALL REVERSE
    call Delay
    CALL Stop
    call Delay
    CALL LEFT
    call Delay
    CALL Stop
    call Delay
    CALL RIGHT	
    call Delay
    CALL Stop
    call Delay
    GOTO MAIN_LOOP   ; Repeat forever

END 