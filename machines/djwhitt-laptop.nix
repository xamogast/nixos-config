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
      ../private/djwhitt-laptop-tahoe-lafs.nix
    ];

  #############################################################################
  ### Boot and Hardware

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelModules = [ "virtio" ];

  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-uuid/de3fc10d-39aa-4508-96b8-2a7fd625ccd8";
      preLVM = true;
      allowDiscards = true;
    }
  ];

  hardware.enableAllFirmware = true;

  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
  };

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
  networking.firewall.allowedTCPPorts = [ 3457 3458 ];
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  #############################################################################
  ### Power Management

  services.logind.extraConfig = "HandleLidSwitch=ignore";

  #############################################################################
  ### Services

  services.avahi = {
    enable = true;
    nssmdns = true;
  };
  services.bitlbee.enable = true;
  services.openssh.enable = true;
  services.postgresql = {
    enable = true;
    authentication =  pkgs.lib.mkOverride 10 ''
      local all all              ident
      host  all all 127.0.0.1/32 md5
      host  all all ::1/128      md5
      '';
  };
  services.printing.enable = true;

  #############################################################################
  ### Users

  security.sudo.wheelNeedsPassword = false;

  users.extraUsers.djwhitt = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/djwhitt";
    shell = "/run/current-system/sw/bin/zsh";
    extraGroups = [ "libvirtd" "wheel" ];
  };

  #############################################################################
  ### X

  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;

  # Video
  services.xserver.videoDrivers = [ "modesettings" ];

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

  virtualisation.libvirtd = {
    enable = true;
    enableKVM = true;
  };

  nixpkgs.config = {
    allowUnfree = true;

    chromium = {
      enablePepperFlash = true;
      enablePepperPDF = true;
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
    copyq
    dmenu
    dunst
    emacs25
    evince
    gitAndTools.git-annex
    glxinfo
    gnome3.adwaita-icon-theme
    gnome3.dconf
    gnome3.gedit
    gnome3.gnome_themes_standard
    heroku
    hexchat
    i3lock-fancy
    i3status
    jq
    keychain
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
    ranger
    redshift
    ruby
    slack
    sqlite-interactive
    sylpheed
    texlive.combined.scheme-full
    tig
    tmate
    universal-ctags
    usbutils
    virtmanager
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
