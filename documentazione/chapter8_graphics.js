function addChapter8(doc) {
    doc.addPage("8. GRAFICA, VRAM E RENDERING FLICKER-FREE");
    doc.addSectionHeader("8", "GRAFICA, VRAM E RENDERING FLICKER-FREE");

    doc.addHeading2("8.1 Organizzazione e Geometria della VRAM dello ZX Spectrum ($4000..$5AFF)");
    doc.addParagraph("L'architettura grafica dello ZX Spectrum presenta una mappa di memoria storicamente non lineare, concepita dalla Sinclair per ottimizzare il circuito integrato ULA. La memoria video e' divisa in due blocchi contigui:");
    doc.addBullet("1. Display Pixel RAM ($4000..$57FF, 6144 Byte)", "Risoluzione 256x192 pixel monocromatici a 1 bit per pixel (1 byte = 8 pixel orizzontali). L'area e' suddivisa in 3 terzi verticali da 64 scanline ciascuno. All'interno di ciascun terzo, le scanline non sono consecutive ma interlacciate a blocchi di 8 righe di caratteri.");
    doc.addBullet("2. Attribute RAM ($5800..$5AFF, 768 Byte)", "Matrice di 32 colonne x 24 righe di caratteri (8x8 pixel). Ciascun byte definisce i colori della cella corrispondente secondo il layout di bit standard: Bit 7: FLASH (lampeggio), Bit 6: BRIGHT (luminosita), Bit 5-3: PAPER (colore sfondo 0..7), Bit 2-0: INK (colore tracciato 0..7).");

    doc.addHeading2("8.2 Calcolo Matematico degli Indirizzi Video e Scanline (Gfx_GetScreenAddr)");
    doc.addParagraph("Per convertire una coordinata cartesiana (L = X in pixel 0..255, H = Y in scanline 0..191) nell'indirizzo fisico a 16 bit della VRAM, la routine Gfx_GetScreenAddr applica la seguente manipolazione di bit:");

    doc.addCodeBlock([
        "; Calcolo indirizzo VRAM da coordinate cartesiane (H=Y, L=X)",
        "; Formato Byte Alto (D): 0 1 0 y7 y6 y2 y1 y0",
        "; Formato Byte Basso (E): y5 y4 y3 x4 x3 x2 x1 x0",
        "Gfx_GetScreenAddr:",
        "    ld   a, h",
        "    and  %00000111         ; Isola i bit di scanline y2 y1 y0",
        "    or   %01000000         ; Base memoria video $40 (0100 0000)",
        "    ld   d, a              ; D parziale",
        "    ld   a, h",
        "    and  %11000000         ; Isola i bit del terzo y7 y6",
        "    rrca : rrca : rrca     ; Shift a destra di 3 posizioni",
        "    or   d",
        "    ld   d, a              ; D completo",
        "    ld   a, h",
        "    and  %00111000         ; Isola la riga del carattere y5 y4 y3",
        "    add  a, a : add a, a   ; Shift a sinistra di 2 posizioni",
        "    ld   e, a              ; E parziale",
        "    ld   a, l",
        "    srl a : srl a : srl a  ; A = X / 8 (colonna orizzontale 0..31)",
        "    or   e",
        "    ld   e, a              ; E completo",
        "    ld   h, d : ld l, e    ; HL = Indirizzo fisico esatto in VRAM",
        "    ret"
    ], "graphics.asm - Gfx_GetScreenAddr");

    doc.addHeading2("8.3 Rendering degli Sprite e Ricostruzione dello Sfondo (Gfx_GetBackgroundByte)");
    doc.addParagraph("Poiche lo ZX Spectrum 48K non possiede memoria sufficiente per un secondo buffer video da 6.75 KB (double buffering), Manic Miner adotta una sofisticata pipeline di rendering differenziale a cancellazione selettiva:");
    doc.addBullet("Cancellazione Intelligente senza Sfarfallio", "Quando un guardiano o Willy si sposta, la routine Gfx_ErasePixelSprite16x16 non cancella lo sprite disegnando nero, ma interroga Gfx_GetBackgroundByte. Questa funzione calcola analiticamente quale elemento grafico si trova in quella posizione (matrice tile, nastro trasportatore, pavimento sgretolabile o portale) e riscrive i byte originali della scena!");
    doc.addBullet("Ripristino Attributi Colore", "Contemporaneamente, Gfx_RestoreEnemyColorAttributes ripristina gli esatti attributi cromatici dello sfondo presenti prima del passaggio del nemico, prevenendo l'attribute bleeding.");

    doc.addHeading2("8.4 Pipeline di Rendering a Due Passate e Risoluzione Sovrapposizioni");
    doc.addParagraph("Per eliminare qualsiasi sfarfallio e garantire che Willy rimanga sempre visibile in primo piano rispetto ai guardiani, il ciclo di rendering si suddivide in due passate atomiche:");
    doc.addBullet("Passata 1 (Erase Pass)", "Tutti i nemici attivi vengono cancellati nella loro vecchia posizione (Old X, Old Y). Durante questa fase, la funzione CheckEnemyWillyOverlap controlla se la vecchia posizione del nemico intersecava Willy: in caso affermativo, imposta il flag willy_needs_redraw = 1.");
    doc.addBullet("Passata 2 (Draw Pass)", "Tutti i nemici vengono ridisegnati nella nuova posizione (Current X, Current Y). CheckEnemyWillyOverlap verifica nuovamente se la nuova posizione si sovrappone a Willy: in tal caso, reimposta willy_needs_redraw = 1.");
    doc.addBullet("Ridisegno Willy in Primo Piano (Gfx_UpdatePlayer)", "Subito dopo il disegno dei nemici, Gfx_UpdatePlayer verifica se Willy si e' mosso oppure se willy_needs_redraw == 1: in entrambi i casi cancella e ridisegna immediatamente Willy, assicurando che il protagonista compaia SEMPRE sopra qualsiasi guardiano!");

    doc.addHeading2("8.5 HUD, Barra dell'Aria Dinamica e Animazione delle Vite");
    doc.addParagraph("L'interfaccia a video occupa le righe da 16 a 23 dello schermo:");
    doc.addBullet("Nome Stanza (Riga 16)", "Centrato su 32 colonne, con colori vividi associati alla caverna.");
    doc.addBullet("Barra dell'Aria (Riga 17)", "28 colonne di pixel (224 pixel totali). Gfx_UpdateAirBar aggiorna con precisione di 1 singolo pixel l'estremita della barra verde/rossa senza ridisegnare l'intero schermo.");
    doc.addBullet("Riga di Stato e Vite (Righe 18..23)", "Visualizza 'High Score: XXXXXX', 'Score: XXXXXX' e le icone animate di Willy che camminano sul fondo dello schermo indicando le vite rimanenti.");
}

module.exports = { addChapter8 };
