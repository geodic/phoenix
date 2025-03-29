{
  config,
  lib,
  pkgs,
  inputs,
  hardware,
  ...
}:

let
  cfg = config.phoenix.nixos.binfmt;
in
{
  options.phoenix.nixos.binfmt.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable binfmt emulation.";
  };

  config = lib.mkIf cfg.enable {
    boot.binfmt = {
      emulatedSystems = lib.remove hardware.system [ "x86_64-linux" "aarch64-linux" ];
      registrations = {
        appimage = {
          wrapInterpreterInShell = false;
          interpreter = "${pkgs.appimage-run}/bin/appimage-run";
          recognitionType = "magic";
          offset = 0;
          mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
          magicOrExtension = ''\x7fELF....AI\x02'';
        };
      };
    };
  };
}
