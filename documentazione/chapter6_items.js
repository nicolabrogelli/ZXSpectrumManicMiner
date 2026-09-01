function addChapter6(doc) {
    doc.addPage("6. OGGETTI, PUNTEGGIO E MECCANICHE DI GAMEPLAY");
    doc.addSectionHeader("6", "OGGETTI, PUNTEGGIO E MECCANICHE DI GAMEPLAY");

    doc.addHeading2("6.1 Struttura e Caricamento degli Oggetti della Caverna");
    doc.addParagraph("Gli oggetti collezionabili (chiavi e tesori) sono definiti all'interno della struttura della caverna a partire dall'offset OFFSET_ITEMS (629). Ciascuna stanza puo contenere fino a 5 oggetti. Ogni record oggetto occupa 5 byte:");

    const itemStructHeaders = ["Byte", "Campo", "Descrizione", "Esempio Valore"];
    const itemStructWidths = [45, 110, 240, 120];
    const itemStructRows = [
        ["+0", "Color Attribute", "Attributo colore iniziale ZX Spectrum (Paper, Ink, Bright)", "3 (Magenta su nero)"],
        ["+1", "Attr Address Low", "Byte basso dell'indirizzo video attributi (23552 + Row*32 + Col)", "$89 (per Col 9, Row 0)"],
        ["+2", "Attr Address High", "Byte alto dell'indirizzo video attributi ($58..$5A)", "$5C (23552 + offset)"],
        ["+3", "Anim Mask", "Maschera per la rotazione cromatica ciclica", "96 ($60)"],
        ["+4", "Collected Flag", "$FF = attivo / non raccolto, 0 = raccolto", "$FF (Iniziale)"]
    ];
    doc.addTable(itemStructHeaders, itemStructRows, itemStructWidths, 7.1);

    doc.addParagraph("All'avvio della stanza, la funzione Items_DrawRoom copia gli oggetti attivi nella cache veloce current_room_items (5 byte per slot: Col, Row, Color, FlagPtrLow, FlagPtrHigh) e popola la matrice di lookup rapido items_grid (512 byte in RAM). La bitmap grafica comune a tutti gli item della stanza viene letta dagli 8 byte situati all'offset OFFSET_ITEM_GRAPHIC (692).");

    doc.addHeading2("6.2 Animazione Ciclica del Colore degli Item (Items_Animate)");
    doc.addParagraph("Gli oggetti di Manic Miner non possiedono animazione bitmap a piu frame, ma si animano tramite la celebre rotazione degli attributi colore INK a 50Hz (routine originale $8F63):");
    doc.addBullet("Rotazione Colori Ink", "Ad ogni frame, la routine Items_Animate cicla l'inchiostro attraverso la sequenza: Magenta (3) -> Verde (4) -> Ciano (5) -> Giallo (6) -> Magenta (3), preservando inalterati i bit di PAPER e BRIGHT.");
    doc.addBullet("Aggiornamento Diretto VRAM", "Il nuovo attributo cromatico viene scritto simultaneamente sia nella cache current_room_items, sia nella tabella items_grid, sia direttamente nella memoria video degli attributi VRAM ($5800 + Row*32 + Col), creando il caratteristico scintillio.");

    doc.addHeading2("6.3 Raccolta Oggetti e Sistema di Scoring BCD a 6 Cifre");
    doc.addParagraph("Ad ogni frame, Items_CheckCollision esegue un test di intersezione bounding box (16x16 pixel di Willy contro 8x8 pixel dell'oggetto):");
    doc.addBullet("Riconoscimento Raccolta", "Se Willy tocca un oggetto attivo: 1. Il byte +4 nei dati stanza viene azzerato; 2. La cella viene rimossa da items_grid; 3. La cella di sfondo viene ripristinata graficamente tramite RestoreBackgroundCell; 4. Viene emesso il beep audio di raccolta (Audio_PlayCollectSound); 5. Viene decrementato il contatore num_room_items; 6. Vengono assegnati 100 punti.");
    doc.addBullet("Aritmetica BCD con Istruzione DAA", "Il punteggio player_score e' memorizzato in 3 byte BCD (6 cifre decimali). La routine Score_AddItemPoints incrementa il byte 1 (centinaia/migliaia) ed esegue l'istruzione hardware Z80 DAA (Decimal Adjust Accumulator) con propagazione del riporto al byte 2. Questo elimina la necessita di costose routine di conversione binario-decimale a runtime!");

    doc.addHeading2("6.4 Gestione dell'High Score Persistente");
    doc.addParagraph("L'High Score (high_score, 3 byte BCD) viene preservato in memoria tra le varie partite:");
    doc.addBullet("Confronto Big-Endian", "La funzione Score_CheckAndUpdateHighScore confronta i 3 byte BCD partendo dalla cifra piu significativa (byte 2: centinaia di migliaia) fino alla meno significativa (byte 0). Se player_score supera high_score, il valore viene copiato istantaneamente e il display HUD aggiornato.");

    doc.addHeading2("6.5 Portale di Fine Livello e Svuotamento Riserva d'Aria (Air_DepleteCountdown)");
    doc.addParagraph("Quando tutti gli oggetti della stanza sono stati raccolti (num_room_items == 0, game_objective_completed = 1), il Portale d'uscita (16x16 pixel) inizia a lampeggiare (Gfx_AnimatePortal).");
    doc.addBullet("Countdown dell'Aria (Air_DepleteCountdown)", "Quando Willy entra nel portale, il gioco congela la fisica ed esegue un ciclo ad alta velocita che svuota la barra dell'aria 1 pixel alla volta: per ciascun pixel consumato, viene aggiunto 1 punto allo score del giocatore (Score_Add1Point) e viene emesso un impulso audio sul buzzer con frequenza inversamente proporzionale all'aria residua.");

    doc.addHeading2("6.6 Sequenza di Game Over (Piede) e Schermata di Vittoria (Maria)");
    doc.addBullet("Game Over (TriggerGameOver)", "All'esaurimento delle vite, il gioco lancia l'animazione originale del Piede gigante (Monty Python) che scende progressivamente dall'alto schiacciando Willy sul piedistallo, accompagnata da note del beeper e dalla scritta 'Game Over' con effetto cromatico arcobaleno (glistening).");
    doc.addBullet("Vittoria Finale (TriggerVictory)", "Al superamento dell'ultima caverna, viene visualizzata la schermata di vittoria con Maria (lo sprite della 'Vecchia') che cammina verso Willy, la scritta lampeggiante 'CONGRATULATIONS!' e il prompt interattivo 'PLAY AGAIN? Y/N'.");
}

module.exports = { addChapter6 };
