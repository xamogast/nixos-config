# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  #############################################################################
  ### Imports

  imports =
    [ # Include the results of the hardware scan.
      ../hardware-configuration.nix
      ../config/base.nix
      ../private/mail.nix
      ../private/wifi.nix
      ../private/hosts.nix
    ];

  #############################################################################
  ### Boot

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-uuid/de3fc10d-39aa-4508-96b8-2a7fd625ccd8";
      preLVM = true;
      allowDiscards = true;
    }
  ];

  hardware.enableAllFirmware = true;

  #############################################################################
  ### Localization

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "US/Central";

  #############################################################################
  ### Networking

  networking.hostName = "djwhitt-laptop"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  #############################################################################
  ### Power Management

  services.logind.extraConfig = "HandleLidSwitch=ignore";

  #############################################################################
  ### Services

  services.avahi.enable = true;
  services.bitlbee.enable = true;
  services.openssh.enable = true;
  services.printing.enable = true;

  #############################################################################
  ### Users

  security.sudo.wheelNeedsPassword = false;

  users.extraUsers.djwhitt = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/djwhitt";
    shell = "/run/current-system/sw/bin/zsh";
    extraGroups = [ "vboxusers" "wheel" ];
  };

  #############################################################################
  ### X

  services.xserver.enable = true;

  services.xserver.exportConfiguration = true;

  # Keyboard
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "ctrl:nocaps";

  # Touchpad/mouse
  services.xserver.synaptics = {
    enable = true;
    accelFactor = "0.002";
    twoFingerScroll = true;
    horizTwoFingerScroll = false;
    horizEdgeScroll = false;
    palmDetect = true;
  };

  # Blank screen after 10 minutes
  services.xserver.serverFlagsSection = ''
    Option "BlankTime" "0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "10"
  '';

  services.xserver.windowManager.i3.enable = true;

  services.redshift = {
    enable = true;
    latitude = "43.0731";
    longitude = "-89.4012";
    temperature.day = 6200;
    temperature.night = 3700;
  };

  # Restart Redshift when X restarts
  systemd.user.services.redshift = {
    conflicts = [ "exit.target" ];
  };

  fonts = {
    fonts = with pkgs; [
      cantarell_fonts
      dejavu_fonts
      liberation_ttf
      powerline-fonts
      source-code-pro
      ttf_bitstream_vera
    ];
  };

  #############################################################################
  ### Packages

  programs.zsh.enable = true;
  programs.ssh.startAgent = true;

  virtualisation.virtualbox.host.enable = true;

  nixpkgs.config = {
    allowUnfree = true;

    chromium = {
      enablePepperFlash = true;
      enablePepperPDF = true;
    };

    virtualbox = {
      enableExtensionPack = true;
    };

    # Remove once fixed package is available
    packageOverrides = pkgs : {
      heroku = pkgs.callPackage ../pkgs/heroku/default.nix { };
    };
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    (hunspellWithDicts (with hunspellDicts; [en-us]))
    anki
    awscli
    bundler
    chromium
    dmenu
    dunst
    emacs25
    evince
    gitAndTools.git-annex
    gnome3.adwaita-icon-theme
    gnome3.gnome_themes_standard
    heroku
    hexchat
    i3lock-fancy
    i3status
    jq
    keychain
    leafpad
    libnotify
    libreoffice
    mplayer
    nix-repl
    nodejs
    obnam
    openjdk
    pciutils
    phantomjs2
    pwgen
    rake
    redshift
    ruby
    sqlite-interactive
    sylpheed
    texlive.combined.scheme-full
    tig
    universal-ctags
    usbutils
    x11_ssh_askpass
    xautolock
    xfontsel
    xorg.xbacklight
    zip
  ];

  environment.pathsToLink = [ "/include" ];

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";
}