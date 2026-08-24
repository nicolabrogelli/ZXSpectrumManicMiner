;===========================================================================
; TheColdRoom.asm  
;
; Manic Miner Room 01: The Cold Room (1024 Bytes total)
;
; TheColdRoomLayout            Size 512 Byte, Start Byte   0 (Offset 0)
; TheColdRoomTile              Size  32 Byte, Start Byte 512 (Offset 512)
; TheColdRoomBackground        Size   9 Byte, Start Byte 544 (Offset 544)
; TheColdRoomFloor             Size   9 Byte, Start Byte 553 (Offset 553)
; TheColdRoomCrumblingFloor    Size   9 Byte, Start Byte 562 (Offset 562)
; TheColdRoomWall              Size   9 Byte, Start Byte 571 (Offset 571)
; TheColdRoomConveyor          Size   9 Byte, Start Byte 580 (Offset 580)
; TheColdRoomNasty1            Size   9 Byte, Start Byte 589 (Offset 589)
; TheColdRoomNasty2            Size   9 Byte, Start Byte 598 (Offset 598)
; TheColdRoomExtra             Size   9 Byte, Start Byte 607 (Offset 607)
; TheColdRoomWillyPos          Size   7 Byte, Start Byte 616 (Offset 616)
; TheColdRoomConveyorData      Size   4 Byte, Start Byte 623 (Offset 623)
; TheColdRoomBorderColor       Size   1 Byte, Start Byte 627 (Offset 627)
; TheColdRoomUnused1           Size   1 Byte, Start Byte 628 (Offset 628)
; TheColdRoomItems             Size  26 Byte, Start Byte 629 (Offset 629)
; TheColdRoomPortal            Size  37 Byte, Start Byte 655 (Offset 655)
; TheColdRoomItemGraphic       Size   8 Byte, Start Byte 692 (Offset 692)
; TheColdRoomInitialAir        Size   1 Byte, Start Byte 700 (Offset 700)
; TheColdRoomGameClock         Size   1 Byte, Start Byte 701 (Offset 701)
; TheColdRoomHGuardians        Size  29 Byte, Start Byte 702 (Offset 702)
; TheColdRoomUnused2           Size   2 Byte, Start Byte 731 (Offset 731)
; TheColdRoomVGuardians        Size   1 Byte, Start Byte 733 (Offset 733)
; TheColdRoomUnused3           Size   2 Byte, Start Byte 734 (Offset 734)
; TheColdRoomGraphicElement    Size  32 Byte, Start Byte 736 (Offset 736)
; TheColdRoomGraphicGuardian   Size 256 Byte, Start Byte 768 (Offset 768)
;
;===========================================================================

; Room layout for Room 0 (The Cold Room)
; The first 512 bytes are the attributes that define the layout of the cavern.
TheColdRoomLayout:
	DEFB 22,8,8,8,8,8,8,8	;Attributes
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,8,8,22,22,22,22,22
	DEFB 22,22,22,22,22,22,22,22
	DEFB 22,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,13,22
	DEFB 22,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,22
	DEFB 22,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,11,11,11
	DEFB 75,8,8,8,8,8,8,22
	DEFB 22,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,22
	DEFB 22,75,75,75,75,75,75,75
	DEFB 75,75,75,75,75,75,75,75
	DEFB 75,75,75,75,8,8,8,8
	DEFB 8,8,8,8,22,8,8,22
	DEFB 22,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,75,75,75
	DEFB 75,22,11,11,22,8,8,22
	DEFB 22,75,11,11,11,11,11,8
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,22,8,8,22,8,8,22
	DEFB 22,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,22,11,11,22,8,8,22
	DEFB 22,8,8,8,8,8,8,8
	DEFB 8,75,75,75,75,75,75,75
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,22,11,11,22,8,8,22
	DEFB 22,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,8,8,11,11,11,11,8
	DEFB 8,22,11,11,22,8,8,22
	DEFB 22,8,8,14,14,14,14,8
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,22,11,11,22,8,8,22
	DEFB 22,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,75,75
	DEFB 75,75,8,8,8,8,8,8
	DEFB 8,22,11,11,22,8,8,22
	DEFB 22,8,8,8,8,8,8,8
	DEFB 11,11,11,11,8,8,8,8
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,22
	DEFB 22,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,8
	DEFB 8,8,8,8,8,8,8,22
	DEFB 22,75,75,75,75,75,75,75
	DEFB 75,75,75,75,75,75,75,75
	DEFB 75,75,75,75,75,75,75,75
	DEFB 75,75,75,75,75,75,75,22

;The next 72 bytes  specify the room name.
TheColdRoomTile:
    	DEFM "          The Cold Room         "	    ;Room name
		
; The next 72 bytes contain the attributes and graphic data for the tiles used to build the cavern.
TheColdRoomBackground:
	DEFB 8,0,0,0,0,0,0,0,0	
TheColdRoomFloor:	
	DEFB 75,255,255,219,110,197,64,0,0	
TheColdRoomCrumblingFloor:	
	DEFB 11,255,219,165,36,82,32,8,0	 
TheColdRoomWall:	
	DEFB 22,34,255,136,255,34,255,136,255	
TheColdRoomConveyor:	
	DEFB 14,240,102,240,102,0,153,255,0	
TheColdRoomNasty1:	
	DEFB 12,68,40,148,81,53,214,88,16
TheColdRoomNasty2:
	DEFB 13,255,254,94,108,76,76,8,8	
TheColdRoomExtra:
	DEFB 0,0,0,0,0,0,0,0,0

