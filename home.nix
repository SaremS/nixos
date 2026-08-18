{ config, pkgs, ... }:

{
  home.username = "sarem";
  home.homeDirectory = "/home/sarem";

  home.stateVersion = "26.05";


  xdg.configFile."hypr" = {
    source = ./dotfiles/hypr;
    recursive = true;
  };

  xdg.configFile."foot" = {
    source = ./dotfiles/foot;
    recursive = true;
  };

  xdg.configFile."wal" = {
    source = ./dotfiles/wal;
    recursive = true;
  };

  xdg.configFile."waybar" = {
    source = ./dotfiles/waybar;
    recursive = true;
  };

  home.file."Pictures/wallpapers/wallpaper.png".source = 
    ./dotfiles/wallpapers/wallpaper.png;

}

