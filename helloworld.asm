[org 0x7c00] ; BIOS加载程序到0x7c00地址

start:
    mov si, hello ; 将字符串地址存储在SI寄存器中(传参)
    call func__print_string ; 调用打印字符串函数

    call func__wait_loop ; 调用等待按键函数

    call func__power_off ; 调用关机函数

; === Functions ===
; 函数注解规范：
; 函数名(参数列表) -> 返回值

; Function: wait_loop() -> void
; 退出条件： 按下Ctrl+C
func__wait_loop:
.loop:
    call func__wait_for_keypress ; 调用等待按键函数
    cmp byte al, 0x03 ; 检查是否按下Ctrl+C
    jz .done ; 如果是，则结束函数
    jmp .loop ; 继续循环
.done:
    ret ; 函数结束，返回

; Function: print_string(SI: *string) -> void
func__print_string:
.loop:
    call func__print_char ; 调用打印字符函数
    inc si ; 移动到字符串的下一个字符
    cmp byte [si], 0 ; 检查是否到达字符串的末尾
    jnz .loop  ; 如果不是，则继续循环
.done:
    ret ; 函数结束，返回

; Function: print_char(SI: *char) -> void
func__print_char:
    mov ah, 0x0e ; BIOS中断，显示字符
    mov al, [si] ; 从字符串中取出一个字符
    int 0x10 ; BIOS中断调用
    ret ; 返回调用函数

; Function: wait_for_keypress() -> AL: char
func__wait_for_keypress:
    mov ah, 0x00 ; BIOS中断，等待按键
    int 0x16 ; BIOS中断调用
    ret ; 

; Function: power_off() -> void
func__power_off:
    mov si, power_off_message ; 将字符串地址存储在SI寄存器中(传参)
    call func__print_string ; 调用打印字符串函数
    
    mov ax, 0x5307      ; APM 设置电源状态
    mov bx, 0x0001      ; 所有设备
    mov cx, 0x0003      ; 关机 (3 = power off)
    int 0x15

    jc .fallback_shutdown ; 如果APM调用失败，则跳转到fallback_shutdown

    jmp $ ; 启用无限循环，防止程序继续执行

.fallback_shutdown:
    mov si, fallback_shutdown_message ; 将字符串地址存储在SI寄存器中(传参)
    call func__print_string ; 调用打印字符串函数

    mov ax, 0x3400      ; ACPI 关机
    mov bx, 0x0001
    int 0x15

    jmp $ ; 启用无限循环，防止程序继续执行

; === Data Section ===
hello: db 'Hello World!',0
power_off_message: db 'Powering off...',0
fallback_shutdown_message: db 'Fallback shutdown...',0

; === Other Data ===
times 510 - ($-$$) db 0  ; 填充剩余空间
dw 0xaa55                ; 引导扇区 Magic Number