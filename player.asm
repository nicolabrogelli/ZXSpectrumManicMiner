;===========================================================================z
; player.asm
;===========================================================================

; -------------------------------------------------------------------
; MovePlayer
;
; Gestisce il movimento orizzontale del player (Willy),
; applicando input da controlli, limiti di schermo e collisioni
; con i muri.
;
; Input:
;   D = stato dei controlli (bitfield)
;
; Strutture utilizzate:
;   PlayerPos       -> posizione (B = Y, C = X in pixel)
;   player_speed    -> velocità orizzontale
;   flags           -> flag di stato input
;
; Bit controlli:
;   bit 0 = sinistra
;   bit 1 = destra
;
; Nota:
;   Se Willy è in aria (on_ground = 0) il movimento orizzontale viene
;   ignorato per tutta la durata del salto.
;
; Output:
;   aggiorna PlayerPos e body_state
; -------------------------------------------------------------------
MovePlayer:

    ; ---------------------------------------------------------------
    ; Se siamo in aria, usa la direzione bloccata al momento del salto.
    ; Il movimento orizzontale in aria continua anche se non ci sono
    ; tasti di direzione premuti (jump_dir decide).
    ; ---------------------------------------------------------------
    ld   a, (on_ground)
    or   a
    jr   nz, .on_ground_check

    ld   a, (jump_dir)
    or   a
    ret  z                  ; Se jump_dir è 0, salto verticale -> nessun movimento orizzontale
    
    ; In volo: resetta comunque il flag di aggiornamento movimento se era impostato
    ld   ix, flags
    res  $00, (ix)

    ld   bc, (PlayerPos)
    cp   1
    jr   z, movePlayer_left
    cp   2
    jr   z, movePlayer_right
    ret

.on_ground_check:
    ; ---------------------------------------------------------------
    ; Se siamo a terra, muoviti solo se c'è input (bit 0 di flags impostato)
    ; ---------------------------------------------------------------
    ld   ix, flags
    bit  $00, (ix)
    ret  z

    res  $00, (ix)

    ld   bc, (PlayerPos)

.ground_input:
    ; ---------------------------------------------------------------
    ; Input: destra?
    ; ---------------------------------------------------------------
    bit  $01, d
    jr   nz, movePlayer_right

    ; ---------------------------------------------------------------
    ; Input: sinistra?
    ; ---------------------------------------------------------------
    bit  $00, d
    ret  z

; ===============================================================
; MOVIMENTO SINISTRA
; ===============================================================
movePlayer_left:
    ; Impedisci lo spostamento a sinistra se Willy è sul conveyor ed il conveyor va a destra.
    call CheckWillyOnConveyor
    jr   nc, .continue_left
    ld   a, (conveyor_dir)
    or   a
    ret  nz                     ; Se è sul conveyor e va a destra, ritorna senza muovere

.continue_left:
    ; Calcola nuova posizione: X - speed
    ld   a, (on_ground)
    or   a
    jr   z, .air_left
    ld   a, (player_speed)
    jr   .speed_left_ok
.air_left:
    ld   a, 2
    ld   hl, jump_frame
    bit  0, (hl)
    jr   z, .speed_left_ok
    inc  a                      ; Alterna 2 e 3 px per frame (Media = 2.5 px/frame)
.speed_left_ok:
    ld   e, a

    ld   a, c
    sub  e

    ; Controllo limite sinistro schermo
    cp   PLAYER_MIN_X
    jr   c, .clamp_left

    ; -----------------------------------------------------------
    ; Collisione con muro (pre-check)
    ; -----------------------------------------------------------
    push bc
    ld   c, a
    call CheckWillyWallCollision
    pop  bc

    ; Se collisione: non aggiornare posizione
    jr   c, save_x

    ; Applica movimento
    ld   a, c
    sub  e
    ld   c, a

    jr   save_x

