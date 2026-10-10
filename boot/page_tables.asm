; page tables for long mode
; identity-map first 1 gb using 2 mb pages

align 4096
pml4:
  times 512 dq 0

align 4096
pdpt:
  times 512 dq 0

align 4096
pd:
  times 512 dq 0