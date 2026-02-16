<p align="center">
<img src="./assets/ambxst/ambxst-logo-color.svg" alt="Ambxst Logo" style="width: 50%;" align="center" />
  <br>
  <br>
An <i><b>Ax</b>tremely</i> customizable shell — <b>Ubuntu Fork</b>.<br>
<b>Ported & Maintained by Ghosty</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Ubuntu-24.04%20LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=white&labelColor=000000" alt="Ubuntu 24.04" />
  <img src="https://img.shields.io/badge/Hyprland-PPA-blue?style=for-the-badge&labelColor=000000" alt="Hyprland PPA" />
  <img src="https://img.shields.io/badge/Maintainer-Ghosty-purple?style=for-the-badge&labelColor=000000" alt="Maintainer" />
</p>

---

<h2><sub>📸</sub> Screenshots</h2>

<div align="center">
  <img src="./assets/screenshots/1.png" width="100%" />

  <br />

  <img src="./assets/screenshots/2.png" width="32%" />
  <img src="./assets/screenshots/3.png" width="32%" />
  <img src="./assets/screenshots/4.png" width="32%" />

  <img src="./assets/screenshots/5.png" width="32%" />
  <img src="./assets/screenshots/6.png" width="32%" />
  <img src="./assets/screenshots/7.png" width="32%" />

  <img src="./assets/screenshots/8.png" width="32%" />
  <img src="./assets/screenshots/9.png" width="32%" />
  <img src="./assets/screenshots/10.png" width="32%" />
</div>

---

<h2><sub>📦</sub> Installation (Ubuntu 24.04 LTS)</h2>

```bash
curl -fsSL https://raw.githubusercontent.com/Me7war/Ambxst/refs/heads/main/boot.sh | bash
```

This fork is built specifically for:

* **Ubuntu 24.04 LTS**
* Hyprland installed via official PPA
* QuickShell (`qs`)
* Wayland session

The installer will:

* Detect Ubuntu 24.04
* Install required APT dependencies
* Install Hyprland PPA packages
* Build missing components if needed
* Set up services
* Create the `ambxst` launcher
* Optionally import dotfiles

> ⚠️ Hyprland must be installed (the installer can handle this automatically).

---

## Running Ambxst

After installation:

```bash
ambxst
```

This launches the Ambxst shell using QuickShell.

---

## CLI Usage

Ambxst includes a full Ubuntu-focused CLI.

Basic commands:

```bash
ambxst help
ambxst update
ambxst brightness 75
ambxst brightness +10
ambxst screen off
ambxst lock
ambxst quit
```

Features include:

* Brightness control (absolute & relative)
* Monitor listing
* Screen DPMS control
* Locking
* Restarting
* IPC command execution
* Update via installer
* Version display

Run:

```bash
ambxst help
```

for full command documentation.

---

## Post-Install Dot Import (Optional)

During installation you may import a dotfile script.

Requirements:

* Must be a raw file link
* Must start with:

```
!GSH
```

Dot import allows:

* Installing additional packages
* Configuring development environments
* Setting Git configuration
* Installing IDEs
* Automating fresh Ubuntu setups

If skipped, installation continues normally.

---

## Will this change my config?

No.

Ambxst is designed to be non-intrusive. It does not overwrite your existing system configuration. It applies settings only while running via IPC communication.

Exiting Ambxst returns your system to its normal state.

---

<h2><sub>✨</sub> Features</h2>

* [x] Customizable components
* [x] Themes
* [x] System integration
* [x] App launcher
* [x] Clipboard manager
* [x] Notes system
* [x] Wallpaper manager
* [x] Emoji picker
* [x] Tmux session manager
* [x] System monitor
* [x] Media control
* [x] Notification system
* [x] Wi-Fi manager
* [x] Bluetooth manager
* [x] Audio mixer
* [x] EasyEffects integration
* [x] Screen capture
* [x] Screen recording
* [x] Color picker
* [x] OCR
* [x] QR and barcode scanner
* [x] Webcam mirror
* [x] Game mode
* [x] Night mode
* [x] Power profile manager
* [x] AI Assistant
* [x] Weather
* [x] Calendar
* [x] Power menu
* [x] Workspace management
* [x] Multi-monitor support
* [x] Customizable keybindings
* [ ] Plugin and extension system
* [ ] Compatibility with other Wayland compositors

---

## Need Help?

If you encounter issues:

* Open a GitHub issue
* Start a discussion in the repository

Configuration directory:

```
~/.config/ambxst
```

---

## Credits

Original Ambxst project by Axenide.

Ubuntu fork maintained and ported by **Ghosty**.

Huge thanks to all original contributors and the QuickShell community.

---

You are now running the Ubuntu fork of Ambxst.

Enjoy the shell. 🚀
