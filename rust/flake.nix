{
  description = "Rust Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, naersk, fenix }:
    let
      # Define supported host systems
      forEachSupportedSystem = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in {
      devShells = forEachSupportedSystem (system:
        let pkgs = nixpkgs.legacyPackages."${system}";
        in {
          default = pkgs.mkShell {
            # Non-compiler tooling for use
            packages = with pkgs; [
              cargo-audit
              cargo-edit
              cargo-expand
              cargo-tarpaulin
              cargo-nextest
              cargo-udeps
              cargo-watch

              bat
              fd
              helix
              lldb
              lsd
              ripgrep
            ];

            # Tooling to compile the source on the development platform
            nativeBuildInputs = [ self.packages."${system}".rustToolchain ];
          };
        }); # end devShells

      packages = forEachSupportedSystem (system: {
        rustToolchain = with fenix.packages."${system}";
          combine [
            stable.cargo
            stable.clippy
            stable.rust-src
            stable.rustc
            stable.rustfmt

            rust-analyzer
          ];

        naersk = naersk.lib."${system}".override {
          cargo = self.rustToolchain;
          rustc = self.rustToolchain;
        };
      }); # end packages
    };
}
