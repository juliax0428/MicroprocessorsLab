#include <xc.inc>
    
    
extrn	CCP_Echo_Capture
extrn	motor_setup, Forward, Backward, Left, Right,Stop, Stop, motor_test
extrn	safety_dist   

global	sensor_setup, sensor_send_signal, sensor_distance

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sensor Code for Obstacle Detection                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
psect	ping_code,class=CODE
    
sensor_setup:
    bcf		TRISC, PORTC_RC6_POSN, A    ;RC6 as output for debugging purposes
    return          

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Send a short pulse via RE3 to trigger the ultrasonic sensor			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sensor_send_signal:
    bcf		TRISE, PORTE_RE3_POSN, A    ;RE3 output
    bcf		PORTE, PORTE_RE3_POSN, A    ;RE3 low
    bsf		PORTE, PORTE_RE3_POSN, A    ;RE3 high: send trigger pulse
    nop
    nop
    bcf		PORTE, PORTE_RE3_POSN, A    ;RE3 low: end trigger pulse
    bsf		TRISE, PORTE_RE3_POSN, A    ;RE3 input
    retfie
    
sensor_distance:
    movf	safety_dist, w, A
    cpfsgt	CCP_Echo_Capture, A		    ; compare ccp1_count with safety distance
    return				    ; Z flage is set if distance >= safety_dist
    
end