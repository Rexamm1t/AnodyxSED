[bits 64]

section .text.entry

global _start

extern anodyx_kernel
extern bss_start
extern bss_end

_start:
  cld                      ; clear direction flag (required by c abi)

  mov rdi, bss_start       ; start of .bss
  mov rcx, bss_end
  sub rcx, rdi             ; rcx = size of .bss
  xor al, al               ; al = 0

  rep stosb                ; write al to [rdi] rcx times

  call anodyx_kernel
  jmp $