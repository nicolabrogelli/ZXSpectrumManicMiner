;===========================================================================
; physics_config.asm
;
; Configurazioni globali per la fisica del salto e del movimento in Jet Set Willy.
; Tutti i parametri di default della fisica possono essere personalizzati qui.
; Possono anche essere sovrascritti via riga di comando con sjasmplus
; (es. -DDEFAULT_JUMP_STRENGTH=5 -DDEFAULT_GRAVITY_PRESET=1).
;===========================================================================

; --- Forza del Salto di Default (Altezza iniziale) ---
; Definisce l'impulso verticale iniziale per il salto quando la stanza non specifica un valore personalizzato.
; Valori tipici:
;   6 = Salto standard (Jet Set Willy originale)
;   5 = Salto medio/corto
;   4 = Salto corto
    IFNDEF DEFAULT_JUMP_STRENGTH
DEFAULT_JUMP_STRENGTH EQU 6
    ENDIF

; Alias per compatibilità con il codice esistente
JUMP_STRENGTH: EQU DEFAULT_JUMP_STRENGTH

; --- Preset Gravità di Default ---
; Definisce il comportamento della gravità per le stanze che non hanno un valore personalizzato.
; Presets:
;   0 = Gravità 0.5 (leggera)
;   1 = Gravità 0.75 (standard JSW)
;   2 = Gravità 1.0 (pesante)
;   3 = Gravità 0.25 (molto leggera)
;   4 = Gravità 0.0 (nessuna gravità)
    IFNDEF DEFAULT_GRAVITY_PRESET
DEFAULT_GRAVITY_PRESET EQU 1
    ENDIF

; --- Velocità Massima di Caduta ---
; Limite massimo per la velocità di caduta verso il basso (in pixel/frame)
    IFNDEF MAX_FALL_SPEED
MAX_FALL_SPEED EQU 12
    ENDIF

; --- Gravità Base ---
    IFNDEF GRAVITY
GRAVITY EQU 1
    ENDIF

; --- Tolleranza Hitbox Collisioni Guardiani (Inset Margins) ---
; Definisce il margine di rientro in pixel per escludere i bordi trasparenti degli sprite.
;   0 = Hitbox rigida originale 8x16 vs 16x16
;   1 = Tolleranza leggera (1px per lato)
;   2 = Tolleranza consigliata (2px per lato, evita morte su bordi vuoti)
    IFNDEF COLLISION_INSET_X
COLLISION_INSET_X EQU 2
    ENDIF

    IFNDEF COLLISION_INSET_Y
COLLISION_INSET_Y EQU 2
    ENDIF

COLLISION_OFFSET_X:    EQU (7 - (2 * COLLISION_INSET_X))
COLLISION_THRESHOLD_X: EQU (23 - (4 * COLLISION_INSET_X))

COLLISION_OFFSET_Y:    EQU (15 - (2 * COLLISION_INSET_Y))
COLLISION_THRESHOLD_Y: EQU (31 - (4 * COLLISION_INSET_Y))

; --- Tempo di Sicurezza (Invulnerabilità) al Respawn dopo la Morte ---
; Numero di frame (50Hz) di invulnerabilità ai guardiani dopo il respawn di Willy.
;   0  = Disabilitato (nessuna sicurezza)
;  50  = 1 secondo di invulnerabilità (default consigliato)
;  75  = 1.5 secondi
; 100  = 2 secondi
    IFNDEF RESPAWN_SAFETY_TIME
RESPAWN_SAFETY_TIME EQU 0
    ENDIF

; --- Coyote Time (Tempo Coyote per Salto da Bordo) ---
; Numero di frame nei quali Willy può ancora saltare dopo essere scivolato oltre il bordo di una piattaforma.
    IFNDEF COYOTE_TIME_FRAMES
COYOTE_TIME_FRAMES EQU 4
    ENDIF

; --- Buffer Pre-Salto (Jump Buffer) ---
; Numero di frame nei quali l'input del salto (tasto Z) viene conservato
; se premuto poco prima di toccare terra (evita il tasto "sordo").
    IFNDEF JUMP_BUFFER_FRAMES
JUMP_BUFFER_FRAMES EQU 5
    ENDIF



