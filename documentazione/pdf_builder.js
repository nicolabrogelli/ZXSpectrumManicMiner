const fs = require('fs');
const path = require('path');

class PDFBuilder {
    constructor() {
        this.objects = [];
        this.pages = [];
        this.currentPage = null;
        this.currentStream = [];
        this.pageWidth = 595.28;  // A4 Width (pt)
        this.pageHeight = 841.89; // A4 Height (pt)
        this.margin = 40;
        this.contentWidth = 515.28; // 595.28 - 2 * 40
        this.cursorY = this.pageHeight - this.margin;
        this.currentSectionTitle = "";
        this.tocEntries = []; // { title, page, level }
    }

    addObject(content) {
        this.objects.push(content);
        return this.objects.length;
    }

    addPage(sectionTitle = null) {
        if (this.currentPage) {
            this.endPage();
        }
        if (sectionTitle !== null) {
            this.currentSectionTitle = sectionTitle;
        }
        this.currentStream = [];
        this.cursorY = this.pageHeight - this.margin - 26; // Spazio per running header
        this.currentPage = {
            streamIndex: 0,
            pageIndex: this.pages.length + 1,
            sectionTitle: this.currentSectionTitle
        };
        this.pages.push(this.currentPage);
    }

    endPage() {
        const pNum = this.currentPage.pageIndex;
        const secTitle = this.currentPage.sectionTitle || "ZX SPECTRUM MANIC MINER - GUIDA TECNICA E ARCHITETTURALE";

        // Running Header (pagine > 1)
        let headerStream = "";
        if (pNum > 1) {
            headerStream += `
0.52 0.55 0.62 RG
0.5 w
40 806 m 555 806 l S
BT
/F2 7 Tf
0.18 0.24 0.38 rg
40 811 Td
(${this.escapeText(secTitle.toUpperCase())}) Tj
ET
BT
/F1 7 Tf
0.42 0.46 0.54 rg
430 811 Td
(ZX SPECTRUM 48K | Z80 ENGINE) Tj
ET
`;
        }

        // Running Footer (pagine > 1)
        let footerStream = "";
        if (pNum > 1) {
            footerStream = `
0.52 0.55 0.62 RG
0.5 w
40 38 m 555 38 l S
BT
/F1 7.2 Tf
0.36 0.4 0.48 rg
40 27 Td
(ZX Spectrum Manic Miner - Guida Tecnica Completa e Analisi del Codice Sorgente) Tj
ET
BT
/F2 7.2 Tf
0.18 0.24 0.38 rg
512 27 Td
(Pag. ${pNum}) Tj
ET
`;
        }

        const fullStream = headerStream + "\n" + this.currentStream.join("\n") + "\n" + footerStream;
        const streamObj = `<< /Length ${Buffer.byteLength(fullStream, 'latin1')} >>\nstream\n${fullStream}\nendstream`;
        const sIndex = this.addObject(streamObj);
        this.currentPage.streamIndex = sIndex;
    }

    checkSpace(neededHeight) {
        if (this.cursorY - neededHeight < this.margin + 30) {
            this.addPage(this.currentSectionTitle);
        }
    }

    escapeText(str) {
        if (!str) return '';
        return String(str)
            .replace(/\\/g, '\\\\')
            .replace(/\(/g, '\\(')
            .replace(/\)/g, '\\)');
    }

    drawText(text, x, y, font = '/F1', size = 8.5, color = [0, 0, 0]) {
        const [r, g, b] = color;
        this.currentStream.push(`
BT
${r.toFixed(3)} ${g.toFixed(3)} ${b.toFixed(3)} rg
${font} ${size} Tf
${x.toFixed(2)} ${y.toFixed(2)} Td
(${this.escapeText(text)}) Tj
ET
`);
    }

    drawRect(x, y, w, h, fillColor = null, strokeColor = null, lineWidth = 1) {
        let cmd = "";
        if (fillColor) {
            cmd += `${fillColor[0].toFixed(3)} ${fillColor[1].toFixed(3)} ${fillColor[2].toFixed(3)} rg\n`;
        }
        if (strokeColor) {
            cmd += `${strokeColor[0].toFixed(3)} ${strokeColor[1].toFixed(3)} ${strokeColor[2].toFixed(3)} RG\n${lineWidth} w\n`;
        }
        cmd += `${x.toFixed(2)} ${y.toFixed(2)} ${w.toFixed(2)} ${h.toFixed(2)} re\n`;
        if (fillColor && strokeColor) {
            cmd += `B\n`;
        } else if (fillColor) {
            cmd += `f\n`;
        } else if (strokeColor) {
            cmd += `S\n`;
        }
        this.currentStream.push(cmd);
    }

