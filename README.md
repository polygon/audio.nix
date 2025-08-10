# Audio.nix

Assorted audio packages for Nix(OS)/Linux.

* Bitwig Studio Beta versions
* Neuralnote
* Paulxstretch
* Atlas 2
* Audio Assault AmpLocker
* A number of CHOW plugins
* PAPU
* [IEM Plugin Suite](https://git.iem.at/audioplugins/IEMPluginSuite)
* Some other stuff

Mostly things I use myself, provided as-is. Please see [here](#non-support) before opening tickets.

## Usage

You can run standalone versions of most Bitwig and most plugins:

* `nix run github:polygon/audio.nix#neuralnote`
* `nix run github:polygon/audio.nix#paulxstretch`
* `nix run github:polygon/audio.nix#bitwig-studio5-latest`

To use the plugins from within Bitwig, you want to install them into your environment. Add the package to your flake inputs. In case you want to mix plugins and tools from this Flake and regular Nixpkgs, you want to make sure that the versions match up to minimize chances of incompatibilities. I recommend taking `nixpkgs` from your system flake. Be mindful of this when mixing stable and unstable as well.

```
audio = {
    url = "github:polygon/audio.nix";
    inputs.nixpkgs.follows = "nixpkgs";
};
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

## Dev Support

The `devShells.x86_64-linux.juce` output provides a devshell to jumpstart building JUCE based plugins in Nix. It contains the common dependencies and other options usually required for JUCE applications to build. `templates/juce-plugin.nix` can be used as a starting point for building a Nix package of a JUCE plugin. It is commented with the required changes that need to be made.

It is recommended to first get a new plugin to build using the devshell and once that is done, create the actual package.

## (Non-)Support

I started this mainly to improve my own audio environment. Since some recent additions may provide some value to others, I decided to make this public. I already spend a lot of my spare time on this instead of making music so I will not provide support unless the issue also affects me. Everything is provided as-is.

Pull-requests are welcome.
