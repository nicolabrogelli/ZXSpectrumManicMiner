const fs = require('fs');
const path = require('path');

class PDFBuilder {
    constructor() {
        this.objects = [];
        this.pages = [];
        this.currentPage = null;
        this.currentStream = [];
        this.pageWidth = 595.28;  // A4 Width
        this.pageHeight = 841.89; // A4 Height
        this.margin = 45;
        this.cursorY = this.pageHeight - this.margin;
    }

    addObject(content) {
        this.objects.push(content);
        return this.objects.length;
    }

    addPage() {
        if (this.currentPage) {
            this.endPage();
        }
        this.currentStream = [];
        this.cursorY = this.pageHeight - this.margin - 30; // Leave room for header
        this.currentPage = {
            streamIndex: 0,
            pageIndex: this.pages.length + 1
        };
        this.pages.push(this.currentPage);
    }

    endPage() {
        const pNum = this.currentPage.pageIndex;
        
        // Running Header (except on cover)
        let headerStream = "";
        if (pNum > 1) {
            headerStream += `
0.5 0.5 0.55 RG
0.5 w
45 805 m 550 805 l S
BT
/F1 8 Tf
0.4 0.4 0.45 rg
45 810 Td
(ZX SPECTRUM MANIC MINER - GUIDA ALLA COSTRUZIONE DEI LIVELLI) Tj
ET
`;
        }

        // Running Footer
        const footerStream = `
0.5 0.5 0.55 RG
0.5 w
45 40 m 550 40 l S
BT
/F1 8 Tf
0.4 0.4 0.45 rg
45 28 Td
(Documento Tecnico di Sviluppo Z80 / ZX Spectrum) Tj
505 28 Td
(Pagina ${pNum}) Tj
ET
`;

        const fullStream = headerStream + "\n" + this.currentStream.join("\n") + "\n" + footerStream;
        const streamObj = `<< /Length ${Buffer.byteLength(fullStream, 'latin1')} >>\nstream\n${fullStream}\nendstream`;
        const sIndex = this.addObject(streamObj);
        this.currentPage.streamIndex = sIndex;
    }

    checkSpace(neededHeight) {
        if (this.cursorY - neededHeight < this.margin + 35) {
            this.addPage();
        }
    }

    escapeText(str) {
        return str.replace(/\\/g, '\\\\').replace(/\(/g, '\\(').replace(/\)/g, '\\)');
    }

    drawText(text, x, y, font = '/F1', size = 10, color = [0, 0, 0]) {
        const [r, g, b] = color;
        this.currentStream.push(`
BT
${r} ${g} ${b} rg
${font} ${size} Tf
${x} ${y} Td
(${this.escapeText(text)}) Tj
ET
`);
    }

    drawRect(x, y, w, h, fillColor = null, strokeColor = null, lineWidth = 1) {
        let cmd = "";
        if (fillColor) {
            cmd += `${fillColor[0]} ${fillColor[1]} ${fillColor[2]} rg\n`;
        }
        if (strokeColor) {
            cmd += `${strokeColor[0]} ${strokeColor[1]} ${strokeColor[2]} RG\n${lineWidth} w\n`;
        }
        cmd += `${x} ${y} ${w} ${h} re\n`;
        if (fillColor && strokeColor) {
            cmd += `B\n`;
        } else if (fillColor) {
            cmd += `f\n`;
        } else if (strokeColor) {
            cmd += `S\n`;
        }
        this.currentStream.push(cmd);
    }

    addTitle(text) {
        this.checkSpace(70);
        this.drawRect(45, this.cursorY - 25, 505, 30, [0.08, 0.18, 0.36], null);
        this.drawRect(45, this.cursorY - 27, 505, 2, [0.1, 0.6, 0.8], null);
        this.drawText(text, 55, this.cursorY - 17, '/F2', 13, [1, 1, 1]);
        this.cursorY -= 45;
    }

    addHeading2(text) {
        this.checkSpace(40);
        this.drawRect(45, this.cursorY - 16, 505, 20, [0.93, 0.95, 0.98], [0.8, 0.85, 0.92], 1);
        this.drawRect(45, this.cursorY - 16, 4, 20, [0.1, 0.5, 0.8], null);
        this.drawText(text, 56, this.cursorY - 12, '/F2', 10.5, [0.08, 0.18, 0.36]);
        this.cursorY -= 28;
    }

    addHeading3(text) {
        this.checkSpace(25);
        this.drawText(text, 45, this.cursorY, '/F2', 10, [0.15, 0.3, 0.55]);
        this.cursorY -= 15;
    }

    addParagraph(text, fontSize = 9, color = [0.15, 0.15, 0.18], indent = 0) {
        const maxWidth = 505 - indent;
        const words = text.split(' ');
        let currentLine = '';
        const lineHeight = fontSize * 1.35;

        for (const word of words) {
            const testLine = currentLine ? currentLine + ' ' + word : word;
            const approxWidth = testLine.length * (fontSize * 0.51);
            if (approxWidth > maxWidth && currentLine !== '') {
                this.checkSpace(lineHeight);
                this.drawText(currentLine, 45 + indent, this.cursorY, '/F1', fontSize, color);
                this.cursorY -= lineHeight;
                currentLine = word;
            } else {
                currentLine = testLine;
            }
        }
        if (currentLine) {
            this.checkSpace(lineHeight);
            this.drawText(currentLine, 45 + indent, this.cursorY, '/F1', fontSize, color);
            this.cursorY -= lineHeight + 4;
        }
    }

