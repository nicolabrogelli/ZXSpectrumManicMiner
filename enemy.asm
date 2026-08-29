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
    jr   z, .no_v_guardians
    or   a
    jr   z, .no_v_guardians
    ld   a, 1
    ld   (room_has_v_guardians), a
    jr   .has_v_guardians

.no_v_guardians:
    xor  a
    ld   (room_has_v_guardians), a
    jr   .done_v_guardians

.has_v_guardians:
    ld   b, 4                      ; Fino a 4 guardiani verticali
.load_v_loop:
    ld   a, (hl)                   ; Byte 0: Attributo / Colore
    cp   $FF
    jr   z, .done_v_guardians      ; $FF = terminatore
    or   a
    jr   z, .done_v_guardians      ; 0 = nessun guardiano

    ; Slot attivo per guardiano verticale
    ld   (ix+0), $C0               ; Active = 1, Vertical = 1
    ld   (ix+10), a                ; Color / Attributo

    inc  hl
    ld   a, (hl)                   ; Byte 1: Graphic index (0..3)
    and  3                         ; Frame 0..3 nella prima metà dei dati grafici
    ld   (ix+1), a                 ; Frame index (0..3)

    inc  hl
    ld   a, (hl)                   ; Byte 2: Initial Y (pixel)
    ld   (ix+3), a                 ; Current Y

    inc  hl
    ld   a, (hl)                   ; Byte 3: X colonna (0..31)
    and  31
    add  a, a : add a, a : add a, a ; * 8 -> X pixel
    ld   (ix+2), a                 ; Current X

    inc  hl
    ld   a, (hl)                   ; Byte 4: Direction / Speed
    and  3
    jr   nz, .v_step_ok
    ld   a, 1
.v_step_ok:
    ld   (ix+7), a                 ; Speed step (1 o 2 pixel per frame)
    ld   a, 2                      ; Direction iniziale = 2 (Down)
    ld   (ix+6), a

    inc  hl
    ld   a, (hl)                   ; Byte 5: Min Limit Y (pixel)
    ld   (ix+4), a                 ; Min Limit Y

    inc  hl
    ld   a, (hl)                   ; Byte 6: Max Limit Y (pixel)
    ld   (ix+5), a                 ; Max Limit Y

    inc  hl                        ; Prossimo guardiano verticale (7 byte per record)
    ld   de, 11
    add  ix, de
    djnz .load_v_loop

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

    ; 1. Salva subito le coordinate X e Y dal record IX
    ld   c, (ix+2)                 ; C = Current X
    ld   b, (ix+3)                 ; B = Current Y

    ; Controlla se è guardiano verticale
    ld   a, (ix+0)
    and  $40                       ; Vertical?
    jr   nz, .v_frame

    ; Guardiano Orizzontale:
    ld   a, (ix+7)                 ; Anim subframe (0..3)
    and  3
    ld   e, a                      ; E = Anim subframe

    ld   a, (room_has_v_guardians)
    or   a
    jr   nz, .h_use_second_half    ; Se ci sono guardiani verticali, i guardiani orizzontali usano la SECONDA METÀ (frame 4..7)!

    ld   a, (ix+6)                 ; Direction (1 = Left, 2 = Right)
    cp   1                         ; Sinistra?
    jr   z, .left_frames

    ; Movimento a Destra: Frame 0..3 (prima metà)
    ld   a, e
    jr   .got_frame_idx

.h_use_second_half:
.left_frames:
    ; Movimento a Sinistra (o orizzontale in stanze con guardiani verticali): Frame 4..7 (seconda metà)
    ld   a, 4
    add  a, e
    jr   .got_frame_idx

.v_frame:
    ; Guardiano Verticale: usa il frame salvato in (ix+1) (0..3, prima metà)
    ld   a, (ix+1)
    and  3

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

    ld   a, (ix+10)                ; A = Color Attributo
    push af                        ; Salva colore nello stack

    push hl
    pop  ix                        ; IX = frame bitmap pointer

    ; 2. Disegna sprite 16x16 alle coordinate (C=X, B=Y)
    call Gfx_DrawPixelSprite16x16

    ; 3. Imposta gli attributi colore alle coordinate (C=X, B=Y)
    pop  af                        ; A = Color Attributo
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
    ; 0. Controllo della frequenza di aggiornamento guardiani (enemy_update_rate)
    ld   a, (enemy_update_rate)
    cp   1
    jr   z, .do_update             ; Se rate == 1 (standard), aggiorna sempre

    ld   hl, enemy_update_timer
    inc  (hl)
    ld   a, (hl)
    ld   hl, enemy_update_rate
    cp   (hl)
    ret  c                         ; Se il timer non ha ancora raggiunto la soglia, ritorna subito
    xor  a
    ld   (enemy_update_timer), a

