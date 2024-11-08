{ mkDerivation, base, bytestring, HDBC, HDBC-sqlite3, hspec, HUnit
, lib, QuickCheck, scotty
}:
mkDerivation {
  pname = "SqlInjectionTest";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base bytestring HDBC HDBC-sqlite3 hspec HUnit QuickCheck scotty
  ];
  testHaskellDepends = [
    base bytestring HDBC HDBC-sqlite3 hspec HUnit QuickCheck
  ];
  license = lib.licenses.bsd3;
  mainProgram = "SqlInjectionTest";
}
