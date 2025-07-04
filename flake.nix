rec {
  description = "A NixOS configuration that rose from the dead.";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://watersucks.cachix.org"
      "https://phoenix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "watersucks.cachix.org-1:6gadPC5R8iLWQ3EUtfu3GFrVY7X6I4Fwz/ihW25Jbv8="
      "phoenix.cachix.org-1:Jcu2oz0aHNqr/uI1yzMldvCQ0bXLHcsUzJE5XHp7FEA="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixos-hardware.url = "github:geodic/nixos-hardware/fixes";

    stylix.url = "github:geodic/stylix/gdm-icon-theme";

    nixcord.url = "github:kaylorben/nixcord";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      home-manager,
      nixpkgs,
      stylix,
      nixcord,
      deploy-rs,
      ...
    }:
    let
      mkLib =
        nixpkgs:
        nixpkgs.lib.extend (
          final: prev:
          {
            setNestedAttr =
              attr: value: attrset:
              builtins.mapAttrs (_: v: v // { ${attr} = value; }) attrset;

            recursiveConcatMapAttrs = 
              f: v:
              prev.foldl' prev.recursiveUpdate { }
                (prev.attrValues
                  (prev.mapAttrs f v)
                );
          }
          // home-manager.lib
        );
      lib = mkLib nixpkgs;

      overlays = builtins.map (overlayPath: import overlayPath) (
        builtins.filter (path: baseNameOf path == "default.nix") (
          nixpkgs.lib.filesystem.listFilesRecursive ./overlays
        ) 
      );
    in
    flake-parts.lib.mkFlake { inherit inputs; } ( 
      { withSystem, ... }: {
      imports = [ inputs.home-manager.flakeModules.home-manager ];
      flake = lib.recursiveConcatMapAttrs (
        hostname: _:
        let
          defaultConfig = {
            hardware = {
              system = "x86_64-linux";
              ram = 8 * 1024;
            };
            homes = [];
          };
          config = lib.recursiveUpdate defaultConfig (import ./hosts/${hostname}/config.nix);
          deployPkgs = import nixpkgs {
            inherit (config.hardware) system;
            overlays = [
              (final: prev: lib.recursiveUpdate (deploy-rs.overlays.default final prev) { deploy-rs.deploy-rs = prev.deploy-rs; })
            ];
          };
        in
        rec {
          nixosConfigurations.${hostname} = withSystem config.hardware.system ({ self', inputs', ... }:
            nixpkgs.lib.nixosSystem {
              inherit (config.hardware) system;
              modules = lib.flatten [
                ./hosts/${hostname}
                ./hosts/${hostname}/hardware.nix
                {
                  nixpkgs.config.allowUnfree = true;
                  nixpkgs.overlays = overlays;
                  nixpkgs.hostPlatform = lib.mkDefault config.hardware.system;
                  
                  networking.hostName = hostname;

                  system.stateVersion = "25.05";
                }
                stylix.nixosModules.stylix

                (builtins.filter (path: baseNameOf path == "default.nix") (
                  nixpkgs.lib.filesystem.listFilesRecursive ./modules/nixos
                ))
              ];
              specialArgs = {
                inherit (config) hardware;
                inherit inputs inputs' lib hostname;
              };
            });
          deploy.nodes.${hostname} = withSystem config.hardware.system ({ self', inputs', ... }: 
            {
              inherit hostname;

              sshUser = "root";

              profilesOrder = [ "system" ] ++ config.homes;
              profiles = {
                system = {
                  user = "root";
                  path = deployPkgs.deploy-rs.lib.activate.nixos nixosConfigurations.${hostname};
                };
              } // (builtins.listToAttrs (builtins.map (home: 
              {
                name = home;
                value = {
                  user = home;
                  path = deployPkgs.deploy-rs.lib.activate.home-manager self'.legacyPackages.homeConfigurations.${home};
                };
              }
              ) config.homes));
            });
        }
      ) (builtins.readDir ./hosts);
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem =
        { pkgs, system, inputs', ... }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = overlays;
          };

          legacyPackages.homeConfigurations = builtins.mapAttrs (
            username: _:
            inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = lib.flatten [
                ./homes/${username}
                {
                  home.username = username;
                  home.homeDirectory = "/home/${username}";
                  home.stateVersion = "25.05";
                  programs.home-manager.enable = true;
                }
                stylix.homeModules.stylix
                nixcord.homeModules.nixcord

                (builtins.filter (path: baseNameOf path == "default.nix") (
                  lib.filesystem.listFilesRecursive ./modules/home
                ))
              ];
              extraSpecialArgs = {
                inherit inputs inputs' lib system username;
              };
            }
          ) (builtins.readDir ./homes);

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [ pkgs.deploy-rs nixfmt-rfc-style ack ];
          };
        };
    });
}
