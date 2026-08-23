;===========================================================================
; enemy.asm
;
; Gestione dei Guardiani (Nemici) per Manic Miner.
; I dati e le sprite dei guardiani (8 frame da 16x16 pixel) sono definiti
; direttamente all'interno della stanza (OFFSET_H_GUARDIANS, OFFSET_V_GUARDIANS,
; OFFSET_GUARDIAN_GRAPHICS).
;===========================================================================

; -------------------------------------------------------------------
; Struttura dati per i nemici attivi della stanza corrente (RAM)
; 8 slot, 11 byte ciascuno:
; Offset 0: Flags (Bit 7: Active, Bit 6: Vertical)
; Offset 1: Sprite Frame Offset / Tipo
; Offset 2: Current X
; Offset 3: Current Y
; Offset 4: Min Limit
; Offset 5: Max Limit
; Offset 6: Direction (1 = Left/Up, 2 = Right/Down)
; Offset 7: Anim State (0..3)
; Offset 8: Old X
; Offset 9: Old Y
; Offset 10: Color (Attributo Spectrum)
; -------------------------------------------------------------------
ActiveEnemies:
    .88 db 0

; -------------------------------------------------------------------
; Enemy_LoadRoom
;
; Carica i guardiani della stanza corrente in ActiveEnemies.
; Chiamato quando si entra in una stanza.
; -------------------------------------------------------------------
Enemy_LoadRoom:
    push hl
    push de
    push bc
    push ix

    ; 1. Azzera la tabella ActiveEnemies (8 slot x 11 byte = 88 byte)
    ld   hl, ActiveEnemies
    ld   de, ActiveEnemies + 1
    ld   (hl), 0
    ld   bc, 87
    ldir

    ; Inizializza Old X e Old Y a $FF per tutti gli 8 slot
    ld   ix, ActiveEnemies
    ld   b, 8
    ld   de, 11
.init_old_pos:
    ld   (ix+8), $FF               ; Old X
    ld   (ix+9), $FF               ; Old Y
    add  ix, de
    djnz .init_old_pos

    ; 2. Carica i guardiani orizzontali da room_ptr + OFFSET_H_GUARDIANS
    ld   ix, ActiveEnemies
    ld   hl, (room_ptr)
    ld   de, OFFSET_H_GUARDIANS
    add  hl, de

    ld   b, 4                      ; Fino a 4 guardiani orizzontali
.load_h_loop:
    ld   a, (hl)                   ; Byte 0: Attributo / Flags
    cp   $FF
    jr   z, .done_h_guardians      ; $FF = terminatore
    or   a
    jr   z, .done_h_guardians      ; 0 = terminatore

    ; Slot attivo
    ld   (ix+0), $80               ; Active = 1, Horizontal (Bit 6 = 0)
    ld   (ix+10), a                ; Color / Attributo

    inc  hl
    ld   c, (hl)                   ; C = AttrAddr Low
    inc  hl
    ld   a, (hl)                   ; A = AttrAddr High

    ; Calcola StartX e StartY da AttrAddr: Offset = AttrAddr - 23552
    push hl
    push bc
    ld   h, a
    ld   l, c
    ld   bc, -23552
    add  hl, bc                    ; HL = AttrOffset

    ; Col = Offset & 31 -> StartX = Col * 8
    ld   a, l
    and  31
    add  a, a : add a, a : add a, a
    ld   (ix+2), a                 ; Current X = StartX

    ; Row = Offset / 32 -> StartY = Row * 8
    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    ld   a, l
    add  a, a : add a, a : add a, a
    ld   (ix+3), a                 ; Current Y = StartY
    pop  bc
    pop  hl

    inc  hl
    ld   a, (hl)                   ; Byte 3: Anim mask / frame
    ld   (ix+7), 0                 ; Anim subframe iniziale = 0

    inc  hl
    ld   a, (hl)                   ; Byte 4: Direction (0 = Destra, 1 = Sinistra)
    and  1
    jr   z, .h_dir_right
    ld   a, 1                      ; 1 = Sinistra
    jr   .set_h_dir
.h_dir_right:
    ld   a, 2                      ; 2 = Destra
.set_h_dir:
    ld   (ix+6), a                 ; Direction

    inc  hl
    ld   a, (hl)                   ; Byte 5: Min limit
    and  31
    add  a, a : add a, a : add a, a
    ld   (ix+4), a                 ; Min Limit X (pixel)

    inc  hl
    ld   a, (hl)                   ; Byte 6: Max limit
    and  31
    add  a, a : add a, a : add a, a
    ld   (ix+5), a                 ; Max Limit X (pixel)

    inc  hl                        ; Prossimo guardiano
    ld   de, 11
    add  ix, de
    djnz .load_h_loop