    addBullet(text, level = 0) {
        const indent = 15 + level * 15;
        this.checkSpace(14);
        const bulletChar = level === 0 ? ">" : "-";
        this.drawText(bulletChar, 45 + indent - 10, this.cursorY, '/F2', 8.5, [0.1, 0.5, 0.8]);
        this.addParagraph(text, 8.5, [0.2, 0.2, 0.22], indent);
    }

    addCallout(title, text, type = 'info') {
        let boxColor = [0.93, 0.96, 1.0];
        let borderColor = [0.2, 0.5, 0.8];
        let titleColor = [0.1, 0.3, 0.6];
        if (type === 'warn') {
            boxColor = [1.0, 0.96, 0.9];
            borderColor = [0.9, 0.5, 0.1];
            titleColor = [0.6, 0.3, 0.0];
        } else if (type === 'tip') {
            boxColor = [0.92, 0.98, 0.93];
            borderColor = [0.2, 0.7, 0.3];
            titleColor = [0.1, 0.45, 0.2];
        }

        const approxLines = Math.ceil(text.length / 90) + 1;
        const h = approxLines * 11 + 22;
        this.checkSpace(h + 10);

        this.drawRect(45, this.cursorY - h, 505, h, boxColor, borderColor, 1);
        this.drawRect(45, this.cursorY - h, 4, h, borderColor, null);
        this.drawText(title, 55, this.cursorY - 13, '/F2', 9, titleColor);

        const oldY = this.cursorY;
        this.cursorY -= 24;
        this.addParagraph(text, 8, [0.2, 0.2, 0.25], 12);
        this.cursorY = oldY - h - 8;
    }

    addCodeBlock(lines) {
        const lineHeight = 10.5;
        const blockHeight = lines.length * lineHeight + 12;
        this.checkSpace(blockHeight + 10);

        this.drawRect(45, this.cursorY - blockHeight, 505, blockHeight, [0.12, 0.14, 0.18], [0.25, 0.28, 0.35], 1);
        let curY = this.cursorY - 11;
        for (const line of lines) {
            this.drawText(line, 55, curY, '/F3', 7.5, [0.85, 0.9, 0.95]);
            curY -= lineHeight;
        }
        this.cursorY -= blockHeight + 8;
    }

    addTable(headers, rows, colWidths) {
        const rowHeight = 15;
        const tableHeight = (rows.length + 1) * rowHeight;
        this.checkSpace(tableHeight + 12);

        // Header Background
        this.drawRect(45, this.cursorY - rowHeight, 505, rowHeight, [0.15, 0.25, 0.42], null);

        let curX = 45;
        for (let i = 0; i < headers.length; i++) {
            this.drawText(headers[i], curX + 5, this.cursorY - 11, '/F2', 8, [1, 1, 1]);
            curX += colWidths[i];
        }
        this.cursorY -= rowHeight;

        for (let r = 0; r < rows.length; r++) {
            const rowBg = r % 2 === 0 ? [0.97, 0.98, 0.99] : [0.91, 0.93, 0.96];
            this.drawRect(45, this.cursorY - rowHeight, 505, rowHeight, rowBg, [0.8, 0.83, 0.88], 0.5);

            curX = 45;
            for (let c = 0; c < rows[r].length; c++) {
                const cellText = String(rows[r][c]);
                const font = c === 0 ? '/F2' : '/F1';
                this.drawText(cellText, curX + 5, this.cursorY - 11, font, 7.5, [0.15, 0.15, 0.2]);
                curX += colWidths[c];
            }
            this.cursorY -= rowHeight;
        }
        this.cursorY -= 8;
    }

    buildPDF(outputPath) {
        if (this.currentPage) {
            this.endPage();
        }

        const font1 = this.addObject(`<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>`);
        const font2 = this.addObject(`<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>`);
        const font3 = this.addObject(`<< /Type /Font /Subtype /Type1 /BaseFont /Courier >>`);
        const font4 = this.addObject(`<< /Type /Font /Subtype /Type1 /BaseFont /Courier-Bold >>`);

        const pageObjIndices = [];
        for (const page of this.pages) {
            const pObj = this.addObject(`<<
/Type /Page
/Parent 0 R
/MediaBox [0 0 ${this.pageWidth} ${this.pageHeight}]
/Contents ${page.streamIndex} 0 R
/Resources <<
  /Font <<
    /F1 ${font1} 0 R
    /F2 ${font2} 0 R
    /F3 ${font3} 0 R
    /F4 ${font4} 0 R
  >>
>>
>>`);
            pageObjIndices.push(pObj);
        }

        const kidsStr = pageObjIndices.map(idx => `${idx} 0 R`).join(' ');
        const pagesRootIndex = this.addObject(`<<
/Type /Pages
/Kids [${kidsStr}]
/Count ${pageObjIndices.length}
>>`);

        for (const idx of pageObjIndices) {
            this.objects[idx - 1] = this.objects[idx - 1].replace('/Parent 0 R', `/Parent ${pagesRootIndex} 0 R`);
        }

        const catalogIndex = this.addObject(`<<
/Type /Catalog
/Pages ${pagesRootIndex} 0 R
>>`);

        let pdf = `%PDF-1.4\n%âãÏÓ\n`;
        const offsets = [];

        for (let i = 0; i < this.objects.length; i++) {
            offsets.push(Buffer.byteLength(pdf, 'latin1'));
            pdf += `${i + 1} 0 obj\n${this.objects[i]}\nendobj\n`;
        }

        const xrefStart = Buffer.byteLength(pdf, 'latin1');
        pdf += `xref\n0 ${this.objects.length + 1}\n0000000000 65535 f \n`;
        for (const off of offsets) {
            pdf += `${String(off).padStart(10, '0')} 00000 n \n`;
        }

        pdf += `trailer\n<<\n/Size ${this.objects.length + 1}\n/Root ${catalogIndex} 0 R\n>>\nstartxref\n${xrefStart}\n%%EOF\n`;

        fs.writeFileSync(outputPath, pdf, 'latin1');
        console.log(`PDF generato con successo: ${outputPath} (${this.pages.length} pagine)`);
    }
}

