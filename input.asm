;===========================================================================
; input.asm
;===========================================================================


; -------------------------------------------------------------------
; Input_CheckCtrl
; Legge la tastiera e popola il registro D con i flag di input.
;
; Output:
;   D = bitmask tasti attivi:
;       bit 0 → sinistra (O)
;       bit 1 → destra   (P)
;       bit 2 → salto    (Z)
;
; Effetti collaterali in RAM:
;   (q_prev)        → debounce tasto Q (cambio stanza)
;   (direction)     → 1=sinistra, 2=destra (ultimo movimento)
;   (jump_prev)     → debounce tasto salto
;   (jump_pressed)  → flag "salto appena premuto" (edge detection)
;   (flags)         → bit 0 impostato se movimento rilevato
; -------------------------------------------------------------------

Input_CheckCtrl:
    xor  a
    ld   (current_input_dir), a

    IF ENABLE_ROOM_SKIP_KEYS != 0
    ; ── Sezione 1a: tasto Q (cambio stanza AVANTI) ─────────────────────
    ;
    ; Porta $FB → riga Q, W, E, R, T. Bit 0 = Q.
    ; Se bit 0 = 0, Q è premuto.

    ld   bc, $fbfe
    in   a, (c)
    bit  0, a
    jr   nz, .q_not_pressed     ; bit 0 = 1 → Q non premuto, salta

    ; Q è premuto: debounce tramite (q_prev).
    ; Se (q_prev) ≠ 0 il tasto era già giù nel frame precedente → ignora.
    ld   a, (q_prev)
    or   a
    jr   nz, .q_handled         ; era già premuto, niente da fare

    ; ── Primo frame di pressione di Q ──
    ld   a, 1
    ld   (q_prev), a            ; marca "Q era premuto"

    ; NOTA sullo stack:
    ; Input_CheckCtrl è stata invocata con CALL, quindi l'indirizzo di ritorno
    ; è in cima allo stack. Vogliamo saltare a PerformRoomChangeNext senza
    ; tornare al chiamante, quindi POP HL scarta quell'indirizzo,
    ; poi JP salta direttamente.
    pop  hl                     ; rimuove indirizzo di ritorno di Input_CheckCtrl
    jp   PerformRoomChangeNext  ; salta al cambio stanza avanti (non torna qui)

.q_not_pressed:
    xor  a
    ld   (q_prev), a            ; Q rilasciato → azzera debounce

.q_handled:

    ; ── Sezione 1b: tasto A (cambio stanza INDIETRO) ────────────────────
    ;
    ; Porta $FD → riga A, S, D, F, G. Bit 0 = A.
    ; Se bit 0 = 0, A è premuto.

    ld   bc, $fdfe
    in   a, (c)
    bit  0, a
    jr   nz, .a_not_pressed     ; bit 0 = 1 → A non premuto, salta

    ; A è premuto: debounce tramite (a_prev).
    ld   a, (a_prev)
    or   a
    jr   nz, .a_handled         ; era già premuto, niente da fare

    ; ── Primo frame di pressione di A ──
    ld   a, 1
    ld   (a_prev), a            ; marca "A era premuto"

    pop  hl                     ; rimuove indirizzo di ritorno di Input_CheckCtrl
    jp   PerformRoomChangePrev  ; salta al cambio stanza indietro (non torna qui)

.a_not_pressed:
    xor  a
    ld   (a_prev), a            ; A rilasciato → azzera debounce

.a_handled:
    call Input_CheckWarpKeys
    ENDIF

    ; ── Sezione 2: movimento (sinistra / destra) ────────────────────
    ;
    ; Porta $DF → riga P, O, I, U, Y.
    ; Bit 0 = P (destra), Bit 1 = O (sinistra).

    ld  d, $00                  ; azzera output
    ld  bc, $dffe
    in  a, (c)                  ; legge riga $FE

    ld  ix, flags               ; IX punta alla variabile flags

checkCtrl_left:
    bit $01, a                  ; bit 1 = O → sinistra?
    jr  nz, checkCtrl_right     ; bit = 1 → O non premuto, prova destra
    set $00, d                  ; imposta bit 0 di D = "sinistra attiva"
    set 0, (ix)                 ; flags bit 0 = "movimento in corso"
    ld  e, a                    ; salva A
    ld  a, 1
    ld  (current_input_dir), a
    ld  a, (on_ground)
    or  a
    jr  z, .skip_dir_left
    ld  a, 1
    ld  (direction), a          ; direction = 1 → sinistra