    addSectionHeader(numberStr, titleStr) {
        this.checkSpace(62);
        this.currentSectionTitle = `${numberStr} ${titleStr}`;
        this.tocEntries.push({ title: `${numberStr} ${titleStr}`, page: this.pages.length + 1, level: 1 });

        this.drawRect(40, this.cursorY - 24, 515, 28, [0.08, 0.16, 0.32], [0.12, 0.45, 0.78], 1.2);
        this.drawRect(40, this.cursorY - 26, 515, 2, [0.2, 0.7, 0.95], null);
        this.drawText(numberStr, 50, this.cursorY - 16, '/F2', 11.5, [0.35, 0.85, 1.0]);
        this.drawText(titleStr.toUpperCase(), 72 + (numberStr.length * 4.5), this.cursorY - 16, '/F2', 10.5, [1, 1, 1]);
        this.cursorY -= 38;
    }

    addHeading2(title) {
        this.checkSpace(36);
        this.tocEntries.push({ title: title, page: this.pages.length + 1, level: 2 });

        this.drawRect(40, this.cursorY - 15, 515, 19, [0.93, 0.95, 0.98], [0.75, 0.82, 0.92], 0.7);
        this.drawRect(40, this.cursorY - 15, 4, 19, [0.12, 0.48, 0.82], null);
        this.drawText(title, 50, this.cursorY - 11.5, '/F2', 9, [0.08, 0.18, 0.36]);
        this.cursorY -= 24;
    }

    addHeading3(title) {
        this.checkSpace(22);
        this.drawText(title, 40, this.cursorY, '/F2', 8.5, [0.14, 0.32, 0.58]);
        this.cursorY -= 13;
    }

    measureTextWidth(text, fontSize = 8.2, isBold = false) {
        if (!text) return 0;
        const charWidth = fontSize * (isBold ? 0.52 : 0.48);
        return text.length * charWidth;
    }

    wrapText(text, maxWidth, fontSize = 8.2, isBold = false) {
        if (!text) return [];
        const words = text.split(' ');
        const lines = [];
        let currentLine = '';

        for (const word of words) {
            const testLine = currentLine ? currentLine + ' ' + word : word;
            const w = this.measureTextWidth(testLine, fontSize, isBold);
            if (w > maxWidth && currentLine !== '') {
                lines.push(currentLine);
                currentLine = word;
            } else {
                currentLine = testLine;
            }
        }
        if (currentLine) lines.push(currentLine);
        return lines;
    }

    addParagraph(text, fontSize = 8.2, color = [0.15, 0.15, 0.18], indent = 0) {
        const maxWidth = 515 - indent;
        const lines = this.wrapText(text, maxWidth, fontSize, false);
        const lineHeight = fontSize * 1.32;

        for (const line of lines) {
            this.checkSpace(lineHeight);
            this.drawText(line, 40 + indent, this.cursorY, '/F1', fontSize, color);
            this.cursorY -= lineHeight;
        }
        this.cursorY -= 3;
    }

    addBullet(title, text = "", level = 0) {
        const indent = 12 + level * 14;
        const fontSize = 8.0;
        const lineHeight = fontSize * 1.32;
        const maxWidth = 515 - indent;
        const bulletSymbol = level === 0 ? ">" : "-";

        if (!text) {
            const lines = this.wrapText(title, maxWidth, fontSize, false);
            this.checkSpace(lines.length * lineHeight + 2);
            this.drawText(bulletSymbol, 40 + indent - 7, this.cursorY, '/F2', 7.5, [0.12, 0.5, 0.82]);
            for (const line of lines) {
                this.checkSpace(lineHeight);
                this.drawText(line, 40 + indent, this.cursorY, '/F1', fontSize, [0.2, 0.22, 0.26]);
                this.cursorY -= lineHeight;
            }
            this.cursorY -= 2;
            return;
        }

        const prefix = title + ": ";
        const prefixWidth = this.measureTextWidth(prefix, fontSize, true);
        const fullText = prefix + text;
        const lines = this.wrapText(fullText, maxWidth, fontSize, false);

        this.checkSpace(lines.length * lineHeight + 3);
        this.drawText(bulletSymbol, 40 + indent - 7, this.cursorY, '/F2', 7.5, [0.12, 0.5, 0.82]);

        for (let i = 0; i < lines.length; i++) {
            this.checkSpace(lineHeight);
            const line = lines[i];
            if (i === 0) {
                if (line.startsWith(prefix)) {
                    this.drawText(prefix, 40 + indent, this.cursorY, '/F2', fontSize, [0.1, 0.18, 0.32]);
                    const rest = line.substring(prefix.length);
                    this.drawText(rest, 40 + indent + prefixWidth, this.cursorY, '/F1', fontSize, [0.2, 0.22, 0.26]);
                } else if (line.startsWith(title)) {
                    this.drawText(title, 40 + indent, this.cursorY, '/F2', fontSize, [0.1, 0.18, 0.32]);
                    const rest = line.substring(title.length);
                    const tW = this.measureTextWidth(title, fontSize, true);
                    this.drawText(rest, 40 + indent + tW, this.cursorY, '/F1', fontSize, [0.2, 0.22, 0.26]);
                } else {
                    this.drawText(line, 40 + indent, this.cursorY, '/F1', fontSize, [0.2, 0.22, 0.26]);
                }
            } else {
                this.drawText(line, 40 + indent, this.cursorY, '/F1', fontSize, [0.2, 0.22, 0.26]);
            }
            this.cursorY -= lineHeight;
        }
        this.cursorY -= 2;
    }

