;===========================================================================
; CentralCavern.asm  
;
; Manic Miner Room 00: Central Cavern (1024 Bytes total)
;
; CentralCavernLayout            Size 512 Byte, Start Byte   0 (Offset 0)
; CentralCavernTile              Size  32 Byte, Start Byte 512 (Offset 512)
; CentralCavernBackground        Size   9 Byte, Start Byte 544 (Offset 544)
; CentralCavernFloor             Size   9 Byte, Start Byte 553 (Offset 553)
; CentralCavernCrumblingFloor    Size   9 Byte, Start Byte 562 (Offset 562)
; CentralCavernWall              Size   9 Byte, Start Byte 571 (Offset 571)
; CentralCavernConveyor          Size   9 Byte, Start Byte 580 (Offset 580)
; CentralCavernNasty1            Size   9 Byte, Start Byte 589 (Offset 589)
; CentralCavernNasty2            Size   9 Byte, Start Byte 598 (Offset 598)
; CentralCavernExtra             Size   9 Byte, Start Byte 607 (Offset 607)
; CentralCavernWillyPos          Size   7 Byte, Start Byte 616 (Offset 616)
; CentralCavernConveyorData      Size   4 Byte, Start Byte 623 (Offset 623)
; CentralCavernBorderColor       Size   1 Byte, Start Byte 627 (Offset 627)
; CentralCavernUnused1           Size   1 Byte, Start Byte 628 (Offset 628)
; CentralCavernItems             Size  26 Byte, Start Byte 629 (Offset 629)
; CentralCavernPortal            Size  37 Byte, Start Byte 655 (Offset 655)
; CentralCavernItemGraphic       Size   8 Byte, Start Byte 692 (Offset 692)
; CentralCavernInitialAir        Size   1 Byte, Start Byte 700 (Offset 700)
; CentralCavernGameClock         Size   1 Byte, Start Byte 701 (Offset 701)
; CentralCavernHGuardians        Size  29 Byte, Start Byte 702 (Offset 702)
; CentralCavernUnused2           Size   2 Byte, Start Byte 731 (Offset 731)
; CentralCavernVGuardians        Size   1 Byte, Start Byte 733 (Offset 733)
; CentralCavernUnused3           Size   2 Byte, Start Byte 734 (Offset 734)
; CentralCavernGraphicElement    Size  32 Byte, Start Byte 736 (Offset 736)
; CentralCavernGraphicGuardian   Size 256 Byte, Start Byte 768 (Offset 768)
;
;===========================================================================

; Room layout for Room 0 (Central Cavern)
; The first 512 bytes are the attributes that define the layout of the cavern.
CentralCavernLayout:
	DEFB 22,0,0,0,0,0,0,0	; Attributes
	DEFB 0,0,0,5,0,0,0,0
	DEFB 5,0,0,0,0,0,0,0
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
	DEFB 0,0,0,0,0,0,0,68
	DEFB 0,0,0,68,0,0,0,22
	DEFB 22,66,66,66,66,66,66,66
	DEFB 66,66,66,66,66,66,2,2
	DEFB 2,2,66,2,2,2,2,66
	DEFB 66,66,66,66,66,66,66,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,66,66,66,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,22,22,22,0,68,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,66,66,66,66,0,0,0
	DEFB 4,4,4,4,4,4,4,4
	DEFB 4,4,4,4,4,4,4,4
	DEFB 4,4,4,4,0,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,66,66,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,68,0,0,0
	DEFB 0,0,0,0,22,22,22,2
	DEFB 2,2,2,2,66,66,66,22
	DEFB 22,0,0,0,0,66,66,66
	DEFB 66,66,66,66,66,66,66,66
	DEFB 66,66,66,66,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,22
	DEFB 22,66,66,66,66,66,66,66
	DEFB 66,66,66,66,66,66,66,66
	DEFB 66,66,66,66,66,66,66,66
	DEFB 66,66,66,66,66,66,66,22

;The next 72 bytes  specify the room name.
CentralCavernTile:
    	DEFM "         Central Cavern         "	    ;Room name
		
; The next 72 bytes contain the attributes and graphic data for the tiles used to build the cavern.
CentralCavernBackground: 
	DEFB 0,0,0,0,0,0,0,0,0	
CentralCavernFloor:
	DEFB 66,255,255,219,110,197,64,0,0	
CentralCavernCrumblingFloor:
	DEFB 2,255,219,165,36,82,32,8,0	 
CentralCavernWall:
	DEFB 22,34,255,136,255,34,255,136,255	
CentralCavernConveyor:
	DEFB 4,240,102,240,102,0,153,255,0	
CentralCavernNasty1:	
	DEFB 68,68,40,148,81,53,214,88,16	
CentralCavernNasty2:
	DEFB 5,255,254,126,124,76,76,8,8	
CentralCavernExtra:
	DEFB 0,0,0,0,0,0,0,0,0

; The next seven bytes specify Miner Willy's initial location and appearance in the cavern.
CentralCavernWillyAppearanceAndPosition:
	DEFB 208		;Pixel y-coordinate * 2 (see 32872)
	DEFB 0			;Animation frame (see 32873)
	DEFB 0			;Direction and movement flags: facing right (see 32874)
	DEFB 0			;Airborne status indicator (see 32875)
	DEFW 23970		;Location in the attribute buffer at 23552: (13,2) (see 32876)
	DEFB 0			;Jumping animation counter (see 32878)
	
