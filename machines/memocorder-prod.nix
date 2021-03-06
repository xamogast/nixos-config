{ config, pkgs, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/virtualisation/amazon-image.nix>
      ../config/base.nix
      ../private/hosts.nix
    ];

  #############################################################################
  ### EC2

  ec2.hvm = true;

  #############################################################################
  ### Nix

  system.autoUpgrade.enable = true;

  #############################################################################
  ### Networking

  networking.hostName = "memocorder-prod";
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  #############################################################################
  ### Users

  security.sudo.wheelNeedsPassword = false;

  users.extraUsers = {
    djwhitt = {
      isNormalUser = true;
      home = "/home/djwhitt";
      shell = "/run/current-system/sw/bin/bash";
      extraGroups = [ "wheel" ];
    };
    memocorder = {
      home = "/srv/memocorder";
      shell = pkgs.bashInteractive;
    };
  };

  #############################################################################
  ### Services

  services.redis.enable = true;

  # Memocorder
  systemd.services.memocorder = {
    enable = true;
    description = "Memocorder Server";
    path = [ pkgs.bash ];
    after = [ "network.target" ];
    wants = [ "network.target" ];
    serviceConfig = {
      WorkingDirectory = "/srv/memocorder/memocorder";
      ExecStart = "/var/setuid-wrappers/su - -c \"cd memocorder && nix-shell . --run 'boot run' \" memocorder";
      Restart = "always";
      RestartSec = 30;
    };
  };

  #############################################################################
  ### Sites

  services.nginx = {
    enable = true;

    virtualHosts = {
      "memocorder.com" = {
        port = 443;
        enableSSL = true;
        forceSSL = true;
        sslCertificate = "/srv/memocorder/certs/memocorder_com-bundle.crt";
        sslCertificateKey = "/srv/memocorder/certs/memocorder_com.key";

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:4000";
            extraConfig = ''
              proxy_set_header    Host                $host:$server_port;
              proxy_set_header    X-Real-IP           $remote_addr;
              proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;
              proxy_set_header    X-Forwarded-Proto   $scheme;
              proxy_set_header    X-Frame-Options     SAMEORIGIN;
              proxy_redirect      http:// https://;
            '';
          };

          "/chsk" = {
            proxyPass = "http://127.0.0.1:4000";
            extraConfig = ''
              proxy_http_version  1.1;
              proxy_set_header    Upgrade             $http_upgrade;
              proxy_set_header    Connection          "upgrade";
              proxy_set_header    Host                $host:$server_port;
              proxy_set_header    X-Real-IP           $remote_addr;
              proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;
              proxy_set_header    X-Forwarded-Proto   $scheme;
              proxy_set_header    X-Frame-Options     SAMEORIGIN;
              proxy_redirect      http:// https://;
            '';
          };
        };
      };
    };
  };
}
