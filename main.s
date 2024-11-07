#include <xc.inc>

    psect code, abs

main:
    org	    0
    goto    setup
    
setup:
    bcf	    CFGS        ; Point to Flash memory 
    bsf	    EEPGD       ; Access flash program memory
    goto    start

myTable:
    myArray	EQU 0x400
    counter	EQU 0x10
    align 2

start:
    lfsr    0, myArray ; Load FSR0 with address in RAM
    movlw   0x0
    movwf   counter, A
    clrf    TRISD, A  ;set Port D as output

incresement:
    movf    counter, W, A
    movwf   PORTD   , A; Write to PORTD register
    incf    counter, F, A
    movlw   0xFE
    cpfsgt  counter, A
    bra	    incresement

decresement:
    ; Output the current value to DAC
    movf    counter, W, A
    movwf   PORTD, A   ; Write to PORTD register
    decf    counter, F, A
    movlw   0x00
    cpfseq  counter, A
    bra	    decresement
    bra	    incresement

loop:
    movff counter, PORTD
    incf counter, W, A
test:
    movwf counter, A 
    movlw 0x63
    cpfsgt counter, A
    bra loop         ; Not yet finished, go to start of loop again
    goto 0x0         ; Re-run program from start

    end main