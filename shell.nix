{ ps ? import <nixpkgs> {}
, nixpkgs ?  import (ps.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "f75d62941d8ad616bfc334ae19d71a0a6677dd19";
    sha256 = "0n88r4fw1syad9zl7r40r7xlxwx38ni8s9hzyayxssr21ii2p38h";
}) {}
, ghcVersion ? "ghc865"
}:
with nixpkgs;
let
  drv = import ./. { inherit ghcVersion;};
  hie = 
    ((import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {})
    .selection { selector = p: { ${ghcVersion} = p.${ghcVersion}; }; });

in 
drv.env.overrideAttrs (shellEnv: {
  buildInputs = shellEnv.buildInputs ++ [
    cabal2nix
    hie
    (vscode-utils.vscodeEnv {
      #usually this path go to tmp but feel free to change it wherever you think it is good place to the "fake" global folder
      #putting it on empty string will leave the default one.
      user-data-dir = "./.vscode-globalUserData";
      #this file will be updated/created automaticly by vscode in result of using vscode GUI to install/uninstall extensions(can be changed manually to)
      mutableExtensionsFile = ./mutable-extensions.nix;
      #this extensions will be stored in the nix store and cannot be modified from vscode GUI
      nixExtensions = [
        { name = "vscode-hie-server"; publisher = "alanz"; version = "0.0.40"; sha256 = "1cmlgidjma41s5zq5161gcxxmk5lfzcm8dvznls04y5l7q9b0gca";  }
        { name = "language-haskell"; publisher = "justusadam"; version = "3.2.0"; sha256 = "190h1hky2yy5n00ncqf15mmaizgpm3w9pzvasmi2gangpg4qb6y5";  }
      ];

      # configuration for settings files- those will be overrides/create over the one in .vscode folder
      # settings = {};
      # keybindings ={};
    })
  ];

  shellHook = ''
    echo 'to start editor with HIE run on the root of the folder: code .'
  '';
})
