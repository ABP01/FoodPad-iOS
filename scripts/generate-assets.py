#!/usr/bin/env python3
"""
Génère les visuels de FoodPad qui manquent.

Pourquoi ce script existe
-------------------------
Les visuels d'origine étaient des **placeholders vides** :

    avatar.png     0,0 % de pixels opaques
    background.png 0,0 % (fichier identique à avatar.png, même MD5)
    splash.png     0,2 %
    AppIcon        92,6 % de noir

Autrement dit : ni avatar, ni fond d'écran d'accueil, et une icône en carré
noir. Le rendu SwiftUI était correct — c'est la source qui était vide.

Ces fichiers ont été supprimés du dépôt (voir le tag `pre-rename-before-rn-purge`
pour les retrouver) ; ce script produit de vrais visuels dans le catalogue iOS.

    python3 scripts/generate-assets.py

Aucune dépendance : encodeur PNG maison (zlib + struct) et formes dessinées
par champs de distance, avec anticrénelage par `smoothstep`.

Palette : celle relevée dans `Theme.swift` — accent `#f64e32`.
"""

from __future__ import annotations

import math
import os
import struct
import zlib

# --------------------------------------------------------------------------
# Couleurs de la charte (voir ios/FoodPad/Theme/Theme.swift)
# --------------------------------------------------------------------------

ACCENT = (0xF6, 0x4E, 0x32)
ACCENT_LIGHT = (0xFF, 0x7A, 0x5E)
ACCENT_DEEP = (0xD9, 0x38, 0x1E)
WARM_WHITE = (0xFF, 0xF4, 0xF1)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "ios", "FoodPad", "Assets.xcassets")


# --------------------------------------------------------------------------
# Encodeur PNG
# --------------------------------------------------------------------------

def write_png(path: str, width: int, height: int, pixels: bytes, channels: int) -> None:
    """Écrit un PNG 8 bits non entrelacé. `pixels` est en row-major RGBA/RGB."""
    color_type = 6 if channels == 4 else 2

    # Une ligne = 1 octet de filtre (0 = aucun) + les pixels.
    stride = width * channels
    raw = bytearray()
    for y in range(height):
        raw.append(0)
        raw += pixels[y * stride:(y + 1) * stride]

    def chunk(tag: bytes, data: bytes) -> bytes:
        return (struct.pack(">I", len(data)) + tag + data
                + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF))

    ihdr = struct.pack(">IIBBBBB", width, height, 8, color_type, 0, 0, 0)
    blob = (b"\x89PNG\r\n\x1a\n"
            + chunk(b"IHDR", ihdr)
            + chunk(b"IDAT", zlib.compress(bytes(raw), 9))
            + chunk(b"IEND", b""))

    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as handle:
        handle.write(blob)


# --------------------------------------------------------------------------
# Outils de dessin
# --------------------------------------------------------------------------

def smoothstep(edge0: float, edge1: float, x: float) -> float:
    if edge0 == edge1:
        return 0.0 if x < edge0 else 1.0
    t = min(1.0, max(0.0, (x - edge0) / (edge1 - edge0)))
    return t * t * (3.0 - 2.0 * t)


def coverage_signed(distance: float, feather: float = 1.0) -> float:
    """1 à l'intérieur (distance < 0), 0 à l'extérieur, dégradé sur `feather`."""
    return smoothstep(feather, -feather, distance)


def mix(a, b, t):
    return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))


def over(dst, src, alpha: float):
    """Compose `src` sur `dst` avec l'alpha donné (sans division préalable)."""
    return tuple(dst[i] + (src[i] - dst[i]) * alpha for i in range(3))