.skip_dir_left:
    ld  a, e                    ; ripristina A

checkCtrl_right:
    bit $00, a                  ; bit 0 = P → destra?
    jr  nz, checkCtrl_jump      ; bit = 1 → P non premuto, prova salto
    set $01, d                  ; imposta bit 1 di D = "destra attiva"
    set 0, (ix)                 ; flags bit 0 = "movimento in corso"
    ld  e, a
    ld  a, 2
    ld  (current_input_dir), a
    ld  a, (on_ground)
    or  a
    jr  z, .skip_dir_right
    ld  a, 2
    ld  (direction), a          ; direction = 2 → destra
.skip_dir_right:
    ld  a, e

checkCtrl_jump:

    ; ── Sezione 3: salto (Z) ────────────────────────────────────────
    ;
    ; Salto su Z.
    ;
    ; Z → porta $FE, bit 1  (riga CAPS, Z, X, C, V)

    ld  bc, $fefe
    in  a, (c)
    bit 1, a
    jr  z, .pressed             ; bit 1 = 0 → Z premuto

.released:
    ; Nessun tasto di salto premuto: azzera debounce.
    xor a
    ld  (jump_prev), a
    jr  .end

.pressed:
    ; Tasto salto premuto: edge detection.
    ; Se (jump_prev) ≠ 0 era già premuto nel frame precedente → ignora.
    ld  a, (jump_prev)
    or  a
    jr  nz, .end
    ; Primo frame di pressione:
    ld  a, 1
    ld  (jump_prev), a          ; marca come già premuto (debounce)
    ld  a, JUMP_BUFFER_FRAMES
    ld  (jump_pressed), a       ; imposta buffer di salto
    set 2, d                    ; imposta bit 2 di D = "salto attivo"

.end:

    ; ── Sezione 4: filtro "entrambe le direzioni" ───────────────────
    ;
    ; Se O e P sono premuti insieme i movimenti si annullano:
    ; azzera entrambi i bit di direzione, mantieni solo l'eventuale salto.
    ;
    ;   A = D AND $03   → isola bit 0 (sinistra) e bit 1 (destra)
    ;   A - $03         → zero solo se entrambi attivi
    ;   RET NZ          → non entrambi attivi → ritorna con D intatto
    ;
    ;   (cade qui solo se O e P premuti insieme)
    ;   A = D AND $04   → tieni solo bit 2 (salto)
    ;   D = A           → direzioni cancellate, salto conservato

    ld   a, d
    and  $03                    ; isola bit 0 e bit 1 (direzioni)
    sub  $03                    ; zero se e solo se entrambi attivi
    ret  nz                     ; non entrambi → ritorna con D com'è

    ld   a, d
    and  $04                    ; tieni solo il bit 2 (salto)
    ld   d, a                   ; D = solo salto, direzioni azzerate
    xor  a
    ld   (current_input_dir), a
    ret

    IF ENABLE_ROOM_SKIP_KEYS != 0
; -------------------------------------------------------------------
; Esegue il cambio di stanza ciclico alla stanza successiva o precedente
; -------------------------------------------------------------------
PerformRoomChange:
PerformRoomChangeNext:
    ld   d, 1                      ; 1 = avanti
    jr   PerformRoomChangeCommon

PerformRoomChangePrev:
    ld   d, 0                      ; 0 = indietro

PerformRoomChangeCommon:
    ; 1. Cerca il layout corrente in RoomsListTable per trovare l'indice
    ld   hl, RoomsListTable
    ld   bc, (room_ptr)            ; BC = layout corrente
    ld   e, 0                      ; E = contatore indice
.loop:
    ld   a, (hl)
    inc  hl
    cp   c
    jr   nz, .no_match
    ld   a, (hl)
    cp   b
    jr   z, .found
.no_match:
    inc  hl
    inc  e
    ld   a, e
    cp   NUM_ROOMS
    jr   c, .loop
    
    ld   e, 0                      ; Se non trovato, riparte da 0

.found:
    ; 2. Trova il prossimo / precedente indice non nullo (ciclando)
    ld   c, e                      ; C = indice di partenza
.index_loop:
    bit  0, d
    jr   z, .go_prev

.go_next:
    ld   a, c
    inc  a
    cp   NUM_ROOMS
    jr   c, .no_wrap_next
    xor  a
.no_wrap_next:
    ld   c, a                      ; C = nuovo indice candidato
    jr   .check_candidate

