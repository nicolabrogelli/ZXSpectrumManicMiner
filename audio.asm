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
    ; Speaker ON (attiva bit 3 MIC e bit 4 EAR per volume ottimale)
    ld   a, (room_border_color)
    or   $18
    out  ($fe), a
    ld   c, d
.d1:
    dec  c
    jr   nz, .d1

    ; Speaker OFF
    ld   a, (room_border_color)
    and  $e7
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
; Gestisce la riproduzione della musica di sottofondo frame-by-frame
; fedele al motore audio originale di Matthew Smith (Manic Miner 1983).
; Brano: "In the Hall of the Mountain King" (Edvard Grieg).
;
; Nel gioco originale (routine a $883A / 34874):
; - Un loop di sintesi a 1-bit su porta $FE (768 passaggi, ~8.8 ms) viene
;   eseguito a intervalli regolari.
; - Ciascuna delle 64 note della melodia viene suonata per 2 burst consecutivi
;   (producendo il caratteristico ritmo staccato "ta-ta").
; - Con MUSIC_FRAME_DIVIDER = 2 a 25 FPS, un burst viene emesso ogni 80 ms,
;   riproducendo il tema completo di 64 note in 10.24 secondi, perfettamente
;   allineato ai ~11.5 secondi del gioco originale.
; -------------------------------------------------------------------
Audio_UpdateMusic:
    push af
    push bc
    push de
    push hl

    IF MUTE_MUSIC_ON_JUMP != 0
    ; Se abilitato, il salto silenzia temporaneamente la musica
    ld   a, (Audio_jump_sound_note)
    cp   18
    jr   c, .done
    ENDIF

    IF MUSIC_FRAME_DIVIDER > 1
    ; Divisore di frame per sincronizzare il tempo al frame rate di gioco
    ld   a, (Audio_music_frame_counter)
    dec  a
    ld   (Audio_music_frame_counter), a
    jr   nz, .done
    ld   a, MUSIC_FRAME_DIVIDER
    ld   (Audio_music_frame_counter), a
    ENDIF

    ; Avanza l'indice del burst e calcola la nota corrente (0..63)
    ; INC A; AND 126; RRCA; mantiene ciascuna nota attiva per 2 burst
    ld   a, (Audio_music_note_idx)
    inc  a
    ld   (Audio_music_note_idx), a
    and  126                      ; Maschera bit 7 e bit 0 (valori 0, 2, ..., 126)
    rrca                          ; Dividi per 2 -> indice nota 0..63
    ld   e, a
    ld   d, 0
    ld   hl, Audio_GameTune
    add  hl, de                   ; HL = puntatore al delay del semionda della nota

    ; Configura il colore del bordo corrente e lo stato iniziale dello speaker
    ld   a, (room_border_color)
    and  $07                      ; Mantiene solo i 3 bit del colore bordo (speaker OFF)
    ld   e, (hl)                  ; E = delay iniziale per il pitch counter
    ld   bc, 3                    ; B = 0 (256 cicli), C = 3 -> 768 iterazioni totali (~8.8 ms)

    ; Loop originale di generazione tono a 1 bit (routine 34898 / TM51)
.sound_loop:
    out  ($fe), a                 ; Emette lo stato corrente su porta $FE
    dec  e
    jr   nz, .no_flip
    ld   e, (hl)                  ; Ricarica il valore del semionda
    xor  $18                      ; Inverte bit 3 (MIC) e bit 4 (EAR/BEEPER)
.no_flip:
    djnz .sound_loop
    dec  c
    jr   nz, .sound_loop

    ; Spegni lo speaker assicurando che i bit 3 e 4 tornino a 0
    ld   a, (room_border_color)
    and  $07
    out  ($fe), a

.done:
    pop  hl
    pop  de
    pop  bc
    pop  af
    ret

; -------------------------------------------------------------------
; Tabella delle note dell'in-game tune: "In the Hall of the Mountain King"
; Dati originali Manic Miner (Bug-Byte Ltd, 1983 - memoria $858C / 34188).
; 64 note (1 byte per nota che rappresenta il delay del semionda).
; -------------------------------------------------------------------
Audio_GameTune:
    db 128, 114, 102,  96,  86, 102,  86,  86,  81,  96,  81,  81,  86, 102,  86,  86
    db 128, 114, 102,  96,  86, 102,  86,  86,  81,  96,  81,  81,  86,  86,  86,  86
    db 128, 114, 102,  96,  86, 102,  86,  86,  81,  96,  81,  81,  86, 102,  86,  86
    db 128, 114, 102,  96,  86, 102,  86,  64,  86, 102, 128, 102,  86,  86,  86,  86
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
    or   $18               ; speaker ON (EAR + MIC)
    out  ($fe), a

    ld   c, 60
.d1:
    dec  c
    jr   nz, .d1

    ld   a, (room_border_color)
    and  $e7              ; speaker OFF
    out  ($fe), a

    ld   c, 60
.d2:
    dec  c
    jr   nz, .d2

    djnz .sound_loop

    pop  de
    pop  bc
    ret
