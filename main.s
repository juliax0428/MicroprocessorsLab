	#include <xc.inc>
	
psect	code, abs
main:
	org 0x0
	goto	setup
	
	org 0x100		    ; Main code starts here at address 0x100

	; ******* Programme FLASH read Setup Code ****  
setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	clrf	PORTC, A	; Clear PORT C to start with all LEDs off
	movlw	0x00
	movwf	TRISC, A	; Set PORT C as output for LEDs
	goto	start
	
	; ******* My data and where to put it in RAM *
myTable:
	db	'a','b','c','d','e','f', 'g','h'
	myArray EQU 0x400	; Address in RAM for data
	counter EQU 0x10	; Address of counter variable
	align	2		; ensure alignment of subsequent instructions
	
	; ******* Main programme *********************
start:	
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A	; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A	; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A	; load low byte to TBLPTRL
	movlw	8		; 7 bytes to read
	movwf 	counter, A	; our counter register
loop:
        tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, PORTC	;Output data to PORT C LEDs
	call	bigdelay	; Call delay routine
	call	bigdelay
	call	bigdelay
	call	bigdelay
	call	bigdelay
	call	bigdelay
	movff	TABLAT, POSTINC0	;Move read data from TABLAT to FSR0, increment FSR0
	decfsz	counter, A	; count down to zero
	bra	loop		; keep going until finished
	goto	0

	
	;******Delay Subroutine ********************
bigdelay:
	movlw	0x00		; W=0
Dloop:				;Delay Loop
	decf	0x08,  f, A	; no carry when 0x00 --> 0xff
	subwfb  0x10,  f, A	; no carry when 0x00 --> 0xff
	bc	Dloop		; if carry, hen loop again
	return			; carry not set so return	
	
	end	main
