, pkgs
, ...
}:

{
  home.username = "demo";
  home.homeDirectory = "/home/demo";

  services.mopidy.enable = true;
  services.mopidy.extensionPackages = [ pkgs.mopidy-mpd ];
  home.stateVersion = "22.11";
}