; ---------------------------------------------------------------
; Clamp sinistra: forzatura al limite minimo
; ---------------------------------------------------------------
.clamp_left:
    ; Controlla se c'è una stanza a sinistra
    ld   hl, (room_ptr)
    ld   de, 235           ; Offset per stanza a sinistra
    add  hl, de
    ld   a, (hl)           ; A = ID stanza a sinistra
    cp   $FF
    jr   z, .no_left_transition
    
    ; C'è una stanza a sinistra!
    ld   c, PLAYER_MAX_X   ; Posiziona Willy a destra della nuova stanza
    jp   TriggerRoomChange ; Salta alla transizione (non ritorna qui)
    
.no_left_transition:
    push bc
    ld   c, PLAYER_MIN_X
    call CheckWillyWallCollision
    pop  bc
    jr   c, save_x         ; Se collide al limite, mantieni la posizione precedente
    
    ld   c, PLAYER_MIN_X
    jr   save_x

; ===============================================================
; MOVIMENTO DESTRA
; ===============================================================
movePlayer_right:
    ; Impedisci lo spostamento a destra se Willy è sul conveyor ed il conveyor va a sinistra.
    call CheckWillyOnConveyor
    jr   nc, .continue_right
    ld   a, (conveyor_dir)
    or   a
    ret  z                      ; Se è sul conveyor e va a sinistra, ritorna senza muovere

.continue_right:
    ; Prova movimento X + speed
    ld   a, (on_ground)
    or   a
    jr   z, .air_right
    ld   a, (player_speed)
    jr   .speed_right_ok
.air_right:
    ld   a, 2
    ld   hl, jump_frame
    bit  0, (hl)
    jr   z, .speed_right_ok
    inc  a                      ; Alterna 2 e 3 px per frame (Media = 2.5 px/frame)
.speed_right_ok:
    ld   e, a

    ld   a, c
    add  a, e

    ; Controllo limite destro
    cp   PLAYER_MAX_X
    jr   z, .ok_right
    jr   nc, .clamp_right

.ok_right:

    ; -----------------------------------------------------------
    ; Collisione muro a destra
    ; usa bordo destro player (X + 7)
    ; -----------------------------------------------------------
    push bc
    add  a, 7
    ld   c, a
    call CheckWillyWallCollision
    pop  bc

    jr   c, save_x

    ; Applica movimento
    ld   a, c
    add  a, e
    ld   c, a

    jr   save_x

; ---------------------------------------------------------------
; Clamp destro: forzatura al limite massimo
; ---------------------------------------------------------------
.clamp_right:
    ; Controlla se c'è una stanza a destra
    ld   hl, (room_ptr)
    ld   de, 236           ; Offset per stanza a destra
    add  hl, de
    ld   a, (hl)           ; A = ID stanza a destra
    cp   $FF
    jr   z, .no_right_transition
    
    ; C'è una stanza a destra!
    ld   c, PLAYER_MIN_X   ; Posiziona Willy a sinistra della nuova stanza
    jp   TriggerRoomChange ; Salta alla transizione
    
.no_right_transition:
    push bc
    ld   a, PLAYER_MAX_X
    add  a, 7
    ld   c, a
    call CheckWillyWallCollision
    pop  bc
    jr   c, save_x         ; Se collide al limite, mantieni la posizione precedente
    
    ld   c, PLAYER_MAX_X

; ===============================================================
; Salvataggio posizione finale
; ===============================================================
save_x:

    ld   (PlayerPos), bc

; ===============================================================
; Animazione corpo (gambe)
; ciclo: 0 → 1 → 2 → 0 ...
; ===============================================================
movePlayer_print:

    ld   a, (body_state)
    inc  a

    cp   3
    jr   nz, .save_state

    ld   a, 0

.save_state:

    ld   (body_state), a

    ret

