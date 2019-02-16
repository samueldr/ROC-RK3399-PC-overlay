let
  overlay = (import ./. {});
  pkgs = overlay.overlay;
  firmware = overlay.pkgsCross.aarch64-multiplatform.ROC-RK3399-PC.firmware;
in
  pkgs.runCommand "firmware-release" {} ''
    (
    PS4=" $ "
    mkdir -p $out
    cd $out
    xz < "${firmware}/combined.img" > ROC-RK3399-PC-firmware-combined.img.xz
    )
  ''
