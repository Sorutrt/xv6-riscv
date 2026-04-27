{
  description = "Nix dev shell for studying xv6-riscv with QEMU and GDB";

  inputs = {
    nixpkgs.url = "nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = f:
        builtins.listToAttrs (map (system: {
          name = system;
          value = f system;
        }) systems);
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          cross = pkgs.pkgsCross.riscv64-embedded;

          xv6-gdb = pkgs.writeShellApplication {
            name = "xv6-gdb";
            runtimeInputs = [
              pkgs.gdb
              pkgs.gnumake
            ];
            text = ''
              if [ ! -f .gdbinit ]; then
                make .gdbinit
              fi

              exec gdb -nx -iex "set auto-load safe-path /" -x .gdbinit "$@"
            '';
          };

          xv6-qemu = pkgs.writeShellApplication {
            name = "xv6-qemu";
            runtimeInputs = [ pkgs.gnumake ];
            text = ''
              exec make qemu "$@"
            '';
          };

          xv6-qemu-gdb = pkgs.writeShellApplication {
            name = "xv6-qemu-gdb";
            runtimeInputs = [ pkgs.gnumake ];
            text = ''
              exec make qemu-gdb "$@"
            '';
          };
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.bc
              pkgs.gcc
              pkgs.gdb
              pkgs.gnumake
              pkgs.perl
              pkgs.qemu
              cross.stdenv.cc
              cross.stdenv.cc.bintools
              xv6-gdb
              xv6-qemu
              xv6-qemu-gdb
            ];

            shellHook = ''
              cat <<'EOF'
xv6-riscv dev shell
  run kernel:     make qemu
  qemu wrapper:   xv6-qemu
  wait for gdb:   make qemu-gdb
  gdb wrapper:    xv6-gdb
EOF
            '';
          };
        });
    };
}
