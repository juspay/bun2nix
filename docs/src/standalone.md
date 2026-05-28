# Standalone API

If you do not want to adopt [`flake-parts`](https://flake.parts) and would rather
not overlay `nixpkgs` either, `bun2nix` exposes a **standalone library** —
`bun2nix.lib.mkBun2nix { pkgs }` — that returns its package-building helpers as
a plain attrset, bound to the `pkgs` you pass in.

This mirrors the [haskell-flake standalone pattern](https://haskell.nixos.asia/standalone).

## Usage

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    bun2nix.url = "github:nix-community/bun2nix";
    bun2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, bun2nix, ... }:
    let
      system = "x86_64-linux";
      pkgs   = nixpkgs.legacyPackages.${system};
      b2n    = bun2nix.lib.mkBun2nix { inherit pkgs; };
    in {
      packages.${system}.default = b2n.mkDerivation {
        packageJson = ./package.json;
        src         = ./.;
        bunDeps     = b2n.fetchBunDeps { bunNix = ./bun.nix; };
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.bun b2n.bun2nix ];
      };
    };
}
```

The runnable equivalent of the above lives in the [`standalone` template](./template-installation.md):

```sh
nix flake init --template github:nix-community/bun2nix#standalone
```

## What you get back

`mkBun2nix { pkgs }` returns an attrset containing:

| Attribute                       | Description                                                                |
| ------------------------------- | -------------------------------------------------------------------------- |
| `bun2nix`                       | The `bun2nix` CLI derivation (the same one in `packages.${system}.default`) |
| `mkDerivation`                  | See [`mkDerivation`](./building-packages/mkDerivation.md)                  |
| `fetchBunDeps`                  | See [`fetchBunDeps`](./building-packages/fetchBunDeps.md)                  |
| `hook`                          | See [`hook`](./building-packages/hook.md)                                  |
| `writeBunScriptBin`             | See [`writeBunScriptBin`](./building-packages/writeBunScriptBin.md)        |
| `writeBunApplication`           | See [`writeBunApplication`](./building-packages/writeBunApplication.md)    |
| `patchedDependenciesToOverrides`| Helper for projects using bun `patchedDependencies`                        |

## When to pick this over the overlay

| Want…                                                            | Use                                  |
| ---------------------------------------------------------------- | ------------------------------------ |
| Plain flake outputs, no `flake-parts`, no `import nixpkgs { ... }` | `lib.mkBun2nix` (this page)          |
| `pkgs.bun2nix.*` inside an already-overlaid pkgs                 | [the overlay](./overlay.md)          |
| Composition as a flake-parts module                               | [pre-existing flake](./flake-installation.md) |

All three live in the same flake — pick whichever fits your project layout.