// Generate the Document
const doc = new PDFBuilder();

// ================= PAGE 1: COVER & ARCHITECTURE =================
doc.addPage();

// Hero Header Banner
doc.drawRect(45, 680, 505, 120, [0.08, 0.15, 0.32], [0.1, 0.6, 0.8], 2);
doc.drawRect(45, 680, 505, 6, [0.1, 0.65, 0.85], null);
doc.drawText("ZX SPECTRUM MANIC MINER", 65, 760, '/F2', 20, [1, 1, 1]);
doc.drawText("Guida Tecnica Completa alla Costruzione dei Livelli (Caverne)", 65, 735, '/F2', 12, [0.2, 0.8, 1.0]);
doc.drawText("Specifiche Dati a 1024 Byte, Griglia di Layout, Tile, Fisica, Nemici, Boss e Casi Studio", 65, 715, '/F1', 9, [0.85, 0.9, 0.95]);
doc.drawText("Documento Tecnico di Riferimento per Sviluppatori Z80 / Manic Miner Engine", 65, 695, '/F1', 8, [0.6, 0.75, 0.9]);

doc.cursorY = 660;

doc.addTitle("1. Architettura di una Caverna a 1024 Byte");
doc.addParagraph("Ogni livello (Caverna) del gioco Manic Miner per ZX Spectrum occupa una struttura dati rigorosamente fissa di esattamente 1024 byte (1 KB). Questa tabella definisce in modo autocontenuto la geometria del livello, la grafica e i colori dei blocchi, la posizione di partenza di Willy, i nemici, gli oggetti collezionabili, il portale e le meccaniche speciali.");

doc.addHeading2("Mappa Completa degli Offset di Memoria (1024 Byte)");

const offsetHeaders = ["Offset", "Dim.", "Etichetta Dati", "Descrizione e Funzione"];
const offsetWidths = [50, 40, 155, 260];
const offsetRows = [
    ["0..511", "512 B", "CavernLayout", "Matrice 16x32 delle celle (attributi grafici delle tile)"],
    ["512..543", "32 B", "CavernTile / Name", "Nome della stanza (stringa ASCII di 32 caratteri)"],
    ["544..615", "72 B", "CavernTilesDef (8x9)", "8 Definizioni di tile (1 attr + 8 byte bitmap cad.)"],
    ["616..622", "7 B", "WillyAppearanceAndPos", "Posizione iniziale Y/X di Willy, direzione e frame"],
    ["623..626", "4 B", "ConveyorData", "Direzione, indirizzo schermo e lunghezza del nastro"],
    ["627", "1 B", "BorderColor", "Colore del bordo video dello Spectrum (0..7)"],
    ["628", "1 B", "Unused1", "Byte di riserva / non utilizzato (0)"],
    ["629..654", "26 B", "LocationColorItems", "Tabella fino a 5 chiavi/oggetti + terminatore 255"],
    ["655..691", "37 B", "PortalData", "Attributo, 32 byte bitmap (4 frame), indirizzi video"],
    ["692..699", "8 B", "ItemGraphic", "Bitmap 8x8 dell'oggetto raccoglibile della stanza"],
    ["700", "1 B", "InitialAir", "Riserva d'aria iniziale della caverna (es. 63)"],
    ["701", "1 B", "GameClock", "Velocita / clock del timer della stanza (es. 128..252)"],
    ["702..730", "29 B", "HorizontalGuardians", "Fino a 4 nemici orizzontali (7 byte cad. + term. 255)"],
    ["731..732", "2 B", "Unused2", "Byte non utilizzati (0, 0)"],
    ["733", "1 B", "VGuardians", "Guardiano verticale o terminatore 255 (o 0 per boss)"],
    ["734..735", "2 B", "Unused3", "Byte non utilizzati (0, 0)"],
    ["736..767", "32 B", "GraphicElement", "Grafica decorativa o sprite speciale del boss (32 byte)"],
    ["768..1023", "256 B", "GraphicGuardian", "Sprite animati dei guardiani (16 frame da 16 byte)"]
];
doc.addTable(offsetHeaders, offsetRows, offsetWidths);

