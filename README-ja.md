# README-ja
```
nix develop
make qemu
```
GDB を使うときは 2 端末で:

```端末1
nix develop --command make qemu-gdb
```

```端末2
nix develop --command xv6-gdb
```

