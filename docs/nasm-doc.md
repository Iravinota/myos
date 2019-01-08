# NASM Language Ref

- Can't use `mov ds, opp` , use `mov ax, operand` and `mov ds, ax`
- If the GUI command is not corrent, click *Command-->Refresh Screen*
- `org 0x7c00` 表示假设此程序的起始地址是0x7c00。它的作用是把*常量字段*加上一个偏移量。比如有个常量字段`msg db "Welcome to My Operating System!", 0`，假设`org 0`时它的地址为`0x0056`，那么当`org 0x7c00`时，它的地址就变成了`0x7c00+0x0056= 0x7c56`。这样，在使用`mov si, msg`命令时，经过编译之后的地址就是不一样的。