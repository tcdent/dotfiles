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

## Documentation

- [Config Reference](https://github.com/ghostty-org/website/blob/main/docs/config/reference.mdx)
- [Ghostty Docs](https://ghostty.org/docs)
