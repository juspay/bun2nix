# Bun2Nix standalone sample

Same hello-world as the `default` template, but consumes `bun2nix` via the
**standalone API** (`bun2nix.lib.mkBun2nix { pkgs }`) instead of going through
`flake-parts` or the `bun2nix` overlay.

Use this template if you want a plain `outputs = { self, nixpkgs, bun2nix, ... }: ...`
flake without overlaying nixpkgs or adopting `flake-parts`.

To try it out: `nix run .`

## Notable files

- `flake.nix` -> Plain flake that calls `bun2nix.lib.mkBun2nix { inherit pkgs; }`
- `default.nix` -> Build instructions for this bun package (identical to the `default` template)
- `bun.nix` -> Generated bun expression from `bun.lock`
- `package.json` -> Standard `package.json` with a `postinstall` running `bun2nix`
