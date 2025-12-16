# Media packages: video, audio, players
{ pkgs, wrapWithNixGL }:

with pkgs; [
  (wrapWithNixGL gpu-screen-recorder)
  (wrapWithNixGL mpvpaper)

  ffmpeg
  playerctl

  # Audio
  pipewire
  wireplumber
]
