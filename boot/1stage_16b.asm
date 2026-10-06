[bits 16]
[org 0x7c00]

start:
  cli

  xor ax, ax      ; as = 0

  mov ds, ax      ; ds = 0
  mov es, ax      ; es = 0
  mov ss, ax      ; ss = 0

  mov sp, 0x7c00

  sti

uloop:
  jmp uloop

times 510-($-$$) db 0
dw 0xaa55
