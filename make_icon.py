#!/usr/bin/env python3
"""Generate Sudoku app icon: clean 9×9 grid on blue gradient, macOS style."""

from PIL import Image, ImageDraw, ImageFont
import os

SIZE = 1024

def lerp_color(c1, c2, t):
    return tuple(int(a + (b - a) * t) for a, b in zip(c1, c2))

def grid_bg_at(y, size, top=(21, 101, 192), bottom=(10, 46, 110)):
    t = y / (size - 1)
    return lerp_color(top, bottom, t)

def make_icon(size=SIZE):
    radius = int(size * 0.2237)

    # ── Build gradient as RGB, composite later ────────────────────────────
    base = Image.new("RGB", (size, size))
    for y in range(size):
        r, g, b = grid_bg_at(y, size)
        ImageDraw.Draw(base).line([(0, y), (size - 1, y)], fill=(r, g, b))

    draw = ImageDraw.Draw(base)

    # ── Grid geometry ─────────────────────────────────────────────────────
    margin  = int(size * 0.11)
    grid_px = size - 2 * margin
    cell    = grid_px / 9

    puzzle = [
        [5, 3, 0,  0, 7, 0,  0, 0, 0],
        [6, 0, 0,  1, 9, 5,  0, 0, 0],
        [0, 9, 8,  0, 0, 0,  0, 6, 0],

        [8, 0, 0,  0, 6, 0,  0, 0, 3],
        [4, 0, 0,  8, 0, 3,  0, 0, 1],
        [7, 0, 0,  0, 2, 0,  0, 0, 6],

        [0, 6, 0,  0, 0, 0,  2, 8, 0],
        [0, 0, 0,  4, 1, 9,  0, 0, 5],
        [0, 0, 0,  0, 8, 0,  0, 7, 9],
    ]

    # A few accent cells (amber) — simulate "selected" or "just placed" digit
    accent_cells = {(0, 4), (4, 1)}  # (row, col) of cells to highlight

    # Draw accent cell backgrounds
    for (row, col) in accent_cells:
        x0 = int(margin + col * cell) + 1
        y0 = int(margin + row * cell) + 1
        x1 = int(margin + (col + 1) * cell) - 1
        y1 = int(margin + (row + 1) * cell) - 1
        # Blend amber into the gradient background
        n_rows = y1 - y0
        for py in range(n_rows):
            abs_y = y0 + py
            bg = grid_bg_at(abs_y, size)
            amber = (255, 193, 7)
            alpha = 0.78
            blended = tuple(int(bg[i] * (1 - alpha) + amber[i] * alpha) for i in range(3))
            draw.line([(x0, abs_y), (x1, abs_y)], fill=blended)

    # ── Thin cell lines ───────────────────────────────────────────────────
    thin = max(1, int(size * 0.0018))
    thin_rgba = (200, 220, 255)
    for i in range(1, 9):
        if i % 3 == 0:
            continue
        x = int(margin + i * cell)
        y = int(margin + i * cell)
        # Blend thin lines at ~25% opacity
        for px in range(margin, margin + grid_px):
            def blend_line(pos, horiz):
                orig = base.getpixel((px, x) if horiz else (x, px))
                return tuple(int(orig[j] * 0.75 + thin_rgba[j] * 0.25) for j in range(3))
            if thin == 1:
                draw.point((px, x), fill=blend_line(px, True))
                draw.point((x, px), fill=blend_line(px, False))
            else:
                draw.line([(x, margin), (x, margin + grid_px)], fill=(170, 200, 240), width=thin)
                draw.line([(margin, y), (margin + grid_px, y)], fill=(170, 200, 240), width=thin)
                break

    # ── Thick box lines ───────────────────────────────────────────────────
    thick = max(2, int(size * 0.0045))
    for i in range(0, 10):
        if i % 3 == 0:
            x = int(margin + i * cell)
            y = int(margin + i * cell)
            draw.line([(x, margin), (x, margin + grid_px)], fill=(240, 248, 255), width=thick)
            draw.line([(margin, y), (margin + grid_px, y)], fill=(240, 248, 255), width=thick)

    # ── Numbers ───────────────────────────────────────────────────────────
    font_size = int(cell * 0.54)
    font = None
    for path in [
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/SFNSRounded.ttf",
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/SFNSDisplay.ttf",
        "/Library/Fonts/Arial.ttf",
    ]:
        if os.path.exists(path):
            try:
                font = ImageFont.truetype(path, font_size)
                break
            except Exception:
                pass
    if font is None:
        font = ImageFont.load_default()

    for row in range(9):
        for col in range(9):
            n = puzzle[row][col]
            if n == 0:
                continue
            cx = margin + col * cell + cell / 2
            cy = margin + row * cell + cell / 2
            s = str(n)
            bbox = font.getbbox(s)
            tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
            tx = cx - tw / 2 - bbox[0]
            ty = cy - th / 2 - bbox[1]

            if (row, col) in accent_cells:
                color = (30, 60, 140)   # dark blue on amber
            else:
                color = (245, 250, 255)
            draw.text((tx, ty), s, font=font, fill=color)

    # ── Apply rounded rect mask → RGBA ───────────────────────────────────
    img = base.convert("RGBA")
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    img.putalpha(mask)

    return img


def main():
    out_dir = "sudoku_app/macos/Runner/Assets.xcassets/AppIcon.appiconset"
    icon = make_icon(SIZE)
    for s in [16, 32, 64, 128, 256, 512, 1024]:
        resized = icon.resize((s, s), Image.LANCZOS)
        path = os.path.join(out_dir, f"app_icon_{s}.png")
        resized.save(path, "PNG")
        print(f"  {s}px → {path}")
    print("Done.")


if __name__ == "__main__":
    main()
