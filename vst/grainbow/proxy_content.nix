{ fetchurl }: [
  {
    url =
      "https://github.com/StrangeLoopsAudio/libonnxruntime-basicpitch/releases/download/release/onnxruntime-v1.14.1-basicpitch-linux-x86_64.tar.gz";
    file = fetchurl {
      url =
        "https://github.com/StrangeLoopsAudio/libonnxruntime-basicpitch/releases/download/release/onnxruntime-v1.14.1-basicpitch-linux-x86_64.tar.gz";
      hash = "sha256-mxMXp5llTwgc5fRnTpLYKVVuakL0Nv5NBTOnmkDuLZQ=";
    };
  }
  {
    url =
      "https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.38.6/CPM.cmake";
    file = fetchurl {
      url =
        "https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.38.6/CPM.cmake";
      hash = "sha256-EcP6XxuhTxXTHC+2PbyGKO4TPYHI12TKrZqNueC6ywc=";
    };
  }
]
