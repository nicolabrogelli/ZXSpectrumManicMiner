function addChapter12(doc) {
    doc.addPage("12. DIAGRAMMI DI FLUSSO E SCHEMI ARCHITETTURALI");
    doc.addSectionHeader("12", "DIAGRAMMI DI FLUSSO E SCHEMI ARCHITETTURALI");

    doc.addHeading2("12.1 Flusso del Game Loop Principale");
    doc.addAsciiDiagram([
        "  +-------------------------------------------------------------------+",
        "  |                        AVVIO FRAME (HALT 50Hz)                    |",
        "  +---------------------------------+---------------------------------+",
        "                                    |                                  ",
        "                                    v                                  ",
        "  +---------------------------------+---------------------------------+",
        "  | RENDERING: Erase nemici -> Check Overlap -> Draw nemici -> Willy  |",
        "  +---------------------------------+---------------------------------+",
        "                                    |                                  ",
        "                                    v                                  ",
        "  +---------------------------------+---------------------------------+",
        "  | GESTIONE RISORSE: Air Deplete (Morte se 0) -> Audio Jump & Music   |",
        "  +---------------------------------+---------------------------------+",
        "                                    |                                  ",
        "                                    v                                  ",
        "  +---------------------------------+---------------------------------+",
        "  | INPUT & FISICA: Scansione tastiera -> MovePlayer -> Gravita/Salto |",
        "  +---------------------------------+---------------------------------+",
        "                                    |                                  ",
        "                  +-----------------+-----------------+                ",
        "                  |                                   |                ",
        "                  v                                   v                ",
        "    [Dislivello Caduta > 40px?]             [Contatto con Nasty/Nemico]",
        "            SI /                                     SI /              ",
        "              v                                        v               ",
        "      +---------------+                        +---------------+       ",
        "      |  WILLY MUORE  |                        |  WILLY MUORE  |       ",
        "      +---------------+                        +---------------+       ",
        "              | NO                                     | NO            ",
        "              +-----------------+----------------------+               ",
        "                                |                                      ",
        "                                v                                      ",
        "  +---------------------------------+---------------------------------+",
        "  | ENTITA & EVENTI: Update Nemici -> Raccolta Item -> Check Portale  |",
        "  +---------------------------------+---------------------------------+",
        "                                    |                                  ",
        "                                    v                                  ",
        "  +---------------------------------+---------------------------------+",
        "  | [Willy nel Portale Attivo?] -> SI -> Countdown Aria -> Stanza Succ|",
        "  +-------------------------------------------------------------------+"
    ], "FLOWCHART COMPLETO DEL GAME LOOP A 25 FPS");

    doc.addHeading2("12.2 Macchina a Stati di Miner Willy");
    doc.addAsciiDiagram([
        "                      +--------------------+                           ",
        "                      |     ON GROUND      | <--------------------+    ",
        "                      | (Willy Cammina 2px)|                      |    ",
        "                      +---------+----------+                      |    ",
        "                                |                                 |    ",
        "             +------------------+------------------+              |    ",
        "             | Tasto Salto (Z)                     | Vuoto Sotto  |    ",
        "             v                                     v              |    ",
        "    +--------------------+               +--------------------+   |    ",
        "    |     JUMPING UP     |               |    FALLING DOWN    |   |    ",
        "    | (Velocita Positiva)|               | (Velocita Negativa)|   |    ",
        "    +---------+----------+               +---------+----------+   |    ",
        "              | Apice del Salto                    |              |    ",
        "              v                                    |              |    ",
        "    +--------------------+                         |              |    ",
        "    |    FALLING DOWN    |                         | Atterraggio  |    ",
        "    | (Gravita Frazion.) +------------------------>+ Sicuro <=40px|    ",
        "    +---------+----------+                                        |    ",
        "              | Caduta > 40px                                     |    ",
        "              v                                                   |    ",
        "    +--------------------+               +--------------------+   |    ",
        "    |    WILLY DIES      +-------------->|     RESPAWN        +---+    ",
        "    | (Decr. Vite / Over)|  (Vite > 0)   | (Punto di Spawn)   |        ",
        "    +--------------------+               +--------------------+        "
    ], "MACCHINA A STATI FINITI DI MINER WILLY");

    doc.addHeading2("12.3 Pipeline di Collision Detection Pixel-Perfect");
    doc.addAsciiDiagram([
        "  [Coordinate Willy: WX, WY]           [Coordinate Nemico: EX, EY]     ",
        "                |                                   |                  ",
        "                +-----------------+-----------------+                  ",
        "                                  |                                    ",
        "                                  v                                    ",
        "                 Calcola: DeltaX = WX - EX, DeltaY = WY - EY           ",
        "                                  |                                    ",
        "                                  v                                    ",
        "        [DeltaX in [-7..15] AND DeltaY in [-15..15]?]                  ",
        "                        NO /             \\ SI                          ",
        "                          v               v                            ",
        "                  +---------------+  Calcola Scanline Sovrapposte      ",
        "                  |  NESSUNA COLL.|  (overlap_num_lines: 1..16)        ",
        "                  +---------------+               |                    ",
        "                                                  v                    ",
        "                                     Per ogni riga: Shift a 16 bit dei ",
        "                                     2 byte del nemico allineati a WX  ",
        "                                                  |                    ",
        "                                                  v                    ",
        "                                     Esegui: (Byte_Willy AND Byte_Nem) ",
        "                                                  |                    ",
        "                                 +----------------+----------------+   ",
        "                                 | != 0 (Match)                    | =0",
        "                                 v                                 v   ",
        "                         +---------------+                 Prossima    ",
        "                         |  COLLISIONE!  |                 Scanline    ",
        "                         +---------------+                             "
    ], "ALGORITMO BIT-A-BIT DI COLLISION DETECTION");
}

module.exports = { addChapter12 };
