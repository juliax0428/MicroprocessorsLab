#include <xc.inc>

global  ADC_Setup, ADC_Read,ADC_hex2dec
    
psect	udata_acs   ; reserve data space in access ram
ARG1L: ds    1	    ; reserve 1 byte for ARG1 Low
ARG1H: ds    1      ; reserve 1 byte for ARG1 High
ARG1:  ds    1
ARG2L: ds    1
ARG2M: ds    1
ARG2H: ds    1
RES0:  ds    1
RES1:  ds    1
RES2:  ds    1
RES3:  ds    1
MSB:   ds    1	    ; Researve 1 byte for Most Significant Byte
Counter: ds  1	    ; Researve 1 byte for counter

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
	MOVF	ARG1L, W, A
	MULWF	ARG2L, A	    ; ARG1L*ARG2L -- PRODH:PRODL
	MOVFF	PRODH, RES1
	MOVFF	PRODL, RES0
	
	MOVF	ARG1H,W, A
	MULWF	ARG2H, A    ; ARG1L*ARG2H -- PRODH:PRODL
	MOVFF	PRODH, RES3
	MOVFF	PRODL, RES2
	
	MOVF	ARG1L, W, A
	MULWF	ARG2H, A
	MOVF	PRODL, W, A
	ADDWF	RES1, F, A	    ; ADD cross product
	MOVF	PRODH, W, A
	ADDWFC	RES2, F,A
	CLRF	WREG, A
	ADDWFC	RES3, F, A
	
	MOVF	ARG1H, W, A
	MULWF	ARG2L, A	    ; ARG1H*ARG2L -- PRODH:PRODL
	MOVF	PRODL, W, A
	ADDWF	RES1, F, A	    ; Add Cross Product
	MOVF	PRODH, W, A
	ADDWFC	RES2, F, A
	CLRF	WREG, A
	ADDWFC	RES3, F, A

ADC_8x24:
	MOVF	ARG1, W, A
	MULWF	ARG2L, A
	MOVFF	PRODL, RES0
	MOVFF	PRODH, RES1
	
	MOVF	ARG1, W, A
	MULWF	ARG2M, A
	MOVFF	PRODL, RES1
	MOVFF	PRODH, RES2
	
	MOVF	ARG1, W, A
	MULWF	ARG2H, A
	MOVFF	PRODL, RES2
	MOVFF	PRODH, RES3
	
ADC_hex2dec:
	CLRF    RES1, A        ; Clear the low byte of the result
	CLRF    RES2, A        ; Clear the high byte of the result
	CLRF    RES3, A   

    ; First multiplication step: Multiply by k = 0x418A
	MOVLW   0x8A       ; Load the lower byte of k (0x418A)
	MOVWF   ARG2L, A
	MOVLW   0x41        ; Load the upper byte of k (0x418A)
	MOVWF   ARG2H, A

	CALL    ADC_16x16_unsigned ; Call the 16x16 multiplication function
	MOVF    RES3, W, A     ; Take the most significant byte
	MOVWF   MSB, A        ; Store it in MSB register
	
	MOVLW   0x03
	MOVWF   Counter, A  ; Store loop counter
	
	call	ADC_Mult_Loop
	
ADC_Mult_Loop:
	MOVLW   0x0A        ; Load 0x0A for the next multiplication
	MOVWF   ARG1, A

	MOVF    RES0, W, A        ; Get the lower byte of the result
	MOVWF   ARG2L, A      ; Store it as the new remainder
	MOVF    RES1, W, A        ; Get the middle byte
	MOVWF   ARG2M, A    ; Store it in the next byte of REMAINDER
	MOVF    RES2, W, A        ; Get the most significant byte
	MOVWF   ARG2H, A    ; Store it in the last byte of REMAINDER
	
	CALL    ADC_8x24    ; Call the 8x24 multiplication function
	
	MOVF    RES3, W, A     ; Take the most significant byte
	MOVWF   MSB, A
	
	DECFSZ  Counter, F, A  ; Decrement the loop counter, if it's zero, exit loop
	GOTO    ADC_Mult_Loop      ; Repeat the multiplication step

	return

end