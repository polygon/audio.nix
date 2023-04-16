{ self }:
{ pkgs, config, ... }:
{ imports = [ 
    (import ./drumkits.nix { inherit self; }) 
    (import ./rvxx.nix { inherit self; })
    (import ./audioenv.nix { inherit self; })
    (import ./x42.nix { inherit self; })
  ];
}