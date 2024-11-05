let
  pkgs = import (fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b.tar.gz")
    { };
in pkgs.haskellPackages.shellFor {
  packages = hpkgs: [
    # reuse the nixpkgs for this package
    hpkgs.distribution-nixpkgs
    # call our generated Nix expression manually
    (hpkgs.callPackage ./my-project.nix { })
  ];

  # development tools we use
  nativeBuildInputs = [ pkgs.sqlite pkgs.cabal-install pkgs.cabal2nix ];

  # Extra arguments are added to mkDerivation's arguments as-is.
  # Since it adds all passed arguments to the shell environment,
  # we can use this to set the environment variable the `Paths_`
  # module of distribution-nixpkgs uses to search for bundled
  # files.
  # See also: https://cabal.readthedocs.io/en/latest/cabal-package.html#accessing-data-files-from-package-code
  distribution_nixpkgs_datadir = toString ./distribution-nixpkgs;
}
