{
  description = "A simple zig development environment that exposes the latest zig version";
  inputs = rec {
   
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zig-overlay.url = "github:mitchellh/zig-overlay";
    zig-overlay.inputs.nixpkgs.follows = "nixpkgs";

    zls-overlay.url = "github:zigtools/zls";
    zls-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, zig-overlay, zls-overlay, ... } @ inputs: let
    supportedSystems = builtins.attrNames inputs.zig-overlay.packages;
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    #pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system}.extend zig.overlays.default);
    pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
    zig = forAllSystems (system: inputs.zig-overlay.packages.${system}.master);
  in {
    devShells = forAllSystems (system: {
      default = pkgs.${system}.mkShell {
#        LD_LIBRARY_PATH = with pkgs.${system}; lib.makeLibraryPath [
#          stdenv.cc.cc
#          SDL2
#        ];

        nativeBuildInputs = [
          zig-overlay.packages.${system}.master
          zls-overlay.packages.${system}.zls
        ];

        packages = with pkgs.${system}; [
          #zig
          #zls # lsp
          #zls-overlay.packages.master
          SDL2
          SDL2_ttf
          pkg-config # this is insane but SDL2 libs are capitalized and this
                     # package allows for case insensitivity for SDL.zig?!!?!
        ];
      };
    });
  };
}
