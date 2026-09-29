# PR draft (do not open without operator go-ahead)

## Title

fix(sensors): keep text contrast against the real background

## Body

### Problem

The sensors chip colors each metric from theme tokens (`success_color`,
`warning_color`, `error_color`, `accent_color`) without looking at what is
behind it. On a translucent panel over a bright wallpaper, or a light theme
over a dark surface, the text is close to invisible. The popover dims values
with `dim-label` opacity, which lowers contrast further.

Measured with the WCAG formula for the colors seen in the "before" shots:

| Text on background                          | Ratio |
|---------------------------------------------|-------|
| red accent (0.88, 0.10, 0.10) on sky blue   | 1.7   |
| green ok (0.20, 0.82, 0.48) on sky blue     | 1.4   |
| green ok on a light panel (0.96)            | 1.8   |
| dim-label value on a light popover          | 3.8   |

### Change

- `sensors/contrast.vala`: pure WCAG luminance and contrast math, lightness
  shifting that keeps the theme hue, a muted tone, and a median helper.
- The chip and popover sample the pixels around themselves (offscreen render
  of the native surface) and derive neutral, muted, ok, warning, critical and
  accent colors that reach 7:1, with 4.5:1 as the floor.
- A translucent surface (mean alpha below 0.95) gets its own backing so the
  result does not depend on the wallpaper.
- Warning and critical also differ by glyph and weight, not hue alone.
- Re-evaluated on `gtk-theme-name`, dark-preference and color-scheme
  changes, panel redraw (150 ms debounce) and popover open. No polling.
- One concern only. No libadwaita. Only GTK4 and libsingularity.

### Test

`meson test -C build sensors-contrast`: 7 cases over 10 backgrounds (white,
black, light gray, dark gray, mid-gray, blue, cream, two translucent
composites). Every neutral, muted and semantic color is asserted at 4.5:1 or
better; the white and black extremes are asserted at 7:1.

```
1/1 sensors-contrast OK
Ok: 1  Fail: 0
```

### Verified

- Two x86_64 laptops (AMD Navi14, GTK 4.22, labwc): dark and light theme,
  live theme switch without restart. Screenshots in
  `docs/sensors-contrast/` (before-dark, before-light, after-dark,
  after-light).
- Unit test also passes natively on aarch64 (Debian trixie, GTK 4.18).

### Not verified

- Built against libsingularity as shipped on the test machines, not a fresh
  upstream libsingularity build.
- Warning and critical states were only exercised by the unit test; the test
  machines never reached those readings.
- A translucent panel still cannot see the wallpaper; the backing is chosen
  from the theme background polarity.

AI assistance: disclosed
