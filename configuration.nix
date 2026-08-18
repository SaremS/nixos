{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./configs/tmux.nix
      ./configs/flyline.nix
      ./configs/ssh.nix
      ./configs/nvim.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  networking.networkmanager.enable = true;

  programs.hyprland.enable = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.sarem = import ./home.nix;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  services.xserver.xkb = {
    layout = "de";
    variant = "";
    options = "caps:escape,ctrl:swap_lalt_lctl";
  };

  console.keyMap = "de";

  users.users."sarem" = {
    isNormalUser = true;
    description = "sarem";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neovim
    foot
    kitty
    waybar
    wofi
    google-chrome
    swaybg
    pywal16
    tmux
    nnn
    bibata-cursors
    git
    go
    ffuf
    nuclei
    katana
    nmap
    chisel
    wget
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      monospace = [
        "JetBrainsMono Nerd Font"
        "JetBrains Mono"
      ];
    };
  };

  services.greetd = {
    enable = true;

    settings = {
      initial_session = {
        command = "Hyprland --config /home/sarem/.config/hypr/hyprland.conf";
        user = "sarem";
      };

      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd 'Hyprland --config /home/sarem/.config/hypr/hyprland.conf'";
        user = "greeter";
      };
    };
  };

  system.stateVersion = "26.05"; 
}
