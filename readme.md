# 环境
- windows 7 32 bit
- vfdwin 软盘模拟器
- partcopy 用于拷贝文件
- bochs X86模拟器
- nasm
- VS Code 编辑器
- Microsoft Visual C++ 2010

## Install Visual Floppy Disk
- start vfdwin
- click *install*
- In the *Driver* page, click *Open/Create*, create a A: floppy disk, and then format it.

## Start Bochs and Debugger
- Create a file *bochsrc.bxrc* in the bochs directory:

```
# ROM and VGA BIOS images ---------------------------------------------
 
romimage:    file=BIOS-bochs-latest
vgaromimage: file=VGABIOS-lgpl-latest 
 
# boot from floppy using our disk image -------------------------------
 
floppya: 1_44=a:, status=inserted  # Set a floppy a at path a:
boot: floppy                       # Boot from floppy drive

# debugger gui --------------------------------------------------------

display_library: win32, options="gui_debug" # use Win32 debugger gui
 
# logging and reporting -----------------------------------------------
 
log:         OSDev.log             # All errors and info logs will output to OSDev.log
error:       action=report 
info:        action=report
```

- Double click *bochsdbg.exe* to start the debugger.
- Write `lb 0x7c00` to set a break point at liner address 0x7c00. This is becaue the BIOS load a bootable image into 0x7c00 address.
- Click *Continue[c]* button, go to that break point.
- The memory at this address is not a usefull instruction. But We know the Bochs is running.

# 执行
- In the *cmd* window, execute this command: `nasm -f bin Boot1.asm -o Boot1.bin`. The `-f bin` denotes the output format is a *pure binary* format.
- Execute: `partcopy Boot1.bin 0 200 -f0`, copy this image to floppy disk A:. Then the floppy A:\ is a pure disk, has no file system format ever.
- Start the bochs debugger by double click *bochsrc.bxrc*. Write `lb 0x7c00`, then write `c`. Bochs will stop at address 0x7c00. Then you can see the Boot1.bin content.

# 参考文档

- https://thestarman.pcministry.com/asm/bochs/bochsdbg.html


# 记录
- 2018-12-27: 参照Demo23编写操作系统，也参照其它demo
- 2018-12-28: 0xAA55可启动镜像