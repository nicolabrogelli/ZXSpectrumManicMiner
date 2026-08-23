;===========================================================================
; settings.asm
;
; Impostazioni e flag di configurazione a tempo di compilazione per Jet Set Willy.
; Ogni flag può essere abilitato (1) o disabilitato (0).
; Possono anche essere sovrascritti via riga di comando con sjasmplus 
; (es. -DENABLE_MUSIC=0 -DENABLE_ROOM_SKIP_KEYS=0).
;===========================================================================

; --- Effetti di sottofondo ---
; 1 = Effetti abilitati
; 0 = Effetti disabilitati
    IFNDEF ENABLE_EFFECTS
ENABLE_EFFECTS EQU 0
    ENDIF

; --- Musica di sottofondo ---
; 1 = Musica abilitata
; 0 = Musica disabilitata
    IFNDEF ENABLE_MUSIC
ENABLE_MUSIC EQU 0
    ENDIF

; --- Morte per collisione con i guardiani (nemici) ---
; 1 = Abilita la morte e il decremento delle vite alla collisione con i guardiani
; 0 = Disabilita la morte
    IFNDEF ENABLE_GUARDIAN_COLLISION_DEATH
ENABLE_GUARDIAN_COLLISION_DEATH EQU 1
    ENDIF

; --- Bande colorate di debug per collisione con i guardiani ---
; 1 = Abilita le bande colorate (raster bar) sul bordo alla collisione con i guardiani (quando la morte è disabilitata)
; 0 = Disabilita le bande colorate di debug per i guardiani
    IFNDEF ENABLE_GUARDIAN_DEBUG_BARS
ENABLE_GUARDIAN_DEBUG_BARS EQU 1
    ENDIF

; --- Morte per collisione con gli elementi Nasty (tiles pericolose) ---
; 1 = Abilita la morte e il decremento delle vite al tocco delle Nasty tiles
; 0 = Disabilita il controllo di morte sulle Nasty tiles
    IFNDEF ENABLE_NASTY_COLLISION_DEATH
ENABLE_NASTY_COLLISION_DEATH EQU 1
    ENDIF

; --- Animazione delle icone delle vite ---
; 1 = Abilita l'animazione camminante per le icone delle vite in basso a schermo
; 0 = Icone delle vite statiche
    IFNDEF ENABLE_ANIMATE_LIVES
ENABLE_ANIMATE_LIVES EQU 0
    ENDIF

; --- Tasti di navigazione rapida tra le stanze (Q / A) ---
; 1 = Abilita i tasti Q (stanza successiva) e A (stanza precedente) per scorrere tra le stanze
; 0 = Disabilita i tasti Q e A
    IFNDEF ENABLE_ROOM_SKIP_KEYS
ENABLE_ROOM_SKIP_KEYS EQU 1
    ENDIF

; --- Bande colorate di debug per Willy su rampa ---
; 1 = Abilita le bande colorate (raster bar) sul bordo quando Willy si trova posizionato su una rampa
; 0 = Disabilita le bande colorate di debug per le rampe
    IFNDEF ENABLE_RAMP_DEBUG_BARS
ENABLE_RAMP_DEBUG_BARS EQU 0
    ENDIF


; --- Riavvio del gioco al Game Over quando Willy esaurisce tutte le vite ---
; 1 = Abilita la schermata di Game Over e il riavvio completo dal primo livello quando le vite finiscono
; 0 = Disabilita il riavvio (Willy respawna normalmente mantenendo 1 vita senza azzerare la partita)
    IFNDEF ENABLE_GAME_OVER_RESTART
ENABLE_GAME_OVER_RESTART EQU 1
    ENDIF

; --- Velocità dell'orologio di gioco (Test rapido) ---
; 1 = Modalità Test rapido (1 secondo reale = 1 minuto di gioco, 50 tick IM2 a 50Hz)
; 0 = Modalità Normale (40 secondi reali = 1 minuto di gioco, 2000 tick IM2 a 50Hz)
    IFNDEF ENABLE_FAST_CLOCK_TEST
ENABLE_FAST_CLOCK_TEST EQU 0
    ENDIF

    IF ENABLE_FAST_CLOCK_TEST != 0
CLOCK_TICKS_PER_MINUTE EQU 50    ; Test rapido: 1 secondo reale = 1 minuto di gioco
    ELSE
CLOCK_TICKS_PER_MINUTE EQU 2000  ; Normale: 40 secondi reali = 1 minuto di gioco
    ENDIF

; --- Sprite Vecchia (Maria) nella Master Bedroom ---
; 1 = Mostra lo sprite della Vecchia nella stanza Master Bedroom (comportamento originale)
; 0 = Non far comparire lo sprite della Vecchia nella Master Bedroom
;    IFNDEF ENABLE_MASTER_BEDROOM_VECCHIA
;ENABLE_MASTER_BEDROOM_VECCHIA EQU 1
;    ENDIF

; --- Schermata di vittoria al completamento del gioco ---
; 1 = Abilita la schermata di vittoria quando Willy raccoglie tutti gli item ed entra nel letto (conveyor) in Master Bedroom
; 0 = Disabilita la schermata di vittoria
    IFNDEF ENABLE_VICTORY_SCREEN
ENABLE_VICTORY_SCREEN EQU 1
    ENDIF



