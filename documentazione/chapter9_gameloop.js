function addChapter9(doc) {
    doc.addPage("9. GAME LOOP, SINCRONIZZAZIONE E GESTIONE INPUT");
    doc.addSectionHeader("9", "GAME LOOP, SINCRONIZZAZIONE E GESTIONE INPUT");

    doc.addHeading2("9.1 Ciclo Principale di Gioco (Main_loop) e Sequenza Rigorosa delle Fasi");
    doc.addParagraph("Il ciclo principale di gioco (Main_loop in manicminer.asm) orchestra l'intero funzionamento del programma con una sequenza temporale rigorosa e deterministica a 25 frame al secondo:");

    const loopStepsHeaders = ["Fase", "Modulo / Funzione Chiamata", "Operazioni Eseguite e Obiettivo"];
    const loopStepsWidths = [45, 140, 325];
    const loopStepsRows = [
        ["1", ".sync_loop (HALT)", "Attende il vertical blank hardware della ULA a 50Hz. Modula la velocita tramite GAME_SPEED_DELAY (2 interrupt = 25 FPS)."],
        ["2", "willy_safety_timer", "Decrementa il timer di sicurezza (invulnerabilita post-respawn) se > 0."],
        ["3", "Enemy_RenderRoom", "Passata atomica: cancella vecchi nemici, controlla sovrapposizioni con Willy (willy_needs_redraw) e disegna nuovi nemici."],
        ["4", "Gfx_UpdatePlayer", "Cancella e ridisegna Willy in primo piano se mosso o se coperto da un guardiano."],
        ["5", "Gfx_AnimatePortal", "Se tutti gli item sono raccolti, fa lampeggiare ciclicamente l'attributo del portale."],
        ["6", "Phys_UpdateAir", "Decrementa la riserva d'aria in base ad air_deplete_rate; se l'aria e' a 0, salta a .willy_dies."],
        ["7", "Audio_UpdateJumpSound", "Esegue l'effetto sonoro del salto frame-by-frame se attivo (suono modulato a 18 note)."],
        ["8", "Audio_UpdateMusic", "Aggiorna la musica di sottofondo a 1-bit (\"In the Hall of the Mountain King\") se abilitata."],
        ["9", "Gfx_PrintWillyLives", "Aggiorna l'animazione camminante delle icone delle vite in basso a schermo."],
        ["10", "Salvataggio PlayerPosOld", "Copia PlayerPos in PlayerPosOld per preparare la cancellazione al frame successivo."],
        ["11", "Input_CheckCtrl", "Scansiona le porte I/O della tastiera ($DF, $FE, $FB, $FD), popola registro D e applica i filtri."],
        ["12", "MovePlayer", "Calcola lo spostamento orizzontale di Willy, gestisce collisioni muri e cattura nastro."],
        ["13", "Phys_ApplyGravity", "Applica la gravita frazionaria, salto, atterraggio, rampe e crumbling floors; controlla caduta fatale."],
        ["14", "Enemy_Update", "Aggiorna le posizioni e i frame dei guardiani orizzontali, verticali, Eugene e Kong."],
        ["15", "Items_CheckCollision", "Verifica raccolta chiavi, assegna 100 punti BCD, emette beep e anima i colori degli item."],
        ["16", "CheckPortalTransition", "Verifica se Willy entra nel portale attivo -> Scatena Air_DepleteCountdown e cambio caverna."]
    ];
    doc.addTable(loopStepsHeaders, loopStepsRows, loopStepsWidths, 7.0);

    doc.addHeading2("9.2 Sincronizzazione Hardware Vertical Blank via Interrupt IM2 a 50Hz");
    doc.addParagraph("Per garantire un frame rate costante e privo di tearing video, il gioco sfrutta la modalita di interrupt vettorizzato IM 2 dello Z80:");
    doc.addBullet("Inizializzazione IM2 (SetupIM2)", "Carica il registro I con $FE; riempie la tabella da 257 byte ($FE00..$FEFF) con il byte $FD; scrive all'indirizzo $FDFD un'istruzione di salto assoluto jp im2_handler (opcode $C3 seguito dall'indirizzo dell'handler); attiva IM 2 ed abilita gli interrupt con EI.");
    doc.addBullet("Handler Interrupt (im2_handler)", "Eseguito esattamente ogni 20 millisecondi (50 volte al secondo) dal segnale di sincronismo verticale della ULA. Incrementa la variabile a 16 bit counter, legge la porta $FE per resettare la linea di interrupt e ritorna con RETI.");

    doc.addHeading2("9.3 Scansione della Tastiera, Matrice delle Porte I/O Spectrum");
    doc.addParagraph("L'input viene letto direttamente scansionando le linee della matrice di commutazione tastiera dello Spectrum (routine Input_CheckCtrl in input.asm):");

    const ioHeaders = ["Porta Hardware", "Linee / Bit", "Tasti Associati", "Funzione nel Gioco"];
    const ioWidths = [90, 80, 110, 230];
    const ioRows = [
        ["IN A, ($DF)", "Bit 0 (P), Bit 1 (O)", "P = Destra, O = Sinistra", "Movimento orizzontale di Miner Willy a terra e in salto."],
        ["IN A, ($FE)", "Bit 1 (Z), Bit 0 (Space)", "Z / Space = Salto", "Attivazione salto parabolico (imposta bit 2 del registro D)."],
        ["IN A, ($FB)", "Bit 0 (Q), Bit 1 (W)", "Q = Stanza Avanti, W = Warp", "Cambio stanza immediato (debug/cheat) e selezione numerica caverna."],
        ["IN A, ($FD)", "Bit 0 (A)", "A = Stanza Indietro", "Cambio stanza retroattivo alla caverna precedente."],
        ["IN A, ($BF)", "Bit 0 (ENTER)", "ENTER = Avvia / Conferma", "Avvio partita da Title Screen e conferma selezioni."]
    ];
    doc.addTable(ioHeaders, ioRows, ioWidths, 7.1);

    doc.addHeading2("9.4 Coyote Time, Jump Buffer e Gestione Debounce per Controlli Fluidi");
    doc.addParagraph("Per eliminare la rigidita frustrante tipica dei giochi a 8 bit e garantire un'esperienza di controllo moderna e reattiva, sono state introdotte tre tecniche evolute:");
    doc.addBullet("1. Jump Buffer (JUMP_BUFFER_FRAMES = 5)", "Se il giocatore preme il tasto di salto (Z) fino a 5 frame prima di toccare terra, jump_pressed conserva l'input ed esegue il salto istantaneamente nel momento esatto dell'atterraggio, eliminando i tasti 'sordi'.");
    doc.addBullet("2. Coyote Time (COYOTE_TIME_FRAMES = 4)", "Quando Willy cammina oltre il bordo di una piattaforma cadendo nel vuoto, coyote_timer gli concede una finestra di tolleranza di 4 frame (80ms) durante la quale puo ancora spiccare il salto come se si trovasse a terra.");
    doc.addBullet("3. Debounce Hardware (jump_prev, q_prev, a_prev)", "I tasti speciali e il salto implementano edge detection: l'azione scatta solo sul fronte di salita della pressione e non si ripete finché il tasto non viene rilasciato.");
}

module.exports = { addChapter9 };
