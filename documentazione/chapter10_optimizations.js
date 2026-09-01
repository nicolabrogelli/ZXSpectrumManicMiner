function addChapter10(doc) {
    doc.addPage("10. OTTIMIZZAZIONI Z80 E TECNICHE A BASSO LIVELLO");
    doc.addSectionHeader("10", "OTTIMIZZAZIONI Z80 E TECNICHE A BASSO LIVELLO");

    doc.addHeading2("10.1 Tecniche di Risparmio di Memoria e Compattazione Dati");
    doc.addParagraph("Sviluppare un gioco ricco di 20 livelli, decine di sprite animati, audio polifonico e fisica accurata nei 48 Kilobyte di RAM dello ZX Spectrum ha imposto strategie di compattazione estreme:");

    doc.addBullet("Formato Monolitico a 1024 Byte per Livello", "Ogni stanza e' un blocco binario rigorosamente allineato a 1024 byte (1 KB). Tutte le 20 caverne occupano esattamente 20480 byte (dal $E000 al $F7FF). I dati di layout (512 byte) utilizzano codici di attributo diretti, condividendo la grafica delle 8 tile definite all'interno della stanza stessa.");
    doc.addBullet("Sprite Condivisi e Mascherati", "Tutti i guardiani orizzontali di ciascuna caverna condividono lo stesso set di 8 frame da 32 byte situato a OFFSET_GUARDIAN_GRAPHICS (256 byte totali). I guardiani verticali utilizzano i frame 0..3 della stessa tabella, eliminando duplicazioni di memoria.");
    doc.addBullet("Decompressione Dinamica del Layout (unpacked_layout)", "Invece di memorizzare matrici di collisione separate per ogni caverna, la singola matrice di 512 byte viene generata dinamicamente in RAM all'ingresso nella stanza analizzando le 8 definizioni di tile, risparmiando oltre 10 KB di ROM.");

    doc.addHeading2("10.2 Ottimizzazioni di Velocita nei Calcoli Critici a 16-Bit");
    doc.addParagraph("Il microprocessore Z80 non dispone di istruzioni hardware di moltiplicazione o divisione. I calcoli matematici critici a 50Hz sono stati ottimizzati tramite shift veloci e aritmetica a 16 bit:");

    doc.addBullet("Moltiplicazione per 32 (Row * 32)", "Eseguita in soli 5 cicli di add hl, hl (HL = Row; 5 raddoppi = moltiplicazione per 32 in appena 55 T-States, contro le centinaia di cicli di una routine generica).");
    doc.addBullet("Shift Rapido a 16 Bit per Allineamento Pixel", "Nella routine di collision detection (CheckCollision), lo scorrimento dei 16 pixel del guardiano viene eseguito accoppiando i registri D ed E con la sequenza sla e / rl d: un solo shift combinato ad alta efficienza.");
    doc.addBullet("Uso dei Registri Alternativi (EXX)", "Nelle routine di stampa testo e posizionamento cursore (Gfx_At, Gfx_Ink), lo scambio rapido dei banchi di registri con l'istruzione EXX consente di preservare i registri primari (BC, DE, HL) senza dover accedere allo stack con lente istruzioni PUSH/POP.");

    doc.addHeading2("10.3 Gestione Atomica della VRAM per Eliminazione Sfarfallio");
    doc.addParagraph("L'architettura hardware dello Spectrum rende impossibile il double-buffering tradizionale per mancanza di RAM video secondaria. Manic Miner risolve questo limite storico con una tecnica proprietaria di rendering atomico:");

    doc.addAsciiDiagram([
        "+-------------------------------------------------------------------------+",
        "|              PIPELINE DI RENDERING DIFFERENZIALE FLICKER-FREE           |",
        "+-------------------------------------------------------------------------+",
        "| 1. FASE ERASE:                                                          |",
        "|    Per ogni guardiano attivo:                                           |",
        "|    - Leggi Old X, Old Y.                                                |",
        "|    - Calcola i byte dello sfondo originale tramite Gfx_GetBackgroundByte |",
        "|    - Riscrivi i byte esatti dello sfondo nella VRAM pixel ($4000..$57FF) |",
        "|    - Ripristina gli attributi cromatici originali in VRAM ($5800..$5AFF) |",
        "|    - Controlla se toccava Willy -> willy_needs_redraw = 1               |",
        "|                                                                         |",
        "| 2. FASE DRAW:                                                           |",
        "|    Per ogni guardiano attivo:                                           |",
        "|    - Disegna lo sprite 16x16 a Current X, Current Y                     |",
        "|    - Scrivi gli attributi cromatici del nemico                          |",
        "|    - Controlla se tocca Willy -> willy_needs_redraw = 1                 |",
        "|                                                                         |",
        "| 3. FASE PLAYER OVERLAY:                                                 |",
        "|    Se Willy si e' mosso OPPURE willy_needs_redraw == 1:                 |",
        "|    - Cancella Willy alla vecchia posizione (ripristina sfondo)           |",
        "|    - Ridisegna Willy in primo piano sopra qualsiasi nemico              |",
        "+-------------------------------------------------------------------------+"
    ], "SCHEMA DELLA PIPELINE DI RENDERING FLICKER-FREE");

    doc.addHeading2("10.4 Aritmetica BCD Hardware e Lookup Table");
    doc.addParagraph("Per gestire il punteggio a 6 cifre e l'High Score in tempo reale ad ogni frame senza degradare il framerate, il motore adotta l'aritmetica BCD (Binary Coded Decimal):");
    doc.addBullet("Istruzione DAA (Decimal Adjust Accumulator)", "L'istruzione hardware Z80 DAA corregge automaticamente l'accumulatore dopo un'addizione binaria per mantenerlo in formato decimale compresso (due cifre per byte). Questo consente di aggiornare centinaia e migliaia in sole 4 istruzioni macchina (add a, 1; daa; ld (score+1), a; adc a, 0; daa; ld (score+2), a).");
    doc.addBullet("Lookup Table Precalcolate", "L'indirizzamento delle stanze (RoomsListTable), la mappa delle definizioni tile e le tabelle di ritardo delle note audio sono interamente precompilate come tabelle di puntatori diretti.");
}

module.exports = { addChapter10 };
