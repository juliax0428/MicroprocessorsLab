#include <xc.inc>
    
extrn	Stop, delay
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
    btfsc	PORTC, 2, A
    return
;    bcf		PORTE, 3, A		    ;Ensure Trigger is Low
    movlw	1
    call	delay
    bsf		PORTE, 3, A		    ;Trigger is High ~ 10us
    call	delay_10us
    bcf		PORTE, 3, A		    ;Trigger is Low again
    bsf		US_measuring, 0, A
    return

compare_distance:			    ; Compare high byte of Echo_Time with safety_dist_h
    movf	Echo_Time_H, W, A	    ; Load high byte of measured distance
    cpfslt	safety_dist_h, A	    ; Compare safety_dist_h with Echo_Time_H
    goto	Distance_Safe		    ; Safe if safety_dist_h >= Echo_Time_H
    goto	Distance_Unsafe
    
Distance_Unsafe:
    ;bsf		PORTE, 4, A
    
    call	Stop
    ;call	buzzer
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