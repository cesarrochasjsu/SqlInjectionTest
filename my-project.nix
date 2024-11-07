{ mkDerivation, base, bytestring, HDBC, HDBC-sqlite3, hspec, HUnit
, lib, QuickCheck
}:
mkDerivation {
  pname = "SqlInjectionTest";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base bytestring HDBC HDBC-sqlite3 hspec HUnit QuickCheck
  ];
  testHaskellDepends = [ base hspec HUnit QuickCheck ];
  license = lib.licenses.bsd3;
  mainProgram = "SqlInjectionTest";
}
