{
  description = "Sia renterd";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";

  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        renterd = with pkgs;
          let
            zipUrl = if stdenv.isDarwin then {
              url =
                "https://github.com/SiaFoundation/renterd/releases/download/v1.0.6/renterd_darwin_amd64.zip";
              hash = "sha256-YTJcJC52ZNswUrVclcYMiEfJKfEoJ1/X7p6nrEkGAg0=";
              stripRoot = false;
            } else {
              url =
                "https://github.com/SiaFoundation/renterd/releases/download/v1.0.6/renterd_linux_amd64.zip";
              hash = "sha256-PGDwmwhXu8d6ivZ4GWVyPK+Z4FrEDRjnVqQsK5vouDE=";
              stripRoot = false;
            };

          in stdenv.mkDerivation {
            name = "renterd";
            src = fetchzip zipUrl;
            installPhase = ''
              mkdir -p $out/bin
              cp -v renterd $out/bin
            '';
          };

      in {
        packages = { inherit renterd; };

        apps = {
          renterd = {
            type = "app";
            program = "${renterd}/bin/renterd";
          };
        };

        devShells.default = pkgs.mkShell { packages = [ renterd ]; };
      });
}