    addCallout(title, text, type = 'info') {
        let boxColor = [0.94, 0.97, 1.0];
        let borderColor = [0.15, 0.5, 0.85];
        let titleColor = [0.08, 0.28, 0.58];

        if (type === 'warn') {
            boxColor = [1.0, 0.96, 0.91];
            borderColor = [0.92, 0.52, 0.1];
            titleColor = [0.65, 0.32, 0.02];
        } else if (type === 'tip') {
            boxColor = [0.93, 0.98, 0.94];
            borderColor = [0.2, 0.72, 0.35];
            titleColor = [0.1, 0.48, 0.2];
        } else if (type === 'crit') {
            boxColor = [1.0, 0.93, 0.94];
            borderColor = [0.88, 0.22, 0.25];
            titleColor = [0.65, 0.1, 0.15];
        }

        const lines = this.wrapText(text, 495, 7.6, false);
        const h = lines.length * 10 + 21;
        this.checkSpace(h + 7);

        this.drawRect(40, this.cursorY - h, 515, h, boxColor, borderColor, 0.7);
        this.drawRect(40, this.cursorY - h, 3.5, h, borderColor, null);
        this.drawText(title.toUpperCase(), 49, this.cursorY - 11.5, '/F2', 8, titleColor);

        let curY = this.cursorY - 21.5;
        for (const line of lines) {
            this.drawText(line, 49, curY, '/F1', 7.6, [0.18, 0.2, 0.25]);
            curY -= 10;
        }
        this.cursorY -= h + 6;
    }

