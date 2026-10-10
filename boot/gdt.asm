; global descriptor table

gdt_start:
  dq 0                     ; null descriptor

; code — ring 0, 32-bit
gdt_code:
  dw 0xffff                ; bytes 0-1: limit 15..0
  dw 0x0000                ; bytes 2-3: base 15..0
  db 0x00                  ; byte 4: base 23..16
  db 10011010b             ; byte 5: access byte
  db 11001111b             ; byte 6: flags + limit 19..16
  db 0x00                  ; byte 7: base 31..24

; data — ring 0, 32-bit
gdt_data:
  dw 0xffff                ; bytes 0-1: limit 15..0
  dw 0x0000                ; bytes 2-3: base 15..0
  db 0x00                  ; byte 4: base 23..16
  db 10010010b             ; byte 5: access byte
  db 11001111b             ; byte 6: flags + limit 19..16
  db 0x00                  ; byte 7: base 31..24

; code — ring 0, 64-bit
gdt64_code:
  dw 0x0000                ; limit (ignored in 64-bit)
  dw 0x0000                ; base 15..0
  db 0x00                  ; base 23..16
  db 10011010b             ; access = code, ring 0, readable
  db 10101111b             ; flags: g=1, d/b=0, l=1, avl=0
  db 0x00                  ; base 31..24

; data — ring 0, 64-bit
gdt64_data:
  dw 0x0000                ; limit (ignored in 64-bit)
  dw 0x0000                ; base 15..0
  db 0x00                  ; base 23..16
  db 10010010b             ; access = data, ring 0, readable
  db 11001111b             ; flags: g=1, d/b=1, l=0, avl=0
  db 0x00                  ; base 31..24

gdt_end:

gdt_descriptor:
  dw gdt_end - gdt_start - 1   ; size(gdt) - 1
  dd gdt_start                 ; linear start address of gdt

code_seg    equ gdt_code    - gdt_start   ; = 0x08
data_seg    equ gdt_data    - gdt_start   ; = 0x10
code64_seg  equ gdt64_code  - gdt_start   ; = 0x18
data64_seg  equ gdt64_data  - gdt_start   ; = 0x20