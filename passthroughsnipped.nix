
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader (Die Tür 5 Architektur beibehalten)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot = {
  kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "vfio-pci.ids=10de:1380,10de:0fbc"
  ];

  kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" ];

  # Das hier zwingt die VFIO-Module, VOR den Grafiktreibern zu laden:
  initrd.kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" ];
};

}
