;===========================================================================
; resources.asm
;
; Gestione delle risorse statiche non modificabili del gioco.
; Contiene le stanze (livelli) e le sprite dei personaggi.
;===========================================================================

RoomsStart:
    include "rooms/CentralCavern.asm"               ; ID 00
    include "rooms/TheColdRoom.asm"                 ; ID 01
    include "rooms/TheMenagerie.asm"                ; ID 02
    include "rooms/AbandonedUraniumWorkings.asm"    ; ID 03
    include "rooms/EugeneLair.asm"                  ; ID 04
    include "rooms/ProcessingPlant.asm"             ; ID 05
    include "rooms/TheVat.asm"                      ; ID 06
    include "rooms/MinerWillymeetstheKongBeast.asm" ; ID 07
    include "rooms/WackyAmoebatrons.asm"            ; ID 08
    include "rooms/TheEndorianForest.asm"           ; ID 09
    include "rooms/AttackoftheMutantTelephones.asm" ; ID 10
    include "rooms/ReturnoftheAlienKongBeast.asm"   ; ID 11
    include "rooms/OreRefinery.asm"                 ; ID 12
    include "rooms/SkylabLandingBay.asm"            ; ID 13 
    include "rooms/TheBanck.asm"                    ; ID 14
    include "rooms/TheSixteenthCavern.asm"          ; ID 15
    include "rooms/TheWarehouse.asm"                ; ID 16
    include "rooms/AmoebatronsRevenge.asm"          ; ID 17
    include "rooms/SolarPowerGenerator.asm"         ; ID 18
    include "rooms/TheFInalBarrier.asm"             ; ID 19

    include "data/datasprite.asm"
    include "data/datalandscape.asm"

font_buffer:
    .1024 db 0

items_grid:
    .512 db 0
