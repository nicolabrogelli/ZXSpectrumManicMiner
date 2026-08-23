;===========================================================================
; audio.asm
;
; Gestione degli effetti sonori e della musica di sottofondo per il beeper.
;===========================================================================

; -------------------------------------------------------------------
; Audio_UpdateJumpSound
;
; Gestisce la riproduzione dell'effetto sonoro del salto frame-by-frame.
; Viene chiamata una volta per frame nel ciclo principale.
; -------------------------------------------------------------------
Audio_UpdateJumpSound:
    push af
    push bc
    push de
    push hl

    ; Controlla se il suono è attivo (note < 18)
    ld   a, (Audio_jump_sound_note)
    cp   18                        ; Ci sono 18 note (0..17)
    jr   nc, .done                 ; Se >= 18, non stiamo riproducendo

    ; Carica la nota corrente da suonare
    ld   e, a
    ld   d, 0
    ld   hl, Audio_JumpSoundDelays
    add  hl, de
    ld   a, (hl)                   ; A = delay della nota corrente
    ld   d, a                      ; D = delay della nota

    ; Suona la nota: 15 cicli
    ld   b, 15
.note_loop:
    ; Speaker ON
    ld   a, (room_border_color)
    or   $10
    out  ($fe), a
    ld   c, d
.d1:
    dec  c
    jr   nz, .d1

    ; Speaker OFF
    ld   a, (room_border_color)
    and  $ef
    out  ($fe), a
    ld   c, d
.d2:
    dec  c
    jr   nz, .d2

    djnz .note_loop

    ; Passa alla nota successiva
    ld   a, (Audio_jump_sound_note)
    inc  a
    ld   (Audio_jump_sound_note), a

.done:
    pop  hl
    pop  de
    pop  bc
    pop  af
    ret

Audio_JumpSoundDelays:
    db 51, 45, 38, 32, 25, 19, 12, 6, 12, 19, 25, 32, 38, 45, 51, 58, 64, 71

    IF ENABLE_MUSIC != 0
; -------------------------------------------------------------------
; Audio_UpdateMusic
;
; Gestisce la riproduzione della musica di sottofondo frame-by-frame.
; Viene chiamata a ogni frame.
; -------------------------------------------------------------------
Audio_UpdateMusic:
    push af
    push bc
    push de
    push hl

    ; Se il salto sta riproducendo un effetto sonoro, non suonare la musica
    ld   a, (Audio_jump_sound_note)
    cp   18
    jr   c, .done                 ; Salto attivo -> niente musica

    ; Decrementa il contatore dei frame della nota corrente
    ld   a, (Audio_music_frame_counter)
    dec  a
    ld   (Audio_music_frame_counter), a
    jr   nz, .play_current_note   ; Se non è zero, continua a suonare

    ; Altrimenti carica la nota successiva
    ld   a, (Audio_music_note_idx)
    inc  a
    cp   35                       ; Abbiamo 35 note in totale
    jr   c, .no_wrap
    xor  a                        ; Torna a 0 se raggiunge la fine (loop)
.no_wrap:
    ld   (Audio_music_note_idx), a

    ; Carica la durata e impostala come nuovo contatore di frame
    ld   e, a
    ld   d, 0
    ld   hl, Audio_MusicSheet
    add  hl, de
    add  hl, de                   ; Ogni nota prende 2 byte (delay, duration)
    
    ; Leggi durata (secondo byte)
    inc  hl
    ld   a, (hl)
    srl  a                        ; Divide per 2 (velocizza 2x, quattro volte più lento rispetto all'inizio)
    jr   nz, .dur_ok
    ld   a, 1
.dur_ok:
    ld   (Audio_music_frame_counter), a

.play_current_note:
    ; Ottieni il delay della nota corrente (primo byte)
    ld   a, (Audio_music_note_idx)
    ld   e, a
    ld   d, 0
    ld   hl, Audio_MusicSheet
    add  hl, de
    add  hl, de                   ; hl punta al primo byte della nota
    ld   a, (hl)                  ; A = delay
    or   a
    jr   z, .done                 ; Se delay è 0, è una pausa (Rest)

    ; Suona la nota: 2 cicli
    ld   d, a                     ; D = delay
    ld   b, 2                     ; 2 cicli per frame
.note_loop:
    ; Speaker ON
    ld   a, (room_border_color)
    or   $10
    out  ($fe), a
    ld   c, d
.d1:
    push af
    pop  af
    dec  c
    jr   nz, .d1

    ; Speaker OFF
    ld   a, (room_border_color)
    and  $ef
    out  ($fe), a
    ld   c, d
.d2:
    push af
    pop  af
    dec  c
    jr   nz, .d2

    djnz .note_loop

.done:
    pop  hl
    pop  de
    pop  bc
    pop  af
    ret

Audio_MusicSheet:
    ; Formato: db delay, durata (in frame a 50Hz)
    db 96, 5, 101, 15, 96, 5, 107, 25, 152, 5, 143, 35, 107, 15, 96, 10
    db 107, 10, 96, 10, 107, 25, 96, 10, 85, 10, 81, 10, 85, 5, 81, 10
    db 85, 10, 96, 70, 72, 40, 81, 10, 76, 5, 85, 20, 96, 10, 107, 25
    db 90, 20, 114, 5, 107, 10, 90, 10, 96, 10, 107, 10, 96, 10, 85, 5
    db 90, 10, 107, 20, 68, 65
    ELSE
Audio_UpdateMusic:
    ret
    ENDIF

; -------------------------------------------------------------------
; Audio_PlayCollectSound
;
; Genera un breve effetto sonoro (beep) tramite il buzzer
; dello ZX Spectrum utilizzando il port $FE quando viene raccolto un oggetto.
; -------------------------------------------------------------------
Audio_PlayCollectSound:
    push bc
    push de

    ld   b, 120
.sound_loop:
    ld   a, (room_border_color)
    or   $10               ; speaker ON
    out  ($fe), a

    ld   c, 60
.d1:
    dec  c
    jr   nz, .d1

    ld   a, (room_border_color)
    and  $ef              ; speaker OFF
    out  ($fe), a

    ld   c, 60
.d2:
    dec  c
    jr   nz, .d2

    djnz .sound_loop

    pop  de
    pop  bc
    ret
