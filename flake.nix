{
  description = "Sia renterd";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        renterdPkg = with pkgs;
          let
            baseUrl =
              "https://github.com/SiaFoundation/renterd/releases/download";
            version = "v1.0.8";
            zipUrl = if stdenv.isDarwin then {
              url = "${baseUrl}/${version}/renterd_darwin_amd64.zip";
              hash = "sha256-k6wUwsTdrFF7l3sn2aEJpOksZ0PUWKVrNUqJ/gDzC/I=";
              stripRoot = false;
            } else {
              url = "${baseUrl}/${version}/renterd_linux_amd64.zip";
              hash = "sha256-2VE1HA1Bd4XiJ3UDfs9P/EV/XHMF0RjRfrS56Owmge4=";
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
        packages = {
          renterd = renterdPkg;
          default = renterdPkg;
        };

        apps = rec {
          renterd = {
            type = "app";
            program = "${renterdPkg}/bin/renterd";
          };
          default = renterd;
        };

        devShells.default =
          pkgs.mkShell { packages = [ pkgs.rclone renterdPkg ]; };
      });
}
