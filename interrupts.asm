;===========================================================================
; interrupts.asm
;===========================================================================

; -------------------------------------------------------------------
; Setup interrupt IM2
; -------------------------------------------------------------------
SetupIM2:
    di
    ld de,IM2_TABLE
    ld hl,IM2_VECTOR
    ld a,d
    ld i,a
    ld a,l
.fill_loop:
    ld (de),a
    inc e
    jp nz,.fill_loop
    inc d
    ld (de),a
    ld (hl),$C3
    inc l
    ld (hl),low im2_handler
    inc l
    ld (hl),high im2_handler
    im 2
    ei
    ret

; -------------------------------------------------------------------
; Handler interrupt IM2
; -------------------------------------------------------------------
im2_handler:
    push af
    push hl

    ; Reset interrupt ULA
    in a, (0xFE)

    ; Incrementa il contatore (usato per animazioni/raster bars)
    ld hl, (counter)
    inc hl
    ld (counter), hl

    ; Ripristina registri
    pop hl
    pop af
    ei
    reti