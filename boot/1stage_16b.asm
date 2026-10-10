[bits 16]
[org 0x7c00]

stage1:
  cli

  xor ax, ax               ; ax = 0
  mov ds, ax               ; ds = 0
  mov es, ax               ; es = 0
  mov ss, ax               ; ss = 0

  mov sp, 0x7c00

  sti

  mov [boot_drive], dl     ; save disk number

read_stage2:
  mov si, dap              ; si = dap
  mov dl, [boot_drive]     ; dl received disk number
  mov ah, 0x42             ; extended Reading Call
  int 0x13
  jc disk_error            ; cf = 1, read error
  jmp 0x0000:0x8000        ; transition to stage2 (32bit)

disk_error:
  jmp disk_error

boot_drive:
  db 0

dap:
  db 0x10                  ; package size (16 byte)
  db 0x00                  ; reserved (0)
  dw 0x0001                ; number of readable sectors
  dw 0x8000                ; buffer offset in memory (like 0x8000)
  dw 0x0000                ; buffer segment (0x0000)
  dq 0x0000000000000001    ; reading from the first lba sector

times 510-($-$$) db 0
dw 0xaa55