.done_h_guardians:
    ; 3. Carica guardiani verticali (se presenti a OFFSET_V_GUARDIANS)
    ld   hl, (room_ptr)
    ld   de, OFFSET_V_GUARDIANS
    add  hl, de
    ld   a, (hl)
    cp   $FF
    jr   z, .done_v_guardians
    or   a
    jr   z, .done_v_guardians

    ; Slot attivo per guardiano verticale
    ld   (ix+0), $C0               ; Active = 1, Vertical = 1
    ld   (ix+10), a                ; Color
    ; (Imposta coordinate verticali se presenti in livelli futuri)

.done_v_guardians:
    pop  ix
    pop  bc
    pop  de
    pop  hl
    ret

; -------------------------------------------------------------------
; Controlla se la posizione (C = X, B = Y) del nemico si sovrappone a Willy
; -------------------------------------------------------------------
CheckEnemyWillyOverlap:
    ld   a, (player_drawn_pos+1)
    cp   $FF
    ret  z                  ; Se Willy non è disegnato, esci
    
    ; 1. Controllo X: (EnemyX & $F8) - (WillyX & $F8) + 16 <= 24
    ld   a, (player_drawn_pos)
    and  $F8
    ld   e, a               ; E = WillyX & $F8
    ld   a, c
    and  $F8                ; A = EnemyX & $F8
    sub  e                  ; A = (EnemyX & $F8) - (WillyX & $F8)
    add  a, 16
    cp   25
    ret  nc                 ; Fuori portata X
    
    ; 2. Controllo Y: WillyY - EnemyY + 15 <= 30
    ld   a, (player_drawn_pos+1) ; A = WillyY
    sub  b                  ; A = WillyY - EnemyY
    add  a, 15
    cp   31
    ret  nc                 ; Fuori portata Y
    
    ; Sovrapposizione confermata! Segnala che Willy deve essere ridisegnato
    ld   a, 1
    ld   (willy_needs_redraw), a
    ret

; -------------------------------------------------------------------
; Aggiorna e disegna i nemici in due passate (prima cancella tutti i vecchi, poi disegna tutti i nuovi)
; -------------------------------------------------------------------
Enemy_EraseRoom:
Enemy_DrawRoom:
Enemy_RenderRoom:
    push hl
    push de
    push bc
    push ix
    
    ; ---------------------------------------------------------------
    ; PASSATA 1: Cancella la vecchia posizione di tutti i nemici che si sono mossi o aggiornati
    ; ---------------------------------------------------------------
    ld   ix, ActiveEnemies
    ld   b, 8              ; 8 slot
.erase_loop:
    ld   a, (ix+0)         ; Flags
    and  $80               ; Active?
    jr   z, .next_erase
    
    ; Se Old X == $FF (nuova stanza o non ancora disegnato), non c'è nulla da cancellare
    ld   a, (ix+8)         ; Old X
    cp   $FF
    jr   z, .next_erase
    
    ; Controlla se la posizione è cambiata o se l'animazione/stato si è aggiornato
    ld   a, (ix+8)         ; Old X
    cp   (ix+2)            ; Current X
    jr   nz, .do_erase_slot
    ld   a, (ix+9)         ; Old Y
    cp   (ix+3)            ; Current Y
    jr   nz, .do_erase_slot
    
    ld   a, (enemy_was_updated)
    or   a
    jr   z, .next_erase    ; Nessuna modifica in questo frame, non cancellare!

.do_erase_slot:
    push bc                ; Salva contatore ciclo
    
    ; Controlla se la VECCHIA posizione del guardiano sovrascrive Willy
    ld   c, (ix+8)         ; C = Old X
    ld   b, (ix+9)         ; B = Old Y
    call CheckEnemyWillyOverlap

    ; Cancella il nemico nella VECCHIA posizione
    ld   c, (ix+8)         ; C = Old X
    ld   b, (ix+9)         ; B = Old Y
    call Gfx_ErasePixelSprite16x16
    ld   c, (ix+8)         ; C = Old X
    ld   b, (ix+9)         ; B = Old Y
    call Gfx_RestoreEnemyColorAttributes

    pop  bc

.next_erase:
    ld   de, 11
    add  ix, de            ; Prossimo slot (11 byte)
    dec  b
    jr   nz, .erase_loop

    ; ---------------------------------------------------------------
    ; PASSATA 2: Disegna la nuova posizione di tutti i nemici
    ; ---------------------------------------------------------------
    ld   ix, ActiveEnemies
    ld   b, 8              ; 8 slot
