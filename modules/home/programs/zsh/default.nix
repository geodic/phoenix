{
  config,
  lib,
  ...
}:

let
  cfg = config.phoenix.programs.zsh;
in
{
  options.phoenix.programs.zsh.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable ZSH shell configuration.";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      antidote = {
        enable = true;
        plugins = [
          "Aloxaf/fzf-tab"
          "jeffreytse/zsh-vi-mode"
          "zsh-users/zsh-autosuggestions"
          "zdharma-continuum/fast-syntax-highlighting"
        ];
      };
      initContent = builtins.concatStringsSep "\n" [
        (builtins.readFile ./environment.zsh)
        (builtins.readFile ./functions.zsh)
        (builtins.concatStringsSep "\n" (
          map builtins.readFile (
            builtins.filter (name: lib.hasSuffix ".zsh" name) (lib.filesystem.listFilesRecursive ./configs)
          )
        ))
      ];
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.fzf.enable = true;

    programs.eza = {
      enable = true;
      icons = "auto";
    };
  };
}
