;===========================================================================
; EugeneLair.asm  
;
; Manic Miner Room 04:Eugene's Lair (1024 Bytes total)
;
; EugeneLairLayout            Size 512 Byte, Start Byte   0 (Offset 0)
; EugeneLairTile              Size  32 Byte, Start Byte 512 (Offset 512)
; EugeneLairBackground        Size   9 Byte, Start Byte 544 (Offset 544)
; EugeneLairFloor             Size   9 Byte, Start Byte 553 (Offset 553)
; EugeneLairCrumblingFloor    Size   9 Byte, Start Byte 562 (Offset 562)
; EugeneLairWall              Size   9 Byte, Start Byte 571 (Offset 571)
; EugeneLairConveyor          Size   9 Byte, Start Byte 580 (Offset 580)
; EugeneLairNasty1            Size   9 Byte, Start Byte 589 (Offset 589)
; EugeneLairNasty2            Size   9 Byte, Start Byte 598 (Offset 598)
; EugeneLairExtra             Size   9 Byte, Start Byte 607 (Offset 607)
; EugeneLairWillyPos          Size   7 Byte, Start Byte 616 (Offset 616)
; EugeneLairConveyorData      Size   4 Byte, Start Byte 623 (Offset 623)
; EugeneLairBorderColor       Size   1 Byte, Start Byte 627 (Offset 627)
; EugeneLairUnused1           Size   1 Byte, Start Byte 628 (Offset 628)
; EugeneLairItems             Size  26 Byte, Start Byte 629 (Offset 629)
; EugeneLairPortal            Size  37 Byte, Start Byte 655 (Offset 655)
; EugeneLairItemGraphic       Size   8 Byte, Start Byte 692 (Offset 692)
; EugeneLairInitialAir        Size   1 Byte, Start Byte 700 (Offset 700)
; EugeneLairGameClock         Size   1 Byte, Start Byte 701 (Offset 701)
; EugeneLairHGuardians        Size  29 Byte, Start Byte 702 (Offset 702)
; EugeneLairUnused2           Size   2 Byte, Start Byte 731 (Offset 731)
; EugeneLairVGuardians        Size   1 Byte, Start Byte 733 (Offset 733)
; EugeneLairUnused3           Size   2 Byte, Start Byte 734 (Offset 734)
; EugeneLairGraphicElement    Size  32 Byte, Start Byte 736 (Offset 736)
; EugeneLairGraphicGuardian   Size 256 Byte, Start Byte 768 (Offset 768)
;
;===========================================================================