.draw_loop:
    ld   a, (ix+0)         ; Flags
    and  $80               ; Active?
    jr   z, .next_draw
    
    ; Se Old X == $FF, deve essere disegnato (prima volta)
    ld   a, (ix+8)         ; Old X
    cp   $FF
    jr   z, .do_draw_slot
    
    ; Controlla se si è mosso o se l'animazione/stato si è aggiornato
    ld   a, (ix+8)         ; Old X
    cp   (ix+2)            ; Current X
    jr   nz, .do_draw_slot
    ld   a, (ix+9)         ; Old Y
    cp   (ix+3)            ; Current Y
    jr   nz, .do_draw_slot
    
    ld   a, (enemy_was_updated)
    or   a
    jr   z, .next_draw     ; Nessuna modifica in questo frame, non ridisegnare!

.do_draw_slot:
    push bc                ; Salva contatore ciclo
    
    ; Disegna il nemico nella NUOVA posizione (applica anche gli attributi colore)
    call Enemy_DrawSingleSlot
    
    ; Controlla se la NUOVA posizione del guardiano si sovrappone a Willy
    ld   c, (ix+2)         ; C = Current X
    ld   b, (ix+3)         ; B = Current Y
    call CheckEnemyWillyOverlap

    ; Salva le coordinate effettivamente disegnate
    ld   a, (ix+2)
    ld   (ix+8), a         ; Old X = Current X
    ld   a, (ix+3)
    ld   (ix+9), a         ; Old Y = Current Y

    pop  bc

.next_draw:
    ld   de, 11
    add  ix, de            ; Prossimo slot (11 byte)
    dec  b
    jr   nz, .draw_loop
    
    xor  a
    ld   (enemy_was_updated), a ; Resetta flag aggiornamento nemici
    
    pop  ix
    pop  bc
    pop  de
    pop  hl
    ret

; -------------------------------------------------------------------
; Enemy_DrawSingleSlot
;
; Disegna un singolo guardiano 16x16 pixel specificato da IX.
; La grafica (8 frame da 32 byte) è letta direttamente da
; room_ptr + OFFSET_GUARDIAN_GRAPHICS.
; -------------------------------------------------------------------
Enemy_DrawSingleSlot:
    push bc
    push de
    push hl
    push ix

    ; 1. Determina il frame di animazione (0..7)
    ; Direction: 1 = Left (Frame 0..3), 2 = Right (Frame 4..7)
    ld   a, (ix+7)                 ; Anim subframe (0..3)
    and  3
    ld   b, a                      ; B = Anim subframe

    ld   a, (ix+6)                 ; Direction (1 = Left, 2 = Right)
    cp   1
    jr   z, .left_frames
    ; Right frames: 4..7
    ld   a, 4
    add  a, b
    jr   .got_frame_idx

.left_frames:
    ; Left frames: 0..3
    ld   a, b

.got_frame_idx:
    ; Frame index in A (0..7). Calcola Offset = Frame * 32
    ld   l, a
    ld   h, 0
    add  hl, hl                    ; *2
    add  hl, hl                    ; *4
    add  hl, hl                    ; *8
    add  hl, hl                    ; *16
    add  hl, hl                    ; *32

    ld   de, OFFSET_GUARDIAN_GRAPHICS
    add  hl, de
    ld   de, (room_ptr)
    add  hl, de                    ; HL = puntatore ai 32 byte del frame bitmap
    push hl
    pop  ix                        ; IX = frame bitmap pointer

    ; 2. Coordinate e colore
    pop  iy                        ; IY = ActiveEnemies slot
    push iy

    ld   c, (iy+2)                 ; C = Current X
    ld   b, (iy+3)                 ; B = Current Y
    ld   a, (iy+10)                ; A = Color Attributo

    ; 3. Disegna sprite 16x16 e imposta attributi colore
    call Gfx_DrawPixelSprite16x16
    ld   a, (iy+10)                ; A = Color Attributo
    call Gfx_SetEnemyColorAttributes

    pop  ix
    pop  hl
    pop  de
    pop  bc
    ret

; -------------------------------------------------------------------
; Enemy_Update
;
; Aggiorna le posizioni e le animazioni dei guardiani attivi.
; -------------------------------------------------------------------
Enemy_Update:
    push hl
    push de
    push bc
    push ix

    ld   a, 1
    ld   (enemy_was_updated), a

    ld   ix, ActiveEnemies
    ld   b, 8                      ; 8 slot
.loop:
    ld   a, (ix+0)                 ; Flags
    and  $80                       ; Active?
    jp   z, .next

    ; 1. Aggiorna Anim State (0..3)
    ld   a, (ix+7)
    inc  a
    and  3
    ld   (ix+7), a

    ; 2. Determina se orizzontale o verticale
    ld   a, (ix+0)
    and  $40                       ; Vertical?
    jp   nz, .vertical

