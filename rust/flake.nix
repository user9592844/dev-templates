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
              cargo-llvm-cov
              cargo-nextest
              cargo-udeps
              cargo-watch

              bat
              fd
              helix
              lldb
              lsd
              openocd
              probe-rs-tools
              ripgrep
            ];

            # Tooling to compile the source on the development platform
            nativeBuildInputs = [ self.packages."${system}".rustToolchain ];

            shellHooks = ''
              cargo watch -x check -x test -x run
            '';
          };
        }); # end devShells

      packages = forEachSupportedSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          naersk' = pkgs.callPackage naersk {
            cargo = self.packages."${system}".rustToolchain;
            rustc = self.packages."${system}".rustToolchain;
          };
        in {
          rustToolchain = with fenix.packages."${system}";
            combine [
              stable.cargo
              stable.clippy
              stable.rust-src
              stable.rustc
              stable.rustfmt

              targets.aarch64-unknown-linux-gnu.stable.rust-std
              targets.riscv32imac-unknown-none-elf.stable.rust-std

              stable.rust-analyzer
            ];

          # Build the crate using as a host system binary
          native = naersk'.buildPackage {
            src = ./.;
            RUSTC_LINKER = "${pkgs.mold}/bin/mold";
          };

          # TODO (user9592844): Figure out a way to streamline this
          # Build the crate as an ARM64 Linux binary
          aarch64-unknown-linux-gnu = naersk'.buildPackage {
            src = ./.;
            CARGO_BUILD_TARGET = "aarch64-unknown-linux-gnu";
            CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER =
              let inherit (pkgs.pkgsCross.aarch64-multiplatform.stdenv) cc;
              in "${cc}/bin/${cc.targetPrefix}cc";
          };

          # TODO (user9592844): Figure out a way to streamline this
          # Build the crate as a RISC-V 32-bit bare-metal binary
          riscv32imac-unknown-none-elf = naersk'.buildPackage {
            src = ./.;
            CARGO_BUILD_TARGET = "riscv32imac-unknown-none-elf";
            CARGO_TARGET_RISCV32IMAC_UNKNOWN_NONE_ELF_LINKER =
              let inherit (pkgs.pkgsCross.riscv32-embedded.stdenv) cc;
              in "${cc}/bin/${cc.targetPrefix}.cc";

          };
        }); # end packages
    };
}
