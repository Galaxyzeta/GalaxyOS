# 引导内核载入

编写操作系统的第一步就是要通过汇编代码完成内核载入，并从16位实模式切换到32位保护模式。

## 1 准备工作

前置条件：

- Nasm 编译工具。
- VMWare 或 Qemu 等虚拟机，我使用了前者，不过推荐使用后者。
- gcc 作为 c 语言编译器。
- 一些 Linux 基本操作。
- 一些 OS 知识。
- 学过 C 语言，能理解指针。

本实验在 windows WSL2 下进行，如果你使用 windows 10，强烈建议在 WSL 下进行实验。如果你使用其他 Linux 发行版或 MacOS，那完全没有问题甚至更好。

在进行下一步操作前，请务必安装这些工具。

## 2 入门 Nasm 汇编

### 引导区格式

引导区将被放在软盘的起始位置，其大小是 512B，最后部分通过 magic number `0xAA55` 来标识这是一个引导区。

一个最简单的引导区写法：
```nasm
times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
dw 0xAA55		; The standard PC boot signature
```
解释上述代码：
1. dw 表示定义一个 word，一个 word 在 16 位模式下自然是 16位，即 2B。
2. db 表示定义一个 byte，一个 byte 是 8 位。
3. times 将后续操作重复 n 次。\$-\$\$ 表示当前所在行字节编号 - 前一行字节编号。这句话就是必须要填充满 510 个字节。为什么不是 512？因为最后一个字长（2B）必须是 magic number。

### BIOS

首先需要知道 BIOS，BIOS 是标准输入输出系统，会在开机时自动加载。个人理解可以把它当成一个自带的，最小化的“操作系统”，用户可以调用中断指令使得 BIOS 执行一系列的动作，比如打印、磁盘读取等。

本教程目标，就是通过汇编操作 BIOS 帮助我们完成内核载入和模式切换。

### Hello world 程序

编写一个 16 位实模式下的打印函数非常有利于我们熟悉 NASM 语法、BIOS 调用操作，打印操作在后面也能帮助我们暴力debug。

下面代码保存在 `print_string.asm` 中：
```nasm
print_string:			; Routine: output string in SI to screen
	mov ah, 0Eh			; int 10h 'print char' function

	.repeat:
		lodsb			; Get character from string
		cmp al, 0
		je .done		; If char is zero, end of string
		int 10h			; Otherwise, print it
		jmp .repeat

	.done:
		ret
```

下面代码保存在 `boot.asm` 中：

```nasm
	#include "print_string.asm"
	mov si , text_loading_kernel
	call print_string
	jmp $

	text_loading_kernel db "Hello world", 0
```

解释上面的代码：

1. include 跟 c 语言 include 一样，就不再解释了。
2. print_string 可以理解为一个标签、一段内容，或者一个函数。
3. ax 寄存器16位，mov ah, 0Eh 将 0E 放到了 ax 寄存器的高8位。同理，al 表示 ax 寄存器的低8位。
4. .repeat 表示一个标签， 可以通过 jmp 语句跳转标签，实现汇编层面的循环。
5. cmp a, b 是汇编层面的 if 语句，je(jump if equal) 放在 cmp 下面，表示如果上一句 cmp 结果是 true，则进行跳转，否则不跳转。同理 jne(jump if not equal) 和 je 相反，只有当 cmp 返回 false 才能跳转。
6. ret 表示函数的返回。函数通过 call 进行调用。
7. jmp $，美元符号表示当前位置，jmp $ 表示代码无限跳转当前位置，不再向下执行。
8. text_loading_kernel db "Loading kernel...", 0 类似 c 语言的宏或是常量定义。这句话实际上实在声明一个字符串常量。
9.  si 寄存器指向了数据的地址；lodsb 操作将 si 指向的数据取出，放到 ax 的低 8 位 al，然后 si++。
10. int 10h 是BIOS中断，跟 OS 中断差不多，用来调用 BIOS 执行特定动作。这里的 10h 中断表示屏幕打印操作，它的参数是放在 ax 高8位 ah 中。

事实上，这段字符串打印代码等价于以下 C 代码：
```c
void main() {
	const char* str = "Hello world";
	int i = 0;
	while(str[i] != '\0') {
		printf("%c", str[i++]);
	}
}
```
## 3 栈、段及相关寄存器

### 明确内存结构

https://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf

第 18 页的图非常重要，建议反复查看。
这个 pdf 也是本实验的基础，但有点虎头蛇尾的感觉，建议前面部分遇到不懂的详细参考这个文档。

### 段

段这个概念表示将不同的内容进行了分类，比如栈相关数据以栈段为起始位置，其他类似的还有ds（数据段）、cs（代码段）、ss（栈段）、es（额外段）等。即使你不显示声明段，程序的加载已经在隐式的使用段来进行了。

段地址在进行真实地址计算时，需要左移 4 位。例如栈段 1000h，偏移1000h，实际上物理地址是 11000h。

### 栈

https://en.wikipedia.org/wiki/Stack_register

- ss: 栈段指针，表示栈区域的起始位置。
- bp：栈底指针。
- sp：栈顶指针。


### todo