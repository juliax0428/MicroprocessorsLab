#include <xc.inc>
    
global  Keypad_Setup_1, Keypad_Setup_2, Keypad_loop

psect	udata_acs   ; reserve data space in access ram
Keypad_counter: ds    1	    ; reserve 1 byte for variable UART_counter
Keypad_Value: ds 1
Keypad_Value_Row: ds  1
Keypad_Value_Col: ds  1
    
    
psect	Keypad_code,class=CODE
Keypad_Setup:
    banksel	PADCFG1
    bsf		REPU
    clrf	LATE, A		; Write 0s to the LATE
    clrf	TRISD
    return
    
Keypad_Read:
    call	Keypad_Setup_1
    call	Keypad_Read_Row
    call	Keypad_Setup_2
    call	Keypad_Read_Col
    movf	Keypad_Value_Row, W
    iorwf	Keypad_Value_Col, W
    movwf	PORTD
    return
    
    
Keypad_Setup_1:
    movlw	0x0F		;Set TRISE to 0x0F (0-3 as input, 4-7 as output)
    movwf	TRISE, A
    call	Keypad_Delay	; wait 10ms for Keypad output pins voltage to settle
    return
    
Keypad_Setup_2:
    movlw	0xF0		;Set TRISE to 0xF0 (0-3 as output, 4-7 as input)
    movwf	TRISE, A
    movlw	10
    call	Keypad_Delay	; wait 10ms for Keypad output pins voltage to settle
    return
    
Keypad_Read_Row:
	movf	PORTE, W	; Read PORTE to determine the logic levels on PORTE 0-3
	movwf	Keypad_Value_Row
	return

Keypad_Read_Col:
	movf	PORTE, W	; Read PORTE to determine the logic levels on PORTE 4-7
	movwf	Keypad_Value_Col
	return
	
Keypad_loop:
	movf	Keypad_value_Row, W, A
	
	sublw   1110
	btfsc	STATUS, Z
	bra	Keypad_Decoding_1110
	
	sublw   1101
	btfsc	STATUS, Z
	bra	Keypad_Decoding_1101
	
	sublw   1011
	btfsc	STATUS, Z
	bra	Keypad_Decoding_1011
	
	sublw   0111
	btfsc	STATUS, Z
	bra	Keypad_Decoding_0111
	
	sublw	1111
	btfsc	STATUS, Z
	retlw	0x00
	
	movlw	movlweypad_Value, A
	lfsr	3, A
	
	return
	
	
Keypad_Decoding_1110:
	movf	Keypad_Value_Col, W, A
	sublw   0111
	btfsc	STATUS, Z
	retlw	1		    ;1: 1110, 0111
	sublw   1011
	btfsc	STATUS, Z
	retlw	2		    ;2: 1110, 1011
	sublw   1101
	btfsc	STATUS, Z
	retlw	3		    ;3: 1110, 1101
	sublw   1110
	btfsc	STATUS, Z
	retlw	F		    ;F: 1110,1110
	
	return
Keypad_Decoding_1101:
	movf	Keypad_Value_Col, W, A
	sublw   0111
	btfsc	STATUS, Z
	retlw	4
	sublw   1011
	btfsc	STATUS, Z
	retlw	5
	sublw   1101
	btfsc	STATUS, Z
	retlw	6
	sublw   1110
	btfsc	STATUS, Z
	retlw	E
	
	return
	
Keypad_Decoding_1011:
	movf	Keypad_Value_Col, W, A
	sublw   0111
	btfsc	STATUS, Z
	retlw	7
	sublw   1011
	btfsc	STATUS, Z
	retlw	8
	sublw   1101
	btfsc	STATUS, Z
	retlw	9
	sublw   1110
	btfsc	STATUS, Z
	retlw	D
	
	return
	
Keypad_Decoding_0111:
	movf	Keypad_Value_Col, W, A
	sublw   0111
	btfsc	STATUS, Z
	retlw	A
	sublw   1011
	btfsc	STATUS, Z
	retlw	0
	sublw   1101
	btfsc	STATUS, Z
	retlw	B
	sublw   1110
	btfsc	STATUS, Z
	retlw	C
	
	return
 
    
    
    
    
 
Keypad_Delay:	    ; Message stored at FSR2, length stored in W
    movlw   10
    movwf   Keypad_counter, A
Keypad_Delay_Loop:
    decfsz  Keypad_counter, A
    bra	    Keypad_Delay_Loop
    return

;UART_Transmit_Byte:	    ; Transmits byte stored in W
;    btfss   TX1IF	    ; TX1IF is set when TXREG1 is empty
;    bra	    UART_Transmit_Byte
;    movwf   TXREG1, A
;    return


