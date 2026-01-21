# Ghostty Configuration

## Display Switching

Different font/cell settings for laptop vs external monitor:

- `dock` - switch to external monitor settings
- `undock` - switch to laptop settings

These commands swap the `display` symlink and reload the config automatically.

| File | Description |
|------|-------------|
| `config` | Main config, includes `display` via `config-file` |
| `display` | Symlink to active display config |
| `display.docked` | External monitor: smaller font, no cell adjustments |
| `display.laptop` | Laptop: larger font, wider/taller cells |

## Useful Commands

- `ghostty-reload-config` - reload config without leaving terminal
- `ghostty +list-themes` - list available themes
- `ghostty +list-fonts` - list available fonts
- `ghostty +show-config` - show current config

## Background Image (1.2.0+)

| Option | Default | Description |
|--------|---------|-------------|
| `background-image` | - | Path to PNG or JPEG file |
| `background-image-opacity` | `1.0` | Opacity relative to `background-opacity` |
| `background-image-position` | `center` | `top-left`, `top-center`, `top-right`, `center-left`, `center`, `center-right`, `bottom-left`, `bottom-center`, `bottom-right` |
| `background-image-fit` | `contain` | `contain`, `cover`, `stretch`, `none` |
| `background-image-repeat` | `false` | Tile the image if it doesn't fill the terminal |

Example:
```
background-image = ~/Pictures/terminal-bg.png
background-image-opacity = 0.3
background-image-fit = cover
background-opacity = 0.9
```

Note: Use low `background-image-opacity` (0.2-0.4) so text remains readable.

## Documentation

- [Config Reference](https://github.com/ghostty-org/website/blob/main/docs/config/reference.mdx)
- [Ghostty Docs](https://ghostty.org/docs)
