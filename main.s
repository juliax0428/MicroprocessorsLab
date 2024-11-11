	#include <xc.inc>

psect	code, abs
main:
    org	    0
    goto    setup
    
setup:
    bcf	    CFGS		; Point to Flash memory 
    bsf	    EEPGD		; Access flash program memory
    goto    start

myTable:
    db		'a','b','c','d','e','f','g','h','i'
    db		'1','2','3','4','5','6','7','8','9'
    myArray	EQU 0x400
    counter	EQU 0x10
    align 2

start:
    lfsr    0, myArray		; Load FSR0 with address in RAM
    movlw   low highword(myTable)
    movwf   TBLPTRU, A
    movlw   high(myTable)
    movwf   TBLPTRH, A
    movlw   low(myTable)
    movwf   TBLPTRL,A
    clrf    TRISD, A		;set Port D as output
    call    SPI_MasterInit
    call    SPI_MasterTransmit

loop:
    tblrd*+
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
	movwf	SSP2BUF, A	    ; Write data to output buffer
Wait_Transmit:			    ; Wait for transmission to complete
	btfss	PIR2, 5		    ; check interrupt flag to see if data has been sent; Bit Test File, Skip if Set
	bra	Wait_Transmit
	bcf	PIR2, 5		    ; Clear interrupt flag
	return 
	

    
delay:
    movlw   0x00    ; W=0
    setf    0x08, A
    clrf    0x09, A
Dloop:
    decf    0x08, f, A
    subwfb  0x09, f, A
    bc	    Dloop
    return
    
	end	main
