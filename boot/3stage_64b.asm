[bits 32]
[org 0x10000]

pre64:
  mov ax, data_seg         ; 0x10
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax

  mov esp, 0x90000         ; setup 32-bit stack

; fill page tables
  mov dword [pml4], pdpt | 0x03    ; pml4[0] -> pdpt, flags p|rw
  mov dword [pml4 + 4], 0          ; upper 4 bytes

  mov dword [pdpt], pd | 0x03      ; pdpt[0] -> pd, flags p|rw
  mov dword [pdpt + 4], 0          ; upper 4 bytes

  mov edi, pd              ; edi = addr of pd
  mov eax, 0x83            ; start = 0 * 2mb | p|rw|ps
  mov ecx, 512             ; counter

.fill_pd:
  mov [edi], eax           ; lower 4 bytes
  mov dword [edi + 4], 0   ; upper 4 bytes
  add eax, 0x200000        ; next 2 mb
  add edi, 8               ; next record (8 bytes)
  loop .fill_pd            ; ecx--, repeat if != 0

check_cpu64:
  mov eax, 0x80000000      ; get max extended leaf
  cpuid
  cmp eax, 0x80000001
  jb go32                  ; extended leaf not available

  mov eax, 0x80000001      ; check lm bit
  cpuid
  test edx, (1 << 29)      ; bit 29 = long mode available
  jz go32                  ; if 0 — not available

enable_pae:
  mov eax, cr4
  or eax, (1 << 5)         ; cr4.pae
  mov cr4, eax

load_cr3:
  mov eax, pml4            ; physical addr of pml4
  mov cr3, eax

enable_lme:
  mov ecx, 0xc0000080      ; ia32_efer msr
  rdmsr
  or eax, (1 << 8)         ; efer.lme
  wrmsr

enable_paging:
  mov eax, cr0
  or eax, (1 << 31)        ; cr0.pg
  mov cr0, eax

  lgdt [gdt_descriptor]    ; load gdt with 64-bit descriptors

  jmp code64_seg:anodyx_64 ; far jump to 64-bit

go32:
  jmp go32                 ; no long mode, halt

[bits 64]

anodyx_64:
  mov ax, data64_seg       ; 0x20
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax

  mov rsp, 0x90000         ; setup 64-bit stack

in64:
  jmp in64                 ; hang

%include "gdt.asm"
%include "page_tables.asm"