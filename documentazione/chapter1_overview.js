function addChapter1(doc) {
    doc.addPage("1. PANORAMICA DEL GIOCO E MECCANICHE FONDAMENTALI");
    doc.addSectionHeader("1", "PANORAMICA DEL GIOCO E MECCANICHE FONDAMENTALI");

    doc.addHeading2("1.1 Obiettivo del Gioco e Condizioni di Vittoria");
    doc.addParagraph("Manic Miner e' uno dei capostipiti del genere platform a schermata fissa (single-screen platformer), sviluppato originariamente da Matthew Smith nel 1983 per l'home computer Sinclair ZX Spectrum 48K. L'obiettivo primario del giocatore e' guidare il protagonista, Miner Willy (il minatore Willy), attraverso una sequenza di 20 caverne sotterranee colme di pericoli, trappole letali e creature ostili.");

    doc.addParagraph("In ciascuna caverna, il giocatore deve tassativamente raccogliere tutti gli oggetti scintillanti (chiavi/tesori) sparsi per la schermata. La raccolta dell'ultimo oggetto presente nella stanza scatena l'attivazione del Portale d'Uscita (Portal), che inizia a lampeggiare con un ciclo cromatico arcobaleno. Il completamento del livello avviene nel momento esatto in cui la bounding box del giocatore entra in collisione con il portale attivo:");

    doc.addBullet("Condizione di Avanzamento Livello", "Raccolta di tutti gli oggetti (num_room_items == 0) e sovrapposizione fisica di Willy con il portale (CheckPortalTransition attiva). Al passaggio, l'aria residua viene convertita in punti bonus.");
    doc.addBullet("Condizione di Vittoria Globale", "Superamento della ventesima ed ultima caverna (Stanza 19: The Final Barrier). Al raggiungimento del portale finale, si attiva la sequenza cinematica di vittoria (TriggerVictory) in cui Willy raggiunge la moglie Maria (la 'VecchiaSprite') nella Master Bedroom.");

    doc.addHeading2("1.2 Meccaniche Principali e Dinamiche di Gioco");
    doc.addParagraph("Il gameplay di Manic Miner si distingue per una fisica deterministica, inflessibile e priva di qualsiasi inerzia residua, richiedendo una precisione millimetrica nel tempismo e nella posizione di salto.");

    doc.addBullet("Movimento Orizzontale a Terra", "Willy si muove a terra a una velocita fissa di 2 pixel per frame (WILLY_WALK_SPEED = 2). La pressione dei tasti direzionali sposta immediatamente il player senza fasi di accelerazione o decelerazione.");
    doc.addBullet("Salto Parabolico a Traiettoria Rigida", "A differenza dei moderni platform con salto variabile, in Manic Miner il salto ha un arco e una traiettoria immutabili e non correggibili a mezz'aria. Una volta iniziato un salto direzionale, Willy continuera inesorabilmente a volare nella direzione iniziale (jump_dir) per l'intera durata del salto.");
    doc.addBullet("Nastri Trasportatori (Conveyor)", "Piattaforme speciali animate che trascinano forzatamente Willy a sinistra o a destra. Se Willy cerca di opporsi camminando contro il nastro, puo avanzare temporaneamente, ma non appena il tasto direzionale viene rilasciato, Willy viene 'catturato' (conveyor_caught = 1) e trascinato ineluttabilmente verso il bordo del nastro.");
    doc.addBullet("Pavimenti Sgretolabili (Crumbling Floor)", "Piattaforme di roccia friabile a 8 stadi di dissoluzione. Ogni frame in cui Willy calpesta un blocco sgretolabile, la texture del blocco scende verso il basso di 1 scanline. Al raggiungimento dell'ottavo stadio (8 pixel di dissoluzione), il blocco collassa completamente trasformandosi in spazio vuoto (Background) e facendo precipitare Willy.");
    doc.addBullet("Rampe Inclinate a Pendenza Analitica", "Piani inclinati a 45 gradi sui quali Willy sale e scende con continuita pixel-by-pixel, agganciando la quota calcolata analiticamente dalla formula di pendenza.");
    doc.addBullet("Celle Letali Fisse (Nasty Tiles)", "Ostacoli ambientali fissi come punte rocciose, stalattiti, pozze di acido, fiamme o ragni statici. Il minimo contatto tra il bounding box di Willy e una cella Nasty provoca la morte immediata del protagonista.");
    doc.addBullet("Guardiani Mobili (Nemici)", "Creature che pattugliano la caverna secondo percorsi ciclici prefissati orizzontali o verticali, con animazioni sincronizzate e rilevamento delle collisioni pixel-perfect (bit a bit).");

    doc.addHeading2("1.3 Struttura Generale di una Partita");
    doc.addParagraph("L'architettura del flusso di gioco segue un automa a stati finiti rigorosamente gerarchico:");

    const flowHeaders = ["Stato di Gioco", "Routine Principale", "Eventi di Transizione e Condizioni"];
    const flowWidths = [95, 120, 300];
    const flowRows = [
        ["Title Screen", "ShowTitleScreen", "Mostra logo e grafica del titolo con animazione colore ciclica. Attende la pressione del tasto ENTER per azzerare lo stato e avviare la Caverna 00."],
        ["In-Game Loop", "Main_loop", "Esegue a 25 FPS il ciclo sincrono: rendering nemici, disegno Willy, aggiornamento aria, audio, lettura input, fisica, collisioni e raccolta item."],
        ["Morte / Respawn", ".willy_dies", "Decrementa willy_lives. Se vite > 0, esegue una pausa a schermo nero di 0.5s, ripristina gli item della stanza e ricarica Willy allo spawn point."],
        ["Game Over", "TriggerGameOver", "Scatenato all'esaurimento delle vite (willy_lives == 0). Aggiorna l'High Score, esegue l'animazione del Piede gigante sul piedistallo con audio beeper e torna a Title Screen."],
        ["Vittoria Finale", "TriggerVictory", "Scatenato al completamento della Stanza 19. Disegna Maria che cammina verso Willy, anima 'CONGRATULATIONS!' e chiede 'PLAY AGAIN? Y/N'."]
    ];
    doc.addTable(flowHeaders, flowRows, flowWidths, 7.2);

    doc.addHeading2("1.4 Gestione dei Livelli e Flusso delle Caverne");
    doc.addParagraph("Il gioco comprende 20 caverne numerate da 00 a 19, ciascuna definita da un blocco dati monolitico di esattamente 1024 byte (1 KB). I puntatori a tutte le stanze sono registrati nella tabella RoomsListTable:");
    doc.addBullet("Sequenza Caverne (00..19)", "00: Central Cavern, 01: The Cold Room, 02: The Menagerie, 03: Abandoned Uranium Workings, 04: Eugene's Lair, 05: Processing Plant, 06: The Vat, 07: Miner Willy meets the Kong Beast, 08: Wacky Amoebatrons, 09: The Endorian Forest, 10: Attack of the Mutant Telephones, 11: Return of the Alien Kong Beast, 12: Ore Refinery, 13: Skylab Landing Bay, 14: The Bank, 15: The Sixteenth Cavern, 16: The Warehouse, 17: Amoebatrons' Revenge, 18: Solar Power Generator, 19: The Final Barrier.");

    doc.addHeading2("1.5 Regole di Gioco, Vite, Punteggio e Game Over");
    doc.addParagraph("Le regole di ingaggio e i parametri di sopravvivenza sono rigidamente codificati:");
    doc.addBullet("Riserva di Vite", "Il giocatore inizia la partita con 7 vite (INITIAL_LIVES = 7 in constants.asm). Il contatore e' memorizzato nella variabile willy_lives.");
    doc.addBullet("Altezza di Caduta Letale (Fall Death)", "Willy puo cadere in sicurezza per un massimo di 40 pixel verticali (MAX_SAFE_FALL_HEIGHT = 40, pari a 5 blocchi da 8 pixel). Se l'atterraggio avviene dopo un dislivello superiore a 40 pixel rispetto alla quota di inizio caduta (jump_start_y), Willy soccombe all'impatto.");
    doc.addBullet("Riserva d'Aria e Asfissia", "Ogni caverna possiede una riserva d'aria visualizzata graficamente dalla barra AIR a riga 17 (224 pixel). L'aria si consuma al ritmo di 1 pixel ogni N tick (Phys_UpdateAir). Se l'aria si esaurisce (air_pixels == 0), Willy muore all'istante per soffocamento.");
    doc.addBullet("Sistema di Punteggio BCD", "Il punteggio e' gestito in memoria in formato BCD (Binary Coded Decimal) a 3 byte (6 cifre decimali 000000..999999). Ogni oggetto raccolto assegna 100 punti. Durante la transizione di fine livello, ogni pixel di aria residua viene convertito in 1 punto supplementare.");
}

module.exports = { addChapter1 };
