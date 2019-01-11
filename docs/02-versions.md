# MyOS v0.0.0

- See readme.md to install and configurate all the softwares.

# MyOS v0.0.4

## In Stage1 Directory
- `nasm Boot1.asm -o Boot1.bin`
- `partcopy Boot1.bin 0 200 -f0`

## In Stage2 Directory
- `nasm Stage2.asm -o KRNLDR.SYS`
- `copy KRNLDR.SYS  A:\`

## Bochs
- start bochsdbg.exe
- `lb 0x0500`
- The KRNLDR.SYS file is loaded by Boot1.bin to 0050:0000 address
- At the end of *Boot1.bin*, it *retf* to 0050:0000 address to execute