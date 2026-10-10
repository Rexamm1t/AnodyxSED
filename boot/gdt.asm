; global descriptor table

gdt_start:
  dq 0               ; null descriptor

; code - ring 0, 32bit
gdt_code:
  dw 0xffff          ; bytes 0-1: limit 15..0 (16bit)
  dw 0x0000          ; bytes 2-3: base 15..0 (16bit)
  db 0x00            ; byte 4: base 23..16 (8bit)
  db 10011010b       ; byte 5: access byte (8bit)
  db 11001111b       ; byte 6: flags + limit 19..16 (8bit)
  db 0x00            ; byte 7: base 31..24 (8bit)

; data - ring 0, 32bit
gdt_data:
  dw 0xffff          ; bytes 0-1: limit 15..0 (16bit)
  dw 0x0000          ; bytes 2-3: base 15..0 (16bit)
  db 0x00            ; byte 4: base 23..16 (8bit)
  db 10010010b       ; byte 5: access byte (8bit)
  db 11001111b       ; byte 6: flags + limit 19..16 (8bit)
  db 0x00            ; byte 7: base 31..24 (8bit)

; code - ring 0, 64bit
gdt64_code:
  dw 0x0000          ; limit
  dw 0x0000          ; base 15..0
  db 0x00            ; base 23..16
  db 10011010b       ; access = code, ring 0, readable
  db 10101111b       ; flags: G=1, D/B=0, L=1, AVL=0, limit19..16=0xf
  db 0x00            ; base 31..24

; data - ring 0, 64bit
gdt64_data:
  dw 0x0000          ; limit
  dw 0x0000          ; base 15..0
  db 0x00            ; base 23..16
  db 10010010b       ; access = data, ring 0, readable
  db 11001111b       ; flags: G=1, D/B=1, L=0, AVL=0, limit19..16=0xf
  db 0x00            ; base 31..24

gdt_end:

; pointer to gdt
gdt_descriptor:
  dw gdt_end - gdt_start - 1  ; size(gdt)-1
  dd gdt_start                ; linear start address gdt 

code_seg   equ gdt_code   - gdt_start ; = 0x08
data_seg   equ gdt_data   - gdt_start ; = 0x10
code64_seg equ gdt64_code - gdt_start ; = 0x18
data64_seg equ gdt64_data - gdt_start ; = 0x20
; pointer to gdt
gdt_descriptor:
  dw gdt_end - gdt_start - 1  ; size(gdt)-1
  dd gdt_start                ; linear start address gdt 

code_seg equ gdt_code - gdt_start ; = 0x08
data_seg equ gdt_data - gdt_start ; = 0x10