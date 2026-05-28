{
  description = "Bun2Nix standalone sample (no flake-parts, no overlay)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";

    bun2nix.url = "github:nix-community/bun2nix?tag=2.0.8";
    bun2nix.inputs.nixpkgs.follows = "nixpkgs";
    bun2nix.inputs.systems.follows = "systems";
  };

  # Use the cached version of bun2nix from the nix-community cli
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs =
    inputs:
    let
      eachSystem = inputs.nixpkgs.lib.genAttrs (import inputs.systems);

      # Per-system bundle of bun2nix functions, obtained via the
      # standalone `lib.mkBun2nix` API — no overlay required.
      bun2nixFor = eachSystem (
        system:
        inputs.bun2nix.lib.mkBun2nix {
          pkgs = inputs.nixpkgs.legacyPackages.${system};
        }
      );
    in
    {
      packages = eachSystem (system: {
        default = inputs.nixpkgs.legacyPackages.${system}.callPackage ./default.nix {
          bun2nix = bun2nixFor.${system};
        };
      });

      devShells = eachSystem (system: {
        default = inputs.nixpkgs.legacyPackages.${system}.mkShell {
          packages = [
            inputs.nixpkgs.legacyPackages.${system}.bun
            bun2nixFor.${system}.bun2nix
          ];

          shellHook = ''
            bun install --frozen-lockfile
          '';
        };
      });
    };
}
