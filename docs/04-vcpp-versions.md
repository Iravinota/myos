# VC++ SysCore Versions

The [02-versions.md](./02-versions.md) contains all the GRUB like versions. Now we will step into the real kernel.

## MyOS v0.0.13

### Changes

- Setup the VC++ 2010 environment.
- Add Kernel, Lib, Include, Hal projects.
- Kernel is the start project.
- Lib#cstd.cpp is a C++ runtime environmnet. Because the MyOS has no C++ runtime environment, so we build one. This simple runtime is only include some simple functions.
- Lib#string.cpp is a String Operation library.
- Include only contains .h files, so it can be a *Utility* Type.
- Hal contains the hardware operations. It contains some function to communicate with hardware according **port mapping**.
- Kernel is the real kernel of our MyOS.
- Kernel#entry.cpp is the entry point. It has a function *kernel_entry*, which is the exact name we set on the *Linker's entry point* of Kernel's property pages.
- Kernel#main.cpp is our *main* function which is called by entry.cpp.
- Kernel#DebugDisplay.cpp contains some useful functions to display strings on the screen.

### Bochs debug

- Comment the  *bochsrc.bxrx*'s line: `# display_library: win32, options="gui_debug" # use Win32 debugger gui`, disable the GUI debug.
- Click the *bochs.exe* to start.

![first print](img/2019-01-31-20-41-25.png)