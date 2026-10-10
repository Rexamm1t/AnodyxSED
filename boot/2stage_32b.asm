[bits 16]
[org 0x8000]

pre32:
  in  al, 0x92            ; read 0x92 port
  or  al, 2               ; write 1 bit (a20 gate)
  and al, 0xfe            ; reset 0 bit (fast reset)
  out 0x92, al            ; write back

  lgdt [gdt_descriptor]   ; load gdt

  ; enable protected mode

  ; cr0.pe
  mov eax, cr0
  or  eax, 1
  mov cr0, eax

  jmp code_seg:anodyx_32

[bits 32]

anodyx_32:
  mov ax, data_seg        ; 0x10
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax

  mov esp, 0x90000

loop:
  jmp loop

%include "gdt.asm"