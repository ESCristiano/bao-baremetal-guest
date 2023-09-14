{
  pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/22.11.tar.gz";
    sha256 = "sha256:11w3wn2yjhaa5pv20gbfbirvjq6i3m7pqrq2msf0g7cv44vijwgw";
  }) {},
  platform ? " ",
  list_tests ? " ",
  list_suites ? " "
}:

with pkgs;

let
  packages = rec {
    # platform = "qemu-aarch64-virt";
    aarch64-none-elf = callPackage ./bao-tests-firmware/pkgs/toolchains/aarch64-none-elf-11-3.nix{};
    demos = callPackage ./bao-tests-firmware/pkgs/demos/demos.nix {};
    bao-tests = callPackage ./bao-tests-firmware/pkgs/bao-tests/bao-tests.nix {};
    tests = callPackage ./bao-tests-firmware/pkgs/tests/tests.nix {};
    baremetal = callPackage ./bao-tests-firmware/pkgs/guest/baremetal-tf.nix 
                {
                  toolchain = aarch64-none-elf; 
                  inherit platform;
                  inherit list_tests; 
                  inherit list_suites;
                  inherit bao-tests;
                  inherit tests;
                };

    bao = callPackage ./bao-tests-firmware/pkgs/bao/bao.nix 
                { 
                  toolchain = aarch64-none-elf; 
                  guest = baremetal; 
                  inherit demos; 
                  inherit platform;
                };

    u-boot = callPackage ./bao-tests-firmware/pkgs/u-boot/u-boot.nix 
                { 
                  toolchain = aarch64-none-elf; 
                };

    atf = callPackage ./bao-tests-firmware/pkgs/atf/atf.nix 
                { 
                  toolchain = aarch64-none-elf; 
                  inherit u-boot; 
                  inherit platform;
                };

    inherit pkgs;
  };
in
  packages


