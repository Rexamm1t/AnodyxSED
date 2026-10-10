[bits 16]
[org 0x8000]

pre32:
  in al, 0x92              ; read port 0x92
  or al, 2                 ; set bit 1 (a20 gate)
  and al, 0xfe             ; reset bit 0 (fast reset)
  out 0x92, al             ; write back

  lgdt [gdt_descriptor]    ; load gdt

  mov eax, cr0             ; read cr0
  or eax, 1                ; set cr0.pe
  mov cr0, eax             ; write back

  jmp code_seg:anodyx_32   ; far jump to 32-bit

[bits 32]

anodyx_32:
  mov ax, data_seg         ; 0x10
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax

  mov esp, 0x90000         ; setup stack

  jmp 0x10000              ; jump to stage3

%include "gdt.asm"