; -------------------------------------------------------------------
; LoadPositionPlayeinRoom
;
; Inizializza la posizione del player (Willy) quando entra
; in una nuova stanza.
;
; La posizione viene letta direttamente dai dati della stanza
; (layout/metadata) a partire da room_ptr.
;
; Output:
;   PlayerPos     = posizione iniziale (Y, X)
;   PlayerPosOld  = copia della posizione iniziale
;
; Struttura dati stanza:
;   OFFSET_POS_WILLY:
;       +0 = X
;       +1 = Y
; -------------------------------------------------------------------
LoadPositionPlayeinRoom:
    ; ---------------------------------------------------------------
    ; Accede alla struttura dati della stanza corrente (OFFSET_POS_WILLY = 616)
    ; ---------------------------------------------------------------
    ld   hl, (room_ptr)
    ld   de, OFFSET_POS_WILLY
    add  hl, de

    ; Byte 0: Y * 2
    ld   a, (hl)
    srl  a                         ; A = Pixel Y (es. 208 -> 104)
    ld   d, a                      ; D = PlayerY

    ; Byte 2: Direction (0 = right, 1 = left in formato MM)
    inc  hl                        ; Byte 1 (Anim frame)
    inc  hl                        ; Byte 2 (Direction)
    ld   a, (hl)
    and  1
    jr   z, .facing_right
    ld   a, 1                      ; 1 = Sinistra nel motore
    jr   .set_dir
.facing_right:
    ld   a, 2                      ; 2 = Destra nel motore
.set_dir:
    ld   (direction), a

    ; Byte 4-5: Location in attribute buffer (DEFW) -> AttrAddr (es. 23970)
    inc  hl                        ; Byte 3 (Airborne)
    inc  hl                        ; Byte 4 (AttrAddr Low)
    ld   c, (hl)
    inc  hl                        ; Byte 5 (AttrAddr High)
    ld   a, (hl)

    ; Col = (AttrAddr - 23552) & 31 -> Pixel X = Col * 8
    ld   h, a
    ld   l, c
    ld   bc, -23552
    add  hl, bc
    
    ld   a, l
    and  31
    add  a, a                      ; *2
    add  a, a                      ; *4
    add  a, a                      ; *8 -> Pixel X (es. 16)
    ld   c, a                      ; C = PlayerX
    ld   b, d                      ; B = PlayerY

    ; Salva coordinate (C = X, B = Y)
    ld   (PlayerPos), bc
    ld   (PlayerPosOld), bc
    ret

; -------------------------------------------------------------------
; InitRoomEntryPositions
; Popola la tabella room_entry_positions con le coordinate di default
; per tutte le stanze (NUM_ROOMS).
; -------------------------------------------------------------------
InitRoomEntryPositions:
    ld   hl, RoomsListTable
    ld   de, room_entry_positions
    ld   b, NUM_ROOMS
.loop:
    push bc
    push de
    ld   e, (hl)
    inc  hl
    ld   d, (hl)                   ; DE = puntatore alla struttura stanza
    inc  hl
    push hl                        ; Salva posizione corrente in RoomsListTable

    ; Calcola indirizzo di OFFSET_POS_WILLY
    ld   hl, OFFSET_POS_WILLY
    add  hl, de                    ; HL = layout + OFFSET_POS_WILLY
    
    ld   a, (hl)                   ; Byte 0: Y * 2
    srl  a
    push af                        ; Salva PlayerY sullo stack
    
    inc  hl                        ; Byte 1
    inc  hl                        ; Byte 2
    inc  hl                        ; Byte 3
    inc  hl                        ; Byte 4 (AttrAddr Low)
    ld   c, (hl)
    inc  hl                        ; Byte 5 (AttrAddr High)
    ld   a, (hl)
    
    ld   h, a
    ld   l, c
    ld   bc, -23552
    add  hl, bc
    ld   a, l
    and  31
    add  a, a
    add  a, a
    add  a, a                      ; Col * 8 = Pixel X
    ld   c, a                      ; C = PlayerX
    pop  af                        ; A = PlayerY
    ld   b, a                      ; B = PlayerY

    pop  hl                        ; Ripristina puntatore RoomsListTable
    pop  de                        ; DE = room_entry_positions + (i * 2)
    ld   a, c
    ld   (de), a                   ; X
    inc  de
    ld   a, b
    ld   (de), a                   ; Y
    inc  de

    pop  bc
    djnz .loop
    ret

