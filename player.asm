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

    ; In aria: resetta lo stato di cattura del nastro
    xor  a
    ld   (conveyor_caught), a

    ld   a, (jump_dir)
    or   a
    ret  z                  ; Se jump_dir è 0, salto verticale -> nessun movimento orizzontale
    
    ; In volo: resetta comunque il flag di aggiornamento movimento se era impostato
    ld   ix, flags
    res  $00, (ix)

    ld   bc, (PlayerPos)
    cp   1
    jp   z, movePlayer_left
    cp   2
    jp   z, movePlayer_right
    ret

.on_ground_check:
    ; ---------------------------------------------------------------
    ; Controlla se Willy è sopra un nastro trasportatore (Conveyor)
    ; ---------------------------------------------------------------
    call CheckWillyOnConveyor
    jr   c, .on_conveyor_ground

    ; ---------------------------------------------------------------
    ; Terreno normale (non su conveyor):
    ; Resetta lo stato di cattura del conveyor
    ; ---------------------------------------------------------------
    xor  a
    ld   (conveyor_caught), a

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
    jp   nz, movePlayer_right

    ; ---------------------------------------------------------------
    ; Input: sinistra?
    ; ---------------------------------------------------------------
    bit  $00, d
    ret  z
    jp   movePlayer_left

.on_conveyor_ground:
    ; ---------------------------------------------------------------
    ; Willy si trova sul nastro trasportatore:
    ; - Se Willy monta sul nastro muovendosi nella direzione opposta
    ;   allo scorrimento, finché tiene premuto il tasto direzionale
    ;   continua il movimento nella direzione scelta.
    ; - Non appena il tasto direzionale opposto viene rilasciato,
    ;   Willy viene catturato dal nastro (conveyor_caught = 1) e trascinato
    ;   nella direzione del nastro.
    ; - Se il tasto opposto viene ripremuto mentre Willy è già catturato
    ;   sul nastro, non ha alcun effetto e Willy continua a essere trascinato.
    ; ---------------------------------------------------------------
    ld   ix, flags
    res  $00, (ix)
    ld   bc, (PlayerPos)

    ld   a, (conveyor_dir)
    or   a
    jr   nz, .conv_is_right

    ; ── CONVEYOR VA A SINISTRA (conveyor_dir == 0) ──
    ; Tasto opposto = DESTRA (bit 1 di D)
    bit  $01, d                 ; Premuto DESTRA (opposto)?
    jr   nz, .check_oppose_right

    ; Non sta premendo Destra: Willy viene catturato dal nastro a Sinistra
    ld   a, 1
    ld   (conveyor_caught), a

    ; Muovi a Sinistra (trascinamento del nastro)
    ld   a, 1
    ld   (direction), a
    jp   movePlayer_left

.check_oppose_right:
    ; Sta premendo Destra contro il nastro a Sinistra.
    ; Se sta saltando (bit 2 di D o jump_pressed), permetti sempre il salto a Destra
    bit  2, d
    jr   nz, .do_move_right
    ld   a, (jump_pressed)
    or   a
    jr   nz, .do_move_right

    ; Se era già stato catturato (tasto rilasciato prima sul nastro), ignora l'input!
    ld   a, (conveyor_caught)
    or   a
    jr   nz, .right_ignored_drag_left

.do_move_right:
    ; Non era ancora catturato o sta saltando: continua a muoversi a Destra!
    ld   a, 2
    ld   (direction), a
    jp   movePlayer_right

.right_ignored_drag_left:
    ; Tasto opposto ignorato: continua il trascinamento a Sinistra
    ld   a, 1
    ld   (direction), a
    jp   movePlayer_left

.conv_is_right:
    ; ── CONVEYOR VA A DESTRA (conveyor_dir == 1) ──
    ; Tasto opposto = SINISTRA (bit 0 di D)
    bit  $00, d                 ; Premuto SINISTRA (opposto)?
    jr   nz, .check_oppose_left

    ; Non sta premendo Sinistra: Willy viene catturato dal nastro a Destra
    ld   a, 1
    ld   (conveyor_caught), a

    ; Muovi a Destra (trascinamento del nastro)
    ld   a, 2
    ld   (direction), a
    jp   movePlayer_right

