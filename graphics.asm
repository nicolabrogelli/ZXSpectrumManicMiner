;===========================================================================
; graphics.asm
;===========================================================================

; -------------------------------------------------------------------
; Copia il set dei caratteri dalla ROM alla RAM
; -------------------------------------------------------------------
Gfx_CopyChars:
    ld   hl, $3D00             ; Indirizzo del set di caratteri originale in ROM (ASCII 32)
    ld   de, font_buffer + 256 ; Indirizzo in RAM per ASCII 32..127 (font_buffer + 32*8)
    ld   bc, 768               ; Numero di byte da copiare (96 caratteri * 8 byte ciascuno)
    ldir                       ; Copiare i dati
    ret

; -------------------------------------------------------------------
; Ridefinisci i caratteri (incluso quello per i bordi)
; -------------------------------------------------------------------
Gfx_DefineChars:
    ld   hl, Willy             ; Indirizzo dei dati del nuovo carattere
    ld   de, font_buffer + 8   ; Indirizzo di ASCII 1 nel nuovo set di caratteri (font_buffer + 1*8)
    ld   bc, 72                ; Numero di byte da copiare (9 caratteri * 8 byte)
    ldir                       ; Effettua la copia dei caratteri
    ld   hl, font_buffer       ; Indirizzo del nuovo set di caratteri in RAM (font base ASCII 0)
    ld   ($5C36), hl           ; Aggiornare la variabile di sistema CHARS
    ret

; -------------------------------------------------------------------
; Posiziona il cursore
; Input: B = Y, C = X
; -------------------------------------------------------------------
Gfx_At:
    push bc
    exx
    pop bc
    call $0a23
    exx
    ret

; -------------------------------------------------------------------
; Cambia colore inchiostro
; Input: A = colore
; -------------------------------------------------------------------
Gfx_Ink:
    exx
    and  $07               ; Garantisci colore 0..7
    ld   b, a
    ld   a, (ATTR_T)
    and  $f8
    or   b
    ld   (ATTR_T), a
    exx
    ret

; -------------------------------------------------------------------
; ===================================================================
; NUOVE ROUTINE DI RENDERING PIXEL-BY-PIXEL
; ===================================================================

; -------------------------------------------------------------------
; Calcola indirizzo schermo da coordinate pixel (X, Y)
; Input: H = Y (0..191), L = X (0..255)
; Output: HL = indirizzo schermo
; -------------------------------------------------------------------
Gfx_GetScreenAddr:
    ld a, h
    and %00000111     ; A = y2 y1 y0 (scanline offset)
    or  %01000000     ; Base dello schermo ($40)
    ld  d, a          ; D = high byte parziale
    
    ld  a, h
    and %11000000     ; A = y7 y6 000000 (third select)
    rrca
    rrca
    rrca              ; Shift a destra di 3 -> 000 y7 y6 000
    or  d
    ld  d, a          ; D = high byte completo (010 y7 y6 y2 y1 y0)
    
    ld  a, h
    and %00111000     ; A = 00 y5 y4 y3 000 (character row)
    add a, a
    add a, a          ; Shift a sinistra di 2 -> y5 y4 y3 00000
    ld  e, a          ; E = low byte parziale
    
    ld  a, l
    srl a
    srl a
    srl a              ; A = X / 8 (colonna)
    or  e
    ld  e, a          ; E = low byte completo
    
    ld  h, d
    ld  l, e          ; HL = indirizzo finale
    ret

; -------------------------------------------------------------------
; Incrementa indirizzo schermo alla riga (scanline) successiva
; Input/Output: HL = indirizzo schermo
; -------------------------------------------------------------------
Gfx_IncScreenLine:
    inc h             ; Vai alla riga successiva
    ld  a, h
    and 7             ; Controlla se la scanline è tornata a 0 (wrap)
    ret nz            ; Se non è 0, abbiamo finito!
    
    ld  a, l
    add a, 32         ; Altrimenti passa alla riga di caratteri successiva
    ld  l, a
    ret c             ; Se c'è carry, abbiamo cambiato terzo e H è già corretto!
    
    ; Se non c'è carry, rimaniamo nello stesso terzo. Ripristina il terzo corretto in H.
    ld  a, h
    sub 8
    ld  h, a
    ret

; -------------------------------------------------------------------
; Disegna uno sprite 8x8 a coordinate pixel (X, Y)
; Input: C = X, B = Y, IX = puntatore dati sprite (8 byte)
; -------------------------------------------------------------------
Gfx_DrawPixelSprite8x8:
    push bc
    push de
    push hl
    push ix
    
    ; 1. Calcola indirizzo schermo
    ld   h, b
    ld   l, c
    call Gfx_GetScreenAddr ; HL = indirizzo schermo
    
    ; 2. Calcola offset shift = X & 7
    ld   a, c
    and  7
    ld   b, a          ; B = shift offset (0..7)
    
    ld   c, 8          ; 8 linee
.line_loop:
    ld   a, (ix+0)     ; A = byte dello sprite
    ld   d, a
    ld   e, 0
    
    ld   a, b          ; Shift se necessario
    or   a
    jr   z, .no_shift
    
.shift_loop:
    srl  d
    rr   e
    dec  a
    jr   nz, .shift_loop
    
.no_shift:
    ; Scrivi sullo schermo (OR trasparente)
    ld   a, d
    or   (hl)
    ld   (hl), a
    inc  hl
    ld   a, e
    or   (hl)
    ld   (hl), a
    dec  hl            ; Ritorna alla colonna iniziale
    
    call Gfx_IncScreenLine ; Prossima scanline sullo schermo
    inc  ix            ; Prossimo byte dello sprite
    dec  c
    jr   nz, .line_loop
    
    pop  ix
    pop  hl
    pop  de
    pop  bc
    ret

