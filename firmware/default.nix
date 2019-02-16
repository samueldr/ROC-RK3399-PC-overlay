{ stdenv, ROC-RK3399-PC }:

let
  inherit (ROC-RK3399-PC) u-boot rkbin;
in
stdenv.mkDerivation rec {
  pname = "ROC-RK3399-PC-firmware";
  version = "2019-02-14";

  unpackPhase = ":";
  flashData = "${rkbin}/share/rkbin/bin/rk33/rk3399_ddr_800MHz_v1.14.bin";
  flashBoot = "${rkbin}/share/rkbin/bin/rk33/rk3399_miniloader_v1.15.bin";

  nativeBuildInputs = [
    rkbin
  ];

  # Reading material:
  #  * https://github.com/FireflyTeam/u-boot/blob/1ce6742a2e94f14352b58132f45689e9205de712/make.sh#L434-L435
  #  * http://opensource.rock-chips.com/wiki_Boot_option#Boot_from_SD.2FTF_Card
  installPhase = ''
    (
    PS4="$ "
    set -x

    ${u-boot}/mkimage -n rk3399 -T rksd -d ${flashData} idbloader.img
    cat ${flashBoot} >> idbloader.img

    cp idbloader.img combined.img

    ln -s ${rkbin}/share/rkbin rk_tools

    loaderimage --pack \
      --uboot ${u-boot}/u-boot.bin uboot.img \
      --size 1024 2

    trust_merger --size 1024 2 --verbose \
     --replace tools/ "(dummy)" \
      ${rkbin}/share/rkbin/RKTRUST/RK3399TRUST.ini

    # minus 64 since this file is written starting at offset 64.
    dd if=uboot.img of=combined.img seek=$(( 0x4000 - 64 ))
    dd if=trust.img of=combined.img seek=$(( 0x6000 - 64 ))

    mkdir -p $out
    mv combined.img $out/
    )
  '';

  meta = with stdenv.lib; {
    maintainers = [ maintainers.samueldr ];
    platforms = ["aarch64-linux"];
  };
}
