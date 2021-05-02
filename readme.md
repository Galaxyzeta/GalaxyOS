# GalaxyOS

一个自制操作系统尝试，是对项目 os-tutorial 的学习。

# How2Use

1. 修改一下 `make` 文件中的目录变量。
2. 运行 `make` 得到 `boot.img`。
3. 在 `Vmware` 等虚拟机中加载镜像，即可运行。

# Developing Progress

1. 扇区引导进入32位保护模式。✅
2. 编写vga接口完成文字打印。✅
3. 中断处理响应键盘输入。❌
4. 内存管理。❌
5. 进程调度。❌
6. 文件系统。❌
7. shell。❌