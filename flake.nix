{
  description = "Some miscellaneous packages";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable-small";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, rust-overlay }:
    let
      overlays = [ (import rust-overlay) ];

      forAllSystems = f: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: f {
        pkgs = import nixpkgs { inherit system overlays; };
        system = system;
      });
    in
    {
      packages = forAllSystems ({ system, pkgs }:
        let
          rustPlatform = pkgs.makeRustPlatform {
            cargo = pkgs.rust-bin.nightly.latest.default;
            rustc = pkgs.rust-bin.nightly.latest.default;
          };
        in
        let
          fd = pkgs.fd;
          helix = pkgs.helix;
        in
        {
          inherit helix fd;
          default = helix;
        }
      );
    };
}
