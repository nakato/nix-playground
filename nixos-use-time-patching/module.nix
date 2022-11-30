{ pkgs
, ...
}:

{
  services.iwd = {
    enabled = true;
    package = (pkgs.iwd.override {
      ell = pkgs.ell.overrideAttrs (final: prev: rec {
        # Required for IWD 2.0.  Provides IPv6 improvments.
        version = "0.54";
        src = pkgs.fetchgit {
          url = "https://git.kernel.org/pub/scm/libs/ell/ell.git";
          rev = version;
          sha256 = "sha256-Oi+S4DWXuTUL36Xh3iWIZj9rdN2qUDHmZiFSH1csW+8=";
        };
      });
    }).overrideAttrs (final: prev: rec {
      # Enabling IPv6 on 1.30 puts it into an infinite loop.
      version = "2.0";
      src = pkgs.fetchgit {
        url = "https://git.kernel.org/pub/scm/network/wireless/iwd.git";
        rev = version;
        sha256 = "sha256-9eQ2fW3ha69ngugYonbYdqrpERqt8aM0Ed4HM0CrmUU=";
      };
    });
  };
}
