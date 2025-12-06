# Devshell that makes most JUCE based projects build
# Can be used to prototype builds before transitioning to a full
# Nix based build
# Also has some debugging tools available (patchelf, gdb)
{ 
  mkShell
, freetype
, alsa-lib
, webkitgtk_4_1
, curl
, gtk3
, xorg
, pcre2
, pcre
, libuuid
, libselinux
, libsepol
, libthai
, libdatrie
, libxkbcommon
, libepoxy
, libpsl
, libsysprof-capture
, sqlite
, cmake
, pkg-config
, jack2
, patchelf
, gdb
}:
mkShell { 
  buildInputs = [
    freetype
    alsa-lib
    webkitgtk_4_1
    curl
    gtk3
    jack2
    xorg.libX11
    xorg.libX11.dev
    xorg.libXext
    xorg.libXinerama
    xorg.xrandr
    xorg.libXcursor

    pcre2
    pcre
    libuuid
    libselinux
    libsepol
    libthai
    libdatrie
    libpsl
    xorg.libXdmcp
    libxkbcommon
    libepoxy
    xorg.libXtst
    libsysprof-capture
    sqlite.dev
  ];
  nativeBuildInputs = [
    cmake
    pkg-config
    patchelf
    gdb
  ];

  NIX_LDFLAGS = (toString [
    "-lX11"
    "-lXext"
    "-lXcursor"
    "-lXinerama"
    "-lXrandr"
  ]);
}
