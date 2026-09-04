AmoebatronsRevengeLayout:
	DEFB 22,0,0,0,0,0,0,0	;Attributes
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,22,0,0,22
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
	DEFB 22,0,0,66,66,0,0,66
	DEFB 66,66,0,0,66,66,66,66
	DEFB 66,66,66,66,0,0,66,66
	DEFB 66,0,0,66,66,66,66,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,66,66,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,66,66,66,66
	DEFB 66,66,66,66,0,0,66,66
	DEFB 66,0,0,66,66,0,0,22
	DEFB 22,0,0,66,66,0,0,66
	DEFB 66,66,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,66,66,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,66,66,0,0,66
	DEFB 66,66,0,0,66,66,66,66
	DEFB 66,66,66,66,0,0,66,66
	DEFB 66,0,0,66,66,0,0,22
	DEFB 22,66,66,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 66,66,66,66,66,66,66,66
	DEFB 66,66,66,66,66,66,66,66
	DEFB 66,66,66,66,66,66,66,66
	DEFB 66,66,66,66,66,66,66,66
	DEFM "      Amoebatrons' Revenge      "	;Cavern name
	DEFB 0,0,0,0,0,0,0,0,0	;Background
	DEFB 66,255,255,219,110,197,64,0,0	;Floor
	DEFB 2,255,219,165,36,82,32,8,0	;Crumbling floor (unused)
	DEFB 22,255,129,129,255,255,129,129,255	;Wall
	DEFB 4,240,102,240,102,0,153,255,0	;Conveyor (unused)
	DEFB 68,68,40,148,81,53,214,88,16	;Nasty 1 (unused)
	DEFB 5,126,60,28,24,24,8,8,8	;Nasty 2 (unused)
	DEFB 0,0,0,0,0,0,0,0,0	;Extra (unused)
	DEFB 208	;Pixel y-coordinate * 2 (see 32872)
	DEFB 3	;Animation frame (see 32873)
	DEFB 1	;Direction and movement flags: facing left (see 32874)
	DEFB 0	;Airborne status indicator (see 32875)
	DEFW 23997	;Location in the attribute buffer at 23552: (13,29) (see 32876)
	DEFB 0	;Jumping animation counter (see 32878)
	DEFB 1	;Direction (right)
	DEFW 30759	;Location in the screen buffer at 28672: (9,7)
	DEFB 3	;Length
	DEFB 1	;Border colour
	DEFB 0	;Vertical Jump Apex Pause (0 = default VERTICAL_JUMP_APEX_PAUSE)
	DEFB 3	;Item 1 at (1,16)
	DEFW 23600
	DEFB 96
	DEFB 255
	DEFB 255,255,255,255,255	;Item 2 (unused)
	DEFB 0,255,255,255,255	;Item 3 (unused)
	DEFB 0,255,255,255,255	;Item 4 (unused)
	DEFB 0,255,255,255,255	;Item 5 (unused)
	DEFB 255	;Terminator
	DEFB 14	;Attribute
	DEFB 255,255,128,1,176,13,160,5	;Graphic data
	DEFB 170,85,170,85,170,85,170,85
	DEFB 170,85,170,85,170,85,170,85
	DEFB 160,5,176,13,128,1,255,255
	DEFW 23581	;Location in the attribute buffer at 23552: (0,29)
	DEFW 24605	;Location in the screen buffer at 24576: (0,29)
	DEFB 48,72,136,144,104,4,10,4	;Item graphic data
	DEFB 63	;Air
	DEFB 128	;Game clock
	DEFB 196	;Horizontal guardian 1: y=3, initial x=12, 12<=x<=18, speed=slow
	DEFW 23660
	DEFB 96
	DEFB 0
	DEFB 108
	DEFB 114
	DEFB 133	;Horizontal guardian 2: y=10, initial x=16, 12<=x<=17, speed=slow
	DEFW 23888
	DEFB 104
	DEFB 0
	DEFB 76
	DEFB 81
	DEFB 67	;Horizontal guardian 3: y=6, initial x=16, 12<=x<=17, speed=normal
	DEFW 23760
	DEFB 96
	DEFB 0
	DEFB 204
	DEFB 209
	DEFB 6	;Horizontal guardian 4: y=13, initial x=16, 12<=x<=18, speed=normal
	DEFW 23984
	DEFB 104
	DEFB 7
	DEFB 172
	DEFB 178
	DEFB 255	;Terminator
	DEFB 0	;Air speed preset (0 = default DEFAULT_AIR_SPEED_PRESET)
	DEFB 0	;Unused
	DEFB 67	;Vertical guardian 1: x=5, initial y=8, 5<=y<104, initial y-increment=3
	DEFB 0
	DEFB 8
	DEFB 5
	DEFB 3
	DEFB 5
	DEFB 104
	DEFB 4	;Vertical guardian 2: x=10, initial y=8, 5<=y<104, initial y-increment=2
	DEFB 1
	DEFB 8
	DEFB 10
	DEFB 2
	DEFB 5
	DEFB 104
	DEFB 5	;Vertical guardian 3: x=20, initial y=8, 5<=y<104, initial y-increment=4
	DEFB 2
	DEFB 8
	DEFB 20
	DEFB 4
	DEFB 5
	DEFB 104
	DEFB 6	;Vertical guardian 4: x=25, initial y=8, 5<=y<104, initial y-increment=1
	DEFB 3
	DEFB 8
	DEFB 25
	DEFB 1
	DEFB 5
	DEFB 104
	DEFB 255	;Terminator
	DEFB 0,0,0,0,0,0	;Unused
	DEFB 3,192,14,112,19,200,49,140	;Guardian graphic data
	DEFB 57,156,95,250,141,178,132,164
	DEFB 73,36,41,18,36,137,66,73
	DEFB 130,82,4,144,8,136,0,64
	DEFB 3,192,14,112,19,200,49,140
	DEFB 57,156,95,250,77,177,133,17
	DEFB 132,146,72,164,41,36,41,18
	DEFB 68,137,2,72,2,80,4,0
	DEFB 3,192,14,112,19,200,49,140
	DEFB 57,156,95,250,77,177,68,145
	DEFB 130,73,130,74,68,148,37,36
	DEFB 41,34,8,144,4,72,0,64
	DEFB 3,192,14,112,19,200,49,140
	DEFB 57,156,95,250,77,178,41,18
	DEFB 36,145,66,73,130,74,132,74
	DEFB 72,145,9,32,9,0,0,128
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
