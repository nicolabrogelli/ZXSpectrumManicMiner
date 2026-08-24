;===========================================================================
; TheMenagerie.asm  
;
; Manic Miner Room 02: The Menagerie (1024 Bytes total)
;
; TheMenagerieLayout            Size 512 Byte, Start Byte   0 (Offset 0)
; TheMenagerieTile              Size  32 Byte, Start Byte 512 (Offset 512)
; TheMenagerieBackground        Size   9 Byte, Start Byte 544 (Offset 544)
; TheMenagerieFloor             Size   9 Byte, Start Byte 553 (Offset 553)
; TheMenagerieCrumblingFloor    Size   9 Byte, Start Byte 562 (Offset 562)
; TheMenagerieWall              Size   9 Byte, Start Byte 571 (Offset 571)
; TheMenagerieConveyor          Size   9 Byte, Start Byte 580 (Offset 580)
; TheMenagerieNasty1            Size   9 Byte, Start Byte 589 (Offset 589)
; TheMenagerieNasty2            Size   9 Byte, Start Byte 598 (Offset 598)
; TheMenagerieExtra             Size   9 Byte, Start Byte 607 (Offset 607)
; TheMenagerieWillyPos          Size   7 Byte, Start Byte 616 (Offset 616)
; TheMenagerieConveyorData      Size   4 Byte, Start Byte 623 (Offset 623)
; TheMenagerieBorderColor       Size   1 Byte, Start Byte 627 (Offset 627)
; TheMenagerieUnused1           Size   1 Byte, Start Byte 628 (Offset 628)
; TheMenagerieItems             Size  26 Byte, Start Byte 629 (Offset 629)
; TheMenageriePortal            Size  37 Byte, Start Byte 655 (Offset 655)
; TheMenagerieItemGraphic       Size   8 Byte, Start Byte 692 (Offset 692)
; TheMenagerieInitialAir        Size   1 Byte, Start Byte 700 (Offset 700)
; TheMenagerieGameClock         Size   1 Byte, Start Byte 701 (Offset 701)
; TheMenagerieHGuardians        Size  29 Byte, Start Byte 702 (Offset 702)
; TheMenagerieUnused2           Size   2 Byte, Start Byte 731 (Offset 731)
; TheMenagerieVGuardians        Size   1 Byte, Start Byte 733 (Offset 733)
; TheMenagerieUnused3           Size   2 Byte, Start Byte 734 (Offset 734)
; TheMenagerieGraphicElement    Size  32 Byte, Start Byte 736 (Offset 736)
; TheMenagerieGraphicGuardian   Size 256 Byte, Start Byte 768 (Offset 768)
;
;===========================================================================

; Room layout for Room 0 (The Cold Room)
; The first 512 bytes are the attributes that define the layout of the cavern.
TheMenagerieLayout:
	DEFB 13,0,0,0,0,0,0,0	;Attributes
	DEFB 0,0,67,0,0,0,0,0
	DEFB 0,0,3,0,0,0,0,0
	DEFB 0,0,0,67,0,0,0,13
	DEFB 13,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,67,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,13
	DEFB 13,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,13
	DEFB 13,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,13
	DEFB 13,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,13
	DEFB 13,69,69,69,69,5,5,5
	DEFB 5,5,5,5,5,5,5,5
	DEFB 5,5,5,5,5,5,5,5
	DEFB 5,5,5,5,5,5,5,13
	DEFB 13,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,13
	DEFB 13,69,69,69,69,69,69,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,69,69,69,69,13
	DEFB 13,3,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,13
	DEFB 13,3,0,0,0,0,2,2
	DEFB 2,2,2,2,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,13
	DEFB 13,3,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,69,69,69,69,69,69,13
	DEFB 13,67,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,69,69
	DEFB 69,69,69,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,13
	DEFB 13,0,0,0,0,69,69,69
	DEFB 69,69,69,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,13
	DEFB 13,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,69,69,69
	DEFB 69,69,69,69,69,69,69,13
	DEFB 13,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,13
	DEFB 13,69,69,69,69,69,69,69
	DEFB 69,69,69,69,69,69,69,69
	DEFB 69,69,69,69,69,69,69,69
	DEFB 69,69,69,69,69,69,69,13

;The next 72 bytes  specify the room name.
TheMenagerieTile:
	DEFM "          The Menagerie         "	    ;Room name
		
; The next 72 bytes contain the attributes and graphic data for the tiles used to build the cavern.
TheMenagerieBackground:
	DEFB 0,0,0,0,0,0,0,0,0	
TheMenagerieFloor:	
	DEFB 69,255,255,102,153,102,153,255,0	
TheMenagerieCrumblingFloor:	
	DEFB 5,255,255,102,153,66,24,234,0	 
TheMenagerieWall:	
	DEFB 13,129,195,165,153,153,165,195,129	
TheMenagerieConveyor:	
	DEFB 2,240,170,240,102,102,0,0,0
TheMenagerieNasty1:	
	DEFB 6,68,40,148,81,53,214,88,16
TheMenagerieNasty2:
	DEFB 67,16,214,56,214,56,68,198,40	
TheMenagerieExtra:
	DEFB 3,16,16,16,16,16,16,16,16

; The next seven bytes specify Miner Willy's initial location and appearance in the cavern.
TheMenagerieWillyAppearanceAndPosition:
	DEFB 208		;Pixel y-coordinate * 2 (see 32872)
	DEFB 0			;Animation frame (see 32873)
	DEFB 0			;Direction and movement flags: facing right (see 32874)
	DEFB 0			;Airborne status indicator (see 32875)
	DEFW 23970		;Location in the attribute buffer at 23552: (13,2) (see 32876)
	DEFB 0			;Jumping animation counter (see 32878)
	
