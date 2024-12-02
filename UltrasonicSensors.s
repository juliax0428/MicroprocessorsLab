#include <xc.inc>
    
    
extrn	CCP1_count
extrn	motor_setup, Forward, Backward, Turn_left, Turn_right,Stop, Standby, motor_test
    

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
    cpfsgt	CCP1_count		    ; compare ccp1_count with safety distance
    return				    ; Z flage is set if distance >= safety_dist
    
stop_r:
    call	Standby			    ;
    return
 
run_r:
    call	motor_test
    return

end