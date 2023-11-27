{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSystem = nixpkgs.lib.genAttrs systems;
    forEachPkgs = f: forEachSystem (sys: f nixpkgs.legacyPackages.${sys});
    conformance' = pkgs: (pkgs.callPackage ./conformance.nix {});
  in {
    formatter = forEachPkgs (pkgs: pkgs.alejandra);
    packages = forEachPkgs (pkgs: rec {
      default = conformanceTest;
      conformance = conformance' pkgs;
      conformanceTest = conformance.conformanceTest {
        rootURL = "http://127.0.0.1:3001";
        namespace = "testing";
        crossmountNamespace = "other-testing";
      };
    });
  };
}
