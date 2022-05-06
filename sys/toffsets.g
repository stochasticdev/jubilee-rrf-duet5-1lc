; Tool Offsets
; These are XYZ offsets from the tip of the tool to the
; trigger location of the Z Probe.
; See the wiki on how to calculate these:
; https://jubilee3d.com/index.php?title=Setting_Tool_Offsets


global T0XOffset = -0.6
global T1XOffset = -0.6
global T2XOffset = 0
global T3XOffset = -0.1
global T4XOffset = 0.1

global T0YOffset = 38.4
global T1YOffset = 38.2
global T2YOffset = 37.9
global T3YOffset = 38.4
global T4YOffset = 37.9


global scaleFlex = -0.155 ; .155

;G10		P0 	Z-2	X0 Y41.75 ; tool 0
G10 P0 Z{-0.79+global.scaleFlex} X{global.T0XOffset} Y{global.T0YOffset} ; tool 0
G10 P1 Z{-1.03+global.scaleFlex} X{global.T1XOffset} Y{global.T1YOffset} ; tool 1
G10 P2 Z{-2.87+global.scaleFlex} X{global.T2XOffset} Y{global.T2YOffset} ; tool 2
G10 P3 Z{-2.87+global.scaleFlex} X{global.T3XOffset} Y{global.T3YOffset} ; tool 3
G10 P4 Z{-2.87+0.18+global.scaleFlex} X{global.T4XOffset} Y{global.T4YOffset} ; tool 4
; G10		P1 	Z-2	X0 Y32.75  ; tool 1
;G10		P1 	Z-0.35	X6.9 Y41.7  ; tool 1, etc.