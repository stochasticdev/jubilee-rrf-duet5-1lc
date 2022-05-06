; Default config.g template for DuetPi
; Replace this with a proper configuration file (e.g from https://configtool.reprapfirmware.org)

; Display initial welcome message
; M291 P"Please go to <a href=""https://www.duet3d.com/StartHere"" target=""_blank"">this</a> page for further instructions on how to set it up." R"Welcome to your new Duet 3!" S1 T0

M550 P"Jubilee"           ; Name used in UI and for mDNS  http://Jubilee.local

; Enable network
if {network.interfaces[0].type = "ethernet"}
    M552 P0.0.0.0 S1
else
    M552 S1

M586 P0 S1                                   ; enable HTTP
M586 P1 S1                                   ; enable FTP
M586 P2 S0                                   ; disable Telnet

; General setup
;-------------------------------------------------------------------------------
M111 S0                    ; Debug off 
;M929 P"eventlog.txt" S1    ; Start logging to file eventlog.txt

; General Preferences
M555 P2                    ; Set Marlin-style output
G21                        ; Set dimensions to millimetres
G90                        ; Send absolute coordinates...
M83                        ; ...but relative extruder moves

; PanelDue 5i
M575 P1 B115200 S1

; Motor (Drive) to Axis Mapping
;-------------------------------------------------------------------------------
M584 X0.5 Y0.6            ; Map Corexy's X,Y axes to mini 5+'s expansion board
M584 U0.3                 ; Map U axis (toolchanger lock) do main board port 1.
M584 Z0.0:0.1:0.2         ; Map 3 axes for Z to main board ports 2, 3, and 4.

; Motor (Drive) Currents and Directions
;-------------------------------------------------------------------------------
M569 P0.5 S1 D2             ; Flip 3HC Motor 0 (corexy a) direction
M569 P0.6 S1 D2             ; Flip 3HC Motor 1 (corexy b) direction
M906 X{0.7*sqrt(2)*1200} I30 ; LDO XY 1200mA RMS the TMC2209 driver on duet3 mini
M906 Y{0.7*sqrt(2)*1200} I30 ; generates a sinusoidal coil current so we can 
                          ; multply by sqrt(2) to get peak used for M906
                          ; Do not exceed 90% without heatsinking the XY 
                          ; steppers.
                                            
M569 P0.0 S0 D3              ; Flip Mainboard Motor 2 (Front Left Z) direction.
M569 P0.1 S0 D3             ; Flip Mainboard Motor 2 (Front Right Z) direction.
M569 P0.2 S0 D3             ; Flip Mainboard Motor 2 (Back Z) direction.
M906 Z{0.7*sqrt(2)*1200} I30 ; 70% of 1200mA RMS current.

M569 P0.3 S0 D3             ; Flip Main Board Motor 0 (toolchanger) directon.
M906 U670 I60             ; 100% of 670mA RMS current. idle 60%.
                          ; Note that the idle will be shared for all drivers.
						  
; Kinematics
;-------------------------------------------------------------------------------
M669 K1                   ; CoreXY mode

; Kinematic bed ball locations.
; Locations are extracted from CAD model assuming lower left build plate corner
; is (0, 0) on a 305x305mm plate.
M671 X295:0:145 Y313.5:313.5:-16.5 S10 ; Front Left: (297.5, 313.5)
                                           ; Front Right: (2.5, 313.5)
                                           ; Back: (150, -16.5)
                                           ; Set up to 10mm correction.
										   
; Steps/<unit> Configuration
; XYZZZ are in steps/mm. U is in steps/degree. 
;-------------------------------------------------------------------------------

M350 X1 Y1 Z1 U1       ; Disable microstepping to simplify calculations.
M92 X{1/(1.8*16/180)}  ; step angle * tooth count / 180 .
M92 Y{1/(1.8*16/180)}  ; The 2mm tooth spacing cancel out with diam to radius.
M92 Z{360/0.9/4}       ; 0.9 deg stepper / screw lead pitch (4mm) .
                       ; If using a T8x2 leadscrew, change 4 to 2.
M92 U{13.76/1.8}       ; gear ratio / step angle for tool lock geared motor.

; Enable microstepping.
; All steps-per-unit will be multiplied by the new step definition.
M350 X16 Y16 I1        ; 16x microstepping for CoreXY axes. Not Use interpolation.
M350 U4 I1             ; 4x for toolchanger lock. Use interpolation.
M350 Z16 I1            ; 16x microstepping for Z axes. Not Use interpolation.

; Speed and Acceleration
;-------------------------------------------------------------------------------
M201 X6000 Y6000       ; XY accelerations [mm/s^2]
                       ; XY accel can be increased up to 2500 or beyond later.
M201 Z80              ; ZZZ Acceleration
M201 U800              ; U accelerations [deg/s^2]

M203 X60000.00 Y60000.00 Z1800 U9000 ; Maximum axis speeds [mm/min]
                               ; If using a T8x2 leadscrew, change Z to 800.
M566 X500 Y500 Z500 U50        ; Maximum jerk speeds [mm/min]

; Endstops and Probes 
;-------------------------------------------------------------------------------
M574 X1 S1 P"^0.io1.in"  ; 3HC X homing position X1 = axis min, S1 = switch type
M574 Y1 S1 P"^0.io2.in"  ; 3HC Y homing position Y1 = axis min, S1 = switch type
M574 U1 S1 P"^0.io4.in"  ; Mainboard U homing position.
                         ; U1 = axis min, S1 = switch type

M574 Z0                  ; Configure z switch as a Z probe, not as an endstop. 
M558 K0 P8 C"0.io3.in" H3 F360 T30000 A10 ; H = dive height
                                ; F = probe speed
                                ; T = travel speed
								; A = Maximum number of times to probe each poin
G31 K0 X0 Y0 Z-2        ; Set the limit switch as the "Control Point"
                        ; Offset it downwards slightly so we don't smear it along
                        ; the bed while traveling when z=0.
						
						
; Set axis software limits and min/max switch-triggering positions.
; Dimensions are adjusted such that (0,0) lies at the lower left corner
; of a centered 300x300mm square in the 305mmx305mm build plate.
M208 X-13.75:313.75 Y-44:341 Z0:315
M208 U0:200            ; Set Elastic Lock (U axis) max rotation angle
M557 X0:300 Y0:300 S41  ; Define bed mesh grid (inductive probe, positions include the Z offset!)

; Bed Heater and Temperature Sensor
;-------------------------------------------------------------------------------
; Define Built-in Thermistor Settings
M308 S0 P"0.temp0" Y"thermistor" T100000 B3950 A"Bed" ; built-in Keenovo thermistor
; Define Heater 0
M950 H0 C"0.out0" T0 Q360
                        ; H = Heater 0
                        ; C = heater output pin
                        ; T = assigned temperature sensor
						; Q = pwm frequency
M143 H0 S137            ; Set max bed temperature to 137C / to allow overshoot from 110C    
M140 H0                 ; Assign Heater 0 to the bed
M570 H0 T25 P5         ; Set overshoot limit to 25C and for over 5 seconds

; Tools

; Tool 0
; extruder
M569 P20.0 S0    ; E motor direction
; Tool 1
; extruder
M569 P21.0 S0    ; E motor direction
; Tool 2
; extruder
M569 P22.0 S0    ; E motor direction
; Tool 3
; extruder
M569 P23.0 S0
; Tool 4
; extruder
M569 P24.0 S0

M584 E20.0:21.0:22.0:23.0:24.0       ; extruder mapping
M350 E16:16:16:16:16 I0      ; Extruder microstepping
M92 E562:562:562:562:562  ; step angle * tooth count / 180 .

var lgxLiteRatio = 0.65
var lgxLitePeakCurrent = 1000 * sqrt(2) ; Max current = 1A for LGX Lite 20mm NEMA14 pancake motor
var lgxLiteCurrent = var.lgxLiteRatio * var.lgxLitePeakCurrent

M906 E{var.lgxLiteCurrent}:{var.lgxLiteCurrent}:{var.lgxLiteCurrent}:{var.lgxLiteCurrent}:{var.lgxLiteCurrent} I50  ; LGX Lite

; HotEnd Heaters and Thermistor HotEnd      
M308 S1 P"20.temp0" Y"thermistor"               ; define E0 temperature sensor 
M950 H1 C"20.out0" T1 Q100					                        ; Create HotEnd Heater
M307 H1 B0 R2.310 C158.7:115.4 D5.24 S1.00 V24.5					; PID
M143 H1 S295                                                    	; Set temperature limit for heater 1 to 285C HotEnd

; Fans Hotend + Part
M950 F1 C"20.out1" Q250				; Creates HOTEND Fan
M106 P1 T45 S1 H1 C"Tool 1 Hotend Fan"                ; HOTEND Fan Settings
M950 F0 C"20.out2" Q250				; Creates PARTS COOLING FAN
M106 P0 H-1 C"Tool 1 Parts Fan"                        ; Set fan 1 value, PWM signal inversion and frequency. Thermostatic control is turned off PARTS COOLING FAN

; HotEnd Heaters and Thermistor HotEnd      
M308 S2 P"21.temp0" Y"thermistor"               ; define E1 temperature sensor 
M950 H2 C"21.out0" T2 Q100					                        ; Create HotEnd Heater
M307 H2 B0 R2.310 C158.7:115.4 D5.24 S1.00 V24.5					; PID
M143 H2 S295                                                    	; Set temperature limit for heater 1 to 285C HotEnd
	
; Fans Hotend + Part
M950 F3 C"21.out1" Q250				   ; Creates HOTEND Fan
M106 P3 T45 S2 H2 C"Tool 2 Hotend Fan" ; HOTEND Fan Settings
M950 F2 C"21.out2" Q250				   ; Creates PARTS COOLING FAN
M106 P2 H-1 C"Tool 2 Parts Fan"        ; Set fan 1 value, PWM signal inversion and frequency. Thermostatic control is turned off PARTS COOLING FAN

; HotEnd Heaters and Thermistor HotEnd      
M308 S3 P"22.temp0" Y"thermistor"               ; define E1 temperature sensor 
M950 H3 C"22.out0" T3 Q100					                        ; Create HotEnd Heater
M307 H3 B0 R2.310 C158.7:115.4 D5.24 S1.00 V24.5					; PID
M143 H3 S295                                                    	; Set temperature limit for heater 1 to 285C HotEnd
	
; Fans Hotend + Part
M950 F5 C"22.out1" Q250				   ; Creates HOTEND Fan
M106 P5 T45 S3 H3 C"Tool 3 Hotend Fan" ; HOTEND Fan Settings
M950 F4 C"22.out2" Q250				   ; Creates PARTS COOLING FAN
M106 P4 H-1 C"Tool 3 Parts Fan"        ; Set fan 1 value, PWM signal inversion and frequency. Thermostatic control is turned off PARTS COOLING FAN

; HotEnd Heaters and Thermistor HotEnd      
M308 S4 P"23.temp0" Y"thermistor"               ; define E1 temperature sensor 
M950 H4 C"23.out0" T4 Q100					                        ; Create HotEnd Heater
M307 H4 B0 R2.310 C158.7:115.4 D5.24 S1.00 V24.5					; PID
M143 H4 S295                                                    	; Set temperature limit for heater 1 to 285C HotEnd
	
; Fans Hotend + Part
M950 F7 C"23.out1+out1.tach" Q250				   ; Creates HOTEND Fan
M106 P7 T45 S4 H4 C"Tool 4 Hotend Fan" ; HOTEND Fan Settings
M950 F6 C"23.out2" Q250				   ; Creates PARTS COOLING FAN
M106 P6 H-1 C"Tool 4 Parts Fan"        ; Set fan 1 value, PWM signal inversion and frequency. Thermostatic control is turned off PARTS COOLING FAN

; HotEnd Heaters and Thermistor HotEnd      
M308 S5 P"24.temp0" Y"thermistor"               ; define E1 temperature sensor 
M950 H5 C"24.out0" T5 Q100					                        ; Create HotEnd Heater
M307 H5 B0 R2.310 C158.7:115.4 D5.24 S1.00 V24.5					; PID
M143 H5 S295                                                    	; Set temperature limit for heater 1 to 285C HotEnd
	
; Fans Hotend + Part
M950 F9 C"24.out1+out1.tach" Q250				   ; Creates HOTEND Fan
M106 P9 T45 S5 H5 C"Tool 5 Hotend Fan" ; HOTEND Fan Settings
M950 F8 C"24.out2" Q250				   ; Creates PARTS COOLING FAN
M106 P8 H-1 C"Tool 5 Parts Fan"        ; Set fan 1 value, PWM signal inversion and frequency. Thermostatic control is turned off PARTS COOLING FAN

M302 S185 R185 ; extrusion temp

; Speed and Acceleration
;-------------------------------------------------------------------------------
M201 E300       ; E accelerations [mm/s^2]
M203 E3000 ; Maximum axis speeds [mm/min]
M566 E600        ; Maximum jerk speeds [mm/min]

M563 P0 S"Tool 0" D0 H1 F0 ; Define tool 0
M563 P1 S"Tool 1" D1 H2 F2 ; tool 1
M563 P2 S"Tool 2" D2 H3 F4 ; tool 2
M563 P3 S"Tool 3" D3 H4 F6 ; tool 3
M563 P4 S"Tool 4" D4 H5 F8 ; tool 4

; reset all tools

M568 P0 R0 S0 F0 A0
M568 P1 R0 S0 F0 A0
M568 P2 R0 S0 F0 A0
M568 P3 R0 S0 F0 A0
M568 P4 R0 S0 F0 A0

; Accelerometers

M955 P24.0 I14
;M955 P21.0 I14
;M955 P22.0 I14

; Input shaping
M593 P"mzv" F49.0 S0.1

M84 S86400

; This config requires a heater-tuning procedure to produce a valid M307 command.
M98  P"/sys/toffsets.g" ; Load tool offsets from the Control Point from ext file.
M501                    ; Load saved parameters from config-override.g
