"""Render compact SVG previews from the actual Icarus VCD recordings."""
from pathlib import Path
import html
import re
import sys


SIGNALS = {
    "Piano": ["rst", "key", "selected_hz", "piezo"],
    "Traffic": ["rst", "flicker", "red", "yellow", "green", "left", "walk_red", "walk_green"],
    "ADC": ["rst", "channel", "cs_n", "sclk", "din", "adc_dout", "sample", "valid", "led"],
}


def read_vcd(path, names):
    lines = path.read_text(encoding="ascii").splitlines()
    scopes = []
    identifiers = {}
    widths = {}
    events = {name: [] for name in names}
    in_header = True
    time = 0
    for line in lines:
        words = line.split()
        if in_header:
            if len(words) >= 3 and words[0] == "$scope":
                scopes.append(words[2])
            elif words and words[0] == "$upscope":
                scopes.pop()
            elif len(words) >= 5 and words[0] == "$var" and len(scopes) == 1:
                width, ident, name = int(words[2]), words[3], words[4]
                if name in events:
                    identifiers[ident] = name
                    widths[name] = width
            elif words and words[0] == "$enddefinitions":
                in_header = False
            continue
        if line.startswith("#"):
            time = int(line[1:])
        elif line.startswith("b"):
            value, ident = line[1:].split()
            if ident in identifiers:
                events[identifiers[ident]].append((time, value.lower()))
        elif line and line[0] in "01xXzZ":
            ident = line[1:]
            if ident in identifiers:
                events[identifiers[ident]].append((time, line[0].lower()))
    missing = [name for name in names if name not in widths]
    if missing:
        raise ValueError(f"Missing VCD signals in {path}: {missing}")
    return events, widths, time


def label(value, width):
    if any(ch in value for ch in "xz"):
        return value.upper()
    return f"0x{int(value, 2):0{(width + 3) // 4}X}" if width > 1 else value


def render(lab, folder):
    names = SIGNALS[lab]
    events, widths, duration = read_vcd(folder / "wave.vcd", names)
    width, left, right, top, row = 1600, 205, 45, 105, 61
    height = top + row * len(names) + 70
    plot_width = width - left - right
    x = lambda t: left + plot_width * t / max(duration, 1)
    out = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        '<rect width="100%" height="100%" fill="#111827"/>',
        '<style>text{font-family:Consolas,monospace;fill:#e5e7eb}.title{font-size:26px;font-weight:bold}.small{font-size:15px;fill:#9ca3af}.name{font-size:18px;fill:#d1d5db}.value{font-size:13px;fill:#f8fafc}</style>',
        f'<text class="title" x="28" y="39">{lab} — behavioral simulation</text>',
        '<text class="small" x="28" y="66">Generated from wave.vcd; horizontal scale in ns</text>',
    ]
    for tick in range(11):
        t = duration * tick / 10
        px = x(t)
        out.append(f'<line x1="{px:.1f}" y1="{top-22}" x2="{px:.1f}" y2="{height-65}" stroke="#273449"/>')
        out.append(f'<text class="small" x="{px:.1f}" y="{height-35}" text-anchor="middle">{t/1000:.0f}</text>')
    for index, name in enumerate(names):
        y = top + index * row
        out.append(f'<text class="name" x="28" y="{y+21}">{html.escape(name)}</text>')
        out.append(f'<line x1="{left}" y1="{y+45}" x2="{width-right}" y2="{y+45}" stroke="#334155"/>')
        raw = events[name]
        values = []
        for t, value in raw:
            if values and values[-1][0] == t:
                values[-1] = (t, value)
            elif not values or values[-1][1] != value:
                values.append((t, value))
        if widths[name] == 1:
            color = "#4ade80" if name not in ("rst", "cs_n") else "#fbbf24"
            points = []
            previous = "x"
            for t, value in values:
                high = y + 7 if value == "1" else y + 38
                if points:
                    old_high = y + 7 if previous == "1" else y + 38
                    points.append(f"{x(t):.1f},{old_high}")
                points.append(f"{x(t):.1f},{high}")
                previous = value
            if points:
                points.append(f"{x(duration):.1f},{y+7 if previous == '1' else y+38}")
                out.append(f'<polyline points="{" ".join(points)}" fill="none" stroke="{color}" stroke-width="2.5"/>')
        else:
            for i, (t, value) in enumerate(values):
                end = values[i + 1][0] if i + 1 < len(values) else duration
                x1, x2 = x(t), x(end)
                if x2 - x1 < 1:
                    continue
                out.append(f'<rect x="{x1:.1f}" y="{y+8}" width="{x2-x1:.1f}" height="29" fill="#123d50" stroke="#22d3ee"/>')
                if x2 - x1 > 42:
                    out.append(f'<text class="value" x="{x1+5:.1f}" y="{y+28}">{html.escape(label(value,widths[name]))}</text>')
    out.append('</svg>')
    (folder / "waveform.svg").write_text("\n".join(out), encoding="utf-8")


if __name__ == "__main__":
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent
    for lab in SIGNALS:
        render(lab, root / lab)
        print(root / lab / "waveform.svg")
