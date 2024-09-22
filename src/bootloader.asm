; Real bootloader in x86 Assembly
[BITS 16]
[ORG 0x7C00]

start:
    ; Set up segment registers
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Print welcome message
    mov si, welcome_msg
    call print_string

    ; Load second sector into memory
    mov ah, 0x02    ; BIOS read sector function
    mov al, 1       ; Number of sectors to read
    mov ch, 0       ; Cylinder number
    mov cl, 2       ; Sector number (1-based, sector 1 is the boot sector)
    mov dh, 0       ; Head number
    mov dl, 0x80    ; Drive number (0x80 for first hard drive)
    mov bx, second_stage    ; ES:BX points to where we want to load
    int 0x13        ; Call BIOS interrupt

    jc disk_error   ; If carry flag is set, there was an error

    ; Jump to second stage
    jmp second_stage

disk_error:
    mov si, error_msg
    call print_string
    jmp $

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

welcome_msg db 'Welcome to My Bootloader!', 13, 10, 0
error_msg db 'Error loading second stage', 13, 10, 0

times 510-($-$$) db 0
dw 0xAA55

second_stage:
    mov si, second_msg
    call print_string
    jmp $

second_msg db 'Second stage loaded successfully!', 13, 10, 0

times 1024-($-$$) db 0
