{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.boot.plymouth;
in
{
  options.${namespace}.boot.plymouth = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable Plymouth boot splash configuration.";
  };

  config = lib.mkIf cfg {
    boot.plymouth = {
      enable = true;
      theme = "bgrt";
    };

    boot.initrd.verbose = false;
    boot.consoleLogLevel = 0;
    boot.kernelParams = [
      "quiet"
      "udev.log_level=0"
    ];
  };
}
