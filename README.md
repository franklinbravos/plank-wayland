# plank-wayland

A macOS-style dock for [Hyprland](https://hyprland.org/) built with [Quickshell](https://github.com/Quickshell/Quickshell).

## Features

- **macOS-like dock** with app icons, zoom animation, and running indicators
- **Multi-monitor support** — dock appears on both internal and external displays
- **Window management** — click to focus, multi-window menu (click or hover)
- **Hover preview** — hover over an app with multiple windows to show the window picker (400ms delay)
- **Pinned apps** — right-click to pin/unpin, persistent across sessions
- **App launcher** — click the launcher icon (far left) to search and launch apps
- **Customizable themes** — 20+ built-in styles (macOS, glass, neon, minimal, etc.)
- **Settings panel** — right-click dock background or use the gear icon in window menus
- **Smart hide** — auto-hides when windows overlap the dock area
- **Icon themes** — follows GTK/KDE system icon theme automatically

## Requirements

- **Hyprland** (Wayland compositor)
- **Quickshell** `>= 0.3.0` — [AUR: `quickshell`](https://aur.archlinux.org/packages/quickshell)
- **Qt6** and Qt6 Quick (installed as Quickshell dependency)

## Installation

### Install from Source

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/plank-wayland ~/plank-wayland
cd ~/plank-wayland

# Make run.sh executable
chmod +x run.sh

# Launch it
./run.sh
```

### Install with Hyprland autostart

```bash
# In ~/.config/hypr/autostart.conf:
exec-once = /path/to/plank-wayland/run.sh
```

Or, if you prefer to keep the config in `~/.config/plank-wayland/`:

```bash
# Run once to copy config files
mkdir -p ~/.config/plank-wayland
cp -a components services *.qml *.js run.sh ~/.config/plank-wayland/

# In ~/.config/hypr/autostart.conf:
exec-once = quickshell --path ~/.config/plank-wayland/shell.qml
```

## Usage

| Action | Result |
|--------|--------|
| **Left-click** icon | Focus or launch app |
| **Left-click** icon (multiple windows) | Show window picker menu |
| **Hover** icon (multiple windows, 400ms) | Show window picker menu |
| **Right-click** icon | Open app context menu (pin, settings) |
| **Left-click** launcher (far-left icon) | Open app launcher |
| **Right-click** dock background | Open dock settings |

### Window Picker

When an app has multiple windows open:
- **Click** the dock icon → shows the window list
- **Hover** over the icon for 400ms → automatically shows the window list
- **Click** a window entry → focuses that window
- Hovering over the menu pauses the auto-close timer

## Configuration

### Quick Settings

Open the settings panel by right-clicking the dock background or clicking the gear icon (⚙) in any app's context menu.

### Direct Configuration: `settings.js`

The main configuration file is `settings.js`. Key fields:

```js
var dock = {
    "iconSize": 36,                  // Base icon size in pixels
    "zoomEnabled": true,             // Enable/disable hover zoom
    "zoomPercent": 150,              // Zoom magnification (100 = no zoom)
    "itemPadding": 2.5,              // Spacing between icons
    "topPadding": -11,               // Vertical padding (negative = tighter)
    "bottomPadding": 2.5,
    "autoHide": false,               // Auto-hide when not hovering
    "smartHide": false,              // Hide when window overlaps dock
    "menuBottomMargin": 118,         // Distance from screen bottom to menu
    "hideOffset": 100,               // Pixels to slide down when hidden
    "fadeTime": 160,                 // Fade animation duration (ms)
    "slideTime": 220,                // Slide animation duration (ms)
    "zoomDuration": 120,             // Zoom animation duration (ms)
    "clickTime": 300,                // Click debounce time (ms)
    "launchBounceTime": 420,         // Launch bounce animation (ms)
    "launchBounceHeight": 0.625,     // Bounce height multiplier
    "urgentBounceTime": 600,         // Urgent window bounce (ms)
    "urgentBounceHeight": 1.667,     // Urgent bounce height
}
```

### Pinned Apps: `apps.js`

Pinned apps persist across sessions in `apps.js`. You can also pin/unpin via the right-click menu in the dock.

### Themes

Change the active style:

```js
var styleName = "macos-dark"  // See "styles" block in settings.js for all options
```

Available styles: `macos`, `macos-dark`, `macos-light`, `plank`, `plank-transparent`, `glass`, `clear-glass`, `black-glass`, `neon`, `obsidian`, `deep-sea`, `nebula`, `frost`, `liquid-titanium`, `onyx-gold`, `aurora-noir`, `champagne-glass`, `rose-quartz`, `cobalt-pro`, `minimal`

## Project Structure

```
plank-wayland/
├── shell.qml              # Main entry point — ShellRoot with all panels
├── settings.js            # Dock configuration and themes
├── apps.js                # Pinned apps list
├── i18n.js                # Internationalization
├── run.sh                 # Launch script with icon theme detection
├── README.md              # This file
├── components/
│   ├── Dock.qml           # Dock bar layout and behavior
│   ├── DockItem.qml       # Individual dock icon
│   ├── DockMenu.qml       # Window picker menu
│   ├── DockTooltip.qml    # App name tooltip
│   ├── AppLauncher.qml    # Full-screen app launcher
│   ├── LauncherItem.qml   # Launcher icon (far left of dock)
│   ├── Indicator.qml      # Running/active indicator
│   ├── SettingsButton.qml # Toggle button for settings
│   └── SettingsPanel.qml  # Settings UI panel
└── services/
    ├── WindowModel.qml    # Window tracking and grouping
    ├── PinnedApps.qml     # Pinned app persistence
    └── SettingsStore.qml  # Settings state management
```

## Troubleshooting

### Dock doesn't appear

Make sure `quickshell` is installed and run from a Hyprland session:

```bash
quickshell --path /path/to/plank-wayland/shell.qml
```

### Window picker menu doesn't respond

The menu needs `WlrLayershell.layer: WlrLayer.Overlay` to stay above windows — verify your `shell.qml` includes this in the menu `PanelWindow`.

### Icons not showing

The dock follows your GTK/KDE icon theme. Set `"followSystemIconTheme": false` in `settings.js` and restart if you want to specify icons directly via desktop entries.

## Credits

Based on the original [plank-wayland](https://github.com/Quickshell/plank-wayland) example by the Quickshell project.

## License

MIT
