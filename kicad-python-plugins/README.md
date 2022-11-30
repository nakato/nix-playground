# Kicad with Python Plugin

I'm going to want to use kicad eventually, and the ability to use plugins
is probably something I'll be interested in.

Kicad and python is never very easy to configure, so the ability to configure
it in a repeatable and isolated manner is immensely beneficial.

The details here are only half the story however, this is Python in Kicad.

There is also Kicad in Python. Kicad is listed in 
`pkgs/top-level-python-packages.nix`, which means it's even easier to setup
Kicad in Python.
```
with pkgs;
let
  python-with-kicad = python3.withPackages (p: with p; [ kicad ]);
in ...
```
No manually messing with python-path to get kicad's python module in path,
nor having to get the ffi to load.  Just `import pcbnew`!


Would be amazing if this could also manage kicad footprints, symbols, etc.