doc.addCallout("IMPORTANTE: Dimensione Rigorosa a 1024 Byte", 
    "Tutti i file delle caverne (es. CentralCavern.asm, EugeneLair.asm) devono totalizzare esattamente 1024 byte. Se una sezione ha meno elementi (es. meno di 5 item o meno di 4 guardiani), lo spazio residuo deve essere riempito con zeri e terminato con 255.", 'warn');

// ================= PAGE 2: LAYOUT & TILE SYSTEM =================
doc.addPage();

doc.addTitle("2. Griglia di Layout e Matrice delle Tile");
doc.addParagraph("L'area di gioco di ogni caverna e' una matrice di 16 righe verticali per 32 colonne orizzontali (512 blocchi totali da 8x8 pixel, risoluzione 256x128 pixel per la zona di gioco).");

doc.addHeading2("Coordinate e Calcolo degli Indirizzi");
doc.addBullet("Righe (Row): da 0 (in alto) a 15 (pavimento in basso).");
doc.addBullet("Colonne (Col): da 0 (bordo sinistro) a 31 (bordo destro).");
doc.addBullet("Indice Cella nel Buffer: Offset = Row * 32 + Col (valori da 0 a 511).");
doc.addBullet("Coordinate Pixel: X = Col * 8 (0..248), Y = Row * 8 (0..120).");

doc.addHeading2("Tipologie di Tile Standard (0..7)");
doc.addParagraph("Nel motore di gioco, la funzione UnpackRoomLayout analizza i 512 byte del layout confrontando i valori degli attributi con la tabella delle 8 tile definite all'offset 544. Ciascuna tile viene classificata in un tipo logico standardizzato da 0 a 7:");

const tileHeaders = ["Tipo", "Nome Logico", "Comportamento Fisico e Interazione"];
const tileWidths = [45, 115, 345];
const tileRows = [
    ["0", "Background", "Spazio vuoto attraversabile. Nessuna collisione."],
    ["1", "Floor", "Pavimento solido calpestabile. Willy atterra e cammina."],
    ["2", "Crumbling Floor", "Pavimento sgretolabile. Si dissolve di 1 pixel/frame al tocco."],
    ["3", "Wall", "Muro solido. Blocca il passaggio orizzontale e i salti in testa."],
    ["4", "Conveyor", "Nastro trasportatore. Trascina Willy a sinistra o destra."],
    ["5", "Nasty 1", "Ostacolo letale fisso di tipo 1 (fuoco, punte, acidi). Uccide Willy."],
    ["6", "Nasty 2", "Ostacolo letale fisso di tipo 2 (ragni statici, stalattiti). Uccide Willy."],
    ["7", "Extra / Special", "Tile speciale. In alcune stanze funge da pavimento, in altre decorative."]
];
doc.addTable(tileHeaders, tileRows, tileWidths);

doc.addHeading2("Struttura Dati delle 8 Tile (Offset 544..615, 72 Byte)");
doc.addParagraph("Ogni tile e' composta da 9 byte: 1 byte di Attributo Colore ZX Spectrum seguito da 8 byte di dati Bitmap (1 byte per scanline).");

doc.addCodeBlock([
    "; Esempio di definizione Tile in Assembler Z80 (Eugene's Lair):",
    "EugeneLairBackground:     DEFB 16,  0,0,0,0,0,0,0,0              ; Attr 16 (Paper 2=Red, Ink 0=Black)",
    "EugeneLairFloor:          DEFB 21,  255,255,219,110,197,64,0,0   ; Attr 21 (Paper 2=Red, Ink 5=Cyan)",
    "EugeneLairCrumblingFloor: DEFB 20,  255,219,165,36,82,32,8,0     ; Attr 20 (Paper 2=Red, Ink 4=Green)",
    "EugeneLairWall:           DEFB 46,  34,255,136,255,34,255,136,255; Attr 46 (Paper 5=Cyan, Ink 6=Yellow)",
    "EugeneLairConveyor:       DEFB 86,  252,102,252,102,0,0,0,0      ; Attr 86 (Bright 1, Paper 2, Ink 6)",
    "EugeneLairNasty1:         DEFB 22,  68,40,148,81,53,214,88,16    ; Attr 22 (Paper 2=Red, Ink 6=Yellow)",
    "EugeneLairNasty2:         DEFB 19,  126,60,28,24,24,8,8,8        ; Attr 19 (Stalattite letale)",
    "EugeneLairExtra:          DEFB 0,   0,0,0,0,0,0,0,0              ; Attr 0 (Non utilizzato)"
]);

doc.addCallout("Regola di Attributo ZX Spectrum", 
    "Formato Byte Attributo: [Bit 7: Flash] [Bit 6: Bright] [Bit 5..3: PAPER (Sfondo)] [Bit 2..0: INK (Tratto)]. Esempio: 21 = 00010101b -> Bright 0, Paper 2 (Red), Ink 5 (Cyan).", 'tip');

// ================= PAGE 3: WILLY SPAWN & CONVEYOR & ITEMS =================
doc.addPage();

doc.addTitle("3. Parametri di Spawn, Nastro e Oggetti");

