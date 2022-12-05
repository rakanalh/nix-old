set -x
set -e 

sudo nix-channel --update
sudo nixos-rebuild switch
nix-channel --update
home-manager switch
sudo nix-collect-garbage -d
