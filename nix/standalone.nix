{ self, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.flake.lib = mkOption {
    type = types.lazyAttrsOf types.raw;
  };

  config.flake.lib.mkBun2nix =
    { pkgs }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
      bun2nix = self.packages.${system}.bun2nix;
    in
    {
      inherit bun2nix;
      inherit (bun2nix.passthru)
        mkDerivation
        fetchBunDeps
        writeBunScriptBin
        writeBunApplication
        hook
        patchedDependenciesToOverrides
        ;
    };
}
