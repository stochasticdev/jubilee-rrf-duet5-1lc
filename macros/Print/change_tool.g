; T-1 ; return the tool

var current_extruder = param.C
var next_extruder = param.T

var active_temp = param.S
var standby_temp = param.R
var filament_type = param.F
var nozzle_diameter = param.N

if var.current_extruder != var.next_extruder
  ; retract current tool
  G91
  G1 E-2 F300
  G90
  M568 P{var.current_extruder} S0 R{var.standby_temp}
  M106 P{var.current_extruder*2} S1 ; turn on part cooling fan to make cooling faster

; change the next tool temp
M568 P{var.next_extruder} S{var.active_temp}
M116 P{var.next_extruder} ; wait for temp

; change tool
T{var.next_extruder}
  
; filament profile
M98 P"0:/macros/Print/set_filament_profile.g" C{var.next_extruder} F{var.filament_type} N{var.nozzle_diameter}
