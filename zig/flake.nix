{
  description = "Zig Development Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    makes.url = "github:fluidattacks/makes";
  };

  outputs = { self, nixpkgs, makes }:
    let
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
          default = with pkgs;
            mkShell {
              packages = [
                # Nix Tools
                deadnix
                statix

                # Developer Tools
                fd
                lsd
                helix
                lldb
                ripgrep

                # CICD Tools
                makes.packages."${system}".default

                # Zig Tools
                zig
                zls
              ];
            };
        });
    };
}
