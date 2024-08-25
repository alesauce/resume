{
  description = "A Nix flake-based development environment for rendercv";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  in {
    pkgs = forAllSystems (localSystem: import nixpkgs {inherit localSystem;});
    formatter = forAllSystems (localSystem: self.pkgs.${localSystem}.alejandra);
    devShells = forAllSystems (
      localSystem:
        with self.pkgs.${localSystem}; {
          default = mkShell {
            name = "rendercv dev environment";
            nativeBuildInputs = [alejandra];
            venvDir = ".venv";
            packages =
              [python312]
              ++ (with python312Packages; [
                pip
                venvShellHook
              ]);
          };
        }
    );
  };
}
