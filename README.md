WindowMaster — Window Layout Anchor & Monitor Wake Engine

WindowMaster is a Windows utility that records desktop window positions and restores them after a monitor sleeps, reconnects, or changes resolution. It is designed for multi-monitor setups where windows can move or resize after display changes.

## Features

- Adaptive restore timing that learns how long displays take to recover, or a manually selected delay
- Automatic, periodic snapshots of window positions
- Restore after monitor wake, reconnect, startup, or display topology changes
- Support for multi-monitor layouts
- Configurable snapshot and restore hotkeys (defaults: `Ctrl+Alt+S` and `Ctrl+Alt+R`)
- Options for Windows startup, starting minimized, minimizing to the system tray, and notifications
- In-app engine logs to help review activity and troubleshoot restores

## Installation

1. Download and run `WindowMaster-Setup-2.1.1-x64.exe` from the release files.
2. Follow the setup prompts. If the required .NET Desktop Runtime is missing, setup can offer to download and install it.
3. Launch WindowMaster from the Start menu or the optional desktop shortcut.

## Requirements

- Windows 10 or Windows 11, 64-bit
- .NET 10 Windows Desktop Runtime (the installer can offer to download it)

## Diagnostics and data

Open the **Logs** section in WindowMaster to review engine activity, including snapshot and restore events. Application settings, logs, and snapshots are stored under `%APPDATA%\WindowMaster`.

## Support and community

- [YouTube](https://youtube.com/mikesunboxing)
- [Discord](https://discord.gg/XtBTGQ6BDu)
- [Patreon](https://patreon.com/mikesunboxing)
- [PayPal](https://paypal.me/mikesunboxing)
- Email: [mike@mikesunboxing.com](mailto:mike@mikesunboxing.com)

The app and installer are currently unsigned, so Windows Smart App Control may block them.

