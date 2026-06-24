.pragma library

var items = [
    {
        "appId": "com.google.Chrome",
        "name": "Chrome",
        "icon": "google-chrome",
        "command": "google-chrome",
        "pinned": true
    },
    {
        "appId": "com.mitchellh.ghostty",
        "desktopId": "com.mitchellh.ghostty",
        "name": "Ghostty",
        "icon": "com.mitchellh.ghostty",
        "iconAliases": [],
        "fallback": "C",
        "command": [
            "/usr/bin/ghostty",
            "--gtk-single-instance=true"
        ]
    },
    {
        "appId": "cursor",
        "desktopId": "cursor",
        "name": "Cursor",
        "icon": "co.anysphere.cursor",
        "iconAliases": [],
        "fallback": "C",
        "command": [
            "/usr/share/cursor/cursor"
        ]
    },
    {
        "appId": "chrome-hnpfjngllnobngcgfapefoaidbinmjnm-Profile_6",
        "desktopId": "chrome-hnpfjngllnobngcgfapefoaidbinmjnm-Profile_6",
        "name": "WhatsApp Web",
        "icon": "chrome-hnpfjngllnobngcgfapefoaidbinmjnm-Profile_6",
        "iconAliases": [],
        "fallback": "C",
        "command": [
            "/opt/google/chrome/google-chrome",
            "--profile-directory=Profile 6",
            "--app-id=hnpfjngllnobngcgfapefoaidbinmjnm"
        ]
    },
    {
        "appId": "org.telegram.desktop",
        "desktopId": "org.telegram.desktop",
        "name": "Telegram",
        "icon": "org.telegram.desktop",
        "iconAliases": [],
        "fallback": "O",
        "command": [
            "/usr/bin/flatpak",
            "run",
            "--branch=stable",
            "--arch=x86_64",
            "--command=Telegram",
            "--file-forwarding",
            "org.telegram.desktop",
            "--",
            "@@u",
            "@@"
        ]
    }
]