.check_oppose_left:
    ; Sta premendo Sinistra contro il nastro a Destra.
    ; Se sta saltando (bit 2 di D o jump_pressed), permetti sempre il salto a Sinistra
    bit  2, d
    jr   nz, .do_move_left
    ld   a, (jump_pressed)
    or   a
    jr   nz, .do_move_left

    ; Se era già stato catturato (tasto rilasciato prima sul nastro), ignora l'input!
    ld   a, (conveyor_caught)
    or   a
    jr   nz, .left_ignored_drag_right

.do_move_left:
    ; Non era ancora catturato o sta saltando: continua a muoversi a Sinistra!
    ld   a, 1
    ld   (direction), a
    jp   movePlayer_left

.left_ignored_drag_right:
    ; Tasto opposto ignorato: continua il trascinamento a Destra
    ld   a, 2
    ld   (direction), a
    jp   movePlayer_right

; -------------------------------------------------------------------
; GetPlayerAirSpeed
;
; Calcola la velocità orizzontale in volo (pixel per frame) in base al
; preset configurato in player_air_speed (DEFAULT_AIR_SPEED_PRESET).
;
; Presets:
;   0 = 1.0 px/frame costante  (parabola stretta)
;   1 = 1.5 px/frame alternato (parabola corta: alterna 1 e 2 px)
;   2 = 2.0 px/frame costante  (parabola media)
;   3 = 2.5 px/frame alternato (parabola standard MM: alterna 2 e 3 px)
;   4 = 3.0 px/frame costante  (parabola estesa)
;
; Output:
;   A = pixel di spostamento orizzontale per il frame corrente
; -------------------------------------------------------------------
GetPlayerAirSpeed:
    ld   a, (player_air_speed)
    or   a
    jr   z, .speed_1_0
    dec  a
    jr   z, .speed_1_5
    dec  a
    jr   z, .speed_2_0
    dec  a
    jr   z, .speed_2_5
    dec  a
    jr   z, .speed_3_0
    
    ; Default: se valore diverso, usa 2.0 px/frame
    jr   .speed_2_0

.speed_1_0:
    ld   a, 1
    ret

.speed_1_5:
    ld   a, 1
    ld   hl, jump_frame
    bit  0, (hl)
    ret  z
    inc  a                      ; Alterna 1 e 2 px
    ret

.speed_2_0:
    ld   a, 2
    ret

.speed_2_5:
    ld   a, 2
    ld   hl, jump_frame
    bit  0, (hl)
    ret  z
    inc  a                      ; Alterna 2 e 3 px (standard MM)
    ret

.speed_3_0:
    ld   a, 3
    ret

; ===============================================================
; MOVIMENTO SINISTRA
; ===============================================================
movePlayer_left:
    ; Calcola nuova posizione: X - speed
    ld   a, (on_ground)
    or   a
    jr   z, .air_left
    ld   a, (player_speed)
    jr   .speed_left_ok
.air_left:
    call GetPlayerAirSpeed
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
    ; Prova movimento X + speed
    ld   a, (on_ground)
    or   a
    jr   z, .air_right
    ld   a, (player_speed)
    jr   .speed_right_ok
.air_right:
    call GetPlayerAirSpeed
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
    push bc
    ld   a, PLAYER_MAX_X
    add  a, 7
    ld   c, a
    call CheckWillyWallCollision
    pop  bc
    jr   c, save_x         ; Se collide al limite, mantieni la posizione precedente
    
    ld   c, PLAYER_MAX_X
    jr   save_x

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

    ; Byte 1: Anim frame
    inc  hl
    ld   a, (hl)
    and  3                         ; Garanzia valore valido (0..3)
    cp   3
    jr   c, .valid_anim
    xor  a
.valid_anim:
    ld   (body_state), a
    ld   (player_old_body), a

    ; Byte 2: Direction (0 = right, 1 = left in formato MM)
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
    ld   (player_old_dir), a

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

    ; Reset completi di stato player e rendering
    xor  a
    ld   (sprite_shift), a
    ld   (collision_active), a
    ld   (willy_needs_redraw), a
    ld   (current_input_dir), a
    ld   (conveyor_caught), a
    ld   a, $FF
    ld   (player_drawn_pos), a
    ld   (player_drawn_pos+1), a
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

