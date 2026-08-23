;===========================================================================
; items.asm
;
; Gestione degli Oggetti (Items) per Manic Miner.
; Gli item e la relativa grafica sono definiti direttamente all'interno
; dei dati della stanza (offset OFFSET_ITEMS e OFFSET_ITEM_GRAPHIC).
;===========================================================================

TOTAL_ITEMS: EQU 5 ; Numero totale di item in Central Cavern (aggiornato per le caverne attive)

; -------------------------------------------------------------------
; DetermineCurrentRoomID
;
; Determina l'ID numerico della stanza corrente confrontando
; il puntatore room_ptr con gli indirizzi presenti in RoomsListTable.
;
; Output:
;   A = ID della stanza (0..NUM_ROOMS-1)
;   (current_room) = A
; -------------------------------------------------------------------
DetermineCurrentRoomID:
    push hl
    push de
    push bc

    ld   hl, RoomsListTable
    ld   de, (room_ptr)
    ld   b, NUM_ROOMS
    ld   c, 0

.loop:
    ld   a, (hl)
    cp   e
    jr   nz, .no_match
    inc  hl
    ld   a, (hl)
    cp   d
    jr   z, .found
    dec  hl

.no_match:
    inc  hl
    inc  hl
    inc  c
    djnz .loop

    ld   c, 0                      ; Default stanza 0 se non trovata

.found:
    ld   a, c
    ld   (current_room), a

    pop  bc
    pop  de
    pop  hl
    ret

; -------------------------------------------------------------------
; ResetItemsTable
; Ripristina il flag di raccolta (byte 4 di ciascun item) a $FF (non raccolto)
; per tutte le stanze registrate in RoomsListTable.
; -------------------------------------------------------------------
ResetItemsTable:
    push hl
    push de
    push bc

    ld   hl, RoomsListTable
    ld   b, NUM_ROOMS

.room_loop:
    push bc
    ld   e, (hl)
    inc  hl
    ld   d, (hl)
    inc  hl
    push hl

    ; DE = room_ptr
    ld   hl, OFFSET_ITEMS
    add  hl, de                    ; HL = offset oggetti nella stanza

.item_loop:
    ld   a, (hl)
    cp   $FF
    jr   z, .next_room             ; $FF = fine lista item della stanza
    inc  hl                        ; +1 (Attr Address Low)
    inc  hl                        ; +2 (Attr Address High)
    inc  hl                        ; +3 (Anim mask)
    inc  hl                        ; +4 (Collected flag)
    ld   (hl), $FF                 ; $FF = non raccolto
    inc  hl                        ; Avanza al prossimo item
    jr   .item_loop

.next_room:
    pop  hl
    pop  bc
    djnz .room_loop

    pop  bc
    pop  de
    pop  hl
    ret

; -------------------------------------------------------------------
; Items_ResetCurrentRoomItems
; Ripristina il flag di raccolta (byte 4 di ciascun item) a $FF (non raccolto)
; per tutti gli item della stanza corrente puntata da (room_ptr).
; -------------------------------------------------------------------
Items_ResetCurrentRoomItems:
    push hl
    push de
    push af

    ld   hl, (room_ptr)
    ld   de, OFFSET_ITEMS
    add  hl, de

.item_loop:
    ld   a, (hl)
    cp   $FF
    jr   z, .done                  ; $FF = fine lista item della stanza
    inc  hl                        ; +1 (Attr Address Low)
    inc  hl                        ; +2 (Attr Address High)
    inc  hl                        ; +3 (Anim mask)
    inc  hl                        ; +4 (Collected flag)
    ld   (hl), $FF                 ; $FF = non raccolto
    inc  hl                        ; Avanza al prossimo item
    jr   .item_loop

.done:
    pop  af
    pop  de
    pop  hl
    ret

; -------------------------------------------------------------------
; Items_DrawRoom
;
; Disegna tutti gli oggetti attivi appartenenti alla stanza corrente.
; Legge i dati direttamente da room_ptr + OFFSET_ITEMS e la bitmap da
; room_ptr + OFFSET_ITEM_GRAPHIC.
;
; Record item nella stanza (5 byte):
;   +0 Color / Attributo
;   +1 Attr Address Low (23552 + Row * 32 + Col)
;   +2 Attr Address High
;   +3 Anim Mask (96)
;   +4 Collected Flag ($FF = attivo/non raccolto, 0 = raccolto)
; Fine lista: $FF
; -------------------------------------------------------------------
Items_DrawRoom:
    push hl
    push de
    push bc
    push ix
    push iy

    ; 1. Azzera items_grid (512 byte)
    ld   hl, items_grid
    ld   de, items_grid + 1
    ld   (hl), 0
    ld   bc, 511
    ldir

    ; 2. Nessun item attivo inizialmente nella cache
    xor  a
    ld   (num_room_items), a

    ld   iy, current_room_items

    ; 3. IX = Puntatore alla bitmap grafica dell'item (8 byte)
    ld   hl, (room_ptr)
    ld   de, OFFSET_ITEM_GRAPHIC
    add  hl, de
    push hl
    pop  ix                        ; IX = bitmap item

    ; 4. HL = Inizio lista item nella stanza
    ld   hl, (room_ptr)
    ld   de, OFFSET_ITEMS
    add  hl, de

