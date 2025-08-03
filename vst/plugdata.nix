{ lib
, stdenv
, fetchFromGitHub
, ensureNewerSourcesForZipFilesHook
, makeDesktopItem
, graphicsmagick
, cmake
, pkg-config
, alsa-lib
, freetype
, webkitgtk_4_1
, curl
, xorg
, python3
}:

let
  # copied from build system: https://build.opensuse.org/package/view_file/home:plugdata/plugdata/PlugData.desktop
  desktopItem = makeDesktopItem {
    name = "PlugData";
    desktopName = "PlugData";
    icon = "PlugData";
    exec = "plugdata";
    comment = "Pure Data as a plugin, with a new GUI";
    type = "Application";
    categories = [ "AudioVideo" "Music" ];
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "plugdata";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "plugdata-team";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-156y/L2mNh/09UhsRk0etQyhr8K2Ry61SnFAKlXssLc=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ensureNewerSourcesForZipFilesHook graphicsmagick python3 ];
  buildInputs = [
    alsa-lib
    freetype
    webkitgtk_4_1
    curl
    xorg.libX11
    xorg.xrandr
    xorg.libXext
    xorg.libXinerama
    xorg.libXrender
    xorg.libXinerama
    xorg.libXcursor
  ];

  patchPhase = ''
    set -x
    # Don't build LV2 plugin (it hangs), and don't automatically install
    sed -i 's/ LV2 / /g' CMakeLists.txt
  '';

  installPhase = ''
    runHook preInstall

    cd .. # build artifacts get put in the directory above the source directory for some reason?
    mkdir -p $out/{bin,lib/{clap,vst3}}
    cp    Plugins/Standalone/plugdata      $out/bin
    cp -r Plugins/CLAP/plugdata{,-fx}.clap $out/lib/clap
    cp -r Plugins/VST3/plugdata{,-fx}.vst3 $out/lib/vst3
    # cp -r Plugins/LV2/plugdata{,-fx}.lv2   $out/lib/lv2

    install -m444 -D "${desktopItem}"/share/applications/* -t $out/share/applications
    runHook postInstall
  '';

  meta = with lib; {
    description = "Plugin wrapper around Pure Data to allow patching in a wide selection of DAWs";
    homepage = "https://plugdata.org/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ PowerUser64 ];
  };
})