.do_update:
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

    ; 1. Determina se orizzontale o verticale
    ld   a, (ix+0)
    and  $40                       ; Vertical?
    jp   nz, .vertical

    ; Aggiorna Anim State per guardiano orizzontale (0..3)
    ld   a, (ix+7)
    inc  a
    and  3
    ld   (ix+7), a

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
    ; Aggiorna Anim Frame per guardiano verticale (cicla 0..3)
    ld   a, (ix+1)
    inc  a
    and  3
    ld   (ix+1), a

    ld   a, (ix+7)                 ; Step in pixel (1 o 2)
    and  3
    jr   nz, .v_step_ok
    ld   a, 1
.v_step_ok:
    ld   c, a                      ; C = Step

    ld   a, (ix+6)                 ; Direction (1 = Up, 2 = Down)
    cp   1
    jr   nz, .vert_down

.vert_up:
    ld   a, (ix+3)                 ; Current Y
    sub  c                         ; Muovi verso l'alto
    cp   (ix+4)                    ; Min Limit Y
    jr   z, .v_rev_down
    jr   c, .v_rev_down
    ld   (ix+3), a
    jp   .next

.v_rev_down:
    ld   a, (ix+4)                 ; Min Limit Y
    ld   (ix+3), a
    ld   a, 2                      ; Cambia direzione a Down
    ld   (ix+6), a
    jp   .next

.vert_down:
    ld   a, (ix+3)                 ; Current Y
    add  a, c                      ; Muovi verso il basso
    cp   (ix+5)                    ; Max Limit Y
    jr   z, .v_rev_up
    jr   nc, .v_rev_up
    ld   (ix+3), a
    jp   .next

.v_rev_up:
    ld   a, (ix+5)                 ; Max Limit Y
    ld   (ix+3), a
    ld   a, 1                      ; Cambia direzione a Up
    ld   (ix+6), a
    jp   .next

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
; Controlla se Willy collide con un guardiano attivo con rilevamento
; PIXEL-PERFECT (bit a bit), identico all'originale per ZX Spectrum.
; Output:
;   Carry Set = Collisione reale (pixel Willy sovrapposto a pixel guardiano)
;   Carry Clear = Nessuna collisione
; -------------------------------------------------------------------
CheckCollision:
    push ix
    push bc
    push de
    push hl

    ; 1. Se il timer di sicurezza (post-respawn) è attivo, Willy è invulnerabile
    ld   a, (willy_safety_timer)
    or   a
    jp   nz, .no_collision_found

    ; 2. Prepara i puntatori agli sprite di Willy (Testa e Corpo)
    ld   a, (direction)
    cp   1                         ; Sinistra?
    jr   nz, .willy_right

    ; Willy a Sinistra:
    ld   hl, Willy + (4 * 8)       ; Testa sinistra (tile 4, offset 32)
    ld   (willy_head_ptr), hl
    ld   a, (body_state)           ; 0, 1, 2
    add  a, 5                      ; tile 5, 6, 7
    add  a, a : add a, a : add a, a ; * 8
    ld   e, a
    ld   d, 0
    ld   hl, Willy
    add  hl, de
    ld   (willy_body_ptr), hl      ; Corpo sinistro
    jr   .willy_ptrs_ready

.willy_right:
    ; Willy a Destra:
    ld   hl, Willy + (0 * 8)       ; Testa destra (tile 0, offset 0)
    ld   (willy_head_ptr), hl
    ld   a, (body_state)           ; 0, 1, 2
    add  a, 1                      ; tile 1, 2, 3
    add  a, a : add a, a : add a, a ; * 8
    ld   e, a
    ld   d, 0
    ld   hl, Willy
    add  hl, de
    ld   (willy_body_ptr), hl      ; Corpo destro

.willy_ptrs_ready:
    ld   ix, ActiveEnemies
    ld   b, 8                      ; 8 slot