.go_prev:
    ld   a, c
    sub  1
    jr   nc, .no_wrap_prev
    ld   a, NUM_ROOMS - 1          ; Ultimo indice valido
.no_wrap_prev:
    ld   c, a                      ; C = nuovo indice candidato

.check_candidate:
    ; Leggi RoomsListTable[C] senza corrompere C (indice) né D (direzione)
    push hl
    push de
    ld   hl, RoomsListTable
    ld   e, c
    ld   d, 0
    add  hl, de
    add  hl, de                    ; HL = RoomsListTable + C * 2
    ld   e, (hl)
    inc  hl
    ld   d, (hl)                   ; DE = RoomsListTable[C] (puntatore al layout)
    ld   a, d
    or   e                         ; DE == 0?
    jr   nz, .found_candidate

    ; Candidate is NULL (dw 0)
    pop  de                        ; Ripristina D (direzione) e registro DE
    pop  hl                        ; Ripristina HL
    jr   .index_loop               ; Riprova con la stanza successiva/precedente (C e D intatti!)

.found_candidate:
    ; Trovato! DE = puntatore al layout della stanza
    pop  af                        ; Scarta lo stack frame temporaneo per DE
    pop  hl                        ; Ripristina HL
    ld   (room_ptr), de
    
    ; Azzera transition_active per far caricare a LoadRoomAndRestart
    ; le coordinate iniziali reali definite nella stanza (OFFSET_POS_WILLY)
    xor  a
    ld   (transition_active), a
    ld   (velocity_y), a
    
    ; Pulisci lo schermo e ricarica la stanza
    ld   a, $07
    call Gfx_ClearScreenDirect
    
    jp   LoadRoomAndRestart

; -------------------------------------------------------------------
; Sezione 1c: Selezione diretta della stanza via W + numero stanza + Enter
; -------------------------------------------------------------------
Input_CheckWarpKeys:
    ; 1. Controlla pressione tasto W (Porta $FBFE, Bit 1)
    ld   bc, $fbfe
    in   a, (c)
    bit  1, a
    jr   nz, .w_not_pressed

    ; Tasto W è premuto
    ld   a, (w_key_prev)
    or   a
    jr   nz, .w_handled          ; Era già premuto nel frame precedente

    ; Primo frame di pressione di W!
    ld   a, 1
    ld   (w_key_prev), a
    ld   (w_warp_state), a       ; Imposta stato = 1 (in attesa del 1° digit)
    jr   .w_handled

.w_not_pressed:
    xor  a
    ld   (w_key_prev), a

.w_handled:
    ; 2. Se non siamo in modalità warp (w_warp_state == 0), esci
    ld   a, (w_warp_state)
    or   a
    ret  z

    ; 3. Controlla tasti numerici (0..9)
    call ScanDigitKeys          ; Ritorna A = 0..9 se un tasto numerico è giù, o 0xFF
    cp   $ff
    jr   z, .no_digit_pressed

    ; Un tasto numerico è giù
    ld   b, a                   ; B = cifra (0..9)
    ld   a, (digit_key_prev)
    cp   b
    jr   z, .digit_handled      ; Era già giù nel frame precedente

    ; Primo frame di pressione del tasto numerico B!
    ld   a, b
    ld   (digit_key_prev), a    ; Salva per debounce

    ld   a, (w_warp_state)
    cp   1
    jr   nz, .check_state_2
    ; Stato 1 -> Salva 1° digit, imposta stato = 2
    ld   a, b
    ld   (w_warp_d1), a
    ld   a, 2
    ld   (w_warp_state), a
    jr   .digit_handled

.check_state_2:
    ; Stato 2 o 3 -> Salva 2° digit, imposta stato = 3
    ld   a, b
    ld   (w_warp_d2), a
    ld   a, 3
    ld   (w_warp_state), a
    jr   .digit_handled

.no_digit_pressed:
    ld   a, $ff
    ld   (digit_key_prev), a

.digit_handled:
    ; 4. Controlla tasto ENTER (Porta $BFFE, Bit 0)
    ld   bc, $bffe
    in   a, (c)
    bit  0, a
    jr   nz, .enter_not_pressed

    ; Tasto Enter è premuto
    ld   a, (enter_key_prev)
    or   a
    jr   nz, .enter_handled

    ; Primo frame di pressione del tasto Enter!
    ld   a, 1
    ld   (enter_key_prev), a

    ld   a, (w_warp_state)
    cp   2
    jr   z, .enter_state_2      ; 1 digit inserito (es. W5 + Enter)
    cp   3
    jr   z, .enter_state_3      ; 2 digit inseriti (es. W28 + Enter)

    ; Enter premuto in stato 1 (nessun digit) -> resetta stato warp
    xor  a
    ld   (w_warp_state), a
    jr   .enter_handled

