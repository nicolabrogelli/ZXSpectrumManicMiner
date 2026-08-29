;===========================================================================
; main.asm
;===========================================================================

    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    DEVICE ZXSPECTRUM48

    org  0x5dad

    ; Include files
    include "settings.asm"
    include "physics_config.asm"
    include "constants.asm"
    include "macro.asm"
    include "interrupts.asm"
    include "graphics.asm"
    include "player.asm"
    include "input.asm"
    include "physics.asm"
    include "enemy.asm"
    include "items.asm"
    include "audio.asm"
    
start:
    ld   sp, $fdf0
    jp   Main
 
;    org $7F50
Main:
    call Gfx_CopyChars
    call Gfx_DefineChars
    
    ld   a, $02
    call OPENCHAN
    ld   hl, $8400 
    ld   (UDG), hl

    ld   a, $07
    call Gfx_ClearScreenDirect

    call SetupIM2

    ; Mostra la schermata iniziale (Title Screen) all'avvio del gioco
    jp   ShowTitleScreen

LoadRoomAndRestart:
    ld   sp, $fdf0             ; Ripristina lo stack pointer per evitare stack drift/reset
    call DetermineCurrentRoomID
    call Phys_LoadRoomSettings
    
    ; Azzera la griglia dei pavimenti sgretolabili per la nuova stanza
    ld   hl, crumbling_grid
    ld   de, crumbling_grid + 1
    ld   (hl), 0
    ld   bc, 511
    ldir
    xor  a
    ld   (crumbling_active_count), a
    ld   (crumbling_anim_timer), a
    ld   (portal_anim_timer), a
    ld   (portal_anim_frame), a

    call Gfx_DrawRoom
    call Gfx_DrawConveyorsAndRamps
    call Gfx_PrintRoomName
    call Gfx_InitAirBar
    call Items_DrawRoom
    call Enemy_LoadRoom
    
    ld   a, (transition_active)
    or   a
    jr   nz, .skip_player_pos
    call LoadPositionPlayeinRoom
    jr   .after_player_pos
.skip_player_pos:
    xor  a
    ld   (transition_active), a
.after_player_pos:

    ; Leggi il colore del bordo dalla stanza corrente e impostalo
    ld   hl, (room_ptr)
    ld   de, OFFSET_BORDER_COLOR
    add  hl, de
    ld   a, (hl)
    and  $07               ; Garantisci un valore valido 0..7
    ld   (room_border_color), a
    out  ($fe), a          ; Imposta colore bordo hardware
    
    ; Aggiorna BORDCR per la ROM in modo sicuro (Paper = border, Ink = white)
    rlca
    rlca
    rlca                   ; Sposta nei bit 3-5
    or   $07               ; Ink bianco nei bit 0-2
    ld   (BORDCR), a

    ld   a, $ff
    ld   (player_drawn_pos+1), a
    call Gfx_PrintPlayer

Main_loop:
.sync_loop:
    halt
    ld   hl, (counter)
    ld   de, (last_frame_counter)
    or   a
    sbc  hl, de
    ld   a, l
    cp   GAME_SPEED_DELAY
    jr   c, .sync_loop
    
    ld   hl, (counter)
    ld   (last_frame_counter), hl
    
    ; Aggiorna il timer di sicurezza (invulnerabilità post-morte)
    ld   a, (willy_safety_timer)
    or   a
    jr   z, .no_safety_dec
    dec  a
    ld   (willy_safety_timer), a
