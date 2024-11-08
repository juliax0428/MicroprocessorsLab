#include <xc.inc>

    psect code, abs

main:
    org	    0
    goto    setup
    
setup:
    bcf	    CFGS		; Point to Flash memory 
    bsf	    EEPGD		; Access flash program memory
    goto    start

myTable:
    myArray	EQU 0x400
    counter	EQU 0x10
    align 2

start:
    lfsr    0, myArray		; Load FSR0 with address in RAM
    movlw   0x0
    movwf   counter, A
    clrf    TRISD, A		;set Port D as output

incresement:
    movf    counter, W, A
    movwf   PORTD   , A		; Write to PORTD register
    call    delay
    incf    counter, F, A
    movlw   0xFE
    cpfsgt  counter, A
    bra	    incresement

decresement:
    movf    counter, W, A
    movwf   PORTD, A		; Write to PORTD register
    call    delay
    decf    counter, F, A
    movlw   0x00
    cpfseq  counter, A
    bra	    decresement
    bra	    incresement

loop:
    movff   counter, PORTD
    incf    counter, W, A
test:
    movwf   counter, A 
    movlw   0x63
    cpfsgt  counter, A
    call    delay
    call    delay
    call    delay
    bra	    loop         ; Not yet finished, go to start of loop again
    goto    start   ; Re-run program from start
    
delay:
    movlw   0x00    ; W=0
    setf    0x08, A
    clrf    0x09, A
Dloop:
    decf    0x08, f, A
    subwfb  0x09, f, A
    bc	    Dloop
    return

    end main