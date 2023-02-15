# Building 'nix' for RISC-V

You'd be better off doing a cross build with nix working somewhere, but if not...

Bootstrap a nix binary by:

Installing dev dependencies that you can get away with from the package store.
```
apt install curl git build-essential vim autoconf pkg-config autoconf-archive jq libboost-dev libarchive-dev libsqlite3-dev libcurl4-openssl-dev libz2-dev liblzma-dev libedit-dev libarchive-dev libbrotli-dev libtool libsodium-dev libseccomp-dev libgc-dev libgtest-dev bison flex cmake libboost-context-dev libgmock-dev
```

Install the following with make and make install, assuming you don't care about the system you're on and you plan to lustrate it.
* https://github.com/nlohmann/json
* editline-1.17.1
* lowdown-VERSION_1_0_0

```
cd nix
./bootstrap
./configure ...
make
mkdir .bin
cd .bin
ln -s /path/to/compiled/nix nix
ln -s nix-daemon nix
ln -s nix-env nix
ln -s nix-${AS_NEEDED} nix
export PATH=${PATH}:/.../.bin
```

Create your nix build users, and the nix-daemon.

nix.conf:
```
allowed-users = *
auto-optimise-store = false
builders = 
cores = 0
experimental-features = nix-command flakes
extra-sandbox-paths = 
max-jobs = auto
require-sigs = true
sandbox = true
sandbox-fallback = false
substituters = https://cache.nixos.org/
system-features = nixos-test benchmark big-parallel kvm
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
trusted-substituters = 
trusted-users = root

# Fails in the debian
filter-syscalls = false

# DO NOT USE FULL FEATURED BUSYBOX, leaky, when building some tools like xz, tests will pull in busybox version not built version and tests fail.
# sandbox-paths = /bin/sh=/bin/busybox

# You'll want to swith to nix's bash once you have it built.  /bin/sh is bash 5.2 on nixos, so yes, /bin/sh needs to be bash.
sandbox-paths = /bin/sh=/bin/bash /lib/riscv64-linux-gnu/libtinfo.so.6=/lib/riscv64-linux-gnu/libtinfo.so.6.3 /lib/riscv64-linux-gnu/libdl.so.2=/lib/riscv64-linux-gnu/libdl-2.33.so /lib/riscv64-linux-gnu/libc.so.6=/lib/riscv64-linux-gnu/libc-2.33.so /lib/ld-linux-riscv64-lp64d.so.1=/lib/riscv64-linux-gnu/ld-2.33.so
```

Now you can build a proper nix.  Note, you're going to compile the whole world, so you might as well go outside and see a bit of it, or something.
```
nix build '.#hydraJobs.binaryTarball.riscv64-linux'
```

Notes:
libseccomp is in the deps, and if you're on a VisionFive with the debian kernel, it doesn't have seccomp, so that's going to fail tests, so you need to replace the kernel first.

Pinned nixpkgs to the system version so far to not need to rebuild the world.  
Disabled ld.gold on riscv, because that's not supported by gold.
```
diff --git a/flake.lock b/flake.lock
index 4490b5ead..adb3f11b7 100644
--- a/flake.lock
+++ b/flake.lock
@@ -18,11 +18,11 @@
     },
     "nixpkgs": {
       "locked": {
-        "lastModified": 1670461440,
-        "narHash": "sha256-jy1LB8HOMKGJEGXgzFRLDU1CBGL0/LlkolgnqIsF0D8=",
+        "lastModified": 1675614288,
+        "narHash": "sha256-i3Rc/ENnz62BcrSloeVmAyPicEh4WsrEEYR+INs9TYw=",
         "owner": "NixOS",
         "repo": "nixpkgs",
-        "rev": "04a75b2eecc0acf6239acf9dd04485ff8d14f425",
+        "rev": "d25de6654a34d99dceb02e71e6db516b3b545be6",
         "type": "github"
       },
       "original": {
diff --git a/flake.nix b/flake.nix
index 88ffcf333..c4d936d37 100644
--- a/flake.nix
+++ b/flake.nix
@@ -17,7 +17,7 @@
         then ""
         else "pre${builtins.substring 0 8 (self.lastModifiedDate or self.lastModified or "19700101")}_${self.shortRev or "dirty"}";
 
-      linux64BitSystems = [ "x86_64-linux" "aarch64-linux" ];
+      linux64BitSystems = [ "x86_64-linux" "aarch64-linux" "riscv64-linux" ];
       linuxSystems = linux64BitSystems ++ [ "i686-linux" ];
       systems = linuxSystems ++ [ "x86_64-darwin" "aarch64-darwin" ];
 
@@ -86,7 +86,7 @@
             "--with-boost=${boost}/lib"
             "--with-sandbox-shell=${sh}/bin/busybox"
           ]
-          ++ lib.optionals (stdenv.isLinux && !(isStatic && stdenv.system == "aarch64-linux")) [
+          ++ lib.optionals (stdenv.isLinux && !(isStatic && stdenv.system == "aarch64-linux") && !(stdenv.system == "riscv64-linux")) [
             "LDFLAGS=-fuse-ld=gold"
           ];
```
