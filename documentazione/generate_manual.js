const fs = require('fs');
const path = require('path');
const { PDFBuilder } = require('./pdf_builder');

const { addChapter1 } = require('./chapter1_overview');
const { addChapter2 } = require('./chapter2_architecture');
const { addChapter3 } = require('./chapter3_player');
const { addChapter4 } = require('./chapter4_physics');
const { addChapter5 } = require('./chapter5_enemies');
const { addChapter6 } = require('./chapter6_items');
const { addChapter7 } = require('./chapter7_rooms');
const { addChapter8 } = require('./chapter8_graphics');
const { addChapter9 } = require('./chapter9_gameloop');
const { addChapter10 } = require('./chapter10_optimizations');
const { addChapter11 } = require('./chapter11_code');
const { addChapter12 } = require('./chapter12_diagrams');
const { addChapter13 } = require('./chapter13_critique');

function buildDocument(tocData = null) {
    const doc = new PDFBuilder();

    // ================= PAGE 1: COVER PAGE =================
    doc.addPage("COPERTINA");

    doc.drawRect(40, 790, 515, 5, [0.12, 0.45, 0.78], null);
    doc.drawRect(40, 782, 515, 2, [0.2, 0.7, 0.95], null);

    doc.drawRect(40, 635, 515, 135, [0.07, 0.14, 0.28], [0.15, 0.48, 0.82], 1.5);
    doc.drawRect(40, 635, 515, 5, [0.2, 0.7, 0.95], null);

    doc.drawText("ZX SPECTRUM MANIC MINER", 60, 730, '/F2', 20, [1, 1, 1]);
    doc.drawText("Guida Tecnica Completa, Architettura del Progetto e Analisi dei Sorgenti Z80", 60, 705, '/F2', 11, [0.25, 0.8, 1.0]);
    doc.drawText("Studio approfondito del motore di gioco, fisica, collision detection pixel-perfect, IA guardiani e rendering VRAM", 60, 685, '/F1', 8.5, [0.85, 0.9, 0.96]);
    doc.drawText("Documento di Riferimento per Ingegneri Software, Retrogamer e Sviluppatori Assembly", 60, 665, '/F1', 7.5, [0.65, 0.78, 0.92]);
    doc.drawText("Codice Sorgente Target: Sinclair ZX Spectrum 48K (Z80A @ 3.50 MHz) - Compilatore: sjasmplus", 60, 648, '/F5', 7.2, [0.95, 0.82, 0.4]);

    doc.cursorY = 615;

    doc.drawRect(40, 485, 515, 115, [0.95, 0.97, 1.0], [0.75, 0.82, 0.92], 0.8);
    doc.drawRect(40, 485, 4, 115, [0.12, 0.48, 0.82], null);
    doc.drawText("SPECIFICHE TECNICHE DELL'ARCHITETTURA HARDWARE E SOFTWARE", 52, 582, '/F2', 9, [0.08, 0.2, 0.4]);

    const specHeaders = ["Parametro", "Valore / Indirizzo", "Descrizione Architetturale"];
    const specWidths = [120, 110, 275];
    const specRows = [
        ["Target Hardware", "ZX Spectrum 48K", "CPU Zilog Z80A @ 3.50 MHz, ULA custom, 48KB RAM, 16KB ROM"],
        ["Entry Point", "0x5DAD (org 23981)", "Indirizzo di avvio del programma, Stack pointer inizializzato a $FDF0"],
        ["VRAM Pixel Buffer", "$4000..$57FF (6144 B)", "Matrice 256x192 pixel a 3 terzi con scanline interlacciate"],
        ["VRAM Attribute Buffer", "$5800..$5AFF (768 B)", "Matrice 32x24 celle colore (FLASH, BRIGHT, PAPER, INK)"],
        ["Interrupt Mode", "IM 2 (Vettore $FE00)", "Interrupt a 50Hz sincronizzato con il vertical blank della ULA"],
        ["Dimensione Caverne", "1024 Byte (1 KB)", "20 caverne da 1024 byte ciascuna (Layout, Tile, Nemici, Oggetti, Portale)"],
        ["Formato Punteggio", "BCD 3 Byte (6 Cifre)", "Aritmetica decimale codificata in binario tramite istruzione DAA"]
    ];

    doc.cursorY = 572;
    doc.addTable(specHeaders, specRows, specWidths, 7.0);

    doc.cursorY = 460;
    doc.addSectionHeader("PREMESSA", "SCOPO E STRUTTURA DEL DOCUMENTO");
    doc.addParagraph("Il presente documento costituisce la guida tecnica integrale e autosufficiente del progetto Manic Miner per Sinclair ZX Spectrum 48K. Il manuale è stato redatto analizzando riga per riga l'intera base di codice Assembly Z80 del repository, con l'obiettivo di fornire una documentazione esaustiva che consenta a qualsiasi programmatore di comprendere a fondo il funzionamento, l'architettura logica, la gestione della memoria, la fisica del movimento, il motore di rendering e le strategie di ottimizzazione implementate nel gioco.");

    doc.addParagraph("Tutti i nomi di file, funzioni, etichette (labels), variabili e costanti corrispondono esattamente a quanto definito nei sorgenti del progetto. I concetti teorici sono corredati da schemi a blocchi, tabelle riassuntive e porzioni di codice commentate che illustrano le scelte implementative e i workaround tecnici resi necessari dai vincoli dell'hardware target.");

    // ================= PAGE 2: TABLE OF CONTENTS =================
    doc.addPage("INDICE DEI CONTENUTI");
    doc.addSectionHeader("INDICE", "STRUTTURA DELLA GUIDA TECNICA");

    if (tocData && tocData.length > 0) {
        for (const entry of tocData) {
            const isMain = entry.level === 1;
            const font = isMain ? '/F2' : '/F1';
            const size = isMain ? 7.6 : 7.0;
            const color = isMain ? [0.08, 0.18, 0.35] : [0.25, 0.28, 0.35];
            const titleText = isMain ? entry.title : "   " + entry.title;

            doc.checkSpace(11.5);
            const textY = doc.cursorY;

            doc.drawText(titleText, 45, textY, font, size, color);
            
            const dotsCount = Math.max(5, Math.floor((480 - (titleText.length * (size * 0.48))) / 4));
            const dotsStr = ".".repeat(dotsCount);
            doc.drawText(dotsStr, 510 - (dotsCount * 3.5), textY, '/F1', 6, [0.65, 0.7, 0.78]);

            doc.drawText(String(entry.page), 525, textY, '/F2', size, [0.1, 0.4, 0.7]);
            doc.cursorY -= 11;
        }
    } else {
        doc.addParagraph("Generazione indice in corso...");
    }

    // Add Chapters
    addChapter1(doc);
    addChapter2(doc);
    addChapter3(doc);
    addChapter4(doc);
    addChapter5(doc);
    addChapter6(doc);
    addChapter7(doc);
    addChapter8(doc);
    addChapter9(doc);
    addChapter10(doc);
    addChapter11(doc);
    addChapter12(doc);
    addChapter13(doc);

    return doc;
}

// Fixed-Point Iteration for TOC
console.log('Calcolo pagine reali in corso...');
let currentToc = null;
let finalDoc = null;

for (let iter = 1; iter <= 3; iter++) {
    console.log(`Iterazione ${iter}...`);
    finalDoc = buildDocument(currentToc);
    currentToc = finalDoc.tocEntries;
}

const outputPath = path.join(__dirname, 'Guida_Tecnica_Manic_Miner.pdf');
finalDoc.buildPDF(outputPath);
console.log('Guida Tecnica generata con successo!');
