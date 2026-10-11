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

  ; pml4[0] -> pdpt
  mov eax, pdpt
  or eax, 0x03
  mov dword [pml4], eax
  mov dword [pml4 + 4], 0

  ; pdpt[0] -> pd
  mov eax, pd
  or eax, 0x03
  mov dword [pdpt], eax
  mov dword [pdpt + 4], 0

  mov edi, pd              ; edi = addr of pd
  mov eax, 0x83            ; start = 0 * 2 mb | p|rw|ps
  mov ecx, 512             ; counter

.fill_pd:
  mov [edi], eax           ; lower 4 bytes
  mov dword [edi + 4], 0   ; upper 4 bytes
  add eax, 0x200000        ; next 2 mb
  add edi, 8               ; next record (8 bytes)
  loop .fill_pd            ; ecx--, repeat if != 0

; read kernel from disk to 0x100000
  cli                      ; disable interrupts during ata
  mov eax, 65              ; kernel lba
  xor ebx, ebx             ; kernel lba (high 16) = 0
  mov edi, 0x100000        ; destination address
  mov ecx, 128             ; 128 sectors = 64 kb
  call ata_read_lba48

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

  jmp code64_seg:anodyx_64 ; far jump to 64-bit code

go32:
  mov esi, msg_arch_error  ; esi = pointer to message
  mov edi, 0xb8000         ; edi = vga buffer
  mov ah, 0x1f             ; attribute: white on blue

.print_loop:
  lodsb                    ; al = [esi], esi++
  test al, al              ; check for null terminator
  jz .hang                 ; if null — done
  mov [edi], ax            ; write char + attribute
  add edi, 2               ; next cell (2 bytes)
  jmp .print_loop

.hang:
  jmp .hang

msg_arch_error:
  db "anodyx_arch error: your host doesn't support long mode (64-bit mode).", 0

[bits 64]

anodyx_64:
  mov ax, data64_seg       ; 0x20
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax

  mov rsp, 0x90000         ; setup 64-bit stack

  mov rax, 0x100000        ; kernel entry point
  jmp rax                  ; transfer control to kernel

%include "gdt.asm"
%include "page_tables.asm"
%include "ata_pio_lba48.asm"
