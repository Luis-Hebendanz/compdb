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
        default =
          let
            spkgs = pkgs.${system};
            pypkgs = pkgs.${system}.python310Packages;
          in
          pypkgs.buildPythonPackage {
            pname = "compdb";
            version = "0.2.0";
            src = self;

            doCheck = false;
            checkInputs = with spkgs; [ pypkgs.pytest gcc coreutils ];
            #propagatedBuildInputs = with pypkgs; [ click bashlex shutilwhich ];

            checkPhase = ''
              pytest
            '';
          };
      });



      devShells = forAllSystems (system: {
        default =
          let
            spkgs = pkgs.${system};
            pypkgs = pkgs.${system}.python310Packages;
          in
          pkgs.${system}.mkShellNoCC {
          packages = with spkgs; [
            pypkgs.pytest gcc coreutils
          ];
        };
      });
    };
}
