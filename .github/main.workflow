workflow "Build on push" {
  on = "push"
  resolves = ["Build"]
}

action "Build" {
  uses = "samueldr/action-nix-build@master"
  env = {
    NIXPKGS_ALLOW_UNFREE = "1"
  }
}

workflow "Upload on release" {
  on = "release"
  resolves = [
    "Build for release",
    "Upload release",
  ]
}

action "Build for release" {
  uses = "samueldr/action-nix-build@master"
  env = {
    NIXPKGS_ALLOW_UNFREE = "1"
  }
}

action "Upload release" {
  uses = "JasonEtco/upload-to-release@v0.1.1"
  args = "result/ROC-RK3399-PC-firmware-combined.img.xz application/x-xz; charset=binary"
  secrets = ["GITHUB_TOKEN"]
  needs = ["Build for release"]
}