; Room layout for Room 0 (Eugene's Lair)
; The first 512 bytes are the attributes that define the layout of the cavern.
EugeneLairLayout:
	DEFB 46,16,16,16,16,16,16,16	;Attributes
	DEFB 16,16,16,16,16,16,16,16
	DEFB 16,16,16,16,19,16,16,16
	DEFB 16,16,16,16,16,16,16,46
	DEFB 46,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,46
	DEFB 46,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,46
	DEFB 46,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,46
	DEFB 46,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,16
	DEFB 22,16,16,16,16,16,16,46
	DEFB 46,21,21,21,21,21,21,21
	DEFB 21,21,21,21,21,21,16,16
	DEFB 16,16,20,20,20,20,21,21
	DEFB 21,21,21,21,16,16,16,46
	DEFB 46,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,21,21,46
	DEFB 46,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,22,16,16
	DEFB 16,16,16,16,16,16,16,46
	DEFB 46,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,16
	DEFB 16,16,86,86,86,86,86,86
	DEFB 86,86,86,86,86,16,16,46
	DEFB 46,16,16,16,21,21,21,21
	DEFB 21,21,21,21,21,21,16,16
	DEFB 16,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,46
	DEFB 46,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,46
	DEFB 46,20,20,21,21,21,21,21
	DEFB 21,21,21,21,21,21,16,16
	DEFB 16,16,21,21,21,21,21,21
	DEFB 21,16,16,16,16,16,21,46
	DEFB 46,16,16,16,16,16,16,16
	DEFB 46,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,46
	DEFB 46,21,21,16,16,16,16,16
	DEFB 46,16,16,16,16,16,46,16
	DEFB 16,46,16,16,16,16,16,16
	DEFB 16,16,16,16,16,16,16,46
	DEFB 46,16,16,16,16,22,16,16
	DEFB 46,16,16,16,16,16,46,16
	DEFB 16,46,46,46,46,46,46,46
	DEFB 22,22,16,16,16,16,16,46
	DEFB 46,21,21,21,21,21,21,21
	DEFB 46,46,46,46,46,46,46,46
	DEFB 46,46,46,46,46,46,46,46
	DEFB 21,21,21,21,21,21,21,46

;The next 72 bytes  specify the room name.
EugeneLairTile:
	DEFM "         Eugene's Lair          "	    ;Room name
		
; The next 72 bytes contain the attributes and graphic data for the tiles used to build the cavern.
EugeneLairBackground:
	DEFB 16,0,0,0,0,0,0,0,0	
EugeneLairFloor:	
	DEFB 21,255,255,219,110,197,64,0,0	
EugeneLairCrumblingFloor:	
	DEFB 20,255,219,165,36,82,32,8,0	 
EugeneLairWall:	
	DEFB 46,34,255,136,255,34,255,136,255	
EugeneLairConveyor:	
	DEFB 86,252,102,252,102,0,0,0,0
EugeneLairNasty1:	
	DEFB 22,68,40,148,81,53,214,88,16
EugeneLairNasty2:
	DEFB 19,126,60,28,24,24,8,8,8
EugeneLairExtra:
	DEFB 0,0,0,0,0,0,0,0,0

; The next seven bytes specify Miner Willy's initial location and appearance in the cavern.
EugeneLairWillyAppearanceAndPosition:
	DEFB 48			;Pixel y-coordinate * 2 (see 32872)
	DEFB 0			;Animation frame (see 32873)
	DEFB 0			;Direction and movement flags: facing right (see 32874)
	DEFB 0			;Airborne status indicator (see 32875)
	DEFW 23649		;Location in the attribute buffer at 23552: (13,2) (see 32876)
	DEFB 0			;Jumping animation counter (see 32878)
	
;The next four bytes are copied to 32879 and specify the direction, location and length of the conveyor.
EugeneLairConveyorData:
	DEFB 0			;Direction (left)
	DEFW 30738		;Location in the screen buffer at 28672: (11,1) -> Layout Row 10, Col 1
	DEFB 10			;Length
	
EugeneLairBorderColor:
	DEFB 1			;Border Color	

EugeneLairUnused1:
	DEFB 0			;Unused	
	
;The next 25 bytes specify the location and initial colour of the items in the cavern.
EugeneLairItems:
	DEFB 19		;Item 1 at (1,30)
	DEFW 23614
	DEFB 96
	DEFB 255
	DEFB 20		;Item 2 at (6,10)
	DEFW 23754
	DEFB 96
	DEFB 255
	DEFB 21		;Item 3 at (7,29)
	DEFW 23806
	DEFB 96
	DEFB 255
	DEFB 22		;Item 4 at (12,7)
	DEFW 23943
	DEFB 104
	DEFB 255
	DEFB 19		;Item 5 at (12,9)
	DEFW 23945
	DEFB 104
	DEFB 255
	DEFB 255	;Terminator
	
;The next 37 bytes define the portal graphic and its location.
EugeneLairPortal:
	DEFB 87		;Attribute
	DEFB 255,255,170,170,170,170,170,170	;Graphic data
	DEFB 170,170,170,170,170,170,170,170
	DEFB 170,170,170,170,170,170,170,170
	DEFB 170,170,170,170,170,170,255,255
	DEFW 23983	;Location in the attribute buffer at 23552: (13,15)
	DEFW 26799	;Location in the screen buffer at 24576: (13,15)


;The next eight bytes are copied to 32948 and define the item graphic.
EugeneLairItemGraphic:
	DEFB 31,35,71,255,143,142,140,248	;Item graphic data

;The next byte is  specifies the initial air supply in the cavern.
EugeneLairInitialAir:
	DEFB 63		;Air

;The next byte initialises the game clock.
EugeneLairGameClock:
	DEFB 128	;Game clock

;The next 28 bytes are copied to 32958 and define the horizontal guardians.
EugeneLairHGuardians:
	DEFB 22		;Horizontal guardian 1: y=3, initial x=12, 1<=x<=12, speed=normal
	DEFW 23660
	DEFB 96
	DEFB 7
	DEFB 97
	DEFB 108
	DEFB 16		;Horizontal guardian 2: y=7, initial x=4, 4<=x<=12, speed=normal
	DEFW 23780
	DEFB 96
	DEFB 0
	DEFB 228
	DEFB 236
	DEFB 255,0,0,0,0,0,0	;Horizontal guardian 3 (unused)
	DEFB 0,0,0,0,0,0,0		;Horizontal guardian 4 (unused)
	DEFB 255	;Terminator

;The next two bytes are not used.
EugeneLairUnused2:
	DEFB 0, 0 ;Unused

;The next byte is copied to 32989 and indicates that there are no vertical guardians in this cavern.
EugeneLairVGuardians:
	DEFB 0	;Terminator

;The next two bytes are unused.
EugeneLairUnused3:
	DEFB 0,0	;Unused

;The next 32 bytes define graphic.
EugeneLairGraphicElement:
	DEFB 3,192,15,240,31,248,31,248	 ;Eugene graphic data
	DEFB 49,140,14,112,111,246,174,117
	DEFB 177,141,159,249,155,217,140,49
	DEFB 71,226,2,64,2,64,14,112


;The next 256 bytes define the guardian graphics.
EugeneLairGraphicGuardian:
	DEFB 192,0,192,0,192,0,192,0	;Guardian graphic data
	DEFB 192,0,192,0,192,0,223,192
	DEFB 223,192,255,192,31,192,15,128
	DEFB 119,128,255,0,223,0,223,0
	DEFB 48,0,48,0,48,0,48,0
	DEFB 48,32,48,192,51,0,52,0
	DEFB 55,240,63,240,7,240,3,224
	DEFB 29,224,63,192,55,192,55,192
	DEFB 12,0,12,0,12,32,12,64
	DEFB 12,64,12,128,12,128,13,0
	DEFB 13,252,15,252,1,252,0,248
	DEFB 7,120,15,240,13,240,13,240
	DEFB 3,0,3,0,3,0,3,0
	DEFB 3,2,3,12,3,48,3,64
	DEFB 3,127,3,255,0,127,0,62
	DEFB 1,222,3,252,3,124,3,124
	DEFB 0,192,0,192,0,192,0,192
	DEFB 64,192,48,192,12,192,2,192
	DEFB 254,192,255,192,254,0,124,0
	DEFB 123,128,63,192,62,192,62,192
	DEFB 0,48,0,48,4,48,2,48
	DEFB 2,48,1,48,1,48,0,176
	DEFB 63,176,63,240,63,128,31,0
	DEFB 30,224,15,240,15,176,15,176
	DEFB 0,12,0,12,0,12,0,12
	DEFB 4,12,3,12,0,204,0,44
	DEFB 15,236,15,252,15,224,7,192
	DEFB 7,184,3,252,3,236,3,236
	DEFB 0,3,0,3,0,3,0,3
	DEFB 0,3,0,3,0,3,3,251
	DEFB 3,251,3,255,3,248,1,240
	DEFB 1,238,0,255,0,251,0,251