;The next four bytes are copied to 32879 and specify the direction, location and length of the conveyor.
TheMenagerieConveyorData:
	DEFB 1			;Direction (right)
	DEFW 30758		;Location in the screen buffer at 30819: (11,3)
	DEFB 6			;Length
	
TheMenagerieBorderColor:
	DEFB 2			;Border Color	

TheMenagerieUnused1:
	DEFB 0			;Unused	
	
;The next 25 bytes specify the location and initial colour of the items in the cavern.
TheMenagerieItems:
	DEFB 3		;Item 1 at (0,6)
	DEFW 23558
	DEFB 96
	DEFB 255
	DEFB 4		;Item 2 at (0,15)
	DEFW 23567
	DEFB 96
	DEFB 255
	DEFB 5		;Item 3 at (0,23)
	DEFW 23575
	DEFB 96
	DEFB 255
	DEFB 6		;Item 4 at (6,30)
	DEFW 23774
	DEFB 96
	DEFB 255
	DEFB 3		;Item 5 at (6,21)
	DEFW 23765
	DEFB 96
	DEFB 255
	DEFB 255
	
;The next 37 bytes define the portal graphic and its location.
TheMenageriePortal:
	DEFB 14								;Attribute
	DEFB 255,255,68,68,153,153,34,34	;Graphic data
	DEFB 34,34,153,153,68,68,68,68
	DEFB 153,153,34,34,34,34,153,153
	DEFB 68,68,68,68,153,153,255,255
	DEFW 23933							;Location in the attribute buffer at 23552: (11,29)
	DEFW 26749							;Location in the screen buffer at 24576: (11,29)


;The next eight bytes are copied to 32948 and define the item graphic.
TheMenagerieItemGraphic:
	DEFB 48,72,136,144,104,4,10,4	;Item graphic data

;The next byte is  specifies the initial air supply in the cavern.
TheMenagerieInitialAir:
	DEFB 63		;Air

;The next byte initialises the game clock.
TheMenagerieGameClock:
	DEFB 128	;Game clock

;The next 28 bytes are copied to 32958 and define the horizontal guardians.
TheMenagerieHGuardians:
	DEFB 68		;Horizontal guardian 1: y=13, initial x=19, 1<=x<=19, speed=normal
	DEFW 23987
	DEFB 104
	DEFB 7
	DEFB 161
	DEFB 179
	DEFB 67		;Horizontal guardian 2: y=3, initial x=16, 1<=x<=16, speed=normal
	DEFW 23664
	DEFB 96
	DEFB 7
	DEFB 97
	DEFB 112
	DEFB 66		;Horizontal guardian 3: y=3, initial x=18, 18<=x<=29, speed=normal
	DEFW 23666
	DEFB 96
	DEFB 0
	DEFB 114
	DEFB 125
	DEFB 255,0,0,0,0,0,0	;Horizontal guardian 4 (unused)
	DEFB 255	;Terminator

;The next two bytes are not used.
TheMenagerieUnused2:
	DEFB 0,0	;Unused

;The next byte is copied to 32989 and indicates that there are no vertical guardians in this cavern.
TheMenagerieVGuardians:
	DEFB 255	;Terminator

;The next two bytes are unused.
TheMenagerieUnused3:
	DEFB 0,0	;Unused

;The next 32 bytes define graphic.
TheMenagerieGraphicElement:
	DEFB 42,192,53,64,63,192,9,0	;Boot graphic data
	DEFB 9,0,31,128,16,128,16,128
	DEFB 17,128,34,64,32,184,89,36
	DEFB 68,66,68,2,68,2,255,255

;The next 256 bytes define the guardian graphics.
TheMenagerieGraphicGuardian:
	DEFB 3,0,6,128,7,192,3,0	;Guardian graphic data
	DEFB 1,128,0,192,190,192,227,128
	DEFB 65,0,171,0,127,0,62,0
	DEFB 8,0,8,0,8,0,20,0
	DEFB 0,192,1,160,1,240,0,192
	DEFB 0,96,0,48,47,176,56,224
	DEFB 24,192,48,192,21,192,10,128
	DEFB 21,0,2,0,5,0,0,0
	DEFB 0,48,0,104,0,124,0,48
	DEFB 0,24,0,12,11,236,14,56
	DEFB 4,16,10,176,7,240,3,224
	DEFB 0,128,1,64,0,0,0,0
	DEFB 0,12,0,26,0,31,0,172
	DEFB 1,86,0,171,3,91,3,134
	DEFB 1,12,3,252,1,252,0,248
	DEFB 0,32,0,32,0,80,0,0
	DEFB 48,0,88,0,248,0,53,0
	DEFB 106,128,213,0,218,192,97,192
	DEFB 48,128,63,192,63,128,31,0
	DEFB 4,0,4,0,10,0,0,0
	DEFB 12,0,22,0,62,0,12,0
	DEFB 24,0,48,0,55,208,28,112
	DEFB 8,32,13,80,15,224,7,192
	DEFB 1,0,2,128,0,0,0,0
	DEFB 3,0,5,128,15,128,3,0
	DEFB 6,0,12,0,13,244,7,28
	DEFB 3,24,3,12,3,168,1,80
	DEFB 0,168,0,64,0,160,0,0
	DEFB 0,192,1,96,3,224,0,192
	DEFB 1,128,3,0,3,125,1,199
	DEFB 0,130,0,213,0,254,0,124
	DEFB 0,16,0,16,0,16,0,40