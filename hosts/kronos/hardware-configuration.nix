{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices = {
    cryptroot = {
      device = "/dev/disk/by-uuid/f1e9b431-bfa9-4527-99b9-12774226c225";
      preLVM = true;
      allowDiscards = true;
    };
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/0ac2de3b-f319-4e9f-8ab3-1d3ca47a51e3";
      fsType = "btrfs";
      options = [
        "ssd"
        "discard=async"
        "compress=zstd"
      ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/570b0866-d72a-4c99-b8cd-01ea9e292090";
      fsType = "ext4";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/6d47e704-7659-4096-9db9-8e46cae87b71"; }];

  # powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