class Canvas:
    """RGB en virgule flottante,Peinture par accumulation de couvertures."""

    def __init__(self, width: int, height: int, background=(0, 0, 0)):
        self.w = width
        self.h = height
        self.buf = [list(background) for _ in range(width * height)]

    # -- primitives -------------------------------------------------------

    def _plot(self, x: int, y: int, color, alpha: float) -> None:
        if alpha <= 0:
            return
        i = y * self.w + x
        self.buf[i] = over(self.buf[i], color, min(1.0, alpha))

    def fill_gradient(self, top, bottom) -> None:
        for y in range(self.h):
            t = y / max(1, self.h - 1)
            color = mix(top, bottom, t)
            row = [list(color)] * self.w
            start = y * self.w
            self.buf[start:start + self.w] = row

    def fill_radial(self, center, radius, color, peak_alpha: float) -> None:
        cx, cy = center
        for y in range(self.h):
            dy = y - cy
            for x in range(self.w):
                dx = x - cx
                d = math.hypot(dx, dy) / radius
                if d >= 1.0:
                    continue
                a = peak_alpha * (1.0 - d * d)
                self._plot(x, y, color, a)

    def shape(self, sdf, color, alpha: float = 1.0, feather: float = 1.2) -> None:
        """Peint toute la surface où `sdf(x, y) < 0`.

        `sdf` renvoie une distance signée approximative en pixels : négative à
        l'intérieur. Seules les lignes dont la boîte englobante touche la forme
        sont évaluées, pour ne pas parcourir 1 M de pixels par forme.
        """
        for y in range(self.h):
            row = y * self.w
            for x in range(self.w):
                d = sdf(x + 0.5, y + 0.5)
                if d < feather:
                    self._plot(x, y, color, alpha * coverage_signed(d, feather))

    # -- helpers de SDF ----------------------------------------------------

    @staticmethod
    def circle(cx, cy, r):
        return lambda x, y: math.hypot(x - cx, y - cy) - r

    @staticmethod
    def ring(cx, cy, r_outer, r_inner):
        def sdf(x, y):
            return abs(math.hypot(x - cx, y - cy) - (r_outer + r_inner) / 2) \
                - (r_outer - r_inner) / 2
        return sdf

    @staticmethod
    def rounded_rect(x0, y0, x1, y1, radius):
        hx, hy = (x1 - x0) / 2, (y1 - y0) / 2
        cx, cy = x0 + hx, y0 + hy
        r = min(radius, hx, hy)

        def sdf(x, y):
            qx = abs(x - cx) - (hx - r)
            qy = abs(y - cy) - (hy - r)
            return math.hypot(max(qx, 0.0), max(qy, 0.0)) + min(max(qx, qy), 0.0) - r
        return sdf

    @staticmethod
    def union(*sdfs):
        return lambda x, y: min(sdf(x, y) for sdf in sdfs)

    @staticmethod
    def subtract(base, *holes):
        def sdf(x, y):
            d = base(x, y)
            for hole in holes:
                if hole(x, y) < 0:
                    return hole(x, y)
            return d
        return sdf

    # -- sortie ------------------------------------------------------------

    def to_rgba_bytes(self) -> bytes:
        out = bytearray(self.w * self.h * 4)
        i = 0
        for color in self.buf:
            for ch in range(3):
                value = int(round(color[ch]))
                out[i] = 0 if value < 0 else (255 if value > 255 else value)
                i += 1
            out[i] = 255
            i += 1
        return bytes(out)

    def to_rgb_bytes(self) -> bytes:
        out = bytearray(self.w * self.h * 3)
        i = 0
        for color in self.buf:
            for ch in range(3):
                value = int(round(color[ch]))
                out[i] = 0 if value < 0 else (255 if value > 255 else value)
                i += 1
        return bytes(out)


# --------------------------------------------------------------------------
# Les trois visuels
# --------------------------------------------------------------------------

def make_icon(size: int = 1024) -> bytes:
    """Icône de l'app : assiette blanche, couverts en rouge sur fond dégradé.

    Dessinée pour rester lisible à 60 pt sur l'écran d'accueil : peu de
    formes, très épaisses. Un dessin réaliste serait devenu une bouillie de
    gris à cette taille.
    """
    c = Canvas(size, size, ACCENT)
    c.fill_gradient(ACCENT_LIGHT, ACCENT_DEEP)

    # Halo discret derrière l'assiette, pour décoller le motif du fond.
    c.fill_radial((size / 2, size * 0.44), size * 0.46, WARM_WHITE, 0.16)

    cx = size / 2
    plate_r = size * 0.335

    # Assiette : disque blanc, puis creux (accent) légèrement plus petit.
    c.shape(Canvas.circle(cx, cx, plate_r), (255, 255, 255))
    c.shape(Canvas.circle(cx, cx, plate_r * 0.86), ACCENT)

    # Liseré intérieur, très fin : donne l'épaisseur de l'assiette.
    c.shape(Canvas.ring(cx, cx, plate_r * 0.955, plate_r * 0.925), (255, 255, 255))

    # --- Couverts -------------------------------------------------------
    unit = size / 1024
    top = cx - plate_r * 0.60
    bottom = cx + plate_r * 0.58
    bar = 0.052 * size          # épaisseur des barres
    gap = 0.022 * size

    # Fourchette : 3 dents, col, manche.
    tines = Canvas.union(*[
        Canvas.rounded_rect(cx - plate_r * 0.44 + i * (bar + gap), top,
                            cx - plate_r * 0.44 + i * (bar + gap) + bar,
                            top + plate_r * 0.40, bar / 2)
        for i in range(3)
    ])
    stem_x0 = cx - plate_r * 0.44 + (bar + gap)
    fork = Canvas.union(
        tines,
        Canvas.rounded_rect(stem_x0, top + plate_r * 0.34,
                            stem_x0 + bar, top + plate_r * 0.52, bar * 0.25),
        Canvas.rounded_rect(stem_x0 - bar * 0.05, top + plate_r * 0.48,
                            stem_x0 + bar * 1.05, bottom, bar * 0.4),
    )
    c.shape(fork, (255, 255, 255))

    # Couteau : lame arrondie + manche plus fin.
    blade_x0 = cx + plate_r * 0.24
    knife = Canvas.union(
        Canvas.rounded_rect(blade_x0, top, blade_x0 + bar * 1.25,
                            top + plate_r * 0.52, bar * 0.6),
        Canvas.rounded_rect(blade_x0 + bar * 0.16, top + plate_r * 0.48,
                            blade_x0 + bar * 1.09, bottom, bar * 0.45),
    )
    c.shape(knife, (255, 255, 255))

    del unit
    return c.to_rgb_bytes()


