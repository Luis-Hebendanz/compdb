{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
      myapp = forAllSystems (system: pkgs.${system}.poetry2nix.mkPoetryApplication { projectDir = self; });
    in
    rec {
      packages = forAllSystems (system: {
        default = myapp;
      });

    # apps = forAllSystems (system: {
    #     default = {
    #       program = pkgs.writeShellScriptBin "compdb" ''
    #         ${pkgs.python}/bin/python ${myapp}/lib/python3.10/site-packages/compdb
    #       '';
    #       type = "app";
    #     };
    #   });

      devShells = forAllSystems (system: {
        default = pkgs.${system}.mkShellNoCC {
          packages = with pkgs.${system}; [
            (poetry2nix.mkPoetryEnv { projectDir = self; })
            poetry
          ];
        };
      });
    };
}
