{ compiler    ? "ghc822"
, doProfiling ? false
, doBenchmark ? false
, rev         ? "ee28e35ba37ab285fc29e4a09f26235ffe4123e2"
, sha256      ? "0a6xrqjj2ihkz1bizhy5r843n38xgimzw5s2mfc42kk2rgc95gw5"
, nixpkgs     ? import (builtins.fetchTarball {
    url    = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
    sha256 = sha256; }) {
    config.allowBroken = false;
    config.allowUnfree = true;

    config.packageOverrides = super: let pkgs = super.pkgs; in rec {
      z3 = pkgs.stdenv.lib.overrideDerivation super.z3 (attrs: rec {
        name = "z3-${version}";
        version = "4.6.0";
        src = super.fetchFromGitHub {
          owner  = "Z3Prover";
          repo   = "z3";
          rev    = "b0aaa4c6d7a739eb5e8e56a73e0486df46483222";
          sha256 = "1cgwlmjdbf4rsv2rriqi2sdpz9qxihxrcpm6a4s37ijy437xg78l";
        };
      });
    };
  }
}:

let inherit (nixpkgs) pkgs;

  haskellPackages = pkgs.haskell.packages.${compiler}.override {
    overrides = with pkgs.haskell.lib; self: super: rec {
    };
  };

in haskellPackages.developPackage {
  root = ./.;

  source-overrides = {
  };

  modifier = drv: pkgs.haskell.lib.overrideCabal drv (attrs: {
    libraryHaskellDepends = attrs.libraryHaskellDepends ++ [ pkgs.z3 ];

    enableLibraryProfiling    = doProfiling;
    enableExecutableProfiling = doProfiling;

    inherit doBenchmark;
  });
}
