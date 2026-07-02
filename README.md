# Mini Calendar

A compact and highly customizable calendar widget for KDE Plasma 6.

Mini Calendar focuses on a clean desktop look, hover-only navigation controls,
theme presets, transparency, glass styling, named custom presets, locale-aware
calendar formatting, and adaptive text contrast.

## Features

- Compact month calendar for KDE Plasma.
- Rounded design with hover-only controls.
- Previous and next month navigation.
- Month and year picker.
- Today shortcut.
- Light, dark, and automatic time-based theme mode.
- Appearance presets: Default, Dracula, Nord, Gruvbox, Solarized, Catppuccin,
  Tokyo Night, Everforest, One Dark, Rose Pine, and Material Ocean.
- Named saved presets.
- Transparent background with opacity control.
- Glass effect with intensity and light/dark tone controls.
- Adaptive text contrast for readable transparent and glass styles.
- Locale-aware month names, weekday initials, and first day of week.
- Calendar locale selector with System default plus Portuguese, English,
  Spanish, French, German, Italian, Dutch, Polish, Russian, Turkish, Chinese,
  Japanese, Korean, Arabic, Hindi, Indonesian, and Vietnamese options.

## Requirements

- KDE Plasma 6
- `kpackagetool6`

## Install

From the parent directory:

```bash
kpackagetool6 --type Plasma/Applet --install ./com.vinicius.minicalendar
```

Or from inside this repository:

```bash
./install.sh
```

After installing, add the widget from Plasma's widget picker by searching for
`Mini Calendar`.

## Update

```bash
kpackagetool6 --type Plasma/Applet --upgrade ./com.vinicius.minicalendar
```

Or from inside this repository:

```bash
./install.sh --upgrade
```

Restart Plasma Shell if the old QML remains cached:

```bash
kquitapp6 plasmashell
kstart plasmashell
```

## Package

Create a `.plasmoid` archive for distribution:

```bash
./package.sh
```

The generated package will be written to `dist/com.vinicius.minicalendar.plasmoid`.

## Appearance

Open the widget configuration with right click:

```text
Configure Mini Calendar > Appearance
```

Available options:

- Theme: Automatic, Light, Dark.
- Preset: Default, Dracula, Nord, Gruvbox, Solarized, Catppuccin, Tokyo Night,
  Everforest, One Dark, Rose Pine, Material Ocean, or a saved preset.
- Named custom presets.
- Transparent background.
- Opacity.
- Glass effect.
- Glass intensity.
- Glass tone.
- Text contrast: Automatic, High, Soft.
- Calendar locale: System default or a manually selected locale.

Non-default built-in presets use a curated dark mode to avoid low-contrast light
theme combinations.

## Development

The applet entry point is:

```text
contents/ui/main.qml
```

Configuration UI:

```text
contents/ui/configGeneral.qml
```

Configuration schema:

```text
contents/config/main.xml
```

## License

MIT