.enemy_loop:
    ld   a, (ix+0)
    and  $80                       ; Active?
    jp   z, .next_enemy

    ; ---------------------------------------------------------------
    ; PRE-FILTRO BOUNDING BOX RAPIDO:
    ; ---------------------------------------------------------------
    ; Calcola DeltaX = WillyX - EnemyX (range valido [-7 .. 15])
    ld   a, (PlayerPos)            ; WillyX
    sub  (ix+2)                    ; A = WillyX - EnemyX
    cp   16
    jr   c, .x_in_range             ; 0..15 -> in range
    cp   249                       ; 249..255 = -7..-1
    jp   c, .next_enemy            ; 16..248 -> fuori range
.x_in_range:
    ld   (collision_delta_x), a    ; Salva DeltaX (-7..15)

    ; Calcola DeltaY = WillyY - EnemyY (range valido [-15 .. 15])
    ld   a, (PlayerPos+1)          ; WillyY
    sub  (ix+3)                    ; A = WillyY - EnemyY
    cp   16
    jr   c, .y_in_range             ; 0..15 -> in range
    cp   241                       ; 241..255 = -15..-1
    jp   c, .next_enemy            ; 16..240 -> fuori range
.y_in_range:
    ld   (collision_delta_y), a    ; Salva DeltaY (-15..15)

    ; ---------------------------------------------------------------
    ; DETERMINA FRAME GRAFICO DEL GUARDIANO (32 byte)
    ; ---------------------------------------------------------------
    push bc                        ; Salva contatore nemici (B)

    ; Controlla se è guardiano verticale
    ld   a, (ix+0)
    and  $40                       ; Vertical?
    jr   nz, .col_guard_vert

    ld   a, (ix+7)                 ; Anim subframe (0..3)
    and  3
    ld   c, a

    ld   a, (room_has_v_guardians)
    or   a
    jr   nz, .col_h_second_half    ; Se ci sono guardiani verticali, orizzontali usano la seconda metà (frame 4..7)

    ld   a, (ix+6)                 ; Direction (1 = Left, 2 = Right)
    cp   1
    jr   z, .guard_left_frame
    ; Frame Destra: Frame = Subframe (0..3, prima metà)
    ld   a, c
    jr   .calc_guard_ptr
.col_h_second_half:
.guard_left_frame:
    ; Frame Sinistra (o stanza con guardiani verticali): Frame = 4 + Subframe (4..7, seconda metà)
    ld   a, 4
    add  a, c
    jr   .calc_guard_ptr

.col_guard_vert:
    ; Guardiano verticale: usa il frame salvato in (ix+1) (0..3, prima metà)
    ld   a, (ix+1)
    and  3

.calc_guard_ptr:
    ; Offset = Frame * 32
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
    add  hl, de                    ; HL = puntatore ai 32 byte del frame guardiano
    ld   (guard_sprite_ptr), hl

    ; ---------------------------------------------------------------
    ; DETERMINA IL RANGE DELLE RIGHE SOVRAPPOSTE
    ; ---------------------------------------------------------------
    ld   a, (collision_delta_y)
    bit  7, a                      ; DeltaY negativo? (Willy più in alto del nemico)
    jr   nz, .willy_higher

    ; Willy lower or equal (DeltaY >= 0):
    ; row_enemy_cur = DeltaY, row_willy_cur = 0, num_lines = 16 - DeltaY
    ld   (row_enemy_cur), a
    xor  a
    ld   (row_willy_cur), a
    ld   a, 16
    ld   hl, collision_delta_y
    sub  (hl)
    ld   (overlap_num_lines), a
    jr   .check_lines_loop

.willy_higher:
    ; Willy higher (DeltaY < 0, cioè WillyY < EnemyY):
    neg                            ; A = -DeltaY (1..15)
    ld   (row_willy_cur), a        ; row_willy_cur = -DeltaY
    xor  a
    ld   (row_enemy_cur), a        ; row_enemy_cur = 0
    ld   a, 16
    ld   hl, row_willy_cur
    sub  (hl)
    ld   (overlap_num_lines), a

.check_lines_loop:
    ; ---------------------------------------------------------------
    ; CONFRONTO PIXEL-PERFECT RIGA PER RIGA
    ; ---------------------------------------------------------------
    ld   a, (overlap_num_lines)
    ld   b, a                      ; B = numero di scanlines da controllare

