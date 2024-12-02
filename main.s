#include <xc.inc>

extrn	sensor_setup, sensor_send_signal, sensor_check_distance,
entrn	motor_setup, Forward, Backward, Left, Right, Stop, motor_test
extrn	T1_Setup, CCP_setup

psect	udata_acs
safety_dist:	ds 1			; Reserve 1 bit for safety distance
    
psect code
 
org 0x0
goto setup

 
setup:
    call motor_setup			    ; Initialize motor setup
    call sensor_setup			    ; Initialize sensor setup
    call CCP_setup			    ; Initialize CCP module
    call T1_setup
    
start:    
    movlw	0x0F			    ;Setup the safety distance as 0x0F = 15cm
    movwf	safety_dist, A
    
main_loop:
    call	sensor_send_signal	    ; Send ultrasonic pulse
    call	CCP_reset		    ; Reset CCP and Timer
    call	CCP_setup		    ; Re-enable CCP and Timer

    call	sensor_distance		    ; Check distance
    btfss	STATUS, Z		    ; Check if Z flag is set (safe distance)
					    ; if Z=0(distance<safety distance), jumps to emergency_stop
    goto	emergency_stop

    goto	continue_vehicle

    
emergency_stop:
    call	Stop			    ; Stop the vehicle

continue_vehicle:
    call	motor_test
    goto	main_loop

end
