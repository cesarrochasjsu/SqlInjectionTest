{ mkDerivation, base, HDBC, HDBC-sqlite3, lib }:
mkDerivation {
  pname = "SqlInjectionTest";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base HDBC HDBC-sqlite3 ];
  license = lib.licenses.bsd3;
  mainProgram = "SqlInjectionTest";
}