.no_safety_dec:

    ; 1. Rendering atomico nemici ed estrazione sovrapposizioni
    call Enemy_RenderRoom
    
    ; 2. Rendering del giocatore (ridisegna Willy in primo piano se mosso o se coperto da un guardiano)
    call Gfx_UpdatePlayer

    ; 3. Aggiorna animazione e rimozione dei pavimenti sgretolabili (Crumbling Floor)
    call Phys_UpdateCrumblingFloors
    
    ; 4. Aggiorna animazione lampeggio del portale (se attivo)
    call Gfx_AnimatePortal

    ; 5b. Aggiorna consumo aria (morte se esaurita)
    call Phys_UpdateAir
    jp   c, .willy_dies
    
    ; 6. Aggiornamento audio
    IF ENABLE_EFFECTS != 0
    call Audio_UpdateJumpSound    ; Aggiorna l'effetto sonoro del salto
    ENDIF
    
    IF ENABLE_MUSIC != 0
    call Audio_UpdateMusic        ; Aggiorna la musica
    ENDIF
    
    ; Se l'animazione delle vite è abilitata, aggiorna la visualizzazione delle icone camminanti
    IF ENABLE_ANIMATE_LIVES != 0
    call Gfx_PrintWillyLives
    ENDIF


    ; 7. Salva le posizioni correnti del player per il prossimo frame
    ld   bc, (PlayerPos)
    ld   (PlayerPosOld), bc
    
    ; 8. Aggiorna le posizioni dei personaggi per il prossimo frame
    call Input_CheckCtrl
    call MovePlayer
    call Phys_ApplyGravity
    call Enemy_Update
    call Items_CheckCollision
    call Kong_CheckSwitches
    
    ; Controlla passaggio alla stanza successiva tramite Portale (dopo aver raccolto tutti gli item)
    call CheckPortalTransition
    jp   c, TriggerPortalTransition

    ; Controlla collisione con Nasties (morte di Willy)
    IF ENABLE_NASTY_COLLISION_DEATH != 0
    call Phys_CheckNastyCollision
    jr   c, .willy_dies
    ENDIF
    
    ; Controlla collisione con guardiani
    call CheckCollision
    jr   c, .guardian_collision_found
    
    ; Nessuna collisione con guardiani. Controlla se Willy è su rampa per debug raster bar
    IF ENABLE_RAMP_DEBUG_BARS != 0
    ld   a, (willy_on_ramp)
    or   a
    jp   nz, .draw_raster_bars
    ENDIF
    
    jp   .no_collision

.guardian_collision_found:
    ; C'è collisione con un guardiano!
    ; Controlla se la morte per collisione con i guardiani è abilitata
    IF ENABLE_GUARDIAN_COLLISION_DEATH != 0
    jp   .willy_dies
    ELSE
        IF ENABLE_GUARDIAN_DEBUG_BARS != 0
        jp   .draw_raster_bars ; disegna le raster bar per debug se abilitate
        ELSE
        jp   .no_collision
        ENDIF
    ENDIF
    
.willy_dies:
    ; 1. Decrementa le vite
    ld   hl, willy_lives
    ld   a, (hl)
    or   a
    jr   z, .check_game_over
    dec  (hl)
    jr   z, .check_game_over
    jr   .normal_respawn

.check_game_over:
    IF ENABLE_GAME_OVER_RESTART != 0
    jp   TriggerGameOver
    ELSE
    ld   a, 1
    ld   (willy_lives), a
    jr   .normal_respawn
    ENDIF

.normal_respawn:
    ; 1b. Ripristina tutti gli item della stanza corrente (tutti tornano visibili e da raccogliere)
    call Items_ResetCurrentRoomItems

    ; 2. Cancella lo schermo a nero (imposta bordo e schermo a nero)
    xor  a
    out  ($fe), a              ; Imposta colore bordo hardware a nero
    call Gfx_ClearScreenDirect ; Pulisce il display RAM e imposta gli attributi a nero

    ; 3. Pausa a schermo nero (~0.5 secondi per respawn normale)
    ld   b, 25
.death_pause:
    halt
    djnz .death_pause

    ; 4. Reimposta la fisica di Willy e imposta il timer di sicurezza al respawn
    xor  a
    ld   (velocity_y), a
    ld   (jump_pressed), a
    ld   (coyote_timer), a
    ld   (jump_frame), a
    ld   (jump_dir), a
    ld   (body_state), a
    ld   (player_old_body), a
    ld   (player_old_dir), a
    ld   (sprite_shift), a
    ld   (collision_active), a
    ld   (willy_needs_redraw), a
    ld   (current_input_dir), a
    ld   (conveyor_caught), a
    ld   (transition_active), a    ; 0 = Posiziona Willy nel punto definito nella stanza (OFFSET_POS_WILLY)
    ld   a, 1
    ld   (on_ground), a
    
    ld   a, RESPAWN_SAFETY_TIME
    ld   (willy_safety_timer), a

    ; 5. Ricarica la stanza e riposiziona Willy al punto di spawn definito nella stanza
    jp   LoadRoomAndRestart