.horizontal:
    ld   a, (ix+6)                 ; Direction (1 = Left, 2 = Right)
    cp   1
    jr   nz, .horiz_right

.horiz_left:
    ld   a, (ix+2)                 ; Current X
    sub  2                         ; Muovi a sinistra di 2 pixel
    cp   (ix+4)                    ; Min Limit
    jr   z, .h_rev_right
    jr   c, .h_rev_right
    ld   (ix+2), a
    jp   .next

.h_rev_right:
    ld   a, (ix+4)                 ; Min Limit
    ld   (ix+2), a
    ld   a, 2
    ld   (ix+6), a                 ; Cambia direzione a Destra
    jp   .next

.horiz_right:
    ld   a, (ix+2)                 ; Current X
    add  a, 2                      ; Muovi a destra di 2 pixel
    cp   (ix+5)                    ; Max Limit
    jr   z, .h_rev_left
    jr   nc, .h_rev_left
    ld   (ix+2), a
    jp   .next

.h_rev_left:
    ld   a, (ix+5)                 ; Max Limit
    ld   (ix+2), a
    ld   a, 1
    ld   (ix+6), a                 ; Cambia direzione a Sinistra
    jp   .next

.vertical:
    ld   a, (ix+6)                 ; Direction (1 = Up, 2 = Down)
    cp   1
    jr   nz, .vert_down

.vert_up:
    ld   a, (ix+3)                 ; Current Y
    sub  2
    cp   (ix+4)
    jr   z, .v_rev_down
    jr   c, .v_rev_down
    ld   (ix+3), a
    jp   .next

.v_rev_down:
    ld   a, (ix+4)
    ld   (ix+3), a
    ld   a, 2
    ld   (ix+6), a
    jp   .next

.vert_down:
    ld   a, (ix+3)                 ; Current Y
    add  a, 2
    cp   (ix+5)
    jr   z, .v_rev_up
    jr   nc, .v_rev_up
    ld   (ix+3), a
    jp   .next

.v_rev_up:
    ld   a, (ix+5)
    ld   (ix+3), a
    ld   a, 1
    ld   (ix+6), a

.next:
    ld   de, 11
    add  ix, de
    dec  b
    jp   nz, .loop

    pop  ix
    pop  bc
    pop  de
    pop  hl
    ret

; -------------------------------------------------------------------
; CheckCollision
;
; Controlla se Willy collide con un guardiano attivo (bounding box 16x16).
; Output:
;   Carry Set = Collisione con guardiano
;   Carry Clear = Nessuna collisione
; -------------------------------------------------------------------
CheckCollision:
    push ix
    push bc
    push de
    push hl

    ; Se il timer di sicurezza (post-respawn) è attivo, Willy è invulnerabile
    ld   a, (willy_safety_timer)
    or   a
    jr   nz, .no_collision_found

    ld   ix, ActiveEnemies
    ld   b, 8                      ; 8 slot

.collision_loop:
    ld   a, (ix+0)
    and  $80                       ; Active?
    jr   z, .next_enemy

    ; 1. Controllo Bounding Box X: |WillyX - EnemyX| < 12 (tolleranza collisione)
    ld   bc, (PlayerPos)           ; C = WillyX, B = WillyY
    ld   a, (ix+2)                 ; A = EnemyX

    ; Calcola differenza X
    sub  c                         ; A = EnemyX - WillyX
    jr   nc, .x_diff_pos
    neg                            ; A = |EnemyX - WillyX|
.x_diff_pos:
    cp   12                        ; Sovrapposizione orizzontale?
    jr   nc, .next_enemy           ; Se distanza >= 12 px, nessun contatto

    ; 2. Controllo Bounding Box Y: |WillyY - EnemyY| < 14
    ld   a, (ix+3)                 ; A = EnemyY
    sub  b                         ; A = EnemyY - WillyY
    jr   nc, .y_diff_pos
    neg                            ; A = |EnemyY - WillyY|
.y_diff_pos:
    cp   14                        ; Sovrapposizione verticale?
    jr   nc, .next_enemy           ; Se distanza >= 14 px, nessun contatto

    ; Collisione trovata!
    pop  hl
    pop  de
    pop  bc
    pop  ix
    scf
    ret

.next_enemy:
    ld   de, 11
    add  ix, de
    dec  b
    jr   nz, .collision_loop

.no_collision_found:
    pop  hl
    pop  de
    pop  bc
    pop  ix
    or   a
    ret
