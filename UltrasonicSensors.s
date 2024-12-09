#include <xc.inc>
    
extrn	Stop
extrn	Echo_Time_H, Echo_Time_L
extrn	safety_dist_h, safety_dist_l

global	sensor_setup, sensor_trigger, compare_distance

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup Sensors and Trigger rountine	                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
psect	sensor_code,class=CODE
    
sensor_setup:
    bcf		TRISE, 3,  A
    bcf		TRISF, 7, A
    bsf		TRISE, 3, A		    ; set RE6 as trigger 
    bsf		TRISF, 7, A		    ; Set RE7 as echo
    clrf	LATE, A
    clrf	LATF, A
    return          

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Send a short pulse via RE6 to trigger the ultrasonic sensor			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
sensor_trigger:
    bcf		PORTE, 3, A		    ;Ensure Trigger is Low
    call	delay_10us
    bsf		PORTE, 3, A		    ;Trigger is High ~ 10us
    call	delay_10us
    bcf		PORTE, 3, A		    ;Trigger is Low again
    return

compare_distance:
    ; Compare high byte of Echo_Time with safety_dist_h
    movf	Echo_Time_H, W, A	    ; Load high byte of measured distance
    cpfslt	safety_dist_h, A	    ; Compare safety_dist_h with Echo_Time_H
    goto	Distance_Safe		    ; Safe if safety_dist_h >= Echo_Time_H
    goto	Distance_Unsafe
    
Distance_Unsafe:
    call	Stop
    ;call	buzzer
    return

Distance_Safe:
    return


delay_10us:
    nop					    ; Adjust based on clock speed, usually ~4 cycles per NOP
    nop
    nop
    nop
    return
end