{
  description = "An C/C++ Development Environment";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11"; };

  outputs = { self, nixpkgs }:
    let forEachSupportedSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in {
      devShells = forEachSupportedSystem (system:
        let pkgs = nixpkgs.legacyPackages."${system}";
        in {
          default = (pkgs.buildFHSEnv {
            name = "c-devenv";
            stdenv =
              pkgs.gccStdenv; # Using GCC since some tools (Buildroot) depend on it

            targetPkgs = pkgs:
              (with pkgs;
                [
                  # List any required dev tooling here
                  binutils
                  cmake
                  file
                  (lib.hiPrio gcc)
                  gdb
                  gnumake
                  gtest
                  just
                  ncurses.dev
                  ninja
                  pkg-config
                  renode
                  unzip
                  wget

                  # List any cross-compilation target toolchains here; examples below
                  # pkgs.pkgsCross.riscv64.gccStdenv.cc
                  # pkgs.pkgsCross.aarch64-multiplatform
                ] ++ pkgs.linux.nativeBuildInputs);

            runScript = "bash";
          }).env;
        });
    };
}
