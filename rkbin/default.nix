{ stdenv, fetchFromGitHub, patchelf, makeWrapper }:

# TODO: see if qemu-user-x86_64 could be used on aarch64 to use those binaries?
let
  board = "ROC-RK3399-PC";
in
stdenv.mkDerivation {
  name = "firefly-rkbin-${board}";

  src = fetchFromGitHub {
    rev = "fa1fcfab3d3e8b9a7a93826f4608de9e521bf9d0";
    owner = "FireflyTeam";
    repo = "rkbin";
    sha256 = "16wyc1q1dmypkyarniymgdbypi1vi61rlf658mx3gdb6bvmz3j8i";
  };

  nativeBuildInputs = [ patchelf makeWrapper ];

  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    TOOLS=(
      tools/boot_merger
      tools/firmwareMerger
      tools/kernelimage
      tools/loaderimage
      tools/mkkrnlimg
      tools/rkdeveloptool
      tools/trust_merger
      tools/upgrade_tool
    )

    for tool in "''${TOOLS[@]}"; do
      echo "Patching $tool"
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$tool"
    done

    # ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), statically linked
    TOOLS+=(tools/resource_tool)

    mkdir -p $out/share/rkbin
    for f in *; do
      cp -r $f $out/share/rkbin/
    done

    for tool in "''${TOOLS[@]}"; do
      makeWrapper $out/share/rkbin/$tool $out/bin/''${tool/tools/}
    done
  '';

  meta = with stdenv.lib; {
    description = "Proprietary bits from Rockchip used by Firefly for ${board}";
    license = licenses.unfree;
  };
}
