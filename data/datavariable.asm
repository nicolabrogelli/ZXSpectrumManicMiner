; -------------------------------------------------------------------
; Variabili
; -------------------------------------------------------------------
; Posizioni
PlayerPos:      db 136, 128 ;136, 100
PlayerPosOld:   db 136, 128 ;136, 100
bodyPos:        dw $1111

; Stato player
body_state:     db $00
direction:      db $00
flags:          db $00

collision_active: db $00
items_collected:  db $00  ; Numero di items raccolti durante il gioco (incrementato alla raccolta)
sprite_shift:     db $00
room_border_color: db $00
willy_lives:                   db 7   ; Numero iniziale di vite di Willy (7)

; Fisica
velocity_y:     db $00
on_ground:      db $01
jump_pressed:   db $00
jump_prev:      db $00
coyote_timer:   db $00
jump_start_y:   db $00
jump_dir:       db $00
jump_frame:     db $00
current_input_dir: db $00
q_prev:         db $01
a_prev:         db $01
w_warp_state:   db $00
w_warp_d1:      db $00
w_warp_d2:      db $00
w_key_prev:     db $00
enter_key_prev: db $00
digit_key_prev: db $ff
room_jump_strength:  db DEFAULT_JUMP_STRENGTH
room_gravity_preset: db DEFAULT_GRAVITY_PRESET

; Buffer e contatori
counter:        dw 0
last_music_counter_low: db 0
last_frame_counter: dw 0
line_buffer:    .256 db 0
unpacked_layout: .512 db 0

; Gestione Stanze
current_room:   db 0
conveyor_dir:   db 0
conveyor_len:   db 0
conveyor_row:   db 0
conveyor_col:   db 0
ramp_dir:       db 0
ramp_len:       db 0
ramp_row:       db 0
ramp_col:       db 0
current_room_items: .80 db 0
num_room_items:     db 0
room_ptr:           dw CentralCavernLayout
enemy_update_rate:  db GUARDIAN_UPDATE_RATE
enemy_update_timer: db 0
player_speed:       db WILLY_WALK_SPEED
player_air_speed:   db 2
transition_active:  db 0
room_entry_positions: .122 db 0 ; Tabella posizioni di ingresso per tutte le stanze (61 stanze * 2 byte: X, Y)
ramp_entry_guard:  db 0   ; Guardia aggancio rampa dopo ingresso orizzontale
ramp_entry_guard_x: db 0  ; X oltre il quale la guardia viene rimossa
ramp_entry_guard_dir: db 0 ; 1=ingresso da sinistra, 2=ingresso da destra
room_change_grounded: db 0 ; on_ground al momento del cambio stanza (per l'aggancio rampa)
player_drawn_pos:      db $ff, $ff
player_old_dir:        db $ff
player_old_body:       db $ff
enemy_was_updated:     db 1
willy_safety_timer:    db 0
willy_needs_redraw:    db 0
willy_on_ramp:         db 0 ; 1 = Willy posizionato su rampa (debug)

; Gestione Pavimenti Sgretolabili (Crumbling Floor)
crumbling_grid:         .512 db 0 ; Griglia 16x32 stadi di sgretolamento (0 = intatto, 1..8 = stadi)
crumbling_active_count: db 0      ; Numero di blocchi attualmente in fase di sgretolamento
crumbling_anim_timer:   db 0      ; Timer per scandire la velocità di animazione dello sgretolamento

; Gestione Punteggio (Score & High score - 3 byte BCD ciascuno: 6 cifre decimali)
player_score:               db 0, 0, 0 ; Punteggio partita corrente (inizia a 000000)
high_score:                 db 0, 0, 0 ; Punteggio record (mantenuto tra le partite)
game_objective_completed:   db 0       ; 1 = Obiettivo completato (portale attivo), 0 = Non completato
portal_anim_timer:          db 0       ; Timer velocità lampeggio portale attivo
portal_anim_frame:          db 0       ; Frame ciclo colori portale attivo (0..7)
portal_static_color:        db 0       ; Attributo colore originale del portale statico

Audio_jump_sound_note:    db 18   ; 18 = inactive (0..17 are active notes)
Audio_jump_sound_timer:   db 0
    IF ENABLE_MUSIC != 0
Audio_music_note_idx:      db 0
Audio_music_frame_counter: db 1
    ENDIF

; Gestione Barra dell'Aria (AIR bar - Riga 17)
air_pixels:             db 224     ; Quantità aria rimanente in pixel (28 colonne * 8 = 224 pixel)
air_timer:              db 0       ; Timer frame per il consumo progressivo dell'aria
air_deplete_rate:       db 8       ; Frame per decremento di 1 pixel di aria