.draw_raster_bars:
    ; Collisione attiva: disegna le raster bar nel bordo
    ld   a, (counter)
    and  7                 ; Colore iniziale basato sul contatore di frame
    ld   b, 30             ; Numero di righe della barra raster
.raster_loop:
    out  ($fe), a
    inc  a
    and  7
    ld   c, 150            ; Delay per regolare l'altezza delle bande
.delay:
    dec  c
    jr   nz, .delay
    djnz .raster_loop
    
    ; Ripristina il bordo al colore della stanza dopo il disegno delle barre
    ld   a, (room_border_color)
    out  ($fe), a
    jr   .no_collision_change
    
.no_collision:
    ; Nessuna collisione: mantieni il bordo al colore della stanza
    ld   a, (room_border_color)
    out  ($fe), a
    
.no_collision_change:
    jp   Main_loop

; -------------------------------------------------------------------
; ShowTitleScreen
; Visualizza la schermata iniziale del gioco (Title Screen).
; Rimane visibile con animazione ciclica finché il giocatore non preme ENTER.
; Alla pressione di ENTER, inizializza la partita e avvia il primo livello.
; -------------------------------------------------------------------
ShowTitleScreen:
    ; 1. Disegna la schermata iniziale
    call Gfx_DrawTitleScreen

    ; 2. Attende il rilascio del tasto ENTER (se era già premuto)
.wait_title_enter_release:
    halt
    ld   a, $bf
    in   a, ($fe)
    rra
    jr   nc, .wait_title_enter_release

    ; 3. Ciclo di attesa pressione ENTER con animazione colore
    ld   c, 0                  ; C = contatore frame per animazione colore
.title_loop:
    halt

    ; Animazione ciclo colore su "PRESS ENTER TO START" (Riga 12, Col 0..31, $5980)
    inc  c
    ld   a, c
    srl  a
    srl  a
    srl  a                     ; Cambia colore ogni 8 frame (~160ms)
    and  7
    ld   e, a
    ld   d, 0
    ld   hl, title_color_table
    add  hl, de
    ld   a, (hl)               ; A = nuovo colore
    ld   hl, $5980             ; Riga 12 ($5800 + 12*32 = $5980)
    ld   b, 32
.color_title_loop:
    ld   (hl), a
    inc  hl
    djnz .color_title_loop

    ; Controlla se il tasto ENTER è premuto (Porta $BFFE, Bit 0)
    ld   a, $bf
    in   a, ($fe)
    rra
    jr   c, .title_loop        ; Carry = 1 (non premuto) -> continua loop

    ; 4. Attende il rilascio del tasto ENTER per evitare doppi scatti
.wait_title_enter_release_after:
    halt
    ld   a, $bf
    in   a, ($fe)
    rra
    jr   nc, .wait_title_enter_release_after

    ; 5. Pulisce completamente l'intero schermo e gli attributi (cancella totalmente il Title Screen)
    xor  a
    out  ($fe), a              ; Bordo a nero
    call Gfx_ClearScreenDirect ; Pulisce integralmente tutta la memoria pixel (6144B) e attributi (768B)

    ; 6. Ripristina integralmente lo stato iniziale della partita (vite, item, stanze, tempo)
    call ResetFullGameState

    ; 7. Avvia il gioco dal primo livello (Stanza 0: The Off Licence)
    jp   LoadRoomAndRestart

; -------------------------------------------------------------------
; TriggerGameOver
; Scatena la schermata di Game Over per la stanza corrente.
; - Pulisce gli elementi di gioco della stanza (piattaforme, nemici, Willy, item).
; - Esegue l'animazione del Piede (discesa fluida ed atterraggio sotto BotteSprite).
; - Fa comparire la scritta GAME OVER al centro dello schermo dopo la pausa ed anima i suoi colori.
; - Fa comparire la domanda "VUOI CONTINUARE? Y/N" a riga 8.
; - Mantiene visibile il Nome della Stanza corrente e la Riga di Stato (Item ed Orario).
; - Se il giocatore preme 'Y': riprende la partita dal punto esatto in cui era arrivato,
;   mantenendo lo stato della stanza e tutti gli oggetti (items) raccolti.
; - Se il giocatore preme 'N' (o ENTER): esegue il normale flusso del Game Over (Title Screen).
; -------------------------------------------------------------------
TriggerGameOver:
    ; 1. Disegna la schermata di Game Over ed esegue l'animazione del Piede, GAME OVER e prompt continua
    call Gfx_DrawGameOverScreen

    ; 2. Attende il rilascio dei tasti Y, N ed ENTER se erano già premuti