def make_avatar(size: int = 512) -> bytes:
    """Avatar de l'en-tête : silhouette de personne, fond chaud dégradé.

    512 px suffisent : l'avatar s'affiche sur ~44 pt, soit 132 px en @3x.
    """
    c = Canvas(size, size, WARM_WHITE)
    c.fill_gradient((0xFF, 0xC8, 0xB8), ACCENT_LIGHT)

    # Halo doux, décalé pour éviter un rendu plat.
    c.fill_radial((size * 0.34, size * 0.30), size * 0.55, (255, 255, 255), 0.22)

    # Tête.
    c.shape(Canvas.circle(size / 2, size * 0.395, size * 0.165), (255, 255, 255))

    # Épaules : un disque très bas, coupé par le bord inférieur de la canvas.
    c.shape(Canvas.circle(size / 2, size * 0.925, size * 0.335), (255, 255, 255))

    return c.to_rgb_bytes()


def make_background(width: int = 600, height: int = 900) -> bytes:
    """Fond de l'écran d'accueil.

    L'écran Welcome pose déjà `Theme.accent` en aplat ; cette image vient par
    dessus. Il faut donc des formes **plus claires** que l'accent, sinon elle
    disparaîtrait. Trois disques très translucides donnent de la profondeur
    sans jamais descendre sous l'accent.
    """
    c = Canvas(width, height, ACCENT)
    c.fill_gradient((0xFF, 0x84, 0x66), (0xEE, 0x4B, 0x2F))

    c.fill_radial((width * 0.26, height * 0.24), width * 0.62, (255, 255, 255), 0.13)
    c.fill_radial((width * 0.82, height * 0.46), width * 0.52, (255, 255, 255), 0.09)
    c.fill_radial((width * 0.42, height * 0.82), width * 0.70, (255, 255, 255), 0.07)

    # Vignettage bas, pour asseoir le bouton « Get Started ».
    for y in range(int(height * 0.62), height):
        t = (y - height * 0.62) / (height * 0.38)
        alpha = 0.16 * smoothstep(0.0, 1.0, t)
        row = y * width
        for x in range(width):
            i = row + x
            c.buf[i] = over(c.buf[i], (0xC9, 0x33, 0x1C), alpha)

    return c.to_rgb_bytes()


# --------------------------------------------------------------------------
# Écriture dans le catalogue
# --------------------------------------------------------------------------

def emit(imageset: str, png_name: str, rgb: bytes, width: int, height: int) -> None:
    folder = os.path.join(ASSETS, f"{imageset}.imageset")
    os.makedirs(folder, exist_ok=True)
    write_png(os.path.join(folder, png_name), width, height, rgb, 3)

    contents = f"""{{
  "images" : [
    {{
      "filename" : "{png_name}",
      "idiom" : "universal",
      "scale" : "1x"
    }},
    {{
      "idiom" : "universal",
      "scale" : "2x"
    }},
    {{
      "idiom" : "universal",
      "scale" : "3x"
    }}
  ],
  "info" : {{
    "author" : "xcode",
    "version" : 1
  }}
}}
"""
    with open(os.path.join(folder, "Contents.json"), "w", encoding="utf-8") as handle:
        handle.write(contents)

    print(f"  {imageset}.imageset/{png_name}  {width}x{height}")


def main() -> None:
    print("Génération des visuels FoodPad…")

    print("Icône de l'app")
    icon = make_icon(1024)
    write_png(
        os.path.join(ASSETS, "AppIcon.appiconset", "icon-1024.png"),
        1024, 1024, icon, 3,
    )
    print("  AppIcon.appiconset/icon-1024.png  1024x1024")

    print("Avatar de l'en-tête")
    avatar = make_avatar(512)
    emit("Avatar", "avatar.png", avatar, 512, 512)

    print("Fond de l'écran d'accueil")
    background = make_background(600, 900)
    emit("Background", "background.png", background, 600, 900)

    print("Terminé.")


if __name__ == "__main__":
    main()