.loop:
    ld   a, (hl)                   ; Byte 0: Color
    cp   $FF
    jr   z, .done                  ; $FF = fine lista item

    ld   e, a                      ; E = Color
    inc  hl
    ld   c, (hl)                   ; C = AttrAddr Low
    inc  hl
    ld   b, (hl)                   ; B = AttrAddr High
    inc  hl                        ; Salta Anim Byte
    inc  hl                        ; HL punta a Byte 4: Collected flag

    ld   a, (hl)                   ; A = Collected flag
    cp   $FF
    jr   nz, .next_item            ; Se != $FF, l'item è già stato raccolto

    ; Calcola Row e Col da BC (AttrAddr): Offset = BC - 23552
    push hl
    ld   h, b
    ld   l, c
    ld   bc, -23552
    add  hl, bc                    ; HL = AttrOffset

    ; Col = Offset & 31
    ld   a, l
    and  31
    ld   c, a                      ; C = Col (0..31)

    ; Row = Offset / 32
    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    ld   a, l
    ld   b, a                      ; B = Row (0..15)

    ; Disegna l'item sullo schermo
    push ix
    pop  hl                        ; HL = puntatore bitmap
    call DrawItemGraphic

    ; Aggiorna items_grid: offset = Row * 32 + Col
    push de
    ld   h, 0
    ld   l, b                      ; HL = Row
    add  hl, hl
    add  hl, hl
    add  hl, hl
    add  hl, hl
    add  hl, hl                    ; Row * 32
    ld   e, c
    ld   d, 0
    add  hl, de                    ; Row * 32 + Col
    ld   de, items_grid
    add  hl, de
    pop  de                        ; E = Color
    ld   (hl), e                   ; Salva colore nella griglia

    pop  hl                        ; HL = puntatore al flag Collected nei dati stanza

    ; Salva l'item nella cache current_room_items (5 byte: Col, Row, Color, FlagPtrLow, FlagPtrHigh)
    ld   (iy+0), c                 ; Colonna
    ld   (iy+1), b                 ; Riga
    ld   (iy+2), e                 ; Colore
    ld   (iy+3), l                 ; Flag Ptr Low
    ld   (iy+4), h                 ; Flag Ptr High

    ld   bc, 5
    add  iy, bc

    ld   a, (num_room_items)
    inc  a
    ld   (num_room_items), a

.next_item:
    inc  hl                        ; Avanza al prossimo item
    jr   .loop

.done:
    ; Se la stanza non ha item o sono già stati tutti raccolti, attiva subito il portale
    ld   a, (num_room_items)
    or   a
    jr   nz, .room_has_items
    ld   a, 1
    ld   (game_objective_completed), a
    jr   .pop_and_ret
.room_has_items:
    xor  a
    ld   (game_objective_completed), a
.pop_and_ret:
    pop  iy
    pop  ix
    pop  bc
    pop  de
    pop  hl
    ret

; -------------------------------------------------------------------
; DrawItemGraphic
;
; Disegna un oggetto 8x8 pixel sullo schermo dello ZX Spectrum
; utilizzando una bitmap di 8 byte e un attributo colore.
;
; Input:
;   B = Riga attributi (0..23)
;   C = Colonna attributi (0..31)
;   HL = Puntatore alla bitmap dell'oggetto (8 byte)
;   E = Attributo colore
; -------------------------------------------------------------------
DrawItemGraphic:
    push bc
    push de
    push hl

    ; Calcolo indirizzo bitmap: High = $40 + (Row & $18), Low = ((Row & 7) * 32) + Col
    ld   a, b
    and  $18
    add  a, $40
    ld   d, a                      ; Byte alto indirizzo video

    ld   a, b
    and  7
    add  a, a                      ; *2
    add  a, a                      ; *4
    add  a, a                      ; *8
    add  a, a                      ; *16
    add  a, a                      ; *32
    add  a, c                      ; + Col
    ld   e, a                      ; Byte basso indirizzo video

    push bc
    ld   b, 8                      ; 8 scanline
.line_loop:
    ld   a, (hl)
    ld   (de), a
    inc  d
    inc  hl
    dec  b
    jr   nz, .line_loop
    pop  bc

    ; Calcolo indirizzo attributo: $5800 + Row * 32 + Col
    ld   h, 0
    ld   l, b
    add  hl, hl
    add  hl, hl
    add  hl, hl
    add  hl, hl
    add  hl, hl                    ; Row * 32
    ld   a, c
    add  a, l
    ld   l, a
    jr   nc, .no_carry
    inc  h