.wait_keys_release:
    halt
    ; Controlla tasto Y (Porta $DF, bit 4)
    ld   bc, $dffe
    in   a, (c)
    bit  4, a
    jr   z, .wait_keys_release

    ; Controlla tasto N (Porta $7F, bit 3)
    ld   bc, $7ffe
    in   a, (c)
    bit  3, a
    jr   z, .wait_keys_release

    ; Controlla tasto ENTER (Porta $BF, bit 0)
    ld   bc, $bffe
    in   a, (c)
    bit  0, a
    jr   z, .wait_keys_release

    ; 3. Attesa della scelta del giocatore con animazione ciclo colore su GAME OVER
    ld   c, 0                  ; C = contatore frame per animazione colore
.wait_choice_loop:
    halt

    ; Animazione ciclo colore per GAME OVER (Riga 5, Colonna 11..19, $58AB)
    inc  c
    ld   a, c
    srl  a
    srl  a                     ; Cambia colore ogni 4 frame (~80ms)
    and  7
    ld   e, a
    ld   d, 0
    ld   hl, game_over_color_table
    add  hl, de
    ld   a, (hl)               ; A = nuovo colore attributo
    ld   hl, $58ab             ; Indirizzo attributi riga 5, col 11 ($5800 + 5*32 + 11 = $58AB)
    ld   b, 9
.color_cycle_loop:
    ld   (hl), a
    inc  hl
    djnz .color_cycle_loop

    ; Controlla se il tasto Y è premuto (Porta $DF, bit 4 = 0)
    ld   bc, $dffe
    in   a, (c)
    bit  4, a
    jr   z, .continue_chosen

    ; Controlla se il tasto N è premuto (Porta $7F, bit 3 = 0)
    ld   bc, $7ffe
    in   a, (c)
    bit  3, a
    jr   z, .quit_chosen

    ; Controlla se il tasto ENTER è premuto (Porta $BF, bit 0 = 0)
    ld   bc, $bffe
    in   a, (c)
    bit  0, a
    jr   z, .quit_chosen

    jr   .wait_choice_loop

.quit_chosen:
    ; 4a. Attende il rilascio di N ed ENTER per evitare doppi scatti
.wait_quit_release:
    halt
    ld   bc, $7ffe
    in   a, (c)
    bit  3, a
    jr   z, .wait_quit_release
    ld   bc, $bffe
    in   a, (c)
    bit  0, a
    jr   z, .wait_quit_release

    ; 5a. Esegue il normale flusso del Game Over (ritorno a Title Screen)
    jp   ShowTitleScreen

.continue_chosen:
    ; 4b. Attende il rilascio del tasto Y per evitare doppi scatti
