# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      efiSupport = false;
      device = "/dev/nvme0n1"; # or "nodev" for efi only
    };
    tmpOnTmpfs = true;
    extraModprobeConfig = ''
      options snd_usb_audio vid=0x1235 pid=0x8214 device_setup=1
      # options thinkpad_acpi fan_control=1
    '';
    extraModulePackages = [ pkgs.linuxPackages_latest.v4l2loopback ];
    kernel.sysctl = {
      "net.core.rmem_max" = 2500000;
      "net.ipv4.ip_unprivileged_port_start" = 0;
    };
    kernelModules = [ "v4l2loopback" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  networking = {
    hostName = "kronos";
    networkmanager = {
      enable = true;
      # wifi.backend = "iwd";
      firewallBackend = "nftables";
      enableFccUnlock = true;
      dispatcherScripts = [
        {
          source = pkgs.writeText "aisecUpHook" ''
            #!${pkgs.bash}/bin/bash

            set -eu

            if [[ "$NM_DISPATCHER_ACTION" != "vpn-up" ]]; then
                exit
            fi

            if [[ "$CONNECTION_ID" != "AISEC-2FA" ]]; then
                exit
            fi

            resolvectl domain "$VPN_IP_IFACE" "~fraunhofer.de" "~aisec.fraunhofer.de"
          '';
        }
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_COLLATE = "de_DE.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MESSAGES = "en_US.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
      # LC_ALL = "en_US.UTF-8";
    };
  };
  console = {
    #   font = "Lat2-Terminus16";
    #   keyMap = "us";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    epiphany # web browser
    geary # email reader
    gnome-music
    gnome-software
    gnome-terminal
    totem # video player
  ]);


  programs = {
    nix-ld.enable = true;
    neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      defaultEditor = true;
    };

    git.enable = true;
    htop.enable = true;
    iftop.enable = true;
    iotop.enable = true;
    wireshark.enable = true;
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "gnome3";
    };

    evolution = {
      enable = true;
      plugins = [ pkgs.evolution-ews ];
    };
  };

  fonts = {
    fonts = with pkgs; [
      dina-font
      fira-code
      fira-code-symbols
      jetbrains-mono
      liberation_ttf
      mplus-outline-fonts.githubRelease
      nerdfonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      proggyfonts
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto" "Serif" ];
        sansSerif = [ "Noto" "Sans" ];
        monospace = [ "Jetbrains Mono" ];
      };
    };
  };

  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";

    PATH = [
      "\${XDG_BIN_HOME}"
    ];
  };

  security = {
    rtkit.enable = true;
    pam.loginLimits = [
      { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
      { domain = "@audio"; item = "rtprio"; type = "-"; value = "98"; }
      { domain = "@audio"; item = "nice"; type = "-"; value = "-11"; }
      { domain = "@audio"; item = "nofile"; type = "soft"; value = "99999"; }
      { domain = "@audio"; item = "nofile"; type = "hard"; value = "99999"; }
    ];
    pki.certificates = [
      ''
        -----BEGIN CERTIFICATE-----
        MIIFEjCCA/qgAwIBAgIJAOML1fivJdmBMA0GCSqGSIb3DQEBCwUAMIGCMQswCQYD
        VQQGEwJERTErMCkGA1UECgwiVC1TeXN0ZW1zIEVudGVycHJpc2UgU2VydmljZXMg
        R21iSDEfMB0GA1UECwwWVC1TeXN0ZW1zIFRydXN0IENlbnRlcjElMCMGA1UEAwwc
        VC1UZWxlU2VjIEdsb2JhbFJvb3QgQ2xhc3MgMjAeFw0xNjAyMjIxMzM4MjJaFw0z
        MTAyMjIyMzU5NTlaMIGVMQswCQYDVQQGEwJERTFFMEMGA1UEChM8VmVyZWluIHp1
        ciBGb2VyZGVydW5nIGVpbmVzIERldXRzY2hlbiBGb3JzY2h1bmdzbmV0emVzIGUu
        IFYuMRAwDgYDVQQLEwdERk4tUEtJMS0wKwYDVQQDEyRERk4tVmVyZWluIENlcnRp
        ZmljYXRpb24gQXV0aG9yaXR5IDIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
        AoIBAQDLYNf/ZqFBzdL6h5eKc6uZTepnOVqhYIBHFU6MlbLlz87TV0uNzvhWbBVV
        dgfqRv3IA0VjPnDUq1SAsSOcvjcoqQn/BV0YD8SYmTezIPZmeBeHwp0OzEoy5xad
        rg6NKXkHACBU3BVfSpbXeLY008F0tZ3pv8B3Teq9WQfgWi9sPKUA3DW9ZQ2PfzJt
        8lpqS2IB7qw4NFlFNkkF2njKam1bwIFrEczSPKiL+HEayjvigN0WtGd6izbqTpEp
        PbNRXK2oDL6dNOPRDReDdcQ5HrCUCxLx1WmOJfS4PSu/wI7DHjulv1UQqyquF5de
        M87I8/QJB+MChjFGawHFEAwRx1npAgMBAAGjggF0MIIBcDAOBgNVHQ8BAf8EBAMC
        AQYwHQYDVR0OBBYEFJPj2DIm2tXxSqWRSuDqS+KiDM/hMB8GA1UdIwQYMBaAFL9Z
        IDYAeaCgImuM1fJh0rgsy4JKMBIGA1UdEwEB/wQIMAYBAf8CAQIwMwYDVR0gBCww
        KjAPBg0rBgEEAYGtIYIsAQEEMA0GCysGAQQBga0hgiweMAgGBmeBDAECAjBMBgNV
        HR8ERTBDMEGgP6A9hjtodHRwOi8vcGtpMDMzNi50ZWxlc2VjLmRlL3JsL1RlbGVT
        ZWNfR2xvYmFsUm9vdF9DbGFzc18yLmNybDCBhgYIKwYBBQUHAQEEejB4MCwGCCsG
        AQUFBzABhiBodHRwOi8vb2NzcDAzMzYudGVsZXNlYy5kZS9vY3NwcjBIBggrBgEF
        BQcwAoY8aHR0cDovL3BraTAzMzYudGVsZXNlYy5kZS9jcnQvVGVsZVNlY19HbG9i
        YWxSb290X0NsYXNzXzIuY2VyMA0GCSqGSIb3DQEBCwUAA4IBAQCHC/8+AptlyFYt
        1juamItxT9q6Kaoh+UYu9bKkD64ROHk4sw50unZdnugYgpZi20wz6N35at8yvSxM
        R2BVf+d0a7Qsg9h5a7a3TVALZge17bOXrerufzDmmf0i4nJNPoRb7vnPmep/11I5
        LqyYAER+aTu/de7QCzsazeX3DyJsR4T2pUeg/dAaNH2t0j13s+70103/w+jlkk9Z
        PpBHEEqwhVjAb3/4ru0IQp4e1N8ULk2PvJ6Uw+ft9hj4PEnnJqinNtgs3iLNi4LY
        2XjiVRKjO4dEthEL1QxSr2mMDwbf0KJTi1eYe8/9ByT0/L3D/UqSApcb8re2z2WK
        GqK1chk5
        -----END CERTIFICATE-----
      ''
      ''
        -----BEGIN CERTIFICATE-----
        MIIFrjCCBJagAwIBAgIHG2O6uM8z+jANBgkqhkiG9w0BAQsFADCBlTELMAkGA1UE
        BhMCREUxRTBDBgNVBAoTPFZlcmVpbiB6dXIgRm9lcmRlcnVuZyBlaW5lcyBEZXV0
        c2NoZW4gRm9yc2NodW5nc25ldHplcyBlLiBWLjEQMA4GA1UECxMHREZOLVBLSTEt
        MCsGA1UEAxMkREZOLVZlcmVpbiBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eSAyMB4X
        DTE2MDUyNDExMzgxNloXDTMxMDIyMjIzNTk1OVowgY8xCzAJBgNVBAYTAkRFMQ8w
        DQYDVQQIDAZCYXllcm4xETAPBgNVBAcMCE11ZW5jaGVuMRMwEQYDVQQKDApGcmF1
        bmhvZmVyMSEwHwYDVQQLDBhGcmF1bmhvZmVyIENvcnBvcmF0ZSBQS0kxJDAiBgNV
        BAMMG0ZyYXVuaG9mZXIgU2VydmljZSBDQSAtIEcwMjCCASIwDQYJKoZIhvcNAQEB
        BQADggEPADCCAQoCggEBAL1YM8PClKcJX2DnO5OCgs0I9/VixH8yjmHRNI8l48h/
        2nu9xIoGVrPBWAVwJVkPjuBpF184BT2nDrIRqGSwRUhaJfqDMTUc1pspgqTuo4SN
        YK7W5hjYarRUV7ChK6CuwI8YZLBJHsdIn2MM0eGxKR9Tn1q1/HMG3HwuY2te242U
        Bh6rq7P3QZM+WDMwLaKBo7tObT8FG5mQw/R4vG1WXsuNViYTeHBqN0FfgIlBUEQv
        Dpg5VPQTfNWC0TPk/QRgOiCLJnqvURx5cSx1oUhXDsIttukieaicYcd5pcbCw/9y
        EwlhzLJEOEk4SgkWkABstD5vnbnW9ysmiuKP2N28xskCAwEAAaOCAgUwggIBMBIG
        A1UdEwEB/wQIMAYBAf8CAQEwDgYDVR0PAQH/BAQDAgEGMCkGA1UdIAQiMCAwDQYL
        KwYBBAGBrSGCLB4wDwYNKwYBBAGBrSGCLAEBBDAdBgNVHQ4EFgQUAEQ0lxwfK5km
        jRanHWBole2al64wHwYDVR0jBBgwFoAUk+PYMiba1fFKpZFK4OpL4qIMz+EwgY8G
        A1UdHwSBhzCBhDBAoD6gPIY6aHR0cDovL2NkcDEucGNhLmRmbi5kZS9nbG9iYWwt
        cm9vdC1nMi1jYS9wdWIvY3JsL2NhY3JsLmNybDBAoD6gPIY6aHR0cDovL2NkcDIu
        cGNhLmRmbi5kZS9nbG9iYWwtcm9vdC1nMi1jYS9wdWIvY3JsL2NhY3JsLmNybDCB
        3QYIKwYBBQUHAQEEgdAwgc0wMwYIKwYBBQUHMAGGJ2h0dHA6Ly9vY3NwLnBjYS5k
        Zm4uZGUvT0NTUC1TZXJ2ZXIvT0NTUDBKBggrBgEFBQcwAoY+aHR0cDovL2NkcDEu
        cGNhLmRmbi5kZS9nbG9iYWwtcm9vdC1nMi1jYS9wdWIvY2FjZXJ0L2NhY2VydC5j
        cnQwSgYIKwYBBQUHMAKGPmh0dHA6Ly9jZHAyLnBjYS5kZm4uZGUvZ2xvYmFsLXJv
        b3QtZzItY2EvcHViL2NhY2VydC9jYWNlcnQuY3J0MA0GCSqGSIb3DQEBCwUAA4IB
        AQDBVFypVUFm1ViyM0oLovI7I699bRpGHyK2HX4ZnjBLGK5+16f9xGe1QHg9N799
        l0FjuPxRGGHaeNouPXebPsKNPAZ+AHsAIm4R/Jyt1yqFGgmXhdhHMhSKKen3dUGz
        Y9k4KFQyVta93CA9mpdORc9te/bkPoJ5b1hma1OwufZrnWBAakXPVM5xWN5xWUfw
        t90GTHoxkgLZXfbqFRfTq8kSkfmzHv2iSbbZcij5iqugNv2bpGFtV+iWsds3O0k4
        mMyxKMkDpE3IXlg0Ln8Dnke+ZMm/yZlkCKNqG1AbQ5xPqUhPXcUjiV1+y4AI0LQQ
        hbI4tNarnGrwQ6XxhM0KR2+D
        -----END CERTIFICATE-----
      ''
      ''
        -----BEGIN CERTIFICATE-----
        MIIDwzCCAqugAwIBAgIBATANBgkqhkiG9w0BAQsFADCBgjELMAkGA1UEBhMCREUx
        KzApBgNVBAoMIlQtU3lzdGVtcyBFbnRlcnByaXNlIFNlcnZpY2VzIEdtYkgxHzAd
        BgNVBAsMFlQtU3lzdGVtcyBUcnVzdCBDZW50ZXIxJTAjBgNVBAMMHFQtVGVsZVNl
        YyBHbG9iYWxSb290IENsYXNzIDIwHhcNMDgxMDAxMTA0MDE0WhcNMzMxMDAxMjM1
        OTU5WjCBgjELMAkGA1UEBhMCREUxKzApBgNVBAoMIlQtU3lzdGVtcyBFbnRlcnBy
        aXNlIFNlcnZpY2VzIEdtYkgxHzAdBgNVBAsMFlQtU3lzdGVtcyBUcnVzdCBDZW50
        ZXIxJTAjBgNVBAMMHFQtVGVsZVNlYyBHbG9iYWxSb290IENsYXNzIDIwggEiMA0G
        CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCqX9obX+hzkeXaXPSi5kfl82hVYAUd
        AqSzm1nzHoqvNK38DcLZSBnuaY/JIPwhqgcZ7bBcrGXHX+0CfHt8LRvWurmAwhiC
        FoT6ZrAIxlQjgeTNuUk/9k9uN0goOA/FvudocP05l03Sx5iRUKrERLMjfTlH6VJi
        1hKTXrcxlkIF+3anHqP1wvzpesVsqXFP6st4vGCvx9702cu+fjOlbpSD8DT6Iavq
        jnKgP6TeMFvvhk1qlVtDRKgQFRzlAVfFmPHmBiiRqiDFt1MmUUOyCxGVWOHAD3bZ
        wI18gfNycJ5v/hqO2V81xrJvNHy+SE/iWjnX2J14np+GPgNeGYtEotXHAgMBAAGj
        QjBAMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBS/
        WSA2AHmgoCJrjNXyYdK4LMuCSjANBgkqhkiG9w0BAQsFAAOCAQEAMQOiYQsfdOhy
        NsZt+U2e+iKo4YFWz827n+qrkRk4r6p8FU3ztqONpfSO9kSpp+ghla0+AGIWiPAC
        uvxhI+YzmzB6azZie60EI4RYZeLbK4rnJVM3YlNfvNoBYimipidx5joifsFvHZVw
        IEoHNN/q/xWA5brXethbdXwFeilHfkCoMRN3zUA7tFFHei4R40cR3p1m0IvVVGb6
        g1XqfMIpiRvpb7PO4gWEyS8+eIVibslfwXhjdFjASBgMmTnrpMwatXlajRWc2BQN
        9noHV8cigwUtPJslJj0Ys6lDfMjIq2SPDqO/nBudMNva0Bkuqjzx+zOAduTNrRlP
        BSeOE6Fuwg==
        -----END CERTIFICATE-----
      ''
    ];
  };

  hardware = {
    pulseaudio.enable = false;
    sane = {
      enable = true;
      extraBackends = [ pkgs.hplipWithPlugin pkgs.sane-airscan ];
    };
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        vaapiVdpau
        libvdpau-va-gl
        intel-ocl
        intel-compute-runtime
      ];
    };
    openrazer = {
      users = [ "steff" ];
      enable = true;
    };
  };
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users.steff = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "wireshark" "docker" "scanner" "lp" "saned" "vboxusers" "audio" ];
      packages = with pkgs; [
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    gnome.dconf-editor
    gnome.gnome-boxes
    gnome.gnome-tweaks
    libp11
    p11-kit
    opensc
    gnutls.bin
    pcsctools
    glibcLocales
  ];

  environment.etc = {
    "pkcs11/modules/work".text = ''
      module:/nix/store/z8qzygd7scmk3agjam9lg3f0qrpz27w0-fraunhofer-smartcard-8.0.1.694/usr/lib/libcvP11.so
    '';
    "pkcs11/modules/opensc".text = ''
      module:${pkgs.opensc}/lib/opensc-pkcs11.so
    '';
  };

  # environment.variables =
  virtualisation = {
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };

    spiceUSBRedirection.enable = true;
    docker.enable = true;
  };

  system = {
    activationScripts = {
      rfkillUnblockWlan = {
        text = ''
          rfkill unblock wlan
        '';
        deps = [ ];
      };
    };
    userActivationScripts = {
      # This is for smartcard support in evolution.
      # Should be the default, but it isn't… Check at some point 
      # in time if the smartcard works without this…
      addP11KitProxy = {
        text = ''
          ${pkgs.nssTools}/bin/modutil -dbdir sql:.pki/nssdb -delete p11-kit-proxy || true
          ${pkgs.nssTools}/bin/modutil -dbdir sql:.pki/nssdb -add p11-kit-proxy -libfile ${pkgs.p11-kit}/lib/p11-kit-proxy.so
        '';
        deps = [ ];
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  services = {
    # thinkfan.enable = true;
    btrfs.autoScrub.enable = true;
    pcscd.enable = true;
    geoclue2.enable = true;
    resolved = {
      enable = true;
      dnssec = "false";
    };

    printing = {
      enable = true;
      drivers = [
        pkgs.hplipWithPlugin
      ];
    };

    xserver = {
      enable = true;
      layout = "de";
      xkbVariant = "neo";
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    flatpak.enable = true;
    gnome.gnome-keyring.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    udev = {
      extraRules = ''
        KERNEL=="rtc0", GROUP="audio"
        KERNEL=="hpet", GROUP="audio"
        KERNEL=="cpu_dma_latency", GROUP="audio"
      '';
    };
  };

  # xdg = {
  #   portal.gtkUsePortal = true;
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
