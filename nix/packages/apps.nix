# Applications: terminal, launcher, control panels
{ pkgs, wrapWithNixGL }:

with pkgs; [
  # Terminal
  (wrapWithNixGL kitty)
  tmux

  # Launcher
  fuzzel

  # Control panels
  networkmanagerapplet
  blueman
  pwvucontrol
  easyeffects

  # Icons
  kdePackages.breeze-icons
  hicolor-icon-theme
]
