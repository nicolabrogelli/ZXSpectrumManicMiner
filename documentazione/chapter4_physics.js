function addChapter4(doc) {
    doc.addPage("4. MOTORE FISICO E RILEVAMENTO DELLE COLLISIONI");
    doc.addSectionHeader("4", "MOTORE FISICO E RILEVAMENTO DELLE COLLISIONI");

    doc.addHeading2("4.1 Decompressione del Layout e Mappatura delle Celle (unpacked_layout)");
    doc.addParagraph("Nel formato originale di Manic Miner, i 512 byte del layout di una stanza (OFFSET_LAYOUT) contengono i codici di attributo grafico delle 16x32 celle. Per garantire prestazioni estreme durante i controlli di collisione ed evitare complesse ricerche lineari a 50Hz, all'ingresso in ogni stanza la routine UnpackRoomLayout analizza ciascun byte e lo converte in un tipo logico standardizzato salvato nel buffer RAM unpacked_layout (512 byte):");

    const tileTypeHeaders = ["ID Tipo", "Costante Logica", "Tile Originale", "Comportamento Fisico"];
    const tileTypeWidths = [50, 110, 120, 235];
    const tileTypeRows = [
        ["0", "Background", "OFFSET_BG (544)", "Spazio vuoto attraversabile. Nessuna collisione."],
        ["1", "Floor", "OFFSET_FLOOR (553)", "Pavimento solido calpestabile. Willy atterra e cammina."],
        ["2", "Crumbling", "OFFSET_CRUMBLING (562)", "Pavimento sgretolabile. Solido finche non collassa (8 stadi)."],
        ["3", "Wall", "OFFSET_WALL (571)", "Muro solido. Blocca movimento orizzontale e salti in testa."],
        ["4", "Conveyor", "OFFSET_CONVEYOR (580)", "Nastro trasportatore solido. Trascina forzatamente il player."],
        ["5", "Nasty 1", "OFFSET_NASTY1 (589)", "Ostacolo letale fisso (fuoco, punte, acidi). Provoca morte istantanea."],
        ["6", "Nasty 2", "OFFSET_NASTY2 (598)", "Ostacolo letale fisso (stalattiti, ragni). Provoca morte istantanea."],
        ["7", "Extra / Special", "OFFSET_EXTRA_TILE (607)", "Solido come Floor in alcune caverne (Telefoni, Foresta, Miniera, Banca)."]
    ];
    doc.addTable(tileTypeHeaders, tileTypeRows, tileTypeWidths, 7.1);

    doc.addHeading2("4.2 Rilevamento Collisioni con Pavimenti e Piattaforme (Phys_CheckSolid)");
    doc.addParagraph("La funzione Phys_CheckSolid (in physics.asm) determina se le coordinate pixel (C = X, B = Y) corrispondono a una cella solida. La procedura calcola: Row = Y / 8 e Col = X / 8, ed interroga unpacked_layout tramite GetCellFromUnpacked:");

    doc.addBullet("Controllo ai Piedi di Willy", "Per verificare se Willy poggia su una piattaforma, il motore esamina due punti critici a quota Y + 16: il piede sinistro (X, Y + 16) e il piede destro (X + 7, Y + 16). Se almeno uno dei due punti tocca una cella solida (Floor, Crumbling, Wall, Conveyor), Willy e' considerato a terra (on_ground = 1).");
    doc.addBullet("Tolleranza di Atterraggio da Sopra (.check_landing)", "Durante la caduta, per evitare che Willy rimanga bloccato atterrando su pareti verticali laterali o agganci piattaforme arrivando da sotto, l'atterraggio e' consentito solo se la quota precedente dei piedi era entro i primi 3 pixel dalla superficie superiore: VecchioY + 16 <= (Row * 8 + 3). Se Willy proveniva da sotto, attraversa la piattaforma verso l'alto!");

    doc.addHeading2("4.3 Collisioni con Muri e Soffitti (CheckWillyWallCollision, CheckWallCell)");
    doc.addParagraph("I muri verticali e i soffitti orizzontali (tipo 3 = Wall) bloccano rigidamente il movimento:");
    doc.addBullet("Collisione Muro Orizzontale", "La routine CheckWillyWallCollision verifica 3 punti lungo il bordo di avanzamento: vertice superiore (X, Y), centro del corpo (X, Y + 7) e base (X, Y + 15). Se anche un solo punto tocca un Wall, la coordinata X non viene incrementata.");
    doc.addBullet("Collisione Soffitto (Testa)", "Durante la salita in salto (velocity_y > 0), il motore controlla se la testa a sinistra (X, Y) o a destra (X + 7, Y) tocca un Wall. In caso di impatto, PlayerY viene clampato immediatamente sotto il soffitto (riga r + 1) e velocity_y viene azzerata, facendo iniziare la caduta.");

    doc.addHeading2("4.4 Meccanica Dinamica dei Pavimenti Sgretolabili (Phys_CheckCrumblingTrigger)");
    doc.addParagraph("I pavimenti sgretolabili costituiscono uno degli enigmi fisici piu celebri del gioco:");
    doc.addBullet("Griglia crumbling_grid (512 Byte)", "Ogni cella della matrice 16x32 possiede un contatore di stadio (da 0 a 8). 0 = blocco intatto; 1..7 = stadi di dissoluzione; 8 = collasso completo.");
    doc.addBullet("Avanzamento ad Ogni Frame", "Quando Willy poggia i piedi su una tile Crumbling (Phys_CheckCrumblingTrigger), la routine .advance_crumble_cell incrementa lo stadio di 1 e ridisegna la tile (Gfx_DrawCrumblingTile) traslando il pattern bitmap verso il basso di 1 pixel.");
    doc.addBullet("Collasso Finale", "Non appena lo stadio raggiunge 8, la cella corrispondente in unpacked_layout viene sovrascritta con 0 (Background). Il blocco cessa all'istante di essere solido e Willy precipita nel vuoto.");

    doc.addHeading2("4.5 Modello Matematico delle Rampe Inclinate (GetRampY)");
    doc.addParagraph("Le rampe inclinate a 45 gradi consentono a Willy di salire e scendere fluidamente pixel per pixel. La quota teorica della rampa viene calcolata analiticamente dalla funzione GetRampY:");
    doc.addBullet("Rampa che Sale a Destra (ramp_dir == 1)", "Data la colonna di partenza ramp_col e la riga di base ramp_row: ramp_Y = (ramp_row * 8 - 16) - (PlayerX - ramp_col * 8).");
    doc.addBullet("Rampa che Sale a Sinistra (ramp_dir == 0)", "Data la colonna di partenza ramp_col: ramp_Y = (ramp_row * 8 - 16) - (ramp_col * 8 - PlayerX).");
    doc.addBullet("Aggancio e Guardia d'Ingresso (ramp_entry_guard)", "Se Willy entra orizzontalmente in una stanza con una rampa, per evitare che venga teletrasportato sulla rampa dal pavimento sottostante, la guardia disattiva l'aggancio finche Willy non e' uscito dalla zona di confine o non e' gia alla quota corretta.");

    doc.addHeading2("4.6 Nastri Trasportatori e Logica di Cattura (CheckWillyOnConveyor)");
    doc.addParagraph("La gestione del nastro trasportatore implementa la celebre dinamica irreversibile del gioco originale:");
    doc.addBullet("Rilevamento", "CheckWillyOnConveyor verifica se i piedi poggiano su una cella Conveyor (tipo 4) o entro i limiti definiti da conveyor_row, conveyor_col e conveyor_len.");
    doc.addBullet("Cattura e Trascinamento", "Se Willy cammina nella direzione opposta allo scorrimento del nastro tenendo premuto il tasto, puo avanzare; ma non appena il tasto viene rilasciato, conveyor_caught viene impostato a 1. Da quel momento ogni pressione contraria viene ignorata e Willy viene trascinato verso l'estremita.");

    doc.addHeading2("4.7 Rilevamento Ostacoli Letali (Phys_CheckNastyCollision)");
    doc.addParagraph("Phys_CheckNastyCollision protegge Willy controllando 6 punti strategici del suo bounding box (16x8 pixel): Top-Left (X, Y), Top-Right (X+7, Y), Mid-Left (X, Y+7), Mid-Right (X+7, Y+7), Bot-Left (X, Y+15), Bot-Right (X+7, Y+15). Se uno qualsiasi di questi punti tocca una cella Nasty 1 (tipo 5) o Nasty 2 (tipo 6), la funzione ritorna Carry = 1 scatenando la morte di Willy.");
}

module.exports = { addChapter4 };
