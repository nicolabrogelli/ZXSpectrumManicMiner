;===========================================================================
; AbandonedUraniumWorkings.asm  
;
; Manic Miner Room 03: Abandoned Uranium Workings (1024 Bytes total)
;
; AbandonedUraniumWorkingsLayout            Size 512 Byte, Start Byte   0 (Offset 0)
; AbandonedUraniumWorkingsTile              Size  32 Byte, Start Byte 512 (Offset 512)
; AbandonedUraniumWorkingsBackground        Size   9 Byte, Start Byte 544 (Offset 544)
; AbandonedUraniumWorkingsFloor             Size   9 Byte, Start Byte 553 (Offset 553)
; AbandonedUraniumWorkingsCrumblingFloor    Size   9 Byte, Start Byte 562 (Offset 562)
; AbandonedUraniumWorkingsWall              Size   9 Byte, Start Byte 571 (Offset 571)
; AbandonedUraniumWorkingsConveyor          Size   9 Byte, Start Byte 580 (Offset 580)
; AbandonedUraniumWorkingsNasty1            Size   9 Byte, Start Byte 589 (Offset 589)
; AbandonedUraniumWorkingsNasty2            Size   9 Byte, Start Byte 598 (Offset 598)
; AbandonedUraniumWorkingsExtra             Size   9 Byte, Start Byte 607 (Offset 607)
; AbandonedUraniumWorkingsWillyPos          Size   7 Byte, Start Byte 616 (Offset 616)
; AbandonedUraniumWorkingsConveyorData      Size   4 Byte, Start Byte 623 (Offset 623)
; AbandonedUraniumWorkingsBorderColor       Size   1 Byte, Start Byte 627 (Offset 627)
; AbandonedUraniumWorkingsUnused1           Size   1 Byte, Start Byte 628 (Offset 628)
; AbandonedUraniumWorkingsItems             Size  26 Byte, Start Byte 629 (Offset 629)
; AbandonedUraniumWorkingsPortal            Size  37 Byte, Start Byte 655 (Offset 655)
; AbandonedUraniumWorkingsItemGraphic       Size   8 Byte, Start Byte 692 (Offset 692)
; AbandonedUraniumWorkingsInitialAir        Size   1 Byte, Start Byte 700 (Offset 700)
; AbandonedUraniumWorkingsGameClock         Size   1 Byte, Start Byte 701 (Offset 701)
; AbandonedUraniumWorkingsHGuardians        Size  29 Byte, Start Byte 702 (Offset 702)
; AbandonedUraniumWorkingsUnused2           Size   2 Byte, Start Byte 731 (Offset 731)
; AbandonedUraniumWorkingsVGuardians        Size   1 Byte, Start Byte 733 (Offset 733)
; AbandonedUraniumWorkingsUnused3           Size   2 Byte, Start Byte 734 (Offset 734)
; AbandonedUraniumWorkingsGraphicElement    Size  32 Byte, Start Byte 736 (Offset 736)
; AbandonedUraniumWorkingsGraphicGuardian   Size 256 Byte, Start Byte 768 (Offset 768)
;
;===========================================================================

; Room layout for Room 0 (Abandoned Uranium Workings)
; The first 512 bytes are the attributes that define the layout of the cavern.
AbandonedUraniumWorkingsLayout:
	DEFB 41,0,0,0,0,0,0,5	;Attributes
	DEFB 0,0,0,0,0,0,41,41
	DEFB 41,41,41,41,41,41,41,41
	DEFB 41,41,41,41,41,41,41,41
	DEFB 41,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,41
	DEFB 41,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,41
	DEFB 41,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,70,70,70,70,70
	DEFB 70,0,0,0,0,0,0,41
	DEFB 41,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,70,70,70,70,41
	DEFB 41,70,0,0,0,0,0,70
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,70,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,41
	DEFB 41,0,0,0,0,0,0,0
	DEFB 0,0,0,0,70,70,0,0
	DEFB 0,0,0,0,0,70,70,70
	DEFB 0,0,0,0,0,0,0,41
	DEFB 41,6,6,6,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,41
	DEFB 41,0,0,0,0,0,0,70
	DEFB 70,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,70,70,70,0,0,41
	DEFB 41,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,70,70,70,0,0,0
	DEFB 0,0,0,0,0,0,0,41
	DEFB 41,3,3,3,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,70,41
	DEFB 41,0,0,0,0,0,0,0
	DEFB 0,0,0,0,70,70,70,0
	DEFB 0,0,0,0,0,0,70,70
	DEFB 70,0,0,0,0,0,0,41
	DEFB 41,0,0,0,0,0,70,70
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,5
	DEFB 0,0,0,0,70,70,70,41
	DEFB 41,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,70,70,0,0,0,0
	DEFB 0,0,0,0,0,0,0,41
	DEFB 41,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,0
	DEFB 0,0,0,0,0,0,0,41
	DEFB 41,70,70,70,70,70,70,70
	DEFB 70,70,70,70,70,70,70,70
	DEFB 70,70,70,70,70,70,70,70
	DEFB 70,70,70,70,70,70,70,41

