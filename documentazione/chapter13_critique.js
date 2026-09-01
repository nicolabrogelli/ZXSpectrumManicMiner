function addChapter13(doc) {
    doc.addPage("13. ANALISI CRITICA: WORKAROUND, LIMITAZIONI E PUNTI DELICATI");
    doc.addSectionHeader("13", "ANALISI CRITICA: WORKAROUND, LIMITAZIONI E PUNTI DELICATI");

    doc.addHeading2("13.1 Gestione dell'Attribute Clash dello ZX Spectrum");
    doc.addParagraph("Il limite hardware piu celebre dello ZX Spectrum e' l'Attribute Clash (conflitto di colore): ogni cella di 8x8 pixel puo contenere un solo colore di inchiostro (INK) e un solo colore di sfondo (PAPER).");
    doc.addBullet("Soluzione Adottata", "Nel motore di Manic Miner, gli sprite dinamici (Willy e i guardiani) non alterano permanentemente la memoria attributi dello sfondo. Quando un guardiano si muove, sovrascrive temporaneamente l'attributo delle celle che attraversa; al momento della cancellazione (Gfx_RestoreEnemyColorAttributes), l'attributo originale della caverna viene ripristinato.");
    doc.addBullet("Willy in Primo Piano", "Per evitare che Willy assuma il colore del nemico quando si incrociano, Willy viene sempre ridisegnato DOPO i guardiani, imponendo il suo inchiostro (Cyan su sfondo trasparente) al di sopra dell'attributo del nemico.");

    doc.addHeading2("13.2 Risoluzione del Glitch di Aggancio Rampe dal Basso (ramp_entry_guard)");
    doc.addParagraph("Nelle prime versioni dei platform su Spectrum, l'equazione lineare di una rampa calcolata unicamente in base a X (Y = BaseY - X) provocava un grave glitch: se il giocatore camminava sul pavimento sottostante la rampa, il motore interpretava la sua coordinata X come appartenente alla rampa e lo 'teletrasportava' magneticamente in alto sulla superficie inclinata.");
    doc.addBullet("Implementazione della Guardia Orizzontale", "La variabile ramp_entry_guard impedisce l'aggancio quando Willy entra orizzontalmente in una stanza con una rampa finche non si allontana dalla zona di confine o non e' gia alla quota corretta.");
    doc.addBullet("Controllo di Provenienza Verticale in Salto", "Durante la salita in salto, la quota iniziale jump_start_y viene confrontata con la quota teorica della rampa ramp_Y: se Willy proveniva da sotto la rampa (jump_start_y > ramp_Y), l'atterraggio viene bloccato permettendo a Willy di passare oltre senza agganci impropri.");

    doc.addHeading2("13.3 Preservazione dei Registri in Funzioni di Calcolo Fisico");
    doc.addParagraph("Un punto delicatissimo emerso dall'analisi dei sorgenti riguarda la gestione dei registri CPU nelle routine matematiche:");
    doc.addBullet("Il Caso GetRampY e Registro D", "GetRampY calcola la quota della rampa in A e clobbera il registro D durante le sottrazioni. La routine chiamante falling_checks utilizzava D per conservare old_Y: un confronto tra D e la quota rampa generava un bug per cui Willy atterrava sulla rampa anche provenendo da sotto. Il codice attuale risolve elegantemente rileggendo old_Y direttamente dalla memoria (ld a, (PlayerPos+1)).");

    doc.addHeading2("13.4 Gestione dello Stack Pointer (ld sp, $fdf0) per Evitare Stack Drift");
    doc.addParagraph("In un gioco complesso con salti diretti, transizioni tra livelli e respawn continui, un uso disinvolto di chiamate CALL senza corrispondenti RET puo provocare uno 'Stack Drift' (progressivo riempimento dello stack con conseguente crash per sovrascrittura delle variabili in RAM):");
    doc.addBullet("Workaround Hardware Rigoroso", "All'inizio di LoadRoomAndRestart, ShowTitleScreen, TriggerGameOver e dei salti di warp stanza, il codice esegue un reset esplicito e incondizionato dello Stack Pointer: ld sp, $fdf0. Questo garantisce che lo stack torni sempre alla sua posizione vergine in cima alla memoria, rendendo il programma immune a qualsiasi stack overflow.");

    doc.addHeading2("13.5 Limiti di Scalabilita del Modello a 1024 Byte");
    doc.addParagraph("Sebbene la struttura rigida a 1024 byte per stanza sia un capolavoro di economia per l'hardware del 1983, presenta limiti architetturali determinati dai vincoli dei buffer fissi:");
    doc.addBullet("Massimo 5 Oggetti per Caverna", "Lo spazio riservato a OFFSET_ITEMS (26 byte) consente un massimo di 5 record da 5 byte piu terminatore $FF.");
    doc.addBullet("Massimo 4 Guardiani Orizzontali", "Lo spazio a OFFSET_H_GUARDIANS (29 byte) ospita al massimo 4 guardiani da 7 byte piu terminatore $FF.");
    doc.addBullet("Risoluzione Fissa a Schermata Singola", "Non e' previsto scrolling multidirezionale: ogni caverna e' rigorosamente confinata nella matrice 16x32 blocchi.");

    doc.addCallout("CONCLUSIONE DELL'ANALISI TECNICA",
        "L'architettura del sorgente di Manic Miner dimostra un'eccezionale maestria nell'ingegneria del software su Z80. I vincoli fisici estremi dello ZX Spectrum 48K sono stati superati non con compromessi qualitativi, ma attraverso algoritmi deterministici brillanti: decompressione al volo, collision detection bit-a-bit a 16 bit, aritmetica BCD hardware e gestione atomica della VRAM.", 'tip');
}

module.exports = { addChapter13 };
