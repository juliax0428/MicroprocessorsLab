#include <xc.inc>

extrn	sensor_setup, sensor_trigger, sensor_distance
extrn	motor_setup, Forward, Backward, Left, Right, Stop, motor_test
extrn	T1_setup, CCP_setup, CCP_reset
extrn	Keypad_Setup, Keypad_Read

global	safety_dist
    
psect	udata_acs
safety_dist_h:	ds 1			; Reserve 1 byte for safety distance high
safety_dist_l:	ds 1			; Reserve 1 byte for safety distance low
key_value:	ds 1			; Reserve 1 byte for keypad value
    
psect code, abs
 
rst:
    org 0x0
    goto setup

setup:
    call motor_setup			    ; Initialize motor setup
    call Keypad_Setup			    ; Initialize keypad setup
    ;call sensor_setup			    ; Initialize sensor setup
    ;call CCP_setup			    ; Initialize CCP module
    ;call T1_setup
     
    movlw	0x04			    ;Setup the safety distance 10cm
    movwf	safety_dist_h, A
    movlw	0x8F
    movwf	safety_dist_l, A	    
    
main_loop:
    call	Keypad_Read
    ;call	sensor_trigger		    ; Send ultrasonic pulse
    ;call	CCP_reset		    ; Reset CCP and Timer
    ;call	CCP_Interrupt
    ;call	compare_distance	    
    goto	$
    
end rst
