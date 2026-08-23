;===========================================================================
; resources.asm
;
; Gestione delle risorse statiche non modificabili del gioco.
; Contiene le stanze (livelli) e le sprite dei personaggi.
;===========================================================================

RoomsStart:
    include "rooms/CentralCavern.asm"               ; ID 00
    

    include "data/datasprite.asm"

font_buffer:
    .1024 db 0

items_grid:
    .512 db 0
