; anodyx_e_ata pio driver with lba48 support

; ata_wait_bsy
; wait until disk is not busy (bsy = 0)
; clobbers: eax, dx

[bits 32]

ata_wait_bsy:
  mov dx, 0x1f7            ; status port
.loop:
  in al, dx                ; read status
  test al, 0x80            ; bsy bit
  jnz .loop                ; if busy — wait
  ret


; ata_wait_drq
; wait for bsy = 0 and drq = 1 (ready to transfer)
; cf = 0 on success, cf = 1 on error
; clobbers: eax, dx


ata_wait_drq:
  mov dx, 0x1f7            ; status port
.loop:
  in al, dx                ; read status
  test al, 0x80            ; bsy
  jnz .loop
  test al, 0x01            ; err
  jnz .error
  test al, 0x08            ; drq
  jz .loop                 ; not ready yet
  clc                      ; success
  ret
.error:
  stc                      ; error
  ret


; ata_read_lba48
; read sectors via ata pio with lba48
;
; input:
;   eax = lba bits 0-31
;   ebx = lba bits 32-47 (in lower 16 bits)
;   edi = destination address (linear)
;   ecx = sector count (lower 16 bits used)
;
; clobbers: eax, ebx, ecx, edx, edi


ata_read_lba48:
  push eax                 ; save lba low
  push ebx                 ; save lba high
  push ecx                 ; save sector count
  push edi                 ; save destination

  call ata_wait_bsy        ; wait for not busy

; select drive 0, lba mode
  mov dx, 0x1f6            ; drive/head port
  mov al, 0x40             ; bit 6 = lba mode, bit 4 = drive 0
  out dx, al

; high bytes (lba48 sends high first)
  mov dx, 0x1f2            ; sector count port
  mov al, ch               ; high byte of cx
  out dx, al

  mov dx, 0x1f3            ; lba low port (lba 4)
  mov al, bl
  out dx, al

  mov dx, 0x1f4            ; lba mid port (lba 5)
  mov al, bh
  out dx, al

  mov dx, 0x1f5            ; lba high port (lba 6)
  xor al, al               ; always 0 for now
  out dx, al

; low bytes
  mov dx, 0x1f2            ; sector count port
  mov al, cl               ; low byte of cx
  out dx, al

  mov eax, [esp + 12]      ; original eax = lba low 32

  mov dx, 0x1f3
  out dx, al               ; lba 0-7
  shr eax, 8

  mov dx, 0x1f4
  out dx, al               ; lba 8-15
  shr eax, 8

  mov dx, 0x1f5
  out dx, al               ; lba 16-23

; send read sectors ext command
  mov dx, 0x1f7            ; command port
  mov al, 0x24             ; read sectors ext (lba48)
  out dx, al

; restore destination and count
  pop edi                  ; destination
  pop ecx                  ; sector count
  pop ebx                  ; unused
  pop eax                  ; unused

; read loop
  cld                      ; direction flag = 0 (edi increases)

.read_sector:
  call ata_wait_drq
  jc .error                ; cf = 1 — error

; read 256 words = 512 bytes
  mov dx, 0x1f0            ; data port
  mov ebx, 256             ; word counter

.read_word:
  in ax, dx                ; read 16-bit word
  stosw                    ; [edi] = ax, edi += 2
  dec ebx
  jnz .read_word

  dec ecx                  ; next sector
  jnz .read_sector

  ret

.error:
  ; error handler. for now — just return
  ret
