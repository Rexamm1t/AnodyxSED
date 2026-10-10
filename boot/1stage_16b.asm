[bits 16]
[org 0x7c00]

stage1:
  cli
  xor ax, ax               ; ax = 0
  mov ds, ax               ; ds = 0
  mov es, ax               ; es = 0
  mov ss, ax               ; ss = 0
  mov sp, 0x7c00           ; stack grows down from 0x7c00

  mov [boot_drive], dl     ; save boot drive (before enabling ints)

  sti

  mov si, dap2             ; si = dap2
  mov dl, [boot_drive]     ; dl = boot drive
  mov ah, 0x42             ; extended read
  int 0x13                 ; read stage2
  jc disk_error

  mov si, dap3             ; si = dap3
  mov dl, [boot_drive]     ; dl = boot drive
  mov ah, 0x42             ; extended read
  int 0x13                 ; read stage3
  jc disk_error

  jmp 0x0000:0x8000        ; jump to stage2

disk_error:
  jmp disk_error

boot_drive:
  db 0

dap2:
  db 0x10                  ; packet size (16 bytes)
  db 0x00                  ; reserved
  dw 0x0010                ; 16 sectors = 8 kb
  dw 0x8000                ; offset
  dw 0x0000                ; segment (0x0000:0x8000 = 0x8000)
  dq 0x0000000000000001    ; lba = 1

dap3:
  db 0x10                  ; packet size (16 bytes)
  db 0x00                  ; reserved
  dw 0x0020                ; 32 sectors = 16 kb
  dw 0x0000                ; offset
  dw 0x1000                ; segment (0x1000:0x0000 = 0x10000)
  dq 0x0000000000000011    ; lba = 17

times 510-($-$$) db 0
dw 0xaa55