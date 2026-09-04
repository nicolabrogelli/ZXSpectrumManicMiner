function addChapter7(doc) {
    doc.addPage("7. STRUTTURA DATI DELLE CAVERNE (1024 BYTE STANDARD)");
    doc.addSectionHeader("7", "STRUTTURA DATI DELLE CAVERNE (1024 BYTE STANDARD)");

    doc.addHeading2("7.1 Mappa Completa dei 1024 Byte della Caverna");
    doc.addParagraph("Ogni livello del gioco Manic Miner e' memorizzato in un blocco binario compatto e rigidamente vincolato a 1024 byte (1 KB). Questa tabella autocontenuta racchiude l'intera definizione geometrica, cromatica, fisica ed entitaria della caverna:");

    const roomMapHeaders = ["Offset", "Dim.", "Etichetta Simbolica", "Descrizione del Blocco Dati"];
    const roomMapWidths = [50, 45, 145, 275];
    const roomMapRows = [
        ["0..511", "512 B", "CavernLayout", "Matrice 16x32 delle celle di gioco (codici di attributo grafico delle tile)."],
        ["512..543", "32 B", "CavernTile / RoomName", "Nome della caverna in formato stringa ASCII (esattamente 32 caratteri)."],
        ["544..615", "72 B", "CavernTilesDef (8x9)", "8 definizioni di tile (1 byte attr + 8 byte bitmap: BG, Floor, Crumble, Wall, Conv, Nasty1, Nasty2, Extra)."],
        ["616..622", "7 B", "WillyAppearanceAndPos", "Posizione iniziale: Byte 0: Y*2, Byte 1: frame, Byte 2: dir, Byte 4-5: AttrAddr."],
        ["623..626", "4 B", "ConveyorData", "Nastro trasportatore: Byte 0: dir (0=SX, 1=DX), Byte 1-2: ScreenAddr, Byte 3: len."],
        ["627", "1 B", "BorderColor", "Colore del bordo video dello ZX Spectrum per la caverna (valore 0..7)."],
        ["628", "1 B", "ApexPause", "Pausa all'apice salto verticale (0 = default da physics_config.asm, >0 = valore custom)."],
        ["629..654", "26 B", "LocationColorItems", "Fino a 5 oggetti (5 byte cad.: Attr, AttrAddr Low/High, Anim, Flag) + terminatore $FF."],
        ["655..691", "37 B", "PortalData", "Portale 16x16: Attributo, 32 byte bitmap (4 frame da 8 byte), AttrAddr Low/High."],
        ["692..699", "8 B", "ItemGraphic", "Bitmap 8x8 comune per tutti gli oggetti collezionabili della caverna."],
        ["700", "1 B", "InitialAir", "Riserva d'aria iniziale disponibile nella caverna (es. 63)."],
        ["701", "1 B", "GameClock", "Velocita dell'orologio / timer per il consumo d'aria della stanza."],
        ["702..730", "29 B", "HorizontalGuardians", "Fino a 4 guardiani orizzontali (7 byte cad.: Attr, AttrAddr, Mask, Frame, MinX, MaxX) + $FF."],
        ["731", "1 B", "AirSpeed", "Ampiezza parabola / preset volo (0 = default da physics_config.asm, 1..4 = custom, $FF = preset 0)."],
        ["732", "1 B", "Unused2", "Byte di riserva non utilizzato (impostato a 0)."],
        ["733", "1 B", "VGuardians", "Guardiani verticali (o terminatore $FF; se 0 indica stanza con boss)."],
        ["734..735", "2 B", "Unused3", "Byte non utilizzati (impostati a 0, 0)."],
        ["736..767", "32 B", "GraphicElement", "Grafica speciale per boss (Eugene, Kong) o elementi paesaggistici speciali."],
        ["768..1023", "256 B", "GraphicGuardian", "Set di sprite dei guardiani (8 frame 16x16 pixel da 32 byte ciascuno)."]
    ];
    doc.addTable(roomMapHeaders, roomMapRows, roomMapWidths, 7.1);

    doc.addHeading2("7.2 Caricamento, Inizializzazione e Transizione tra Stanze");
    doc.addParagraph("All'ingresso in una caverna, la routine LoadRoomAndRestart (in manicminer.asm) esegue la seguente pipeline atomica:");
    doc.addBullet("1. Reset Stack e Stato", "Ripristina lo stack pointer (ld sp, $fdf0) per azzerare qualsiasi residuo di chiamate precedenti; azzera la griglia dei pavimenti sgretolabili (crumbling_grid) e i timer dei portali.");
    doc.addBullet("2. Decompressione e Disegno", "Esegue UnpackRoomLayout; chiama Gfx_DrawRoom per disegnare l'intera matrice 16x32; disegna conveyor e rampe (Gfx_DrawConveyorsAndRamps); stampa il nome della caverna a riga 16 e inizializza la barra dell'aria a riga 17.");
    doc.addBullet("3. Inizializzazione Entita", "Chiama Items_DrawRoom per disegnare e registrare gli oggetti; chiama Enemy_LoadRoom per inizializzare ActiveEnemies con guardiani orizzontali, verticali o boss.");
    doc.addBullet("4. Posizionamento Willy e Bordo", "Legge le coordinate di spawn da OFFSET_POS_WILLY (se transition_active == 0); legge il colore del bordo da OFFSET_BORDER_COLOR, lo invia alla porta hardware out ($fe), a e aggiorna la variabile BORDCR della ROM; disegna Willy.");

    doc.addHeading2("7.3 Analisi Dettagliata delle 20 Caverne del Gioco");
    doc.addParagraph("Tabella sinottica delle 20 caverne originali incluse nel motore:");

    const roomsHeaders = ["ID", "Nome Caverna", "Colore Bordo", "Caratteristiche, Guardiani e Meccaniche Speciali"];
    const roomsWidths = [30, 140, 75, 270];
    const roomsRows = [
        ["00", "Central Cavern", "Rosso (2)", "Livello introduttivo; 5 chiavi, 1 conveyor a sinistra, guardiani minerari orizzontali."],
        ["01", "The Cold Room", "Blu (1)", "Pavimenti ghiacciati; guardiani pinguini orizzontali e blocchi sgretolabili."],
        ["02", "The Menagerie", "Magenta (3)", "Presenza di molteplici animali e mostri guardiani; percorsi multilivello."],
        ["03", "Abandoned Uranium Workings", "Verde (4)", "Ostacoli radioattivi Nasty; salti di precisione millimetrica su blocchi singoli."],
        ["04", "Eugene's Lair", "Rosso (2)", "Boss Eugene al centro; scende sul portale e diventa arcobaleno alla raccolta degli item."],
        ["05", "Processing Plant", "Ciano (5)", "Nastri trasportatori multipli contrapposti e nastri sgretolabili combinati."],
        ["06", "The Vat", "Giallo (6)", "Vasca profonda; richiede una discesa controllata senza superare l'altezza di caduta sicura."],
        ["07", "Miner Willy meets the Kong Beast", "Verde (4)", "Boss Kong Beast in alto a destra; 2 interruttori per aprire il varco e far precipitare il boss."],
        ["08", "Wacky Amoebatrons", "Blu (1)", "Guardiani amebe con percorsi orizzontali sovrapposti e piattaforme sgretolabili."],
        ["09", "The Endorian Forest", "Verde (4)", "Tile Extra (7) solido come Floor; alberi e rami percorribili, guardiani ewok."],
        ["10", "Attack of the Mutant Telephones", "Magenta (3)", "Tile Extra solido; guardiani telefoni giganti; nastri trasportatori veloci."],
        ["11", "Return of the Alien Kong Beast", "Giallo (6)", "Seconda battaglia contro Kong; interruttori e guardiani alieni sincronizzati."],
        ["12", "Ore Refinery", "Rosso (2)", "Raffineria con pavimenti metallici e acido; tile Extra solido come Floor."],
        ["13", "Skylab Landing Bay", "Ciano (5)", "Guardiani Skylab verticali che precipitano dall'alto simulando detriti spaziali."],
        ["14", "The Bank", "Verde (4)", "Caveau della banca; tile Extra solido; casseforti e guardiani custodi."],
        ["15", "The Sixteenth Cavern", "Blu (1)", "Labirinto verticale complesso con piattaforme sgretolabili a cascata."],
        ["16", "The Warehouse", "Giallo (6)", "Magazzino con barili e casse rotolanti; salti con raggio d'azione strettissimo."],
        ["17", "Amoebatrons' Revenge", "Magenta (3)", "Ritorno delle amebe mutanti; densita di ostacoli Nasty elevatissima."],
        ["18", "Solar Power Generator", "Giallo (6)", "Generatore solare; raggi laser letali e piattaforme mobili a tempo."],
        ["19", "The Final Barrier", "Bianco (7)", "Livello finale; paesaggio montano esterno (datalandscape.asm); porta alla Master Bedroom!"]
    ];
    doc.addTable(roomsHeaders, roomsRows, roomsWidths, 7.0);
}

module.exports = { addChapter7 };
