#include <xc.inc>
    
global  Keypad_Setup, Keypad_Read

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
    movf	Keypad_Value_Row, W, A
    iorwf	Keypad_Value_Col, W, A
    movwf	PORTD
    bra		Keypad_Compare_1
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
	movf	PORTE, W, A	; Read PORTE to determine the logic levels on PORTE 0-3
	movwf	Keypad_Value_Row, A
	return

Keypad_Read_Col:
	movf	PORTE, W, A	; Read PORTE to determine the logic levels on PORTE 4-7
	movwf	Keypad_Value_Col, A
	return
	
Keypad_Compare_1:
	movlw	11100111B		; 1: 1110 0111
	cpfseq	PORTD
	bra	Keypad_Compare_2
	retlw	'1'
Keypad_Compare_2:
	movlw	11101011B		;2: 1110 1011
	cpfseq	PORTD
	bra	Keypad_Compare_3
	retlw	'2'
Keypad_Compare_3:
	movlw	11101101B		;3: 1110 1101
	cpfseq	PORTD
	bra	Keypad_Compare_F
	retlw	'3'
Keypad_Compare_F:
	movlw	11101110B		;F: 1110 1110
	cpfseq	PORTD
	bra	Keypad_Compare_4
	retlw	'F'
    
Keypad_Compare_4:
	movlw	11010111B		;4: 1101 0111
	cpfseq	PORTD
	bra	Keypad_Compare_5
	retlw	'4'
Keypad_Compare_5:
	movlw	11101011B		;5: 1101 1011
	cpfseq	PORTD
	bra	Keypad_Compare_6
	retlw	'5'
Keypad_Compare_6:
	movlw	11011101B		;6: 1101 1101
	cpfseq	PORTD
	bra	Keypad_Compare_E
	retlw	'6'
Keypad_Compare_E:
	movlw	11011110B		;E: 1101 1110
	cpfseq	PORTD
	bra	Keypad_Compare_7
	retlw	'E'
    
 Keypad_Compare_7:
	movlw	10110111B		;7:
	cpfseq	PORTD
	bra	Keypad_Compare_8
	retlw	'7'
Keypad_Compare_8:
	movlw	10111011B		;8: 1011 1011
	cpfseq	PORTD
	bra	Keypad_Compare_9
	retlw	'8'
Keypad_Compare_9:
	movlw	10111101B		;9: 1011 1101
	cpfseq	PORTD
	bra	Keypad_Compare_D
	retlw	'9'
Keypad_Compare_D:
	movlw	10111110B		;D: 1011 1110
	cpfseq	PORTD
	bra	Keypad_Compare_A
	retlw	'D'

Keypad_Compare_A:
	movlw	01110111B		;A: 0111 0111
	cpfseq	PORTD
	bra	Keypad_Compare_0
	retlw	'A'
Keypad_Compare_0:
	movlw	01111011B		;0: 1110 1011
	cpfseq	PORTD
	bra	Keypad_Compare_B
	retlw	'0'
Keypad_Compare_B:
	movlw	01111101B		;B: 0111 1101
	cpfseq	PORTD
	bra	Keypad_Compare_C
	retlw	'B'
Keypad_Compare_C:
	movlw	01111110B		;F: 0111 1110
	cpfseq	PORTD
	bra	Keypad_Compare_error
	retlw	'C'

Keypad_Compare_error:
	retlw	0xff	
	
Keypad_Delay:	    ; Message stored at FSR2, length stored in W
    movlw   10
    movwf   Keypad_counter, A
Keypad_Delay_Loop:
    decfsz  Keypad_counter, A
    bra	    Keypad_Delay_Loop
    return

