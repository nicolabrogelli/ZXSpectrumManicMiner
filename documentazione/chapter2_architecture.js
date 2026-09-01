function addChapter2(doc) {
    doc.addPage("2. ARCHITETTURA DEL PROGETTO E ORGANIZZAZIONE DEL CODICE");
    doc.addSectionHeader("2", "ARCHITETTURA DEL PROGETTO E ORGANIZZAZIONE DEL CODICE");

    doc.addHeading2("2.1 Struttura delle Cartelle e Mappa dei File");
    doc.addParagraph("Il progetto e' organizzato secondo una struttura modulare pulita, dove ogni modulo Assembly Z80 racchiude un sottosistema funzionale ben definito:");

    const fileHeaders = ["Percorso File", "Modulo / Funzione", "Descrizione e Contenuto Tecnico"];
    const fileWidths = [135, 110, 270];
    const fileRows = [
        ["manicminer.asm", "Main & Flow Control", "Entry point del programma ($5DAD), loop principale, gestione transizioni stanze, game over, victory screen e salvataggio snapshot .SNA."],
        ["constants.asm", "Costanti Globali", "Indirizzi ROM/RAM Spectrum, costanti colore, flag interrupt, UDG, costanti stanza e ID sprite."],
        ["settings.asm", "Flag di Compilazione", "Interruttori condizionali IF/ENDIF (musica, effetti, velocita game loop, collision death, debug bars)."],
        ["physics_config.asm", "Parametri Fisica", "Configurazione salto di default, gravita, coyote time, jump buffer frames, hitbox inset."],
        ["interrupts.asm", "Gestione Interrupt IM2", "Configurazione tabella e vettore IM 2 ($FE00/$FDFD), ISR a 50Hz per incremento counter."],
        ["graphics.asm", "Motore Grafico & VRAM", "Geometria VRAM Spectrum, disegno layout, rendering pixel-perfect sprite 16x16, HUD, air bar, erase e background restore."],
        ["player.asm", "Logica Giocatore", "Movimento orizzontale Willy a terra/aria, clamp limiti, animazione gambe, spawn da stanza e cattura conveyor."],
        ["physics.asm", "Motore Fisico", "Gravita modulare, salto, atterraggio, crumbling floors a 8 stadi, rampe analitiche, collisioni wall e nasty."],
        ["enemy.asm", "Sistema Nemici & IA", "Tabella ActiveEnemies (8 slot x 11B), guardiani orizzontali/verticali, Eugene, Kong Beast, interruttori e collisioni bit-a-bit."],
        ["items.asm", "Oggetti & Punteggio", "Parsing item stanza (OFFSET_ITEMS), animazione colore $8F63, raccolta bounding box, BCD score e high score."],
        ["audio.asm", "Beeper Sound Engine", "Effetti sonori frame-by-frame sul buzzer porta $FE (salto, raccolta item) e sintetizzatore musicale a 1 bit."],
        ["resources.asm", "Gestore Risorse", "Inclusione di tutte le 20 caverne (rooms/*.asm), sprite grafiche dei personaggi e font buffer UDG."],
        ["data/datavariable.asm", "RAM Globale Dinamica", "Allocazione di tutte le variabili di stato, posizioni, buffer di layout (unpacked_layout, items_grid, crumbling_grid)."],
        ["rooms/*.asm (20 file)", "Layout Caverne (1KB)", "File sorgenti individuali delle 20 caverne, ciascuno contenente esattamente 1024 byte di dati di livello."]
    ];
    doc.addTable(fileHeaders, fileRows, fileWidths, 7.1);

    doc.addHeading2("2.2 Funzione e Responsabilita dei Principali Moduli");
    doc.addParagraph("Ciascun file .asm implementa uno strato architetturale rigorosamente isolato:");
    doc.addBullet("manicminer.asm (Core)", "Inizializza l'hardware (imposta stack pointer a $FDF0, apre il canale video 2 della ROM con OPENCHAN, inizializza UDG a $8400, pulisce lo schermo e attiva IM2). Orchestratore del game loop.");
    doc.addBullet("graphics.asm (Rendering)", "Contiene la logica matematica di conversione tra coordinate cartesiane pixel (X, Y) e indirizzi fisici non lineari della VRAM dello ZX Spectrum. Implementa il rendering atomico privo di sfarfallio (Flicker-Free).");
    doc.addBullet("physics.asm (Physics Engine)", "Decomprime il layout in RAM e calcola ad ogni frame la traiettoria di salto, la velocita verticale, l'aggancio millimetrico su pavimenti e rampe e la dissoluzione dei pavimenti sgretolabili.");
    doc.addBullet("enemy.asm (AI & Guardiani)", "Aggiorna ad ogni frame i frame di animazione e le posizioni dei guardiani attivi. Contiene la celebre routine di collisione pixel-perfect bit-a-bit tra lo sprite di Willy e la grafica dei guardiani.");

    doc.addHeading2("2.3 Grafo delle Dipendenze e Flusso dei Dati");
    doc.addParagraph("Il flusso di comunicazione tra i moduli si articola su una memoria centrale condivisa (definita in data/datavariable.asm) senza overhead di stack o passaggio di parametri complessi:");

    doc.addAsciiDiagram([
        "+-------------------------------------------------------------------------+",
        "|                           manicminer.asm (Main)                         |",
        "+--------+----------------+----------------+----------------+-------------+",
        "         |                |                |                |              ",
        "         v                v                v                v              ",
        "  +--------------+ +--------------+ +--------------+ +--------------+      ",
        "  |  input.asm   | |  player.asm  | | physics.asm  | |  enemy.asm   |      ",
        "  | (Lettura IO) | | (Movimento)  | | (Fisica/Grav)| | (IA Guardiani|      ",
        "  +-------+------+ +------+-------+ +------+-------+ +------+-------+      ",
        "          |               |                |                |              ",
        "          +---------------+--------+-------+----------------+              ",
        "                                   |                                       ",
        "                                   v                                       ",
        "                       +-----------------------+                           ",
        "                       | data/datavariable.asm |                           ",
        "                       | (PlayerPos, Layout...) |                          ",
        "                       +-----------+-----------+                           ",
        "                                   |                                       ",
        "                                   v                                       ",
        "                       +-----------------------+                           ",
        "                       |     graphics.asm      |                           ",
        "                       |  (Rendering VRAM ULA) |                           ",
        "                       +-----------------------+                           "
    ], "DIAGRAMMA DELLE DIPENDENZE E FLUSSO DATI DEL MOTORE");

    doc.addHeading2("2.4 Assemblaggio, Mappa della Memoria RAM e Target Hardware");
    doc.addParagraph("Il codice viene compilato tramite l'assemblatore sjasmplus producendo un'immagine di memoria completa da 48KB e uno snapshot avviabile in formato .SNA:");

    const memHeaders = ["Intervallo Indirizzi", "Dimensione", "Funzione e Contenuto in Memoria"];
    const memWidths = [120, 85, 310];
    const memRows = [
        ["$0000..$3FFF", "16384 B (16KB)", "ROM Standard ZX Spectrum (Tabelle matematiche, font ASCII base, routine ROM)"],
        ["$4000..$57FF", "6144 B (6KB)", "VRAM Bitmap Pixel ZX Spectrum (256x192 pixel, visualizzata dalla ULA)"],
        ["$5800..$5AFF", "768 B", "VRAM Color Attributes (32x24 caratteri a 8x8 con attributi FLASH, BRIGHT, PAPER, INK)"],
        ["$5B00..$5DAC", "685 B", "Buffer di sistema ZX Spectrum e variabili BASIC"],
        ["$5DAD..$E000", "~33 KB", "Codice Sorgente Eseguibile Manic Miner (Tutti i moduli .asm compilati)"],
        ["$E000..$F7FF", "6144 B", "Dati Statici Caverne (20 stanze x 1024 byte ciascuna = 20480 byte complessivi)"],
        ["$F800..$FDFF", "1536 B", "Buffer RAM Dinamici (unpacked_layout, items_grid, crumbling_grid, font_buffer)"],
        ["$FE00..$FEFF", "257 B", "Tabella di Vettori Interrupt IM 2 (riempita con il byte $FD)"],
        ["$FDF0", "Puntatore", "Stack Pointer (SP) hardware inizializzato all'avvio del gioco"]
    ];
    doc.addTable(memHeaders, memRows, memWidths, 7.2);
}

module.exports = { addChapter2 };
