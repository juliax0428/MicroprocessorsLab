	#include <xc.inc>

psect	code, abs
main:
    org	    0
    goto    setup
    
    org	    0x100
    

myTable:
    db		'a','b','c','d','e','f','g','h','i'
    db		'1','2','3','4','5','6','7','8','9'
    myArray	EQU 0x400
    counter	EQU 0x10
    num		EQU 16
    align	2

setup:
    call	SPI_MasterInit
    
start:
    movlw   low highword(myTable)
    movwf   TBLPTRU, A
    movlw   high(myTable)
    movwf   TBLPTRH, A
    movlw   low(myTable)
    movwf   TBLPTRL,A
    movlw   num
    movwf   counter, A

loop:
    call    SPI_MasterTransmit
    movff   TABLAT, POSTINC0
    decfsz  counter, A
    bra	    loop
    goto    0

SPI_MasterInit:
	bcf	CKE2	    ;CKE bit in SSP2STAT
	movlw	(SSP2CON1_SSPEN_MASK)|(SSP2CON1_CKP_MASK)|(SSP2CON1_SSPM1_MASK)
	movwf	SSP2CON1, A	    ;SDO2Output; SCK2 Output
	bcf	TRISD, PORTD_SDO2_POSN, A	    ; bit in register f is cleared
	bcf	TRISD, PORTD_SCK2_POSN, A
	return

SPI_MasterTransmit:		    ; Start transmission of data (held in W)
	tblrd*+
	movf	TABLAT, W, A
	movwf	SSP2BUF, A	    ; Write data to output buffer
	call	Wait_Transmit
	movlw	0xffff
	movwf	0x20,A
	call	delay
	call	delay
	return
	
Wait_Transmit:			    ; Wait for transmission to complete
	btfss	PIR2, 5		    ; check interrupt flag to see if data has been sent; Bit Test File, Skip if Set
	bra	Wait_Transmit
	bcf	PIR2, 5		    ; Clear interrupt flag
	return 
	
    
delay:
	decfsz	0x20, F, A
	bra	delay
	return
    
	end	main
