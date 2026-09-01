function addChapter3(doc) {
    doc.addPage("3. GESTIONE DEL GIOCATORE (MINER WILLY)");
    doc.addSectionHeader("3", "GESTIONE DEL GIOCATORE (MINER WILLY)");

    doc.addHeading2("3.1 Strutture Dati e Variabili di Stato del Giocatore");
    doc.addParagraph("Tutte le proprieta dinamiche di Miner Willy sono allocate in variabili globali a 1 o 2 byte in RAM (data/datavariable.asm):");

    const varHeaders = ["Variabile", "Tipo / Dim.", "Valori Ammessi", "Funzione Logica nel Motore"];
    const varWidths = [110, 75, 100, 230];
    const varRows = [
        ["PlayerPos", "Byte x 2", "B=Y (0..127), C=X (5..245)", "Coordinate cartesiane attuali in pixel di Willy (Top-Left dello sprite)."],
        ["PlayerPosOld", "Byte x 2", "B=OldY, C=OldX", "Coordinate del frame precedente, utilizzate per cancellare lo sprite."],
        ["player_drawn_pos", "Byte x 2", "X, Y ($FF se invalido)", "Coordinate effettive renderizzate a video nell'ultimo frame."],
        ["direction", "Byte", "1 = Sinistra, 2 = Destra", "Orientamento orizzontale dello sprite e della camminata."],
        ["body_state", "Byte", "0, 1, 2", "Frame corrente dell'animazione ciclica delle gambe di Willy."],
        ["on_ground", "Byte", "1 = a terra, 0 = in aria", "Flag di stato: indica se Willy poggia su solido o e' in volo."],
        ["velocity_y", "Signed Byte", "-12 .. +6", "Velocita verticale istantanea (positiva verso l'alto, negativa in caduta)."],
        ["jump_dir", "Byte", "0=Vert, 1=SX, 2=DX", "Direzione di volo bloccata all'inizio del salto (inalterabile in aria)."],
        ["jump_start_y", "Byte", "0..127", "Quota Y di partenza del salto/caduta per calcolare il dislivello di morte."],
        ["jump_frame", "Byte", "0..255", "Contatore incrementale dei frame di volo per gravita frazionaria."],
        ["coyote_timer", "Byte", "0..4", "Timer Coyote Time: permette il salto per 4 frame dopo aver lasciato un bordo."],
        ["jump_pressed", "Byte", "0..5", "Jump Buffer: conserva la pressione del tasto Z poco prima di toccare terra."],
        ["conveyor_caught", "Byte", "0 o 1", "Flag di cattura nastro: impedisce a Willy di opporsi dopo aver rilasciato il tasto."],
        ["willy_safety_timer", "Byte", "0..255 (frame)", "Timer di invulnerabilita temporanea post-respawn contro i guardiani."]
    ];
    doc.addTable(varHeaders, varRows, varWidths, 7.1);

    doc.addHeading2("3.2 Sistema di Movimento Orizzontale a Terra e in Volo");
    doc.addParagraph("La routine MovePlayer (in player.asm) gestisce lo spostamento orizzontale di Willy analizzando la maschera di input D generata da Input_CheckCtrl (bit 0 = Sinistra, bit 1 = Destra, bit 2 = Salto):");

    doc.addBullet("Movimento a Terra (on_ground == 1)", "Se Willy e' a terra, lo spostamento orizzontale corrisponde a player_speed (2 pixel per frame). L'animazione delle gambe cicla sequenzialmente attraverso body_state (0 -> 1 -> 2 -> 0).");
    doc.addBullet("Movimento in Aria (on_ground == 0)", "Durante il salto o la caduta, la direzione e' rigidamente vincolata a jump_dir. Il codice ignora completamente i tasti premuti in quel frame. La velocita orizzontale in volo alterna 2 e 3 pixel per frame (esaminando bit 0 di jump_frame) garantendo una velocita media perfetta di 2.5 pixel/frame.");
    doc.addBullet("Controlli Opposti Simultanei", "Se il giocatore preme contemporaneamente O (Sinistra) e P (Destra), la sezione 4 di Input_CheckCtrl cancella entrambi i bit di direzione preservando solo l'eventuale salto su Z.");

    doc.addHeading2("3.3 Modello Fisico del Salto Parabolico e Caduta");
    doc.addParagraph("Il modello balistico di Manic Miner non fa uso di costose librerie a virgola mobile, ma implementa un'elegante gravita frazionaria a precisione intera integrata in Phys_ApplyGravity:");

    doc.addBullet("Impulso Iniziale", "All'avvio del salto, velocity_y viene caricata con il valore room_jump_strength (default 6). La coordinata Y di partenza viene congelata in jump_start_y.");
    doc.addBullet("Applicazione Gravita Frazionaria", "Ad ogni frame in aria (in_air), jump_frame viene incrementato. In base al preset attivo (room_gravity_preset = 1, corrispondente a gravita media 0.75), la gravita sottrae 1 da velocity_y per 3 frame su 4 (saltando la sottrazione quando jump_frame & 3 == 3).");
    doc.addBullet("Spostamento Verticale", "PlayerY viene aggiornato sottraendo velocity_y: PlayerY = PlayerY - velocity_y. Se velocity_y > 0 Willy sale verso l'alto; se velocity_y < 0 Willy scende verso il basso.");
    doc.addBullet("Velocita Terminale di Caduta", "La velocita di discesa e' limitata superiormente a MAX_FALL_SPEED = 12 pixel per frame per evitare lo sfondamento delle collisioni.");

    doc.addHeading2("3.4 Limiti di Schermo, Clamp e Coordinate Pixel");
    doc.addParagraph("L'area di movimento del player e' delimitata da costanti hardware e software:");
    doc.addBullet("Limite Sinistro (PLAYER_MIN_X = 5)", "Se Willy cerca di muoversi oltre il pixel 5, la coordinata viene bloccata a PLAYER_MIN_X e lo sprite non sconfina nel bordo.");
    doc.addBullet("Limite Destro (PLAYER_MAX_X = 245)", "La coordinata X destra non puo superare 245 pixel (permettendo allo sprite largo 16 pixel di fermarsi prima del bordo destro).");
    doc.addBullet("Limite Verticale Superiore (Y < 0)", "Se Willy salta oltre la cima dello schermo (bit 7 di PlayerY = 1), PlayerY viene clampato a 0, velocity_y azzerata e il salto interrotto.");
    doc.addBullet("Limite Verticale Inferiore (Y >= 113)", "Se Willy cade nel baratro sul fondo della caverna (PlayerY >= 113), scatta il controllo di caduta fatale provocando la morte immediata.");

    doc.addHeading2("3.5 Macchina a Stati del Giocatore e Condizioni di Morte/Respawn");
    doc.addParagraph("Lo stato del giocatore transita tra condizioni ben definite. La morte (.willy_dies) puo essere causata da:");
    doc.addBullet("1. Caduta Fatale", "Dislivello verticale (landing_Y - jump_start_y) > 40 pixel (5 blocchi).");
    doc.addBullet("2. Contatto con Guardiano", "Collisione bit-a-bit pixel-perfect con un pixel attivo di un nemico.");
    doc.addBullet("3. Contatto con Nasty", "Bounding box di Willy tocca una tile letale fissa (Nasty1 o Nasty2).");
    doc.addBullet("4. Asfissia", "Esaurimento totale dei 224 pixel della barra dell'aria.");

    doc.addCallout("Sequenza di Respawn (.normal_respawn)",
        "Alla morte di Willy: 1. Decremento willy_lives; 2. Ripristino di tutti gli item della caverna (Items_ResetCurrentRoomItems); 3. Schermo e bordo a nero con pausa di 0.5s (25 HALT); 4. Azzeramento fisica e impostazione timer sicurezza willy_safety_timer = RESPAWN_SAFETY_TIME; 5. Riposizionamento allo spawn point (OFFSET_POS_WILLY).", 'warn');
}

module.exports = { addChapter3 };
