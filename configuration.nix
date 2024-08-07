# vim: et ts=2 sw=2 listchars+=leadmultispace\:\⎸\  list
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub = {
  enable = false;
  device = "nodev";
  efiSupport = true;
  gfxmodeEfi = "1920x1080";
  useOSProber = true;
  # Minegrub theme
  theme = pkgs.stdenv.mkDerivation {
    name = "minegrub-world-sel-theme-manual";
    src = pkgs.fetchFromGitHub {
      owner = "Lxtharia";
      repo = "minegrub-world-sel-theme";
      rev = "90aa7a546d7e9a6de33b5f152a677c7ff8720e84";
      hash = "sha256-uhTUsI9bRr/TWQL9BqWT4OB74isQjVJdHvpgW/w4ayE=";
    };
    installPhase = ''
      cp -r minegrub-world-selection $out
    '';
  };
  splashImage = "/boot/dirt.png";
  # Add UEFI option
  extraEntries = ''
    # Uefi Settings
    if [ "''${grub_platform}" == "efi" ]; then
      menuentry 'UEFI Firmware Settings' --class uefi --id 'uefi-firmware ' {
        fwsetup
      }
    fi
  '';
  };
  boot.loader.timeout = 10;

  networking.hostName = "Vanixlin"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.hosts = {
    "127.0.0.1" = [ "localhost" ];
    "192.168.2.222" = [ "cassis" "cassis.local" "cassis.lan" ];
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # use resolved cause it suddenly broke?
  services.resolved.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Set hardwareclock to local time like windows does
  time.hardwareClockInLocalTime = true;

  # Select internationalisation properties.
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

  # Select fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" "FiraCode" "IntelOneMono" ]; })
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
  ];

  # Scanner stuff
  hardware.sane.enable = true; # enables support for SANE scanners
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];
  # services.ipp-usb.enable=true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.sway.enable = true;
  # programs.hyprland.enable = true;

  # XDG Desktop Portal Configuration
  xdg.portal.wlr.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-kde ];
  xdg.portal.enable = true;
  xdg.portal.config = {
    # Default portals for all desktops:
    common = {
      "org.freedesktop.impl.portal.FileChooser" = [ "kde" "gtk" ];
    };
    # On sway use kde or gtk, but use wlr for screenshot and screencast
    sway = {
      "default" = [ "kde" "gtk" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Mounting samba is horrible, when it's not available. It just lags out the file manager and terminal
#  fileSystems."/home/lin/cloud" = {
#    device = "//cassis/cloud";
#    fsType = "cifs";
#    options = [
#      "credentials=/home/lin/.smb/creds"
#      "uid=lin"
#      "x-systemd.automount"
#    ];
#  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lin = {
    isNormalUser = true;
    description = "Lin";
    extraGroups = [ "networkmanager" "wheel" "scanner" ];
    shell = pkgs.zsh;
    packages = import ./user_packages.nix pkgs;
  };
  programs.steam = {
    enable = true;
  };

  services.syncthing = {
    enable = true;
    user = "lin";
    dataDir = "/home/lin/Documents";    # Default folder for new synced folders
    configDir = "/home/lin/.config/syncthing";   # Folder for Syncthing's settings and keys
  };

  # I don't know what this does, but for now it does nothing i think
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages

  ];


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Automatically optimize storage space: https://nixos.wiki/wiki/Storage_optimization
  nix.optimise.automatic = true;

  # Some environmental variables
  environment.variables = {
    "EDITOR" = "nvim";
  };
  environment.sessionVariables = {
    "GTK_USE_PORTAL" = "1";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Essentials
    bash
    git
    vim
    neovim
    wget
    # Important
    zsh
    cifs-utils
    tree
    htop
    # Other packages
    nh
    dig
    usbutils
    # Bigger packages
    wireguard-tools
    wgnord
    # languages
    gcc
    rustup
  ];

  # Only works if neovim enabled and managed over nix
  programs.neovim.defaultEditor = true;
  programs.zsh.enable = true;
  programs.java.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable avahi to find network scanner
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;

  # Enable Samba for NetBIOS name stuff
  # services.samba.nsswins = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
