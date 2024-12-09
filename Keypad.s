#include <xc.inc>
extrn	Forward, Backward, Left, Right, Stop
global  Keypad_Setup, Keypad_Read

psect	udata_acs	    ; reserve data space in access ram
Keypad_counter:	ds  1	    ; reserve 1 byte for variable UART_counter
Keypad_Value:	ds  1	    ; Reserve 1 byte for keypad value
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Keypad Input Pins:								;
;	Rows:RJ7, RJ6, RJ4, RB5,						;
;	Columns: RB4, RJ2, RJ3, RJ0						;
; Read the Keypad Input:							;
;	Forward = '2', Backward = '8', Left = '4', Right = '6'			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
psect	Keypad_code,class=CODE
Keypad_Setup:
    ; Select the proper bank where INTCON2 and PORTG reside
    banksel	INTCON2
    bcf		RBPU				; Clear RBPU to enable PORTB internal pull-ups

    banksel	PORTG
    bcf		RJPU				; Clear RJPU to enable PORTJ internal pull-ups

    clrf	LATJ, A         
    bcf		LATB, 5, A			; Setup PortB 5 as output
    bcf		LATB, 4, A			; Setup PortB 4 as output 
    return
    
Keypad_Read:
    clrf	Keypad_Value, A
    movlw	11111111B
    movwf	Keypad_Value, A
    call	Keypad_Setup_Row
    call	Keypad_Read_Row
    call	Keypad_Setup_Col
    call	Keypad_Read_Col
    bra		Keypad_Compare_2
    return
    
    
Keypad_Setup_Col:		; 0x0F 
    bcf TRISJ, 7, A		; RJ7 as output
    bcf TRISJ, 6, A		; RJ6 as output
    bcf	TRISJ, 4, A		; RJ4 as output
    bcf TRISB, 5, A		; RB5 as output
    bsf TRISB, 4, A		; RB4 as input
    bsf TRISJ, 2, A		; RJ2 as input
    bsf TRISJ, 3, A		; RJ3 as input
    bsf	TRISJ, 0, A		; RJ0 as input
    call	Keypad_Delay	; wait 10ms for Keypad output pins voltage to settle
    return
    
Keypad_Setup_Row:		;0xF0
    bsf TRISJ, 7, A		; RJ7 as input
    bsf TRISJ, 6, A		; RJ6 as input
    bsf	TRISJ, 4, A		; RJ4 as input
    bsf TRISB, 5, A		; RB5 as input
    bcf TRISB, 4, A		; RB4 as output
    bcf TRISJ, 2, A		; RJ2 as output
    bcf TRISJ, 3, A		; RJ3 as output
    bcf	TRISJ, 0, A		; RJ0 as output
    call	Keypad_Delay	; wait 10ms for Keypad output pins voltage to settle
    return
    
Keypad_Read_Row:
    btfss PORTJ, 7, A          ;
    bcf Keypad_Value, 0, A     ; Set bit 0 if is high

    btfss PORTJ, 6, A          ; Check 
    bcf Keypad_Value, 1, A     ; Set bit 1 if is high

    btfss PORTJ, 4, A          ; Check RJ4
    bcf Keypad_Value, 2, A     ; Set bit 2 if RJ4 is high

    btfss PORTB, 5, A          ; Check RB5
    bcf Keypad_Value, 3, A     ; Set bit 3 if RB5 is high
    return

Keypad_Read_Col:
    btfss PORTB, 4, A          ; Check RB4
    bcf Keypad_Value, 4, A     ; Set bit 4 if RB4 is high

    btfss PORTJ, 2, A          ; Check RJ2
    bcf Keypad_Value, 5, A     ; Set bit 5 if RJ2 is high

    btfss PORTJ, 3, A          ; Check RJ3
    bcf Keypad_Value, 6, A     ; Set bit 6 if RJ3 is high
    
    btfss PORTJ, 0, A          ; Check RJ0
    bcf Keypad_Value, 7, A     ; Set bit 7 if RJ0 is high
    return
  

Keypad_Compare_2:
	movlw	11101011B		;2: 1110 1011
	cpfseq	Keypad_Value, A
	bra	Keypad_Compare_4
	;retlw	'2'
	call	Forward
	return

Keypad_Compare_4:
	movlw	11010111B		;4: 1101 0111
	cpfseq	Keypad_Value, A
	bra	Keypad_Compare_6
	;retlw	'4'
	call	Left
	return

Keypad_Compare_6:
	movlw	11011101B		;6: 1101 1101
	cpfseq	Keypad_Value, A
	bra	Keypad_Compare_8
	;retlw	'6'
	call	Right
	return

Keypad_Compare_8:
	movlw	10111011B		;8: 1011 1011
	cpfseq	Keypad_Value, A
	bra	Keypad_Compare_error
	;retlw	'8'
	call	Backward
	return

Keypad_Compare_error:
	call	Stop
	return
	
Keypad_Delay:	    ; Message stored at FSR2, length stored in W
    movlw   10
    movwf   Keypad_counter, A
Keypad_Delay_Loop:
    decfsz  Keypad_counter, A
    bra	    Keypad_Delay_Loop
    return

