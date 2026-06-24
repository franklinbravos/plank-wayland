import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import "components"
import "services"
import "settings.js" as DockSettings

ShellRoot {
    id: root

    property var menuApp: null
    property bool menuOpen: false
    property bool launcherOpen: false
    property bool settingsOpen: false
    property bool closeLayerOpen: false
    property real menuX: 0
    property real menuBottomMargin: DockSettings.dock.menuBottomMargin

    function focusToplevel(win) {
        if (!win) return false

        let savedX = 0, savedY = 0
        try {
            const cur = Hyprland.cursor
            if (cur && cur.x !== undefined) {
                savedX = cur.x
                savedY = cur.y
            }
        } catch (e) {}

        let address = ""
        let from = "none"
        try {
            if (win.address !== undefined && win.address !== null && String(win.address).length > 0) {
                address = String(win.address)
                from = "win.address"
            } else if (win.lastIpcObject && win.lastIpcObject.address) {
                address = String(win.lastIpcObject.address)
                from = "lastIpcObject"
            }
        } catch (e) {}

        if (!address) {
            console.log("focusToplevel: no address found")
            return false
        }

        if (!address.startsWith("0x")) address = "0x" + address

        Hyprland.dispatch("focuswindow address:" + address)
        Hyprland.dispatch("alterzorder top,address:" + address)
        if (savedX !== 0 || savedY !== 0) {
            Hyprland.dispatch("movecursor " + Math.round(savedX) + " " + Math.round(savedY))
        }
        return true
    }

    function normalizeId(id) {
        return String(id || "").toLowerCase().replace(/\.desktop$/, "")
    }

    function desktopEntryForApp(app) {
        if (!app) return null
        const candidates = [app.desktopId, app.appId, app.icon, app.name]
        for (let i = 0; i < candidates.length; i++) {
            const id = String(candidates[i] || "")
            if (!id || id.startsWith("/")) continue
            try {
                const entry = DesktopEntries.heuristicLookup(id) || DesktopEntries.byId(id) || DesktopEntries.byId(normalizeId(id))
                if (entry) return entry
            } catch (e) {}
        }
        for (let i = 0; i < candidates.length; i++) {
            const entry = scanDesktopEntry(candidates[i])
            if (entry) return entry
        }
        return null
    }

    function entryValue(entry, keys) {
        if (!entry) return ""
        for (let i = 0; i < keys.length; i++) {
            try {
                const value = entry[keys[i]]
                if (value !== undefined && value !== null && String(value)) return String(value)
            } catch (e) {}
        }
        return ""
    }

    function executableNameFromEntry(entry) {
        const exec = entryValue(entry, ["execString", "exec"])
        if (exec) {
            const first = exec.trim().split(/\s+/)[0]
            const parts = first.split("/")
            return parts[parts.length - 1]
        }
        try {
            const command = entry.command ? Array.from(entry.command) : []
            if (command.length > 0) {
                const parts = String(command[0]).split("/")
                return parts[parts.length - 1]
            }
        } catch (e) {}
        return ""
    }

    function entryMatchesId(entry, id) {
        const normalized = normalizeId(id)
        if (!normalized) return false
        const values = [
            entryValue(entry, ["id", "desktopId"]),
            entryValue(entry, ["name"]),
            entryValue(entry, ["icon"]),
            entryValue(entry, ["startupWmClass", "startupWMClass", "startupClass", "wmClass"]),
            executableNameFromEntry(entry)
        ]
        for (let i = 0; i < values.length; i++) {
            if (normalizeId(values[i]) === normalized) return true
        }
        return false
    }

    function scanDesktopEntry(id) {
        if (!id || String(id).startsWith("/")) return null
        try {
            const entries = DesktopEntries.applications.values || []
            for (let i = 0; i < entries.length; i++) {
                const entry = entries[i]
                if (entryMatchesId(entry, id)) return entry
            }
        } catch (e) {}
        return null
    }

    function commandArray(command) {
        if (!command) return []
        if (Array.isArray(command)) return command
        if (typeof command === "string") return []
        if (command.length !== undefined) return Array.from(command)
        return []
    }

    function cleanedCommandArray(command) {
        const values = commandArray(command)
        const result = []
        for (let i = 0; i < values.length; i++) {
            const part = String(values[i] || "").trim()
            if (!part || /^%[fFuUdDnNickvm]$/.test(part)) continue
            result.push(part.replace(/%%/g, "%"))
        }
        while (result.length > 1 && result[result.length - 1] === "--") result.pop()
        return result
    }

    function cleanedExec(text) {
        let exec = String(text || "")
        if (!exec) return ""
        exec = exec.replace(/%%/g, "\u0000")
        exec = exec.replace(/%[fFuUdDnNickvm]/g, "")
        exec = exec.replace(/\u0000/g, "%")
        exec = exec.replace(/\s+--\s*$/g, "")
        exec = exec.replace(/\s+/g, " ")
        return exec.trim()
    }

    function looksLikeDesktopId(command, app) {
        const text = String(command || "").trim()
        if (!text || text.indexOf(" ") >= 0 || text.indexOf("/") >= 0) return false
        if (text.indexOf(".") >= 0) return true
        const key = normalizeId(text)
        return key === normalizeId(app && app.appId) || key === normalizeId(app && app.icon)
    }

    function launchApp(app) {
        const entry = desktopEntryForApp(app)
        const arrayCommand = cleanedCommandArray(app && app.command)
        if (arrayCommand.length > 0) {
            Quickshell.execDetached(arrayCommand)
            return
        }

        const rawCommand = String((app && app.command) || "")
        const command = cleanedExec(rawCommand)
        if (command) {
            if (entry && entry.execute && looksLikeDesktopId(command, app)) {
                entry.execute()
                return
            }
            Quickshell.execDetached(["sh", "-c", command])
            return
        }

        if (entry && entry.execute) {
            entry.execute()
            return
        }

        const fallback = cleanedExec(app && app.appId)
        if (fallback) Quickshell.execDetached(["sh", "-c", fallback])
    }

    function activateApp(app) {
        if (!app) return
        if (app.running && app.toplevels && app.toplevels.length > 0) {
            if (focusToplevel(app.toplevels[0])) return
        }
        launchApp(app)
    }

    property bool screensReady: Quickshell.screens && Quickshell.screens.length > 0

    function focusWindowByAddress(win) {
        return focusToplevel(win)
    }

    function screenForMonitor(name) {
        try {
            const screens = Quickshell.screens
            if (!screens) return null
            for (let i = 0; i < screens.length; i++) {
                if (screens[i].name === name) return screens[i]
            }
        } catch (e) {}
        return null
    }

    Connections {
        target: Quickshell
        function onScreensChanged() {
            root.screensReady = Quickshell.screens && Quickshell.screens.length > 0
        }
    }

    SettingsStore {
        id: settingsStore
    }

    PinnedApps {
        id: pinnedApps
        onChanged: windowModel.update()
    }

    WindowModel {
        id: windowModel
        pinnedApps: pinnedApps.apps
    }

    property bool isOverlapped: {
        if (!settingsStore.smartHide) return false
        const active = Hyprland.activeToplevel
        if (!active) return false

        // Always hide if fullscreen
        if (active.fullscreen) return true

        try {
            const ipc = active.lastIpcObject
            if (ipc && Array.isArray(ipc.at) && Array.isArray(ipc.size) && ipc.at.length >= 2 && ipc.size.length >= 2) {
                const winBottom = ipc.at[1] + ipc.size[1]
                const screenHeight = dockWindow.screen.height
                // If window is within the bottom 120 pixels of the screen
                return winBottom > (screenHeight - 120)
            }
        } catch (e) {
            console.log("SmartHide: Overlap check failed", e)
        }

        // Fallback for tiled windows if IPC is incomplete
        return !active.floating
    }

    Loader {
        active: root.screensReady && Quickshell.screens && screenForMonitor("HDMI-A-1") !== null
        sourceComponent: Component {
            PanelWindow {
                id: dockWindow
                visible: windowModel.ready

                anchors {
                    bottom: true
                }

                margins {
                    bottom: 0
                }

                color: "transparent"
                implicitWidth: dock.implicitWidth
                implicitHeight: dock.layerHeight
                exclusiveZone: dock.hidden ? 0 : 30
                screen: screenForMonitor("HDMI-A-1")
                WlrLayershell.namespace: "plank-wayland-dock"
                mask: Region { item: dockInputArea }

                Item {
                    id: dockInputArea
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    width: dock.barWidth
                    height: dock.barHeight
                }

                Dock {
                    id: dock
                    anchors.horizontalCenter: parent.horizontalCenter
                    apps: windowModel.dockApps.length > 0 ? windowModel.dockApps : windowModel.pinnedDockApps
                    settings: settingsStore
                    smartHideEnabled: settingsStore.smartHide
                    isOverlapped: root.isOverlapped
                    menuOpen: root.menuOpen || root.settingsOpen
                    menuApp: root.menuApp
                    onActivate: app => {
                        if (app && app.running && app.toplevels && app.toplevels.length > 1) {
                            root.menuApp = app
                            root.menuX = dockWindow.x + dock.menuX
                            root.menuBottomMargin = dock.menuBottomMargin
                            root.menuOpen = true
                        } else {
                            root.activateApp(app)
                        }
                    }
                    onOpenMenu: app => {
                        root.menuApp = app
                        root.menuX = dockWindow.x + dock.menuX
                        root.menuBottomMargin = dock.menuBottomMargin
                        root.menuOpen = true
                    }
                    onCloseMenuRequested: root.menuOpen = false
                    onLaunch: root.launcherOpen = !root.launcherOpen
                }
            }
        }
    }

    Loader {
        active: root.screensReady && Quickshell.screens && screenForMonitor("eDP-1") !== null
        sourceComponent: Component {
            PanelWindow {
                id: dockWindowEdp
                visible: windowModel.ready

                anchors {
                    bottom: true
                }

                margins {
                    bottom: 0
                }

                color: "transparent"
                implicitWidth: dockEdp.implicitWidth
                implicitHeight: dockEdp.layerHeight
                exclusiveZone: dockEdp.hidden ? 0 : 30
                screen: screenForMonitor("eDP-1")
                WlrLayershell.namespace: "plank-wayland-dock-edp"
                mask: Region { item: dockEdpInputArea }

                Item {
                    id: dockEdpInputArea
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    width: dockEdp.barWidth
                    height: dockEdp.barHeight
                }

                Dock {
                    id: dockEdp
                    anchors.horizontalCenter: parent.horizontalCenter
                    apps: windowModel.dockApps.length > 0 ? windowModel.dockApps : windowModel.pinnedDockApps
                    settings: settingsStore
                    smartHideEnabled: settingsStore.smartHide
                    isOverlapped: root.isOverlapped
                    menuOpen: root.menuOpen || root.settingsOpen
                    menuApp: root.menuApp
                    onActivate: app => {
                        if (app && app.running && app.toplevels && app.toplevels.length > 1) {
                            root.menuApp = app
                            root.menuX = dockWindowEdp.x + dockEdp.menuX
                            root.menuBottomMargin = dockEdp.menuBottomMargin
                            root.menuOpen = true
                        } else {
                            root.activateApp(app)
                        }
                    }
                    onOpenMenu: app => {
                        root.menuApp = app
                        root.menuX = dockEdp.x + dockEdp.menuX
                        root.menuBottomMargin = dockEdp.menuBottomMargin
                        root.menuOpen = true
                    }
                    onCloseMenuRequested: root.menuOpen = false
                    onLaunch: root.launcherOpen = !root.launcherOpen
                }
            }
        }
    }

    Loader {
        active: root.screensReady && Quickshell.screens && screenForMonitor("HDMI-A-1") !== null
        sourceComponent: Component {
            PanelWindow {
                id: launcherWindow
                visible: true

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }
                color: "transparent"
                exclusiveZone: 0
                mask: Region { item: root.launcherOpen ? launcher : null }
                WlrLayershell.namespace: "plank-wayland-launcher"
                WlrLayershell.keyboardFocus: root.launcherOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                screen: screenForMonitor("HDMI-A-1")

                AppLauncher {
                    id: launcher
                    anchors.fill: parent
                    shown: root.launcherOpen
                    settings: settingsStore
                    onCloseRequested: root.launcherOpen = false
                }
            }
        }
    }

    PanelWindow {
        visible: root.menuOpen

        anchors {
            bottom: true
        }

        margins {
            bottom: root.menuBottomMargin
            left: root.menuX
        }

        color: "transparent"
        implicitWidth: dockMenu.implicitWidth
        implicitHeight: dockMenu.implicitHeight
        exclusiveZone: 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        DockMenu {
            id: dockMenu
            anchors.fill: parent
            app: root.menuApp
            settings: settingsStore
            onPinRequested: app => pinnedApps.pin(app)
            onUnpinRequested: app => pinnedApps.unpin(app.appId)
            onSettingsRequested: {
                root.settingsOpen = true
                root.menuOpen = false
            }
            onCloseRequested: root.menuOpen = false
            onFocusWindowRequested: win => {
                root.focusWindowByAddress(win)
                root.menuOpen = false
            }
            onNewWindowRequested: app => {
                root.launchApp(app)
                root.menuOpen = false
            }
        }
    }

    // ESC keybind via Hyprland (configured in hyprland.conf)

    PanelWindow {
        visible: root.settingsOpen

        anchors {
            bottom: true
            right: true
        }

        margins {
            bottom: 24
            right: 24
        }

        color: "transparent"
        implicitWidth: 420
        implicitHeight: 640
        exclusiveZone: 0

        SettingsPanel {
            anchors.fill: parent
            store: settingsStore
            onCloseRequested: root.settingsOpen = false
        }
    }
}