.wait_continue_release:
    halt
    ld   bc, $dffe
    in   a, (c)
    bit  4, a
    jr   z, .wait_continue_release

    ; 5b. Ripristina lo stato per continuare la partita:
    ; - Ripristina tutti gli item della stanza corrente al valore $FF (tutti da raccogliere)
    call Items_ResetCurrentRoomItems

    ; - Ripristina le vite di Willy al valore iniziale
    ld   a, INITIAL_LIVES
    ld   (willy_lives), a

    ; - Sincronizza i contatori temporali con counter hardware per evitare salti dopo la pausa a schermo
    ld   hl, (counter)
    ld   (last_frame_counter), hl

    ; - Reimposta la fisica e le variabili di stato di Willy
    xor  a
    ld   (velocity_y), a
    ld   (jump_pressed), a
    ld   (coyote_timer), a
    ld   (jump_frame), a
    ld   (jump_dir), a
    ld   (body_state), a
    ld   (w_warp_state), a
    ld   (w_key_prev), a
    ld   (enter_key_prev), a
    ld   (collision_active), a
    ld   (flags), a
    ld   (ramp_entry_guard), a
    ld   (willy_on_ramp), a
    ld   (willy_needs_redraw), a
    ld   a, $ff
    ld   (digit_key_prev), a
    ld   (player_drawn_pos+1), a
    ld   (player_old_dir), a
    ld   (player_old_body), a
    ld   a, 1
    ld   (q_prev), a
    ld   (a_prev), a
    ld   (on_ground), a
    ld   (enemy_was_updated), a
    
    ; - Timer di sicurezza post-respawn (invulnerabilità)
    ld   a, RESPAWN_SAFETY_TIME
    ld   (willy_safety_timer), a

    ; - Ripristina lo stato audio
    ld   a, 18
    ld   (Audio_jump_sound_note), a
    xor  a
    ld   (Audio_jump_sound_timer), a
    IF ENABLE_MUSIC != 0
    ld   (Audio_music_note_idx), a
    ld   a, 1
    ld   (Audio_music_frame_counter), a
    ENDIF

    ; - Riposiziona Willy nel punto di default definito nella stanza
    xor  a
    ld   (transition_active), a

    ; - Cancella lo schermo a nero prima del caricamento
    xor  a
    out  ($fe), a
    call Gfx_ClearScreenDirect

    ; - Ricarica e riavvia la stanza corrente mantenendo tutti gli items raccolti
    jp   LoadRoomAndRestart

; -------------------------------------------------------------------
; TriggerVictory
; Scatena la schermata di vittoria (Victory Screen) per la partita completata.
; - Pulisce gli elementi di gioco della stanza.
; - Esegue l'animazione di Maria (VecchiaSprite) che cammina verso Willy.
; - Fa comparire le scritte "YOU HAVE WON!" e "CONGRATULATIONS!" ed anima i colori.
; - Fa comparire la domanda "PLAY AGAIN? Y/N" a riga 8.
; - Mantiene visibile il Nome della Stanza (Master Bedroom) e la Riga di Stato.
; - Se il giocatore preme 'Y': resetta completamente la partita e avvia una nuova partita.
; - Se il giocatore preme 'N' (o ENTER): ritorna alla schermata iniziale (Title Screen).
; -------------------------------------------------------------------
TriggerVictory:
    ; 1. Disegna la schermata di vittoria ed esegue l'animazione di Maria, CONGRATULATIONS e prompt
    call Gfx_DrawVictoryScreen

    ; 2. Attende il rilascio dei tasti Y, N ed ENTER se erano già premuti
.wait_keys_release:
    halt
    ; Controlla tasto Y (Porta $DF, bit 4)
    ld   bc, $dffe
    in   a, (c)
    bit  4, a
    jr   z, .wait_keys_release

    ; Controlla tasto N (Porta $7F, bit 3)
    ld   bc, $7ffe
    in   a, (c)
    bit  3, a
    jr   z, .wait_keys_release

    ; Controlla tasto ENTER (Porta $BF, bit 0)
    ld   bc, $bffe
    in   a, (c)
    bit  0, a
    jr   z, .wait_keys_release

    ; 3. Attesa della scelta del giocatore con animazione ciclo colore su CONGRATULATIONS!
    ld   c, 0                  ; C = contatore frame per animazione colore
.wait_choice_loop:
    halt

    ; Animazione ciclo colore per CONGRATULATIONS! (Riga 5, Colonna 8..23, $58A8)
    inc  c
    ld   a, c
    srl  a
    srl  a                     ; Cambia colore ogni 4 frame (~80ms)
    and  7
    ld   e, a
    ld   d, 0
    ld   hl, victory_color_table
    add  hl, de
    ld   a, (hl)               ; A = nuovo colore attributo
    ld   hl, $58a8             ; Indirizzo attributi riga 5, col 8 ($5800 + 5*32 + 8 = $58A8)
    ld   b, 16                 ; 16 caratteri "CONGRATULATIONS!"
