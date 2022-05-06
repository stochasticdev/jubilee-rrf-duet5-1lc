; Set parameters according to filament type

; default retraction
M207 P{param.C} S0.4 R0 F2100 Z{param.N}    ; firmware retraction 

echo "Filament profile: " ^ param.F
if param.F == "PETG"
  ;M572 D0 S0.06                  ; pressure advance
  M207 P{param.C} S0.80 R0 F2100 Z{param.N}    ; firmware retraction
  M221 D{param.C} S95.0
elif param.F == "ABS" || param.F == "ASA"
  ;M572 D0 S0.04 ; pressure advance
  M207 P{param.C} S0.4 R0 F2100 Z{param.N}    ; firmware retraction
  M221 D{param.C} S95.0
elif param.F == "PLA"
  ;M572 D0 S0.04
  M207 P{param.C} S0.6 R0 F2100 Z{param.N}    ; firmware retraction 
  M221 D0 S96.0