;The next 72 bytes  specify the room name.
AbandonedUraniumWorkingsTile:
	DEFM "   Abandoned Uranium Workings   "	    ;Room name
		
; The next 72 bytes contain the attributes and graphic data for the tiles used to build the cavern.
AbandonedUraniumWorkingsBackground:
	DEFB 0,0,0,0,0,0,0,0,0	
AbandonedUraniumWorkingsFloor:	
	DEFB 70,255,255,219,110,197,64,0,0	
AbandonedUraniumWorkingsCrumblingFloor:	
	DEFB 6,255,219,165,36,82,32,8,0	 
AbandonedUraniumWorkingsWall:	
	DEFB 41,34,255,136,255,34,255,136,255	
AbandonedUraniumWorkingsConveyor:	
	DEFB 3,240,102,240,102,0,153,255,0
AbandonedUraniumWorkingsNasty1:	
	DEFB 4,68,40,148,81,53,214,88,16
AbandonedUraniumWorkingsNasty2:
	DEFB 5,16,16,16,84,56,214,56,84	
AbandonedUraniumWorkingsExtra:
	DEFB 0,0,0,0,0,0,0,0,0

; The next seven bytes specify Miner Willy's initial location and appearance in the cavern.
AbandonedUraniumWorkingsWillyAppearanceAndPosition:
	DEFB 208		;Pixel y-coordinate * 2 (see 32872)
	DEFB 0			;Animation frame (see 32873)
	DEFB 0			;Direction and movement flags: facing right (see 32874)
	DEFB 0			;Airborne status indicator (see 32875)
	DEFW 23997		;Location in the attribute buffer at 23552: (13,2) (see 32876)
	DEFB 0			;Jumping animation counter (see 32878)
	
;The next four bytes are copied to 32879 and specify the direction, location and length of the conveyor.
AbandonedUraniumWorkingsConveyorData:
	DEFB 1			;Direction (right)
	DEFW 30785		;Location in the screen buffer at 28672: (10,1)
	DEFB 3			;Length
	
AbandonedUraniumWorkingsBorderColor:
	DEFB 2			;Border Color	

AbandonedUraniumWorkingsUnused1:
	DEFB 0			;Unused	
	
;The next 25 bytes specify the location and initial colour of the items in the cavern.
AbandonedUraniumWorkingsItems:
	DEFB 3		;Item 1 at (0,1)
	DEFW 23553
	DEFB 96
	DEFB 255
	DEFB 4		;Item 2 at (1,12)
	DEFW 23596
	DEFB 96
	DEFB 255
	DEFB 5		;Item 3 at (1,25)
	DEFW 23609
	DEFB 96
	DEFB 255
	DEFB 6		;Item 4 at (6,16)
	DEFW 23760
	DEFB 96
	DEFB 255
	DEFB 3		;Item 5 at (6,30)
	DEFW 23774
	DEFB 96
	DEFB 255
	DEFB 255
	
;The next 37 bytes define the portal graphic and its location.
AbandonedUraniumWorkingsPortal:
	DEFB 14							;Attribute
	DEFB 34,34,17,17,136,136,68,68	;Graphic data
	DEFB 34,34,17,17,136,136,68,68
	DEFB 34,34,17,17,136,136,68,68
	DEFB 34,34,17,17,136,136,68,68
	DEFW 23613						;Location in the attribute buffer at 23552: (1,29)
	DEFW 24637						;Location in the screen buffer at 24576: (1,29)


