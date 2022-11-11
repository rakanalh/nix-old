# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, callPackage, ... }:

{
  imports =
    [ 
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.supportedFilesystems = [ "ntfs" ];
  fileSystems."/run/media/rakan/windows" = { 
    device = "/dev/nvme0n1p3";
    label = "Windows";
    fsType = "ntfs"; 
    options = [ "rw" "uid=1000" ];
  };
  fileSystems."/run/media/rakan/sd1" = {
    device = "/dev/sda";
    fsType = "auto";
    label = "SD1";
    options = [ "defaults" "user" "rw" "auto" ];
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Amman";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];

    # Enable the XFCE Desktop Environment.
    displayManager = {
      lightdm = {
        enable = true;
        greeters.gtk.extraConfig = "xft-dpi=72";
      };
      defaultSession = "none+awesome";
    };
    
    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks
        luadbi-mysql
      ];
    };

    desktopManager.xfce.enable = true;

    # Configure keymap in X11
    layout = "us,ara";
    xkbVariant = ",mac";
    xkbOptions = "grp:alt_space_toggle";
  };

  security.polkit.enable = true;
  security.rtkit.enable = true;

  hardware.keyboard.uhk.enable = true;
  hardware.keyboard.zsa.enable = true;

  # Nvidia
  hardware.opengl.enable = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.ledger.enable = true;
  hardware.video.hidpi.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable sound with pipewire.
  sound.enable = false;
  hardware.pulseaudio.enable = false;
  # hardware.pulseaudio.package = pkgs.pulseaudioFull;
  # hardware.pulseaudio.tcp.enable = true;
  # hardware.pulseaudio.tcp.anonymousClients.allowedIpRanges = [
  #   "127.0.0.1"
  #   "192.168.1.0/24"
  #   "192.168.14.0/24"
  #   "192.168.43.0/24"
  # ];
  # hardware.pulseaudio.daemon.config = {
  #   daemonize = "yes";
  # };
  # hardware.pulseaudio.extraClientConf = ''
  #   autospawn = yes;
  # '';
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  systemd.user.services.pipewire-pulse.path = [ pkgs.pulseaudio ];

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rakan = {
    isNormalUser = true;
    description = "Rakan";
    extraGroups = [ "audio" "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  fonts = {
    fontDir.enable = true;
    enableDefaultFonts = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      hack-font
      fira-code
      ubuntu_font_family
      liberation_ttf
      inconsolata
      noto-fonts
      noto-fonts-emoji
      iosevka
      (nerdfonts.override { fonts = [ "Hack" "Iosevka" ]; })
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    direnv
    vim
    wget
    polkit_gnome
  ];

  programs.vim.defaultEditor = true;
  programs.zsh.enable = true;
  programs.ssh.startAgent = true;
  programs.file-roller.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.plex = {
    enable = true;
    user = "rakan";
    openFirewall = true;
  };
  services.pipewire = {
    config.pipewire-pulse = {
      "context.properties" = {
        "log.level" = 2;
      };
      "context.modules" = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -15;
            "rt.prio" = 88;
            "rt.time.soft" = 200000;
            "rt.time.hard" = 200000;
          };
          flags = [ "ifexists" "nofail" ];
        }
        { name = "libpipewire-module-protocol-native"; }
        { name = "libpipewire-module-client-node"; }
        { name = "libpipewire-module-adapter"; }
        { name = "libpipewire-module-metadata"; }
        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            "pulse.min.req" = "32/48000";
            "pulse.default.req" = "32/48000";
            "pulse.max.req" = "32/48000";
            "pulse.min.quantum" = "32/48000";
            "pulse.max.quantum" = "32/48000";
            "server.address" = [ "unix:native" ];
          };
        }
      ];
      "stream.properties" = {
        "node.latency" = "32/48000";
        "resample.quality" = 1;
      };
    };
  };
  services.lorri.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;
  services.actkbd.enable = true;
  virtualisation.docker.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.extraHosts = ''
    3.65.111.62 my-efinity.io
    3.210.250.187 efinity-remote-builds
    54.228.22.78 buildbot-worker1
    34.252.13.18 buildbot-worker2
    54.76.195.127 buildbot-worker3	
    34.240.40.232 buildbot-worker4
    176.34.129.233 buildbot-worker5
  '';

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
