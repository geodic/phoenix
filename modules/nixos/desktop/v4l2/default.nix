{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.phoenix.desktop.v4l2;
in
{
  options.phoenix.desktop.v4l2.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable V4L2 configuration.";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "v4l2loopback" ];
    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=0
    '';

    environment.systemPackages = with pkgs; [
      config.boot.kernelPackages.v4l2loopback.bin
      v4l-utils
    ];
  };
}