.color_cycle_loop:
    ld   (hl), a
    inc  hl
    djnz .color_cycle_loop

    ; Controlla se il tasto Y è premuto (Porta $DF, bit 4 = 0)
    ld   bc, $dffe
    in   a, (c)
    bit  4, a
    jr   z, .play_again_chosen

    ; Controlla se il tasto N è premuto (Porta $7F, bit 3 = 0)
    ld   bc, $7ffe
    in   a, (c)
    bit  3, a
    jr   z, .quit_chosen

    ; Controlla se il tasto ENTER è premuto (Porta $BF, bit 0 = 0)
    ld   bc, $bffe
    in   a, (c)
    bit  0, a
    jr   z, .quit_chosen

    jr   .wait_choice_loop

.quit_chosen:
    ; 4a. Attende il rilascio di N ed ENTER per evitare doppi scatti
.wait_quit_release:
    halt
    ld   bc, $7ffe
    in   a, (c)
    bit  3, a
    jr   z, .wait_quit_release
    ld   bc, $bffe
    in   a, (c)
    bit  0, a
    jr   z, .wait_quit_release

    ; 5a. Esegue il normale flusso di uscita (ritorno a Title Screen)
    jp   ShowTitleScreen

.play_again_chosen:
    ; 4b. Attende il rilascio del tasto Y per evitare doppi scatti
.wait_play_again_release:
    halt
    ld   bc, $dffe
    in   a, (c)
    bit  4, a
    jr   z, .wait_play_again_release

    ; 5b. Reset completo dello stato di gioco e avvio di una nuova partita
    call ResetFullGameState
    jp   LoadRoomAndRestart

; -------------------------------------------------------------------
; CheckPortalTransition
; Verifica le condizioni per accedere alla stanza successiva:
; 1. Tutti gli oggetti della caverna corrente devono essere raccolti (game_objective_completed != 0);
; 2. Willy collide con il portale attivo definito a partire dal byte 655 (OFFSET_PORTAL).
;
; Output:
;   Carry Set   = Tutti gli item raccolti e Willy sul portale -> Transizione attiva
;   Carry Clear = Condizioni non soddisfatte -> Nessuna transizione
; -------------------------------------------------------------------
CheckPortalTransition:
    push bc
    push de
    push hl

    ; 1. Tutti gli item della stanza sono stati raccolti?
    call CheckAllItemsCollected
    jr   nc, .no_transition

    ; 2. Willy collide con il portale (16x16 pixel)?
    ; Dai dati della stanza (OFFSET_PORTAL = 655):
    ; Offset 655 + 33 (688) contiene AttrAddr (DEFW: 23552 + Row * 32 + Col)
    ld   hl, (room_ptr)
    ld   de, OFFSET_PORTAL + 33    ; Offset AttrAddr del portale
    add  hl, de
    ld   c, (hl)
    inc  hl
    ld   b, (hl)                   ; BC = AttrAddr
    
    ; Offset = BC - 23552
    ld   h, b
    ld   l, c
    ld   bc, -23552
    add  hl, bc
    
    ; PortalX = (Offset & 31) * 8
    ld   a, l
    and  31
    add  a, a : add a, a : add a, a
    ld   e, a                      ; E = PortalX (0..248)
    
    ; PortalY = (Offset / 32) * 8
    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    srl  h : rr l
    ld   a, l
    add  a, a : add a, a : add a, a
    ld   d, a                      ; D = PortalY (0..120)

    ; Collisione Bounding Box 16x16 tra Willy (PlayerPos) e Portale (E, D)
    ld   bc, (PlayerPos)           ; C = WillyX, B = WillyY
    
    ; Controllo orizzontale: |WillyX - PortalX| < 12
    ld   a, e
    sub  c
    jr   nc, .x_diff_pos
    neg
.x_diff_pos:
    cp   12
    jr   nc, .no_transition

    ; Controllo verticale: |WillyY - PortalY| < 14
    ld   a, d
    sub  b
    jr   nc, .y_diff_pos
    neg
.y_diff_pos:
    cp   14
    jr   nc, .no_transition

    ; Transizione al portale attiva!
    pop  hl
    pop  de
    pop  bc
    scf
    ret

.no_transition:
    pop  hl
    pop  de
    pop  bc
    or   a
    ret

; Alias per retrocompatibilità
CheckVictoryCondition: EQU CheckPortalTransition