.no_carry:
    ld   de, $5800
    add  hl, de

    pop  bc                        ; Recupera HL originale
    pop  de                        ; Recupera DE originale (E = colore)
    ld   a, e
    ld   (hl), a                   ; Scrive l'attributo colore

    push bc
    pop  hl
    pop  bc
    ret

; -------------------------------------------------------------------
; RestoreBackgroundCell
;
; Ripristina il tile originale presente nella mappa della stanza.
; Chiamata quando un item viene raccolto.
;
; Input:
;   B = Row (0..15)
;   C = Col (0..31)
; -------------------------------------------------------------------
RestoreBackgroundCell:
    push iy
    push bc
    push de
    push hl
    push ix

    push bc
    pop  iy                        ; IYH = Row, IYL = Col

    ld   a, b
    call GetCellFromUnpacked       ; A = tile index (0..7)

    ; IX = room_ptr + OFFSET_TILES + A * 9
    ld   l, a
    ld   h, 0
    ld   e, a
    ld   d, 0
    add  hl, hl                    ; *2
    add  hl, hl                    ; *4
    add  hl, hl                    ; *8
    add  hl, de                    ; *9
    ld   de, OFFSET_TILES
    add  hl, de
    ld   de, (room_ptr)
    add  hl, de
    push hl
    pop  ix                        ; IX = tile pointer

    push iy
    pop  bc                        ; B = Row, C = Col
    call Gfx_DrawTile

    pop  ix
    pop  hl
    pop  de
    pop  bc
    pop  iy
    ret

; -------------------------------------------------------------------
; CheckWillyItemCollision
;
; Verifica collisione bounding box (16x16 vs 8x8) tra Willy e un item.
; Input:
;   A = Item Col (0..31)
;   H = Item Row (0..15)
; Output:
;   Carry Set = Collisione
;   Carry Clear = Nessuna collisione
; -------------------------------------------------------------------
CheckWillyItemCollision:
    push bc
    push de
    push hl

    ; ItemLeft = Col * 8, ItemRight = ItemLeft + 7
    ld   l, a
    add  a, a                      ; *2
    add  a, a                      ; *4
    add  a, a                      ; *8
    ld   e, a                      ; E = ItemLeft
    add  a, 7
    ld   d, a                      ; D = ItemRight

    ld   bc, (PlayerPos)           ; B = WillyY, C = WillyX

    ; WillyLeft <= ItemRight
    ld   a, c
    cp   d
    jr   z, .x_ok
    jr   c, .x_ok
    jr   .no_collision

.x_ok:
    ; WillyRight >= ItemLeft (WillyRight = WillyX + 7 o 15)
    add  a, 7
    cp   e
    jr   z, .y_check
    jr   nc, .y_check
    jr   .no_collision

.y_check:
    pop  hl
    push hl

    ; ItemTop = Row * 8, ItemBottom = ItemTop + 7
    ld   a, h
    add  a, a                      ; *2
    add  a, a                      ; *4
    add  a, a                      ; *8
    ld   e, a                      ; ItemTop
    add  a, 7
    ld   d, a                      ; ItemBottom

    ; WillyTop <= ItemBottom
    ld   a, b
    cp   d
    jr   z, .y_ok
    jr   c, .y_ok
    jr   .no_collision

.y_ok:
    ; WillyBottom >= ItemTop (WillyBottom = WillyY + 15)
    add  a, 15
    cp   e
    jr   z, .collision
    jr   nc, .collision
    jr   .no_collision

.collision:
    pop  hl
    pop  de
    pop  bc
    scf
    ret

.no_collision:
    pop  hl
    pop  de
    pop  bc
    or   a
    ret

; -------------------------------------------------------------------
; Items_CheckCollision
;
; Controlla se Willy collide con uno degli item attivi nella stanza.
; -------------------------------------------------------------------
Items_CheckCollision:
    push hl
    push de
    push bc
    push iy

    ld   a, (num_room_items)
    or   a
    jr   z, .done

    ld   b, a                      ; B = numero item attivi
    ld   iy, current_room_items

