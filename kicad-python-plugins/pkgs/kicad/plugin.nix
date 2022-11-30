{ pkgs
, stdenv
, ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kicadComponentLayout";
  version = "65f349a";

  src = pkgs.fetchFromGitHub {
    owner = "mcbridejc";
    repo = "kicad_component_layout";
    rev = "65f349a";
    hash = "sha256-C9mws9LgReoxlqJEHXl17Mh2uwKCVVj4BU/3qiZWjao=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm444 $src/component_layout_plugin.py -t $out/plugins
    runHook postInstall
  '';
})
