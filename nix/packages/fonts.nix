# Fonts
{ pkgs, ttf-phosphor-icons }:

with pkgs; [
  roboto
  barlow
  terminus_font
  terminus_font_ttf
  dejavu_fonts
  liberation_ttf

  # Nerd Fonts
  nerd-fonts.symbols-only
  nerd-fonts.iosevka

  # Noto family
  noto-fonts
  noto-fonts-color-emoji
  noto-fonts-cjk-sans
  noto-fonts-cjk-serif

  ttf-phosphor-icons
]
