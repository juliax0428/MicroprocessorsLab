#include <xc.inc>
    
extrn	Stop, delay, Backward
extrn	Echo_Time_H, Echo_Time_L
extrn	safety_dist_h, safety_dist_l

global	sensor_setup, sensor_trigger, compare_distance, US_measuring

psect udata_acs
US_measuring:	ds 1	; flag to indicate if measurement in progress

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup Sensors and Trigger rountine	                                     ;
;   Trigger: RE3, Echo: RE1						     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
psect	sensor_code,class=CODE
    
sensor_setup:
    bcf		TRISE, 3,  A			    ; set RE3 as trigger
    ;bcf		TRISE, 1, A
    ;bsf		TRISE, 3, A		     
    ;bsf		TRISC, 2, A			    ; Set RE1 as echo
    ;bcf		LATE, 3, A
    ;bcf	    	LATE, 1, A
    clrf	US_measuring, A
    return          

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Send a short pulse via RE3 to trigger the ultrasonic sensor			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
sensor_trigger:
    btfsc	PORTC, 2, A		    ;Check if Echo is Low
    return

    bcf		PORTE, 3, A		    ;Ensure Trigger is Low
    movlw	1
    call	delay
    bsf		PORTE, 3, A		    ;Trigger is High ~ 10us
    call	delay_10us
    bcf		PORTE, 3, A		    ;Trigger is Low again
    bsf		US_measuring, 0, A
    return

compare_distance:
    ; Compare (Echo_Time_H:Echo_Time_L) <= (safety_dist_h:safety_dist_l)
    
    ; First compare the high bytes
    movf    Echo_Time_H, W, A
    subwf   safety_dist_h, W, A     ; W = safety_dist_h - Echo_Time_H
    btfss   STATUS, 2               ; If zero skip next
    btfsc   STATUS, 0               ; If carry set, Echo_Time_H <= safety_dist_h
    goto    compare_low
    goto    Distance_Unsafe         ; If Echo_Time_H > safety_dist_h, unsafe
    
compare_low:
    ; High bytes are equal, compare low bytes
    movf    Echo_Time_L, W, A
    subwf   safety_dist_l, W, A     ; W = safety_dist_l - Echo_Time_L
    btfsc   STATUS, 0               ; If carry set, Echo_Time_L <= safety_dist_l
    goto    Distance_Safe
    goto    Distance_Unsafe
    
    
Distance_Unsafe:
    call	Backward
    return

Distance_Safe:
    return


delay_10us:
    nop					    ; Adjust based on clock speed, usually ~4 cycles per NOP
    nop
    nop					    ; Adjust based on clock speed, usually ~4 cycles per NOP
    nop
    nop					    ; Adjust based on clock speed, usually ~4 cycles per NOP
    nop
    nop					    ; Adjust based on clock speed, usually ~4 cycles per NOP
    nop
    nop					    ; Adjust based on clock speed, usually ~4 cycles per NOP
    nop
    nop					    ; Adjust based on clock speed, usually ~4 cycles per NOP
    nop
    nop					    ; Adjust based on clock speed, usually ~4 cycles per NOP
    nop
    nop
    return
end