;The next four bytes are copied to 32879 and specify the direction, location and length of the conveyor.
CentralCavernConveyorData:
	DEFB 0			;Direction (left)
	DEFW 30760		;Location in the screen buffer at 28672: (9,8)
	DEFB 20			;Length
	
CentralCavernBorderColor:
	DEFB 2			;Border Color	

CentralCaverUnused1:
	DEFB 0			;Unused	
	
;The next 25 bytes specify the location and initial colour of the items in the cavern.
CentralCavernLocationColorItems:
	DEFB 3			;Item 1 at (0,9)
	DEFW 23561
	DEFB 96
	DEFB 255
	DEFB 4			;Item 2 at (0,29)
	DEFW 23581
	DEFB 96
	DEFB 255
	DEFB 5			;Item 3 at (1,16)
	DEFW 23600
	DEFB 96
	DEFB 255
	DEFB 6			;Item 4 at (4,24)
	DEFW 23704
	DEFB 96
	DEFB 255
	DEFB 3			;Item 5 at (6,30)
	DEFW 23774
	DEFB 96
	DEFB 255
	DEFB 255		;Terminator	
	
;The next 37 bytes define the portal graphic and its location.
CentralCavernPortal:
	DEFB 14			;Attribute
	DEFB 255,255,146,73,182,219,255,255		;Graphic data
	DEFB 146,73,182,219,255,255,146,73
	DEFB 182,219,255,255,146,73,182,219
	DEFB 255,255,146,73,182,219,255,255
	DEFW 23997								;Location in the attribute buffer at 23552: (13,29)
	DEFW 26813								;Location in the screen buffer at 24576: (13,29)


;The next eight bytes are copied to 32948 and define the item graphic.
CentralCavernItemGraphic:
	DEFB 48,72,136,144,104,4,10,4	;Item graphic data

;The next byte is  specifies the initial air supply in the cavern.
CentralCavernInitialAir:
	DEFB 63		;Air

;The next byte initialises the game clock.
CentralCavernGameClock:
	DEFB 252	;Game clock

;The next 28 bytes are copied to 32958 and define the horizontal guardians.
CentralCaverHorizontalGuardians:
	DEFB 70					;Horizontal guardian 1: y=7, initial x=8, 8<=x<=15, speed=normal
	DEFW 23784
	DEFB 96
	DEFB 0
	DEFB 232
	DEFB 239
	DEFB 255,0,0,0,0,0,0	;Horizontal guardian 2 (unused)
	DEFB 0,0,0,0,0,0,0		;Horizontal guardian 3 (unused)
	DEFB 0,0,0,0,0,0,0		;Horizontal guardian 4 (unused)
	DEFB 255				;Terminator

;The next two bytes are not used.
CentralCaverUnused2:
	DEFB 0,0	;Unused

;The next byte is copied to 32989 and indicates that there are no vertical guardians in this cavern.
CentralCavernVGuardians:
	DEFB 255	;Terminator

;The next two bytes are unused.
CentralCaverUnused3:
	DEFB 0,0	;Unused

;The next 32 bytes define graphic.
CentralCavernGraphicElement:
	DEFB 2,160,5,67,31,228,115,255		;Swordfish graphic data
	DEFB 242,248,31,63,255,228,63,195
	DEFB 0,0,1,0,57,252,111,2
	DEFB 81,1,127,254,57,252,1,0

;The next 256 bytes define the guardian graphics.
CentralCavernGraphicGuardian:
	DEFB 31,32,57,224,25,224,15,32		;Guardian graphic data
	DEFB 159,0,95,128,255,192,94,0
	DEFB 159,192,31,128,14,0,31,0
	DEFB 187,160,113,192,32,128,17,0
	DEFB 7,196,14,124,6,124,35,196
	DEFB 23,192,23,224,63,240,23,240
	DEFB 23,240,39,224,3,128,3,128
	DEFB 6,192,6,192,28,112,6,192
	DEFB 1,242,3,158,1,158,0,242
	DEFB 9,240,5,248,15,252,5,224
	DEFB 9,252,1,248,0,224,0,224
	DEFB 0,224,0,224,0,224,1,240
	DEFB 0,125,0,231,0,103,0,61
	DEFB 0,124,0,127,3,252,0,120
	DEFB 0,124,0,127,0,56,0,56
	DEFB 0,108,0,108,1,199,0,108
	DEFB 190,0,231,0,230,0,188,0
	DEFB 62,0,254,0,63,192,30,0
	DEFB 62,0,254,0,28,0,28,0
	DEFB 54,0,54,0,227,128,54,0
	DEFB 79,128,121,192,121,128,79,0
	DEFB 15,144,31,160,63,240,7,160
	DEFB 63,144,31,128,7,0,7,0
	DEFB 7,0,7,0,7,0,15,128
	DEFB 35,224,62,112,62,96,35,196
	DEFB 3,232,7,232,15,252,15,232
	DEFB 15,232,7,228,1,192,1,192
	DEFB 3,96,3,96,14,56,3,96
	DEFB 4,248,7,156,7,152,4,240
	DEFB 0,249,1,250,3,255,0,122
	DEFB 3,249,1,248,0,112,0,248
	DEFB 5,221,3,142,1,4,0,136