; The next seven bytes specify Miner Willy's initial location and appearance in the cavern.
TheColdRoomWillyPos:
TheColdRoomWillyAppearanceAndPosition:
	DEFB 208		;Pixel y-coordinate * 2 (see 32872)
	DEFB 0			;Animation frame (see 32873)
	DEFB 0			;Direction and movement flags: facing right (see 32874)
	DEFB 0			;Airborne status indicator (see 32875)
	DEFW 23970		;Location in the attribute buffer at 23552: (13,2) (see 32876)
	DEFB 0			;Jumping animation counter (see 32878)
	
;The next four bytes are copied to 32879 and specify the direction, location and length of the conveyor.
TheColdRoomConveyorData:
	DEFB 1			;Direction (right)
	DEFW 30819		;Location in the screen buffer at 30819: (11,3)
	DEFB 4			;Length
	
TheColdRoomBorderColor:
	DEFB 2			;Border Color	

TheColdRoomUnused1:
	DEFB 0			;Unused	
	
;The next 25 bytes specify the location and initial colour of the items in the cavern.
TheColdRoomItems:
	DEFB 11		;Item 1 at (1,7)
	DEFW 23591
	DEFB 96
	DEFB 255
	DEFB 12		;Item 2 at (1,24)
	DEFW 23608
	DEFB 96
	DEFB 255
	DEFB 13		;Item 3 at (7,26)
	DEFW 23802
	DEFB 96
	DEFB 255
	DEFB 14		;Item 4 at (9,3)
	DEFW 23843
	DEFB 104
	DEFB 255
	DEFB 11		;Item 5 at (12,19)
	DEFW 23955
	DEFB 104
	DEFB 255
	DEFB 255	;Terminator
	
;The next 37 bytes define the portal graphic and its location.
TheColdRoomPortal:
	DEFB 83		;Attribute
	DEFB 255,255,146,73,146,73,146,73	;Graphic data
	DEFB 146,73,146,73,146,73,146,73
	DEFB 146,73,146,73,146,73,146,73
	DEFB 146,73,146,73,146,73,255,255
	DEFW 23997							;Location in the attribute buffer at 23552: (13,29)
	DEFW 26813							;Location in the screen buffer at 24576: (13,29)


;The next eight bytes are copied to 32948 and define the item graphic.
TheColdRoomItemGraphic:
	DEFB 80,168,84,168,84,44,2,1	;Item graphic data

;The next byte is  specifies the initial air supply in the cavern.
TheColdRoomInitialAir:
	DEFB 63		;Air

;The next byte initialises the game clock.
TheColdRoomGameClock:
	DEFB 252	;Game clock

;The next 28 bytes are copied to 32958 and define the horizontal guardians.
TheColdRoomHGuardians:
	DEFB 14		;Horizontal guardian 1: y=3, initial x=18, 1<=x<=18, speed=normal
	DEFW 23666
	DEFB 96
	DEFB 7
	DEFB 97
	DEFB 114
	DEFB 13		;Horizontal guardian 2: y=13, initial x=29, 12<=x<=29, speed=normal
	DEFW 23997
	DEFB 104
	DEFB 7
	DEFB 172
	DEFB 189
	DEFB 255,0,0,0,0,0,0	;Horizontal guardian 3 (unused)
	DEFB 0,0,0,0,0,0,0		;Horizontal guardian 4 (unused)
	DEFB 255	;Terminator

;The next two bytes are not used.
TheColdRoomUnused2:
	DEFB 0,0	;Unused

;The next byte is copied to 32989 and indicates that there are no vertical guardians in this cavern.
TheColdRoomVGuardians:
	DEFB 255	;Terminator

;The next two bytes are unused.
TheColdRoomUnused3:
	DEFB 0,0	;Unused

;The next 32 bytes define graphic.
TheColdRoomGraphicElement:
	DEFB 255,255,114,78,138,81,170,85	;Plinth graphic data
	DEFB 74,82,18,72,34,68,42,84
	DEFB 42,84,42,84,42,84,42,84
	DEFB 42,84,42,84,42,84,42,84

;The next 256 bytes define the guardian graphics.
TheColdRoomGraphicGuardian:
	DEFB 12,0,30,0,27,0,30,192	;Guardian graphic data
	DEFB 57,0,50,0,58,0,61,0
	DEFB 109,0,105,0,105,0,97,0
	DEFB 113,0,190,0,8,0,30,0
	DEFB 3,0,7,128,6,192,7,176
	DEFB 14,64,12,128,15,128,13,192
	DEFB 27,64,27,64,22,64,24,64
	DEFB 28,64,47,128,5,64,15,128
	DEFB 0,192,1,224,1,176,1,236
	DEFB 3,144,3,32,3,160,3,208
	DEFB 6,208,6,144,6,144,6,16
	DEFB 7,16,11,232,2,80,7,224
	DEFB 0,48,0,120,0,108,0,123
	DEFB 0,228,0,200,0,232,0,244
	DEFB 1,180,1,148,1,148,1,132
	DEFB 1,196,2,248,0,84,0,248
	DEFB 12,0,30,0,54,0,222,0
	DEFB 39,0,19,0,23,0,47,0
	DEFB 45,128,41,128,41,128,33,128
	DEFB 35,128,31,64,42,0,31,0
	DEFB 3,0,7,128,13,128,55,128
	DEFB 9,192,4,192,5,192,11,192
	DEFB 11,96,9,96,9,96,8,96
	DEFB 8,224,23,208,10,64,7,224
	DEFB 0,192,1,224,3,96,13,224
	DEFB 2,112,1,48,1,240,3,176
	DEFB 2,216,2,216,2,104,2,24
	DEFB 2,56,1,244,2,160,1,240
	DEFB 0,48,0,120,0,216,3,120
	DEFB 0,156,0,76,0,92,0,188
	DEFB 0,182,0,150,0,150,0,134
	DEFB 0,142,0,125,0,16,0,120