; -------------------------------------------------------------------
; TriggerPortalTransition
; Esegue il passaggio alla stanza successiva quando Willy entra nel portale:
; - Identifica l'ID della stanza corrente in RoomsListTable.
; - Avanza all'indice della stanza successiva.
; - Se ci sono altre stanze: carica la nuova stanza leggendo le coordinate
;   iniziali di Willy da OFFSET_POS_WILLY (byte 616) e avvia la stanza.
; - Se era l'ultima stanza disponibile: scatena la vittoria (Victory Screen).
; -------------------------------------------------------------------
TriggerPortalTransition:
    ; 1. Determina l'ID della stanza corrente
    call DetermineCurrentRoomID    ; (current_room) = ID stanza (0..NUM_ROOMS-1)
    
    ; 2. Calcola l'indice della stanza successiva
    ld   a, (current_room)
    inc  a
    cp   NUM_ROOMS
    jr   nc, .all_rooms_completed  ; Se >= NUM_ROOMS, tutte le stanze completate!

    ; 3. Carica il puntatore alla stanza successiva da RoomsListTable[A]
    ld   hl, RoomsListTable
    ld   e, a
    ld   d, 0
    add  hl, de
    add  hl, de                    ; HL = RoomsListTable + A * 2
    ld   e, (hl)
    inc  hl
    ld   d, (hl)                   ; DE = puntatore layout nuova stanza
    ld   (room_ptr), de

    ; 4. Prepara lo stato per l'ingresso nella nuova stanza
    xor  a
    ld   (transition_active), a    ; 0 = carica coordinate da OFFSET_POS_WILLY
    ld   (velocity_y), a
    ld   (game_objective_completed), a
    ld   a, 1
    ld   (on_ground), a

    ; 5. Pulisci lo schermo e avvia la nuova stanza
    ld   a, $07
    call Gfx_ClearScreenDirect

    jp   LoadRoomAndRestart

.all_rooms_completed:
    ; Tutte le stanze sono state completate con successo!
    IF ENABLE_VICTORY_SCREEN != 0
    jp   TriggerVictory
    ELSE
    ; Ricomincia dalla prima stanza (Stanza 00)
    ld   de, (RoomsListTable)
    ld   (room_ptr), de
    xor  a
    ld   (transition_active), a
    ld   (velocity_y), a
    ld   (game_objective_completed), a
    ld   a, 1
    ld   (on_ground), a
    ld   a, $07
    call Gfx_ClearScreenDirect
    jp   LoadRoomAndRestart
    ENDIF

; -------------------------------------------------------------------
; CheckAllItemsCollected
; Verifica che tutti gli item della stanza/gioco siano stati raccolti.
; Output: Carry = 1 se tutti raccolti, Carry = 0 altrimenti
; -------------------------------------------------------------------
CheckAllItemsCollected:
    ld   a, (game_objective_completed)
    or   a
    jr   nz, .all_collected
    ld   a, (num_room_items)
    or   a
    jr   z, .all_collected
    or   a
    ret
.all_collected:
    scf
    ret

; -------------------------------------------------------------------
; CheckInMasterBedroom (alias per retrocompatibilità)
; -------------------------------------------------------------------
CheckInMasterBedroom:
    scf
    ret

; -------------------------------------------------------------------
; CheckWillyConveyorCollision
; Verifica se Willy collide o si trova sul blocco Conveyor attivo nella stanza.
; Output: Carry = 1 se collide con conveyor, Carry = 0 altrimenti
; -------------------------------------------------------------------
CheckWillyConveyorCollision:
    push bc
    push de
    push hl

    ; 1. Se Willy è in piedi / cammina sul conveyor (check solido da fisica)
    call CheckWillyOnConveyor
    jr   c, .collision_detected

    ; 2. Controlla anche intersezione tra Bounding Box di Willy (16x16) e blocco Conveyor
    ld   a, (conveyor_len)
    or   a
    jr   z, .no_conv_collision ; Nessun conveyor presente

    ; B = WillyY, C = WillyX
    ld   bc, (PlayerPos)

    ; ConveyorTop = conveyor_row * 8, ConveyorBottom = ConveyorTop + 7
    ld   a, (conveyor_row)
    add  a, a                  ; *2
    add  a, a                  ; *4
    add  a, a                  ; *8
    ld   e, a                  ; E = ConveyorTop
    add  a, 7
    ld   d, a                  ; D = ConveyorBottom

    ; WillyTop = WillyY (B), WillyBottom = WillyY + 15
    ld   a, b                  ; WillyTop
    cp   d
    jr   z, .y_overlap
    jr   c, .y_overlap         ; WillyTop <= ConveyorBottom
    jr   .no_conv_collision

