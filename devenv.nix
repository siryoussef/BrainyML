{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "BrainyML memory extension environment active.";

  # https://devenv.sh/packages/
  packages = [
    pkgs.git
    pkgs.jq
    pkgs.unison-ucm
  ];

  # https://devenv.sh/languages/
  languages.python = {
    enable = true;
    package = pkgs.python312;
    venv.enable = true;
    venv.requirements = ''
      pandas>=2.0
      click>=8.0
      rdflib>=7.0
    '';
  };
  
  languages.unison.enable = true;

  # https://devenv.sh/scripts/
  scripts.hello.exec = "echo $GREET";

  scripts.parse-nell.exec = ''
    python scripts/parse_kg.py nell --input submodules/NELL/ --output unison/kg/generated/ "$@"
  '';

  scripts.parse-cskg.exec = ''
    python scripts/parse_kg.py cskg --input submodules/CSKG/ --output unison/kg/generated/ "$@"
  '';

  scripts.check-unison.exec = ''
    ucm transcript unison/**/*.u
  '';

  enterShell = ''
    hello
    python --version
    ucm --version
  '';
}
