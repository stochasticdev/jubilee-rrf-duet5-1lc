M98 P"0:/macros/tool/retreat.g"

; Home, but only if homing is needed
M98 P"/macros/Home/Home_xy"
M98 P"/macros/Home/z_current_low.g"

M290 R0 S0                 ; Reset baby stepping
M561                       ; Disable any Mesh Bed Compensation
;G30 P0 X152.5 Y5 Z-99999   ; probe near back leadscrew
;G30 P1 X295 Y295 Z-99999   ; probe near front left leadscrew
;G30 P2 X5 Y295 Z-99999 S3  ; probe near front right leadscrew and calibrate 3 motors
;G29 S1                     ; Enable Mesh Bed Compensation

; move gantry up
G91               	; relative positioning
G1 H2 Z15 F6000    	; lift Z relative to current position
G90				  	; absolute positioning

M558 F300 ; set probe speed

while true
  if iterations = 10
    abort "Too many auto calibration attempts"
  
  G30 P0 X152.5 Y5 Z-99999   ; probe near back leadscrew
  if result != 0
    continue
  
  G30 P1 X295 Y295 Z-99999   ; probe near front left leadscrew
  if result != 0
    continue
  
  G30 P2 X5 Y295 Z-99999 S3  ; probe near front right leadscrew and calibrate 3 motors
  if result != 0
    continue

  if move.calibration.initial.deviation <= 0.005
    break

  ; If there were too many errors or the deviation is too high - abort and notify user  
  echo "Repeating calibration because deviation is too high (" ^ move.calibration.initial.deviation ^ "mm)"
; end loop
echo "Auto calibration successful, deviation", move.calibration.initial.deviation ^ "mm"

M98 P"0:/macros/Home/move_over_center.g"

M98 P"/macros/Home/z_current_high.g"
