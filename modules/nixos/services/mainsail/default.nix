{
  config,
  lib,
  ...
}:

let
  cfg = config.phoenix.programs.mainsail;
in
{
  options.phoenix.programs.mainsail = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable Mainsail klipper client.";
  };

  config = lib.mkIf cfg {
    phoenix.programs.klipper = true;

    services.mainsail.enable = true;
  };
}
