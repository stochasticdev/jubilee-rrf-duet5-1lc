; Extrude 5mm

var tool_temp = tools[param.C].active[0]

G91

if var.tool_temp >= heat.coldExtrudeTemperature
  G1 E8 F300

G4 P100
G1 Y-30 F3000
G1 Y30
G1 Y-30
G1 Y30
G1 Y-30
G1 Y30
G1 Y-30
G1 Y30
G1 Y-30
G1 Y30
G90
