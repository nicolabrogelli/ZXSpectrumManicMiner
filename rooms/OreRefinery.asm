OreRefineryLayout:
	DEFB 22,22,22,22,22,22,22,22	;Attributes
	DEFB 22,22,22,22,22,22,22,22
	DEFB 22,22,22,22,22,22,22,22
	DEFB 22,22,22,22,22,22,22,22
	DEFB 22,0,0,6,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,6,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,6,0,0,0,5
	DEFB 5,5,5,5,5,5,5,5
	DEFB 5,5,5,5,5,5,5,5
	DEFB 5,0,0,5,5,5,5,22
	DEFB 22,0,0,6,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,6,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,6,0,0,0,5
	DEFB 5,0,0,5,5,5,5,0
	DEFB 0,5,5,5,5,5,0,0
	DEFB 5,5,5,5,0,0,5,22
	DEFB 22,0,0,6,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,6,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,6,0,0,0,5
	DEFB 5,5,5,5,0,0,5,5
	DEFB 5,0,0,0,5,5,5,5
	DEFB 5,0,0,5,5,5,5,22
	DEFB 22,0,0,6,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,6,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,6,0,0,0,5
	DEFB 5,5,0,0,5,5,5,0
	DEFB 0,5,5,5,5,0,0,5
	DEFB 5,5,5,0,0,5,5,22
	DEFB 22,0,0,6,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,6,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,5,5,4,4,4,4,4
	DEFB 4,4,4,4,4,4,4,4
	DEFB 4,4,4,4,4,4,4,4
	DEFB 4,4,4,4,4,5,5,22
	
	DEFM "          Ore Refinery          "	;Cavern name
	
	DEFB 0,0,0,0,0,0,0,0,0	;Background
	DEFB 5,255,255,17,34,68,136,255,255	;Floor
	DEFB 66,255,219,165,36,82,32,8,0	;Crumbling floor (unused)
	DEFB 22,90,90,90,90,90,90,90,90	;Wall
	DEFB 4,240,102,240,102,0,0,0,0	;Conveyor
	DEFB 68,68,40,148,81,53,214,88,16	;Nasty 1 (unused)
	DEFB 69,126,60,28,24,24,8,8,8	;Nasty 2 (unused)
	DEFB 6,255,129,129,129,129,129,129,129	;Extra
	
	DEFB 208	;Pixel y-coordinate * 2 (see 32872)
	DEFB 0	;Animation frame (see 32873)
	DEFB 0	;Direction and movement flags: facing right (see 32874)
	DEFB 0	;Airborne status indicator (see 32875)
	DEFW 23997	;Location in the attribute buffer at 23552: (13,29) (see 32876)
	DEFB 0	;Jumping animation counter (see 32878)
	
	DEFB 1	;Direction (right)
	DEFW 30947	;Location in the screen buffer at 28672: (15,3)
	DEFB 26	;Length
	
	DEFB 1	;Border colour
	
	DEFB 0	;Unused
	
	DEFB 3	;Item 1 at (3,26)
	DEFW 23674
	DEFB 96
	DEFB 255
	DEFB 4	;Item 2 at (6,10)
	DEFW 23754
	DEFB 96
	DEFB 255
	DEFB 5	;Item 3 at (9,19)
	DEFW 23859
	DEFB 104
	DEFB 255
	DEFB 6	;Item 4 at (9,26)
	DEFW 23866
	DEFB 104
	DEFB 255
	DEFB 3	;Item 5 at (12,11)
	DEFW 23947
	DEFB 104
	DEFB 255
	DEFB 255	;Terminator
	
	DEFB 79	;Attribute
	DEFB 3,192,7,224,15,240,9,144	;Graphic data
	DEFB 9,144,7,224,5,160,2,64
	DEFB 97,134,248,31,254,127,5,224
	DEFB 7,160,254,127,248,31,96,6
	DEFW 23969	;Location in the attribute buffer at 23552: (13,1)
	DEFW 26785	;Location in the screen buffer at 24576: (13,1)
	
	DEFB 24,110,66,219,201,98,126,24	;Item graphic data
	
	DEFB 63	;Air
	
	DEFB 252	;Game clock
	
	DEFB 67	;Horizontal guardian 1: y=1, initial x=7, 7<=x<=29, speed=normal
	DEFW 23591
	DEFB 96
	DEFB 0
	DEFB 39
	DEFB 61
	DEFB 196	;Horizontal guardian 2: y=4, initial x=16, 7<=x<=29, speed=slow
	DEFW 23696
	DEFB 96
	DEFB 0
	DEFB 135
	DEFB 157
	DEFB 70	;Horizontal guardian 3: y=7, initial x=20, 10<=x<=26, speed=normal
	DEFW 23796
	DEFB 96
	DEFB 7
	DEFB 234
	DEFB 250
	DEFB 194	;Horizontal guardian 4: y=10, initial x=18, 7<=x<=29, speed=slow
	DEFW 23890
	DEFB 104
	DEFB 0
	DEFB 71
	DEFB 93
	DEFB 255	;Terminator
	
	DEFB 0,0	;Unused
	
	DEFB 71	;Vertical guardian 1: x=5, initial y=8, 8<=y<100, initial y-increment=2
	DEFB 0
	DEFB 8
	DEFB 5
	DEFB 2
	DEFB 8
	DEFB 100
	DEFB 255,0,0,0,0,0,0	;Vertical guardian 2 (unused)
	DEFB 0,0,0,0,0,0,0	;Vertical guardian 3 (unused)
	DEFB 0,0,0,0,0,0,0	;Vertical guardian 4 (unused)
	
	DEFB 0,0,0,0,0,0,0	;Unused
	
	DEFB 0,0,0,0,0,0,3,192	;Guardian graphic data
	DEFB 12,48,16,8,32,4,64,2
	DEFB 128,1,64,2,32,4,208,11
	DEFB 44,52,75,210,18,72,2,64
	DEFB 0,0,0,0,0,0,3,192
	DEFB 12,48,16,8,32,4,64,2
	DEFB 248,31,87,234,43,212,18,72
	DEFB 12,48,3,192,0,0,0,0
	DEFB 4,32,4,32,18,72,75,210
	DEFB 44,52,147,201,167,229,70,98
	DEFB 134,97,71,226,35,196,16,8
	DEFB 12,48,3,192,0,0,0,0
	DEFB 0,0,0,0,0,0,3,192
	DEFB 12,48,18,72,42,84,95,250
	DEFB 246,127,71,226,35,196,16,8
	DEFB 12,48,3,192,0,0,0,0
	DEFB 97,128,178,64,179,192,97,128
	DEFB 12,0,255,192,82,128,18,0
	DEFB 18,0,30,0,12,0,12,0
	DEFB 12,0,12,0,30,0,63,0
	DEFB 24,96,36,208,60,208,24,96
	DEFB 3,0,63,240,20,160,4,128
	DEFB 4,128,7,128,3,0,3,0
	DEFB 7,128,15,192,0,0,0,0
	DEFB 6,24,13,60,13,36,6,24
	DEFB 0,192,15,252,5,40,1,32
	DEFB 1,32,1,224,1,224,3,240
	DEFB 0,0,0,0,0,0,0,0
	DEFB 1,134,3,203,2,75,1,134
	DEFB 0,48,3,255,1,74,0,72
	DEFB 0,72,0,120,0,48,0,48
	DEFB 0,120,0,252,0,0,0,0
