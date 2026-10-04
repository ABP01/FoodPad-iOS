#!/usr/bin/env python3
"""Vérifie qu'une capture d'écran iOS contient réellement du contenu.

Décode le PNG sans dépendance externe (zlib + struct), puis rapporte :
- la répartition des couleurs dominantes
- le nombre de couleurs uniques (un écran vide = 1-2)
- un échantillon de pixels pour repérer la présence d'accent #f64e32
"""
import sys
import zlib
import struct
from collections import Counter


def read_png(path):
    with open(path, "rb") as fh:
        data = fh.read()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("pas un PNG")

    pos = 8
    idat = b""
    width = height = bit_depth = color_type = None
    while pos < len(data):
        (length,) = struct.unpack(">I", data[pos:pos + 4])
        ctype = data[pos + 4:pos + 8]
        chunk = data[pos + 8:pos + 8 + length]
        if ctype == b"IHDR":
            width, height, bit_depth, color_type = struct.unpack(">IIBB", chunk[:10])
        elif ctype == b"IDAT":
            idat += chunk
        elif ctype == b"IEND":
            break
        pos += 12 + length

    if bit_depth != 8:
        raise ValueError(f"profondeur non gérée : {bit_depth}")

    channels = {0: 1, 2: 3, 4: 2, 6: 4}[color_type]
    raw = zlib.decompress(idat)
    stride = width * channels

    # Annule le filtrage PNG ligne par ligne.
    out = bytearray()
    prev = bytearray(stride)
    idx = 0
    for _ in range(height):
        filt = raw[idx]
        line = bytearray(raw[idx + 1:idx + 1 + stride])
        idx += 1 + stride

        if filt == 1:
            for i in range(channels, stride):
                line[i] = (line[i] + line[i - channels]) & 0xFF
        elif filt == 2:
            for i in range(stride):
                line[i] = (line[i] + prev[i]) & 0xFF
        elif filt == 3:
            for i in range(stride):
                left = line[i - channels] if i >= channels else 0
                line[i] = (line[i] + ((left + prev[i]) >> 1)) & 0xFF
        elif filt == 4:
            for i in range(stride):
                a = line[i - channels] if i >= channels else 0
                b = prev[i]
                c = prev[i - channels] if i >= channels else 0
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pred = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[i] = (line[i] + pred) & 0xFF

        out += line
        prev = line

    return width, height, channels, bytes(out)


def main(path):
    width, height, channels, pixels = read_png(path)
    print(f"image      : {width}x{height}, {channels} canaux")

    # Échantillonne une grille pour garder le décodage rapide.
    step = max(1, min(width, height) // 120)
    counter = Counter()
    for y in range(0, height, step):
        row = y * width * channels
        for x in range(0, width, step):
            o = row + x * channels
            counter[pixels[o:o + 3]] += 1

    total = sum(counter.values())
    unique = len(counter)
    print(f"echantillon: {total} px, {unique} couleurs uniques")

    if unique <= 3:
        print("\nVERDICT: ecran quasi uniforme -> probablement vide ou bloque")
    else:
        print("\nVERDICT: ecran peuple")

    print("\nCouleurs dominantes :")
    for rgb, count in counter.most_common(8):
        pct = 100 * count / total
        print(f"  #{rgb[0]:02X}{rgb[1]:02X}{rgb[2]:02X}  {pct:5.1f} %")

    accent = (0xF6, 0x4E, 0x32)
    hits = sum(c for rgb, c in counter.items()
               if abs(rgb[0] - accent[0]) < 26
               and abs(rgb[1] - accent[1]) < 26
               and abs(rgb[2] - accent[2]) < 26)
    pct = 100 * hits / total
    print(f"\naccent #f64e32 : {pct:.2f} % de l'ecran"
          + ("  -> couleur d'accent bien presente" if pct > 0.4 else "  -> ABSENT"))

    # Profil vertical : 12 bandes horizontales, avec la luminance moyenne et
    # la part de pixels sombres. Permet de localiser une zone vide (bande
    # uniformement claire) ou un dégradé (bande progressivement sombre).
    def luma(rgb):
        return 0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2]

    print("\nProfil vertical (12 bandes, haut -> bas) :")
    bands = 12
    band_h = height // bands
    for b in range(bands):
        y0, y1 = b * band_h, (b + 1) * band_h
        lumas, darks = [], 0
        count_in_band = 0
        for y in range(y0, y1, 7):
            row = y * width * channels
            for x in range(0, width, 11):
                o = row + x * channels
                px = pixels[o:o + 3]
                lumas.append(luma(px))
                if luma(px) < 90:
                    darks += 1
                count_in_band += 1
        if not lumas:
            continue
        mean = sum(lumas) / len(lumas)
        dark_pct = 100 * darks / count_in_band
        bar = "#" * int(dark_pct / 4)
        label = f"{100*b/bands:3.0f}-{(b+1)*100//bands:3.0f}%"
        print(f"  {label} %  luminance {mean:5.1f}  sombre {dark_pct:5.1f} %  {bar}")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "docs/phase1-design-system.png")
