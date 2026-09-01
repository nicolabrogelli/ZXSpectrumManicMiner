function addChapter5(doc) {
    doc.addPage("5. SISTEMA DEI NEMICI E INTELLIGENZA ARTIFICIALE");
    doc.addSectionHeader("5", "SISTEMA DEI NEMICI E INTELLIGENZA ARTIFICIALE");

    doc.addHeading2("5.1 Tabella dei Nemici Attivi (ActiveEnemies) e Struttura dello Slot");
    doc.addParagraph("I guardiani (nemici mobili) presenti nella caverna corrente vengono istanziati all'ingresso nella tabella ActiveEnemies allocata in RAM. La tabella e' composta da 8 slot da 11 byte ciascuno (88 byte totali):");

    const enemyStructHeaders = ["Offset", "Campo Dati", "Tipo / Range", "Significato e Funzione Logica"];
    const enemyStructWidths = [45, 110, 85, 275];
    const enemyStructRows = [
        ["+0", "Flags", "Bitfield", "Bit 7: Active (1=attivo), Bit 6: Vertical (1=vert), Bit 5: Eugene/Kong, Bit 4: Slow."],
        ["+1", "Sprite Frame Index", "0..7", "Indice del frame grafico (da moltiplicare per 32 per l'offset bitmap)."],
        ["+2", "Current X", "0..248 (pixel)", "Posizione orizzontale attuale dello sprite 16x16 (Top-Left)."],
        ["+3", "Current Y", "0..120 (pixel)", "Posizione verticale attuale dello sprite 16x16 (Top-Left)."],
        ["+4", "Min Limit", "0..248 (pixel)", "Limite minimo del percorso (X min per orizzontali, Y min per verticali)."],
        ["+5", "Max Limit", "0..248 (pixel)", "Limite massimo del percorso (X max per orizzontali, Y max per verticali)."],
        ["+6", "Direction / Status", "1 o 2", "1 = Sinistra / Alto, 2 = Destra / Basso (o stato Kong: 0=ledge, 1=falling, 2=dead)."],
        ["+7", "Anim State / Speed", "0..7 / 1..2", "Frame di animazione (0..7) per orizzontali; step in pixel (1..2) per verticali."],
        ["+8", "Old X", "0..248 ($FF)", "Coordinata X del frame precedente, usata per la cancellazione differenziale."],
        ["+9", "Old Y", "0..120 ($FF)", "Coordinata Y del frame precedente, usata per la cancellazione differenziale."],
        ["+10", "Color Attribute", "0..127", "Attributo colore ZX Spectrum (Bright, Paper, Ink) applicato allo sprite 16x16."]
    ];
    doc.addTable(enemyStructHeaders, enemyStructRows, enemyStructWidths, 7.1);

    doc.addHeading2("5.2 Guardiani Orizzontali: Ciclo Animazione a 8 Frame e Inversione");
    doc.addParagraph("I guardiani orizzontali seguono l'algoritmo classico di Manic Miner (routine originale $8D0F):");
    doc.addBullet("Ciclo dei Frame (0..7)", "I frame 0, 1, 2, 3 rappresentano il movimento verso destra all'interno della cella a 8 pixel. I frame 7, 6, 5, 4 rappresentano il movimento verso sinistra.");
    doc.addBullet("Avanzamento Cella e Limiti", "Quando il frame raggiunge 3 (bordo destro della cella), se Current X < Max Limit X, Current X avanza di 8 pixel e il frame torna a 0. Se Current X ha raggiunto Max Limit X, il guardiano inverte la marcia impostando il frame a 7 e la direzione a 1 (Sinistra). Analogamente, al raggiungimento del frame 4 a sinistra, indietreggia di 8 pixel finche non tocca Min Limit X, dove inverte verso destra.");
    doc.addBullet("Guardiani Lenti (Slow Speed)", "Se il bit 4 dei Flags e' impostato, il guardiano viene aggiornato solo sui frame pari (counter & 1 == 0), dimezzando la sua velocita di pattugliamento.");

    doc.addHeading2("5.3 Guardiani Verticali: Pattugliamento Lineare e Velocita Frazionaria");
    doc.addParagraph("I guardiani verticali (Bit 6 impostato) si muovono lungo una colonna fissa:");
    doc.addBullet("Movimento in Pixel", "Ad ogni frame in cui i nemici vengono aggiornati, la coordinata Y viene incrementata o decrementata dello step (1 o 2 pixel) indicato all'offset +7.");
    doc.addBullet("Inversione di Marcia", "Al raggiungimento di Min Limit Y (in alto) la direzione passa a 2 (Down); al raggiungimento di Max Limit Y (in basso) la direzione passa a 1 (Up).");
    doc.addBullet("Animazione", "L'indice del frame grafico (offset +1) cicla continuamente tra 0, 1, 2 e 3.");

    doc.addHeading2("5.4 Comportamento Speciale del Boss Eugene (Caverna 04)");
    doc.addParagraph("Eugene, il boss della Caverna 04 (Eugene's Lair), e' allocato nello Slot 4 di ActiveEnemies con flag $E0 (Active, Vertical, Eugene):");
    doc.addBullet("Fase 1: Pattugliamento", "Finché restano oggetti da raccogliere (game_objective_completed == 0), Eugene pattuglia verticalmente tra Y=0 e Y=88 con colore bianco su rosso (Paper 2, Ink 7 = 23).");
    doc.addBullet("Fase 2: Discesa sul Portale e Arcobaleno", "Non appena tutti gli oggetti sono stati raccolti, Eugene scende verso la base (Y=88) bloccando l'accesso al portale e inizia a cambiare colore a ogni frame con un effetto arcobaleno sincronizzato con il timer interrupt (counter).");

    doc.addHeading2("5.5 Meccaniche del Boss Kong Beast e Interruttori (Caverne 07 e 11)");
    doc.addParagraph("Nelle caverne 'Miner Willy meets the Kong Beast' e 'Return of the Alien Kong Beast', Kong Beast e' posizionato su un cornicione in alto a destra (Y=0, X=120, Slot 3 di ActiveEnemies). La sconfitta di Kong richiede l'azionamento sequenziale di due interruttori speciali (Kong_CheckSwitches):");
    doc.addBullet("1. Interruttore Sinistro (Row 0, Col 6)", "Quando Willy tocca l'interruttore sinistro (kong_switch_left = 1), l'interruttore scatta graficamente a video, il muro alle celle (Row 11-12, Col 17) viene abbattuto in unpacked_layout e il percorso del guardiano 2 viene esteso fino a Col 28.");
    doc.addBullet("2. Interruttore Destro (Row 0, Col 18)", "Quando Willy tocca l'interruttore destro (kong_switch_right = 1), l'interruttore scatta, il pavimento sotto Kong a (Row 2, Col 15-16) crolla, Kong precipita verso il basso (Y aumenta di 2 px/frame con frame 2-3) e all'impatto a Y=88 viene rimosso assegnando 100 punti bonus al giocatore.");

    doc.addHeading2("5.6 Collision Detection Pixel-Perfect Bit-a-Bit (CheckCollision)");
    doc.addParagraph("Manic Miner e' universalmente celebre per la sua collision detection rigorosamente bit-a-bit (CheckCollision in enemy.asm):");
    doc.addBullet("Fase 1: Pre-filtro Bounding Box Rapido", "Calcola DeltaX = WillyX - EnemyX (valido se tra -7 e +15) e DeltaY = WillyY - EnemyY (valido se tra -15 e +15). Se fuori range, il nemico viene scartato all'istante a costo quasi zero.");
    doc.addBullet("Fase 2: Calcolo Righe Sovrapposte", "Determina overlap_num_lines (numero di scanline orizzontali in cui Willy e il guardiano si intersecano, da 1 a 16).");
    doc.addBullet("Fase 3: Allineamento Shift a 16 Bit", "Per ciascuna scanline sovrapposta, i 2 byte grafici del guardiano vengono estratti e traslati a sinistra o a destra con istruzioni sla e / rl d per allinearli esattamente alla coordinata pixel di Willy.");
    doc.addBullet("Fase 4: Operazione AND Logica", "Il byte allineato del guardiano viene confrontato con il byte della scanline corrispondente di Willy (testa o corpo) tramite l'istruzione AND C. Se il risultato e' diverso da zero (AND C != 0), c'e un contatto fisico reale tra pixel opachi -> CARRY SET (Collisione Confermata!).");
}

module.exports = { addChapter5 };
