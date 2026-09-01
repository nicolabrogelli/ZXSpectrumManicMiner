function addChapter11(doc) {
    doc.addPage("11. PORZIONI DI CODICE SIGNIFICATIVE COMMENTATE");
    doc.addSectionHeader("11", "PORZIONI DI CODICE SIGNIFICATIVE COMMENTATE");

    doc.addHeading2("11.1 Il Game Loop Principale (manicminer.asm: Main_loop)");
    doc.addParagraph("Il ciclo principale di gioco sincronizzato a 25 FPS che scandisce tutte le fasi operative:");

    doc.addCodeBlock([
        "Main_loop:",
        ".sync_loop:",
        "    halt                   ; Attende interrupt VBLANK della ULA a 50Hz",
        "    ld   hl, (counter)     ; HL = contatore interrupt a 16 bit",
        "    ld   de, (last_frame_counter)",
        "    or   a",
        "    sbc  hl, de            ; Calcola quanti tick sono trascorsi",
        "    ld   a, l",
        "    cp   GAME_SPEED_DELAY  ; 2 tick (50Hz / 2 = 25 FPS)",
        "    jr   c, .sync_loop     ; Se non sono ancora passati 2 tick, attendi",
        "    ld   hl, (counter)",
        "    ld   (last_frame_counter), hl",
        "",
        "    ; 1. Rendering atomico nemici ed estrazione sovrapposizioni",
        "    call Enemy_RenderRoom",
        "    ; 2. Rendering del giocatore (overlay in primo piano)",
        "    call Gfx_UpdatePlayer",
        "    ; 3. Aggiorna animazione lampeggio portale",
        "    call Gfx_AnimatePortal",
        "    ; 4. Aggiorna consumo aria (morte se esaurita)",
        "    call Phys_UpdateAir",
        "    jp   c, .willy_dies",
        "    ; 5. Aggiorna audio salto e musica",
        "    call Audio_UpdateJumpSound",
        "    ; 6. Aggiorna fisica, controlli, gravita e collisioni",
        "    call Input_CheckCtrl",
        "    call MovePlayer",
        "    call Phys_ApplyGravity",
        "    jp   c, .willy_dies    ; Caduta fatale",
        "    call Enemy_Update",
        "    call Items_CheckCollision",
        "    call Items_Animate",
        "    call CheckCollision    ; Collisione pixel-perfect con guardiani",
        "    jp   c, .willy_dies",
        "    jp   Main_loop"
    ], "manicminer.asm - Main_loop");

    doc.addHeading2("11.2 Movimento del Giocatore e Cattura del Conveyor (player.asm: MovePlayer)");
    doc.addParagraph("Gestione del movimento a terra, in aria e logica di cattura forzata sui nastri trasportatori:");

    doc.addCodeBlock([
        "MovePlayer:",
        "    ld   a, (on_ground)",
        "    or   a",
        "    jr   nz, .on_ground_check",
        "    ; IN ARIA: Direzione vincolata a jump_dir, input ignorato",
        "    xor  a : ld (conveyor_caught), a",
        "    ld   a, (jump_dir)",
        "    or   a : ret z         ; Salto verticale -> nessun movimento X",
        "    ld   bc, (PlayerPos)",
        "    cp   1 : jp z, movePlayer_left",
        "    cp   2 : jp z, movePlayer_right",
        "    ret",
        "",
        ".on_ground_check:",
        "    call CheckWillyOnConveyor",
        "    jr   c, .on_conveyor_ground",
        "    ; Terreno normale: leggi input D",
        "    xor  a : ld (conveyor_caught), a",
        "    bit  $01, d : jp nz, movePlayer_right",
        "    bit  $00, d : ret z",
        "    jp   movePlayer_left",
        "",
        ".on_conveyor_ground:",
        "    ; NASTRO TRASPORTATORE: se rilascia il tasto opposto -> catturato!",
        "    ld   a, (conveyor_dir)",
        "    or   a : jr nz, .conv_is_right",
        "    bit  $01, d            ; Nastro a SX: premuto Destra?",
        "    jr   nz, .check_oppose_right",
        "    ld   a, 1 : ld (conveyor_caught), a ; Catturato!",
        "    jp   movePlayer_left   ; Trascinato a Sinistra"
    ], "player.asm - MovePlayer");

    doc.addHeading2("11.3 Collision Detection Pixel-Perfect Bit-a-Bit (enemy.asm: CheckCollision)");
    doc.addParagraph("L'algoritmo di confronto delle scanline sovrapposte tra Willy e i guardiani:");

    doc.addCodeBlock([
        ".scanline_loop:",
        "    push bc",
        "    ; 1. Leggi i 2 byte della scanline corrente del guardiano",
        "    ld   a, (row_enemy_cur) : add a, a : ld e, a : ld d, 0",
        "    ld   hl, (guard_sprite_ptr) : add hl, de",
        "    ld   d, (hl) : inc hl : ld e, (hl) ; D=Byte0, E=Byte1",
        "    ; 2. Allinea a 16 bit la fetta di pixel in base a DeltaX",
        "    ld   a, (collision_delta_x)",
        "    bit  7, a : jr nz, .shift_neg_dx",
        "    or   a : jr z, .slice_ready_in_d",
        "    ld   c, a",
        ".shift_left_16bit:",
        "    sla  e : rl   d        ; Shift combinato a 16 bit!",
        "    dec  c : jr nz, .shift_left_16bit",
        ".slice_ready_in_d:",
        "    ld   a, d              ; A = Fetta guardiano allineata a Willy",
        "    ; 3. Leggi il byte corrispondente dello sprite di Willy",
        "    ld   c, a",
        "    ld   a, (row_willy_cur) ; Leggi testa (0..7) o corpo (8..15)",
        "    ... (lettura byte Willy in A) ...",
        "    ; 4. TEST BIT A BIT: AND Logico tra pixel Willy e pixel Nemico!",
        "    and  c",
        "    jr   nz, .pixel_collision_detected ; Se != 0 -> COLLISIONE FISICA!",
        "    pop  bc : dec b : jp nz, .scanline_loop"
    ], "enemy.asm - CheckCollision");

    doc.addHeading2("11.4 Aritmetica BCD per lo Scoring (items.asm: Score_AddItemPoints)");
    doc.addParagraph("Incremento decimale a 6 cifre senza costose conversioni binario-decimale:");

    doc.addCodeBlock([
        "Score_AddItemPoints:",
        "    ; Incrementa di 100 punti (Byte 1 = centinaia/migliaia)",
        "    ld   a, (player_score + 1)",
        "    add  a, $01",
        "    daa                    ; Decimal Adjust Accumulator hardware!",
        "    ld   (player_score + 1), a",
        "    ; Propagazione eventuale riporto al Byte 2 (decine/centinaia di migliaia)",
        "    ld   a, (player_score + 2)",
        "    adc  a, 0",
        "    daa                    ; Decimal Adjust per il riporto!",
        "    ld   (player_score + 2), a",
        "    call Score_CheckAndUpdateHighScore",
        "    call Gfx_UpdateScoreDisplay",
        "    ret"
    ], "items.asm - Score_AddItemPoints");
}

module.exports = { addChapter11 };
