{ lib
, libsForQt5
, qt5
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, alsa-lib
, pandoc
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kmidimon";
  version = "1.4.1";
  src = fetchFromGitHub {
    owner = "pedrolcl";
    repo = "kmidimon";
    rev = "RELEASE_1_4_0";
    hash = "sha256-rsd4tG7tEyAMxGjletH24cP4c7BFGxGWxZXb+sgTH8I=";
  };

  nativeBuildInputs = [ cmake pkg-config qt5.wrapQtAppsHook pandoc ];

  cmakeFlags = [ "-DUSE_QT5=On" ];

  # Patch accuracy of seconds display
  prePatch = ''
    substituteInPlace src/sequencemodel.cpp --replace "itm.getSeconds(), 'f', 4" "itm.getSeconds(), 'f', 6"
  '';

  buildInputs = [
    qt5.qtbase
    qt5.qttools
    alsa-lib
  ] ++ (with libsForQt5; [ drumstick ]);
})
