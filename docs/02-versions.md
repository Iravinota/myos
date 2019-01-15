# MyOS versions

The things that version did.

## MyOS v0.0.0

- See readme.md to install and configurate all the softwares.

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

## MyOS v0.0.5

### Changes

- Use `%include` to include other files
- Enable A20
- Load GDT(Global Discriptor Table) which defines what memory can be executed (the **Code Descriptor**), and what memory contains data (**Data Descriptor**)
- GDT item is 64 bits (8 Bytes)

### Bochs

- After InstallDGT, we can click *view-->GDT* to see the GDT

![gdt](img/2019-01-13-00-31-04.png)

## MyOS v0.0.6

### Changes

- Check physical memory size: BiosGetMemorySize64MB in Memory.inc

### Bochs debug

- `lb 0x06f8`: before hlt, after 0x0500
- *eax* register contains the total size of the physical memory (bochs default: 32M, see Bochs-2.6.9/bochsrc-sample.txt line-340)

![eax](img/2019-01-13-18-07-02.png)

### References

- multiboot_info, BiosGetMemorySize64MB <http://www.brokenthorn.com/Resources/OSDev17.html>

## MyOS v0.0.7

### Changes

- Load another file(B.TXT) from floppy disk into memory 0x3000 by Stage2.asm->KRNLDR.SYS

### Bochs debug

- In Stage2 Directory: `nasm Stage2.asm -o KRNLDR.SYS`
- In Stage2 Directory: `copy /Y KRNLDR.SYS  A:\`
- In Stage2 Directory: `copy /Y a.txt  A:\`
- In Stage2 Directory: `copy /Y b.txt  A:\`
- Bochs: `lb 0x0500`
- Go to the last *hlt* command
- Click *F7* and enter `0x3000`
- *ECX* contains the file size in sectors
- Change the value of 'ImageName' in common.inc can load different files into 0x3000

![b.txt](img/2019-01-13-22-44-18.png)

## MyOS v0.0.8

At staring, the BIOS set the address space into some regions. Each region define something. This is called Memory-mapping.

![memory-mapping](img/2019-01-15-21-10-53.png)

The BIOS also set each devices (register in devices) a number, which is called port number. When we use `in` or `out` instrunctions, we communicate with these devivces. This is called Port-mapped I/O.

### Changes

- Enter protected mode. Now we will use descriptor:address to addressing. The descriptor (also called selector) is in GDT. We now installed 3 descriptors: NULL_DESC(0x00), CODE_DESC(0x08), DATA_DESC(0x10), which offset is relative to GDTR register.
- Use `jmp CODE_DESC:Stage3` to far jump to Stage3. This instruction will set CS register to CODE_DESC descriptor. We now set the CODE_DESC's base address is 0x0000, so we can jump to Stage3. If we set CODE_DESC's base low address to 1, this instruction will jump to Stage3's next instruction. You can try it by yourself.
- Clear screen

### Bochs debug

- Look 0xB8000 liner memory dump. At the Bochs start, it's all *FF*. When some characters were print on screen, we can see this dump has the same character.
- `lb 0x0500`, *F7* and enter `0xB8000`, we can see the same character:

![same-character](img/2019-01-15-20-20-38.png)

- After we clear the screen, this is also changed.

### References

- [jmp instruction](https://c9x.me/x86/html/file_module_x86_id_147.html)
- [Memory Map (X86)](https://wiki.osdev.org/Memory_Map_(x86))
- [I/O Ports](https://wiki.osdev.org/I/O_Ports)
- [Bochs I/O ports](http://bochs.sourceforge.net/techspec/PORTS.LST)