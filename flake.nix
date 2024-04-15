{
  description = "Modern, pure OCaml socket pool for Riot.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    riot = {
      url = "github:riot-ml/riot";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.telemetry.follows = "telemetry";
    };

    telemetry = {
      url = "github:leostera/telemetry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          inherit (pkgs) ocamlPackages mkShell;
          inherit (ocamlPackages) buildDunePackage;
          name = "atacama";
          version = "0.0.5+dev";
        in
          {
            devShells = {
              default = mkShell {
                buildInputs = with ocamlPackages; [
                  dune_3
                  ocaml
                  utop
                  ocamlformat
                ];
                inputsFrom = [ self'.packages.default ];
                packages = builtins.attrValues {
                  inherit (ocamlPackages) ocaml-lsp ocamlformat-rpc-lib;
                };
              };
            };

            packages = {
              default = buildDunePackage {
                inherit version;
                pname = name;
                propagatedBuildInputs = with ocamlPackages; [
                  (mdx.override {
                    inherit logs;
                  })
                  odoc
                  inputs'.riot.packages.default
                  inputs'.telemetry.packages.default
                ];
                src = ./.;
              };
            };
          };
    };
}