.scanline_loop:
    push bc                        ; Salva contatore scanlines

    ; 1. Leggi i 2 byte della scanline corrente del guardiano
    ld   a, (row_enemy_cur)
    add  a, a                      ; row * 2
    ld   e, a
    ld   d, 0
    ld   hl, (guard_sprite_ptr)
    add  hl, de                    ; HL = guard_sprite_ptr + row * 2
    ld   d, (hl)                   ; D = Enemy Byte 0
    inc  hl
    ld   e, (hl)                   ; E = Enemy Byte 1

    ; 2. Estrai la fetta di 8 pixel del guardiano allineata a DeltaX
    ld   a, (collision_delta_x)
    bit  7, a
    jr   nz, .shift_neg_dx         ; DeltaX in [-7..-1]

    ; DeltaX >= 0:
    cp   9
    jr   nc, .shift_dx_gt_8        ; DeltaX in [9..15]

    ; DeltaX in [0..8]: shift a sinistra a 16 bit (D, E) per DeltaX volte
    or   a
    jr   z, .slice_ready_in_d      ; DeltaX == 0 -> fetta già allineata in D
    ld   c, a                      ; C = DeltaX (1..8)
.shift_left_16bit:
    sla  e
    rl   d
    dec  c
    jr   nz, .shift_left_16bit
.slice_ready_in_d:
    ld   a, d                      ; A = fetta guardiano allineata
    jr   .test_willy_line

.shift_dx_gt_8:
    ; DeltaX in [9..15]: shift a sinistra del solo byte E per (DeltaX - 8) volte
    sub  8
    ld   c, a                      ; C = DeltaX - 8 (1..7)
.shift_left_e_only:
    sla  e
    dec  c
    jr   nz, .shift_left_e_only
    ld   a, e                      ; A = fetta guardiano allineata
    jr   .test_willy_line

.shift_neg_dx:
    ; DeltaX in [-7..-1]: shift a destra del solo byte D per (-DeltaX) volte
    neg
    ld   c, a                      ; C = -DeltaX (1..7)
.shift_right_d_only:
    srl  d
    dec  c
    jr   nz, .shift_right_d_only
    ld   a, d                      ; A = fetta guardiano allineata

.test_willy_line:
    ; Se la fetta del guardiano non ha pixel attivi su questa scanline, passa alla prossima
    or   a
    jr   z, .next_scanline

    ; 3. Leggi il byte corrispondente dello sprite di Willy
    ld   c, a                      ; C = fetta guardiano
    ld   a, (row_willy_cur)
    cp   8
    jr   c, .read_willy_head

    ; Riga corpo (8..15)
    sub  8
    ld   l, a
    ld   h, 0
    ld   de, (willy_body_ptr)
    add  hl, de
    ld   a, (hl)                   ; A = byte corpo Willy
    jr   .do_pixel_and

.read_willy_head:
    ; Riga testa (0..7)
    ld   l, a
    ld   h, 0
    ld   de, (willy_head_ptr)
    add  hl, de
    ld   a, (hl)                   ; A = byte testa Willy

.do_pixel_and:
    ; 4. TEST BIT A BIT: (Pixel_Willy AND Pixel_Guardiano)
    and  c
    jr   nz, .pixel_collision_detected ; Se != 0, COLLISIONE PIXEL-PERFECT!

.next_scanline:
    ; Avanza alla prossima riga
    ld   hl, row_enemy_cur
    inc  (hl)
    ld   hl, row_willy_cur
    inc  (hl)

    pop  bc                        ; Ripristina B (contatore scanlines)
    dec  b
    jp   nz, .scanline_loop

    ; Nessun pixel sovrapposto per questo guardiano
    pop  bc                        ; Ripristina B (contatore nemici)

.next_enemy:
    ld   de, 11
    add  ix, de
    dec  b
    jp   nz, .enemy_loop

.no_collision_found:
    pop  hl
    pop  de
    pop  bc
    pop  ix
    or   a                         ; Carry = 0 (Nessuna collisione)
    ret

.pixel_collision_detected:
    pop  bc                        ; Pulisci stack scanline
    pop  bc                        ; Pulisci stack nemici
    pop  hl
    pop  de
    pop  bc
    pop  ix
    scf                            ; Carry = 1 (COLLISIONE CONFERMATA!)
    ret