doc.addHeading2("Posizione Iniziale di Miner Willy (Offset 616..622, 7 Byte)");
doc.addParagraph("Definisce le coordinate e lo stato con cui Willy appare nella stanza:");

const willyHeaders = ["Byte", "Campo", "Valori e Descrizione"];
const willyWidths = [45, 130, 330];
const willyRows = [
    ["0", "Pixel Y * 2", "Coordinata Y di Willy moltiplicata per 2. Es: 48 -> Y = 24 pixel (Eugene's Lair)."],
    ["1", "Animation Frame", "Frame iniziale dell'animazione di camminata (0..3). Di solito 0."],
    ["2", "Direction / Flags", "0 = Willy guarda a Destra, 1 = Willy guarda a Sinistra."],
    ["3", "Airborne Status", "0 = a terra (grounded), 1 = a mezz'aria (in volo/caduta)."],
    ["4..5", "Attribute Buffer Addr", "Indirizzo buffer attributi a 23552 (DEFW 23552 + Row*32 + Col)."],
    ["6", "Jumping Counter", "Contatore salto / frame animazione di salto (inizializzare a 0)."]
];
doc.addTable(willyHeaders, willyRows, willyWidths);

doc.addHeading2("Configurazione del Nastro Trasportatore (Offset 623..626, 4 Byte)");
doc.addParagraph("Se la caverna contiene un nastro trasportatore (Conveyor), questi 4 byte ne regolano la direzione e l'estensione:");

const convHeaders = ["Byte", "Campo", "Valore e Funzione"];
const convWidths = [45, 130, 330];
const convRows = [
    ["0", "Direction", "0 = Trascinamento verso SINISTRA, 1 = Trascinamento verso DESTRA."],
    ["1..2", "Screen Buffer Addr", "Indirizzo video Spectrum (DEFW) calcolato per (Row, Col)."],
    ["3", "Length", "Lunghezza del nastro in numero di tile orizzontali (es. 10 blocchi in Eugene's Lair)."]
];
doc.addTable(convHeaders, convRows, convWidths);

doc.addHeading2("Tabella Oggetti Raccoglibili / Chiavi (Offset 629..654, 26 Byte)");
doc.addParagraph("Ogni caverna puo' contenere fino a un massimo di 5 oggetti raccoglibili (chiavi). Ogni oggetto occupa 5 byte, e la lista deve terminare con il byte di fine lista 255 (0xFF):");

const itemHeaders = ["Offset Oggetto", "Struttura Dati (5 Byte)", "Esempio Eugene's Lair"];
const itemWidths = [100, 180, 225];
const itemRows = [
    ["Oggetto 1 (5B)", "DEFB Attr, DEFW Addr, DEFB Char, DEFB 255", "Attr=19, Addr=23614 (Row 1, Col 30), Char=96"],
    ["Oggetto 2 (5B)", "DEFB Attr, DEFW Addr, DEFB Char, DEFB 255", "Attr=20, Addr=23754 (Row 6, Col 10), Char=96"],
    ["Oggetto 3 (5B)", "DEFB Attr, DEFW Addr, DEFB Char, DEFB 255", "Attr=21, Addr=23805 (Row 7, Col 29), Char=96"],
    ["Oggetto 4 (5B)", "DEFB Attr, DEFW Addr, DEFB Char, DEFB 255", "Attr=22, Addr=23943 (Row 12, Col 7), Char=104"],
    ["Oggetto 5 (5B)", "DEFB Attr, DEFW Addr, DEFB Char, DEFB 255", "Attr=19, Addr=23945 (Row 12, Col 9), Char=104"],
    ["Terminatore (1B)", "DEFB 255", "Indica la fine degli item attivi (0xFF)"]
];
doc.addTable(itemHeaders, itemRows, itemWidths);

doc.addHeading2("Portale di Uscita (Offset 655..691, 37 Byte)");
doc.addParagraph("Il portale si attiva e lampeggia quando tutti gli oggetti sono stati raccolti:");
doc.addBullet("Byte 0: Attributo colore del portale (es. 87 = Flash 0, Bright 1, Paper 2, Ink 7).");
doc.addBullet("Byte 1..32: 32 byte di grafica (4 frame di animazione 8x8 da 8 byte ciascuno).");
doc.addBullet("Byte 33..34: Indirizzo nel buffer attributi (DEFW 23552 + Row*32 + Col). In EugeneLair: 23983 (13,15).");
doc.addBullet("Byte 35..36: Indirizzo nel buffer video dello schermo Spectrum (DEFW). In EugeneLair: 26799.");

// ================= PAGE 4: GUARDIANS & SPECIALS =================
doc.addPage();

doc.addTitle("4. Guardiani, Nemici e Meccaniche Speciali");

doc.addHeading2("Guardiani Orizzontali (Offset 702..730, 29 Byte)");
doc.addParagraph("Una caverna puo' ospitare fino a 4 guardiani orizzontali indipendenti. Ciascun guardiano e' configurato con un blocco da 7 byte:");

