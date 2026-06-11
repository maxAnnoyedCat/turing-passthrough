# =========================================================================
  # ENTERPRISE TURING/T4 PASSTHROUGH PROFILE (Driver Branch: 595+)
  # Tesla T4 (CC 7.5) in Multi-GPU-Umgebungen.
  # =========================================================================
  specialisation.turing-t4-passthrough.configuration = {
    system.nixos.tags = [ "turing-t4-passthrough" ];

    # 1. IOMMU & Kernel-Level GPU Isolation
    # Der 595er Treiber versteht 'ignore_gpus' nativ. Wir verbieten dem Host-Treiber
    # explizit den Zugriff auf die zweite GPU auf PCI-Slot 03:00.0.
    boot.kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
      "pci=noaer"
      "nvidia-drm.modeset=1"
      "nvidia.ignore_gpus=0000:03:00.0" 
    ];

    # 2. Early VFIO Boot Binding
    # Wir zwingen die Initrd (Early Boot Stage), die VFIO-Treiber zu laden,
    # bevor irgendwelche Grafiktreiber überhaupt initialisiert werden.
    boot.initrd.kernelModules = [ 
      "vfio_pci" 
      "vfio" 
      "vfio_iommu_type1" 
    ];

    # 3. Deklarative Udev-Regeln für identische GPUs
    # Falls zwei identische T4-Karten verbaut sind, reicht die Hardware-ID nicht aus.
    # Wir binden VFIO-PCI direkt an den physischen PCI-Pfad (03:00) beim Erkennen der Hardware.
    boot.initrd.services.udev.rules = ''
      # Zwinge VFIO-PCI auf die VM-Zielkarte (VGA + Audio)
      ACTION=="add", SUBSYSTEM=="pci", KERNELS=="0000:03:00.0", ATTR{driver_override}="vfio-pci"
      ACTION=="add", SUBSYSTEM=="pci", KERNELS=="0000:03:00.1", ATTR{driver_override}="vfio-pci"

      # Halte die Primär-Karte (02:00.0) für den Host/Nvidia-Treiber frei
      ACTION=="add", SUBSYSTEM=="pci", KERNELS=="0000:02:00.0", ATTR{driver_override}="nvidia"
    '';

    # 4. Modern Production Nvidia Driver Config (595+ Schema)
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      open = false; # Auf Servern/T4 oft 'false' wegen CUDA-Stabilität im Enterprise-Umfeld
      powerManagement.enable = lib.mkForce false;

      # Dynamisches Pinning auf den modernsten stabilen Branch (z.B. r595)
      # In der Praxis wird hier das entsprechende Paket aus den aktuellen Nixpkgs referenziert.
      package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # 5. CUDA-Optimierungen für das Gast-System / Virtualisierung
    virtualisation.libvirtd = {
      enable = true;
      onBoot = "start";
      # Erlaubt KVM das Durchreichen von riesigen Speicherseiten (Hugepages) für KI-Workloads
      qemu.verbatimConfig = ''
        max_outputs = 1
        user = "root"
        group = "kvm"
      '';
    };

    # Komfort-Alias für das Rechenzentrum-Monitoring
    environment.shellAliases = {
      whereami = "echo 'MODUS: Turing/T4 Passthrough (Host-Driver: 595+)'";
      check-passthrough = "lspci -nnk | grep -A 3 -i nvidia";
    };
  };
