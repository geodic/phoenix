# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    inputs.nixos-hardware.nixosModules.common-gpu-intel-tiger-lake
    inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.hostName = "euler";

  phoenix = {
    boot = {
      plymouth.enable = true;
    };
    hardware = {
      fprint.enable = true;
    };
    disks = {
      swap.enable = true;
      zram.enable = true;
    };
    desktop = {
      gnome.enable = true;
      flatpak.enable = true;
      v4l2.enable = true;
      ddcci.enable = true;
    };
    networking = {
      firewall.enable = true;
      tailscale.enable = true;
    };
    locale = {
      eastern.enable = true;
    };
    users = {
      mainUser = "advaith";
      advaith = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
