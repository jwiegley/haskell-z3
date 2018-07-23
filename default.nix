{ compiler    ? "ghc822"
, rev         ? "49bdae006e66e70ad3245a463edc01b5749250d3"
, sha256      ? "1ijsifmap47nfzg0spny94lmj66y3x3x8i6vs471bnjamka3dx8p"
, pkgs        ? import (builtins.fetchTarball {
    url    = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
    sha256 = sha256; }) {
    config.allowBroken = false;
    config.allowUnfree = true;

    config.packageOverrides = super: let pkgs = super.pkgs; in rec {
      z3 = pkgs.stdenv.lib.overrideDerivation super.z3 (attrs: rec {
        name = "z3-${version}";
        version = "4.6.0";
        src = pkgs.fetchFromGitHub {
          owner  = "Z3Prover";
          repo   = "z3";
          rev    = "b0aaa4c6d7a739eb5e8e56a73e0486df46483222";
          sha256 = "1cgwlmjdbf4rsv2rriqi2sdpz9qxihxrcpm6a4s37ijy437xg78l";
        };
      });
    };
  }
, returnShellEnv ? pkgs.lib.inNixShell
}:

let haskellPackages = pkgs.haskell.packages.${compiler};

in haskellPackages.developPackage {
  root = ./.;

  source-overrides = {
    exceptions = "0.10.0";
  };

  modifier = drv: pkgs.haskell.lib.overrideCabal drv (attrs: {
    libraryHaskellDepends = attrs.libraryHaskellDepends ++ [ pkgs.z3 ];
  });

  inherit returnShellEnv;
}
