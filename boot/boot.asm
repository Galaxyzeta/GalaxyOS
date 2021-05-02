[org 0x7c00]			; specify the base address of the section of the file.
KERNEL_OFFSET equ 0x1000
	
	mov [ BOOT_DRIVE ], dl
	
	mov ax, 0			
	mov bp, 0x9000
	mov sp, bp

	mov ax, 0			; Set data segment to where we're loaded
	mov ds, ax			; ds = 0x7c00

	mov si, text_string	; Put string position into SI
	call print_string	; Call our string-printing routine
	call load_kernel	; Call kernel load
	call switch_to_pm	; will never go back

	jmp $				; Jump here - infinite loop!

%include "gdt.asm"
%include "print_string.asm"
%include "switch_to_pm.asm"
%include "print_string_pm.asm"
%include "disk.asm"

[bits 16]
load_kernel:
	mov si , text_loading_kernel ; Print a message to say we are loading the kernel
	call print_string
	mov bx , KERNEL_OFFSET 		; Set -up parameters for our disk_load routine , so
	mov dh , 30 				; that we load the first 15 sectors ( excluding
	mov dl , [ BOOT_DRIVE ] 	; the boot sector ) from the boot disk ( i.e. our
	call disk_load 				; kernel code ) to address KERNEL_OFFSET
	mov si , text_loading_ok    ; Print a message to say we are loading the kernel
	call print_string
	ret

[bits 32]
begin_pm:
	mov ebx, text_string_pm
	call print_string_pm
	call KERNEL_OFFSET
	jmp $

; Global variables
text_string db 'This is my cool new OS!', 0
text_string_pm db 'Landed in 32-bit PM mode!', 0
text_loading_kernel db "Loading kernel...", 0
text_loading_ok db "Loading kernel OK! ", 0
BOOT_DRIVE db 0

times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
dw 0xAA55		; The standard PC boot signature

; == Note ==
; ESP is the current stack pointer.
; EBP is the base pointer for the current stack frame.