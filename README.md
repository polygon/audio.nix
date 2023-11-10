# Audio.nix

Assorted audio packages for Nix(OS)/Linux.

* Bitwig Studio Beta versions
* Neuralnote
* Paulxstretch
* Atlas 2
* Audio Assault AmpLocker
* Some other stuff

Mostly things I use myself, provided as-is. Please see [here](#non-support) before opening tickets.

## Usage

You can run standalone versions of most Bitwig and most plugins:

* `nix run github:polygon/audio.nix#neuralnote`
* `nix run github:polygon/audio.nix#paulxstretch`
* `nix run github:polygon/audio.nix#bitwig-studio5-latest`

To use the plugins from within Bitwig, you want to install them into your environment. Add the package to your flake inputs:

```
audio.url = "github:polygon/audio.nix";
```

Then add the overlay to your system configuration.

```
nixpkgs.overlays = audio.overlays.default;
```

Then install as normal:

```
environment.systemPackages = with pkgs; [
    neuralnote
    bitwig-studio5-latest
];
```

Don't mix stable and unstable within your audio environment (DAW + plugins) as it tends to just not work well. If plugins are not loaded, you can check with `ldd` if dependency and especially glibc-versions are the same.

## (Non-)Support

I started this mainly to improve my own audio environment. Since some recent additions may provide some value to others, I decided to make this public. I already spend a lot of my spare time on this instead of making music so I will not provide support unless the issue also affects me. Everything is provided as-is.

Pull-requests are welcome.