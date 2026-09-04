ProcessingPlantLayout:
	DEFB 22,0,0,0,0,0,0,0	;Attributes
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,6,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 68,68,68,0,0,0,0,68
	DEFB 68,0,0,0,0,68,68,68
	DEFB 68,68,0,0,0,0,0,22
	DEFB 22,0,0,68,68,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,68,68,68,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,68
	DEFB 68,68,68,68,0,0,0,22
	DEFB 22,68,68,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,0,0,0,0,68
	DEFB 68,68,68,68,68,68,68,68
	DEFB 22,68,68,68,68,68,68,68
	DEFB 68,68,0,0,0,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 22,6,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,67,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,68,68,68,22
	DEFB 22,0,0,5,5,5,5,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,68,68
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,68,68,68,68,68,68,68
	DEFB 68,68,68,68,68,68,68,68
	DEFB 68,68,68,68,68,68,68,68
	DEFB 68,68,68,68,68,68,68,22

	DEFM "       Processing Plant         "	;Cavern name

	DEFB 0,0,0,0,0,0,0,0,0						;Background
	DEFB 68,255,255,153,153,255,153,102,0		;Floor
	DEFB 4,255,219,165,36,82,32,8,0	            ;Crumblingfloor (unused)
	DEFB 22,255,153,255,102,255,153,255,102		;Wall
	DEFB 5,240,102,240,102,0,153,255,0			;Conveyor
	DEFB 67,68,40,148,81,53,214,88,16			;Nasty 1
	DEFB 6,60,24,189,231,231,189,24,60			;Nasty 2
	DEFB 0,0,0,0,0,0,0,0,0						;Extra (unused)

	DEFB 48										;Pixel y-coordinate * 2 (see 32872)
	DEFB 3										;Animation frame (see 32873)
	DEFB 1										;Direction and movement flags: facing left (see 32874)
	DEFB 0										;Airborne status indicator (see 32875)
	DEFW 23663									;Location in the attribute buffer at 23552: (3,15) (see 32876)
	DEFB 0										;Jumping animation counter (see 32878)

	DEFB 0										;Direction (left)
	DEFW 30883									;Location in the screen buffer at 28672: (13,3)
	DEFB 4										;Length

	DEFB 2										;Border colour
												;
	DEFB 0										;Vertical Jump Apex Pause (0 = default VERTICAL_JUMP_APEX_PAUSE)

	DEFB 3		;Item 1 at (6,15)
	DEFW 23759
	DEFB 96
	DEFB 255
	DEFB 4		;Item 2 at (6,17)
	DEFW 23761
	DEFB 96
	DEFB 255
	DEFB 5		;Item 3 at (7,30)
	DEFW 23806
	DEFB 96
	DEFB 255
	DEFB 6		;Item 4 at (10,1)
	DEFW 23873
	DEFB 104
	DEFB 255
	DEFB 3		;Item 5 at (11,13)
	DEFW 23917
	DEFB 104
	DEFB 255
	DEFB 255	;Terminator

	DEFB 14		;Attribute
	DEFB 255,255,129,129,191,253,191,253	;Graphic data
	DEFB 176,13,176,13,176,13,240,15
	DEFB 240,15,176,13,176,13,176,13
	DEFB 191,253,191,253,129,129,255,255
	DEFW 23581	;Location in the attribute buffer at 23552: (0,29)
	DEFW 24605	;Location in the screen buffer at 24576: (0,29)

	DEFB 48,72,136,144,104,4,10,4	;Item graphic data

	DEFB 63		;Air

	DEFB 128	;Game clock
	
	DEFB 70	;Horizontal guardian 1: y=8, initial x=6, 6<=x<=13, speed=normal
	DEFW 23814
	DEFB 104
	DEFB 0
	DEFB 6
	DEFB 13
	DEFB 67	;Horizontal guardian 2: y=8, initial x=14, 14<=x<=21, speed=normal
	DEFW 23822
	DEFB 104
	DEFB 1
	DEFB 14
	DEFB 21
	DEFB 69	;Horizontal guardian 3: y=13, initial x=8, 8<=x<=20, speed=normal
	DEFW 23976
	DEFB 104
	DEFB 2
	DEFB 168
	DEFB 180
	DEFB 6	;Horizontal guardian 4: y=13, initial x=24, 24<=x<=29, speed=normal
	DEFW 23992
	DEFB 104
	DEFB 3
	DEFB 184
	DEFB 189
	DEFB 255	;Terminator
	
	DEFB 0	;Air speed preset (0 = default DEFAULT_AIR_SPEED_PRESET)
	DEFB 0	;Unused

	DEFB 255,0,0,0,0,0,0	;Vertical guardian 1 (unused)
	DEFB 0,0,0,0,0,0,0		;Vertical guardian 2 (unused)
	DEFB 0,0,0,0,0,0,0		;Vertical guardian 3 (unused)
	DEFB 0,0,0,0,0,0,0		;Vertical guardian 4 (unused)
	
	DEFB 0,0,0,0,0,0,0	;Unused
	
	DEFB 31,0,127,192,115,224,243,128	;Guardian graphic data
	DEFB 254,0,248,0,254,0,255,128
	DEFB 127,224,127,192,31,0,10,0
	DEFB 10,0,10,0,10,0,31,0
	DEFB 7,192,31,240,30,112,62,120
	DEFB 63,248,62,0,63,248,63,248
	DEFB 31,240,31,240,7,192,2,128
	DEFB 2,128,7,192,0,0,0,0
	DEFB 1,240,7,252,7,62,15,56
	DEFB 15,224,15,128,15,224,15,248
	DEFB 7,254,7,252,1,240,1,240
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,124,1,207,1,206,3,252
	DEFB 3,240,3,224,3,240,3,252
	DEFB 1,254,1,255,0,124,0,40
	DEFB 0,40,0,124,0,0,0,0
	DEFB 62,0,243,128,115,128,63,192
	DEFB 15,192,7,192,15,192,63,192
	DEFB 127,128,255,128,62,0,20,0
	DEFB 20,0,62,0,0,0,0,0
	DEFB 15,128,63,224,124,224,28,240
	DEFB 7,240,1,240,7,240,31,240
	DEFB 127,224,63,224,15,128,15,128
	DEFB 0,0,0,0,0,0,0,0
	DEFB 3,224,15,248,14,120,30,124
	DEFB 31,252,0,124,31,252,31,252
	DEFB 15,248,15,248,3,224,1,64
	DEFB 1,64,3,224,0,0,0,0
	DEFB 0,248,3,254,7,206,1,207
	DEFB 0,127,0,31,0,127,1,255
	DEFB 7,254,3,254,0,248,0,80
	DEFB 0,80,0,80,0,80,0,248