; -------------------------------------------------------------------
; Ripristina un byte dello sfondo statico.
; Input: A = X del byte schermo in pixel (0, 8, 16...), D = Y pixel
; Output: A = byte di sfondo
; -------------------------------------------------------------------
Gfx_GetBackgroundByte:
    push hl
    push de
    push bc

    ld   c, a                  ; C = X pixel (0, 8, 16...)
    
    ; 1. Controlla se Y (in D) è fuori dalla griglia di layout (Y >= 128)
    ld   a, d
    cp   128
    jp   nc, .blank

    ; 2. Calcola Col = X / 8
    ld   a, c
    srl  a
    srl  a
    srl  a
    ld   c, a                  ; C = Col (0..31)

    ; 3. Calcola Row = Y / 8
    ld   a, d
    srl  a
    srl  a
    srl  a
    ld   e, a                  ; E = Row (0..15)

    ; 4. Calcola Scanline offset = (Y & 7) + 1 (byte 0 nel tile da 9 byte è l'attributo)
    ld   a, d
    and  7
    inc  a
    ld   b, a                  ; B = Scanline offset (1..8)

    ; 5. Controlla se c'è un Item Attivo in questa cella (Row E, Col C)
    push de
    push bc
    ld   b, c                  ; B = Col
    ld   c, e                  ; C = Row
    call CheckActiveItemAtCell
    jr   nc, .no_item

    ; --- ITEM ATTIVO PRESENTE ---
    pop  bc                    ; B = Scanline offset (1..8), C = Col
    pop  de                    ; D = Y, E = Row
    
    ld   a, b                  ; A = 1..8
    dec  a                     ; A = 0..7 (scanline per item da 8 byte)
    ld   e, a
    ld   d, 0
    ld   hl, (room_ptr)
    ld   bc, OFFSET_ITEM_GRAPHIC
    add  hl, bc
    add  hl, de                ; HL = indirizzo scanline item
    ld   a, (hl)               ; A = byte bitmap item

    pop  bc
    pop  de
    pop  hl
    ret

.no_item:
    pop  bc                    ; B = Scanline offset (1..8), C = Col
    pop  de                    ; D = Y, E = Row

    ; 5b. Controlla se la cella (Row E, Col C) appartiene al Portale (16x16 pixel a OFFSET_PORTAL = 655)
    push de
    push bc
    ld   hl, (room_ptr)
    ld   de, OFFSET_PORTAL + 33
    add  hl, de
    ld   a, (hl)
    inc  hl
    ld   h, (hl)
    ld   l, a                  ; HL = AttrAddr (es. 23997)
    ld   de, -23552
    add  hl, de                ; HL = AttrOffset

    ld   a, l
    and  31
    ld   d, a                  ; D = PortalCol (0..31)

    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    ld   a, l                  ; A = PortalRow (0..15)

    pop  bc                    ; B = Scanline offset (1..8), C = Col
    pop  de                    ; D = Y, E = Row

    ; Confronta Row (in E) con PortalRow (in A): DeltaRow = E - PortalRow
    sub  e
    neg
    cp   2
    jr   nc, .not_portal_bg

    ld   h, a                  ; H = DeltaRow (0..1)

    ; Confronta Col (in C) con PortalCol (in D): DeltaCol = C - PortalCol
    ld   a, c
    sub  d
    cp   2
    jr   nc, .not_portal_bg

    ; A = DeltaCol (0..1)
    ld   l, a                  ; L = DeltaCol (0..1)

    ; --- LA CELLA APPARTIENE AL PORTALE! ---
    ; Calcola offset nella bitmap del portale (32 byte):
    ; ScanlineIndex = (DeltaRow * 8) + (ScanlineOffset - 1)
    ; BitmapOffset = (DeltaRow * 16) + (Scanline * 2) + DeltaCol
    ld   a, b                  ; A = Scanline offset (1..8)
    dec  a                     ; A = Scanline (0..7)
    add  a, a                  ; *2
    add  a, l                  ; + DeltaCol
    ld   e, a
    ld   a, h                  ; A = DeltaRow (0..1)
    or   a
    jr   z, .portal_top_row
    ld   a, e
    add  a, 16                 ; +16 per la riga inferiore del portale
    ld   e, a
.portal_top_row:
    ld   d, 0
    ld   hl, (room_ptr)
    ld   bc, OFFSET_PORTAL + 1 ; Inizio bitmap 32 byte del portale
    add  hl, bc
    add  hl, de
    ld   a, (hl)               ; A = byte bitmap del portale

    pop  bc
    pop  de
    pop  hl
    ret

.not_portal_bg:
    ; 6. Ottieni il tipo di cella da unpacked_layout
    ld   a, e                  ; A = Row (0..15)
    ; C = Col (0..31)
    call GetCellFromUnpacked   ; A = tile index (0..7)

    ; Controlla se è un Crumbling Floor (Tile 2)
    cp   2
    jr   nz, .not_crumbling_bg

    ; Calcola offset in crumbling_grid: Row * 32 + Col
    push hl
    push de
    ld   l, e
    ld   h, 0
    add  hl, hl : add hl, hl : add hl, hl : add hl, hl : add hl, hl
    ld   e, c
    ld   d, 0
    add  hl, de
    ld   de, crumbling_grid
    add  hl, de
    ld   a, (hl)               ; A = crumbling stage (0..8)
    pop  de
    pop  hl

    ; Se stage > 0 e ScanlineOffset <= stage, la scanline è già sgretolata!
    or   a
    jr   z, .crumble_intact
    cp   b
    jr   nc, .blank            ; Se stage >= scanline_offset (1..8), linea cancellata!

.crumble_intact:
    ld   a, 2                  ; Tile 2

.not_crumbling_bg:
    ; 7. Calcola puntatore alla scanline del tile:
    ; HL = (room_ptr + OFFSET_TILES) + (A * 9) + ScanlineOffset (in B)
    ld   l, a
    ld   h, 0
    ld   e, a
    ld   d, 0
    add  hl, hl                ; *2
    add  hl, hl                ; *4
    add  hl, hl                ; *8
    add  hl, de                ; *9 (HL = A * 9)

    ld   de, OFFSET_TILES      ; 544
    add  hl, de
    ld   de, (room_ptr)
    add  hl, de                ; HL = room_ptr + OFFSET_TILES + A * 9 (byte 0 = attributo)

    ld   e, b                  ; E = Scanline offset (1..8)
    ld   d, 0
    add  hl, de                ; HL = puntatore alla scanline bitmap richiesta
    ld   a, (hl)               ; A = byte bitmap originale del tile

    pop  bc
    pop  de
    pop  hl
    ret

.blank:
    pop  bc
    pop  de
    pop  hl
    xor  a
    ret

; -------------------------------------------------------------------
; Cancella uno sprite 8x8 a coordinate pixel (X, Y) ripristinando lo sfondo
; Input: C = X, B = Y
; -------------------------------------------------------------------
Gfx_ErasePixelSprite8x8:
    push bc
    push de
    push hl
    
    ld   h, b
    ld   l, c
    call Gfx_GetScreenAddr ; HL = indirizzo schermo (modifica D ed E)
    
    ld   d, b          ; D = Y corrente
    ld   a, c
    and  $f8
    ld   e, a          ; E = X del primo byte schermo in pixel
    
    ld   a, c
    and  7
    jr   z, .erase_1byte
    
    ld   c, 8          ; 8 linee
.erase_loop_2:
    ld   a, e
    call Gfx_GetBackgroundByte
    ld   (hl), a
    inc  hl
    ld   a, e
    add  a, 8
    call Gfx_GetBackgroundByte
    ld   (hl), a
    dec  hl
    
    call Gfx_IncScreenLine
    inc  d
    dec  c
    jr   nz, .erase_loop_2
    
    pop  hl
    pop  de
    pop  bc
    ret

.erase_1byte:
    ld   c, 8          ; 8 linee
.erase_loop_1:
    ld   a, e
    call Gfx_GetBackgroundByte
    ld   (hl), a
    
    call Gfx_IncScreenLine
    inc  d
    dec  c
    jr   nz, .erase_loop_1
    
    pop  hl
    pop  de
    pop  bc
    ret

; -------------------------------------------------------------------
; Disegna uno sprite 16x16 a coordinate pixel (X, Y)
; Input: C = X, B = Y, IX = puntatore dati sprite (32 byte)
; -------------------------------------------------------------------
Gfx_DrawPixelSprite16x16:
    push bc
    push de
    push hl
    push ix
    
    ; 1. Salva la coordinata X per calcolare lo shift
    ld   a, c
    and  7
    ld   (sprite_shift), a
    
    ; 2. Calcola indirizzo schermo
    ld   h, b
    ld   l, c
    call Gfx_GetScreenAddr ; HL = indirizzo schermo
    
    ld   c, 16          ; 16 linee/scanline
.line_loop:
    ld   d, (ix+0)     ; D = primo byte dello sprite
    ld   e, (ix+1)     ; E = secondo byte dello sprite
    
    ; Esegui lo shift a destra se necessario
    ld   a, (sprite_shift)
    or   a
    jr   z, .no_shift
    
    push bc            ; Salva il contatore delle linee (C) e lo shift (B)
    ld   b, a          ; B = contatore shift
    xor  a             ; A = terzo byte (inizializzato a 0)
    
.shift_loop:
    srl  d
    rr   e
    rr   a
    djnz .shift_loop
    
    pop  bc            ; Ripristina C (contatore linee)
    
    ; Scrive i 3 byte sullo schermo (OR trasparente)
    ld   b, a          ; Salva il 3° byte dello sprite in B
    ld   a, d
    or   (hl)
    ld   (hl), a
    inc  hl
    ld   a, e
    or   (hl)
    ld   (hl), a
    inc  hl
    ld   a, b          ; Recupera il 3° byte dello sprite
    or   (hl)
    ld   (hl), a
    dec  hl
    dec  hl            ; Ripristina HL alla colonna iniziale
    jr   .next_line
    
.no_shift:
    ; Nessuno shift: scrivi i 2 byte direttamente (OR trasparente)
    ld   a, d
    or   (hl)
    ld   (hl), a
    inc  hl
    ld   a, e
    or   (hl)
    ld   (hl), a
    dec  hl            ; Ripristina HL alla colonna iniziale
    
.next_line:
    call Gfx_IncScreenLine ; Vai alla prossima riga dello schermo
    inc  ix
    inc  ix            ; Avanza di 2 byte nei dati dello sprite
    dec  c
    jr   nz, .line_loop
    
    pop  ix
    pop  hl
    pop  de
    pop  bc
    ret

; -------------------------------------------------------------------
; Cancella uno sprite 16x16 ripristinando lo sfondo statico su 2 o 3 colonne
; Input: C = X, B = Y
; -------------------------------------------------------------------
Gfx_ErasePixelSprite16x16:
    push bc
    push de
    push hl
    
    ld   h, b
    ld   l, c
    call Gfx_GetScreenAddr ; HL = indirizzo schermo (modifica D ed E)
    
    ld   d, b          ; D = Y corrente
    ld   a, c
    and  $f8
    ld   e, a          ; E = X del primo byte schermo in pixel
    
    ld   a, c
    and  7
    jr   z, .erase_2bytes
    
    ld   c, 16          ; 16 linee
.erase_loop_3:
    ld   a, e
    call Gfx_GetBackgroundByte
    ld   (hl), a
    inc  hl
    ld   a, e
    add  a, 8
    call Gfx_GetBackgroundByte
    ld   (hl), a
    inc  hl
    ld   a, e
    add  a, 16
    call Gfx_GetBackgroundByte
    ld   (hl), a
    dec  hl
    dec  hl
    
    call Gfx_IncScreenLine
    inc  d
    dec  c
    jr   nz, .erase_loop_3
    
    pop  hl
    pop  de
    pop  bc
    ret

.erase_2bytes:
    ld   c, 16          ; 16 linee
.erase_loop_2:
    ld   a, e
    call Gfx_GetBackgroundByte
    ld   (hl), a
    inc  hl
    ld   a, e
    add  a, 8
    call Gfx_GetBackgroundByte
    ld   (hl), a
    dec  hl
    
    call Gfx_IncScreenLine
    inc  d
    dec  c
    jr   nz, .erase_loop_2
    
    pop  hl
    pop  de
    pop  bc
    ret

; -------------------------------------------------------------------
; Disegna il player (testa e corpo se Willy, oppure MaialeSprite se in TheNightmareRoom)
; -------------------------------------------------------------------
Gfx_PrintPlayer:
    push ix
    push de
    push hl
    push bc
    
    ; --- RENDERING STANDARD WILLY ---
    ; 1. Determina sprite per la testa (sinistra o destra)
    ld   a, (direction)
    cp   1                 ; Sinistra?
    jr   nz, .right_head
    
    ld   ix, Willy + (4 * 8) ; 5° tile (HEAD_GRAPH_LEFT)
    jr   .draw_head
    
.right_head:
    ld   ix, Willy + (0 * 8) ; 1° tile (HEAD_GRAPH_RIGHT)
    
.draw_head:
    ld   bc, (PlayerPos)   ; C = PlayerX, B = PlayerY
    call Gfx_DrawPixelSprite8x8 ; Disegna testa
    
    ; 2. Determina sprite per il corpo (sinistra o destra con frame animazione)
    ld   a, (direction)
    cp   1                 ; Sinistra?
    jr   nz, .right_body
    
    ; Corpo a sinistra
    ld   a, (body_state)   ; 0, 1, 2
    add  a, 5              ; offset del tile per il corpo sinistro (5, 6, 7)
    add  a, a              ; *2
    add  a, a              ; *4
    add  a, a              ; *8
    ld   e, a
    ld   d, 0
    ld   ix, Willy
    add  ix, de
    jr   .draw_body

.right_body:
    ; Corpo a destra
    ld   a, (body_state)   ; 0, 1, 2
    add  a, 1              ; offset del tile per il corpo destro (1, 2, 3)
    add  a, a              ; *2
    add  a, a              ; *4
    add  a, a              ; *8
    ld   e, a
    ld   d, 0
    ld   ix, Willy
    add  ix, de

.draw_body:
    ld   bc, (PlayerPos)   ; C = PlayerX, B = PlayerY
    ld   a, b
    add  a, 8
    ld   b, a              ; B = PlayerY + 8
    call Gfx_DrawPixelSprite8x8 ; Disegna corpo

    ; 3. Imposta gli attributi colore di Willy e gestisce il secondo piano rispetto alle tiles
    ld   bc, (PlayerPos)   ; C = PlayerX, B = PlayerY
    call Gfx_ApplyPlayerTileLayers

.done_print:
    pop  bc
    pop  hl
    pop  de
    pop  ix
    ret

; -------------------------------------------------------------------
; Gfx_ApplyPlayerTileLayers
; Gestisce la colorazione e il livello di Willy rispetto alle tiles della stanza:
; - Scansiona tutte le celle 8x8 sovrapposte dallo sprite 16x16 di Willy (PlayerPos).
; - Se la cella è spazio vuoto (tile 0): applica il colore bianco brillante di Willy.
; - Se la cella contiene un tile della stanza (Floor, Wall, Crumbling, Conveyor, Nasty, Portal, Item):
;   la cella mantiene l'attributo originale del tile, così la parte di Willy sovrapposta
;   prende il colore del tile, esattamente come nel gioco originale per ZX Spectrum!
; Input: C = PlayerX, B = PlayerY
; -------------------------------------------------------------------
Gfx_ApplyPlayerTileLayers:
    push hl
    push de
    push bc

    ; Se Y >= 128, esci
    ld   a, b
    cp   128
    jp   nc, .done_layers

    ; Calcola ColStart (E) e ColEnd (C)
    ld   a, c
    srl  a : srl a : srl a
    ld   e, a                  ; E = ColStart (0..31)

    ld   a, c
    add  a, 15
    srl  a : srl a : srl a
    ld   c, a                  ; C = ColEnd (0..31)

    ; Calcola RowStart (H) e RowEnd (L)
    ld   a, b
    srl  a : srl a : srl a
    ld   h, a                  ; H = RowStart (0..15)

    ld   a, b
    add  a, 15
    srl  a : srl a : srl a
    ld   l, a                  ; L = RowEnd (0..15)

.row_loop:
    ld   a, h
    cp   l
    jr   z, .ok_row
    jp   nc, .done_layers
.ok_row:
    push bc
    push de

    ld   b, e                  ; B = Col corrente
.col_loop:
    ld   a, b
    cp   c
    jr   z, .ok_col
    jr   nc, .col_done
.ok_col:
    ; Processa la cella a Row H, Col B
    call IsCellEmptyBackground
    jr   c, .cell_is_empty

    ; --- LA CELLA CONTIENE UN TILE DELLA STANZA ---
    ; La parte di Willy sovrapposta al tile prende il colore (attributo) del tile!
    push hl
    push bc
    call Gfx_GetCellAttribute  ; Input: H = Row, B = Col -> Output: A = colore tile
    pop  bc
    pop  hl

    push hl
    ld   e, a                  ; E = attributo originale del tile
    ld   l, h
    ld   h, 0
    add  hl, hl : add hl, hl : add hl, hl : add hl, hl : add hl, hl
    ld   a, b
    add  a, l
    ld   l, a
    jr   nc, .no_c_tile
    inc  h
.no_c_tile:
    ld   a, h
    add  a, $58
    ld   h, a                  ; HL = AttrAddr ($5800 + Row * 32 + Col)
    ld   (hl), e               ; Applica l'attributo del tile alla cella
    pop  hl
    jr   .next_col

.cell_is_empty:
    ; --- LA CELLA È SPAZIO VUOTO ---
    ; Applica il colore bianco brillante di Willy
    push hl
    ld   l, h
    ld   h, 0
    add  hl, hl : add hl, hl : add hl, hl : add hl, hl : add hl, hl
    ld   a, b
    add  a, l
    ld   l, a
    jr   nc, .no_c
    inc  h
.no_c:
    ld   a, h
    add  a, $58
    ld   h, a                  ; HL = AttrAddr ($5800 + Row * 32 + Col)

    ld   a, (hl)
    and  $f8
    or   (WHITE | $40)         ; Bianco brillante
    ld   (hl), a
    pop  hl

.next_col:
    inc  b                     ; Prossima colonna
    jr   .col_loop

.col_done:
    pop  de
    pop  bc
    inc  h                     ; Prossima riga
    jr   .row_loop

.done_layers:
    pop  bc
    pop  de
    pop  hl
    ret

; -------------------------------------------------------------------
; IsCellEmptyBackground
; Verifica se la cella (H = Row 0..15, B = Col 0..31) è spazio vuoto (tile 0).
; Output:
;   Carry Set   = Cella vuota (nessun tile, nessun item, nessun portale)
;   Carry Clear = Cella occupata da un tile della stanza, item o portale
; -------------------------------------------------------------------
IsCellEmptyBackground:
    push hl
    push de
    push bc

    ; 1. Se Row >= 16, fuori dal layout di gioco
    ld   a, h
    cp   16
    jr   nc, .not_empty

    ; 2. Controlla se c'è un Item attivo
    push bc
    ld   c, h                  ; C = Row
    call CheckActiveItemAtCell
    pop  bc
    jr   c, .not_empty

    ; 3. Controlla se appartiene al Portale (16x16)
    push hl
    push de
    push bc
    ld   hl, (room_ptr)
    ld   de, OFFSET_PORTAL + 33
    add  hl, de
    ld   a, (hl)
    inc  hl
    ld   h, (hl)
    ld   l, a                  ; HL = AttrAddr
    ld   de, -23552
    add  hl, de                ; HL = AttrOffset

    ld   a, l
    and  31
    ld   d, a                  ; D = PortalCol

    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    ld   a, l                  ; A = PortalRow

    pop  bc                    ; B = Col
    pop  de
    pop  hl                    ; H = Row

    ; DeltaRow = H - PortalRow (in A)
    sub  h
    neg
    cp   2
    jr   nc, .check_layout_tile

    ; DeltaCol = B - PortalCol (in D)
    ld   a, b
    sub  d
    cp   2
    jr   c, .not_empty         ; Se DeltaRow < 2 E DeltaCol < 2 -> È nel portale!

.check_layout_tile:
    ; 4. Controlla il tipo di tile in unpacked_layout
    ld   a, h                  ; A = Row
    ld   c, b                  ; C = Col
    call GetCellFromUnpacked   ; A = tile index (0..7)
    or   a
    jr   nz, .not_empty        ; Se != 0, contiene un tile (Floor, Wall, Crumbling, Conveyor, Nasty...)

    ; La cella è completamente vuota!
    pop  bc
    pop  de
    pop  hl
    scf                        ; Carry Set = Vuota
    ret

.not_empty:
    pop  bc
    pop  de
    pop  hl
    or   a                     ; Carry Clear = Occupata da tile/elemento stanza
    ret

; -------------------------------------------------------------------
; Aggiorna il player a schermo cancellandolo e ridisegnandolo solo se mosso o animato
; -------------------------------------------------------------------
Gfx_UpdatePlayer:
    push bc
    push de
    push hl
    
    ; Durante il tempo di sicurezza, forza il ridisegno ad ogni frame per permettere il lampeggio
    ld   a, (willy_safety_timer)
    or   a
    jr   nz, .player_moved
    
    ; 1. Controlla se la posizione o l'animazione sono cambiate
    ld   bc, (PlayerPos)            ; C = PlayerX, B = PlayerY
    ld   de, (player_drawn_pos)     ; E = Drawn X, D = Drawn Y
    ld   a, b
    cp   d
    jr   nz, .player_moved
    ld   a, c
    cp   e
    jr   nz, .player_moved
    
    ld   a, (direction)
    ld   hl, player_old_dir
    cp   (hl)
    jr   nz, .player_moved
    
    ld   a, (body_state)
    ld   hl, player_old_body
    cp   (hl)
    jr   nz, .player_moved

    ; Willy non si è mosso. Ma se un nemico lo ha sovrascritto, ridisegnalo senza prima cancellarlo!
    ld   a, (willy_needs_redraw)
    or   a
    jr   nz, .redraw_overlay_only
    jr   .player_no_change

.player_moved:
    ; 2. Cancella lo sprite dalla posizione precedentemente disegnata solo se Willy si è mosso
    ld   a, (player_drawn_pos+1)
    cp   $FF
    jr   z, .redraw_overlay_only
    
    ld   bc, (player_drawn_pos)
    call Gfx_ErasePixelSprite8x8    ; Cancella testa
    ld   bc, (player_drawn_pos)
    ld   a, b
    add  a, 8
    ld   b, a
    call Gfx_ErasePixelSprite8x8    ; Cancella corpo
    ld   bc, (player_drawn_pos)
    call Gfx_RestoreEnemyColorAttributes ; Ripristina sfondo

.redraw_overlay_only:
    ; Durante il timer di sicurezza, fa lampeggiare lo sprite
    ld   a, (willy_safety_timer)
    or   a
    jr   z, .do_print
    
    ld   a, (counter)
    and  4
    jr   z, .skip_print_blink       ; Nelle fasi "off" del lampeggio, non ridisegnare

.do_print:
    ; 3. Disegna il player nella nuova posizione
    call Gfx_PrintPlayer

.skip_print_blink:
    ; 4. Registra lo stato disegnato a schermo
    ld   bc, (PlayerPos)
    ld   (player_drawn_pos), bc
    ld   a, (direction)
    ld   (player_old_dir), a
    ld   a, (body_state)
    ld   (player_old_body), a
    
    xor  a
    ld   (willy_needs_redraw), a

.player_no_change:
    pop  hl
    pop  de
    pop  bc
    ret

; -------------------------------------------------------------------
; Cancella il player alle coordinate correntemente disegnate
; -------------------------------------------------------------------
Gfx_DeleteCharAtOldPos:
    push bc
    push de
    push hl
    ld   a, (player_drawn_pos+1)
    cp   $FF
    jr   z, .skip_del
    
    ld   bc, (player_drawn_pos)
    call Gfx_ErasePixelSprite8x8    ; Cancella testa
    ld   bc, (player_drawn_pos)
    ld   a, b
    add  a, 8
    ld   b, a
    call Gfx_ErasePixelSprite8x8    ; Cancella corpo
    ld   bc, (player_drawn_pos)
    call Gfx_RestoreEnemyColorAttributes ; Ripristina sfondo

.done_del:
    ld   a, $FF
    ld   (player_drawn_pos+1), a    ; Resetta posizione disegnata
.skip_del:
    pop  hl
    pop  de
    pop  bc
    ret

; -------------------------------------------------------------------
; Disegna stringa
; Input: HL = stringa, B = lunghezza
; -------------------------------------------------------------------
Gfx_PrintString:
    ld   a, (hl)
    rst  $10
    inc  hl
    djnz Gfx_PrintString
    ret

; -------------------------------------------------------------------
; Disegna il nome della stanza sotto la piattaforma di base (Riga 16)
; -------------------------------------------------------------------
Gfx_PrintRoomName:
    push af
    push bc
    push de
    push hl

    ; Calcola una volta sola l'indirizzo del nome stanza
    ld   hl, (room_ptr)
    ld   de, OFFSET_ROOM_NAME
    add  hl, de
    push hl                    ; Salva puntatore base del nome stanza

    ; 1. Rendering diretto in VRAM dei 32 caratteri del nome stanza a Riga 16 ($5000..$571F)
    ld   c, 0                  ; C = Colonna (0..31)
.room_name_loop:
    pop  hl
    push hl                    ; HL = puntatore base del nome stanza
    ld   e, c
    ld   d, 0
    add  hl, de
    ld   a, (hl)               ; A = codice ASCII del carattere

    ; Indirizzo nel font_buffer: font_buffer + ASCII * 8
    ld   l, a
    ld   h, 0
    add  hl, hl                ; *2
    add  hl, hl                ; *4
    add  hl, hl                ; *8
    ld   de, font_buffer
    add  hl, de                ; HL = puntatore bitmap font (8 byte)

    ; DE = Indirizzo VRAM scanline 0 per Riga 16, Colonna C ($5000 + C)
    ld   a, c
    ld   e, a
    ld   d, $50                ; DE = $5000 + C

    ; Copia le 8 scanline
    ld   a, (hl) : ld (de), a : inc hl : inc d  ; Scanline 0 ($50xx)
    ld   a, (hl) : ld (de), a : inc hl : inc d  ; Scanline 1 ($51xx)
    ld   a, (hl) : ld (de), a : inc hl : inc d  ; Scanline 2 ($52xx)
    ld   a, (hl) : ld (de), a : inc hl : inc d  ; Scanline 3 ($53xx)
    ld   a, (hl) : ld (de), a : inc hl : inc d  ; Scanline 4 ($54xx)
    ld   a, (hl) : ld (de), a : inc hl : inc d  ; Scanline 5 ($55xx)
    ld   a, (hl) : ld (de), a : inc hl : inc d  ; Scanline 6 ($56xx)
    ld   a, (hl) : ld (de), a                   ; Scanline 7 ($57xx)

    inc  c
    ld   a, c
    cp   32
    jr   c, .room_name_loop

    pop  hl                    ; Ripulisci lo stack dal puntatore nome stanza

    ; 2. Imposta attributi colore Giallo Brillante per Riga 16 ($5A00..$5A1F)
    ld   hl, $5a00
    ld   (hl), (YELLOW | $40)
    ld   de, $5a01
    ld   bc, 31
    ldir

    pop  hl
    pop  de
    pop  bc
    pop  af

    ; Disegna la riga di stato (High score & Score) a Riga 18
    call Gfx_UpdateScoreDisplay

    ; Disegna i 7 Willy in basso a sinistra (Row 19, 20)
    call Gfx_PrintWillyLives
    ret

; -------------------------------------------------------------------
; Gfx_Clear16x16_Black
; Azzera (pulisce a nero) un blocco di 16x16 pixel alla coordinata (C, B)
; Input: C = X, B = Y
; -------------------------------------------------------------------
Gfx_Clear16x16_Black:
    push bc
    push de
    push hl
    
    ld   h, b
    ld   l, c
    call Gfx_GetScreenAddr      ; HL = indirizzo schermo per (X, Y)
    
    ld   c, 16                  ; 16 scanline
.clear_loop:
    xor  a
    ld   (hl), a
    inc  hl
    ld   (hl), a
    dec  hl
    call Gfx_IncScreenLine
    dec  c
    jr   nz, .clear_loop
    
    pop  hl
    pop  de
    pop  bc
    ret

; -------------------------------------------------------------------
; Gfx_Clear2Scanlines_Black
; Azzera 2 scanline di 16 pixel alla coordinata (X=120, Y=B)
; Input: B = Y
; -------------------------------------------------------------------
Gfx_Clear2Scanlines_Black:
    push bc
    push de
    push hl

    ld   c, 120
    ld   h, b
    ld   l, c
    call Gfx_GetScreenAddr      ; HL = indirizzo schermo per (X=120, Y=B)

    xor  a
    ld   (hl), a
    inc  hl
    ld   (hl), a
    dec  hl
    call Gfx_IncScreenLine
    ld   (hl), a
    inc  hl
    ld   (hl), a

    pop  hl
    pop  de
    pop  bc
    ret

; ===================================================================
; TITLE SCREEN DATA & ROUTINE
; ===================================================================

title_banner_1:
    db "   * * *  MANIC MINER  * * *    "
title_banner_2:
    db "   THE SPECTRUM 48K ADVENTURE   "
title_sep_line:
    db "--------------------------------"
title_goal_str:
    db "  COLLECT ALL ITEMS BEFORE BED  "
title_press_enter:
    db " > >  PRESS  ENTER  TO START < <"
title_controls_hdr:
    db "           CONTROLS:            "
title_ctrl_left:
    db "    O : LEFT        P : RIGHT   "
title_ctrl_jump:
    db "    Z : JUMP    ENTER : START   "
title_copyright:
    ;db " (C) 2026 SOFTWARE PROJECTS LTD "
    db "   2026 8BIT SOFTWARE PROJECT   "

title_color_table:
    db $46, $47, $45, $44, $46, $42, $43, $47   ; Tabella ciclica colori Bright per "PRESS ENTER TO START"

; -------------------------------------------------------------------
; Gfx_DrawTitleScreen
; Disegna la schermata iniziale (Title Screen):
; - Bordo nero e pulizia schermo.
; - Titolo "MANIC MINER" e sottotitolo.
; - Separatori grafici.
; - Sprite decorativi (Willy a sinistra, Maria a destra).
; - Obiettivo di gioco.
; - Messaggio "PRESS ENTER TO START".
; - Riepilogo controlli (O, P, Z, ENTER).
; - Copyright.
; (Tutte le righe sono comprese tra 0 e 20 per evitare errori "Out of screen" della ROM)
; -------------------------------------------------------------------
Gfx_DrawTitleScreen:
    push af
    push bc
    push de
    push hl
    push ix

    ; 1. Bordo hardware e schermo a nero
    xor  a
    out  ($fe), a              ; Bordo a nero
    ld   hl, ATTR_P
    ld   (hl), a               ; Paper/Ink = 0 (Nero)
    call CLS                   ; Pulisce tutti i pixel e gli attributi a nero
    ld   (hl), $07             ; Ripristina ATTR_P a $07
    ld   a, $07
    ld   (ATTR_T), a           ; Ripristina ATTR_T a $07

    ; 2. Stampa riga 1: Titolo principale (Riga 1, Colonna 0)
    ld   a, 22
    rst  $10
    ld   a, 1
    rst  $10
    ld   a, 0
    rst  $10
    ld   hl, title_banner_1
    ld   b, 32
    call Gfx_PrintString

    ; Imposta attributi riga 1 a Giallo Brillante ($5820)
    ld   hl, $5820
    ld   b, 32
    ld   a, YELLOW | $40
.attr_r1:
    ld   (hl), a
    inc  hl
    djnz .attr_r1

    ; 3. Stampa riga 3: Sottotitolo (Riga 3, Colonna 0)
    ld   a, 22
    rst  $10
    ld   a, 3
    rst  $10
    ld   a, 0
    rst  $10
    ld   hl, title_banner_2
    ld   b, 32
    call Gfx_PrintString

    ; Imposta attributi riga 3 a Ciano Brillante ($5860)
    ld   hl, $5860
    ld   b, 32
    ld   a, CYAN | $40
.attr_r3:
    ld   (hl), a
    inc  hl
    djnz .attr_r3

    ; 4. Stampa riga 4: Separatore (Riga 4, Colonna 0)
    ld   a, 22
    rst  $10
    ld   a, 4
    rst  $10
    ld   a, 0
    rst  $10
    ld   hl, title_sep_line
    ld   b, 32
    call Gfx_PrintString

    ; Imposta attributi riga 4 a Blu ($5880)
    ld   hl, $5880
    ld   b, 32
    ld   a, BLUE
.attr_r4:
    ld   (hl), a
    inc  hl
    djnz .attr_r4

    ; 5. Disegna gli sprite al centro dello schermo (Y = 56, corrispondente a righe 7-8):
    ; 5a. Willy a X = 104, Y = 56 (B = 56, C = 104)
    ld   bc, $3868             ; B = Y = 56 ($38), C = X = 104 ($68)
    ld   ix, Willy + (0 * 8)   ; HEAD_GRAPH_RIGHT
    call Gfx_DrawPixelSprite8x8

    ld   bc, $4068             ; B = Y = 64 ($40), C = X = 104 ($68)
    ld   ix, Willy + (1 * 8)   ; Body right frame 0
    call Gfx_DrawPixelSprite8x8

    ld   bc, $3868
    ld   a, WHITE | $40
    call Gfx_SetEnemyColorAttributes

    ; 5b. Maria / VecchiaSprite a X = 136, Y = 56 (B = 56, C = 136)
    ld   bc, $3888             ; B = Y = 56 ($38), C = X = 136 ($88)
    ld   ix, VecchiaSprite     ; Frame 1
    call Gfx_DrawPixelSprite16x16

    ld   bc, $3888
    ld   a, YELLOW | $40
    call Gfx_SetEnemyColorAttributes

    ; 6. Stampa riga 10: Obiettivo (Riga 10, Colonna 0)
    ld   a, 22
    rst  $10
    ld   a, 10
    rst  $10
    ld   a, 0
    rst  $10
    ld   hl, title_goal_str
    ld   b, 32
    call Gfx_PrintString

    ; Imposta attributi riga 10 a Verde Brillante ($5940)
    ld   hl, $5940
    ld   b, 32
    ld   a, GREEN | $40
.attr_r10:
    ld   (hl), a
    inc  hl
    djnz .attr_r10

    ; 7. Stampa riga 12: "PRESS ENTER TO START" (Riga 12, Colonna 0)
    ld   a, 22
    rst  $10
    ld   a, 12
    rst  $10
    ld   a, 0
    rst  $10
    ld   hl, title_press_enter
    ld   b, 32
    call Gfx_PrintString

    ; Imposta attributi iniziali riga 12 a Giallo Brillante ($5980)
    ld   hl, $5980
    ld   b, 32
    ld   a, YELLOW | $40
.attr_r12:
    ld   (hl), a
    inc  hl
    djnz .attr_r12

    ; 8. Stampa riga 14: Separatore (Riga 14, Colonna 0)
    ld   a, 22
    rst  $10
    ld   a, 14
    rst  $10
    ld   a, 0
    rst  $10
    ld   hl, title_sep_line
    ld   b, 32
    call Gfx_PrintString

    ; Imposta attributi riga 14 a Blu ($59C0)
    ld   hl, $59c0
    ld   b, 32
    ld   a, BLUE
.attr_r14:
    ld   (hl), a
    inc  hl
    djnz .attr_r14

    ; 9. Stampa riga 15: Intestazione Controlli (Riga 15, Colonna 0)
    ld   a, 22
    rst  $10
    ld   a, 15
    rst  $10
    ld   a, 0
    rst  $10
    ld   hl, title_controls_hdr
    ld   b, 32
    call Gfx_PrintString

    ; Imposta attributi riga 15 a Bianco Brillante ($59E0)
    ld   hl, $59e0
    ld   b, 32
    ld   a, WHITE | $40
.attr_r15:
    ld   (hl), a
    inc  hl
    djnz .attr_r15

    ; 10. Stampa riga 16: Controlli Sinistra / Destra (Riga 16, Colonna 0)
    ld   a, 22
    rst  $10
    ld   a, 16
    rst  $10
    ld   a, 0
    rst  $10
    ld   hl, title_ctrl_left
    ld   b, 32
    call Gfx_PrintString

    ; Imposta attributi riga 16 a Giallo ($5A00)
    ld   hl, $5a00
    ld   b, 32
    ld   a, YELLOW
.attr_r16:
    ld   (hl), a
    inc  hl
    djnz .attr_r16

    ; 11. Stampa riga 17: Controlli Salto / Start (Riga 17, Colonna 0)
    ld   a, 22
    rst  $10
    ld   a, 17
    rst  $10
    ld   a, 0
    rst  $10
    ld   hl, title_ctrl_jump
    ld   b, 32
    call Gfx_PrintString

    ; Imposta attributi riga 17 a Giallo ($5A20)
    ld   hl, $5a20
    ld   b, 32
    ld   a, YELLOW
.attr_r17:
    ld   (hl), a
    inc  hl
    djnz .attr_r17

    ; 12. Stampa riga 19: Separatore (Riga 19, Colonna 0)
    ld   a, 22
    rst  $10
    ld   a, 19
    rst  $10
    ld   a, 0
    rst  $10
    ld   hl, title_sep_line
    ld   b, 32
    call Gfx_PrintString

    ; Imposta attributi riga 19 a Blu ($5A60)
    ld   hl, $5a60
    ld   b, 32
    ld   a, BLUE
.attr_r19:
    ld   (hl), a
    inc  hl
    djnz .attr_r19

    ; 13. Stampa riga 20: Copyright (Riga 20, Colonna 0)
    ld   a, 22
    rst  $10
    ld   a, 20
    rst  $10
    ld   a, 0
    rst  $10
    ld   hl, title_copyright
    ld   b, 32
    call Gfx_PrintString

    ; Imposta attributi riga 20 a Ciano ($5A80)
    ld   hl, $5a80
    ld   b, 32
    ld   a, CYAN
.attr_r20:
    ld   (hl), a
    inc  hl
    djnz .attr_r20

    pop  ix
    pop  hl
    pop  de
    pop  bc
    pop  af
    ret

game_over_str:
    db "GAME OVER"

game_over_continue_str:
    ;db "VUOI CONTINUARE? Y/N"
    db "   CONTINUE? Y/N    "

game_over_color_table:
    db $42, $46, $47, $45, $44, $43, $46, $42

victory_str:
    db "CONGRATULATIONS!"

victory_sub_str:
    db " YOU HAVE WON!  "

victory_continue_str:
    db "  PLAY AGAIN? Y/N   "

victory_color_table:
    db $46, $44, $45, $47, $46, $43, $45, $47

; -------------------------------------------------------------------
; Gfx_DrawGameOverScreen
; Esegue la sequenza animata di Game Over:
; 1. Pulisce lo schermo a nero, mostra Willy (Y=96), BotteSprite (Y=112, Rosso), Nome Stanza (riga 16) e Status Line (riga 18).
; 2. Animazione di discesa fluida di PiedeSprite dall'alto (Y=0) fino a fermarsi sopra Willy (Y=80), prima del bordo alto della Botte.
; 3. Breve pausa con PiedeSprite fermo sopra Willy.
; 4. Stampa la scritta GAME OVER al centro dello schermo (riga 5) solo dopo la pausa.
; 5. Stampa la richiesta "VUOI CONTINUARE? Y/N" a riga 8.
; -------------------------------------------------------------------
Gfx_DrawGameOverScreen:
    push af
    push bc
    push de
    push hl
    push ix

    ; 1. Bordo hardware e schermo a nero
    xor  a
    out  ($fe), a              ; Bordo a nero
    ld   hl, ATTR_P
    ld   (hl), a               ; Paper/Ink = 0 (Nero)
    call CLS                   ; Pulisce tutti i pixel e gli attributi a nero
    ld   (hl), $07             ; Ripristina ATTR_P a $07 (Inchiostro Bianco, Sfondo Nero)
    ld   a, $07
    ld   (ATTR_T), a           ; Ripristina ATTR_T a $07

    ; 2. Disegna Willy (immobile, rivolto a destra) a X=124, Y=96
    ; 2a. Testa di Willy (8x8) a X=124, Y=96
    ld   bc, $607c             ; B = Y = 96 ($60), C = X = 124 ($7C)
    ld   ix, Willy + (0 * 8)   ; HEAD_GRAPH_RIGHT
    call Gfx_DrawPixelSprite8x8

    ; 2b. Corpo di Willy (8x8) a X=124, Y=104
    ld   bc, $687c             ; B = Y = 104 ($68), C = X = 124 ($7C)
    ld   ix, Willy + (1 * 8)   ; Body right frame 0
    call Gfx_DrawPixelSprite8x8

    ; 2c. Imposta attributi colore di Willy (Bianco Brillante) a X=124, Y=96
    ld   bc, $607c             ; B = Y = 96, C = X = 124
    ld   a, WHITE | $40        ; Bianco Brillante
    call Gfx_SetEnemyColorAttributes

    ; 3. Disegna BotteSprite (immobile, colore Rosso) a X=120, Y=112
    ld   bc, $7078             ; B = Y = 112 ($70), C = X = 120 ($78)
    ld   ix, BotteSprite       ; Frame 1 di BotteSprite
    call Gfx_DrawPixelSprite16x16

    ; 3b. Imposta attributi colore per BotteSprite (Rosso Brillante) a X=120, Y=112
    ld   bc, $7078             ; B = Y = 112, C = X = 120
    ld   a, RED | $40          ; Rosso Brillante
    call Gfx_SetEnemyColorAttributes

    ; 4. Stampa il Nome della Stanza a riga 16
    ld   a, 22                 ; Codice di controllo AT (22)
    rst  $10
    ld   a, 16                 ; Riga 16
    rst  $10
    ld   a, 0                  ; Colonna 0
    rst  $10
    
    ld   a, YELLOW             ; Inchiostro Giallo
    call Gfx_Ink
    
    ld   hl, (room_ptr)        ; HL = indirizzo stanza corrente
    ld   de, 128               ; Offset del nome stanza (32 byte)
    add  hl, de
    ld   b, 32
    call Gfx_PrintString

    ; 5. Stampa la riga di stato a riga 18
    ld   a, 22                 ; Codice di controllo AT (22)
    rst  $10
    ld   a, 18                 ; Riga 18
    rst  $10
    ld   a, 0                  ; Colonna 0
    rst  $10
    
    ld   hl, status_line       ; HL = indirizzo stringa di stato
    ld   b, 32                 ; B = 32 caratteri
    call Gfx_PrintString

    ; 6. Applica i colori agli attributi di riga 18 ($5A40)
    ld   hl, status_line_attrs
    ld   de, $5a40             ; Indirizzo attributi riga 18
    ld   bc, 32
    ldir

    ; 7. Animazione: Discesa fluida di PiedeSprite dall'alto (Y=0) fino a Y=96 (alla parte alta della Botte)
    ld   b, 0                  ; B = Y iniziale (0)
.foot_descent_loop:
    push bc                    ; Salva B = Y corrente
    
    ; 7a. Cancella l'intero blocco 16x16 della posizione precedente (Y - 2) se Y > 0
    ld   a, b
    or   a
    jr   z, .skip_clear_prev
    sub  2                     ; Y precedente (passo 2 pixel)
    ld   b, a
    ld   c, 120                ; X = 120
    call Gfx_Clear16x16_Black
    
    ; Pulisce l'attributo della riga lasciata indietro (Row = (Y - 2) / 8)
    ld   a, b
    srl  a
    srl  a
    srl  a                     ; A = Row da azzerare
    ld   l, a
    ld   h, 0
    add  hl, hl                ; * 2
    add  hl, hl                ; * 4
    add  hl, hl                ; * 8
    add  hl, hl                ; * 16
    add  hl, hl                ; * 32
    ld   de, $580f             ; $5800 + 15
    add  hl, de
    xor  a
    ld   (hl), a               ; Col 15 = 0
    inc  hl
    ld   (hl), a               ; Col 16 = 0

.skip_clear_prev:
    pop  bc                    ; Ripristina B = Y corrente
    push bc

    ; Quando il Piede raggiunge Y = 96, cancella lo sprite di Willy a (124, 96) prima di disegnare il Piede
    ld   a, b
    cp   96
    jr   nz, .draw_foot
    push bc
    ld   c, 120
    ld   b, 96
    call Gfx_Clear16x16_Black
    pop  bc

.draw_foot:
    ; 7b. Disegna PiedeSprite alla coordinata corrente (X=120, Y)
    ld   c, 120
    ld   ix, PiedeSprite
    call Gfx_DrawPixelSprite16x16

    ; 7c. Imposta colore Giallo Brillante per PiedeSprite
    ld   c, 120
    ld   a, YELLOW | $40
    call Gfx_SetEnemyColorAttributes

    ; 7d. Pausa per movimento fluido a 50Hz
    halt

    pop  bc                    ; B = Y corrente
    ld   a, b
    add  a, 2                  ; Avanza di 2 pixel
    ld   b, a
    cp   98                    ; Si ferma a Y = 96 (incluso, il ciclo termina quando B=98)
    jr   c, .foot_descent_loop

    ; 8. Breve pausa con PiedeSprite fermato sulla parte alta della Botte (~0.7s)
    ld   b, 35
.pause_after_foot:
    halt
    djnz .pause_after_foot

    ; 9. Solo DOPO la pausa, fa comparire GAME OVER al centro dello schermo a riga 5, colonna 11
    ld   a, 22                 ; AT (22)
    rst  $10
    ld   a, 5                  ; Riga 5
    rst  $10
    ld   a, 11                 ; Colonna 11
    rst  $10
    
    ld   a, RED                ; Inchiostro Rosso
    call Gfx_Ink

    ld   hl, game_over_str
    ld   b, 9
    call Gfx_PrintString

    ; Imposta attributo iniziale per GAME OVER (Rosso Brillante)
    ld   hl, $58ab             ; Riga 5, Colonna 11 ($5800 + 5*32 + 11 = $58AB)
    ld   b, 9
    ld   a, RED | $40
.init_go_attr:
    ld   (hl), a
    inc  hl
    djnz .init_go_attr

    ; 10. Fa comparire la domanda "VUOI CONTINUARE? Y/N" a riga 8, colonna 6
    ld   a, 22                 ; AT (22)
    rst  $10
    ld   a, 8                  ; Riga 8
    rst  $10
    ld   a, 6                  ; Colonna 6
    rst  $10
    
    ld   a, YELLOW             ; Inchiostro Giallo
    call Gfx_Ink

    ld   hl, game_over_continue_str
    ld   b, 20
    call Gfx_PrintString

    ; Imposta attributo per "VUOI CONTINUARE? Y/N" (Giallo Brillante)
    ld   hl, $5906             ; Riga 8, Colonna 6 ($5800 + 8*32 + 6 = $5906)
    ld   b, 20
    ld   a, YELLOW | $40
.init_continue_attr:
    ld   (hl), a
    inc  hl
    djnz .init_continue_attr

    pop  ix
    pop  hl
    pop  de
    pop  bc
    pop  af
    ret

; -------------------------------------------------------------------
; Gfx_DrawVictoryScreen
; Esegue la sequenza animata della schermata di vittoria:
; 1. Pulisce lo schermo a nero, mostra Willy (Y=96), Nome Stanza (riga 16) e Status Line (riga 18).
; 2. Animazione di Maria (VecchiaSprite): cammina verso sinistra da X=168 fino a X=128 (accanto a Willy).
; 3. Breve pausa con Maria fermata accanto a Willy.
; 4. Stampa la scritta di sottotitolo "YOU HAVE WON!" a riga 3.
; 5. Stampa la scritta di vittoria "CONGRATULATIONS!" a riga 5.
; 6. Stampa la richiesta "PLAY AGAIN? Y/N" a riga 8.
; -------------------------------------------------------------------
Gfx_DrawVictoryScreen:
    push af
    push bc
    push de
    push hl
    push ix

    ; 1. Bordo hardware e schermo a nero
    xor  a
    out  ($fe), a              ; Bordo a nero
    ld   hl, ATTR_P
    ld   (hl), a               ; Paper/Ink = 0 (Nero)
    call CLS                   ; Pulisce tutti i pixel e gli attributi a nero
    ld   (hl), $07             ; Ripristina ATTR_P a $07 (Inchiostro Bianco, Sfondo Nero)
    ld   a, $07
    ld   (ATTR_T), a           ; Ripristina ATTR_T a $07

    ; 2. Disegna Willy (immobile, rivolto a destra) a X=104, Y=96
    ; 2a. Testa di Willy (8x8) a X=104, Y=96
    ld   bc, $6068             ; B = Y = 96 ($60), C = X = 104 ($68)
    ld   ix, Willy + (0 * 8)   ; HEAD_GRAPH_RIGHT
    call Gfx_DrawPixelSprite8x8

    ; 2b. Corpo di Willy (8x8) a X=104, Y=104
    ld   bc, $6868             ; B = Y = 104 ($68), C = X = 104 ($68)
    ld   ix, Willy + (1 * 8)   ; Body right frame 0
    call Gfx_DrawPixelSprite8x8

    ; 2c. Imposta attributi colore di Willy (Bianco Brillante) a X=104, Y=96
    ld   bc, $6068             ; B = Y = 96, C = X = 104
    ld   a, WHITE | $40        ; Bianco Brillante
    call Gfx_SetEnemyColorAttributes

    ; 3. Stampa il Nome della Stanza a riga 16
    ld   a, 22                 ; Codice di controllo AT (22)
    rst  $10
    ld   a, 16                 ; Riga 16
    rst  $10
    ld   a, 0                  ; Colonna 0
    rst  $10
    
    ld   a, YELLOW             ; Inchiostro Giallo
    call Gfx_Ink
    
    ld   hl, (room_ptr)        ; HL = indirizzo stanza corrente
    ld   de, 128               ; Offset del nome stanza (32 byte)
    add  hl, de
    ld   b, 32
    call Gfx_PrintString

    ; 4. Stampa la riga di stato a riga 18
    ld   a, 22                 ; Codice di controllo AT (22)
    rst  $10
    ld   a, 18                 ; Riga 18
    rst  $10
    ld   a, 0                  ; Colonna 0
    rst  $10
    
    ld   hl, status_line       ; HL = indirizzo stringa di stato
    ld   b, 32                 ; B = 32 caratteri
    call Gfx_PrintString

    ; 5. Applica i colori agli attributi di riga 18 ($5A40)
    ld   hl, status_line_attrs
    ld   de, $5a40             ; Indirizzo attributi riga 18
    ld   bc, 32
    ldir

    ; 6. Animazione: Maria cammina verso sinistra da X=168 fino a fermarsi a X=128 (accanto a Willy)
    ld   b, 96                 ; B = Y = 96
    ld   c, 168                ; C = X iniziale (168)
    ld   d, 0                  ; D = contatore frame/passo

.maria_walk_loop:
    push bc                    ; Salva B = 96, C = X corrente
    push de                    ; Salva D = passo

    ; Cancella la posizione precedente (X + 2) se non siamo alla posizione di partenza (168)
    ld   a, c
    cp   168
    jr   z, .skip_clear_maria_prev
    add  a, 2                  ; X precedente
    ld   c, a
    ld   b, 96
    call Gfx_Clear16x16_Black

    ; Pulisce gli attributi della colonna lasciata indietro a destra: Colonna = (C + 15) / 8
    ld   a, c
    add  a, 15
    srl  a
    srl  a
    srl  a                     ; A = colonna attributi da pulire
    ld   e, a
    ld   d, 0
    ld   hl, $5980             ; Riga 12 ($5800 + 12*32 = $5980)
    add  hl, de
    xor  a
    ld   (hl), a               ; Riga 12 = 0
    ld   de, 32
    add  hl, de
    ld   (hl), a               ; Riga 13 = 0

.skip_clear_maria_prev:
    pop  de                    ; Ripristina D = passo
    pop  bc                    ; Ripristina C = X corrente, B = 96
    push bc
    push de

    ; Calcola il frame di animazione di VecchiaSprite (4 frame da 32 byte ciascuno)
    ; Frame index = (D / 2) & 3
    ld   a, d
    srl  a
    and  3                     ; A = 0..3
    ld   l, a
    ld   h, 0
    add  hl, hl                ; * 2
    add  hl, hl                ; * 4
    add  hl, hl                ; * 8
    add  hl, hl                ; * 16
    add  hl, hl                ; * 32 (HL = offset frame in byte)
    ld   de, VecchiaSprite
    add  hl, de
    push hl
    pop  ix                    ; IX = puntatore al frame corrente

    ; Disegna VecchiaSprite a (C=X, B=96)
    ld   b, 96
    call Gfx_DrawPixelSprite16x16

    ; Imposta colore Giallo Brillante per VecchiaSprite
    ld   b, 96
    ld   a, YELLOW | $40
    call Gfx_SetEnemyColorAttributes

    ; Pausa frame a 50Hz per animazione fluida
    halt

    pop  de                    ; D = passo
    pop  bc                    ; C = X corrente, B = 96
    inc  d                     ; D++
    ld   a, c
    sub  2                     ; Avanza di 2 pixel verso sinistra
    ld   c, a
    cp   126                   ; Si ferma a X = 128 (il ciclo termina quando C < 128, ossia C=126)
    jr   nc, .maria_walk_loop

    ; 7. Breve pausa con Maria fermata accanto a Willy (~0.7s)
    ld   b, 35
.pause_after_walk:
    halt
    djnz .pause_after_walk

    ; 8. Stampa la scritta di sottotitolo " YOU HAVE WON!  " a riga 3, colonna 8
    ld   a, 22                 ; AT (22)
    rst  $10
    ld   a, 3                  ; Riga 3
    rst  $10
    ld   a, 8                  ; Colonna 8
    rst  $10
    
    ld   a, CYAN               ; Inchiostro Ciano
    call Gfx_Ink

    ld   hl, victory_sub_str
    ld   b, 16
    call Gfx_PrintString

    ; Imposta attributi riga 3 (Ciano Brillante)
    ld   hl, $5868             ; Riga 3, Colonna 8 ($5800 + 3*32 + 8 = $5868)
    ld   b, 16
    ld   a, CYAN | $40
.init_sub_attr:
    ld   (hl), a
    inc  hl
    djnz .init_sub_attr

    ; 9. Stampa la scritta "CONGRATULATIONS!" a riga 5, colonna 8
    ld   a, 22                 ; AT (22)
    rst  $10
    ld   a, 5                  ; Riga 5
    rst  $10
    ld   a, 8                  ; Colonna 8
    rst  $10
    
    ld   a, YELLOW             ; Inchiostro Giallo
    call Gfx_Ink

    ld   hl, victory_str
    ld   b, 16
    call Gfx_PrintString

    ; Imposta attributo iniziale per "CONGRATULATIONS!" (Giallo Brillante)
    ld   hl, $58a8             ; Riga 5, Colonna 8 ($5800 + 5*32 + 8 = $58A8)
    ld   b, 16
    ld   a, YELLOW | $40
.init_vic_attr:
    ld   (hl), a
    inc  hl
    djnz .init_vic_attr

    ; 10. Stampa la richiesta "  PLAY AGAIN? Y/N   " a riga 8, colonna 6
    ld   a, 22                 ; AT (22)
    rst  $10
    ld   a, 8                  ; Riga 8
    rst  $10
    ld   a, 6                  ; Colonna 6
    rst  $10
    
    ld   a, GREEN              ; Inchiostro Verde
    call Gfx_Ink

    ld   hl, victory_continue_str
    ld   b, 20
    call Gfx_PrintString

    ; Imposta attributo per "  PLAY AGAIN? Y/N   " (Verde Brillante)
    ld   hl, $5906             ; Riga 8, Colonna 6 ($5800 + 8*32 + 6 = $5906)
    ld   b, 20
    ld   a, GREEN | $40
.init_continue_vic_attr:
    ld   (hl), a
    inc  hl
    djnz .init_continue_vic_attr

    pop  ix
    pop  hl
    pop  de
    pop  bc
    pop  af
    ret

Gfx_PrintWillyLives:
    push hl
    push bc
    push de
    push af
    
    ; Primo Willy (Colonna 0, giallo)
    ld   hl, willy_lives
    ld   a, (hl)
    cp   1
    ld   c, 0
    jr   c, .erase_1
    ld   a, $40 | YELLOW
    call Gfx_DrawWillyLifeIcon
    jr   .check_2
.erase_1:
    call Gfx_EraseWillyLifeIcon
    
.check_2:
    ld   a, (willy_lives)
    cp   2
    ld   c, 2
    jr   c, .erase_2
    ld   a, $40 | CYAN
    call Gfx_DrawWillyLifeIcon
    jr   .check_3
.erase_2:
    call Gfx_EraseWillyLifeIcon

.check_3:
    ld   a, (willy_lives)
    cp   3
    ld   c, 4
    jr   c, .erase_3
    ld   a, $40 | GREEN
    call Gfx_DrawWillyLifeIcon
    jr   .check_4
.erase_3:
    call Gfx_EraseWillyLifeIcon

.check_4:
    ld   a, (willy_lives)
    cp   4
    ld   c, 6
    jr   c, .erase_4
    ld   a, $40 | MAGENTA
    call Gfx_DrawWillyLifeIcon
    jr   .check_5
.erase_4:
    call Gfx_EraseWillyLifeIcon

.check_5:
    ld   a, (willy_lives)
    cp   5
    ld   c, 8
    jr   c, .erase_5
    ld   a, $40 | RED
    call Gfx_DrawWillyLifeIcon
    jr   .check_6
.erase_5:
    call Gfx_EraseWillyLifeIcon

.check_6:
    ld   a, (willy_lives)
    cp   6
    ld   c, 10
    jr   c, .erase_6
    ld   a, $40 | BLUE
    call Gfx_DrawWillyLifeIcon
    jr   .check_7
.erase_6:
    call Gfx_EraseWillyLifeIcon

.check_7:
    ld   a, (willy_lives)
    cp   7
    ld   c, 12
    jr   c, .erase_7
    ld   a, $40 | WHITE
    call Gfx_DrawWillyLifeIcon
    jr   .done
.erase_7:
    call Gfx_EraseWillyLifeIcon

.done:
    pop  af
    pop  de
    pop  bc
    pop  hl
    ret

Gfx_EraseWillyLifeIcon:
    ; Input: C = Colonna (0..31)
    ld   e, c              ; E = Colonna
    
    ; 1. Cancella la testa a Row 21 (Y=168), Colonna E
    ld   a, e
    add  a, a              ; *2
    add  a, a              ; *4
    add  a, a              ; *8
    ld   c, a              ; C = X pixel
    ld   b, 168            ; B = Y pixel (Row 21)
    call Gfx_ClearPixelSprite8x8
    
    ; 2. Cancella il corpo a Row 22 (Y=176), Colonna E
    ld   b, 176            ; B = Y pixel (Row 22)
    call Gfx_ClearPixelSprite8x8
    
    ; 3. Resetta gli attributi a Row 21 e Row 22 per Colonna E a nero (0)
    ; AttrAddr = $5AA0 + E (Row 21)
    ld   h, $5a
    ld   a, $a0
    add  a, e
    ld   l, a
    jr   nc, .no_carry1
    inc  h
.no_carry1:
    ld   (hl), 0           ; Scrivi colore testa a 0 (nero)
    
    ; AttrAddr = $5AC0 + E (Row 22)
    ld   h, $5a
    ld   a, $c0
    add  a, e
    ld   l, a
    jr   nc, .no_carry2
    inc  h
.no_carry2:
    ld   (hl), 0           ; Scrivi colore corpo a 0 (nero)
    ret

Gfx_ClearPixelSprite8x8:
    push bc
    push de
    push hl
    
    ; 1. Calcola indirizzo schermo
    ld   h, b
    ld   l, c
    call Gfx_GetScreenAddr ; HL = indirizzo schermo
    
    ld   c, 8          ; 8 linee
.line_loop:
    ld   (hl), 0       ; Pulisci la cella dello schermo (imposta a zero)
    call Gfx_IncScreenLine ; Prossima scanline sullo schermo
    dec  c
    jr   nz, .line_loop
    
    pop  hl
    pop  de
    pop  bc
    ret

; -------------------------------------------------------------------
; Gfx_UpdateScoreDisplay
; Formatta e visualizza High score e Score nella riga di stato (Riga 18).
; Scrive DIRETTAMENTE in VRAM senza passare dalle routine ROM (rst $10).
; Garantisce un aggiornamento istantaneo, atomico e affidabile a ogni raccolta item.
; -------------------------------------------------------------------
Gfx_UpdateScoreDisplay:
    push af
    push bc
    push de
    push hl
    push ix

    ; 1. Formatta High Score (6 cifre a status_line + 11)
    ld   ix, high_score
    ld   hl, status_line + 11
    call Gfx_FormatBCD6

    ; 2. Formatta Score (6 cifre a status_line + 26)
    ld   ix, player_score
    ld   hl, status_line + 26
    call Gfx_FormatBCD6

    ; 3. Rendering diretto in VRAM dei 32 caratteri di status_line a Riga 18 ($5040..$575F)
    ld   c, 0                  ; C = Colonna (0..31)
.char_loop:
    ld   e, c
    ld   d, 0
    ld   hl, status_line
    add  hl, de
    ld   a, (hl)               ; A = codice ASCII del carattere

    ; Indirizzo nel font_buffer: font_buffer + ASCII * 8
    ld   l, a
    ld   h, 0
    add  hl, hl                ; *2
    add  hl, hl                ; *4
    add  hl, hl                ; *8
    ld   de, font_buffer
    add  hl, de                ; HL = puntatore ai dati bitmap del carattere (8 byte)

    ; DE = Indirizzo VRAM scanline 0 per Riga 18, Colonna C ($5040 + C)
    ld   a, c
    add  a, $40
    ld   e, a
    ld   d, $50                ; DE = $5040 + C

    ; Copia le 8 scanline del carattere direttamente in VRAM
    ld   a, (hl) : ld (de), a : inc hl : inc d  ; Scanline 0 ($50xx)
    ld   a, (hl) : ld (de), a : inc hl : inc d  ; Scanline 1 ($51xx)
    ld   a, (hl) : ld (de), a : inc hl : inc d  ; Scanline 2 ($52xx)
    ld   a, (hl) : ld (de), a : inc hl : inc d  ; Scanline 3 ($53xx)
    ld   a, (hl) : ld (de), a : inc hl : inc d  ; Scanline 4 ($54xx)
    ld   a, (hl) : ld (de), a : inc hl : inc d  ; Scanline 5 ($55xx)
    ld   a, (hl) : ld (de), a : inc hl : inc d  ; Scanline 6 ($56xx)
    ld   a, (hl) : ld (de), a                   ; Scanline 7 ($57xx)

    inc  c
    ld   a, c
    cp   32
    jr   c, .char_loop

    ; 4. Imposta gli attributi colore di Riga 18 ($5A40..$5A5F)
    ld   hl, status_line_attrs
    ld   de, $5a40             ; Indirizzo attributi Riga 18 ($5800 + 18*32 = $5A40)
    ld   bc, 32
    ldir

    pop  ix
    pop  hl
    pop  de
    pop  bc
    pop  af
    ret

; -------------------------------------------------------------------
; Gfx_FormatBCD6
; Converte 3 byte BCD (puntati da IX) in 6 caratteri ASCII (scritti in HL).
; IX+2 = cifre alte (centinaia di migliaia, decine di migliaia)
; IX+1 = cifre medie (migliaia, centinaia)
; IX+0 = cifre basse (decine, unità)
; -------------------------------------------------------------------
Gfx_FormatBCD6:
    ; Cifra 0 (centinaia di migliaia)
    ld   a, (ix+2)
    rrca
    rrca
    rrca
    rrca
    and  $0f
    add  a, '0'
    ld   (hl), a
    inc  hl

    ; Cifra 1 (decine di migliaia)
    ld   a, (ix+2)
    and  $0f
    add  a, '0'
    ld   (hl), a
    inc  hl

    ; Cifra 2 (migliaia)
    ld   a, (ix+1)
    rrca
    rrca
    rrca
    rrca
    and  $0f
    add  a, '0'
    ld   (hl), a
    inc  hl

    ; Cifra 3 (centinaia)
    ld   a, (ix+1)
    and  $0f
    add  a, '0'
    ld   (hl), a
    inc  hl

    ; Cifra 4 (decine)
    ld   a, (ix+0)
    rrca
    rrca
    rrca
    rrca
    and  $0f
    add  a, '0'
    ld   (hl), a
    inc  hl

    ; Cifra 5 (unità)
    ld   a, (ix+0)
    and  $0f
    add  a, '0'
    ld   (hl), a
    inc  hl
    ret

status_line:
    db "High score 000000   Score 000000"

status_line_attrs:
    .32 db (YELLOW | $40)     ; 32 colonne colore Giallo Brillante (Bright Yellow on Black Paper)



; -------------------------------------------------------------------
; Disegna le icone delle vite di Willy (Row 21 per testa, Row 22 per corpo)
; -------------------------------------------------------------------
Gfx_DrawWillyLifeIcon:
    ; Input: C = Colonna (0..31), A = Colore Gfx_Ink (1..7 / bright color)
    ; D = Colore, E = Colonna
    ld   d, a              ; D = Colore
    ld   e, c              ; E = Colonna
    
    ; 0. Cancella la testa e il corpo per evitare artefatti da OR
    push bc
    push de
    ld   a, e
    add  a, a              ; *2
    add  a, a              ; *4
    add  a, a              ; *8
    ld   c, a              ; C = X pixel
    ld   b, 168            ; B = Y pixel (Row 21 / head)
    call Gfx_ClearPixelSprite8x8
    ld   b, 176            ; B = Y pixel (Row 22 / body)
    call Gfx_ClearPixelSprite8x8
    pop  de
    pop  bc
    
    ; 1. Disegna la testa a Row 21 (Y=168), Colonna E
    ; X pixel = E * 8
    ld   a, e
    add  a, a              ; *2
    add  a, a              ; *4
    add  a, a              ; *8
    ld   c, a              ; C = X pixel
    ld   b, 168            ; B = Y pixel (Row 21)
    ld   ix, Willy + 0*8   ; IX = head facing right
    call Gfx_DrawPixelSprite8x8
    
    ; 2. Disegna il corpo a Row 22 (Y=176), Colonna E
    ld   b, 176            ; B = Y pixel (Row 22)
    
    push de                ; SALVA D = Colore, E = Colonna
    
    ; Determina il frame del corpo per le icone delle vite
    IF ENABLE_ANIMATE_LIVES != 0
    ; Calcola il frame animato dal contatore
    ld   a, (counter)
    rrca
    rrca
    rrca
    and  %00000011         ; A = 0..3
    cp   3
    jr   nz, .not_3
    ld   a, 1              ; map 3 to 1 -> cycle is 0, 1, 2, 1
.not_3:
    inc  a
    jr   .calc_ix
    ELSE
    ld   a, 1              ; frame statico 1
    ENDIF
    
.calc_ix:
    ; calcola IX = Willy + A * 8
    add  a, a              ; *2
    add  a, a              ; *4
    add  a, a              ; *8
    ld   e, a
    ld   d, 0
    ld   ix, Willy
    add  ix, de
    call Gfx_DrawPixelSprite8x8
    
    pop  de                ; RIPRISTINA D = Colore, E = Colonna
    
    ; 3. Imposta l'attributo colore per la testa (Row 21, Colonna E)
    ; AttrAddr = $5AA0 + E (Row 21)
    ld   h, $5a
    ld   a, $A0
    add  a, e
    ld   l, a
    jr   nc, .no_carry1
    inc  h
.no_carry1:
    ld   (hl), d           ; Scrivi colore testa
    
    ; 4. Imposta l'attributo colore per il corpo (Row 22, Colonna E)
    ; AttrAddr = $5AC0 + E (Row 22)
    ld   h, $5a
    ld   a, $C0
    add  a, e
    ld   l, a
    jr   nc, .no_carry2
    inc  h
.no_carry2:
    ld   (hl), d           ; Scrivi colore corpo
    ret

; -------------------------------------------------------------------
; Disegna un tile 8x8 sullo schermo
; Input: B = Row (0..23), C = Col (0..31), IX = Puntatore al Tile (9 byte: 1 attr + 8 bitmap)
; -------------------------------------------------------------------
Gfx_DrawTile:
    push bc
    push de
    push hl
    
    ; 1. Calcola indirizzo dello schermo (bitmap) per Row B, Col C, scanline 0
    ; HighByte = $40 + (B & $18)
    ld   a, b
    and  $18
    add  a, $40
    ld   h, a              ; H = High byte
    
    ; LowByte = ((B & 7) * 32) + C
    ld   a, b
    and  7
    add  a, a              ; *2
    add  a, a              ; *4
    add  a, a              ; *8
    add  a, a              ; *16
    add  a, a              ; *32
    add  a, c              ; + Col C
    ld   l, a              ; L = Low byte
    
    ; 2. Copia gli 8 byte del bitmap
    ld   d, 8              ; 8 scanline
    push ix
    inc  ix                ; Salta l'attributo, vai al bitmap
.line_loop:
    ld   a, (ix+0)
    ld   (hl), a
    inc  h                 ; Prossima scanline (stessa riga di caratteri)
    inc  ix
    dec  d
    jr   nz, .line_loop
    pop  ix
    
    ; 3. Scrivi l'attributo
    ; AttrAddr = $5800 + B * 32 + C
    ld   h, 0
    ld   l, b              ; HL = B (Row)
    add  hl, hl            ; *2
    add  hl, hl            ; *4
    add  hl, hl            ; *8
    add  hl, hl            ; *16
    add  hl, hl            ; *32
    ld   d, 0
    ld   e, c              ; DE = C (Col)
    add  hl, de            ; HL = B * 32 + C
    ld   de, $5800
    add  hl, de            ; HL = AttrAddr
    
    ld   a, (ix+0)         ; A = attribute byte
    ld   (hl), a           ; Scrivi in memoria attributi
    
    pop  hl
    pop  de
    pop  bc
    ret

; -------------------------------------------------------------------
; Gfx_DrawCrumblingTile
; Disegna una tile di tipo Crumbling Floor a (Row B, Col C) nello stadio E (0..8).
; Input: B = Row (0..15), C = Col (0..31), E = Stage (0..8)
; -------------------------------------------------------------------
Gfx_DrawCrumblingTile:
    push bc
    push de
    push hl
    push ix

    ; 1. Calcola indirizzo bitmap per Row B, Col C, scanline 0
    ld   a, b
    and  $18
    add  a, $40
    ld   h, a                  ; H = High byte
    
    ld   a, b
    and  7
    add  a, a                  ; *2
    add  a, a                  ; *4
    add  a, a                  ; *8
    add  a, a                  ; *16
    add  a, a                  ; *32
    add  a, c                  ; + Col C
    ld   l, a                  ; HL = indirizzo schermo scanline 0

    ; 2. IX = room_ptr + OFFSET_CRUMBLING + 1 (inizio bitmap 8 byte)
    push hl
    ld   hl, (room_ptr)
    ld   bc, OFFSET_CRUMBLING + 1
    add  hl, bc
    push hl
    pop  ix                    ; IX = puntatore alle 8 scanline bitmap
    pop  hl                    ; HL = indirizzo schermo

    ; 3. Loop su 8 scanline (line = 0..7)
    ld   d, 0                  ; D = line index (0..7)
.line_loop:
    ld   a, d                  ; A = current line
    cp   e                     ; Confronta current line con Stage (in E)
    jr   c, .erase_line        ; Se line < Stage, scrivi 0 (cancellata)
    
    ; Linea visibile: scrivi byte bitmap dal tile
    ld   a, (ix+0)
    ld   (hl), a
    jr   .next_scanline

.erase_line:
    xor  a
    ld   (hl), a

.next_scanline:
    inc  h                     ; Prossima scanline sullo schermo
    inc  ix                    ; Prossima scanline nel tile
    inc  d                     ; line++
    ld   a, d
    cp   8
    jr   c, .line_loop

    ; 4. Gestione Attributo Colore
    ; Se Stage >= 8, azzera l'attributo a 0 (Background)
    ld   a, e
    cp   8
    jr   c, .done_draw_crumble
    
    ld   h, 0
    ld   l, b                  ; HL = Row
    add  hl, hl : add hl, hl : add hl, hl : add hl, hl : add hl, hl
    ld   e, c
    ld   d, 0
    add  hl, de
    ld   de, $5800
    add  hl, de                ; HL = AttrAddr
    xor  a
    ld   (hl), a

.done_draw_crumble:
    pop  ix
    pop  hl
    pop  de
    pop  bc
    ret

; -------------------------------------------------------------------
; Disegna la stanza corrente leggendola dalla struttura dati
; -------------------------------------------------------------------
; -------------------------------------------------------------------
; Disegna la stanza corrente leggendola dalla struttura dati
; -------------------------------------------------------------------
Gfx_DrawRoom:
    push bc
    push de
    push hl
    push ix
    
    call UnpackRoomLayout      ; Decodifica le 512 celle in unpacked_layout (0..7)
    
    ld   hl, unpacked_layout   ; HL punta a unpacked_layout
    ld   b, 0                  ; B = Row (0..15)
.row_loop:
    ld   c, 0                  ; C = Col (0..31)
.col_loop:
    ld   a, (hl)               ; A = tile index (0..7)
    inc  hl
    
    ; IX = room_ptr + OFFSET_TILES + A * 9
    push hl
    ld   l, a
    ld   h, 0
    ld   e, a
    ld   d, 0
    add  hl, hl                ; *2
    add  hl, hl                ; *4
    add  hl, hl                ; *8
    add  hl, de                ; *9
    ld   de, OFFSET_TILES
    add  hl, de
    ld   de, (room_ptr)
    add  hl, de
    push hl
    pop  ix                    ; IX = puntatore al tile (9 byte)
    
    call Gfx_DrawTile          ; Disegna il tile a (Row B, Col C)
    pop  hl
    
    inc  c
    ld   a, c
    cp   32
    jr   nz, .col_loop
    
    inc  b
    ld   a, b
    cp   16
    jr   nz, .row_loop
    
    ; Disegna anche il portale se presente
    call Gfx_DrawPortal
    
    pop  ix
    pop  hl
    pop  de
    pop  bc
    ret

; -------------------------------------------------------------------
; Gfx_DrawPortal
; Disegna il portale di uscita della stanza corrente (16x16 pixel)
; -------------------------------------------------------------------
Gfx_DrawPortal:
; -------------------------------------------------------------------
; Gfx_DrawPortalForeground / Gfx_AnimatePortal
; Disegna il Portale della stanza corrente (definito a partire da OFFSET_PORTAL = 655)
; sempre in PRIMO PIANO (foreground) rispetto a Willy e ai Guardiani.
; - Scrive direttamente i 32 byte della bitmap 16x16 in VRAM.
; - Imposta i 4 attributi colore (2x2 celle):
;   * Se tutti gli item sono raccolti (game_objective_completed != 0): esegue il ciclo di colori lampeggianti.
;   * Se gli item non sono ancora tutti raccolti: imposta il colore statico originale del portale.
; -------------------------------------------------------------------
Gfx_DrawPortalForeground:
Gfx_AnimatePortal:
    push hl
    push de
    push bc
    push ix

    ; 1. Leggi i dati del portale da room_ptr + OFFSET_PORTAL (byte 655)
    ld   hl, (room_ptr)
    ld   de, OFFSET_PORTAL
    add  hl, de
    ld   a, (hl)               ; A = Attribute originale (byte 0)
    ld   (portal_static_color), a
    inc  hl
    push hl
    pop  ix                    ; IX = inizio bitmap 32 byte del portale

    ; Salta 32 byte bitmap per leggere AttrAddr (offset 688)
    ld   de, 32
    add  hl, de
    ld   c, (hl)
    inc  hl
    ld   b, (hl)               ; BC = AttrAddr (es. 23997)

    ; Calcola AttrOffset = BC - 23552
    ld   h, b
    ld   l, c
    ld   bc, -23552
    add  hl, bc                ; HL = AttrOffset

    ; Col = AttrOffset & 31
    ld   a, l
    and  31
    ld   c, a                  ; C = Col (0..31)

    ; Row = AttrOffset / 32
    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    ld   a, l
    ld   b, a                  ; B = Row (0..15)

    ; Converti in coordinate pixel (C = Pixel X, B = Pixel Y)
    ld   a, c
    add  a, a : add a, a : add a, a
    ld   c, a                  ; C = Pixel X (Col * 8)
    ld   a, b
    add  a, a : add a, a : add a, a
    ld   b, a                  ; B = Pixel Y (Row * 8)

    ; 2. Disegna la bitmap 16x16 del portale direttamente in VRAM (16 linee, 2 byte per linea)
    ld   h, b
    ld   l, c
    call Gfx_GetScreenAddr     ; HL = Indirizzo VRAM Top-Left del portale

    ld   b, 16                 ; 16 scanlines
.portal_bitmap_loop:
    ld   a, (ix+0)
    ld   (hl), a               ; Scrivi byte sinistro
    inc  hl
    ld   a, (ix+1)
    ld   (hl), a               ; Scrivi byte destro
    dec  hl                    ; Ripristina HL alla colonna sinistra
    call Gfx_IncScreenLine     ; Prossima scanline
    inc  ix
    inc  ix                    ; Prossimi 2 byte della bitmap
    djnz .portal_bitmap_loop

    ; 3. Gestione Attributi Colore (4 celle 8x8)
    ; Calcola indirizzo VRAM attributi Top-Left: $5800 + AttrOffset
    ld   hl, (room_ptr)
    ld   de, OFFSET_PORTAL + 33
    add  hl, de
    ld   c, (hl)
    inc  hl
    ld   b, (hl)
    ld   h, b
    ld   l, c
    ld   bc, -23552
    add  hl, bc
    ld   bc, $5800
    add  hl, bc                ; HL = Indirizzo VRAM attributo Top-Left

    ; Controlla se il portale è attivo (tutti gli item raccolti)
    ld   a, (game_objective_completed)
    or   a
    jr   z, .apply_static_portal_color

    ; --- PORTALE ATTIVO: ANIMAZIONE COLORI LAMPEGGIANTI ---
    ; Avanza il timer animazione
    ld   a, (portal_anim_timer)
    inc  a
    cp   2
    jr   c, .skip_portal_anim_inc
    xor  a
    ld   (portal_anim_timer), a
    ld   a, (portal_anim_frame)
    inc  a
    and  7
    ld   (portal_anim_frame), a
.skip_portal_anim_inc:

    ld   a, (portal_anim_frame)
    ld   e, a                  ; E = frame base (0..7)

    ; Cella 0: Top-Left (frame + 0)
    call .get_portal_color_hl
    ld   (hl), a

    ; Cella 1: Top-Right (frame + 1)
    inc  hl
    inc  e
    call .get_portal_color_hl
    ld   (hl), a

    ; Cella 2: Bottom-Left (frame + 2)
    ld   bc, 31
    add  hl, bc
    inc  e
    call .get_portal_color_hl
    ld   (hl), a

    ; Cella 3: Bottom-Right (frame + 3)
    inc  hl
    inc  e
    call .get_portal_color_hl
    ld   (hl), a
    jr   .portal_done

.apply_static_portal_color:
    ; --- PORTALE INATTIVO: COLORE STATICO ORIGINALE ---
    ld   a, (portal_static_color)
    ld   (hl), a               ; Top-Left
    inc  hl
    ld   (hl), a               ; Top-Right
    ld   bc, 31
    add  hl, bc
    ld   (hl), a               ; Bottom-Left
    inc  hl
    ld   (hl), a               ; Bottom-Right

.portal_done:
    pop  ix
    pop  bc
    pop  de
    pop  hl
    ret

.get_portal_color_hl:
    push hl
    push de
    ld   a, e
    and  7
    ld   e, a
    ld   d, 0
    ld   hl, portal_color_table
    add  hl, de
    ld   a, (hl)
    pop  de
    pop  hl
    ret

; Tabella colori lampeggio portale (Tutti con BRIGHT $40 attivo)
portal_color_table:
    db (WHITE   | $40)         ; $47
    db (YELLOW  | $40)         ; $46
    db (CYAN    | $40)         ; $45
    db (GREEN   | $40)         ; $44
    db (MAGENTA | $40)         ; $43
    db (RED     | $40)         ; $42
    db (BLUE    | $40)         ; $41
    db (WHITE   | $40)         ; $47

; -------------------------------------------------------------------
; Ottiene l'attributo colore originale dello sfondo per una cella
; Input: H = Row (0..23), B = Col (0..31)
; Output: A = Attributo colore
; -------------------------------------------------------------------
Gfx_GetCellAttribute:
    push hl
    push de
    push bc

    push de
    push bc
    ld   c, h                  ; C = Row
    call CheckActiveItemAtCell
    jr   nc, .no_item_attr
    
    pop  bc
    pop  de
    pop  bc
    pop  de
    pop  hl
    ret

.no_item_attr:
    pop  bc
    pop  de

    ; 1. Controlla se Row (H) è fuori dal layout (H >= 16)
    ld   a, h
    cp   16
    jp   nc, .blank

    ; 1b. Controlla se la cella (Row H, Col B) appartiene al Portale
    push hl
    push de
    push bc
    ld   hl, (room_ptr)
    ld   de, OFFSET_PORTAL + 33
    add  hl, de
    ld   a, (hl)
    inc  hl
    ld   h, (hl)
    ld   l, a                  ; HL = AttrAddr
    ld   de, -23552
    add  hl, de                ; HL = AttrOffset

    ld   a, l
    and  31
    ld   d, a                  ; D = PortalCol (0..31)

    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    ld   a, l                  ; A = PortalRow (0..15)

    pop  bc                    ; B = Col
    pop  de
    pop  hl                    ; H = Row

    ; DeltaRow = Row (H) - PortalRow (A)
    sub  h
    neg
    cp   2
    jr   nc, .not_portal_attr

    ld   e, a                  ; E = DeltaRow (0..1)

    ; DeltaCol = Col (B) - PortalCol (D)
    ld   a, b
    sub  d
    cp   2
    jr   nc, .not_portal_attr

    ; A = DeltaCol (0..1)
    ld   d, a                  ; D = DeltaCol
    ld   a, e                  ; A = DeltaRow
    add  a, a                  ; *2
    add  a, d                  ; A = CellIndex (0..3)
    ld   e, a                  ; E = CellIndex (0..3)

    ; Se game_objective_completed != 0 (portale attivo):
    ld   a, (game_objective_completed)
    or   a
    jr   z, .portal_static_attr

    ld   a, (portal_anim_frame)
    add  a, e                  ; portal_anim_frame + CellIndex
    and  7
    ld   e, a
    ld   d, 0
    ld   hl, portal_color_table
    add  hl, de
    ld   a, (hl)               ; A = colore lampeggiante
    pop  bc
    pop  de
    pop  hl
    ret

.portal_static_attr:
    ld   hl, (room_ptr)
    ld   de, OFFSET_PORTAL
    add  hl, de
    ld   a, (hl)               ; A = attributo originale del portale
    pop  bc
    pop  de
    pop  hl
    ret

.not_portal_attr:
    ; 2. Leggi il tile index da unpacked_layout
    ld   a, h                  ; A = Row
    ld   c, b                  ; C = Col
    call GetCellFromUnpacked   ; A = tile index (0..7)

    ; 3. Leggi l'attributo del tile corrispondente (room_ptr + OFFSET_TILES + A * 9)
    ld   l, a
    ld   h, 0
    ld   e, a
    ld   d, 0
    add  hl, hl                ; *2
    add  hl, hl                ; *4
    add  hl, hl                ; *8
    add  hl, de                ; *9
    ld   de, OFFSET_TILES
    add  hl, de
    ld   de, (room_ptr)
    add  hl, de                ; HL = puntatore al tile
    ld   a, (hl)               ; A = attributo colore del tile

    pop  bc
    pop  de
    pop  hl
    ret

.blank:
    ld   a, $07                ; Sfondo di default (bianco su nero)
    pop  bc
    pop  de
    pop  hl
    ret

; -------------------------------------------------------------------
; Imposta gli attributi colore per la cella occupata da un nemico 16x16
; Input: C = X pixel, B = Y pixel, A = Colore Gfx_Ink (0..7)
; -------------------------------------------------------------------
Gfx_SetEnemyColorAttributes:
    push hl
    push de
    push bc
    
    ld   d, a              ; D = Colore Gfx_Ink (salvato)
    
    ; Se Y è fuori dai limiti della griglia di gioco, non fare nulla
    ld   a, b
    cp   128
    jr   nc, .done
    
    ; Calcola ColStart: col = X / 8
    ld   a, c
    srl  a
    srl  a
    srl  a
    ld   e, a              ; E = ColStart
    
    ; Calcola ColEnd: col_end = (X + 15) / 8
    ld   a, c
    add  a, 15
    srl  a
    srl  a
    srl  a
    ld   c, a              ; C = ColEnd
    
    ; Calcola RowStart: row = Y / 8
    ld   a, b
    srl  a
    srl  a
    srl  a
    ld   h, a              ; H = RowStart
    
    ; Calcola RowEnd: row_end = (Y + 15) / 8
    ld   a, b
    add  a, 15
    srl  a
    srl  a
    srl  a
    ld   l, a              ; L = RowEnd
    
    ; Loop righe: Row corrente in H, fino a L
.row_loop:
    ld   a, h
    cp   l
    jr   z, .ok_row
    jr   nc, .done
.ok_row:
    push bc
    push de
    
    ; Col loop from E (ColStart) to C (ColEnd)
    ld   b, e              ; B = Col corrente
.col_loop:
    ld   a, b
    cp   c
    jr   z, .ok_col
    jr   nc, .col_done
.ok_col:
    ; Processa la cella a H (Row), B (Col)
    push hl
    ld   l, h
    ld   h, 0
    add  hl, hl
    add  hl, hl
    add  hl, hl
    add  hl, hl
    add  hl, hl            ; HL = Row * 32
    
    ld   a, b              ; A = Col corrente
    add  a, l
    ld   l, a
    jr   nc, .no_c_s
    inc  h
.no_c_s:
    ld   a, h
    add  a, $58
    ld   h, a              ; HL = Attribute screen address ($5800 + Row * 32 + Col)
    
    ld   a, (hl)
    and  $f8
    or   d                 ; D has the enemy color
    ld   (hl), a
    pop  hl
    
    inc  b                 ; Prossima colonna
    jr   .col_loop
    
.col_done:
    pop  de
    pop  bc
    inc  h                 ; Prossima riga
    jr   .row_loop
    
.done:
    pop  bc
    pop  de
    pop  hl
    ret

; -------------------------------------------------------------------
; Ripristina gli attributi colore originali dello sfondo per la cella occupata da un nemico
; Input: C = X pixel, B = Y pixel
; -------------------------------------------------------------------
Gfx_RestoreEnemyColorAttributes:
    push hl
    push de
    push bc
    
    ; Se Y è fuori dai limiti della griglia di gioco, non fare nulla
    ld   a, b
    cp   128
    jr   nc, .done
    
    ; Calcola ColStart: col = X / 8
    ld   a, c
    srl  a
    srl  a
    srl  a
    ld   e, a              ; E = ColStart
    
    ; Calcola ColEnd: col_end = (X + 15) / 8
    ld   a, c
    add  a, 15
    srl  a
    srl  a
    srl  a
    ld   c, a              ; C = ColEnd
    
    ; Calcola RowStart: row = Y / 8
    ld   a, b
    srl  a
    srl  a
    srl  a
    ld   h, a              ; H = RowStart
    
    ; Calcola RowEnd: row_end = (Y + 15) / 8
    ld   a, b
    add  a, 15
    srl  a
    srl  a
    srl  a
    ld   l, a              ; L = RowEnd
    
    ; Loop righe: Row corrente in H, fino a L
.row_loop:
    ld   a, h
    cp   l
    jr   z, .ok_row
    jr   nc, .done
.ok_row:
    push bc
    push de
    
    ; Col loop from E (ColStart) to C (ColEnd)
    ld   b, e              ; B = Col corrente
.col_loop:
    ld   a, b
    cp   c
    jr   z, .ok_col
    jr   nc, .col_done
.ok_col:
    ; Ottieni attributo originale dello sfondo per cella H (Row), B (Col)
    call Gfx_GetCellAttribute  ; A = attributo originale
    ld   d, a              ; D = attributo originale
    
    push hl                ; Salva Row pointer
    ld   l, h
    ld   h, 0
    add  hl, hl
    add  hl, hl
    add  hl, hl
    add  hl, hl
    add  hl, hl            ; HL = Row * 32
    
    ld   a, b              ; A = Col corrente
    add  a, l
    ld   l, a
    jr   nc, .no_c_r
    inc  h
.no_c_r:
    ld   a, h
    add  a, $58
    ld   h, a              ; HL = Attribute screen address ($5800 + Row * 32 + Col)
    
    ld   (hl), d           ; Ripristina l'attributo colore dello sfondo
    pop  hl                ; Ripristina Row pointer
    
    inc  b                 ; Prossima colonna
    jr   .col_loop
    
.col_done:
    pop  de
    pop  bc
    inc  h                 ; Prossima riga
    jr   .row_loop
    
.done:
    pop  bc
    pop  de
    pop  hl
    ret

; -------------------------------------------------------------------
; Disegna rampa e conveyor leggendo i dati della stanza corrente
; -------------------------------------------------------------------
Gfx_DrawConveyorsAndRamps:
    push hl
    push de
    push bc
    push ix
    
    ; --- Inizializza dati Conveyor per Manic Miner ---
    ld   hl, (room_ptr)
    ld   de, OFFSET_CONVEYOR_DATA
    add  hl, de            ; HL = ConveyorData pointer (offset 623)
    
    ld   a, (hl)           ; A = Direction (0 = Left, 1 = Right)
    ld   (conveyor_dir), a
    inc  hl
    ld   e, (hl)
    inc  hl
    ld   d, (hl)           ; DE = Location
    inc  hl
    ld   a, (hl)           ; A = Length (es. 20)
    ld   (conveyor_len), a
    
    ; Col = DE & 31
    ld   a, e
    and  31
    ld   (conveyor_col), a
    
    ; Row = 9
    ld   a, 9
    ld   (conveyor_row), a
    
    xor  a
    ld   (ramp_len), a
    ld   (ramp_dir), a
    ld   (ramp_row), a
    ld   (ramp_col), a
    
    pop  ix
    pop  bc
    pop  de
    pop  hl
    ret

Gfx_SetSpriteColor16x16: EQU Gfx_SetEnemyColorAttributes

PiedeSprite:
    .32 db 255
BotteSprite:
    .32 db 0
VecchiaSprite:
    .32 db 0

