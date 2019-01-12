# MyOS versions

The things that version did.

## MyOS v0.0.0

- See readme.md to install and configurate all the softwares.

----

## MyOS v0.0.4

### In Stage1 Directory

- `nasm Boot1.asm -o Boot1.bin`
- `partcopy Boot1.bin 0 200 -f0`

### In Stage2 Directory

- `nasm Stage2.asm -o KRNLDR.SYS`
- `copy /Y KRNLDR.SYS  A:\`

### Bochs

- start bochsdbg.exe
- `lb 0x0500`
- The KRNLDR.SYS file is loaded by Boot1.bin to 0050:0000 address
- At the end of *Boot1.bin*, it *retf* to 0050:0000 address to execute

----

## MyOS v0.0.5

### Changes

- Use `%include` to include other files
- Enable A20
- Load GDT(Global Discriptor Table) which defines what memory can be executed (the **Code Descriptor**), and what memory contains data (**Data Descriptor**)
- GDT item is 64 bits (8 Bytes)

### Bochs

- After InstallDGT, we can click *view-->GDT* to see the GDT

![](img/2019-01-13-00-31-04.png)