.enter_state_2:
    ; 1 digit: room_id = w_warp_d1
    ld   a, (w_warp_d1)
    jp   PerformDirectRoomJump

.enter_state_3:
    ; 2 digit: room_id = (w_warp_d1 * 10) + w_warp_d2
    ld   a, (w_warp_d1)
    ld   b, a
    add  a, a                    ; * 2
    add  a, a                    ; * 4
    add  a, b                    ; * 5
    add  a, a                    ; * 10
    ld   b, a
    ld   a, (w_warp_d2)
    add  a, b                    ; A = (d1 * 10) + d2
    jp   PerformDirectRoomJump

.enter_not_pressed:
    xor  a
    ld   (enter_key_prev), a

.enter_handled:
    ret

; -------------------------------------------------------------------
; Esegue il salto diretto alla stanza specificata nel registro A
; -------------------------------------------------------------------
PerformDirectRoomJump:
    cp   NUM_ROOMS
    jr   nc, .invalid_room

    ld   c, a
    ld   b, 0
    ld   hl, RoomsListTable
    add  hl, bc
    add  hl, bc                    ; HL = RoomsListTable + A * 2

    ld   e, (hl)
    inc  hl
    ld   d, (hl)                   ; DE = RoomsListTable[A]

    ld   a, d
    or   e                         ; DE == 0? (Layout nullo)
    jr   z, .invalid_room

    ; Stanza valida trovata!
    ld   (room_ptr), de
    xor  a
    ld   (w_warp_state), a
    ld   (transition_active), a
    ld   (velocity_y), a

    ld   a, $07
    call Gfx_ClearScreenDirect

    ld   sp, $fdf0
    jp   LoadRoomAndRestart

.invalid_room:
    xor  a
    ld   (w_warp_state), a
    ret

; -------------------------------------------------------------------
; Legge i tasti numerici 0..9.
; Output: A = 0..9 se un tasto numerico è premuto, oppure A = $FF.
; -------------------------------------------------------------------
ScanDigitKeys:
    ; Porta $F7FE -> Tasti 1, 2, 3, 4, 5 (bit 0..4)
    ld   bc, $f7fe
    in   a, (c)
    bit  0, a
    jr   z, .d1
    bit  1, a
    jr   z, .d2
    bit  2, a
    jr   z, .d3
    bit  3, a
    jr   z, .d4
    bit  4, a
    jr   z, .d5

    ; Porta $EFFE -> Tasti 0, 9, 8, 7, 6 (bit 0..4)
    ld   bc, $effe
    in   a, (c)
    bit  0, a
    jr   z, .d0
    bit  1, a
    jr   z, .d9
    bit  2, a
    jr   z, .d8
    bit  3, a
    jr   z, .d7
    bit  4, a
    jr   z, .d6

    ld   a, $ff
    ret

.d0: ld   a, 0 : ret
.d1: ld   a, 1 : ret
.d2: ld   a, 2 : ret
.d3: ld   a, 3 : ret
.d4: ld   a, 4 : ret
.d5: ld   a, 5 : ret
.d6: ld   a, 6 : ret
.d7: ld   a, 7 : ret
.d8: ld   a, 8 : ret
.d9: ld   a, 9 : ret

    ENDIF

