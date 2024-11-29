#include <xc.inc>

extrn	motor_setup, motor_test

psect	udata_acs

setup:
    call motor_setup


psect	code
	
main:
    org 0x0
    goto start
	
start:
    call motor_test

end 