;The next eight bytes are copied to 32948 and define the item graphic.
AbandonedUraniumWorkingsItemGraphic:
	DEFB 48,72,136,144,104,4,10,4	;Item graphic data

;The next byte is  specifies the initial air supply in the cavern.
AbandonedUraniumWorkingsInitialAir:
	DEFB 63		;Air

;The next byte initialises the game clock.
AbandonedUraniumWorkingsGameClock:
	DEFB 128	;Game clock

;The next 28 bytes are copied to 32958 and define the horizontal guardians.
AbandonedUraniumWorkingsHGuardians:
	DEFB 66		;Horizontal guardian 1: y=13, initial x=1, 1<=x<=10, speed=normal
	DEFW 23969
	DEFB 104
	DEFB 0
	DEFB 161
	DEFB 170
	DEFB 68		;Horizontal guardian 2: y=13, initial x=7, 6<=x<=15, speed=normal
	DEFW 23975
	DEFB 104
	DEFB 0
	DEFB 166
	DEFB 175
	DEFB 255,0,0,0,0,0,0	;Horizontal guardian 3 (unused)
	DEFB 0,0,0,0,0,0,0		;Horizontal guardian 4 (unused)
	DEFB 255

;The next two bytes are not used.
AbandonedUraniumWorkingsUnused2:
	DEFB 0,0	;Unused

;The next byte is copied to 32989 and indicates that there are no vertical guardians in this cavern.
AbandonedUraniumWorkingsVGuardians:
	DEFB 255	;Terminator

;The next two bytes are unused.
AbandonedUraniumWorkingsUnused3:
	DEFB 0,0	;Unused

;The next 32 bytes define graphic.
AbandonedUraniumWorkingsGraphicElement:
	DEFB 255,0,0,0,0,0,0	;Vertical guardian 1 (unused)
	DEFB 0,0,0,0,0,0,0		;Vertical guardian 2 (unused)
	DEFB 0,0,0,0,0,0,0		;Vertical guardian 3 (unused)
	DEFB 0,0,0,0,0,0,0		;Vertical guardian 4 (unused)

;The next 256 bytes define the guardian graphics.
AbandonedUraniumWorkingsGraphicGuardian:
	DEFB 7,0,11,128,19,192,19,192	;Guardian graphic data
	DEFB 19,192,11,128,7,0,1,0
	DEFB 7,0,5,0,7,0,7,128
	DEFB 79,128,95,192,254,192,60,64
	DEFB 1,192,2,224,5,208,5,208
	DEFB 5,208,2,224,1,192,0,64
	DEFB 1,192,1,64,1,192,1,224
	DEFB 35,224,47,240,127,176,31,16
	DEFB 0,112,0,232,1,228,1,228
	DEFB 1,228,0,232,0,112,0,16
	DEFB 0,112,0,80,0,112,0,248
	DEFB 33,248,39,252,127,236,15,196
	DEFB 0,28,0,54,0,99,0,99
	DEFB 0,99,0,54,0,28,0,4
	DEFB 0,28,0,20,0,28,0,30
	DEFB 4,62,4,255,15,251,3,241
	DEFB 56,0,108,0,198,0,198,0
	DEFB 198,0,108,0,56,0,32,0
	DEFB 56,0,40,0,56,0,120,0
	DEFB 124,32,255,32,223,240,143,192
	DEFB 14,0,23,0,39,128,39,128
	DEFB 39,128,23,0,14,0,8,0
	DEFB 14,0,10,0,14,0,31,0
	DEFB 31,132,63,228,55,254,35,240
	DEFB 3,128,7,64,11,160,11,160
	DEFB 11,160,7,64,3,128,2,0
	DEFB 3,128,2,128,3,128,7,128
	DEFB 7,196,15,244,13,254,8,248
	DEFB 0,224,1,208,3,200,3,200
	DEFB 3,200,1,208,0,224,0,128
	DEFB 0,224,0,160,0,224,1,224
	DEFB 1,242,3,250,3,127,2,60