TriggerRoomChange:
    ; Input: A = nuovo room ID, C = Willy X, B = Willy Y
    cp   NUM_ROOMS
    ret  nc                        ; Se A >= NUM_ROOMS, ignora transizione!
    
    push bc
    ld   hl, RoomsListTable
    ld   c, a
    ld   b, 0
    add  hl, bc
    add  hl, bc                    ; HL = RoomsListTable + A * 2
    
    ld   e, (hl)
    inc  hl
    ld   d, (hl)                   ; DE = puntatore al layout della nuova stanza
    
    ld   a, d
    or   e                         ; DE == 0?
    pop  bc
    ret  z                         ; Se layout è NULL (stanza non creata), ignora transizione!
    
    ld   (room_ptr), de            ; Aggiorna room_ptr con la nuova stanza prima delle verifiche rampa!

    ; Ricorda se Willy era a terra: entrando dal basso l'aggancio alla rampa
    ; vale solo se ci stava camminando sopra (rampa che continua tra le stanze)
    ld   a, (on_ground)
    ld   (room_change_grounded), a

    ; Reset completo della fisica del player per la nuova stanza
    xor  a
    ld   (velocity_y), a
    ld   (jump_start_y), a         ; Reset del punto di partenza del salto!
    ld   (jump_pressed), a
    ld   (coyote_timer), a
    ld   (jump_frame), a
    ld   (jump_dir), a
    ld   (on_ground), a            ; Imposta a 0 (mezz'aria / caduta)

    ; Se l'ingresso è orizzontale, evita che il primo tratto della
    ; schermata venga interpretato come atterraggio sulla rampa adiacente.
    ; Le transizioni verticali applicano l'allineamento della rampa se presente.
    ld   a, c
    cp   PLAYER_MIN_X
    jr   z, .set_ramp_guard_from_left
    cp   PLAYER_MAX_X
    jr   z, .set_ramp_guard_from_right
    
    ; Transizione verticale!
    xor  a
    ld   (ramp_entry_guard), a
    ; Ingresso dal basso (B nella metà inferiore): aggancia la rampa solo se
    ; Willy ci stava camminando sopra. Se arriva in salto, niente calamita:
    ; sarà la fisica normale a farlo atterrare sulla rampa se ci ricade sopra.
    ld   a, b
    cp   48
    jr   c, .vert_ramp_check       ; Ingresso dall'alto (B=4): comportamento invariato
    ld   a, (room_change_grounded)
    or   a
    jr   z, .ramp_guard_done       ; Era in volo: nessun aggancio alla rampa
.vert_ramp_check:
    call Phys_CheckRampOnRoomChange ; Se allineato, modifica B (PlayerY) e C (PlayerX) e imposta on_ground = 1
    jr   .ramp_guard_done
    
.set_ramp_guard_from_left:
    ld   a, 1
    ld   (ramp_entry_guard), a
    ld   (ramp_entry_guard_dir), a
    ld   a, PLAYER_MIN_X + 16
    ld   (ramp_entry_guard_x), a
    jr   .ramp_guard_done
.set_ramp_guard_from_right:
    ld   a, 1
    ld   (ramp_entry_guard), a
    ld   a, 2
    ld   (ramp_entry_guard_dir), a
    ld   a, PLAYER_MAX_X - 16
    ld   (ramp_entry_guard_x), a
.ramp_guard_done:
    
    ld   (PlayerPos), bc           ; Salva le coordinate aggiornate da Phys_CheckRampOnRoomChange
    ld   (PlayerPosOld), bc
    ld   (room_ptr), de            ; Aggiorna room_ptr

    ; Memorizza il punto di ingresso (bc: C=X, B=Y) per la nuova stanza in room_entry_positions
    push bc
    push de
    call DetermineCurrentRoomID    ; A = ID della nuova stanza (0..NUM_ROOMS-1)
    ld   hl, room_entry_positions
    ld   e, a
    ld   d, 0
    add  hl, de
    add  hl, de                    ; HL = room_entry_positions + (new_room_id * 2)
    pop  de
    pop  bc
    ld   a, c
    ld   (hl), a                   ; Salva X di ingresso per la stanza
    inc  hl
    ld   a, b
    ld   (hl), a                   ; Salva Y di ingresso per la stanza

    ; Imposta il flag di transizione per non caricare la posizione di default
    ld   a, 1
    ld   (transition_active), a
    
    ; Pulisci lo schermo
    ld   a, $07
    call Gfx_ClearScreenDirect
    
    ; Reset dello stack pointer prima di riavviare la stanza
    ld   sp, $fdf0
    jp   LoadRoomAndRestart

RoomsListTable:
.CentralCavernLayout:              dw CentralCavernLayout              ; 00
.TheColdRoomLayout:                dw TheColdRoomLayout                ; 01
.TheMenagerieLayout:               dw TheMenagerieLayout               ; 02
.AbandonedUraniumWorkingsLayout:   dw AbandonedUraniumWorkingsLayout   ; 03
.EugeneLairLayout:                 dw EugeneLairLayout                 ; 04
.ProcessingPlantLayout:            dw ProcessingPlantLayout            ; 05
.TheVatLayout:                     dw TheVatLayout                     ; 06
RoomsListTableEnd:
NUM_ROOMS EQU (RoomsListTableEnd - RoomsListTable) / 2

