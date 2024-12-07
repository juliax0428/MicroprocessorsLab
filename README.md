# Microprocessors -- Motor Vehicle Control and Obstacles Detection
Repository for Physics Year 3 microprocessors lab


## Hardwares:
  - Development Board: PIC18FJ
  - Microcontroller: PIC18F87J50
  - Motor Controller: DC Motor 20 Clicker with TC78H651AFNG embedded
  - Ultrasonic Sensor: HC-SR 04
  - Keypad

## Software:
The programming language used is Assembly. 

The code in Vehicle_Motor Branch is used for this project, inlcuded several modules:
  - main.s: For key routines
  - DC_Motor_20_Click.s: For controlling the motors
  - UltrasonicSensors.s: For sending trigger pulse
  - pwm.s: For receiving echo pulse and time interrupt
  - Delay.s: For a delay routine of approximately 1 second
  - Keypad.s: For reading the input from a keypad 
  
