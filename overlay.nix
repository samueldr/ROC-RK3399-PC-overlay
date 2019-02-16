self: super:

let
  inherit (self) callPackage;
in
{
  ROC-RK3399-PC = {
    rkbin = callPackage ./rkbin {};
  };
}
