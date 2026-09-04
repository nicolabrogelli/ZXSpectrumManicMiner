WackyAmoebatronsLayout:
	DEFB 22,0,0,22,0,0,0,0	;Attributes
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
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,6,6,6,6,0,0,6
	DEFB 6,6,0,0,6,6,6,6
	DEFB 6,6,6,6,0,0,6,6
	DEFB 6,0,0,6,6,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,6,6,22
	DEFB 22,0,0,6,6,0,0,6
	DEFB 6,6,0,0,4,4,4,4
	DEFB 4,4,4,4,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,6,6
	DEFB 6,0,0,6,6,0,0,22
	DEFB 22,6,6,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,6,6,0,0,6
	DEFB 6,6,0,0,6,6,6,6
	DEFB 6,6,6,6,0,0,6,6
	DEFB 6,0,0,6,6,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,6,6,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,6,6,6,6,6,6,6
	DEFB 6,6,6,6,6,6,6,6
	DEFB 6,6,6,6,6,6,6,6
	DEFB 6,6,6,6,6,6,6,22
	
	DEFM "        Wacky Amoebatrons       "	;Cavern name
	
	DEFB 0,0,0,0,0,0,0,0,0	;Background
	DEFB 6,255,255,219,110,197,64,0,0	;Floor
	DEFB 66,255,219,165,36,82,32,8,0	;Crumbling floor (unused)
	DEFB 22,90,90,90,90,90,90,90,90	;Wall
	DEFB 4,240,102,240,102,0,0,0,0	;Conveyor
	DEFB 68,68,40,148,81,53,214,88,16	;Nasty 1 (unused)
	DEFB 5,126,60,28,24,24,8,8,8	;Nasty 2 (unused)
	DEFB 0,0,0,0,0,0,0,0,0	;Extra (unused)
	
	DEFB 208	;Pixel y-coordinate * 2 (see 32872)
	DEFB 0	;Animation frame (see 32873)
	DEFB 0	;Direction and movement flags: facing right (see 32874)
	DEFB 0	;Airborne status indicator (see 32875)
	DEFW 23969	;Location in the attribute buffer at 23552: (13,1) (see 32876)
	DEFB 0	;Jumping animation counter (see 32878)
	
	DEFB 1	;Direction (right)
	DEFW 30732	;Location in the screen buffer at 28672: (8,12)
	DEFB 8	;Length
	
	DEFB 1	;Border colour
	
	DEFB 0	;Vertical Jump Apex Pause (0 = default VERTICAL_JUMP_APEX_PAUSE)
	
	DEFB 3	;Item 1 at (1,16)
	DEFW 23600
	DEFB 96
	DEFB 255
	DEFB 255,255,255,255,255	;Item 2 (unused)
	DEFB 255,255,255,255,255	;Item 3 (unused)
	DEFB 255,255,255,255,255	;Item 4 (unused)
	DEFB 255,255,255,255,255	;Item 5 (unused)
	DEFB 255	;Terminator
	
	DEFB 14	;Attribute
	DEFB 255,255,128,1,129,129,130,65	;Graphic data
	DEFB 132,33,136,17,144,9,161,133
	DEFB 161,133,144,9,136,17,132,33
	DEFB 130,65,129,129,128,1,255,255
	DEFW 23553	;Location in the attribute buffer at 23552: (0,1)
	DEFW 24577	;Location in the screen buffer at 24576: (0,1)
	
	DEFB 48,72,136,144,104,4,10,4	;Item graphic data
	
	DEFB 63	;Air
	
	DEFB 128 ;Game clock
	
	DEFB 68	;Horizontal guardian 1: y=3, initial x=12, 12<=x<=18, speed=normal
	DEFW 23660
	DEFB 96
	DEFB 0
	DEFB 108
	DEFB 114
	DEFB 133	;Horizontal guardian 2: y=10, initial x=16, 12<=x<=18, speed=slow
	DEFW 23888
	DEFB 104
	DEFB 0
	DEFB 76
	DEFB 82
	DEFB 0,0,0,0,0,0,0	;Horizontal guardian 3 (unused)
	DEFB 0,0,0,0,0,0,0	;Horizontal guardian 4 (unused)
	DEFB 255	;Terminator
	
	DEFB 0,0	;Unused
	
	DEFB 67	;Vertical guardian 1: x=5, initial y=8, 5<=y<100, initial y-increment=1
	DEFB 0
	DEFB 8
	DEFB 5
	DEFB 1
	DEFB 5
	DEFB 100
	DEFB 4	;Vertical guardian 2: x=10, initial y=8, 5<=y<100, initial y-increment=2
	DEFB 1
	DEFB 8
	DEFB 10
	DEFB 2
	DEFB 5
	DEFB 100
	DEFB 5	;Vertical guardian 3: x=20, initial y=8, 5<=y<100, initial y-increment=1
	DEFB 2
	DEFB 8
	DEFB 20
	DEFB 1
	DEFB 5
	DEFB 100
	DEFB 66	;Vertical guardian 4: x=25, initial y=8, 5<=y<100, initial y-increment=2
	DEFB 3
	DEFB 8
	DEFB 25
	DEFB 2
	DEFB 5
	DEFB 100
	DEFB 255	;Terminator
	
	DEFB 0,0,0,0,0,0	;Unused
	
	DEFB 10,32,22,104,1,80,57,98	;Guardian graphic data
	DEFB 101,206,3,208,255,238,135,241
	DEFB 119,228,199,255,139,241,50,172
	DEFB 100,166,73,162,18,144,54,152
	DEFB 0,0,5,32,3,64,49,116
	DEFB 29,204,3,208,63,236,7,244
	DEFB 63,224,103,252,11,242,50,172
	DEFB 36,164,11,144,26,216,0,192
	DEFB 0,0,0,0,2,32,9,96
	DEFB 5,200,3,208,31,224,7,248
	DEFB 31,224,23,248,15,240,18,168
	DEFB 5,160,10,176,0,192,0,0
	DEFB 0,0,5,32,3,64,49,116
	DEFB 29,204,3,208,63,236,7,244
	DEFB 63,224,103,252,11,242,50,172
	DEFB 36,164,11,144,26,216,0,192
	DEFB 12,0,12,0,12,0,12,0
	DEFB 12,0,12,0,12,0,12,0
	DEFB 12,0,12,0,255,192,12,0
	DEFB 97,128,210,192,179,64,97,128
	DEFB 3,0,3,0,3,0,3,0
	DEFB 3,0,3,0,3,0,3,0
	DEFB 3,0,3,0,63,240,3,0
	DEFB 24,96,36,208,60,208,24,96
	DEFB 0,192,0,192,0,192,0,192
	DEFB 0,192,0,192,0,192,0,192
	DEFB 0,192,0,192,15,252,0,192
	DEFB 6,24,11,52,13,44,6,24
	DEFB 0,48,0,48,0,48,0,48
	DEFB 0,48,0,48,0,48,0,48
	DEFB 0,48,0,48,3,255,0,48
	DEFB 1,134,2,77,3,205,1,134
