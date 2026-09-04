;===========================================================================
; constants.asm
;===========================================================================


; Indirizzi ROM
CLS:        EQU $0daf
OPENCHAN:   EQU $1601
ATTR_P:     EQU $5c8d
ATTR_T:     EQU $5c8f
BORDCR:     EQU $5c48
UDG:        EQU $5c7b

INITIAL_LIVES: EQU 7

; Colori
BLACK:  EQU $00
NONE:   EQU $00
BLUE:   EQU $01
RED:    EQU $02
MAGENTA: EQU $03
GREEN:  EQU $04
CYAN:   EQU $05
YELLOW: EQU $06
WHITE:  EQU $07

; Colori
BLUE_FLASH:   EQU $C1
RED_FLASH:    EQU $C2
MAGENTA_FLASH: EQU $C3
GREEN_FLASH:  EQU $C4
CYAN_FLASH:   EQU $C5
YELLOW_FLASH: EQU $C6
WHITE_FLASH:  EQU $C7

;; Interrupt
;IM2_TABLE   = $FE00
;IM2_VECTOR  = $FDFD
;SCREEN_LINE = $4860
;SCREEN_MEMORY = $4000
;COLOR_DATA = $5800
;STACK_POINTER = $fdf0

; Note: La fisica (MAX_FALL_SPEED, JUMP_STRENGTH, GRAVITY, DEFAULT_GRAVITY_PRESET)
; è ora configurata in physics_config.asm

; Limiti schermo del Player
PLAYER_MIN_X:    EQU 5
PLAYER_MAX_X:    EQU 245

; items_grid è definito dinamicamente in resources.asm dopo le sprite

; Offsets all'interno della struttura dati della Stanza Manic Miner (1024 byte)
OFFSET_LAYOUT:           EQU 0    ; 512 byte (16 righe x 32 colonne)
OFFSET_ROOM_NAME:        EQU 512  ; 32 byte nome stanza
OFFSET_TILES:            EQU 544  ; 72 byte (8 definizioni tile x 9 byte)
OFFSET_BG:               EQU 544  ; Tile 0: Sfondo
OFFSET_FLOOR:            EQU 553  ; Tile 1: Pavimento
OFFSET_CRUMBLING:        EQU 562  ; Tile 2: Pavimento sgretolabile
OFFSET_WALL:             EQU 571  ; Tile 3: Muro
OFFSET_CONVEYOR:         EQU 580  ; Tile 4: Nastro trasportatore
OFFSET_NASTY1:           EQU 589  ; Tile 5: Nasty 1
OFFSET_NASTY2:           EQU 598  ; Tile 6: Nasty 2
OFFSET_EXTRA_TILE:       EQU 607  ; Tile 7: Extra
OFFSET_POS_WILLY:        EQU 616  ; 7 byte pos/aspetto iniziale Willy
OFFSET_CONVEYOR_DATA:    EQU 623  ; 4 byte conveyor (dir, addr, len)
OFFSET_BORDER_COLOR:     EQU 627  ; 1 byte colore bordo
OFFSET_APEX_PAUSE:       EQU 628  ; 1 byte pausa all'apice salto verticale (0 = default VERTICAL_JUMP_APEX_PAUSE)
OFFSET_UNUSED1:          EQU 628  ; Alias retrocompatibilità (1 byte non usato)
OFFSET_ITEMS:            EQU 629  ; 26 byte item (fino a 5 x 5B + $FF)
OFFSET_PORTAL:           EQU 655  ; 37 byte portale
OFFSET_ITEM_GRAPHIC:     EQU 692  ; 8 byte bitmap grafica item
OFFSET_INITIAL_AIR:      EQU 700  ; 1 byte aria iniziale
OFFSET_GAME_CLOCK:       EQU 701  ; 1 byte orologio
OFFSET_H_GUARDIANS:      EQU 702  ; 29 byte guardiani orizzontali (4 x 7B + $FF)
OFFSET_UNUSED2:          EQU 731  ; 2 byte non usati
OFFSET_V_GUARDIANS:      EQU 733  ; 1 byte terminatore / guardiani verticali
OFFSET_UNUSED3:          EQU 734  ; 2 byte non usati
OFFSET_EXTRA_GRAPHIC:    EQU 736  ; 32 byte grafica extra
OFFSET_GUARDIAN_GRAPHICS: EQU 768 ; 256 byte sprite guardiani stanza (8 frame 16x16)
ROOM_SIZE:               EQU 1024 ; Dimensione stanza Manic Miner

BLOCK:          EQU $FF

ROOM_MASTER_BEDROOM: EQU 35


LAMETTA:  		EQU 0   ;(Lametta)
SEGA: 			EQU 1   ;(Sega)
UCCELLO: 		EQU 2   ;(Uccello)
RADAR: 			EQU 3   ;(Radar)
UOVO: 			EQU 4   ;(Uovo)
UFO: 			EQU 5   ;(Ufo)
FACCIA:			EQU 6   ;(Faccia)
SCIMMIA:		EQU 7   ;(Scimmia)
ROBOT:			EQU 8   ;(Robot)
PALLA:			EQU 9   ;(Palla)
DOUBLE_BALL:	EQU 10  ;(Double Ball)
SOLDATO:		EQU 11  ;(Soldato)
MAIALE:			EQU 12  ;(Maiale)
CANGURO:		EQU 13  ;(Canguro)
FIORE:			EQU 14  ;(Fiore)
FACCIA_PALLA: 	EQU 15  ;(Faccia Palla)
CANDELABRO:		EQU 16  ;(Candelabro)
FRECCIA:		EQU 17  ;(Freccia)
TRONCHESE:		EQU 18  ;(Tronchese)
PERISCOPIO:		EQU 19  ;(Periscopio)
NONNINO:		EQU 20  ;(Nonnino)
PARRUCCA:		EQU 21  ;(Parrucca)
FRATE:			EQU 22  ;(Frate)
FACE_HL:		EQU 23  ;(FaceHellHL - Top-Left)
FACE_HR:		EQU 24  ;(FaceHellHR - Top-Right)
FACE_LL:		EQU 25  ;(FaceHellLL - Bottom-Left)
FACE_LR:		EQU 26  ;(FaceHellLR - Bottom-Right)
PINZA_GHIACCIO:	EQU 27  ;(PinzaGiaccioSprite)
RUOTA:			EQU 28  ;(RuotaSprite)
SALIERA:		EQU 29  ;(SalieraSprite)
GELATO:			EQU 30  ;(GelatoSprite)
PINGUINO:		EQU 31  ;(PinguinoSprite)
MURO:			EQU 32  ;(MuroSprite)
DIAVOLETTO:		EQU 33  ;(DiavolettoSprite)
VECCHIA:		EQU 34  ;(VecchiaSprite)
PIEDE:			EQU 35  ;(PiedeSprite)
CHIP:			EQU 36  ;(ChipSprite)
IPNOSI:			EQU 37  ;(IpnosiSprite)
SWISSARMKIFE:	EQU 38  ;(SwissArmyKife)
BOTTE:			EQU 39  ;(BotteSprite)
ONDA:			EQU 40  ;(OndaSprite)
PALAZZO:		EQU 41  ;(PalazzoSprite)