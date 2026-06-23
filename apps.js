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
        "appId": "chrome-hnpfjngllnobngcgfapefoaidbinmjnm-Default",
        "desktopId": "chrome-hnpfjngllnobngcgfapefoaidbinmjnm-Default",
        "name": "WhatsApp Web",
        "icon": "chrome-hnpfjngllnobngcgfapefoaidbinmjnm-Default",
        "iconAliases": [],
        "fallback": "C",
        "command": [
            "/opt/google/chrome/google-chrome",
            "--profile-directory=Default",
            "--app-id=hnpfjngllnobngcgfapefoaidbinmjnm"
        ]
    }
]
