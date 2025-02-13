{
  description = "Rust Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    rust-overlay.url = "github:oxalica/rust-overlay";
    makes.url = "github:fluidattacks/makes";
  };

  outputs = { self, nixpkgs, makes, rust-overlay }:
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
        let
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs { inherit system overlays; };
        in {
          default = with pkgs;
            mkShell {
              # Developer Utilities
              packages = [
                # Cargo Tools
                cargo-audit
                cargo-expand
                cargo-tarpaulin
                cargo-nextest
                cargo-udeps
                cargo-watch

                # Nix Tools
                deadnix
                statix

                # Developer Tools
                fd
                helix
                lldb
                lsd
                ripgrep
                rust-analyzer

                # CICD Tools
                makes.packages."${system}".default
              ];

              # Project Build Dependencies
              buildInputs = [ rust-bin.beta.latest.default ];
            };
        });
    };
}