.loop:
    ld   a, (iy+2)                 ; Color / Active
    or   a
    jr   z, .next_item

    ld   c, (iy+0)                 ; C = Item Col (0..31)
    ld   h, (iy+1)                 ; H = Item Row (0..15)

    ld   a, c
    call CheckWillyItemCollision
    jr   nc, .next_item

    ; --- ITEM RACCOLTO ---
    ; 1. Imposta il flag collected nei dati stanza
    ld   l, (iy+3)
    ld   h, (iy+4)                 ; HL = puntatore al flag nei dati stanza
    ld   (hl), 0                   ; 0 = raccolto

    ; 2. Rimuovi dalla griglia items_grid
    ld   c, (iy+0)
    ld   b, (iy+1)
    push bc
    ld   h, 0
    ld   l, b
    add  hl, hl : add hl, hl : add hl, hl : add hl, hl : add hl, hl
    ld   e, c
    ld   d, 0
    add  hl, de
    ld   de, items_grid
    add  hl, de
    ld   (hl), 0
    pop  bc

    ; 3. Disattiva lo slot nella cache
    ld   (iy+2), 0

    ; 4. Decrementa il numero di item rimanenti nella stanza corrente
    ld   hl, num_room_items
    ld   a, (hl)
    or   a
    jr   z, .no_dec_room
    dec  (hl)
    jr   nz, .no_dec_room
    ; Ultimo item della stanza raccolto -> Attiva il portale!
    ld   a, 1
    ld   (game_objective_completed), a
.no_dec_room:

    ; Incrementa il conteggio globale degli item raccolti
    ld   a, (items_collected)
    inc  a
    ld   (items_collected), a

    ; 5. Aggiungi 100 punti allo Score, aggiorna High Score e aggiorna la visualizzazione HUD
    call Score_AddItemPoints

    ; 6. Ripristina il tile di sfondo
    call RestoreBackgroundCell

    ; 7. Suono di raccolta
    call Audio_PlayCollectSound

.next_item:
    ld   de, 5
    add  iy, de
    djnz .loop

.done:
    pop  iy
    pop  bc
    pop  de
    pop  hl
    ret

; -------------------------------------------------------------------
; CheckActiveItemAtCell
;
; Verifica rapida su griglia se c'è un item attivo alla cella (B=Col, C=Row)
; Output: Carry Set = Item presente, Carry Clear = Nessun item
; -------------------------------------------------------------------
CheckActiveItemAtCell:
    push de
    push hl

    ld   h, 0
    ld   l, c                      ; HL = Row
    add  hl, hl : add hl, hl : add hl, hl : add hl, hl : add hl, hl
    ld   e, b
    ld   d, 0
    add  hl, de
    ld   de, items_grid
    add  hl, de
    ld   a, (hl)
    or   a
    jr   z, .not_active

    pop  hl
    pop  de
    scf
    ret

.not_active:
    pop  hl
    pop  de
    or   a
    ret

; -------------------------------------------------------------------
; Score_AddItemPoints
; Aggiunge 100 punti allo Score del giocatore quando raccoglie un item.
; Aggiorna automaticamente l'High Score se Score > HighScore.
; -------------------------------------------------------------------
Score_AddItemPoints:
    push af
    push bc
    push de
    push hl

    ; Aggiungi 100 punti (byte 1 in BCD rappresenta centinaia/migliaia)
    ld   a, (player_score + 1)
    add  a, $01
    daa
    ld   (player_score + 1), a

    ; Riporto al byte 2 (decine di migliaia / centinaia di migliaia)
    ld   a, (player_score + 2)
    adc  a, 0
    daa
    ld   (player_score + 2), a

    ; Controlla se player_score ha superato high_score
    call Score_CheckAndUpdateHighScore

    ; Aggiorna visualizzazione a schermo
    call Gfx_UpdateScoreDisplay

    pop  hl
    pop  de
    pop  bc
    pop  af
    ret

; -------------------------------------------------------------------
; Score_CheckAndUpdateHighScore
; Se player_score > high_score, copia player_score in high_score.
; -------------------------------------------------------------------
Score_CheckAndUpdateHighScore:
    ; Confronto BCD a 3 byte (big-endian: byte 2 -> byte 1 -> byte 0)
    ; Byte 2:
    ld   a, (player_score + 2)
    ld   b, a
    ld   a, (high_score + 2)
    cp   b
    jr   c, .new_high_score    ; se high_score+2 < player_score+2 -> nuovo high score
    jr   nz, .done_check       ; se high_score+2 > player_score+2 -> nessun aggiornamento

    ; Byte 1:
    ld   a, (player_score + 1)
    ld   b, a
    ld   a, (high_score + 1)
    cp   b
    jr   c, .new_high_score
    jr   nz, .done_check

    ; Byte 0:
    ld   a, (player_score + 0)
    ld   b, a
    ld   a, (high_score + 0)
    cp   b
    jr   nc, .done_check       ; se high_score+0 >= player_score+0 -> nessun aggiornamento

.new_high_score:
    ld   a, (player_score + 0)
    ld   (high_score + 0), a
    ld   a, (player_score + 1)
    ld   (high_score + 1), a
    ld   a, (player_score + 2)
    ld   (high_score + 2), a

.done_check:
    ret
