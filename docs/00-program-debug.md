# My Programming and Debug information

## 2019-01-09

- Load **Root Directory** from a FAT12/16 formatted floppy disk
- `copy a.txt A:\`
- `copy b.txt A:\`
- Then the floppy disk A: has two normal files, a.txt and b.txt
- Don't forget the Boot1.bin is at the **Boot Sector**
- The FAT12/16 formated disk sectors are:

![](img/2019-01-09-22-58-59.png)

- Open bochs debugger, enter `lb 0x7cf6`, enter `c`
- Click *F7* and enter *0x7c00* to dump memory at 0x7c00
- Now you can see the a.txt and b.txt **Root Sector** at the 0x7e00 address

![](img/2019-01-09-23-05-14.png)

## 2019-01-10

- Load File Allocation Table(FAT), at sector 1 (just besides BootSector(512 bytes) in the FAT12 formated floppy disk)

lb 0x7d36: LOAD_FAT-->call ReadSectors
; CX=>Number of sectors to read     ==>0x12
; AX=>Starting sector               ==>1
; ES:BX=>Buffer to read to          ==>07c0:0200

## 2019-01-11

- `lb 0x7d8b`: The last command of the Boot1.bin
- `lb 0x0500`: The KRNLDR.SYS executable code