const guardHeaders = ["Byte", "Parametro Guardiano", "Descrizione Operativa"];
const guardWidths = [45, 140, 320];
const guardRows = [
    ["0", "Attributo Colore", "Colore video del nemico (es. 22 = Paper 2, Ink 6)."],
    ["1..2", "Indirizzo Schermo Iniziale", "DEFW con l'offset del pixel iniziale (es. 23660 per Y=3, X=12)."],
    ["3", "Frame / Velocita", "Frame iniziale e velocita di animazione (bitmask)."],
    ["4", "Min X (Limite Sinistro)", "Coordinata pixel X minima oltre cui il nemico inverte la marcia."],
    ["5", "Max X (Limite Destro)", "Coordinata pixel X massima oltre cui il nemico inverte la marcia."],
    ["6", "Passo / Direzione", "Direzione iniziale e incremento pixel per frame (+1 o -1)."]
];
doc.addTable(guardHeaders, guardRows, guardWidths);

doc.addHeading2("Guardiani Verticali e Nemici Speciali (Offset 733)");
doc.addParagraph("All'offset 733 e' presente la tabella dei guardiani verticali. Se la stanza non usa guardiani verticali, il byte deve essere impostato a 255 (0xFF). Nelle stanze speciali, questo offset gestisce entita avanzate:");
doc.addBullet("Eugene's Lair: gestisce Eugene che oscilla verticalmente al centro dello schermo.");
doc.addBullet("Skylab Landing Bay: gestisce i 4 moduli Skylab che precipitano a velocita variabili.");
doc.addBullet("Solar Power Generator: gestisce il raggio ottico a riflessione solare.");
doc.addBullet("The Final Barrier: gestisce i guardiani verticali multipli e il checkpoint finale.");

doc.addHeading2("Meccaniche Speciali di Caverna Supportate");

const specialHeaders = ["Stanza Speciale", "Funzione nel Motore", "Meccanica Dedicata"];
const specialWidths = [130, 140, 235];
const specialRows = [
    ["EugeneLair.asm", "enemy.asm (.eugene_update)", "Boss reattivo centrale: oscilla e scende al portale quando finisce l'aria/item."],
    ["MinerWilly...Kong.asm", "Kong_CheckSwitches", "Kong in cima; 2 interruttori fanno crollare il pavimento sotto Kong."],
    ["ReturnoftheAlien...asm", "Kong_CheckSwitches", "Seconda battaglia con Kong con percorso a ostacoli invertito."],
    ["SkylabLandingBay.asm", "Skylab_Update", "4 satelliti che cadono ciclicamente dall'alto a velocita differenziate."],
    ["SolarPowerGen.asm", "Solar_Update", "Raggio riflettente che blocca il passaggio finche non si devia il sole."],
    ["TheSixteenthCavern.asm", "Sixteenth_Update", "Crollo sequenziale dei pavimenti a tempo."],
    ["TheMenagerie.asm", "Phys_ApplyGravity", "Supporto rampe diagonali calpestabili a pendenza costante."]
];
doc.addTable(specialHeaders, specialRows, specialWidths);

doc.addCallout("Regole per le Caverne con Kong (Interruttori)", 
    "Nelle stanze di Kong, le celle degli interruttori (Switches) controllano la caduta di Kong. Quando Willy tocca l'interruttore, la routine Kong_CheckSwitches rimuove i blocchi di pavimento alle coordinate (Row 2, Col 15..16) provocando la caduta di Kong nel baratro.", 'info');

// ================= PAGE 5: EUGENE'S LAIR CASE STUDY =================
doc.addPage();

doc.addTitle("5. Caso Studio Approfondito: Eugene's Lair (Caverna 04)");
doc.addParagraph("Eugene's Lair e' una delle caverne piu' celebri e complesse di Manic Miner. Costituisce un esempio magistrale di come combinare elementi platform rigidi, nastri trasportatori, pavimenti sgretolabili e una logica di Boss Fight programmata in Assembly Z80.");

doc.addHeading2("Architettura e Geometria del Livello");
doc.addBullet("Spawn Point di Willy: In alto a sinistra (Y=24, X=8, Row 3 Col 1), Willy parte in quota e deve farsi strada scendendo e risalendo.");
doc.addBullet("Nastro Trasportatore Centrale (Row 8, Cols 10..19): Lungo 10 blocchi, scorre verso Sinistra (conveyor_dir = 0). Taglia a meta' la caverna e costringe a calcolare con precisione i salti in contro-inerzia.");
doc.addBullet("Pavimenti Sgretolabili (Crumbling Floor 20): Posizionati a Row 5 (Cols 18..21) e Row 10 (Cols 1..2). Obbligano Willy a muoversi senza esitazioni prima che il blocco si dissolva completamente.");
doc.addBullet("Stalattiti Nasty (Tile 19 e 22): Posizionate strategicamente sui passaggi obbligati e sopra il nastro.");

doc.addHeading2("La Meccanica del Boss: Eugene (Sprite e Intelligenza Artificiale)");
doc.addParagraph("Nel file enemy.asm (linee 224..240, 535..550, 738..790), il motore riconosce automaticamente la stanza tramite il puntatore EugeneLairLayout e alloca Eugene nello Slot 4 dei nemici attivi con il flag speciale $E0 (Active=1, Vertical=1, Boss=1):");