.y_overlap:
    add  a, 15                 ; WillyBottom
    cp   e
    jr   z, .x_check
    jr   nc, .x_check          ; WillyBottom >= ConveyorTop
    jr   .no_conv_collision

.x_check:
    ; ConveyorLeft = conveyor_col * 8
    ld   a, (conveyor_col)
    add  a, a                  ; *2
    add  a, a                  ; *4
    add  a, a                  ; *8
    ld   e, a                  ; E = ConveyorLeft

    ; ConveyorRight = (conveyor_col + conveyor_len) * 8 - 1
    ld   hl, conveyor_len
    ld   a, (conveyor_col)
    add  a, (hl)
    add  a, a                  ; *2
    add  a, a                  ; *4
    add  a, a                  ; *8
    dec  a                     ; ConveyorRight
    ld   d, a                  ; D = ConveyorRight

    ; WillyLeft = WillyX (C), WillyRight = WillyX + 15
    ld   a, c                  ; WillyLeft
    cp   d
    jr   z, .x_overlap
    jr   c, .x_overlap         ; WillyLeft <= ConveyorRight
    jr   .no_conv_collision

.x_overlap:
    add  a, 15                 ; WillyRight
    cp   e
    jr   z, .collision_detected
    jr   nc, .collision_detected ; WillyRight >= ConveyorLeft
    jr   .no_conv_collision

.collision_detected:
    pop  hl
    pop  de
    pop  bc
    scf
    ret

.no_conv_collision:
    pop  hl
    pop  de
    pop  bc
    or   a
    ret

; -------------------------------------------------------------------
; ResetFullGameState
; Ripristina tutti i dati ed i parametri allo stato iniziale
; per l'avvio di una nuova partita dopo il Game Over.
; -------------------------------------------------------------------
ResetFullGameState:
    ; Pulisce completamente lo schermo e ripristina gli attributi di default
    xor  a
    out  ($fe), a              ; Bordo a nero
    call Gfx_ClearScreenDirect ; Pulisce tutta la memoria pixel (6144B) e attributi (768B)

    ; Ripristina il numero di vite iniziali
    ld   a, INITIAL_LIVES
    ld   (willy_lives), a

    ; Azzeramento conteggio item raccolti e dello stato fisica/input
    xor  a
    ld   (items_collected), a
    ld   (body_state), a
    ld   (w_warp_state), a
    ld   (w_key_prev), a
    ld   (enter_key_prev), a
    ld   (velocity_y), a
    ld   (jump_pressed), a
    ld   (coyote_timer), a
    ld   (jump_frame), a
    ld   (jump_dir), a
    ld   (transition_active), a
    ld   (willy_safety_timer), a
    ld   a, $ff
    ld   (digit_key_prev), a
    ld   a, 1
    ld   (q_prev), a
    ld   (a_prev), a
    ld   (on_ground), a

    ; Azzeramento punteggio partita corrente (Score = 000000)
    ; Nota: High score viene mantenuto intatto tra le partite
    xor  a
    ld   (player_score + 0), a
    ld   (player_score + 1), a
    ld   (player_score + 2), a

    ; Ripristina tutti gli item in ItemsTable al valore 0 (non raccolti)
    call ResetItemsTable

    ; Inizializza la tabella dei punti di ingresso per tutte le stanze (0..60)
    call InitRoomEntryPositions

    ; Aggiorna la riga di stato con High score e Score azzerato
    call Gfx_UpdateScoreDisplay

    ; Ripristina la stanza iniziale (Central Cavern)
    ld   hl, CentralCavernLayout
    ld   (room_ptr), hl

    ret

  

    include "resources.asm"
    include "data/datavariable.asm"
    
    SAVESNA "manicminer.sna", start ; sna48-ok