    addCodeBlock(lines, label = null) {
        const lineHeight = 9.2;
        const headerH = label ? 14 : 0;
        const blockHeight = lines.length * lineHeight + 10 + headerH;
        this.checkSpace(blockHeight + 7);

        if (label) {
            this.drawRect(40, this.cursorY - 13, 515, 13, [0.15, 0.18, 0.24], [0.25, 0.3, 0.4], 0.5);
            this.drawText(label, 48, this.cursorY - 9.5, '/F5', 7, [0.55, 0.82, 1.0]);
        }

        const bodyY = this.cursorY - blockHeight;
        const bodyH = blockHeight - headerH;
        this.drawRect(40, bodyY, 515, bodyH, [0.08, 0.1, 0.14], [0.2, 0.25, 0.34], 0.7);
        this.drawRect(40, bodyY, 3, bodyH, [0.2, 0.6, 0.9], null);

        let curY = this.cursorY - headerH - 8.5;
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const lineNumStr = String(i + 1).padStart(2, ' ');
            this.drawText(lineNumStr, 45, curY, '/F4', 6.6, [0.38, 0.44, 0.5]);

            let textColor = [0.88, 0.92, 0.98];
            if (line.trim().startsWith(';')) {
                textColor = [0.45, 0.68, 0.48];
            } else if (line.includes(':') && !line.includes('EQU') && !line.includes('db') && !line.includes('DEFB')) {
                textColor = [0.96, 0.82, 0.38];
            } else if (line.includes('call') || line.includes('jp') || line.includes('jr') || line.includes('ret')) {
                textColor = [0.38, 0.82, 1.0];
            } else if (line.includes('ld') || line.includes('push') || line.includes('pop') || line.includes('inc') || line.includes('dec')) {
                textColor = [0.92, 0.7, 0.85];
            }
            this.drawText(line, 64, curY, '/F4', 6.8, textColor);
            curY -= lineHeight;
        }
        this.cursorY -= blockHeight + 6;
    }

    addAsciiDiagram(lines, title = null) {
        const lineHeight = 8.8;
        const headerH = title ? 14 : 0;
        const blockHeight = lines.length * lineHeight + 9 + headerH;
        this.checkSpace(blockHeight + 7);

        if (title) {
            this.drawRect(40, this.cursorY - 13, 515, 13, [0.18, 0.22, 0.3], [0.3, 0.38, 0.5], 0.5);
            this.drawText(title, 48, this.cursorY - 9.5, '/F2', 7.2, [0.9, 0.95, 1.0]);
        }

        const bodyY = this.cursorY - blockHeight;
        const bodyH = blockHeight - headerH;
        this.drawRect(40, bodyY, 515, bodyH, [0.96, 0.97, 0.99], [0.75, 0.8, 0.88], 0.7);
        this.drawRect(40, bodyY, 3, bodyH, [0.28, 0.48, 0.78], null);

        let curY = this.cursorY - headerH - 7.5;
        for (const line of lines) {
            this.drawText(line, 47, curY, '/F4', 6.7, [0.1, 0.16, 0.26]);
            curY -= lineHeight;
        }
        this.cursorY -= blockHeight + 6;
    }

    addTable(headers, rows, colWidths, fontSize = 7.2) {
        const lineHeight = fontSize * 1.25;
        const headerRowHeight = 14;

        const drawHeader = () => {
            this.drawRect(40, this.cursorY - headerRowHeight, 515, headerRowHeight, [0.14, 0.24, 0.4], null);
            let curX = 40;
            for (let i = 0; i < headers.length; i++) {
                this.drawText(headers[i], curX + 4, this.cursorY - 10, '/F2', fontSize, [1, 1, 1]);
                curX += colWidths[i];
            }
            this.cursorY -= headerRowHeight;
        };

        this.checkSpace(headerRowHeight + 25);
        drawHeader();

        for (let r = 0; r < rows.length; r++) {
            const cellLinesPerCol = [];
            let maxLines = 1;

            for (let c = 0; c < rows[r].length; c++) {
                const cellText = String(rows[r][c]);
                const maxColTextW = colWidths[c] - 8;
                const isBold = (c === 0);
                const lines = this.wrapText(cellText, maxColTextW, fontSize, isBold);
                cellLinesPerCol.push(lines);
                if (lines.length > maxLines) {
                    maxLines = lines.length;
                }
            }

            const rowHeight = Math.max(13, maxLines * lineHeight + 5);

            if (this.cursorY - rowHeight < this.margin + 30) {
                this.addPage(this.currentSectionTitle);
                drawHeader();
            }

            const rowBg = r % 2 === 0 ? [0.98, 0.98, 0.99] : [0.92, 0.94, 0.97];
            this.drawRect(40, this.cursorY - rowHeight, 515, rowHeight, rowBg, [0.8, 0.84, 0.9], 0.35);

            let curX = 40;
            for (let c = 0; c < cellLinesPerCol.length; c++) {
                const lines = cellLinesPerCol[c];
                const font = (c === 0) ? '/F2' : '/F1';
                let cellY = this.cursorY - 3.5 - fontSize;

                for (const l of lines) {
                    this.drawText(l, curX + 4, cellY, font, fontSize, [0.15, 0.18, 0.24]);
                    cellY -= lineHeight;
                }
                curX += colWidths[c];
            }

            this.cursorY -= rowHeight;
        }
        this.cursorY -= 6;
    }

    buildPDF(outputPath) {
        if (this.currentPage) {
            this.endPage();
        }

        const font1 = this.addObject(`<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>`);
        const font2 = this.addObject(`<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>`);
        const font3 = this.addObject(`<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Oblique /Encoding /WinAnsiEncoding >>`);
        const font4 = this.addObject(`<< /Type /Font /Subtype /Type1 /BaseFont /Courier /Encoding /WinAnsiEncoding >>`);
        const font5 = this.addObject(`<< /Type /Font /Subtype /Type1 /BaseFont /Courier-Bold /Encoding /WinAnsiEncoding >>`);

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
    /F5 ${font5} 0 R
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
        console.log(`PDF generato con successo: ${outputPath} (${this.pages.length} pagine, ${pdf.length} byte)`);
    }
}

module.exports = { PDFBuilder };