const eugeneHeaders = ["Fase di Gioco", "Stato di Eugene", "Comportamento Tecnico Z80"];
const eugeneWidths = [110, 115, 280];
const eugeneRows = [
    ["Fase 1: Raccolta Item", "Oscillazione Verticale", "Eugene oscilla continuamente tra Y=0 e Y=88 al centro dello schermo (Col 15). Se Willy lo tocca, muore all'istante."],
    ["Fase 2: Item Completati", "Discesa al Portale", "Appena raccolti tutti i 5 item, Eugene scende inesorabilmente a quota Y=88 (sul portale/toilette) e vi si posiziona sopra."],
    ["Fase 3: Portale Attivo", "Cambiamento Colore", "Eugene cambia continuamente colore ciclando l'attributo tramite il registro game_clock, creando un effetto psichedelico lampeggiante."]
];
doc.addTable(eugeneHeaders, eugeneRows, eugeneWidths);

doc.addHeading2("Estratto della Grafica di Eugene (Offset 736, 32 Byte)");
doc.addParagraph("A differenza dei normali guardiani che usano la tabella da 256 byte, Eugene possiede uno sprite dedicato ad alta definizione da 32 byte (16x16 pixel) memorizzato direttamente all'offset 736:");

doc.addCodeBlock([
    "; Offset 736 in EugeneLair.asm - Sprite 16x16 pixel di Eugene:",
    "EugeneLairGraphicElement:",
    "    DEFB 3,192, 15,240, 31,248, 31,248   ; Linee 1..4 (Sommità della testa)",
    "    DEFB 49,140, 14,112, 111,246, 174,117 ; Linee 5..8 (Occhi e fronte)",
    "    DEFB 177,141, 159,249, 155,217, 140,49 ; Linee 9..12 (Bocca e centro)",
    "    DEFB 71,226, 2,64, 2,64, 14,112       ; Linee 13..16 (Base e mento)"
]);

doc.addCallout("Logica di Uscita da Eugene's Lair", 
    "Quando Eugene scende a Y=88 e il portale lampeggia alla coordinata (Row 13, Col 15), Willy deve saltare sopra Eugene o entrare nella toilette dal basso per completare la caverna e passare a 'Central Cavern' successiva.", 'tip');

// ================= PAGE 6: PHYSICS & LEVEL DESIGN RULES =================
doc.addPage();

doc.addTitle("6. Regole di Fisica e Level Design");
doc.addParagraph("Per creare caverne bilanciate, giocabili e prive di bug, e' fondamentale conoscere le costanti fisiche e le regole di collisione implementate nel motore:");

doc.addHeading2("Costanti di Salto, Gravita e Caduta");

const physHeaders = ["Parametro", "Valore", "Descrizione Tecnica"];
const physWidths = [125, 90, 290];
const physRows = [
    ["Altezza Salto", "18 ~ 24 pixel", "Parabola determinata da room_jump_strength (5..6) e gravita."],
    ["Velocita Orizzontale", "2 pixel / frame", "Velocita standard a terra (player_speed = 2 o 3 px)."],
    ["Velocita in Aria", "2.5 px / frame", "Alternanza automatica 2 e 3 pixel per frame durante il salto."],
    ["Caduta Massima Sicura", "40 pixel", "MAX_SAFE_FALL_HEIGHT = 40. Cadute superiori a 5 tile sono fatali."],
    ["Preset Gravita", "0.75 (Standard)", "Sequenza sub-pixel: 3 frame di accelerazione ogni 4 frame."],
    ["Coyote Time", "2 frame", "Permette di saltare fino a 2 frame dopo aver lasciato un bordo."],
    ["Jump Buffer", "2 frame", "Registra la pressione del salto 2 frame prima del contatto col suolo."]
];
doc.addTable(physHeaders, physRows, physWidths);

doc.addHeading2("Regole Geometriche di Collisione (Da Rispettare nel Level Design)");
doc.addBullet("Larghezza Sprite Willy = 8 pixel: La hitbox orizzontale occupa [X .. X+7].");
doc.addBullet("Distacco dai Bordi (Overshoot di 8px): Quando Willy cammina a destra fuori da una piattaforma (Colonna k), il distacco avviene solo quando l'intero sprite entra nella Colonna k+1. Willy cadra' quindi rigorosamente lungo la Colonna k+1. Non puo' lasciarsi cadere su una piattaforma sottostante che finisce alla Colonna k.");
doc.addBullet("Salto da Nastro Trasportatore: Saltando da un nastro senza premere frecce direzionali, Willy eredita automaticamente l'inerzia orizzontale del nastro nella direzione di scorrimento.");
doc.addBullet("Tolleranza di Atterraggio (3 Pixel): Durante una caduta o un salto, Willy atterra su un pavimento solido se la traiettoria intercetta la superficie superiore della tile con tolleranza di 3 pixel. Se un salto colpisce il fianco laterale di un blocco oltre 3 pixel sotto la cima, Willy non scala il blocco e cade.");
doc.addBullet("Gradini di 1 Tile (Step-Down 8px): Willy scende fluidamente gradini di 1 tile (8 pixel) senza entrare in caduta se il blocco inferiore e' immediatamente adiacente.");

doc.addCallout("Regola d'Oro per la Creazione di Salti", 
    "La distanza massima superabile con un salto orizzontale su terreno piano e' di circa 4-5 blocchi (32-40 pixel). Salti verso piattaforme piu' alte di 2 blocchi (16 pixel) richiedono che il punto di decollo sia molto vicino al bordo.", 'tip');

