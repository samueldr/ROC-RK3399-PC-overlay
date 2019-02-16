{
  pkgs ? import <nixpkgs> {
    overlays = [ (import ./overlay.nix) ];
  }
}:

# Makes the ROC-RK3399-PC attrset available directly
pkgs.ROC-RK3399-PC //
{
  # And passes the nixpkgs with overly through if required.
  overlay = pkgs;
}
