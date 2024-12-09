#include <xc.inc>

global  T1_setup, CCP_setup, CCP_Interrupt, CCP_reset
global	Echo_Time_H, Echo_Time_L

psect udata_acs
capture_state:	ds 1			    ; 0 = capture rising edge, 1 = capture falling edge
start_time_H:	ds 1			    ;reserve 1 byte for start time high
start_time_L:	ds 1			    ;reserve 1 byte for start time low
end_time_H:	ds 1			    ;reserve 1 byte for end time high
end_time_L:	ds 1			    ;reserve 1 byte for end time low
Echo_Time_H:	ds 1
Echo_Time_L:	ds 1			    


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup and Initialization for Timer 1 and CCP module.				    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
psect	ccp_code,class=CODE

CCP_setup:
    bsf		TRISF, 7, A		    ;RF7=CCP1 as input
    movlw	00000100B		    ;Capture on every rising edge
    movwf	ECCP1CON, A
    bsf		PIE1, 2, A		    ;Enable CCP1 interrupt
    
    clrf	capture_state, A	    ; Start with capturing rising edge
    return

T1_setup:
    bsf		INTCON, 6, A		    ;Enable peripheral interrupts (PEIE)
    bsf		INTCON, 7, A		    ;Enable Global interrupts (GIE)
    clrf	RCON, A			    ;Disable Interrupt Priority (IPEN)
    clrf	PIR1, A			    ;Clear all interrupt flags
    clrf	CCPR1L, A		    ;Clear CCP1 low byte
    clrf	CCPR1H, A		    ;Clear CCP1 high byte
    clrf	TMR1L, A		    ;Clear Timer 1 low byte
    clrf	TMR1H, A		    ;Clear Timer 1 high byte
    movlw	01001001B		    ;Enable Timer 1 with prescaler 1:1 using Internal Clock, R/W into 2 8-bit operations
    movwf	T1CON, A		    
    return

CCP_Interrupt:				    ;Interrupt routine
    btfsc	PIR1, 2, A		    ;Check if CCP1 interrupt
    goto	CCP_Echo_Capture
    retfie				    ;Return from interrupt routine
    
CCP_Echo_Capture:
    ;store current capture value
    movff	CCPR1H, Echo_Time_H, A	    ;Store high byte of Timer 1 
    movff	CCPR1L, Echo_Time_L, A	    ;Store low byte of Timer 1
    
    btfsc	capture_state,0, A	    ;if capture_state bit is clear, handle rising edge
    goto	falling_edge
    
rising_edge:
    movff	Echo_Time_H, start_time_H, A
    movff	Echo_Time_L, start_time_L, A
    
    movlw	00000101B		    ;Capture on every falling edge
    movwf	ECCP1CON,A
    
    bsf		capture_state,0, A	    ; Waiting for falling edge
    goto	CCP_reset
    
falling_edge:
    movff	Echo_Time_H, end_time_H, A
    movff	Echo_Time_L, end_time_L, A
    
    goto	pulse_width
    
    movlw	00000100B		    ; Capture on every rising edge
    movwf	ECCP1CON, A
    bcf		capture_state, 0, A	    ; Waiting for rising edge
    
    
pulse_width:				    ; Pulse width = end time - start time
    movf	end_time_L, W, A
    subwf	start_time_L, W, A	    ; L: end time - start time = w
    movwf	Echo_Time_L, A		    ; store w in echo_time_L
    
    movf	end_time_H, W, A
    subwf	start_time_H, W, A	    ; H: end time - start time = w
    movwf	Echo_Time_H, A		    ; store w in echo_time_H
    return
    
    
CCP_reset:
    clrf	PIR1, A			    ;Clear all flags
    clrf	CCPR1L, A		    ;Clear CCP1 count
    clrf	CCPR1H, A
    clrf	TMR1L, A
    clrf	TMR1H, A
    retfie
end

    