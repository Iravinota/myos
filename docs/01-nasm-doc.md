# NASM Language Ref

This is a documentation about NASM language.

## Notifacations

- Can't use `mov ds, opp` , use `mov ax, operand` and `mov ds, ax`
- If the GUI command is not corrent, click *Command-->Refresh Screen*
- `org 0x7c00` 表示假设此程序的起始地址是0x7c00。它的作用是把*常量字段*加上一个偏移量。比如有个常量字段`msg db "Welcome to My Operating System!", 0`，假设`org 0`时它的地址为`0x0056`，那么当`org 0x7c00`时，它的地址就变成了`0x7c00+0x0056= 0x7c56`。这样，在使用`mov si, msg`命令时，经过编译之后的地址就是不一样的。
- `istruc` is used to initialize an instance of a `struc`, so the 'struc' must be defined first.

## Instructions

- `loop`: Performs a loop operation using the RCX,ECX, or CX register as a counter.
- `%include "stdio.inc"`: pre include a file. <https://www.nasm.us/doc/nasmdoc2.html#section-2.1.18>
- `%ifdef`: <https://www.nasm.us/doc/nasmdoc4.html#section-4.4.1>
- `%define`: <https://www.nasm.us/doc/nasmdoc4.html#section-4.1.1>
- `istruc`, `at`, `iend`: <https://www.nasm.us/doc/nasmdoc4.html#section-4.11.12>
- `jmp`: near jump, far jump, <file:///E:/books/Intel%20Mannul/64-IA-32-architectures-software-developer-2-instruction-set-reference-manual-325383.pdf>, JMP-Jump

## References

- <https://en.wikipedia.org/wiki/BIOS_interrupt_call> - BIOS Call List
- <http://www.ctyme.com/rbrown.htm> - Interrupt Table, Click *Interrupt*
- [x86 Instruction Set Reference](https://c9x.me/x86/)