// ================= PAGE 7: COMPLETE TEMPLATE EXAMPLE =================
doc.addPage();

doc.addTitle("7. Template Assembler Z80 Completo per una Nuova Caverna");
doc.addParagraph("Di seguito e' riportato lo scheletro completo per creare un nuovo file di livello (es. MyCustomCavern.asm). Il file puo' essere incluso direttamente nella tabella delle stanze in manicminer.asm:");

doc.addCodeBlock([
    ";===========================================================================",
    "; MyCustomCavern.asm - Caverna Personalizzata per Manic Miner (1024 Byte)",
    ";===========================================================================",
    "MyCustomCavernLayout:",
    "    DEFB 22,22,22,22,22,22,22,22, 22,22,22,22,22,22,22,22 ; Riga 0 (Soffitto)",
    "    DEFB 22,22,22,22,22,22,22,22, 22,22,22,22,22,22,22,22",
    "    DEFB 22, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0 ; Righe 1..14 (Zona Gioco)",
    "    DEFB  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0,22",
    "    ; ... (Ripetere per tutte le 16 righe: totale 512 byte) ...",
    "    DEFB 22,66,66,66,66,66,66,66, 66,66,66,66,66,66,66,66 ; Riga 15 (Pavimento)",
    "    DEFB 66,66,66,66,66,66,66,66, 66,66,66,66,66,66,66,22",
    "",
    "MyCustomCavernTile:",
    "    DEFM \"       My Custom Cavern         \"  ; 32 Caratteri esatti",
    "",
    "MyCustomCavernBackground:     DEFB 0,  0,0,0,0,0,0,0,0     ; Attr 0 (Background)",
    "MyCustomCavernFloor:          DEFB 66, 255,255,219,110,197,64,0,0 ; Attr 66 (Floor)",
    "MyCustomCavernCrumblingFloor: DEFB 2,  255,219,165,36,82,32,8,0   ; Attr 2 (Crumbling)",
    "MyCustomCavernWall:           DEFB 22, 34,255,136,255,34,255,136,255 ; Attr 22 (Wall)",
    "MyCustomCavernConveyor:       DEFB 4,  240,102,240,102,0,153,255,0 ; Attr 4 (Conveyor)",
    "MyCustomCavernNasty1:         DEFB 68, 68,40,148,81,53,214,88,16  ; Attr 68 (Nasty 1)",
    "MyCustomCavernNasty2:         DEFB 5,  255,254,126,124,76,76,8,8  ; Attr 5 (Nasty 2)",
    "MyCustomCavernExtra:          DEFB 0,  0,0,0,0,0,0,0,0     ; Attr 0 (Extra)",
    "",
    "MyCustomCavernWillyPos:       DEFB 208, 0, 0, 0           ; Y*2=208 (Y=104), Frame 0, Dir 0, Air 0",
    "                              DEFW 23970, 0               ; Addr Attributi (13,2), Jump Frame 0",
    "MyCustomCavernConveyorData:   DEFB 0, 0,0, 0              ; Dir 0, Addr Video 0, Len 0",
    "MyCustomCavernBorderColor:    DEFB 2                      ; Bordo Rosso",
    "MyCustomCavernUnused1:        DEFB 0                      ; Riserva",
    "",
    "MyCustomCavernItems:          DEFB 3, 23561, 96, 255      ; Item 1 a (Row 0, Col 9)",
    "                              DEFB 255                    ; Terminatore oggetti",
    "                              .fill 21, 0                 ; Padding fino a 26 byte",
    "",
    "MyCustomCavernPortal:         DEFB 14                     ; Attributo Portale",
    "                              .fill 32, 255               ; Grafica 4 frame (32 byte)",
    "                              DEFW 23997, 26813           ; Addr Attributi e Addr Video",
    "",
    "MyCustomCavernItemGraphic:    DEFB 48,72,136,144,104,4,10,4 ; Bitmap Chiave",
    "MyCustomCavernInitialAir:     DEFB 63                     ; Riserva Aria",
    "MyCustomCavernGameClock:      DEFB 252                    ; Clock Stanza",
    "",
    "MyCustomCavernHGuardians:     DEFB 70, 23784, 96, 0, 232, 239, 1 ; Guardiano 1",
    "                              DEFB 255                    ; Terminatore guardiani",
    "                              .fill 21, 0                 ; Padding fino a 29 byte",
    "MyCustomCavernUnused2:        DEFB 0, 0",
    "MyCustomCavernVGuardians:     DEFB 255                    ; Nessun guardiano verticale",
    "MyCustomCavernUnused3:        DEFB 0, 0",
    "MyCustomCavernGraphicElement: .fill 32, 0                 ; Grafica decorativa",
    "MyCustomCavernGraphicGuardian:.fill 256, 0                ; Sprite Nemici (256 Byte)"
]);

doc.addParagraph("Per aggiungere la nuova caverna alla rotazione del gioco, e' sufficiente includere il file in manicminer.asm e registrare l'etichetta del layout nella tabella RoomsListTable.");

// Output the file
const outputPath = path.join(__dirname, 'Guida_Costruzione_Livelli_Manic_Miner.pdf');
doc.buildPDF(outputPath);
