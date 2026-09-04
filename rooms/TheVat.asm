TheVatLayout:
	DEFB 77,0,0,0,0,0,0,0	;Attributes
	DEFB 0,0,0,0,0,0,77,77
	DEFB 77,77,77,77,77,77,77,77
	DEFB 77,77,77,77,77,77,77,77
	DEFB 77,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,77
	DEFB 77,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,77
	DEFB 77,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,70
	DEFB 70,77,2,2,2,2,2,2
	DEFB 2,2,2,2,2,2,0,77
	DEFB 77,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,77,2,2,2,2,2,2
	DEFB 2,2,2,2,2,2,2,77
	DEFB 77,0,0,0,0,0,0,4
	DEFB 4,4,4,4,0,0,70,70
	DEFB 70,77,2,2,2,2,2,2
	DEFB 2,2,2,2,22,2,2,77
	DEFB 77,70,70,70,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,77,2,2,0,2,2,2
	DEFB 2,2,2,2,2,2,2,77
	DEFB 77,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,77,2,2,2,2,2,2
	DEFB 2,2,2,0,2,2,2,77
	DEFB 77,70,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,77,2,2,2,2,2,22
	DEFB 2,2,2,2,2,2,2,77
	DEFB 77,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,70,70
	DEFB 70,77,2,2,2,2,2,2
	DEFB 2,2,2,2,2,2,2,77
	DEFB 77,70,70,70,70,70,70,70
	DEFB 70,70,70,70,0,0,0,0
	DEFB 0,77,2,0,2,2,2,2
	DEFB 2,2,2,2,22,2,2,77
	DEFB 77,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,77,2,2,2,2,2,2
	DEFB 2,2,2,2,2,2,0,77
	DEFB 77,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,77,77
	DEFB 77,77,2,2,2,2,2,22
	DEFB 2,2,2,2,2,2,2,77
	DEFB 77,0,0,0,0,0,0,0
	DEFB 0,70,70,70,0,0,77,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,77
	DEFB 77,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,77,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,77
	DEFB 77,70,70,70,70,70,70,70
	DEFB 70,70,70,70,70,70,77,77
	DEFB 77,77,77,77,77,77,77,77
	DEFB 77,77,77,77,77,77,77,77
	
	DEFM "            The Vat             "	;Cavern name
	
	DEFB 0,0,0,0,0,0,0,0,0	;Background
	DEFB 70,255,255,219,110,197,64,0,0	;Floor
	DEFB 2,255,170,85,170,85,170,85,170	;Crumbling floor
	DEFB 77,34,255,136,255,34,255,136,255	;Wall
	DEFB 4,244,102,244,0,0,0,0,0	;Conveyor
	DEFB 21,68,40,148,81,53,214,88,16	;Nasty 1 (unused)
	DEFB 22,165,66,60,219,60,126,165,36	;Nasty 2
	DEFB 0,0,0,0,0,0,0,0,0	;Extra (unused)
	
	DEFB 208	;Pixel y-coordinate * 2 (see 32872)
	DEFB 0	;Animation frame (see 32873)
	DEFB 0	;Direction and movement flags: facing right (see 32874)
	DEFB 0	;Airborne status indicator (see 32875)
	DEFW 23970	;Location in the attribute buffer at 23552: (13,2) (see 32876)
	DEFB 0	;Jumping animation counter (see 32878)
	
	DEFB 0	;Direction (left)
	DEFW 28839	;Location in the screen buffer at 28672: (5,7)
	DEFB 5	;Length
	
	DEFB 4	;Border colour
	
	DEFB 0	;Vertical Jump Apex Pause (0 = default VERTICAL_JUMP_APEX_PAUSE)
	
	DEFB 3	;Item 1 at (3,30)
	DEFW 23678
	DEFB 96
	DEFB 255
	DEFB 4	;Item 2 at (6,20)
	DEFW 23764
	DEFB 96
	DEFB 255
	DEFB 5	;Item 3 at (7,27)
	DEFW 23803
	DEFB 96
	DEFB 255
	DEFB 6	;Item 4 at (10,19)
	DEFW 23891
	DEFB 104
	DEFB 255
	DEFB 3	;Item 5 at (11,30)
	DEFW 23934
	DEFB 104
	DEFB 255
	DEFB 255	;Terminator
	
	DEFB 11	;Attribute
	DEFB 255,255,129,129,129,129,129,129	;Graphic data
	DEFB 129,129,129,129,129,129,255,255
	DEFB 255,255,129,129,129,129,129,129
	DEFB 129,129,129,129,129,129,255,255
	DEFW 23983	;Location in the attribute buffer at 23552: (13,15)
	DEFW 26799	;Location in the screen buffer at 24576: (13,15)
				
	DEFB 48,72,136,144,104,4,10,4	;Item graphic data
	
	DEFB 63	;Air
	
	DEFB 128 ;Game clock
	
	DEFB 69	;Horizontal guardian 1: y=1, initial x=15, 15<=x<=29, speed=normal
	DEFW 23599
	DEFB 96
	DEFB 0
	DEFB 47
	DEFB 61
	DEFB 67	;Horizontal guardian 2: y=8, initial x=10, 2<=x<=10, speed=normal
	DEFW 23818
	DEFB 104
	DEFB 7
	DEFB 2
	DEFB 10
	DEFB 6	;Horizontal guardian 3: y=13, initial x=17, 17<=x<=29, speed=normal
	DEFW 23985
	DEFB 104
	DEFB 0
	DEFB 177
	DEFB 189
	DEFB 255,0,0,0,0,0,0 ;Horizontal guardian 4 (unused)
	DEFB 255	;Terminator
	
	DEFB 0,0	;Unused
	
	DEFB 255,0,0,0,0,0,0	;Vertical guardian 1 (unused)
	DEFB 0,0,0,0,0,0,0	;Vertical guardian 2 (unused)
	DEFB 0,0,0,0,0,0,0	;Vertical guardian 3 (unused)
	DEFB 0,0,0,0,0,0,0	;Vertical guardian 4 (unused)
	
	DEFB 0,0,0,0,0,0,0	;Unused
	
    DEFB 24,0,28,0,10,128,15,128
	DEFB 12,0,28,0,30,0,29,0
	DEFB 60,0,62,0,62,0,110,0
	DEFB 68,0,66,0,129,0,0,0
	DEFB 0,0,0,0,6,0,7,0
	DEFB 2,160,3,224,3,128,7,0
	DEFB 7,128,7,64,15,0,15,128
	DEFB 15,128,27,128,51,0,64,192
	DEFB 0,0,0,0,0,0,0,0
	DEFB 1,128,1,192,0,168,0,248
	DEFB 0,224,1,192,1,224,1,208
	DEFB 3,192,3,224,7,224,62,248
	DEFB 0,0,0,0,0,96,0,112
	DEFB 0,42,0,62,0,56,0,112
	DEFB 0,120,0,116,0,240,0,248
	DEFB 1,248,1,176,3,12,4,0
	DEFB 0,0,0,0,6,0,14,0
	DEFB 84,0,124,0,28,0,14,0
	DEFB 30,0,46,0,15,0,31,0
	DEFB 31,128,13,128,48,192,0,32
	DEFB 0,0,0,0,0,0,0,0
	DEFB 1,128,3,128,21,0,31,0
	DEFB 7,0,3,128,7,128,11,128
	DEFB 3,192,7,192,7,224,31,124
	DEFB 0,0,0,0,0,96,0,224
	DEFB 5,64,7,192,1,192,0,224
	DEFB 1,224,2,224,0,240,1,240
	DEFB 1,240,1,216,0,204,3,2
	DEFB 0,24,0,56,1,80,1,240
	DEFB 0,48,0,56,0,120,0,184
	DEFB 0,60,0,124,0,124,0,118
	DEFB 0,34,0,66,0,129,0,0
