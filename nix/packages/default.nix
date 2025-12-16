# Main Ambxst package
{ pkgs, lib, self, system, nixgl, quickshell, ambxstLib }:

let
  isNixOS = ambxstLib.detectNixOS pkgs;
  nixGL = nixgl.packages.${system}.nixGLDefault;
  quickshellPkg = quickshell.packages.${system}.default;

  wrapWithNixGL = ambxstLib.wrapWithNixGL {
    inherit pkgs system isNixOS;
  };

  # Import sub-packages
  ambxst-auth = import ./ambxst-auth.nix {
    inherit pkgs;
    src = self + /modules/lockscreen;
  };

  ttf-phosphor-icons = import ./phosphor-icons.nix { inherit pkgs; };

  # Import modular package lists
  corePkgs = import ./core.nix { inherit pkgs wrapWithNixGL quickshellPkg; };
  toolsPkgs = import ./tools.nix { inherit pkgs; };
  mediaPkgs = import ./media.nix { inherit pkgs wrapWithNixGL; };
  appsPkgs = import ./apps.nix { inherit pkgs wrapWithNixGL; };
  fontsPkgs = import ./fonts.nix { inherit pkgs ttf-phosphor-icons; };

  # NixOS-specific packages
  nixosPkgs = [
    ambxst-auth
    pkgs.power-profiles-daemon
    pkgs.networkmanager
  ];

  # Non-NixOS packages
  nonNixosPkgs = [ nixGL ];

  # Combine all packages
  baseEnv = corePkgs
    ++ toolsPkgs
    ++ mediaPkgs
    ++ appsPkgs
    ++ fontsPkgs
    ++ (if isNixOS then nixosPkgs else nonNixosPkgs);

  envAmbxst = pkgs.buildEnv {
    name = "Ambxst-env";
    paths = baseEnv;
  };

  launcher = pkgs.writeShellScriptBin "ambxst" ''
    # Ensure ambxst-auth is in PATH for lockscreen
    ${lib.optionalString isNixOS ''
      export PATH="${ambxst-auth}/bin:$PATH"
    ''}
    ${lib.optionalString (!isNixOS) ''
      # On non-NixOS, use local build from ~/.local/bin
      export PATH="$HOME/.local/bin:$PATH"
    ''}

    # Pass nixGL for non-NixOS
    ${lib.optionalString (!isNixOS) "export AMBXST_NIXGL=\"${nixGL}/bin/nixGL\""}

    export AMBXST_QS="${quickshellPkg}/bin/qs"

    # Delegate execution to CLI
    exec ${self}/cli.sh "$@"
  '';

in pkgs.buildEnv {
  name = "Ambxst";
  paths = [ envAmbxst launcher ];
}
