{
  config,
  lib,
  inputs',
  pkgs,
  system,
  ...
}:

{
  phoenix = {
    desktop = {
      gnome.enable = true;
    };
    programs = {
      ghostty.enable = true;
      git.enable = true;
      vscode.enable = true;
      zsh.enable = true;
      direnv.enable = true;
      nixcord.enable = true;
      _1password.enable = true;
    };
    services = {
      hydroxide.enable = true;
    };
  };

  home.packages = with pkgs; [
    # apps
    fastfetch
    brave
    inputs'.zen-browser.packages.twilight
    micro
    spotify
    signal-desktop
    notion-app-enhanced
    blender
    orca-slicer
    fractal
    polari
    gruvbox-factory

    # archives
    zip
    xz
    unzip
    p7zip
    ripgrep

    # networking
    dnsutils
    nmap
    gping

    # misc
    cowsay
    file
    which
    tree
    gawk
    zstd
    gnupg

    # system tools
    sysstat
    lm_sensors
    ethtool
    pciutils
    usbutils

    # fonts
    nerd-fonts.fira-code

    # nix
    nixd
    nixfmt-rfc-style
    cachix
  ];

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";
}
