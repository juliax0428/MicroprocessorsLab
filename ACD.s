#include <xc.inc>

global  ADC_Setup, ADC_Read    
    
psect	adc_code, class=CODE
    
ADC_Setup:
	bsf	TRISA, PORTA_RA0_POSN, A  ; pin RA0==AN0 input
	movlb	0x0f
	;banksel   ANCON0
	bsf	ANSEL0	    ; set AN0 to analog
	movlb	0x00
	movlw   0x01	    ; select AN0 for measurement
	movwf   ADCON0, A   ; and turn ADC on
	movlw   0x30	    ; Select 4.096V positive reference
	movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
	movlw   0xF6	    ; Right justified output
	movwf   ADCON2, A   ; Fosc/64 clock and acquisition times
	return

ADC_Read:
	bsf	GO	    ; Start conversion by setting GO bit in ADCON0
adc_loop:
	btfsc   GO	    ; check to see if finished
	bra	adc_loop
	return
ADC_16x16_unsigned:
	MOVF	ARG1L, W
	MULWF	ARG2L	    ; ARG1L*ARG2L -- PRODH:PRODL
	MOVFF	PRODH, RES1
	MOVFF	PRODL, RES0
	
	MOVF	ARG1H,W
	MULWF	ARG2H	    ; ARG1L*ARG2H -- PRODH:PRODL
	MOVF	PRODH, RES3
	MOVFF	PRODL, RES2
	
	MOVF	ARG1L, W
	MULWF	ARG2H
	MOVF	PRODL, W
	ADDWF	RES1, F	    ; ADD cross product
	MOVF	PRODH, W
	ADDWFC	RES2, F
	CLRF	WREG
	ADDWFC	RES3, F
	
	MOVF	ARG1H, W
	MULWF	ARG2L	    ; ARG1H*ARG2L -- PRODH:PRODL
	MOVF	PRODL, W
	ADDWF	RES1, F	    ; Add Cross Product
	MOVF	PRODH, W
	ADDWFC	RES2, F
	CLRF	WREG
	ADDWFC	RES3, F

ADC_8x24:
	MOVF	ARG1, W
	MULWF	ARG2L
	MOVF	PRODL, RES0
	MOVF	PRODH, RES1
	
	MOVF	ARG1, W
	MULWF	ARG2M
	MOVF	PRODL, RES1
	MOVF	PRODH, RES2
	
	MOVF	ARG1, W
	MULWF	ARG2H
	MOVF	PRODL, RES2
	MOVF	PRODH, RES3
	
ADC_hex2dec:
	CLRF    RES1        ; Clear the low byte of the result
	CLRF    RES2        ; Clear the high byte of the result
	CLRF    REMAINDER   
	
	MOVF    ARG1, W     ; Load lower byte of hex number
	MOVWF   REMAINDER   ; Store it as the initial remainder

    ; First multiplication step: Multiply by k = 0x418A
	MOVLW   0x8A       ; Load the lower byte of k (0x418A)
	MOVWF   ARG2L
	MOVLW   0x41        ; Load the upper byte of k (0x418A)
	MOVWF   ARG2H

	CALL    ADC_16x16_unsigned ; Call the 16x16 multiplication function
	MOVF    RES3, W     ; Take the most significant byte
	MOVWF   MSB        ; Store it in MSB register
	
	MOVLW   0x03
	MOVWF   Counter  ; Store loop counter
	
ADC_Mult_Loop:
	MOVLW   0x0A        ; Load 0x0A for the next multiplication
	MOVWF   ARG1

	MOVF    RES0, W        ; Get the lower byte of the result
	MOVWF   ARG2L      ; Store it as the new remainder
	MOVF    RES1, W        ; Get the middle byte
	MOVWF   ARG2M    ; Store it in the next byte of REMAINDER
	MOVF    RES2, W        ; Get the most significant byte
	MOVWF   ARG2H    ; Store it in the last byte of REMAINDER
	
	CALL    ADC_8x24    ; Call the 8x24 multiplication function
	
	MOVF    RES3, W     ; Take the most significant byte
	MOVWF   MSB
	
	DECFSZ  Counter, F  ; Decrement the loop counter, if it's zero, exit loop
	GOTO    ADC_Mult_Loop      ; Repeat the multiplication step

	return

end