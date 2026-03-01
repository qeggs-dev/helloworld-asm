# Hello World Bootloader (x86 Assembly)

这是一个简单的 x86 汇编语言编写的引导程序（bootloader），在计算机启动时打印 `"Hello World!"`，并等待用户按下 Ctrl+C 后尝试关机。

## 功能特性

- 打印字符串 `"Hello World!"`
- 使用 BIOS 中断实现字符输出
- 等待用户按下 Ctrl+C 退出
- 尝试通过 APM 或 ACPI 关机
- 支持关机失败时的回退提示

## 环境要求

- NASM 汇编器（用于编译）
- x86 模拟器（如 QEMU）或真实硬件（需写入引导扇区）

## 编译与运行

### 1. 编译为二进制文件

```bash
nasm -f bin helloworld.asm -o helloworld.bin
```

### 2. 使用 QEMU 运行

```bash
qemu-system-x86_64 -drive format=raw,file=helloworld.bin
```

### 3. 写入 USB 或磁盘（可选）

```bash
dd if=helloworld.bin of=/dev/sdX bs=512 count=1
```

> ⚠️ 请谨慎操作，确保指定正确的设备（如 `/dev/sdb`），避免数据丢失。

## 代码结构说明

| 函数 | 描述 |
|------|------|
| `func__print_string` | 打印以 SI 寄存器指向的字符串 |
| `func__print_char` | 打印 SI 指向的单个字符 |
| `func__wait_for_keypress` | 等待键盘输入，返回 ASCII 码在 AL 中 |
| `func__wait_loop` | 循环等待，直到按下 Ctrl+C |
| `func__power_off` | 尝试 APM 关机，失败则尝试 ACPI，并打印提示信息 |

## 注意事项

- 程序从 `0x7c00` 开始执行（由 `[org 0x7c00]` 指定）
- 使用 BIOS 中断（`int 0x10`、`int 0x16`、`int 0x15`）
- 关机功能在现代模拟器或硬件上可能无效，仅供参考
- 引导扇区必须以 `0xaa55` 结尾

## 示例输出

```
Hello World!
Powering off...
```

或（若 APM 失败）：

```
Hello World!
Fallback shutdown...
```

## 许可证

本项目采用 MIT 许可证，详情请参阅 [LICENSE](./LICENSE) 文件。